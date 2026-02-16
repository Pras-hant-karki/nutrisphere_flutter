import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutrisphere_flutter/app/theme/app_colors.dart';

class WorkoutNote {
  final String id;
  String title;
  String body;
  final DateTime createdAt;
  DateTime updatedAt;

  WorkoutNote({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayTitle {
    if (title.trim().isNotEmpty) return title;
    // Get first 4 words from body
    final words = body.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return 'Untitled Note';
    final firstFourWords = words.take(4).join(' ');
    return firstFourWords.length > 30 ? '${firstFourWords.substring(0, 30)}...' : firstFourWords;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory WorkoutNote.fromJson(Map<String, dynamic> json) => WorkoutNote(
    id: json['id'],
    title: json['title'],
    body: json['body'],
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );
}

class WorkoutRecordScreen extends StatefulWidget {
  const WorkoutRecordScreen({super.key});

  @override
  State<WorkoutRecordScreen> createState() => _WorkoutRecordScreenState();
}

class _WorkoutRecordScreenState extends State<WorkoutRecordScreen> {
  List<WorkoutNote> _notes = [];
  WorkoutNote? _currentNote;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList('workout_notes') ?? [];
    setState(() {
      _notes = notesJson.map((json) => WorkoutNote.fromJson(jsonDecode(json))).toList();
      _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt)); // Most recent first
    });
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = _notes.map((note) => jsonEncode(note.toJson())).toList();
    await prefs.setStringList('workout_notes', notesJson);
  }

  void _createNewNote() {
    final newNote = WorkoutNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '',
      body: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    setState(() {
      _notes.insert(0, newNote);
      _currentNote = newNote;
      _titleController.text = newNote.title;
      _bodyController.text = newNote.body;
      _isEditing = true;
    });
    _saveNotes();
  }

  void _selectNote(WorkoutNote note) {
    setState(() {
      _currentNote = note;
      _titleController.text = note.title;
      _bodyController.text = note.body;
      _isEditing = true;
    });
  }

  void _deleteNote(WorkoutNote note) {
    setState(() {
      _notes.remove(note);
      if (_currentNote == note) {
        _currentNote = null;
        _titleController.clear();
        _bodyController.clear();
        _isEditing = false;
      }
    });
    _saveNotes();
  }

  void _autoSave() {
    if (_currentNote != null) {
      _currentNote!.title = _titleController.text;
      _currentNote!.body = _bodyController.text;
      _currentNote!.updatedAt = DateTime.now();
      _saveNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Row(
          children: [
            // Notes List Sidebar
            Container(
              width: 280,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                border: Border(
                  right: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              child: Column(
                children: [
                  // Header with New Note Button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text(
                          "Workout Notes",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _createNewNote,
                          tooltip: 'New Note',
                        ),
                      ],
                    ),
                  ),

                  // Notes List
                  Expanded(
                    child: _notes.isEmpty
                        ? const Center(
                            child: Text(
                              'No notes yet\nTap + to create one',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _notes.length,
                            itemBuilder: (context, index) {
                              final note = _notes[index];
                              final isSelected = _currentNote?.id == note.id;
                              return ListTile(
                                selected: isSelected,
                                selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
                                title: Text(
                                  note.displayTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Text(
                                  '${note.body.split('\n').first}...',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, size: 18),
                                  onPressed: () => _deleteNote(note),
                                  tooltip: 'Delete Note',
                                ),
                                onTap: () => _selectNote(note),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),

            // Editor Area
            Expanded(
              child: _isEditing && _currentNote != null
                  ? Column(
                      children: [
                        // Title Field
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                            ),
                          ),
                          child: TextField(
                            controller: _titleController,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Note Title',
                              hintStyle: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                            onChanged: (_) => _autoSave(),
                          ),
                        ),

                        // Body Field
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.white,
                            child: TextField(
                              controller: _bodyController,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              textAlign: TextAlign.left,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Start writing your workout notes...\n\nExample:\nWeek-1\nFriday:\n1. Leg Press - 200kg 4x12\n2. Hack Squat - 60kg 4x12\n3. Romanian Deadlift - 60kg 4x12',
                                hintStyle: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.textMuted,
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                height: 1.5,
                              ),
                              onChanged: (_) => _autoSave(),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.note_alt_outlined,
                            size: 64,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Select a note to edit or create a new one',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
