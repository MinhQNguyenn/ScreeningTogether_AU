from fastapi import APIRouter, WebSocket, status

from services.mock_call.gemini_live import (
    GeminiLivePracticeSession,
)


router = APIRouter(
    prefix="/mock-call",
    tags=["mock-call"],
)


origins = [
    "http://localhost:5173",
    "http://localhost:5174",
    "http://127.0.0.1:5173",
    "http://127.0.0.1:5174",
    "https://d3dsx64353i3rp.cloudfront.net",
    "https://screeningtogether.app"
]

def is_allowed_origin(websocket: WebSocket) -> bool:
    origin = websocket.headers.get("origin")
    return origin in origins


@router.websocket("/live")
async def live_practice_call(websocket: WebSocket) -> None:
    """Create one private, in-memory Gemini Live session per browser socket."""
    if not is_allowed_origin(websocket):
        await websocket.close(
            code=status.WS_1008_POLICY_VIOLATION,
        )
        return
        
    await websocket.accept()
    session = GeminiLivePracticeSession(websocket)
    await session.run()
