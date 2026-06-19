import 'package:cloud_firestore/cloud_firestore.dart';
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
    const ProgramListingPageAdmin(),
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

class ProgramListingPageAdmin extends StatefulWidget{
  const ProgramListingPageAdmin({super.key});

  @override
  State<ProgramListingPageAdmin> createState() => _ProgramListingPageAdminState();
}

class _ProgramListingPageAdminState extends State<ProgramListingPageAdmin> {

  //sample data
  List<Map<String,dynamic>> programs = []; // initialize to avoid runtime 'not initialized' error

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final snapshot = await FirebaseFirestore.instance.collection("programs").get();
    if (!mounted) return;
    setState(() {
      programs = snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  Widget build(Object context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Program Listing"), centerTitle: true),
      body: ListView.builder(
        itemCount: programs.length,
        itemBuilder: (context,index){
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(programs[index]["name"], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(programs[index]["description"]),
                const SizedBox(height: 8)                  ],
            ),
          );
        },
      ),
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

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _role = '';
  bool _isLoadingRole = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _isLoadingRole = false;
      });
      return;
    }

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      _role = doc.data()?['role'] as String? ?? '';
      _isLoadingRole = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'Unknown UID';
    final email = FirebaseAuth.instance.currentUser?.email ?? 'Unknown email';

    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('UID: $uid', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Email: $email', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            if (_isLoadingRole)
              const Center(child: CircularProgressIndicator())
            else
              Text('Role: ${_role.isEmpty ? 'Unknown' : _role}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            if (!_isLoadingRole && _role == 'master admin')
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/pending-admins');
                },
                child: const Text('Manage Pending Admins'),
              ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              child: const Text("Sign out"),
            ),
          ],
        ),
      ),
    );
  }
}