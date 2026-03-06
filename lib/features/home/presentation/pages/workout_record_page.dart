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
    final words = body.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return 'Untitled Note';
    return words.take(4).join(' ');
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

class _WorkoutRecordScreenState extends State<WorkoutRecordScreen>
    with SingleTickerProviderStateMixin {
  List<WorkoutNote> _notes = [];
  WorkoutNote? _currentNote;
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _drawerOpen = false;

  late final AnimationController _animController;
  late final Animation<double> _slideAnim;
  late final Animation<double> _fadeAnim;

  static const double _drawerWidth = 280;
  String _notesStorageKey = 'workout_notes_guest';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnim = Tween<double>(begin: -_drawerWidth, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(_animController);
    _initializeStorageAndLoadNotes();
  }

  Future<void> _initializeStorageAndLoadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final email = prefs.getString('email');
    final ownerKey = (userId != null && userId.isNotEmpty)
        ? userId
        : ((email != null && email.isNotEmpty) ? email : 'guest');

    _notesStorageKey = 'workout_notes_$ownerKey';
    await _loadNotes();
  }

  @override
  void dispose() {
    _animController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  // ── Drawer toggle ─────────────────────────────────────────────────
  void _toggleDrawer() {
    if (_drawerOpen) {
      _animController.reverse().then((_) {
        setState(() => _drawerOpen = false);
      });
    } else {
      setState(() => _drawerOpen = true);
      _animController.forward();
    }
  }

  void _closeDrawer() {
    if (_drawerOpen) {
      _animController.reverse().then((_) {
        setState(() => _drawerOpen = false);
      });
    }
  }

  // ── Persistence ───────────────────────────────────────────────────
  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = prefs.getStringList(_notesStorageKey) ?? [];
    setState(() {
      _notes = notesJson
          .map((j) => WorkoutNote.fromJson(jsonDecode(j)))
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    });
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _notesStorageKey,
      _notes.map((n) => jsonEncode(n.toJson())).toList(),
    );
  }

  // ── CRUD ──────────────────────────────────────────────────────────
  void _createNewNote() {
    final note = WorkoutNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '',
      body: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _notes.insert(0, note);
    _openNote(note);
    _saveNotes();
    _closeDrawer();
  }

  void _openNote(WorkoutNote note) {
    setState(() {
      _currentNote = note;
      _titleController.text = note.title;
      _bodyController.text = note.body;
    });
    _closeDrawer();
  }

  void _deleteNote(WorkoutNote note) {
    setState(() {
      _notes.remove(note);
      if (_currentNote?.id == note.id) {
        _currentNote = null;
        _titleController.clear();
        _bodyController.clear();
      }
    });
    _saveNotes();
  }

  void _autoSave() {
    if (_currentNote == null) return;
    _currentNote!.title = _titleController.text;
    _currentNote!.body = _bodyController.text;
    _currentNote!.updatedAt = DateTime.now();
    _saveNotes();
  }

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Main content (always visible) ──
            Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: _currentNote != null
                      ? _buildEditor()
                      : _buildEmptyState(),
                ),
              ],
            ),

            // ── Scrim (fades in when drawer opens) ──
            if (_drawerOpen)
              AnimatedBuilder(
                animation: _fadeAnim,
                builder: (_, __) => GestureDetector(
                  onTap: _closeDrawer,
                  child: Container(
                    color: Colors.black.withValues(alpha: _fadeAnim.value * 0.45),
                  ),
                ),
              ),

            // ── Sliding drawer ──
            if (_drawerOpen)
              AnimatedBuilder(
                animation: _slideAnim,
                builder: (_, child) => Transform.translate(
                  offset: Offset(_slideAnim.value, 0),
                  child: child,
                ),
                child: _buildDrawer(),
              ),
          ],
        ),
      ),
    );
  }

  // ── Top bar with hamburger / back ─────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade800, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Hamburger / drawer toggle
          IconButton(
            icon: const Icon(Icons.menu, size: 24),
            onPressed: _toggleDrawer,
            tooltip: 'Notes list',
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              _currentNote != null
                  ? _currentNote!.displayTitle
                  : 'Workout Records',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Back to home
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back to Home',
          ),
        ],
      ),
    );
  }

  // ── Drawer (notes list) ───────────────────────────────────────────
  Widget _buildDrawer() {
    return Container(
      width: _drawerWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drawer header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'My Notes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.note_add, size: 22),
                  onPressed: _createNewNote,
                  tooltip: 'New Note',
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 22),
                  onPressed: _closeDrawer,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // New Note button
          InkWell(
            onTap: _createNewNote,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'New Note',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Notes list
          Expanded(
            child: _notes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.note_alt_outlined,
                            size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'No notes yet',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _notes.length,
                    itemBuilder: (_, i) {
                      final note = _notes[i];
                      final isActive = _currentNote?.id == note.id;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary.withValues(alpha: 0.12)
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            dense: true,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.only(
                                left: 14, right: 4, top: 2, bottom: 2),
                            title: Text(
                              note.displayTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Text(
                              note.body.isEmpty
                                  ? 'Empty note'
                                  : note.body.split('\n').first,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline,
                                  size: 18, color: Colors.red.shade300),
                              onPressed: () => _deleteNote(note),
                              tooltip: 'Delete',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                  minWidth: 32, minHeight: 32),
                            ),
                            onTap: () => _openNote(note),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── Editor (full-screen) ──────────────────────────────────────────
  Widget _buildEditor() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Title field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Note Title',
                hintStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              onChanged: (_) => _autoSave(),
            ),
          ),

          const SizedBox(height: 14),

          // Body field (takes all remaining space)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _bodyController,
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText:
                      'Start writing your notes...',
                  hintStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontStyle: FontStyle.italic,
                    color: const Color.fromARGB(255, 145, 148, 126),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                ),
                style: const TextStyle(fontFamily: 'Montserrat', height: 1.6),
                onChanged: (_) => _autoSave(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.note_alt_outlined, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            'Tap the menu to view your notes\nor create a new one',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 15),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewNote,
            icon: const Icon(Icons.add),
            label: const Text('New Note'),
          ),
        ],
      ),
    );
  }
}
