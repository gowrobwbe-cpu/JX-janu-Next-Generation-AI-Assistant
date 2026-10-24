from fastapi import APIRouter
from pydantic import BaseModel
import aiosqlite

router = APIRouter(prefix="/api/v1/memory", tags=["Memory"])
DB_FILE = "jx_companion_backend.db"

class MemoryItem(BaseModel):
    user_id: str = "gowrob"
    key: str
    value: str

@router.get("/{user_id}")
async def get_user_memories(user_id: str):
    async with aiosqlite.connect(DB_FILE) as db:
        async with db.execute("SELECT key, value FROM memories WHERE user_id = ?", (user_id,)) as cursor:
            rows = await cursor.fetchall()
            return [{"key": row[0], "value": row[1]} for row in rows]

@router.post("")
async def save_memory(item: MemoryItem):
    async with aiosqlite.connect(DB_FILE) as db:
        await db.execute(
            "INSERT OR REPLACE INTO memories (user_id, key, value) VALUES (?, ?, ?)",
            (item.user_id, item.key, item.value)
        )
        await db.commit()
        return {"status": "success", "message": f"Memory saved: {item.key}"}

@router.delete("/{user_id}")
async def clear_memories(user_id: str):
    async with aiosqlite.connect(DB_FILE) as db:
        await db.execute("DELETE FROM memories WHERE user_id = ?", (user_id,))
        await db.commit()
        return {"status": "cleared", "message": f"All memories cleared for {user_id}"}
