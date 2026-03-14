import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/animated_shield.dart';
import '../widgets/premium_glass_card.dart';

class FocusModeScreen extends StatefulWidget {
  const FocusModeScreen({Key? key}) : super(key: key);

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  bool _isFocusModeActive = false;

  void _toggleFocusMode() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isFocusModeActive = !_isFocusModeActive;
    });
    // In production, this will trigger AppBlockerService via MethodChannel
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children:[
            const SizedBox(height: 60.0),
            AnimatedShield(
              isActive: _isFocusModeActive,
              size: 160.0,
            ),
            const SizedBox(height: 40.0),
            Text(
              _isFocusModeActive ? 'STRICT FOCUS ACTIVE' : 'FOCUS MODE OFFLINE',
              style: TextStyle(
                color: _isFocusModeActive ? const Color(0xFF00FF00) : Colors.white,
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 12.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                _isFocusModeActive
                    ? 'Distracting apps are currently blocked. Stay focused on your goals.'
                    : 'Activate Focus Mode to block social media and avoid distractions.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14.0,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 48.0),
            GestureDetector(
              onTap: _toggleFocusMode,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  color: _isFocusModeActive ? Colors.transparent : const Color(0xFF00FF00),
                  border: Border.all(
                    color: const Color(0xFF00FF00),
                    width: 2.0,
                  ),
                ),
                child: Text(
                  _isFocusModeActive ? 'DEACTIVATE' : 'ACTIVATE SHIELD',
                  style: TextStyle(
                    color: _isFocusModeActive ? const Color(0xFF00FF00) : Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: _buildAppList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppList() {
    return PremiumGlassCard(
      borderRadius: 24.0,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children:[
          const Text(
            'BLOCKED APPLICATIONS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16.0),
          _buildAppItem('Instagram', Icons.camera_alt),
          _buildAppItem('TikTok', Icons.music_note),
          _buildAppItem('Twitter / X', Icons.message),
        ],
      ),
    );
  }

  Widget _buildAppItem(String name, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children:[
          Icon(icon, color: Colors.grey, size: 24.0),
          const SizedBox(width: 16.0),
          Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 16.0),
          ),
          const Spacer(),
          Switch(
            value: true,
            activeColor: const Color(0xFF00FF00),
            onChanged: (val) {
              // Logic to individually toggle app block status
            },
          ),
        ],
      ),
    );
  }
}
