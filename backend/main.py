# import os
# import mimetypes
# from fastapi import FastAPI
# from fastapi.middleware.cors import CORSMiddleware
# from fastapi.staticfiles import StaticFiles
# from fastapi.responses import FileResponse

# from routes.guidance import router as guidance_router
# from routes.admin import router as admin_router

# # Fix: Explicitly add MIME types for JavaScript files
# mimetypes.add_type("application/javascript", ".js")
# mimetypes.add_type("application/javascript", ".mjs")

# app = FastAPI(title="MSU Guidance System")

# # --- CORS Configuration ---
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# # 1. API Routes (Must stay at the top)
# app.include_router(guidance_router, prefix="/api/v1")
# app.include_router(admin_router, prefix="/api/v1/admin", tags=["Admin"])

# @app.get("/api/v1/health")
# def health_check():
#     return {"status": "API is online"}

# # 2. Path Logic for Render
# CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
# FRONTEND_DIR = os.path.join(os.path.dirname(CURRENT_DIR), "frontend", "build", "web")

# # 3. Mount Static Files
# # We mount this to the root directory to handle scripts/assets
# if os.path.exists(FRONTEND_DIR):
#     app.mount("/static", StaticFiles(directory=FRONTEND_DIR), name="static")

# # 4. Improved SPA Handler
# @app.get("/{full_path:path}")
# async def serve_spa(full_path: str):
#     # Prevent catching API calls
#     if full_path.startswith("api/"):
#         return {"detail": "Not Found"}, 404
        
#     # Check if the requested path is an actual file (like main.dart.js)
#     file_path = os.path.join(FRONTEND_DIR, full_path)
#     if os.path.isfile(file_path):
#         return FileResponse(file_path)
    
#     # If file doesn't exist, return index.html (Standard SPA behavior)
#     index_file = os.path.join(FRONTEND_DIR, "index.html")
#     if os.path.exists(index_file):
#         return FileResponse(index_file)
    
#     return {"error": "Frontend build not found."}

# import os
# import mimetypes
# from fastapi import FastAPI
# from fastapi.middleware.cors import CORSMiddleware
# from fastapi.staticfiles import StaticFiles
# from fastapi.responses import FileResponse

# from routes.guidance import router as guidance_router
# from routes.admin import router as admin_router

# # 1. FIX MIME TYPES
# # This prevents the "text/html" error that causes white screens in browsers
# mimetypes.add_type("application/javascript", ".js")
# mimetypes.add_type("application/javascript", ".mjs")

# app = FastAPI(title="MSU Guidance System")

# # 2. CORS CONFIGURATION
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# # 3. API ROUTES (Must remain above the SPA handler)
# app.include_router(guidance_router, prefix="/api/v1")
# app.include_router(admin_router, prefix="/api/v1/admin", tags=["Admin"])

# @app.get("/api/v1/health")
# def health_check():
#     return {"status": "API is online"}

# # 4. PATH LOGIC
# # Detects the directory where main.py lives and looks for the frontend build
# CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
# FRONTEND_DIR = os.path.normpath(os.path.join(CURRENT_DIR, "..", "frontend", "build", "web"))

# # 5. STATIC FILES MOUNT
# if os.path.exists(FRONTEND_DIR):
#     app.mount("/static", StaticFiles(directory=FRONTEND_DIR), name="static")

# @app.get("/{full_path:path}")
# async def serve_spa(full_path: str):
#     # 1. Prevent API routes from being handled here
#     if full_path.startswith("api/"):
#         return {"detail": "Not Found"}, 404
        
#     # 2. Check the standard path first (for .js and .html files)
#     file_path = os.path.join(FRONTEND_DIR, full_path)
    
#     # 3. THE LOGO FIX: Handle the Flutter 'Double Assets' folder
#     # If the file isn't found and the path includes "assets/", look one level deeper
#     if not os.path.exists(file_path) and "assets/" in full_path:
#         # This changes 'assets/msu_logo.jpg' to 'assets/assets/msu_logo.jpg'
#         relative_asset_path = full_path.replace("assets/", "assets/assets/", 1)
#         file_path = os.path.join(FRONTEND_DIR, relative_asset_path)

#     if os.path.isfile(file_path):
#         return FileResponse(file_path)
    
#     # 4. Fallback to index.html for Single Page App routing
#     index_file = os.path.join(FRONTEND_DIR, "index.html")
#     if os.path.exists(index_file):
#         return FileResponse(index_file)
    
#     return {"error": "File not found."}

import os
import mimetypes
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from routes.guidance import router as guidance_router
from routes.admin import router as admin_router

# Ensure JS MIME types are correct
mimetypes.add_type("application/javascript", ".js")
mimetypes.add_type("application/javascript", ".mjs")

app = FastAPI(title="MSU Guidance System")

# --- CORS ---
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- API ROUTES ---
app.include_router(guidance_router, prefix="/api/v1")
app.include_router(admin_router, prefix="/api/v1/admin", tags=["Admin"])

@app.get("/api/v1/health")
def health_check():
    return {"status": "API is online"}

# =========================
# FRONTEND (FLUTTER WEB)
# =========================

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
FRONTEND_DIR = os.path.join(CURRENT_DIR, "..", "frontend", "build", "web")

# IMPORTANT: only mount if build exists
if os.path.exists(FRONTEND_DIR):
    app.mount(
        "/",
        StaticFiles(directory=FRONTEND_DIR, html=True),
        name="frontend"
    )
else:
    print("⚠️ Flutter build not found at:", FRONTEND_DIR)