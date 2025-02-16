from fastapi import APIRouter, Request, Depends
from fastapi.responses import Response

from api.routes import books

# Dependency to Add `ngrok-skip-browser-warning` Header
async def add_ngrok_skip_header(request: Request, response: Response):
    response.headers["ngrok-skip-browser-warning"] = "true"
    return response



api_router = APIRouter()

api_router.include_router(books.router, prefix="/books", tags=["books"], dependencies=[Depends(add_ngrok_skip_header)])

