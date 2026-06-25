import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProgramCreateScreen extends StatefulWidget {
  const ProgramCreateScreen({super.key});

  @override
  State<ProgramCreateScreen> createState() => _ProgramCreateScreenState();
}

class _ProgramCreateScreenState extends State<ProgramCreateScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _meetingLinkController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _categoryController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _tagsController = TextEditingController();
  DateTime? _startDateTime;
  DateTime? _endDateTime;

  void _showErrorSnackbar(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4)
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _meetingLinkController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  Future<void> _createProgram() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final meetingLink = _meetingLinkController.text.trim();
    final imageUrl = _imageUrlController.text.trim();
    final category = _categoryController.text.trim();
    final tags = _tagsController.text.trim();

    bool created = false;
    try {
      final docRef = FirebaseFirestore.instance.collection('programs').doc();
      await docRef.set({
        'id': docRef.id,
        'title': title,
        'description': description,
        'meetingLink': meetingLink,
        'imageUrl': imageUrl,
        'category': category,
        'tags': tags,
        'startTime': _startDateTime != null ? _formatDateTime(_startDateTime!) : null,
        'endTime': _endDateTime != null ? _formatDateTime(_endDateTime!) : null,
        'participants': [],
        'reviews': ''
      });
      created = true;
    } catch (e) {
      _showErrorSnackbar("Failed to create program. Please try again.");
      created = false;
    }
    if (created && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create New Program"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Program Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 4,
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Program Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _meetingLinkController,
              decoration: const InputDecoration(
                labelText: "Meeting Link",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: "Image URL",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _startTimeController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Start Date & Time",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_month),
              ),
              onTap: () async {
                final now = DateTime.now();
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _startDateTime ?? now,
                  firstDate: now,
                  lastDate: DateTime(now.year + 1),
                );
                if (pickedDate == null) return;
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: _startDateTime != null
                      ? TimeOfDay.fromDateTime(_startDateTime!)
                      : TimeOfDay(hour: now.hour, minute: now.minute),
                );
                if (pickedTime == null) return;
                final dateTime = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );
                _startDateTime = dateTime;
                _startTimeController.text = _formatDateTime(dateTime);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _endTimeController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "End Date & Time",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_month),
              ),
              onTap: () async {
                final now = DateTime.now();
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _endDateTime ?? _startDateTime ?? now,
                  firstDate: _startDateTime ?? now,
                  lastDate: DateTime(now.year + 1),
                );
                if (pickedDate == null) return;
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: _endDateTime != null
                      ? TimeOfDay.fromDateTime(_endDateTime!)
                      : TimeOfDay(hour: now.hour, minute: now.minute),
                );
                if (pickedTime == null) return;
                final dateTime = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );
                _endDateTime = dateTime;
                _endTimeController.text = _formatDateTime(dateTime);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: "Tags for better search",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () async {
                if (_startDateTime == null || _endDateTime == null) {
                  _showErrorSnackbar("Please select both start and end date & time.");
                  return;
                } else if (_endDateTime!.isBefore(_startDateTime!)) {
                  _showErrorSnackbar("End date & time cannot be before start date & time.");
                  return;
                } else if (_startDateTime!.isBefore(DateTime.now())) {
                  _showErrorSnackbar("Start date & time cannot be in the past.");
                  return;
                } else if (_endDateTime!.isBefore(DateTime.now())) {
                  _showErrorSnackbar("End date & time cannot be in the past.");
                  return;
                } else if (_titleController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty || _meetingLinkController.text.trim().isEmpty || _imageUrlController.text.trim().isEmpty || _categoryController.text.trim().isEmpty || _tagsController.text.trim().isEmpty) {
                  _showErrorSnackbar("Please fill in all fields.");
                  return;
                } else if (!_meetingLinkController.text.trim().startsWith("http")) {
                  _showErrorSnackbar("Please enter a valid meeting link.");
                  return;
                } else if (!_imageUrlController.text.trim().startsWith("http")) {
                  _showErrorSnackbar("Please enter a valid image URL.");
                  return;
                } else {
                  await _createProgram();
                }
              },
              child: const Text("Create Program"),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }
}

class ProgramEditScreen extends StatefulWidget {
  const ProgramEditScreen({super.key});

  @override
  State<ProgramEditScreen> createState() => _ProgramEditScreenState();
}

class _ProgramEditScreenState extends State<ProgramEditScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _meetingLinkController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _categoryController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _tagsController = TextEditingController();
  DateTime? _startDateTime;
  DateTime? _endDateTime;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isDeleting = false;
  String? _programId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _loadProgram();
    }
  }

  Future<void> _loadProgram() async {
    final program = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (program == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    _programId = program['id'] as String?;
    _titleController.text = program['title'] as String? ?? '';
    _descriptionController.text = program['description'] as String? ?? '';
    _meetingLinkController.text = program['meetingLink'] as String? ?? '';
    _imageUrlController.text = program['imageUrl'] as String? ?? '';
    _categoryController.text = program['category'] as String? ?? '';
    _tagsController.text = program['tags'] as String? ?? '';

    final startTime = program['startTime'] as String?;
    final endTime = program['endTime'] as String?;
    _startDateTime = startTime != null && startTime.isNotEmpty ? DateTime.tryParse(startTime) : null;
    _endDateTime = endTime != null && endTime.isNotEmpty ? DateTime.tryParse(endTime) : null;
    _startTimeController.text = _startDateTime != null ? _formatDateTime(_startDateTime!) : '';
    _endTimeController.text = _endDateTime != null ? _formatDateTime(_endDateTime!) : '';

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackbar(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _meetingLinkController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return _titleController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        _meetingLinkController.text.trim().isNotEmpty &&
        _imageUrlController.text.trim().isNotEmpty &&
        _categoryController.text.trim().isNotEmpty &&
        _tagsController.text.trim().isNotEmpty &&
        _startDateTime != null &&
        _endDateTime != null &&
        !_endDateTime!.isBefore(_startDateTime!);
  }

  Future<void> _updateProgram() async {
    if (_programId == null) {
      _showErrorSnackbar('Unable to update program.');
      return;
    }

    if (!_isFormValid()) {
      _showErrorSnackbar('Please fill in all fields and select valid dates.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('programs').doc(_programId).update({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'meetingLink': _meetingLinkController.text.trim(),
        'imageUrl': _imageUrlController.text.trim(),
        'category': _categoryController.text.trim(),
        'tags': _tagsController.text.trim(),
        'startTime': _formatDateTime(_startDateTime!),
        'endTime': _formatDateTime(_endDateTime!),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Program updated successfully.')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showErrorSnackbar('Failed to update program. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _deleteProgram() async {
    if (_programId == null) {
      _showErrorSnackbar('Unable to delete program.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Program'),
          content: const Text('This program will be removed for all participants. Continue?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      final programRef = FirebaseFirestore.instance.collection('programs').doc(_programId);
      final programSnapshot = await programRef.get();
      final programData = programSnapshot.data() ?? {};
      final participantIds = (programData['participants'] as List<dynamic>?)?.cast<String>() ?? [];

      final batch = FirebaseFirestore.instance.batch();
      for (final userId in participantIds) {
        final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
        batch.update(userRef, {
          'programs': FieldValue.arrayRemove([_programId]),
        });
      }
      batch.delete(programRef);
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Program deleted successfully.')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showErrorSnackbar('Failed to delete program. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  String _formatDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Program'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Program Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Program Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _meetingLinkController,
                    decoration: const InputDecoration(
                      labelText: 'Meeting Link',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Image URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      labelText: 'Tags for better search',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _startTimeController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Start Date & Time',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                    onTap: () async {
                      final now = DateTime.now();
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _startDateTime ?? now,
                        firstDate: now,
                        lastDate: DateTime(now.year + 1),
                      );
                      if (pickedDate == null) return;
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: _startDateTime != null
                            ? TimeOfDay.fromDateTime(_startDateTime!)
                            : TimeOfDay(hour: now.hour, minute: now.minute),
                      );
                      if (pickedTime == null) return;
                      final dateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      setState(() {
                        _startDateTime = dateTime;
                        _startTimeController.text = _formatDateTime(dateTime);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _endTimeController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'End Date & Time',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                    onTap: () async {
                      final now = DateTime.now();
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _endDateTime ?? _startDateTime ?? now,
                        firstDate: _startDateTime ?? now,
                        lastDate: DateTime(now.year + 1),
                      );
                      if (pickedDate == null) return;
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: _endDateTime != null
                            ? TimeOfDay.fromDateTime(_endDateTime!)
                            : TimeOfDay(hour: now.hour, minute: now.minute),
                      );
                      if (pickedTime == null) return;
                      final dateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      setState(() {
                        _endDateTime = dateTime;
                        _endTimeController.text = _formatDateTime(dateTime);
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isSaving || _isDeleting ? null : _updateProgram,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Save Changes'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                    onPressed: _isSaving || _isDeleting ? null : _deleteProgram,
                    child: _isDeleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Delete Program'),
                  ),
                ],
              ),
            ),
    );
  }
}
