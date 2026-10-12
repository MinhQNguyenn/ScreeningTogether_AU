from datetime import date

from fastapi import APIRouter, File, Form, Header, Response, UploadFile

from services.mock_call.rag_admin import (
    DocumentUploadResponse,
    handle_document_upload,
)


router = APIRouter(prefix="/rag-admin", tags=["rag-admin"])


@router.post("/documents", response_model=DocumentUploadResponse)
async def upload_rag_document(
    response: Response,
    file: UploadFile = File(...),
    title: str = Form(...),
    publisher: str = Form(...),
    source_url: str = Form(...),
    published_at: date | None = Form(None),
    password: str | None = Header(
        default=None,
        alias="X-RAG-Admin-Key",
    ),
) -> DocumentUploadResponse:
    result = await handle_document_upload(
        file=file,
        title=title,
        publisher=publisher,
        source_url=source_url,
        published_at=published_at,
        password=password,
    )
    response.headers["Cache-Control"] = "no-store"
    return result
