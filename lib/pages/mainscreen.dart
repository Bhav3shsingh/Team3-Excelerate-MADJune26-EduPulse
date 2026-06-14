import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Tracks the current index of the bottom bar
  int _selectedIndex = 0;

  // List of the actual screen widgets corresponding to each tab
  final List<Widget> _pages = [
    const ProgramListingPage(),
    const DashboardPage(),
    const ProfilePage(),
  ];

  // Function to update the selected index when a tab is tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body displays the active screen based on _selectedIndex
      body: _pages[_selectedIndex],
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // Using fixed type ensures all icons and labels stay visible when selected
        type: BottomNavigationBarType.fixed, 
        selectedItemColor: Colors.blue, // Color for the active tab
        unselectedItemColor: Colors.grey, // Color for inactive tabs
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Programs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class ProgramListingPage extends StatelessWidget {
  const ProgramListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Program Listing"), centerTitle: true),
      body: const Center(child: Text("Program Listing Content")),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard"), centerTitle: true),
      body: const Center(child: Text("Dashboard Content")),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), centerTitle: true),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
            Center(
              child:Text("UID: ${FirebaseAuth.instance.currentUser?.uid}\nEmail : ${FirebaseAuth.instance.currentUser?.email}")
            ),
            OutlinedButton(onPressed: (){
              FirebaseAuth.instance.signOut();
            }, child: Text("sign out"))
        ],
      ),
    );
  }
}