import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _editController = TextEditingController();
  late List<String> list = [];

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        backgroundColor: Colors.yellow,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Write your note here',
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (_) => addInformationToList(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: addInformationToList,
              child: const Text('Add'),
            ),
            const SizedBox(height: 10),
            dataUi(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    _editController.dispose();
    super.dispose();
  }

  Widget dataUi() {
    return Expanded(
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(list[index]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // EDIT
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditDialog(index),
                ),
                // DELETE
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      list.removeAt(index);
                    });
                    saveNotes();
                  },
                ),
              ],
            ),
            onTap: () => _showEditDialog(index),
          );
        },
      ),
    );
  }

  void addInformationToList() {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      list.add(text);
    });
    saveNotes();
    _noteController.clear();
  }

  Future<void> _showEditDialog(int index) async {
    _editController.text = list[index];
    final newText = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Note'),
          content: TextField(
            controller: _editController,
            decoration: const InputDecoration(
              hintText: 'Update note',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, _editController.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (newText != null && newText.isNotEmpty) {
      setState(() {
        list[index] = newText;
      });
      saveNotes();
    }
  }

  Future<void> saveNotes() async {
    final ob = await SharedPreferences.getInstance();
    await ob.setStringList('notes', list);
  }

  Future<void> loadNotes() async {
    final ob = await SharedPreferences.getInstance();
    final savedNotes = ob.getStringList('notes');
    if (savedNotes != null) {
      setState(() {
        list = savedNotes;
      });
    }
  }
}