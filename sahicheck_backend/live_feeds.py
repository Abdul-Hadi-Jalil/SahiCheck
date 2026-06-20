"""
Live RSS feed loader for SahiCheck.

Fetches tech news from public RSS feeds (same idea as TechPulse):
- Parses feeds with feedparser
- Caches results for 10 minutes
- Filters by keywords for releases / rumors / reviews / deals
- No GSMArena, Best Buy API, Amazon API, or web scraping
"""

import hashlib
import re
import time
from datetime import datetime
from typing import Any, Dict, List, Optional

import feedparser

from data_catalog import (
    DEAL_KEYWORDS,
    DEALS_RSS_SOURCES,
    FALLBACK_DEALS,
    NEWS_RSS_SOURCES,
    RELEASE_KEYWORDS,
    REVIEW_KEYWORDS,
    RUMOR_KEYWORDS,
)

# Cache TTL: 10 minutes (same as TechPulse)
CACHE_TTL_SECONDS = 600

_cache: Dict[str, Any] = {
    "news_items": [],
    "deal_items": [],
    "fetched_at": 0.0,
}


def _strip_html(text: str) -> str:
    """Remove basic HTML tags from RSS descriptions."""
    if not text:
        return ""
    clean = re.sub(r"<[^>]+>", " ", text)
    clean = re.sub(r"\s+", " ", clean)
    return clean.strip()


def _matches_keywords(text: str, keywords: List[str]) -> bool:
    lowered = text.lower()
    return any(keyword in lowered for keyword in keywords)


def _make_item_id(source: str, link: str, title: str) -> str:
    raw = f"{source}|{link}|{title}"
    return hashlib.md5(raw.encode("utf-8")).hexdigest()


def _parse_published(entry: Any) -> Optional[str]:
    if getattr(entry, "published_parsed", None):
        try:
            return datetime(*entry.published_parsed[:6]).isoformat()
        except (TypeError, ValueError):
            pass
    if getattr(entry, "published", None):
        return str(entry.published)
    return None


def _normalize_entry(entry: Any, source_name: str) -> Dict[str, Any]:
    title = getattr(entry, "title", "") or "Untitled"
    link = getattr(entry, "link", "") or ""
    summary = _strip_html(getattr(entry, "summary", "") or getattr(entry, "description", ""))

    return {
        "id": _make_item_id(source_name, link, title),
        "title": title,
        "summary": summary[:500] if summary else "",
        "link": link,
        "source": source_name,
        "published": _parse_published(entry),
    }


def _fetch_feed(url: str, source_name: str, limit: int = 15) -> List[Dict[str, Any]]:
    """
    Fetch and parse one RSS feed.
    Returns an empty list if the feed fails (does not crash the whole app).
    """
    try:
        parsed = feedparser.parse(url)
        if parsed.bozo and not parsed.entries:
            print(f"RSS parse warning for {source_name}: {parsed.bozo_exception}")
            return []

        items = []
        for entry in parsed.entries[:limit]:
            items.append(_normalize_entry(entry, source_name))
        return items
    except Exception as error:
        print(f"Failed to fetch RSS from {source_name}: {error}")
        return []


def _dedupe_items(items: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    seen = set()
    unique = []
    for item in items:
        if item["id"] in seen:
            continue
        seen.add(item["id"])
        unique.append(item)
    return unique


def _sort_by_date(items: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
    return sorted(items, key=lambda x: x.get("published") or "", reverse=True)


def _refresh_cache_if_needed() -> None:
    now = time.time()
    if now - _cache["fetched_at"] < CACHE_TTL_SECONDS:
        return

    news_items: List[Dict[str, Any]] = []
    for source in NEWS_RSS_SOURCES:
        news_items.extend(_fetch_feed(source["url"], source["name"]))

    deal_items: List[Dict[str, Any]] = []
    for source in DEALS_RSS_SOURCES:
        deal_items.extend(_fetch_feed(source["url"], source["name"], limit=20))

    _cache["news_items"] = _sort_by_date(_dedupe_items(news_items))
    _cache["deal_items"] = _sort_by_date(_dedupe_items(deal_items)) if deal_items else []
    _cache["fetched_at"] = now


def get_all_news() -> List[Dict[str, Any]]:
    _refresh_cache_if_needed()
    return _cache["news_items"]


def get_filtered_news(keywords: List[str]) -> List[Dict[str, Any]]:
    items = get_all_news()
    filtered = []
    for item in items:
        blob = f"{item['title']} {item['summary']}"
        if _matches_keywords(blob, keywords):
            filtered.append(item)
    return filtered


def get_releases() -> List[Dict[str, Any]]:
    return get_filtered_news(RELEASE_KEYWORDS)


def get_rumors() -> List[Dict[str, Any]]:
    return get_filtered_news(RUMOR_KEYWORDS)


def get_reviews() -> List[Dict[str, Any]]:
    return get_filtered_news(REVIEW_KEYWORDS)


def get_deals() -> List[Dict[str, Any]]:
    _refresh_cache_if_needed()
    live_deals = _cache["deal_items"]

    # Also pick deal-like headlines from general news feeds
    news_deals = get_filtered_news(DEAL_KEYWORDS)
    combined = _sort_by_date(_dedupe_items(live_deals + news_deals))

    if not combined:
        return FALLBACK_DEALS.copy()
    return combined


def search_items(query: str) -> List[Dict[str, Any]]:
    query = query.strip().lower()
    if not query:
        return []

    all_items = _dedupe_items(get_all_news() + get_deals())
    results = []
    for item in all_items:
        blob = f"{item['title']} {item['summary']} {item['source']}".lower()
        if query in blob:
            results.append(item)
    return results


def get_week_review() -> Dict[str, Any]:
    """
    Computed summary from cached RSS items (not a separate feed).
    """
    news = get_all_news()
    releases = get_releases()
    rumors = get_rumors()
    reviews = get_reviews()
    deals = get_deals()

    by_source: Dict[str, int] = {}
    for item in news:
        source = item.get("source", "Unknown")
        by_source[source] = by_source.get(source, 0) + 1

    top_headlines = [item["title"] for item in news[:8]]

    return {
        "generated_at": datetime.utcnow().isoformat(),
        "total_articles": len(news),
        "releases_count": len(releases),
        "rumors_count": len(rumors),
        "reviews_count": len(reviews),
        "deals_count": len(deals),
        "by_source": by_source,
        "top_headlines": top_headlines,
        "cache_age_seconds": int(time.time() - _cache["fetched_at"]),
    }


def get_sources_info() -> Dict[str, Any]:
    return {
        "method": "RSS parse + 10 minute in-memory cache",
        "note": "No GSMArena, Best Buy API, Amazon API, or web scraping.",
        "news_sources": NEWS_RSS_SOURCES,
        "deals_sources": DEALS_RSS_SOURCES,
        "verification": "Use existing POST /fake-news ML model on any article title + summary",
    }
