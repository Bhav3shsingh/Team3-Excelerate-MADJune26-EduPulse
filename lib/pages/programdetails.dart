import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProgramDetails extends StatefulWidget {
  const ProgramDetails({super.key});

  @override
  State<ProgramDetails> createState() => _ProgramDetailsState();
}

class _ProgramDetailsState extends State<ProgramDetails> {
  bool _isEnrolled = false;
  bool _isLoading = true;
  String role = 'student';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadEnrollmentStatus();
  }

  Future<void> _loadEnrollmentStatus() async {
    final program =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};
    final programId = program['id'] as String?;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null || programId == null) {
      if (mounted) {
        setState(() {
          _isEnrolled = false;
          _isLoading = false;
        });
      }
      return;
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final registeredPrograms =
        (userDoc.data()?['programs'] as List<dynamic>?)?.cast<String>() ?? [];
    final _role = userDoc.data()?['role'] as String? ?? 'student';

    if (mounted) {
      setState(() {
        role = _role;
        _isEnrolled = registeredPrograms.contains(programId);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    int mode = 0; // 0 for upcoming, 1 for going on, 2 for past
    final program =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
        {};
    final programId = program['id'] as String?;

    if (programId == null) {
      return const Scaffold(body: Center(child: Text('Missing program data.')));
    }

    if (now.isAfter(DateTime.parse(program['endTime']))) {
      mode = 2;
    } else if (now.isAfter(DateTime.parse(program['startTime']))) {
      mode = 1;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Program Overview')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                program['imageUrl'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 12),
              Text(
                'Title: ${program['title']}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('Start Time: ${program['startTime']}'),
              const SizedBox(height: 8),
              Text('End Time: ${program['endTime']}'),
              const SizedBox(height: 8),
              Text('Description: ${program['description']}'),
              const SizedBox(height: 8),
              Text('Category: ${program['category']}'),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
                else
                Row(children:[ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (role == 'admin' || role == 'master admin') {
                      if (mode == 0) {
                        Navigator.pushNamed(
                          context,
                          '/program-edit',
                          arguments: program,
                        );
                        return;
                      }
                      if (mode == 2 || mode==1) {
                        Navigator.pushNamed(
                          context,
                          '/reviews',
                          arguments: program,
                        );
                        return;
                      }
                    } else {
                      if (!_isEnrolled && mode == 0) {
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        final programRef = FirebaseFirestore.instance
                            .collection('programs')
                            .doc(programId);
                        final userRef = FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid);

                        if (uid == null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please sign in to enroll.'),
                              ),
                            );
                          }
                          return;
                        }

                        try {
                          await FirebaseFirestore.instance.runTransaction((
                            transaction,
                          ) async {
                            final userSnapshot = await transaction.get(userRef);
                            if (!userSnapshot.exists) {
                              throw FirebaseException(
                                plugin: 'cloud_firestore',
                                message: 'User record not found.',
                              );
                            }

                            transaction.update(programRef, {
                              'participants': FieldValue.arrayUnion([uid]),
                            });
                            transaction.update(userRef, {
                              'programs': FieldValue.arrayUnion([programId]),
                            });
                          });

                          if (mounted) {
                            setState(() {
                              _isEnrolled = true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Enrolled successfully.'),
                              ),
                            );
                          }
                        } catch (error) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Enrollment failed: $error'),
                              ),
                            );
                          }
                        }
                      } else if (_isEnrolled) {
                        if (mode == 1) {
                          _launchMeetingLink(Uri.parse(program['meetingLink']));
                        } else if (mode == 2) {
                          Navigator.pushNamed(
                            context,
                            '/feedback',
                            arguments: programId,
                          );
                        }
                      }
                    }
                  },
                  child: Text(
                    role == 'admin' || role == 'master admin'
                        ? (mode == 0
                              ? 'Edit Program'
                              : 'View Feedback')
                        : _isEnrolled
                        ? (mode == 0
                              ? 'Program will start'
                              : mode == 1
                              ? 'Join Program'
                              : 'Submit Feedback')
                        : (mode == 0
                              ? 'Join Program'
                              : 'You can no longer enroll'),
                  ),
                ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child:Text('Manage Participants'),
                  onPressed:(){
                    Navigator.pushNamed(
                        context,
                        '/manage-participants',
                        arguments: program,
                    );
                  }
              )]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchMeetingLink(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $uri';
    }
  }
}

class ManageParticipantsPage extends StatefulWidget {
  const ManageParticipantsPage({super.key});

  @override
  State<ManageParticipantsPage> createState() => _ManageParticipantsPageState();
}

class _ManageParticipantsPageState extends State<ManageParticipantsPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _enrolledUsers = [];
  List<String> _participantIds = [];
  String _programTitle = 'Program';
  String? _programId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final programId = routeArgs?['id'] as String?;
    final programTitle = routeArgs?['title'] as String?;

    if (programId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _programTitle = 'Unknown Program';
        });
      }
      return;
    }

    try {
      final programDoc = await FirebaseFirestore.instance
          .collection('programs')
          .doc(programId)
          .get();
      final programData = programDoc.data() ?? {};
      final participantIds =
          (programData['participants'] as List<dynamic>?)?.cast<String>() ?? [];

      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      final users = usersSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'email': data['email'] as String? ?? 'Unknown email',
          'name':
              data['name'] as String? ?? data['displayName'] as String? ?? '',
          'role': data['role'] as String? ?? '',
          'programs':
              (data['programs'] as List<dynamic>?)?.cast<String>() ?? [],
        };
      }).toList();

      final enrolledUsers = users
          .where((user) => participantIds.contains(user['id'] as String))
          .toList();

      if (mounted) {
        setState(() {
          _programId = programId;
          _programTitle =
              programTitle ?? programData['title'] as String? ?? 'Program';
          _participantIds = participantIds;
          _allUsers = users;
          _enrolledUsers = enrolledUsers;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load users: $error')));
    }
  }

  List<Map<String, dynamic>> get _candidateUsers {
    final query = _searchController.text.trim().toLowerCase();
    return _allUsers.where((user) {
      final id = user['id'] as String;
      if (_participantIds.contains(id)) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final email = (user['email'] as String).toLowerCase();
      final name = (user['name'] as String).toLowerCase();
      return email.contains(query) ||
          name.contains(query) ||
          id.contains(query);
    }).toList();
  }

  Future<void> _unenrollUser(String userId) async {
    if (_programId == null) return;
    setState(() {
      _isSaving = true;
    });
    try {
      final programRef = FirebaseFirestore.instance
          .collection('programs')
          .doc(_programId);
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(programRef, {
          'participants': FieldValue.arrayRemove([userId]),
        });
        transaction.update(userRef, {
          'programs': FieldValue.arrayRemove([_programId]),
        });
      });
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Participant removed.')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not remove participant: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _enrollUser(String userId) async {
    if (_programId == null) return;
    setState(() {
      _isSaving = true;
    });
    try {
      final programRef = FirebaseFirestore.instance
          .collection('programs')
          .doc(_programId);
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.update(programRef, {
          'participants': FieldValue.arrayUnion([userId]),
        });
        transaction.update(userRef, {
          'programs': FieldValue.arrayUnion([_programId]),
        });
      });
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Participant added.')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not add participant: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Participants')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _programTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Enrolled Participants',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  if (_enrolledUsers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No participants are enrolled yet.'),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _enrolledUsers.length,
                        itemBuilder: (context, index) {
                          final user = _enrolledUsers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(user['email'] as String),
                              subtitle: Text(
                                (user['name'] as String).isEmpty
                                    ? 'UID: ${user['id']}'
                                    : user['name'] as String,
                              ),
                              trailing: _isSaving
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () =>
                                          _unenrollUser(user['id'] as String),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text(
                    'Add Participant',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search users by email or name',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _candidateUsers.isEmpty
                        ? const Center(
                            child: Text('No users available to add.'),
                          )
                        : ListView.builder(
                            itemCount: _candidateUsers.length,
                            itemBuilder: (context, index) {
                              final user = _candidateUsers[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  title: Text(user['email'] as String),
                                  subtitle: Text(
                                    (user['name'] as String).isEmpty
                                        ? 'UID: ${user['id']}'
                                        : user['name'] as String,
                                  ),
                                  trailing: _isSaving
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : ElevatedButton(
                                          onPressed: () =>
                                              _enrollUser(user['id'] as String),
                                          child: const Text('Add'),
                                        ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
