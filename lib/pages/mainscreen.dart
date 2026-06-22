import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as img;
import 'package:intl/intl.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool swap = false; // swaps programs for different roles

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
  void initState() {
    super.initState();
    _decider();
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
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Programs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          )
        ],
      ),
    );
  }
  
  void _decider() async {
    // decides program listing page based on role
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final role = doc.data()?['role'] as String?;
        setState(() {
          swap = (role == 'admin' || role == 'master admin');
          _pages[0] = swap ? const ProgramListingPageAdmin() : const ProgramListingPage();
        });
      }
    }
  }
}

class ProgramListingPage extends StatefulWidget {
  const ProgramListingPage({super.key});

  @override
  State<ProgramListingPage> createState() => _ProgramListingPageState();
}

class _ProgramListingPageState extends State<ProgramListingPage> {
  List<Map<String, dynamic>> data = [];
  int userType = 0; // 0 for regular user, 1 for admin
  List<String> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard"), centerTitle: true),
      body: Column(
      children: [
        Expanded(
          child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                final title = item["title"] as String? ?? "No Title";
                final startTime = item["startTime"] as String? ?? "No Time";
                final endTime = item["endTime"] as String? ?? "No Time";

                //formatting 
                final st = DateFormat('yyyy-MM-dd HH:mm').parseStrict(startTime);
                final et = DateFormat('yyyy-MM-dd HH:mm').parseStrict(endTime);

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/program-details', arguments: item);
                  },
                  child: Card(
                    child: ListTile(
                      title: Text(title),
                      subtitle: Text("from ${st.day}/${st.month}/${st.year},${st.hour}:${st.minute} to ${et.day}/${et.month}/${et.year},${et.hour}:${et.minute}"),
                    ),
                  ),
                );
              },
            ),
          ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(12),
                child: Text(
                        "Notifications",
                        style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            SingleChildScrollView(
              child: 
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.notifications),
                        title: Text(notifications[index])
                      );
                    },
                )
            )
        ]
      )
    );
  }
  
  void _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return;
    }
  

    final userDoc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
    final userRole = userDoc.data()?['role'] as String? ?? "student";
    
    userType = userRole == "admin" || userRole == "master admin" ? 1 : 0;

    final registeredPrograms = (userDoc.data()?['programs'] as List<dynamic>?)?.cast<String>() ?? [];

    if (registeredPrograms.isEmpty) {
      if (!mounted) return;
      setState(() {
        data = [];
      });
      return;
    }

    //TODO Firestore whereIn only supports up to 10 values. 
    //If registeredPrograms can contain more than 10 IDs, this will fail.
    final snapshot = await FirebaseFirestore.instance
        .collection("programs")
        .where(FieldPath.documentId, whereIn: registeredPrograms)
        .get();
    if (!mounted) return;
    setState(() {
      data = snapshot.docs.map((doc) => doc.data()).toList();
    });
  }
}

class ProgramListingPageAdmin extends StatefulWidget{
  const ProgramListingPageAdmin({super.key});

  @override
  State<ProgramListingPageAdmin> createState() => _ProgramListingPageAdminState();
}

class _ProgramListingPageAdminState extends State<ProgramListingPageAdmin> {

  List<Map<String,dynamic>> programs = [];
  List<String> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final snapshot = await FirebaseFirestore.instance.collection("programs").get();
    final notificationsSnapshot = await FirebaseFirestore.instance.collection("notifications").get();    
    if (!mounted) return;
    
    final loadedNotifications = notificationsSnapshot.docs
        .map((doc) => doc.data()['message'] as String? ?? '')
        .toList();
    
    final loadedPrograms = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'title': data['title'],
        'description': data['description'],
        'imageUrl': data['imageUrl'],
        'startTime': data['startTime'],
        'endTime': data['endTime'],
      };
    }).toList();
    
    setState(() {
      notifications = loadedNotifications;
      programs = loadedPrograms;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard"), centerTitle: true),
      body: Column(
        children: [
          Padding(
              padding: EdgeInsets.all(12),
                child: Text(
                        "Notifications",
                        style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            Row(
              children:[GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/newnotifications');
              },
              child: Container(
                color: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Text("New Notifications", style: TextStyle(color: Colors.white)),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/notifications');
              },
              child: Container(
                color: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const Text("View Notifications", style: TextStyle(color: Colors.white)),
              ),
            )
            ]
            ),
          Expanded(
            child: ListView.builder(
              itemCount: programs.length,
              itemBuilder: (context,index){
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/program-details', arguments: programs[index]);
                  },
                  child: Container(
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
                      Text(
                        programs[index]["title"] as String? ?? 'Untitled Program',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        () {
                          final desc = (programs[index]["description"] as String?) ?? '';
                          return desc.length > 100 ? desc.substring(0, 100) + '...' : desc;
                        }(),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                )
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final created = await Navigator.pushNamed(context, '/program-create');
                  if (created == true) {
                    _loadData();
                  }
                },
                child: const Text("Create New Program"),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  List<Map<String,dynamic>> programs = [];
  List<Map<String,dynamic>> filteredPrograms = [];

  Future<void> _loadData() async {
    final snapshot = await FirebaseFirestore.instance.collection("programs").get();
    if (!mounted) return;
    setState(() {
      programs = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
      filteredPrograms = programs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Programs"), centerTitle: true),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search Programs',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if(value.isEmpty || value.trim()=="" ){
                        filteredPrograms = programs;
                      } else {
                        setState(() {
                          filteredPrograms = programs.where((program) {
                            final title = program["title"] as String? ?? '';
                           final category = program["category"] as String? ?? '';
                            final tags = program["tags"] as String? ?? '';
                            return title.toLowerCase().contains(value.toLowerCase()) || category.toLowerCase().contains(value.toLowerCase()) || tags.toLowerCase().contains(value.toLowerCase());
                          }).toList();
                        });
                      }
                    },
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    setState(() {
                      _searchController.clear();
                      filteredPrograms = programs;
                    });
                  });
                },
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPrograms.length,
              itemBuilder: (context,index){
                final item = filteredPrograms[index];
                final title = item["title"] as String? ?? "No Title";
                final description = item["description"] as String? ?? "No Description";
                final startTime = item["startTime"] as String? ?? "No Time";
                final endTime = item["endTime"] as String? ?? "No Time";

                //formatting 
                final st = DateFormat('yyyy-MM-dd HH:mm').parseStrict(startTime);
                final et = DateFormat('yyyy-MM-dd HH:mm').parseStrict(endTime);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/program-details', arguments: item);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        img.Image.network(item["imageUrl"] as String? ?? 'https://picsum.photos/400/100'),
                        const SizedBox(height: 8),
                        Text(title,style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description.length > 100 ? description.substring(0, 100) + '...' : description,
                        ),
                        const SizedBox(height: 8),
                        Text("on ${st.day}/${st.month}/${st.year},${st.hour}:${st.minute} till ${et.day}/${et.month}/${et.year},${et.hour}:${et.minute}"),
                        const SizedBox(height: 8)
                    ],
                  ),
                )
                );
              },
            ),
          ),
        ],
      )
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