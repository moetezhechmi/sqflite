import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DataBaseHelper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SQLite Notes Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DataBaseHelper dbHelper = DataBaseHelper();
  List<Map<String, dynamic>> notes = [];
  String userName = "";

  @override
  void initState() {
    super.initState();
    loadNotes();
    loadUserName();
  }

  // Charger le nom de l'utilisateur depuis SharedPreferences
  Future<void> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('username') ?? 'Utilisateur';
    });
  }

  Future<void> changeUserName() async {
    TextEditingController controller = TextEditingController(text: userName);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Modifier le nom"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('username', controller.text);
                setState(() {
                  userName = controller.text;
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  Future<void> loadNotes() async {
    final data = await dbHelper.getNotes();
    setState(() {
      notes = data;
    });
  }

  Future<void> addNoteDialog() async {
    TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nouvelle note"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Écrire une note"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await dbHelper.insertNote(controller.text);
                await loadNotes();
              }
              Navigator.pop(context);
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  Future<void> deleteNote(int id) async {
    await dbHelper.deleteNote(id);
    await loadNotes();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bonjour, $userName 👋'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: changeUserName,
          ),
        ],
      ),

      body: notes.isEmpty
          ? const Center(child: Text("Aucune note pour l'instant"))
          : ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(note['name']),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteNote(note['id']),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNoteDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
