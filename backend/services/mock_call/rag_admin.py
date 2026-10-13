import hmac
import logging
from datetime import date

from fastapi import HTTPException, UploadFile, status
from pydantic import BaseModel, ValidationError
from starlette.concurrency import run_in_threadpool

from config import settings
from services.mock_call.rag_ingestion import (
    DocumentMetadata,
    ingest_uploaded_document,
)


logger = logging.getLogger(__name__)


class DocumentUploadResponse(BaseModel):
    document_id: int
    file_name: str
    changed: bool
    page_count: int
    indexed_chunks: int
    filtered_chunks: int
    message: str


def _check_password(password: str | None) -> None:
    if settings.rag_admin_secret is None:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="RAG document upload is not configured.",
        )

    expected = settings.rag_admin_secret.get_secret_value()
    provided = password or ""
    if not expected or not hmac.compare_digest(
        provided.encode("utf-8"),
        expected.encode("utf-8"),
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid upload password.",
        )


async def _read_pdf(file: UploadFile) -> tuple[str, bytes]:
    file_name = (file.filename or "").replace("\\", "/").split("/")[-1]
    if not file_name.lower().endswith(".pdf"):
        raise HTTPException(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail="Only PDF files are supported.",
        )

    try:
        content = await file.read(settings.rag_upload_max_bytes + 1)
    finally:
        await file.close()

    if not content:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail="The uploaded PDF is empty.",
        )
    if len(content) > settings.rag_upload_max_bytes:
        max_mb = settings.rag_upload_max_bytes // (1024 * 1024)
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail=f"PDF is too large. Maximum size is {max_mb} MB.",
        )
    return file_name, content


async def handle_document_upload(
    file: UploadFile,
    title: str,
    publisher: str,
    source_url: str,
    published_at: date | None,
    password: str | None,
) -> DocumentUploadResponse:
    _check_password(password)
    file_name, pdf_data = await _read_pdf(file)

    try:
        metadata = DocumentMetadata(
            title=title,
            publisher=publisher,
            source_url=source_url,
            published_at=published_at,
        )
        result = await run_in_threadpool(
            ingest_uploaded_document,
            file_name=file_name,
            pdf_data=pdf_data,
            metadata=metadata,
        )
    except ValidationError as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail=exc.errors(include_input=False),
        ) from exc
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail=str(exc),
        ) from exc
    except Exception as exc:
        logger.exception("RAG document upload failed")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="The document could not be indexed.",
        ) from exc

    return DocumentUploadResponse(
        document_id=result.document_id,
        file_name=result.file_name,
        changed=result.changed,
        page_count=result.page_count,
        indexed_chunks=result.indexed_chunks,
        filtered_chunks=result.filtered_chunks,
        message=(
            "Document indexed successfully."
            if result.changed
            else "Document was already indexed; metadata was updated."
        ),
    )
