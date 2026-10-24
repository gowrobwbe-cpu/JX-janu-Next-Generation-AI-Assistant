import base64
from fastapi import APIRouter
from pydantic import BaseModel
from services.gemini_agent import JXGeminiAgent

router = APIRouter(prefix="/api/v1/vision", tags=["Vision AI"])
agent = JXGeminiAgent()

class VisionRequest(BaseModel):
    image_base64: str
    prompt: str = "Analyze this image for Gowrob in a cute anime companion voice."

@router.post("/analyze")
async def analyze_vision(payload: VisionRequest):
    try:
        image_bytes = base64.b64decode(payload.image_base64)
        description = await agent.analyze_image(image_bytes, payload.prompt)
        return {"status": "success", "description": description}
    except Exception as e:
        return {"status": "error", "message": str(e)}
