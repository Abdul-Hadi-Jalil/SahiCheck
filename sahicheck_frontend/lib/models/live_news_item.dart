/// Model for RSS news items from /api/live/* endpoints.
class LiveNewsItem {
  final String id;
  final String title;
  final String summary;
  final String link;
  final String source;
  final String? published;

  LiveNewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.link,
    required this.source,
    this.published,
  });

  factory LiveNewsItem.fromJson(Map<String, dynamic> json) {
    return LiveNewsItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      link: json['link']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      published: json['published']?.toString(),
    );
  }
}

/// Summary from GET /api/live/week-review
class WeekReview {
  final int totalArticles;
  final int releasesCount;
  final int rumorsCount;
  final int reviewsCount;
  final int dealsCount;
  final List<String> topHeadlines;

  WeekReview({
    required this.totalArticles,
    required this.releasesCount,
    required this.rumorsCount,
    required this.reviewsCount,
    required this.dealsCount,
    required this.topHeadlines,
  });

  factory WeekReview.fromJson(Map<String, dynamic> json) {
    return WeekReview(
      totalArticles: json['total_articles'] as int? ?? 0,
      releasesCount: json['releases_count'] as int? ?? 0,
      rumorsCount: json['rumors_count'] as int? ?? 0,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      dealsCount: json['deals_count'] as int? ?? 0,
      topHeadlines: (json['top_headlines'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
