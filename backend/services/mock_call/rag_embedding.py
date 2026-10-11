import math

from google import genai
from google.genai import types

from config import settings


def pgvector_literal(embedding: list[float]) -> str:
    expected_dimensions = settings.rag_embedding_dimensions
    if len(embedding) != expected_dimensions:
        raise ValueError(
            "Invalid embedding dimensions: "
            f"expected {expected_dimensions}, "
            f"received {len(embedding)}."
        )
    if not all(math.isfinite(value) for value in embedding):
        raise ValueError("Embedding contains a non-finite value.")

    return (
        "["
        + ",".join(format(value, ".17g") for value in embedding)
        + "]"
    )


class GeminiEmbeddingService:
    def __init__(self) -> None:
        if settings.gemini_api_key is None:
            raise RuntimeError(
                "GEMINI_API_KEY is not configured."
            )

        api_key = settings.gemini_api_key.get_secret_value()
        if not api_key:
            raise RuntimeError("GEMINI_API_KEY is empty.")

        self.client = genai.Client(api_key=api_key)
        self.model = settings.rag_embedding_model
        self.dimensions = settings.rag_embedding_dimensions

    def embed_document(
        self,
        *,
        content: str,
        title: str,
    ) -> list[float]:
        return self._embed(
            content=content,
            task_type="RETRIEVAL_DOCUMENT",
            title=title.strip() or None,
        )

    def embed_query(self, query: str) -> list[float]:
        return self._embed(
            content=query,
            task_type="QUESTION_ANSWERING",
        )

    def _embed(
        self,
        *,
        content: str,
        task_type: str,
        title: str | None = None,
    ) -> list[float]:
        content = content.strip()
        if not content:
            raise ValueError("Embedding content cannot be empty.")

        response = self.client.models.embed_content(
            model=self.model,
            contents=content,
            config=types.EmbedContentConfig(
                task_type=task_type,
                title=title,
                output_dimensionality=self.dimensions,
            ),
        )

        if not response.embeddings:
            raise RuntimeError("Gemini returned no embedding.")

        values = response.embeddings[0].values
        if not values:
            raise RuntimeError("Gemini returned an empty embedding.")

        embedding = [float(value) for value in values]
        if len(embedding) != self.dimensions:
            raise RuntimeError(
                "Unexpected embedding dimensions: "
                f"expected {self.dimensions}, "
                f"received {len(embedding)}."
            )

        magnitude = math.sqrt(
            sum(value * value for value in embedding)
        )
        if magnitude == 0:
            raise RuntimeError(
                "Cannot normalise a zero embedding."
            )

        return [value / magnitude for value in embedding]
