import logging
from dataclasses import dataclass

from sqlalchemy import text

from db.session import SessionLocal
from services.mock_call.rag_embedding import (
    GeminiEmbeddingService,
    pgvector_literal,
)


logger = logging.getLogger(__name__)


@dataclass(frozen=True)
class KnowledgeEntry:
    chunk_id: int
    content: str
    source_title: str
    publisher: str
    source_url: str | None
    page_number: int
    similarity: float


def search_screening_knowledge(
    query: str,
    limit: int = 3,
    min_similarity: float = 0.60,
) -> list[KnowledgeEntry]:
    query = query.strip()
    if len(query) < 2:
        logger.info("RAG search skipped: query_too_short=true")
        return []
    if not 1 <= limit <= 20:
        raise ValueError("Search limit must be between 1 and 20.")
    if not 0 <= min_similarity <= 1:
        raise ValueError(
            "Minimum similarity must be between 0 and 1."
        )

    logger.info(
        "RAG search started: query_chars=%d, limit=%d",
        len(query),
        limit,
    )
    query_embedding = GeminiEmbeddingService().embed_query(query)
    embedding_literal = pgvector_literal(query_embedding)

    statement = text(
        """
        SELECT
            c.chunk_id,
            d.title AS source_title,
            d.publisher,
            d.source_url,
            c.page_number,
            c.content,
            1 - (
                c.embedding
                <=> CAST(:query_embedding AS public.vector)
            ) AS similarity
        FROM rag.chunk AS c
        JOIN rag.document AS d
            ON d.document_id = c.document_id
        WHERE c.embedding IS NOT NULL
          AND (
                c.embedding
                <=> CAST(:query_embedding AS public.vector)
            ) <= :max_distance
        ORDER BY
            c.embedding
            <=> CAST(:query_embedding AS public.vector)
        LIMIT :limit
        """
    )

    with SessionLocal() as session:
        rows = session.execute(
            statement,
            {
                "query_embedding": embedding_literal,
                "max_distance": 1.0 - min_similarity,
                "limit": limit,
            },
        ).mappings().all()

    results = [
        KnowledgeEntry(
            chunk_id=row["chunk_id"],
            content=row["content"],
            source_title=row["source_title"],
            publisher=row["publisher"],
            source_url=row["source_url"],
            page_number=row["page_number"],
            similarity=round(float(row["similarity"]), 4),
        )
        for row in rows
    ]

    logger.info(
        "RAG search completed: result_count=%d",
        len(results),
    )
    return results
