import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';

class NoteEditorPage extends StatefulWidget {
  final Function(String, String, String) onSave;
  final Note? note;
  final String folder;

  const NoteEditorPage({
    super.key,
    required this.onSave,
    this.note,
    required this.folder,
  });

  @override
  _NoteEditorPageState createState() => _NoteEditorPageState();
}

// ignore_for_file: library_private_types_in_public_api
class _NoteEditorPageState extends State<NoteEditorPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  late String _selectedFolder;

  @override
  void initState() {
    super.initState();
    _selectedFolder = widget.folder;
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _selectedFolder = widget.note!.folder;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить заметку'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              widget.onSave(
                _titleController.text,
                _contentController.text,
                _selectedFolder,
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${DateFormat('dd MMMM HH:mm').format(DateTime.now())} | 42 символов',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Заголовок',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: 'Начните ввод',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              style: const TextStyle(fontSize: 16),
              maxLines: null,
              minLines: 5,
              keyboardType: TextInputType.multiline,
            ),
          ],
        ),
      ),
    );
  }
}
