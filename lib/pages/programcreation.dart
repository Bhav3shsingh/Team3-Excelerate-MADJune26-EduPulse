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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Program Title",border: OutlineInputBorder()),
            ),
            TextField(
              maxLength: null,
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Program Description",border: OutlineInputBorder()),
            ),
            TextField(
              controller: _meetingLinkController,
              decoration: const InputDecoration(labelText: "Meeting Link",border: OutlineInputBorder()),
            ),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: "Image URL",border: OutlineInputBorder()),
            ),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: "Category",border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 12),
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
            //TODO textfield to take tags as input and store it in firestore as a list of strings
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(labelText: "Tags for better search",border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                if (_startDateTime == null || _endDateTime == null) {
                  _showErrorSnackbar("Please select both start and end date & time.");
                  return;
                }
                else if (_endDateTime!.isBefore(_startDateTime!)) {
                  _showErrorSnackbar("End date & time cannot be before start date & time.");
                  return;
                }
                else if (_startDateTime!.isBefore(DateTime.now())) {
                  _showErrorSnackbar("Start date & time cannot be in the past.");
                  return;
                }
                else if (_endDateTime!.isBefore(DateTime.now())) {
                  _showErrorSnackbar("End date & time cannot be in the past.");
                  return;
                }
                else if (_titleController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty || _meetingLinkController.text.trim().isEmpty || _imageUrlController.text.trim().isEmpty || _categoryController.text.trim().isEmpty || _tagsController.text.trim().isEmpty) {
                  _showErrorSnackbar("Please fill in all fields.");
                  return;
                }
                else if (!_meetingLinkController.text.trim().startsWith("http")) {
                  _showErrorSnackbar("Please enter a valid meeting link.");
                  return;
                }
                else if (!_imageUrlController.text.trim().startsWith("http")) {
                  _showErrorSnackbar("Please enter a valid image URL.");
                  return;
                }
                else {
                  await _createProgram();
                }
                
              },
              child: const Text("Create Program"),
            ),
          ],
        )
      )
    );
  }

  String _formatDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }
}