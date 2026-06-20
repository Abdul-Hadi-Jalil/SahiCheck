import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sahicheck_frontend/l10n/app_localizations.dart';
import 'package:sahicheck_frontend/models/live_news_item.dart';
import 'package:sahicheck_frontend/services/api_service.dart';

/// Browse live tech news from RSS feeds and verify articles
/// using trusted original publisher sources (official RSS + domain check).
class LiveNewsScreen extends StatefulWidget {
  const LiveNewsScreen({super.key});

  @override
  State<LiveNewsScreen> createState() => _LiveNewsScreenState();
}

class _LiveNewsScreenState extends State<LiveNewsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  bool _isLoading = true;
  String? _error;
  List<LiveNewsItem> _items = [];
  WeekReview? _weekReview;

  static const _tabs = [
    ('All News', 'news'),
    ('Releases', 'releases'),
    ('Rumors', 'rumors'),
    ('Reviews', 'reviews'),
    ('Deals', 'deals'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadTab(_tabs[_tabController.index].$2);
      }
    });
    _loadTab('news');
    _loadWeekReview();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWeekReview() async {
    try {
      final review = await ApiService.fetchWeekReview();
      if (mounted) setState(() => _weekReview = review);
    } catch (_) {
      // Week review is optional UI — ignore errors
    }
  }

  Future<void> _loadTab(String type) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<LiveNewsItem> items;
      switch (type) {
        case 'releases':
          items = await ApiService.fetchLiveReleases();
          break;
        case 'rumors':
          items = await ApiService.fetchLiveRumors();
          break;
        case 'reviews':
          items = await ApiService.fetchLiveReviews();
          break;
        case 'deals':
          items = await ApiService.fetchLiveDeals();
          break;
        default:
          items = await ApiService.fetchLiveNews();
      }
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _runSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _loadTab(_tabs[_tabController.index].$2);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await ApiService.searchLiveNews(query);
      if (!mounted) return;
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyArticle(LiveNewsItem item) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Source trust: official RSS publisher + real website domain
      final result = await ApiService.verifyLiveNewsSource(
        title: item.title,
        link: item.link,
        source: item.source,
      );
      if (!mounted) return;
      Navigator.pop(context);
      _showVerificationResult(item, result);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: $e')),
      );
    }
  }

  void _showVerificationResult(LiveNewsItem item, Map<String, dynamic> result) {
    final verdict = result['result']?.toString() ?? 'Unverified';
    final isReal = verdict == 'Real';
    final isSuspicious = verdict == 'Suspicious';
    final confidence = ((result['confidence'] as num?) ?? 0) * 100;
    final reason = result['reason']?.toString() ?? '';
    final domain = result['domain']?.toString() ?? item.articleDomain ?? '';
    final accountType = result['account_type']?.toString() ?? '';

    Color color;
    IconData icon;
    String headline;

    if (isReal) {
      color = Colors.green;
      icon = Icons.verified;
      headline = 'Verified Real Source';
    } else if (isSuspicious) {
      color = Colors.red;
      icon = Icons.warning_amber;
      headline = 'Suspicious Source';
    } else {
      color = Colors.orange;
      icon = Icons.help_outline;
      headline = 'Unverified Source';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    headline,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Publisher: ${item.source}'),
            if (domain.isNotEmpty) Text('Official domain: $domain'),
            if (accountType.isNotEmpty) Text('Account type: $accountType'),
            const SizedBox(height: 12),
            Text('Trust score: ${confidence.toStringAsFixed(0)}%'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (result['confidence'] as num?)?.toDouble() ?? 0,
              color: color,
            ),
            const SizedBox(height: 16),
            Text(
              reason,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Text(
              'Checked against official RSS feeds and publisher websites '
              '(The Verge, Ars Technica, Engadget, etc.).',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _openArticleDetail(LiveNewsItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: controller,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.source,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              if (item.published != null) ...[
                const SizedBox(height: 4),
                Text(
                  item.published!,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
              const SizedBox(height: 16),
              if (item.summary.isNotEmpty)
                Text(item.summary)
              else
                const Text('No summary available from RSS feed.'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _verifyArticle(item);
                },
                icon: const Icon(Icons.verified_user),
                label: const Text('Verify Original Source'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.liveNews),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _tabs.map((t) => Tab(text: t.$1)).toList(),
        ),
      ),
      body: Column(
        children: [
          if (_weekReview != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.shade100),
              ),
              child: Text(
                'This week: ${_weekReview!.totalArticles} articles · '
                '${_weekReview!.releasesCount} releases · '
                '${_weekReview!.rumorsCount} rumors · '
                '${_weekReview!.reviewsCount} reviews',
                style: TextStyle(fontSize: 13, color: Colors.teal.shade900),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.searchHeadlines,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _runSearch(),
                  ),
                ),
                IconButton(
                  onPressed: _runSearch,
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _loadTab(_tabs[_tabController.index].$2),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return const Center(
        child: Text('No articles found for this category.'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadTab(_tabs[_tabController.index].$2),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          final trustLabel = item.isTrustedSource
              ? 'Verified source'
              : (item.trustResult ?? 'Check source');
          final trustColor =
              item.isTrustedSource ? Colors.green : Colors.orange;

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              title: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${item.source} · ${item.articleDomain ?? 'tap to verify'}'),
                  const SizedBox(height: 4),
                  Text(
                    trustLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: trustColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: Icon(
                  item.isTrustedSource ? Icons.verified : Icons.verified_user,
                  color: item.isTrustedSource
                      ? Colors.green
                      : Colors.teal.shade700,
                ),
                onPressed: () => _verifyArticle(item),
                tooltip: 'Verify source',
              ),
              onTap: () => _openArticleDetail(item),
            ),
          );
        },
      ),
    );
  }
}
