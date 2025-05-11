import 'package:flutter/material.dart';
import '../models/note.dart';

class NoteEditorPage extends StatefulWidget {
  final Function(String, String, String) onSave;
  final Note? note;
  final String folder;

  const NoteEditorPage({super.key, required this.onSave, this.note, required this.folder});

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Заголовок',
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Содержание',
                ),
                maxLines: null,
                expands: true,
                keyboardType: TextInputType.multiline,
              ),
            ),
            const SizedBox(height: 16.0),
            // DropdownButtonFormField<String>(
            //   value: _selectedFolder,
            //   onChanged: (String? newValue) {
            //     setState(() {
            //       _selectedFolder = newValue!;
            //     });
            //   },
            //   items: <String>['Все', 'Апрель', 'Август']
            //       .map<DropdownMenuItem<String>>((String value) {
            //     return DropdownMenuItem<String>(
            //       value: value,
            //       child: Text(value),
            //     );
            //   }).toList(),
            //   decoration: const InputDecoration(
            //     labelText: 'Папка',
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
