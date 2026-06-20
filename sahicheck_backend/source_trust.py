"""
Trusted publisher registry for Live News source verification.

Verification is based on ORIGINAL sources — known tech news publishers
and their official website domains — not the political fake-news ML model.
"""

# Official RSS feeds we fetch from (name must match data_catalog NEWS_RSS_SOURCES)
TRUSTED_PUBLISHERS = {
    "The Verge": {
        "domains": ["theverge.com", "www.theverge.com"],
        "category": "official_tech_news",
        "account_type": "Official publisher RSS",
    },
    "Engadget": {
        "domains": ["engadget.com", "www.engadget.com"],
        "category": "official_tech_news",
        "account_type": "Official publisher RSS",
    },
    "Ars Technica": {
        "domains": ["arstechnica.com", "www.arstechnica.com"],
        "category": "official_tech_news",
        "account_type": "Official publisher RSS",
    },
    "9to5Mac": {
        "domains": ["9to5mac.com", "www.9to5mac.com"],
        "category": "official_tech_news",
        "account_type": "Official Apple news RSS",
    },
    "9to5Google": {
        "domains": ["9to5google.com", "www.9to5google.com"],
        "category": "official_tech_news",
        "account_type": "Official Google/Android news RSS",
    },
    "Android Authority": {
        "domains": ["androidauthority.com", "www.androidauthority.com"],
        "category": "official_tech_news",
        "account_type": "Official publisher RSS",
    },
    "Tom's Hardware": {
        "domains": ["tomshardware.com", "www.tomshardware.com"],
        "category": "official_tech_news",
        "account_type": "Official hardware news RSS",
    },
    "PCWorld": {
        "domains": ["pcworld.com", "www.pcworld.com"],
        "category": "official_tech_news",
        "account_type": "Official publisher RSS",
    },
    "Laptop Mag": {
        "domains": ["laptopmag.com", "www.laptopmag.com"],
        "category": "official_tech_news",
        "account_type": "Official publisher RSS",
    },
    "Slickdeals": {
        "domains": ["slickdeals.net", "www.slickdeals.net"],
        "category": "official_deals",
        "account_type": "Official deals RSS",
    },
}

# URL patterns that suggest an untrusted / forwarded link
SUSPICIOUS_URL_HINTS = [
    "bit.ly",
    "tinyurl.com",
    "t.co",
    "goo.gl",
    "cutt.ly",
    "rb.gy",
]
