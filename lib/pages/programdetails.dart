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
    final program = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
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

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final registeredPrograms = (userDoc.data()?['programs'] as List<dynamic>?)?.cast<String>() ?? [];
    final _role = userDoc.data()?['role'] as String? ?? 'student';


    if (mounted) {
      setState(() {
        role=_role;
        _isEnrolled = registeredPrograms.contains(programId);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    int mode = 0; // 0 for upcoming, 1 for going on, 2 for past
    final program = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final programId = program['id'] as String?;

    

    if (programId == null) {
      return const Scaffold(
        body: Center(child: Text('Missing program data.')),
      );
    }

    if (now.isAfter(DateTime.parse(program['endTime']))) {
      mode = 2;
    } else if (now.isAfter(DateTime.parse(program['startTime']))) {
      mode = 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Program Overview'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(program['imageUrl'], height: 200, width: double.infinity, fit: BoxFit.cover),
              const SizedBox(height: 12),
              Text('Title: ${program['title']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                ElevatedButton(
                  onPressed: () async {
                    //TODO add admin button functions for rest of labels
                    
                    if(role=='admin' || role=='master admin'){
                      if(mode==2){
                        Navigator.pushNamed(context, '/reviews',arguments: program);
                      }
                    }else{
                      if(!_isEnrolled&&mode==0){
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          final programRef = FirebaseFirestore.instance.collection('programs').doc(programId);
                          final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

                          if (uid == null) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please sign in to enroll.')),
                              );
                            }
                            return;
                          }

                          try {
                            await FirebaseFirestore.instance.runTransaction((transaction) async {
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
                                const SnackBar(content: Text('Enrolled successfully.')),
                              );
                            }
                          } catch (error) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Enrollment failed: $error')),
                              );
                            }
                          }
                        }else if(_isEnrolled){
                            if(mode==1){
                              _launchMeetingLink(Uri.parse(program['meetingLink']));
                            }
                            else if(mode==2){
                              Navigator.pushNamed(context, '/feedback', arguments: programId);
                            }
                        }
                  }
                  },
                  child: Text(
                    role == 'admin'||role=='master admin'? (mode == 0 ? 'Edit Program' : mode == 1 ? 'Manage Participants' : 'View Feedback'):
                    _isEnrolled? (mode == 0 ? 'Program will start' : mode == 1 ? 'Join Program' : 'Submit Feedback'): 
                    (mode == 0 ? 'Join Program' : 'You can no longer enroll')
                  ),
                ),
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
 