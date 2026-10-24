from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(prefix="/api/v1/robot", tags=["ESP32 Robot"])

class RobotControlRequest(BaseModel):
    command: str  # FORWARD, BACKWARD, LEFT, RIGHT, STOP
    speed: int = 200

@router.post("/control")
async def control_robot(payload: RobotControlRequest):
    return {
        "status": "executed",
        "command": payload.command,
        "speed": payload.speed,
        "message": f"Robot executing {payload.command} for Gowrob."
    }

@router.get("/status")
async def get_robot_status():
    return {
        "connected": True,
        "battery": "92%",
        "camera_feed": "rtsp://192.168.1.100:8554/mjpeg",
        "sonar_distance_cm": 45
    }
