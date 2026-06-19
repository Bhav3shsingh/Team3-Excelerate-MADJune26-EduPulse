import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MasterAdminApprovalPage extends StatefulWidget {
  const MasterAdminApprovalPage({super.key});

  @override
  State<MasterAdminApprovalPage> createState() => _MasterAdminApprovalPageState();
}

class _MasterAdminApprovalPageState extends State<MasterAdminApprovalPage> {
  bool _isLoading = false;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _cachedPending = [];

  Future<void> _showSnackbar(String message, {Color color = Colors.black87}) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> _confirmApproval(String email) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Approve pending admin'),
          content: Text('Approve $email as an admin?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );
    return result == true;
  }

  Future<String?> _promptPassword() async {
    final passwordController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm deletion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your password to confirm rejecting this pending admin.'),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return null;
    return passwordController.text.trim();
  }

  Future<bool> _reauthenticate(String password) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      await _showSnackbar('No signed-in user found.', color: Colors.redAccent);
      return false;
    }

    if (currentUser.email == null) {
      await _showSnackbar('Unable to reauthenticate: email is missing.', color: Colors.redAccent);
      return false;
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: password,
      );
      await currentUser.reauthenticateWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      await _showSnackbar(e.message ?? 'Reauthentication failed.', color: Colors.redAccent);
      return false;
    }
  }

  Future<void> _approve(String userId, String email) async {
    final confirmed = await _confirmApproval(email);
    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'role': 'admin',
      });
      await _showSnackbar('$email approved as admin.', color: Colors.green);
    } on FirebaseException catch (e) {
      // Surface Firestore-specific errors to the user
      final msg = e.message ?? 'Failed to approve $email.';
      await _showSnackbar(msg, color: Colors.redAccent);
      // log to console for debugging
      // ignore: avoid_print
      print('approve error: ${e.code} - $msg');
    } catch (e) {
      await _showSnackbar('Failed to approve $email: ${e.toString()}', color: Colors.redAccent);
      // ignore: avoid_print
      print('approve unexpected error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deletePending(String userId, String email) async {
    final password = await _promptPassword();
    if (password == null || password.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final reauthSucceeded = await _reauthenticate(password);
      if (!reauthSucceeded) return;

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'role': 'student'
      });
      await _showSnackbar('$email has been rejected and reverted to student.', color: Colors.orange);
    } on FirebaseException catch (e) {
      final msg = e.message ?? 'Failed to reject $email.';
      // Provide actionable hint for permission errors
      final display = e.code == 'permission-denied'
          ? 'Permission denied: you are not allowed to change roles. Check Firestore rules and make sure your account has role "master admin".'
          : msg;
      await _showSnackbar(display, color: Colors.redAccent);
      // ignore: avoid_print
      print('deletePending FirebaseException: ${e.code} - $msg');
    } catch (e) {
      await _showSnackbar('Failed to reject $email: ${e.toString()}', color: Colors.redAccent);
      // ignore: avoid_print
      print('deletePending unexpected error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Admin Controls'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'pending admin')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            if (snapshot.hasError) {
              final err = snapshot.error.toString();
              final display = err.contains('permission-denied')
                  ? 'Permission denied: your account cannot list users. Check Firestore rules and ensure you have role "master admin" in /users/{uid}.'
                  : err;
              return Center(child: Text(display));
            }
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          // If server returns results, update cache. If it returns empty but we
          // have cached pending entries, show the cached list to avoid a sudden
          // disappearance caused by transient server/permission issues.
          if (docs.isNotEmpty) {
            _cachedPending = docs;
          }

          final pendingAdmins = docs.isNotEmpty ? docs : _cachedPending;

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pendingAdmins.length,
                itemBuilder: (context, index) {
                  final doc = pendingAdmins[index];
                  final data = doc.data();
                  final email = data['email'] as String? ?? 'Unknown email';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('UID: ${doc.id}'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  onPressed: _isLoading
                                      ? null
                                      : () => _approve(doc.id, email),
                                  child: const Text('Approve'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  onPressed: _isLoading
                                      ? null
                                      : () => _deletePending(doc.id, email),
                                  child: const Text('Reject'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (_isLoading)
                Container(
                  color: Colors.black38,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(),
                ),
            ],
          );
        },
      ),
    );
  }
}
