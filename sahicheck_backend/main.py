# entry point of the backend application

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for development; restrict in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

# endpoint for fake news
@app.get("/fake-news")
def get_fake_news():
    # In a real application, this would fetch data from a database or external API
    return {
        "news": [
            {"id": 1, "title": "Fake News 1", "content": "This is fake news content."},
            {"id": 2, "title": "Fake News 2", "content": "This is another fake news content."}
        ]
    }