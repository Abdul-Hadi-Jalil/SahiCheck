"""
Verify whether a live news item comes from a trusted original source.
"""

import re
from typing import Any, Dict
from urllib.parse import urlparse

from source_trust import SUSPICIOUS_URL_HINTS, TRUSTED_PUBLISHERS


def _extract_domain(url: str) -> str:
    """Return lowercase hostname from a URL."""
    if not url:
        return ""
    try:
        host = urlparse(url).netloc.lower()
        if host.startswith("www."):
            return host
        return host
    except Exception:
        return ""


def _domain_matches_trusted(domain: str, publisher_name: str) -> bool:
    """Check if link domain belongs to the publisher's official sites."""
    if not domain:
        return False

    publisher = TRUSTED_PUBLISHERS.get(publisher_name)
    if not publisher:
        return False

    allowed = publisher["domains"]
    bare = domain.removeprefix("www.")
    for allowed_domain in allowed:
        allowed_bare = allowed_domain.removeprefix("www.")
        if domain == allowed_domain or bare == allowed_bare:
            return True
        if domain.endswith("." + allowed_bare):
            return True
    return False


def _is_suspicious_url(url: str) -> bool:
    lowered = url.lower()
    if re.match(r"https?://\d+\.\d+\.\d+\.\d+", lowered):
        return True
    return any(hint in lowered for hint in SUSPICIOUS_URL_HINTS)


def verify_source_trust(item: Dict[str, Any]) -> Dict[str, Any]:
    """
    Decide if news is from a real/original trusted account.

    Rules (simple and explainable for a student project):
    1. Article must come from a known RSS publisher name.
    2. Article link domain must match that publisher's official website.
    3. Suspicious shortener/IP links are marked untrusted.
    """
    source_name = item.get("source", "")
    link = item.get("link", "")
    domain = _extract_domain(link)

    # Demo fallback items are not real verified news
    if source_name.startswith("SahiCheck"):
        return {
            "result": "Unverified",
            "confidence": 0.3,
            "verification_method": "fallback_demo",
            "publisher": source_name,
            "domain": domain,
            "reason": "This is a demo placeholder item, not live verified news.",
            "is_trusted_source": False,
        }

    publisher_info = TRUSTED_PUBLISHERS.get(source_name)

    if not publisher_info:
        return {
            "result": "Unverified",
            "confidence": 0.4,
            "verification_method": "unknown_publisher",
            "publisher": source_name or "Unknown",
            "domain": domain,
            "reason": "Publisher is not in the trusted original-source list.",
            "is_trusted_source": False,
        }

    if _is_suspicious_url(link):
        return {
            "result": "Suspicious",
            "confidence": 0.85,
            "verification_method": "suspicious_url",
            "publisher": source_name,
            "domain": domain,
            "reason": "Link uses a shortener or suspicious pattern, not the original publisher site.",
            "is_trusted_source": False,
        }

    if _domain_matches_trusted(domain, source_name):
        return {
            "result": "Real",
            "confidence": 0.95,
            "verification_method": "trusted_publisher_rss",
            "publisher": source_name,
            "domain": domain,
            "account_type": publisher_info["account_type"],
            "reason": (
                f"Fetched from official {source_name} RSS feed and link points to "
                f"their real website ({domain})."
            ),
            "is_trusted_source": True,
        }

    # RSS name is trusted but link domain does not match — could be syndication
    return {
        "result": "Unverified",
        "confidence": 0.55,
        "verification_method": "domain_mismatch",
        "publisher": source_name,
        "domain": domain,
        "reason": (
            f"Headline is from {source_name} RSS, but the link domain ({domain or 'missing'}) "
            "does not match that publisher's official website."
        ),
        "is_trusted_source": False,
    }


def attach_trust_to_item(item: Dict[str, Any]) -> Dict[str, Any]:
    """Add source-trust fields to a news item dict."""
    trust = verify_source_trust(item)
    enriched = dict(item)
    enriched["trust_result"] = trust["result"]
    enriched["trust_confidence"] = trust["confidence"]
    enriched["is_trusted_source"] = trust["is_trusted_source"]
    enriched["trust_reason"] = trust["reason"]
    enriched["article_domain"] = trust.get("domain", "")
    return enriched
