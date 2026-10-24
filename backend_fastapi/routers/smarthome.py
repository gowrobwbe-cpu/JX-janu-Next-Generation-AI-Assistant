from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(prefix="/api/v1/smarthome", tags=["Smart Home"])

class DeviceStateRequest(BaseModel):
    device_id: str
    is_on: bool

@router.get("/devices")
async def get_devices():
    return [
        {"id": "light-1", "name": "Gowrob's Room Light", "type": "light", "is_on": True},
        {"id": "fan-1", "name": "Ambient Cooling Fan", "type": "fan", "is_on": False},
        {"id": "robot-1", "name": "ESP32 CAM Robot", "type": "robot", "is_on": True},
    ]

@router.post("/device/toggle")
async def toggle_device(payload: DeviceStateRequest):
    return {
        "status": "updated",
        "device_id": payload.device_id,
        "is_on": payload.is_on,
        "message": f"Device {payload.device_id} state set to {payload.is_on}"
    }
