from fastapi import APIRouter, WebSocket

from services.mock_call.gemini_live import (
    GeminiLivePracticeSession,
)


router = APIRouter(
    prefix="/mock-call",
    tags=["mock-call"],
)


@router.websocket("/live")
async def live_practice_call(websocket: WebSocket) -> None:
    """Create one private, in-memory Gemini Live session per browser socket."""
    await websocket.accept()
    session = GeminiLivePracticeSession(websocket)
    await session.run()
