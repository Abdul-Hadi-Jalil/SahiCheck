"""
Static fallback data for the Live News feature.

No retailer APIs or web scraping — only hand-curated starter deals
used when live RSS feeds are empty or unavailable.
"""

# External RSS sources (for documentation / /api/live/sources)
NEWS_RSS_SOURCES = [
    {"name": "The Verge", "url": "https://www.theverge.com/rss/index.xml", "type": "news"},
    {"name": "Engadget", "url": "https://www.engadget.com/rss.xml", "type": "news"},
    {"name": "Ars Technica", "url": "https://feeds.arstechnica.com/arstechnica/index", "type": "news"},
    {"name": "9to5Mac", "url": "https://9to5mac.com/feed/", "type": "news"},
    {"name": "9to5Google", "url": "https://9to5google.com/feed/", "type": "news"},
    {"name": "Android Authority", "url": "https://www.androidauthority.com/feed/", "type": "news"},
    {"name": "Tom's Hardware", "url": "https://www.tomshardware.com/feeds/all", "type": "news"},
    {"name": "PCWorld", "url": "https://www.pcworld.com/feed", "type": "news"},
    {"name": "Laptop Mag", "url": "https://www.laptopmag.com/feeds/all", "type": "news"},
]

DEALS_RSS_SOURCES = [
    {
        "name": "Slickdeals",
        "url": "https://slickdeals.net/newsearch.php?mode=frontpage&searcharea=deals&searchin=first&rss=1",
        "type": "deals",
    },
]

# Keyword filters (title + summary, case-insensitive)
RELEASE_KEYWORDS = ["launch", "release", "announced", "unveil", "debut", "introducing"]
RUMOR_KEYWORDS = ["rumor", "rumour", "leak", "allegedly", "reportedly", "speculation"]
REVIEW_KEYWORDS = ["review", "hands-on", "hands on", "benchmark", "tested", "rating"]
DEAL_KEYWORDS = ["deal", "sale", "discount", "price drop", "off", "clearance"]

# Fallback starter deals if live feeds fail
FALLBACK_DEALS = [
    {
        "title": "Example: SSD storage upgrade deals",
        "summary": "Starter deal placeholder — replace with live Slickdeals RSS when online.",
        "link": "https://slickdeals.net/",
        "source": "SahiCheck (fallback)",
        "published": None,
    },
    {
        "title": "Example: Laptop seasonal sale",
        "summary": "Curated fallback item for demo when RSS is unavailable.",
        "link": "https://www.newegg.com/",
        "source": "SahiCheck (fallback)",
        "published": None,
    },
]
