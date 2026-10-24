from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from config import settings
from database import init_db
from routers import chat, memory, vision, esp32_robot, smarthome
from services.gemini_agent import JXGeminiAgent

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.VERSION,
    description="Python FastAPI backend for JX AI Companion created by Gowrob."
)

# Enable CORS for Flutter & Web Clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(chat.router)
app.include_router(memory.router)
app.include_router(vision.router)
app.include_router(esp32_robot.router)
app.include_router(smarthome.router)

@app.on_event("startup")
async def startup_event():
    await init_db()

@app.get("/health")
async def health_check():
    return {
        "status": "online",
        "app_name": settings.APP_NAME,
        "creator": settings.CREATOR_NAME,
        "gemini_api_configured": bool(settings.GEMINI_API_KEY)
    }

# Gemini Live WebSocket Endpoint for Real-time Continuous Conversation
agent = JXGeminiAgent()

@app.websocket("/ws/live-chat")
async def websocket_live_chat(websocket: WebSocket):
    await websocket.accept()
    await websocket.send_text("Connected to JX Live Stream! Gowrob, I am ready to talk with you 💕")
    try:
        while True:
            data = await websocket.receive_text()
            reply = await agent.generate_response(data, user_name="Gowrob")
            await websocket.send_text(reply)
    except WebSocketDisconnect:
        print("WebSocket client disconnected.")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
