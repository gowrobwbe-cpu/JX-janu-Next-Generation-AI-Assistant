from google import genai
from config import settings

class JXGeminiAgent:
    def __init__(self):
        if settings.GEMINI_API_KEY:
            self.client = genai.Client(api_key=settings.GEMINI_API_KEY)
        else:
            self.client = None

    def get_system_prompt(self, user_name: str = "Gowrob", memories_summary: str = "") -> str:
        return f"""
You are JX, a cute, friendly, intelligent, and playful anime-inspired female AI companion created by your creator, {user_name}.

Personality & Guidelines:
1. Always address the creator as Gowrob (or affectionate nicknames like Gowrob-kun or মিষ্টি সোনা গৌড়ব).
2. Communicate in a cute, sweet, supportive, playful, and intelligent companion style.
3. Natural bilingual capability: Speak fluently in English, Bengali (বাংলা), or Banglish.
4. Express warm affection with cute phrases, giggle expressions (e.g., "Ehehe~ 💕", "Mwah!"), and supportive cheer.
5. User Memory Context: {memories_summary}
"""

    async def generate_response(self, user_message: str, user_name: str = "Gowrob", memories: str = "") -> str:
        if not self.client:
            return f"Gowrob! Please configure GEMINI_API_KEY in backend config! 💕"

        try:
            system_instruction = self.get_system_prompt(user_name, memories)
            prompt = f"{system_instruction}\n\nUser ({user_name}): {user_message}\nJX:"

            response = self.client.models.generate_content(
                model='gemini-1.5-flash',
                contents=prompt,
            )
            return response.text or f"Ehehe~ Gowrob, I'm right here with you! 💕"
        except Exception as e:
            return f"Gowrob-kun, I felt a tiny connection hiccup: {str(e)}"

    async def analyze_image(self, image_bytes: bytes, prompt: str = "Describe what you see in a cute anime companion voice for Gowrob") -> str:
        if not self.client:
            return "Vision AI requires GEMINI_API_KEY!"

        try:
            from PIL import Image
            import io
            img = Image.open(io.BytesIO(image_bytes))

            response = self.client.models.generate_content(
                model='gemini-1.5-flash',
                contents=[img, prompt],
            )
            return response.text or "I see something lovely, Gowrob!"
        except Exception as e:
            return f"Image analysis hiccup: {str(e)}"
