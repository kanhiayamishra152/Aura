import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../widgets/premium_dialog.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  void _handleLogout(BuildContext context) {
    PremiumDialog.show(
      context,
      title: 'End Session?',
      message: 'Are you sure you want to log out of your account?',
      primaryButtonText: 'Logout',
      secondaryButtonText: 'Cancel',
      isDestructive: true,
      onPrimaryPressed: () async {
        Navigator.pop(context); // Close dialog
        await context.read<AuthProvider>().logout();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hardcoded stats for structural display; integrate GamificationProvider/AnalyticsService here.
    const int userLevel = 14;
    const int currentXp = 8500;
    const int targetXp = 10000;
    final double xpProgress = currentXp / targetXp;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers:[
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            expandedHeight: 80.0,
            actions:[
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              ),
              const SizedBox(width: 8.0),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children:[
                  Container(
                    height: 100.0,
                    width: 100.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF39FF14),
                        width: 2.0,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage('https://i.pravatar.cc/300'), // Replace with local asset or network image
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Focus Master',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  const Text(
                    'focus@example.com',
                    style: TextStyle(
                      color: Color(0xFF777777),
                      fontSize: 14.0,
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  
                  // Level & XP Bar
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212),
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: const Color(0xFF333333),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      children:[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:[
                            const Text(
                              'LEVEL 14',
                              style: TextStyle(
                                color: Color(0xFF39FF14),
                                fontSize: 16.0,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              '$currentXp / $targetXp XP',
                              style: const TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 12.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: LinearProgressIndicator(
                            value: xpProgress,
                            backgroundColor: const Color(0xFF222222),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF39FF14)),
                            minHeight: 8.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),

                  // Stats Grid
                  Row(
                    children:[
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.local_fire_department_rounded,
                          title: '12 Days',
                          subtitle: 'Current Streak',
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.timer_rounded,
                          title: '48h',
                          subtitle: 'Total Focus',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children:[
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.task_alt_rounded,
                          title: '142',
                          subtitle: 'Tasks Done',
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.shield_rounded,
                          title: '85',
                          subtitle: 'Distractions Blocked',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48.0),

                  // Actions
                  _buildActionTile(
                    icon: Icons.leaderboard_rounded,
                    title: 'Leaderboard Ranking',
                    onTap: () => Navigator.pushNamed(context, '/leaderboard'),
                  ),
                  _buildActionTile(
                    icon: Icons.music_note_rounded,
                    title: 'Soundscapes & Alarms',
                    onTap: () => Navigator.pushNamed(context, '/sounds'),
                  ),
                  _buildActionTile(
                    icon: Icons.logout_rounded,
                    title: 'Log Out',
                    isDestructive: true,
                    onTap: () => _handleLogout(context),
                  ),
                  const SizedBox(height: 100.0), // Padding for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: const Color(0xFF333333),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Icon(icon, color: const Color(0xFF39FF14), size: 28.0),
          const SizedBox(height: 16.0),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF777777),
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.redAccent : Colors.white;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFF222222),
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          children:[
            Icon(icon, color: color, size: 24.0),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDestructive ? Colors.transparent : const Color(0xFF555555),
              size: 24.0,
            ),
          ],
        ),
      ),
    );
  }
}
