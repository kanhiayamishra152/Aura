import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/app_blocker_provider.dart';
import '../../utils/haptic_utils.dart';

class AppWhitelistScreen extends StatefulWidget {
  const AppWhitelistScreen({Key? key}) : super(key: key);

  @override
  State<AppWhitelistScreen> createState() => _AppWhitelistScreenState();
}

class _AppWhitelistScreenState extends State<AppWhitelistScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Allowed Apps',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: const Color(0xFF333333), width: 1.5),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                cursorColor: const Color(0xFF39FF14),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search applications...',
                  hintStyle: TextStyle(color: Color(0xFF777777)),
                  prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF777777)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<AppBlockerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF39FF14),
              ),
            );
          }

          if (!provider.hasPermissions) {
            return _buildPermissionRequest(provider);
          }

          final filteredApps = provider.installedApps.where((app) {
            return app.appName.toLowerCase().contains(_searchQuery);
          }).toList();

          if (filteredApps.isEmpty) {
            return const Center(
              child: Text(
                'No applications found.',
                style: TextStyle(color: Color(0xFF888888), fontSize: 16.0),
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            itemCount: filteredApps.length,
            itemBuilder: (context, index) {
              final app = filteredApps[index];
              final isWhitelisted = provider.whitelistedPackages.contains(app.packageName);

              return Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                decoration: BoxDecoration(
                  color: isWhitelisted ? const Color(0xFF39FF14).withOpacity(0.05) : const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: isWhitelisted ? const Color(0xFF39FF14).withOpacity(0.5) : const Color(0xFF222222),
                    width: 1.0,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  leading: app.iconData != null
                      ? Image.memory(app.iconData!, width: 40, height: 40)
                      : const CircleAvatar(
                          backgroundColor: Color(0xFF222222),
                          child: Icon(Icons.android, color: Color(0xFF555555)),
                        ),
                  title: Text(
                    app.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: isWhitelisted ? FontWeight.w700 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    app.packageName,
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 12.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Switch.adaptive(
                    value: isWhitelisted,
                    activeColor: Colors.black,
                    activeTrackColor: const Color(0xFF39FF14),
                    inactiveThumbColor: const Color(0xFF888888),
                    inactiveTrackColor: const Color(0xFF333333),
                    onChanged: (bool value) {
                      HapticUtils.selectionClick();
                      provider.toggleAppWhitelist(app.packageName);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPermissionRequest(AppBlockerProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.redAccent.withOpacity(0.5), width: 2.0),
            ),
            child: const Icon(
              Icons.security_rounded,
              size: 64.0,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 32.0),
          const Text(
            'Permissions Required',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16.0),
          const Text(
            'To block distracting apps during Focus Mode, you need to grant Accessibility and Usage Access permissions in your Android Settings.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF888888),
              fontSize: 15.0,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48.0),
          GestureDetector(
            onTap: () async {
              HapticUtils.heavyImpact();
              await provider.requestPermissions();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18.0),
              decoration: BoxDecoration(
                color: const Color(0xFF39FF14),
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: const[
                  BoxShadow(
                    color: Color(0x6639FF14),
                    blurRadius: 20.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'GRANT PERMISSIONS',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
