import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sahicheck_frontend/l10n/app_localizations.dart';
import 'package:sahicheck_frontend/screens/fake_news_screen.dart';
import 'package:sahicheck_frontend/screens/fraud_detection_screen.dart';
import 'package:sahicheck_frontend/screens/live_news_screen.dart';
import 'package:sahicheck_frontend/screens/phishing_detection_screen.dart';
import 'package:sahicheck_frontend/screens/settings_screen.dart';
import 'package:sahicheck_frontend/services/integration_test.dart';
import 'package:sahicheck_frontend/utils/responsive.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _userName(User? user) {
    if (user == null) return '';
    if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
      return user.displayName!.trim();
    }
    final email = user.email ?? '';
    if (email.contains('@')) return email.split('@').first;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final name = _userName(user);
    final padding = Responsive.pagePadding(context);
    final columns = Responsive.gridColumns(context);
    final aspectRatio = Responsive.gridAspectRatio(context);

    final modules = [
      _ModuleData(
        icon: Icons.newspaper,
        title: l10n.fakeNews,
        description: l10n.fakeNewsDesc,
        color: Colors.blue,
        screen: const FakeNewsScreen(),
      ),
      _ModuleData(
        icon: Icons.rss_feed,
        title: l10n.liveNews,
        description: l10n.liveNewsDesc,
        color: Colors.teal,
        screen: const LiveNewsScreen(),
      ),
      _ModuleData(
        icon: Icons.phishing,
        title: l10n.phishing,
        description: l10n.phishingDesc,
        color: Colors.red,
        screen: const PhishingDetectionScreen(),
      ),
      _ModuleData(
        icon: Icons.credit_card,
        title: l10n.fraud,
        description: l10n.fraudDesc,
        color: Colors.orange,
        screen: const FraudDetectionScreen(),
      ),
      _ModuleData(
        icon: Icons.bug_report,
        title: l10n.integrationTest,
        description: l10n.integrationTestDesc,
        color: Colors.purple,
        screen: const IntegrationTestScreen(),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.security, size: 24),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n.appTitle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings),
            tooltip: l10n.settings,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.maxContentWidth(context),
          ),
          child: SingleChildScrollView(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome banner
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(columns == 1 ? 16 : 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade700, Colors.blue.shade500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade200,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.shield, color: Colors.white, size: 32),
                      const SizedBox(height: 12),
                      Text(
                        name.isNotEmpty
                            ? '${l10n.welcomeBack}, $name'
                            : l10n.welcomeBack,
                        style: TextStyle(
                          fontSize: Responsive.titleSize(context),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.welcomeSubtitle,
                        style: TextStyle(
                          fontSize: Responsive.bodySize(context),
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Responsive module grid — no Spacer, fixed content height
                LayoutBuilder(
                  builder: (context, constraints) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: aspectRatio,
                      ),
                      itemCount: modules.length,
                      itemBuilder: (context, index) {
                        final m = modules[index];
                        return _buildModuleCard(
                          context,
                          l10n: l10n,
                          icon: m.icon,
                          title: m.title,
                          description: m.description,
                          color: m.color,
                          screen: m.screen,
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),

                // System status
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.systemStatus,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _buildStatusIndicator(l10n.backend, Colors.green),
                          _buildStatusIndicator(l10n.mlModels, Colors.green),
                          _buildStatusIndicator(l10n.database, Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required AppLocalizations l10n,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required Widget screen,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.open,
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _ModuleData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Widget screen;

  _ModuleData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.screen,
  });
}
