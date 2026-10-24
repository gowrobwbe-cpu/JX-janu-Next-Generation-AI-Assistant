from fastapi import APIRouter, Depends
from pydantic import BaseModel
from services.gemini_agent import JXGeminiAgent

router = APIRouter(prefix="/api/v1/chat", tags=["Chat"])
agent = JXGeminiAgent()

class ChatRequest(BaseModel):
    message: str
    user_id: str = "gowrob"

class ChatResponse(BaseModel):
    reply: str
    emotion: str = "happy"

@router.post("", response_model=ChatResponse)
async def chat_endpoint(payload: ChatRequest):
    reply = await agent.generate_response(payload.message, user_name="Gowrob")
    return ChatResponse(reply=reply, emotion="happy")
