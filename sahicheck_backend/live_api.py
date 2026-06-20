"""
Live News API routes for SahiCheck.

Added as a separate router so existing /fake-news, /phishing, and /fraud
logic in main.py stays unchanged.
"""

from typing import Optional

from fastapi import APIRouter, Query
from pydantic import BaseModel

from live_feeds import (
    get_all_news,
    get_deals,
    get_releases,
    get_reviews,
    get_rumors,
    get_sources_info,
    get_week_review,
    search_items,
)
from source_trust import TRUSTED_PUBLISHERS
from source_verify import verify_source_trust

router = APIRouter(prefix="/api/live", tags=["Live News"])


class SourceVerifyInput(BaseModel):
    title: str
    link: str
    source: str


@router.get("/trusted-publishers")
def trusted_publishers():
    """List official publishers used for source-based verification."""
    return {
        "count": len(TRUSTED_PUBLISHERS),
        "publishers": [
            {
                "name": name,
                "domains": info["domains"],
                "account_type": info["account_type"],
                "category": info["category"],
            }
            for name, info in TRUSTED_PUBLISHERS.items()
        ],
        "verification_method": (
            "Checks RSS publisher name + official website domain in article link. "
            "Does not use the political fake-news ML model."
        ),
    }


@router.post("/verify-source")
def verify_live_source(data: SourceVerifyInput):
    """
    Verify if an article is from a real/original trusted source.
    """
    result = verify_source_trust(
        {
            "title": data.title,
            "link": data.link,
            "source": data.source,
        }
    )
    return result


@router.get("/sources")
def live_sources():
    """List external RSS sources used by this feature."""
    return get_sources_info()


@router.get("/news")
def live_news():
    """All tech news from RSS feeds."""
    items = get_all_news()
    return {"count": len(items), "items": items}


@router.get("/releases")
def live_releases():
    """News filtered by release/launch keywords."""
    items = get_releases()
    return {"count": len(items), "items": items}


@router.get("/rumors")
def live_rumors():
    """News filtered by rumor/leak keywords."""
    items = get_rumors()
    return {"count": len(items), "items": items}


@router.get("/reviews")
def live_reviews():
    """News filtered by review/benchmark keywords."""
    items = get_reviews()
    return {"count": len(items), "items": items}


@router.get("/deals")
def live_deals():
    """Deals from Slickdeals RSS + keyword matches, with fallback list."""
    items = get_deals()
    return {"count": len(items), "items": items}


@router.get("/search")
def live_search(q: Optional[str] = Query(default="", min_length=1)):
    """Search RSS headlines and summaries."""
    items = search_items(q or "")
    return {"query": q, "count": len(items), "items": items}


@router.get("/week-review")
def live_week_review():
    """Weekly-style summary computed from recent RSS cache."""
    return get_week_review()
