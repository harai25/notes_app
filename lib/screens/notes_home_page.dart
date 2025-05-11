import 'package:flutter/material.dart';
import '../models/note.dart';
import '../models/folder.dart';
import '../utils/date.dart';
import 'note_editor_page.dart';
import 'package:intl/intl.dart';

class NotesHomePage extends StatefulWidget {
  const NotesHomePage({super.key});

  @override
  State<NotesHomePage> createState() => _NotesHomePageState();
}

class _NotesHomePageState extends State<NotesHomePage> {
  // Список заметок
  final List<Note> _notes = [];

  // Список папок
  List<Folder> _folders = [];

  // Текущая выбранная папка
  String _selectedFolder = 'Все';

  // Флаг для отображения всех папок
  bool _showAllFolders = false;

  @override
  void initState() {
    super.initState();
    _initFolders();
  }

  // Инициализация папок и подсчет заметок
  void _initFolders() {
    // Создаем множество для уникальных имен папок
    final Set<String> folderNames = {'Все'};

    // Добавляем имена папок из заметок
    for (var note in _notes) {
      folderNames.add(note.folder);
    }

    // Создаем список папок
    _folders =
        folderNames.map((name) {
          // Подсчитываем количество заметок в папке
          int count =
              name == 'Все'
                  ? _notes.length
                  : _notes.where((note) => note.folder == name).length;

          return Folder(name: name, noteCount: count);
        }).toList();
  }

  // Фильтрация заметок по выбранной папке
  List<Note> get _filteredNotes {
    if (_selectedFolder == 'Все') {
      return _notes;
    } else {
      return _notes.where((note) => note.folder == _selectedFolder).toList();
    }
  }

  // Форматирование даты
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final noteDate = DateTime(date.year, date.month, date.day);

    if (noteDate == today) {
      return DateFormat('HH:mm').format(date);
    } else {
      return '${date.day} ${getMonthName(date.month)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Секция с папками
            _buildFoldersSection(),

            // Список заметок
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _filteredNotes.length,
                itemBuilder: (context, index) {
                  final note = _filteredNotes[index];
                  return _buildNoteCard(note);
                },
              ),
            ),
          ],
        ),
      ),
      // Кнопка добавления заметки
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNoteEditor(context),
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Построение секции с папками
  Widget _buildFoldersSection() {
    // Определяем, нужно ли показывать стрелочку-плюс (если папок больше, чем помещается)
    final bool needExpandButton = _folders.length > 5;

    // Формируем список отображаемых папок
    final foldersToShow =
        _showAllFolders ? _folders : _folders.take(5).toList();

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    itemCount: foldersToShow.length,
                    itemBuilder: (context, index) {
                      final folder = foldersToShow[index];
                      return _buildFolderChip(folder);
                    },
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => _showAddFolderDialog(context),
                color: Colors.grey[600],
              ),
            ],
          ),
          // Показываем плюсик только если есть скрытые папки и мы ещё не в режиме просмотра всех
          if (!_showAllFolders && needExpandButton) _buildArrowButton(),
          // Если показываем все папки, отображаем их в сетке
          if (_showAllFolders) _buildExpandedFoldersGrid(),
        ],
      ),
    );
  }

  // Построение чипа папки
  Widget _buildFolderChip(Folder folder) {
    final isSelected = _selectedFolder == folder.name;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(
          '${folder.name} ${folder.noteCount > 0 ? folder.noteCount : ''}',
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.grey[300],
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedFolder = folder.name;
              _showAllFolders = false;
            });
          }
        },
      ),
    );
  }

  // Построение расширенной сетки папок
  Widget _buildExpandedFoldersGrid() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Все папки',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _showAllFolders = false;
                  });
                },
              ),
            ],
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _folders.length,
            itemBuilder: (context, index) {
              return _buildFolderChip(_folders[index]);
            },
          ),
        ],
      ),
    );
  }

  // Построение карточки заметки
  Widget _buildNoteCard(Note note) {
    return GestureDetector(
      onTap: () => _onNoteTap(note),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (note.content.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    note.content,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _formatDate(note.dateTime),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArrowButton() {
    return Center(
      child: IconButton(
        icon: const Icon(
          Icons.keyboard_arrow_down,
          size: 20,
          color: Colors.black,
        ),
        color: Colors.grey[600],
        onPressed: () {
          setState(() {
            _showAllFolders = true;
          });
        },
      ),
    );
  }

  // Открытие редактора заметок
  void _openNoteEditor(BuildContext context, {Note? note, String? folder}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => NoteEditorPage(
              onSave: (title, content, folder) {
                setState(() {
                  if (note != null) {
                    // Обновляем существующую заметку
                    final updatedNoteIndex = _notes.indexWhere(
                      (n) => n.id == note.id,
                    );
                    if (updatedNoteIndex != -1) {
                      _notes[updatedNoteIndex] = Note(
                        id: note.id,
                        title: title,
                        content: content,
                        dateTime: DateTime.now(),
                        folder: folder,
                      );
                    }
                  } else {
                    // Создаем новую заметку
                    final newNote = Note(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: title,
                      content: content,
                      dateTime: DateTime.now(),
                      folder: folder,
                    );

                    _notes.insert(0, newNote);
                  }
                  _initFolders(); // Обновляем список папок
                });
              },
              note: note,
              folder: folder ?? _selectedFolder,
            ),
      ),
    );
  }

  // Обработчик нажатия на заметку
  void _onNoteTap(Note note) {
    _openNoteEditor(context, note: note);
  }

  // New state variable for folder name input
  String _newFolderName = '';

  // Widget for adding new folder via popup dialog
  void _showAddFolderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Создать новую папку'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Введите название папки',
            ),
            onChanged: (value) {
              _newFolderName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                if (_newFolderName.isNotEmpty &&
                    !_folders.any((f) => f.name == _newFolderName)) {
                  setState(() {
                    _folders.add(Folder(name: _newFolderName, noteCount: 0));
                    _selectedFolder = _newFolderName;
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }
}
