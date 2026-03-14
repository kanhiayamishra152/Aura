import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../core/services/database_service.dart';
import '../../core/services/gamification_service.dart';
import '../../core/services/analytics_service.dart';
import '../widgets/premium_glass_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseService _dbService = DatabaseService();
  late final GamificationService _gamificationService;
  late final AnalyticsService _analyticsService;

  int _totalScore = 0;
  int _totalTimeFocused = 0;
  int _userLevel = 1;
  double _levelProgress = 0.0;
  String _peakTime = "Loading...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _gamificationService = GamificationService(_dbService);
    _analyticsService = AnalyticsService(_dbService);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Fetch leaderboard data
      final entry = await _dbService.getLocalLeaderboardEntry();
      
      // Fetch analytics
      final peak = await _analyticsService.getPeakProductivityTime();

      if (mounted) {
        setState(() {
          if (entry != null) {
            _totalScore = entry.score;
            _totalTimeFocused = entry.totalTimeFocused;
            _userLevel = _gamificationService.getUserLevel(_totalScore);
            _levelProgress = _gamificationService.getLevelProgress(_totalScore);
          }
          _peakTime = peak;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    return "${hours}h ${minutes}m";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surfaceBlack,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            onPressed: () {
              // Navigate to settings
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accentGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Profile Header
                  _buildProfileHeader(),
                  const SizedBox(height: 24),

                  // Level Progress Card
                  _buildLevelProgressCard(),
                  const SizedBox(height: 24),

                  // Stats Grid
                  _buildStatsGrid(),
                  const SizedBox(height: 24),

                  // Productivity Insights
                  _buildInsightsCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.grey[800]!, AppColors.surfaceBlack],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: AppColors.accentGreen, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGreen.withOpacity(0.2),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Level $_userLevel Achiever",
            style: const TextStyle(
              color: AppColors.accentGreen,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgressCard() {
    return PremiumGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Experience Points",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                "$_totalScore XP",
                style: const TextStyle(color: AppColors.accentGreen, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: _levelProgress.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accentGreen, Color(0xFF69F0AE)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${(_levelProgress * 100).toStringAsFixed(0)}% to Level ${_userLevel + 1}",
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard("Total Focus", _formatTime(_totalTimeFocused), Icons.timer),
        _buildStatCard("Sessions", "N/A", Icons.history), // Fetch count from DB if needed
        _buildStatCard("Peak Time", _peakTime, Icons.access_time),
        _buildStatCard("Rank", "Top 100", Icons.leaderboard),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[850]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard() {
    return PremiumGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Productivity Insights",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.lightbulb_outline, color: AppColors.accentGreen),
            ),
            title: const Text("Keep it up!", style: TextStyle(color: Colors.white)),
            subtitle: Text(
              "You focused ${_totalTimeFocused ~/ 60} minutes today.",
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }
}
