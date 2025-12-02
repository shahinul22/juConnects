import 'package:flutter/material.dart';
import '../../../models/club_event_model.dart';
import '../../../service/club_service.dart';

class EventCreateScreen extends StatefulWidget {
  final String clubId;

  const EventCreateScreen({required this.clubId, super.key});

  @override
  State<EventCreateScreen> createState() => _EventCreateScreenState();
}

class _EventCreateScreenState extends State<EventCreateScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _participantController = TextEditingController();

  DateTime? _eventDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  bool registrationRequired = false;
  List<String> formFields = [];

  final _clubService = ClubService();
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _participantController.dispose();
    super.dispose();
  }

  Future<void> pickEventDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) setState(() => _eventDate = date);
  }

  Future<void> pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void addFormFieldDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Registration Field"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Field Name",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() => formFields.add(controller.text.trim()));
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  Future<void> createEvent() async {
    if (_titleController.text.trim().isEmpty ||
        _eventDate == null ||
        _startTime == null ||
        _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all required fields")),
      );
      return;
    }

    final start = DateTime(
      _eventDate!.year,
      _eventDate!.month,
      _eventDate!.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final end = DateTime(
      _eventDate!.year,
      _eventDate!.month,
      _eventDate!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    if (!end.isAfter(start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("End time must be after start time")),
      );
      return;
    }

    setState(() => _loading = true);

    final event = ClubEvent(
      id: "",
      title: _titleController.text.trim(),
      description:
      _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      location:
      _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      date: _eventDate!,
      startTime: start,
      endTime: end,
      participantLimit: _participantController.text.trim().isEmpty
          ? null
          : int.tryParse(_participantController.text.trim()),
      registrationRequired: registrationRequired,
      registrationForm: registrationRequired
          ? {
        "fields": formFields,
      }
          : null,
    );

    try {
      await _clubService.createEvent(
        clubId: widget.clubId,
        event: event,
      );

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event Created Successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Event")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            textField(_titleController, "Event Title", Icons.title),

            const SizedBox(height: 16),
            textField(_descController, "Description", Icons.description, maxLines: 3),

            const SizedBox(height: 16),
            textField(_locationController, "Location", Icons.location_on),

            const SizedBox(height: 16),
            textField(_participantController, "Participant Limit (optional)", Icons.group),

            const SizedBox(height: 20),
            buildDatePicker(),
            const SizedBox(height: 16),
            buildTimePickers(),

            const SizedBox(height: 20),
            buildRegistrationSection(),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : createEvent,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Create Event"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- UI HELPERS ----------------

  Widget textField(TextEditingController c, String label, IconData icon,
      {int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget buildDatePicker() {
    return OutlinedButton(
      onPressed: pickEventDate,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Event Date"),
          Text(_eventDate == null
              ? "Select"
              : "${_eventDate!.day}/${_eventDate!.month}/${_eventDate!.year}"),
        ],
      ),
    );
  }

  Widget buildTimePickers() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => pickTime(true),
            child: Text(_startTime == null
                ? "Start Time"
                : _startTime!.format(context)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () => pickTime(false),
            child: Text(_endTime == null
                ? "End Time"
                : _endTime!.format(context)),
          ),
        ),
      ],
    );
  }

  Widget buildRegistrationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text("Require Registration?"),
          value: registrationRequired,
          onChanged: (v) => setState(() => registrationRequired = v),
        ),
        if (registrationRequired)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Registration Fields:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...formFields.map((f) => ListTile(
                title: Text(f),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() => formFields.remove(f));
                  },
                ),
              )),
              OutlinedButton.icon(
                onPressed: addFormFieldDialog,
                icon: const Icon(Icons.add),
                label: const Text("Add Field"),
              ),
            ],
          )
      ],
    );
  }
}
