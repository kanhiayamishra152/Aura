import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../config/app_colors.dart';
import '../../core/services/study_tube_service.dart';

class StudyTubeScreen extends StatefulWidget {
  const StudyTubeScreen({Key? key}) : super(key: key);

  @override
  _StudyTubeScreenState createState() => _StudyTubeScreenState();
}

class _StudyTubeScreenState extends State<StudyTubeScreen> {
  late YoutubePlayerController _controller;
  final StudyTubeService _studyTubeService = StudyTubeService();
  final TextEditingController _searchController = TextEditingController();
  String? _currentVideoId;

  @override
  void initState() {
    super.initState();
    // Initialize with a default educational video ID (e.g., MIT OpenCourseWare)
    _loadVideo('wIzcPl4kvfg'); 
  }

  void _loadVideo(String videoId) {
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
      ),
    );
    setState(() {
      _currentVideoId = videoId;
    });
  }

  void _onSearchSubmit(String query) {
    final sanitizedQuery = _studyTubeService.sanitizeSearchQuery(query);
    if (sanitizedQuery == null) {
      _showErrorDialog("Search Restricted", "Only educational keywords are allowed.");
      return;
    }
    
    // Note: Actual search requires YouTube Data API. 
    // Here we simulate the action for the UI.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Searching for: $sanitizedQuery (Demo Mode)")),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceBlack,
        title: Text(title, style: const TextStyle(color: AppColors.accentGreen)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK", style: TextStyle(color: AppColors.accentGreen)),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        title: const Text("Study Tube", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surfaceBlack,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search educational topics...",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: AppColors.surfaceBlack,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: AppColors.accentGreen),
                    onPressed: () => _onSearchSubmit(_searchController.text),
                  ),
                ),
                onSubmitted: _onSearchSubmit,
              ),
            ),

            // Video Player
            YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: AppColors.accentGreen,
                progressColors: const ProgressBarColors(
                  playedColor: AppColors.accentGreen,
                  handleColor: Colors.white,
                ),
              ),
              builder: (context, player) {
                return Column(
                  children: [
                    // player
                    player,
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // Whitelisted Channels / Suggestions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recommended Channels",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildChannelCard("MIT OpenCourseWare", "UCwRXb5dUK4cvsHbx-rGDeSg"),
                      _buildChannelCard("Science ABC", "UCSHZKyawb77iyD7GPsdcOlA"),
                      _buildChannelCard("Mathologer", "UC6107grRI4m0o2-exgo1gig"),
                      _buildChannelCard("ElectroBOOM", "UCJ0-OtVpF0wOKEqT2Z1HEtA"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelCard(String title, String channelId) {
    return GestureDetector(
      onTap: () {
        // In a full implementation, this would load a playlist from this channel
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Loading content from $title... (Demo)")),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceBlack,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
