import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../core/services/audio_service.dart'; // Assuming this exists from initial files

class SoundSelectionScreen extends StatefulWidget {
  const SoundSelectionScreen({Key? key}) : super(key: key);

  @override
  _SoundSelectionScreenState createState() => _SoundSelectionScreenState();
}

class _SoundSelectionScreenState extends State<SoundSelectionScreen> {
  // Note: Ideally, this should be fetched from a provider or service.
  // Using a mock list for demonstration.
  final List<SoundItem> _sounds = [
    SoundItem(id: 'rain', name: 'Heavy Rain', icon: Icons.water_drop_outlined, assetPath: 'assets/sounds/rain.mp3'),
    SoundItem(id: 'forest', name: 'Forest Birds', icon: Icons.forest_outlined, assetPath: 'assets/sounds/forest.mp3'),
    SoundItem(id: 'lofi', name: 'Lo-Fi Beats', icon: Icons.music_note_outlined, assetPath: 'assets/sounds/lofi.mp3'),
    SoundItem(id: 'ocean', name: 'Ocean Waves', icon: Icons.waves_outlined, assetPath: 'assets/sounds/ocean.mp3'),
    SoundItem(id: 'fire', name: 'Campfire', icon: Icons.local_fire_department_outlined, assetPath: 'assets/sounds/fire.mp3'),
    SoundItem(id: 'white_noise', name: 'White Noise', icon: Icons.blur_on_outlined, assetPath: 'assets/sounds/white_noise.mp3'),
  ];

  String? _selectedSoundId;
  final AudioService _audioService = AudioService(); // Assuming instantiation is allowed or GetIt

  @override
  void initState() {
    super.initState();
    // Load currently selected sound from preferences if needed
    _selectedSoundId = 'rain'; // Default
  }

  void _selectSound(String? id) {
    if (id == null) return;
    
    setState(() {
      _selectedSoundId = id;
    });

    // Play preview
    // Note: AudioService implementation details would go here
    // _audioService.playBackgroundSound(id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Sound selected: ${_sounds.firstWhere((s) => s.id == id).name}"),
        backgroundColor: AppColors.surfaceBlack,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        title: const Text("Focus Sounds", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surfaceBlack,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Choose your ambient background",
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemCount: _sounds.length,
                itemBuilder: (context, index) {
                  final sound = _sounds[index];
                  final isSelected = _selectedSoundId == sound.id;
                  
                  return _buildSoundCard(sound, isSelected);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundCard(SoundItem sound, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectSound(sound.id),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceBlack,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accentGreen : Colors.grey[850]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected 
            ? [BoxShadow(color: AppColors.accentGreen.withOpacity(0.2), blurRadius: 15, spreadRadius: 2)]
            : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentGreen.withOpacity(0.1) : Colors.grey[800],
                shape: BoxShape.circle,
              ),
              child: Icon(
                sound.icon,
                color: isSelected ? AppColors.accentGreen : Colors.white70,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              sound.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[400],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Model class for sound items
class SoundItem {
  final String id;
  final String name;
  final IconData icon;
  final String assetPath;

  SoundItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.assetPath,
  });
}
