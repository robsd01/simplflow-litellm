import os
from supabase import create_client
from dotenv import load_dotenv

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

def custom_auth(request):
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header:
            raise Exception("Missing Authorization header")

        # Extract the token value after 'Bearer '
        token = auth_header.split(" ")[1].strip()

        # Find user by API key
        user = supabase.table("users").select("*").eq("api_key", token).single().execute()

        if not user.data:
            raise Exception("Invalid API key")

        # You can log usage or enforce plan here later
        return request

    except Exception as e:
        raise Exception(f"Auth failed: {str(e)}")
