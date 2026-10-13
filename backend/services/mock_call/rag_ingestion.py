import hashlib
import math
import re
from collections import Counter
from dataclasses import dataclass
from datetime import date

import pymupdf
from pydantic import BaseModel, Field, HttpUrl, field_validator
from sqlalchemy import text

from config import settings
from db.session import SessionLocal
from services.mock_call.rag_embedding import (
    GeminiEmbeddingService,
    pgvector_literal,
)


CHUNK_WORDS = 180
CHUNK_OVERLAP = 30
PAGE_FOOTER = re.compile(r"\bpage\s+\d+\s+of\s+\d+\b", re.I)
PAGE_NUMBER = re.compile(r"^(?:page\s*)?\d+$", re.I)


class DocumentMetadata(BaseModel):
    title: str = Field(min_length=2, max_length=300)
    publisher: str = Field(min_length=2, max_length=200)
    source_url: HttpUrl
    published_at: date | None = None

    @field_validator("title", "publisher")
    @classmethod
    def strip_text(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError("Value cannot be blank.")
        return value


@dataclass(frozen=True)
class PdfPage:
    page_number: int
    text: str


@dataclass(frozen=True)
class TextChunk:
    page_number: int
    chunk_index: int
    content: str


@dataclass(frozen=True)
class DocumentLoadResult:
    document_id: int
    file_name: str
    changed: bool
    page_count: int
    indexed_chunks: int
    filtered_chunks: int


def extract_pdf_pages(pdf_data: bytes) -> list[PdfPage]:
    if not pdf_data.lstrip().startswith(b"%PDF-"):
        raise ValueError("The uploaded file is not a valid PDF.")

    try:
        document = pymupdf.open(stream=pdf_data, filetype="pdf")
    except Exception as exc:
        raise ValueError("The uploaded PDF could not be opened.") from exc

    pages: list[PdfPage] = []
    with document:
        if document.needs_pass:
            raise ValueError("Password-protected PDFs are not supported.")
        if document.page_count > settings.rag_upload_max_pages:
            raise ValueError(
                f"PDFs are limited to {settings.rag_upload_max_pages} pages."
            )

        for index, page in enumerate(document):
            page_text = _clean_text(page.get_text("text", sort=True))
            if page_text:
                pages.append(PdfPage(index + 1, page_text))

    if not pages:
        raise ValueError(
            "No selectable text was found. The PDF may require OCR."
        )
    return pages


def _clean_text(value: str) -> str:
    value = value.replace("\u00ad", "").replace("\u00a0", " ")
    value = re.sub(r"(?<=\w)-\n(?=\w)", "", value)
    value = re.sub(r"[ \t]+", " ", value)
    return re.sub(r"\n{3,}", "\n\n", value).strip()


def _lines(value: str) -> list[str]:
    return [
        re.sub(r"\s+", " ", line).strip()
        for line in value.splitlines()
        if line.strip()
    ]


def clean_boilerplate(pages: list[PdfPage]) -> list[PdfPage]:
    edge_counts: Counter[str] = Counter()
    for page in pages:
        lines = _lines(page.text)
        edge_counts.update(
            {line.casefold() for line in lines[:3] + lines[-3:]}
        )

    repeated = {
        line
        for line, count in edge_counts.items()
        if count >= max(2, math.ceil(len(pages) * 0.6))
    }

    cleaned_pages: list[PdfPage] = []
    for page in pages:
        kept_lines = []
        for line in _lines(page.text):
            lower = line.casefold()
            is_boilerplate = (
                lower in repeated
                or lower.startswith("home >")
                or lower.startswith("tags:")
                or PAGE_FOOTER.search(line)
                or PAGE_NUMBER.fullmatch(line)
            )
            if not is_boilerplate:
                kept_lines.append(line)

        if kept_lines:
            cleaned_pages.append(
                PdfPage(page.page_number, "\n".join(kept_lines))
            )
    return cleaned_pages


def chunk_pages(pages: list[PdfPage]) -> list[TextChunk]:
    chunks: list[TextChunk] = []
    step = CHUNK_WORDS - CHUNK_OVERLAP

    for page in pages:
        words = page.text.split()
        for chunk_index, start in enumerate(range(0, len(words), step)):
            chunk_words = words[start : start + CHUNK_WORDS]
            chunks.append(
                TextChunk(
                    page_number=page.page_number,
                    chunk_index=chunk_index,
                    content=" ".join(chunk_words),
                )
            )
            if start + CHUNK_WORDS >= len(words):
                break
    return chunks


def filter_indexable_chunks(chunks: list[TextChunk]) -> list[TextChunk]:
    return [
        chunk
        for chunk in chunks
        if len(chunk.content.split()) >= 20
        and len(chunk.content) >= 100
    ]


def _find_document(session, file_name: str):
    return session.execute(
        text(
            """
            SELECT
                d.document_id,
                d.file_hash,
                d.embedding_model,
                d.embedding_dimensions,
                d.pipeline_version,
                COUNT(c.chunk_id) AS chunk_count,
                COUNT(c.embedding) AS embedded_count
            FROM rag.document AS d
            LEFT JOIN rag.chunk AS c
                ON c.document_id = d.document_id
            WHERE d.file_name = :file_name
            GROUP BY d.document_id
            """
        ),
        {"file_name": file_name},
    ).mappings().one_or_none()


def _reuse_current_document(
    file_name: str,
    file_hash: str,
    metadata: DocumentMetadata,
    chunk_count: int,
) -> int | None:
    with SessionLocal.begin() as session:
        document = _find_document(session, file_name)
        is_current = (
            document
            and document["file_hash"] == file_hash
            and document["embedding_model"] == settings.rag_embedding_model
            and document["embedding_dimensions"]
            == settings.rag_embedding_dimensions
            and document["pipeline_version"] == settings.rag_pipeline_version
            and document["chunk_count"] == chunk_count
            and document["embedded_count"] == chunk_count
        )
        if not is_current:
            return None

        session.execute(
            text(
                """
                UPDATE rag.document
                SET title = :title,
                    publisher = :publisher,
                    source_url = :source_url,
                    published_at = :published_at
                WHERE document_id = :document_id
                """
            ),
            {
                "document_id": document["document_id"],
                "title": metadata.title,
                "publisher": metadata.publisher,
                "source_url": str(metadata.source_url),
                "published_at": metadata.published_at,
            },
        )
        return int(document["document_id"])


def _save_document(
    file_name: str,
    file_hash: str,
    metadata: DocumentMetadata,
    chunks: list[TextChunk],
    embeddings: list[list[float]],
) -> int:
    document_values = {
        "file_name": file_name,
        "file_hash": file_hash,
        "title": metadata.title,
        "publisher": metadata.publisher,
        "source_url": str(metadata.source_url),
        "published_at": metadata.published_at,
        "embedding_model": settings.rag_embedding_model,
        "embedding_dimensions": settings.rag_embedding_dimensions,
        "pipeline_version": settings.rag_pipeline_version,
    }

    with SessionLocal.begin() as session:
        existing_id = session.execute(
            text(
                """
                SELECT document_id
                FROM rag.document
                WHERE file_name = :file_name
                """
            ),
            {"file_name": file_name},
        ).scalar_one_or_none()

        if existing_id is None:
            document_id = session.execute(
                text(
                    """
                    INSERT INTO rag.document (
                        file_name, file_hash, title, publisher, source_url,
                        published_at, embedding_model,
                        embedding_dimensions, pipeline_version
                    ) VALUES (
                        :file_name, :file_hash, :title, :publisher, :source_url,
                        :published_at, :embedding_model,
                        :embedding_dimensions, :pipeline_version
                    )
                    RETURNING document_id
                    """
                ),
                document_values,
            ).scalar_one()
        else:
            document_id = int(existing_id)
            session.execute(
                text("DELETE FROM rag.chunk WHERE document_id = :document_id"),
                {"document_id": document_id},
            )
            session.execute(
                text(
                    """
                    UPDATE rag.document
                    SET file_hash = :file_hash,
                        title = :title,
                        publisher = :publisher,
                        source_url = :source_url,
                        published_at = :published_at,
                        embedding_model = :embedding_model,
                        embedding_dimensions = :embedding_dimensions,
                        pipeline_version = :pipeline_version,
                        indexed_at = NOW()
                    WHERE document_id = :document_id
                    """
                ),
                {**document_values, "document_id": document_id},
            )

        session.execute(
            text(
                """
                INSERT INTO rag.chunk (
                    document_id, page_number, chunk_index, content, embedding
                ) VALUES (
                    :document_id, :page_number, :chunk_index, :content,
                    CAST(:embedding AS public.vector)
                )
                """
            ),
            [
                {
                    "document_id": document_id,
                    "page_number": chunk.page_number,
                    "chunk_index": chunk.chunk_index,
                    "content": chunk.content,
                    "embedding": pgvector_literal(embedding),
                }
                for chunk, embedding in zip(chunks, embeddings)
            ],
        )
        return int(document_id)


def ingest_uploaded_document(
    *,
    file_name: str,
    pdf_data: bytes,
    metadata: DocumentMetadata,
) -> DocumentLoadResult:
    if not file_name or len(file_name) > 255:
        raise ValueError("The PDF file name is invalid.")

    file_hash = hashlib.sha256(pdf_data).hexdigest()
    pages = clean_boilerplate(extract_pdf_pages(pdf_data))
    generated_chunks = chunk_pages(pages)
    chunks = filter_indexable_chunks(generated_chunks)

    if not chunks:
        raise ValueError("No indexable text was found in the PDF.")
    if len(chunks) > settings.rag_upload_max_chunks:
        raise ValueError(
            f"PDFs are limited to {settings.rag_upload_max_chunks} chunks."
        )

    document_id = _reuse_current_document(
        file_name,
        file_hash,
        metadata,
        len(chunks),
    )
    changed = document_id is None

    if changed:
        embedding_service = GeminiEmbeddingService()
        embeddings = [
            embedding_service.embed_document(
                content=chunk.content,
                title=metadata.title,
            )
            for chunk in chunks
        ]
        document_id = _save_document(
            file_name,
            file_hash,
            metadata,
            chunks,
            embeddings,
        )

    return DocumentLoadResult(
        document_id=document_id,
        file_name=file_name,
        changed=changed,
        page_count=len(pages),
        indexed_chunks=len(chunks),
        filtered_chunks=len(generated_chunks) - len(chunks),
    )
