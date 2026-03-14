import 'package:flutter/material.dart';
import '../widgets/premium_glass_card.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'GLOBAL RANKING',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        actions:[
          IconButton(
            icon: const Icon(Icons.sync, color: Color(0xFF00FF00)),
            onPressed: () {
              // Trigger sync logic
            },
          ),
        ],
      ),
      body: Column(
        children:[
          const SizedBox(height: 24.0),
          _buildTopThree(),
          const SizedBox(height: 32.0),
          Expanded(
            child: _buildRankList(),
          ),
          _buildCurrentUserRank(),
        ],
      ),
    );
  }

  Widget _buildTopThree() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children:[
        _buildPodium(name: 'Alex M.', time: '45h', rank: 2, height: 120.0, color: const Color(0xFFC0C0C0)),
        const SizedBox(width: 16.0),
        _buildPodium(name: 'Sarah K.', time: '52h', rank: 1, height: 160.0, color: const Color(0xFFFFD700), isFirst: true),
        const SizedBox(width: 16.0),
        _buildPodium(name: 'David R.', time: '41h', rank: 3, height: 100.0, color: const Color(0xFFCD7F32)),
      ],
    );
  }

  Widget _buildPodium({
    required String name,
    required String time,
    required int rank,
    required double height,
    required Color color,
    bool isFirst = false,
  }) {
    return Column(
      children:[
        Text(
          name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4.0),
        Text(
          time,
          style: const TextStyle(color: Colors.grey, fontSize: 12.0),
        ),
        const SizedBox(height: 12.0),
        Container(
          width: 80.0,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
            border: Border.all(color: color.withOpacity(0.5), width: 1.5),
            boxShadow: isFirst
                ?[
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 20.0,
                      spreadRadius: 2.0,
                    )
                  ]
                :[],
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                color: color,
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankList() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
        physics: const BouncingScrollPhysics(),
        itemCount: 20, // Mock 20 users
        itemBuilder: (context, index) {
          final rank = index + 4; // Starting from 4th
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            leading: Text(
              '#$rank',
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            title: Text(
              'User $rank',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            trailing: Text(
              '${40 - index}h 20m',
              style: const TextStyle(color: Color(0xFF00FF00), fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentUserRank() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(color: Color(0xFF333333), width: 1.0),
        ),
      ),
      child: Row(
        children:[
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: const Color(0xFF00FF00).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Text(
              '42',
              style: TextStyle(
                color: Color(0xFF00FF00),
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children:[
              Text(
                'You',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
              Text(
                'Keep going to reach top 10!',
                style: TextStyle(color: Colors.grey, fontSize: 12.0),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            '12h 45m',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}
