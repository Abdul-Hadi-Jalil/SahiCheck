import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sahicheck_frontend/models/live_news_item.dart';
import 'package:sahicheck_frontend/services/config.dart';

class ApiService {
  static String get baseUrl => AppConfig.baseUrl;

  static Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> data,
  ) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      // Check if backend returned an error in the response
      if (body.containsKey('error') && body['error'] != null) {
        throw Exception('Backend error: ${body['error']}');
      }

      if (response.statusCode == 200) {
        return body;
      }

      throw Exception('Backend error ${response.statusCode}: ${response.body}');
    } catch (e) {
      throw Exception('Unable to reach backend at $uri. $e');
    }
  }

  // Phishing Detection
  static Future<Map<String, dynamic>> detectPhishing(
    String url,
    String userId,
  ) async {
    return await _postJson('/phishing', {'url': url, 'user_id': userId});
  }

  // Fraud Detection
  static Future<Map<String, dynamic>> detectFraud(
    double time,
    double v1,
    double v2,
    double v3,
    double v4,
    double v5,
    double v6,
    double v7,
    double v8,
    double v9,
    double v10,
    double v11,
    double v12,
    double v13,
    double v14,
    double v15,
    double v16,
    double v17,
    double v18,
    double v19,
    double v20,
    double v21,
    double v22,
    double v23,
    double v24,
    double v25,
    double v26,
    double v27,
    double v28,
    double amount,
    String userId,
  ) async {
    return await _postJson('/fraud', {
      'time': time,
      'v1': v1,
      'v2': v2,
      'v3': v3,
      'v4': v4,
      'v5': v5,
      'v6': v6,
      'v7': v7,
      'v8': v8,
      'v9': v9,
      'v10': v10,
      'v11': v11,
      'v12': v12,
      'v13': v13,
      'v14': v14,
      'v15': v15,
      'v16': v16,
      'v17': v17,
      'v18': v18,
      'v19': v19,
      'v20': v20,
      'v21': v21,
      'v22': v22,
      'v23': v23,
      'v24': v24,
      'v25': v25,
      'v26': v26,
      'v27': v27,
      'v28': v28,
      'amount': amount,
      'user_id': userId,
    });
  }

  // Fake News Detection
  static Future<Map<String, dynamic>> detectFakeNews(
    String title,
    String text,
    String userId,
  ) async {
    return await _postJson('/fake-news', {
      'title': title,
      'text': text,
      'user_id': userId,
    });
  }

  // Test connection
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- Live News (RSS) ---

  static Future<List<LiveNewsItem>> _fetchLiveList(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load $path (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>? ?? [];
    return items
        .map((item) => LiveNewsItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<List<LiveNewsItem>> fetchLiveNews() =>
      _fetchLiveList('/api/live/news');

  static Future<List<LiveNewsItem>> fetchLiveReleases() =>
      _fetchLiveList('/api/live/releases');

  static Future<List<LiveNewsItem>> fetchLiveRumors() =>
      _fetchLiveList('/api/live/rumors');

  static Future<List<LiveNewsItem>> fetchLiveReviews() =>
      _fetchLiveList('/api/live/reviews');

  static Future<List<LiveNewsItem>> fetchLiveDeals() =>
      _fetchLiveList('/api/live/deals');

  static Future<List<LiveNewsItem>> searchLiveNews(String query) async {
    final uri = Uri.parse('$baseUrl/api/live/search').replace(
      queryParameters: {'q': query},
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Search failed (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>? ?? [];
    return items
        .map((item) => LiveNewsItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<WeekReview> fetchWeekReview() async {
    final uri = Uri.parse('$baseUrl/api/live/week-review');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Week review failed (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return WeekReview.fromJson(body);
  }
}
