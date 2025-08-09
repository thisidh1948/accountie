import 'package:accountie/home/access_management.dart';
import 'package:accountie/services/auth_service.dart';
import 'package:accountie/services/data_service.dart';
import 'package:accountie/theme/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // Import for Timer
import 'package:provider/provider.dart';

// PlaceholderPage if you still need it for other buttons
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('This is the $title page (Placeholder)')),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  bool _isLoading = true; // Loading state
  String? _error; // Error state

  // List of banner image asset paths
  final List<String> _bannerImages = [
    'assets/icons/banners/banner2.jpg', // Make sure these paths are correct
    'assets/icons/banners/banner3.jpg',
    // Add more banner image paths here
  ];
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DataService>(context, listen: false).fetchCategories();
    });
    _startBannerTimer(); // Start the timer for banner rotation
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        _currentBannerIndex = (_currentBannerIndex + 1) % _bannerImages.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    String userName = currentUser?.displayName != null
        ? "${currentUser?.displayName![0].toUpperCase()}"
        : 'U';

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: $_error')),
      );
    }

    final List<Map<String, dynamic>> allNavigationItems =
        getAllNavigationItems(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.transparent, // Make app bar transparent to blend with body
        elevation: 0, // Remove shadow
        title: Row(
          children: [
            Text(
              'Accountie',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
        ),
        actions: [
          // "Things to Action" text (optional, could be a button to a list)
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Things to Action clicked!')),
              );
            },
            child: Text(
              'Things to Action',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 16),
          // Heart icon
          IconButton(
            icon: Icon(Icons.favorite_border,
                color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {},
          ),
          // Hamburger menu icon to open the endDrawer
          Builder(
            // Use Builder to get a context that can find the Scaffold
            builder: (context) => IconButton(
              icon: Icon(Icons.menu,
                  color: Theme.of(context).colorScheme.onSurface),
              tooltip: 'Open Navigation',
              onPressed: () {
                Scaffold.of(context).openEndDrawer(); // Opens the endDrawer
              },
            ),
          ),
          // User avatar (moved after hamburger menu to match image)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
              child: Text(
                userName, // Default to 'U' if no name
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
      // Drawer for other navigation items
      endDrawer: Drawer(
        // Using endDrawer to match user icon position
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    radius: 30,
                    child: Text(
                      currentUser?.displayName != null
                          ? "${currentUser?.displayName![0].toUpperCase()}"
                          : 'U',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 24),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  Text(
                    currentUser?.email ?? currentUser?.email ?? 'N/A',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withOpacity(0.7)),
                  ),
                ],
              ),
            ),
            // Theme toggle
            ListTile(
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              ),
            ),
            // Other navigation buttons in the drawer (filtered by role)
            ...allNavigationItems
                .map((item) => ListTile(
                      leading: Icon(item['icon'] as IconData),
                      title: Text(item['label'] as String),
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  item['destinationPage'] as Widget),
                        );
                      },
                    ))
                .toList(),
            // Sign out button
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () async {
                Navigator.pop(context); // Close drawer
                await _authService.signOut();
              },
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Section: Greeting, Search, and Image Background
                Container(
                  // Use a Stack to place text and search bar on top of the image
                  height: 300, // Fixed height for the banner container
                  child: Stack(
                    children: [
                      // Background Image (fills the container)
                      Positioned.fill(
                        child: Image.asset(
                          _bannerImages[_currentBannerIndex],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: Colors.grey[300],
                            child: Center(
                                child: Icon(Icons.broken_image,
                                    color: Colors.grey[600])),
                          ),
                        ),
                      ),
                      // Optional: Add a subtle overlay for better text readability
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.3), // Dark overlay
                        ),
                      ),
                      // Content (Greeting, Search, etc.)
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Keep left-aligned as per image
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Center content vertically
                          children: [
                            Text(
                              'Hi $userName',
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors
                                        .white, // Text color for contrast on image
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Welcome to the IT Self Service Portal',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.white.withOpacity(
                                        0.8), // Text color for contrast
                                  ),
                            ),
                            const SizedBox(height: 32),
                            // Search Bar with constrained width
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                  maxWidth:
                                      450), // Set max width for the search bar
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'What are you looking for?',
                                  prefixIcon: const Icon(Icons.search,
                                      color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(
                                      0.9), // Slightly transparent white
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16.0, horizontal: 16.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Bottom Section: Action Cards (filtered based on mainActionCardLabels)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Things to Act On', // Title for the action cards section
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      GridView.count(
                        crossAxisCount: constraints.maxWidth > 1000
                            ? 4
                            : constraints.maxWidth > 600
                                ? 2
                                : 1,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        shrinkWrap:
                            true, // Important for GridView inside SingleChildScrollView
                        physics:
                            const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
                        childAspectRatio:
                            1.5, // Adjust aspect ratio for card size
                        children: allNavigationItems.map((item) {
                          return _buildActionCard(
                            context,
                            label: item['label'] as String,
                            subtitle: item['subtitle']
                                as String, // Helper for subtitles
                            icon: item['icon'] as IconData,
                            iconColor:
                                item['iconColor'], // Helper for icon colors
                            cardColor:
                                item['cardColor'], // Helper for card colors
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          item['destinationPage'] as Widget));
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper method to get subtitles for main action cards

  Widget _buildActionCard(
    BuildContext context, {
    required String label,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color cardColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: 48,
                color: iconColor,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
