import 'package:flutter/material.dart';
import '../widgets/premium_glass_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'AURA',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 4.0,
          ),
        ),
        actions:[
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              const Text(
                'Good Morning,\nReady to focus?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28.0,
                  fontWeight: FontWeight.w300,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 32.0),
              Row(
                children:[
                  Expanded(
                    child: _buildStatCard(
                      title: 'TODAY',
                      value: '4h 20m',
                      icon: Icons.local_fire_department,
                      color: const Color(0xFF00FF00),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: _buildStatCard(
                      title: 'STREAK',
                      value: '12 Days',
                      icon: Icons.bolt,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
              const Text(
                'RECENT SESSIONS',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 16.0),
              _buildSessionTile('Deep Work', '1h 30m', true),
              _buildSessionTile('Reading', '45m', true),
              _buildSessionTile('Coding', '2h 05m', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return PremiumGlassCard(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Icon(icon, color: color, size: 28.0),
          const SizedBox(height: 16.0),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTile(String title, String duration, bool completed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: completed ? const Color(0xFF00FF00).withOpacity(0.3) : Colors.transparent,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        leading: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: completed ? const Color(0xFF00FF00).withOpacity(0.1) : Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            completed ? Icons.check : Icons.close,
            color: completed ? const Color(0xFF00FF00) : Colors.grey,
            size: 20.0,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        trailing: Text(
          duration,
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
