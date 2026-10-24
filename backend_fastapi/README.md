# JX AI Companion — Python FastAPI Backend

FastAPI backend for **JX AI Companion**, providing Gemini AI agent capabilities, SQLite persistent memory, image vision processing, ESP32-S3 CAM robot telemetry, and WebSocket real-time audio streams.

---

## 🛠️ How to Run Backend

### 1. Install Dependencies
```bash
cd backend_fastapi
pip install -r requirements.txt
```

### 2. Configure Environment
Set your Gemini API Key in `.env` or export environment variable:
```bash
export GEMINI_API_KEY="your-gemini-api-key"
```

### 3. Start Server
```bash
python main.py
```
Or with Uvicorn:
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

---

## 📌 API Endpoints Overview
- `GET /health` — Backend health check & configuration status
- `POST /api/v1/chat` — Chat with JX (Bengali & English, Gowrob companion context)
- `GET /api/v1/memory/{user_id}` — Get persistent memories
- `POST /api/v1/memory` — Save a memory key-value pair
- `POST /api/v1/vision/analyze` — Multimodal camera image vision AI
- `POST /api/v1/robot/control` — ESP32-S3 CAM robot movement commands
- `WS /ws/live-chat` — Real-time WebSocket streaming audio/text channel
