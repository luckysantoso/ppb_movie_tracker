import 'package:flutter/material.dart';
import '../models/director.dart';
import '../database/database_helper.dart';
import 'director_form.dart';
import 'dart:io';

class DirectorListScreen extends StatefulWidget {
  @override
  _DirectorListScreenState createState() => _DirectorListScreenState();
}

class _DirectorListScreenState extends State<DirectorListScreen> {
  final db = DatabaseHelper();
  List<Director> directors = [];

  Future<void> loadDirectors() async {
    final data = await db.getAllDirectors();
    setState(() => directors = data);
  }

  @override
  void initState() {
    super.initState();
    loadDirectors();
  }

  Future<void> confirmDelete(Director d) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Delete Director'),
            content: Text("Are you sure you want to delete '${d.name}'?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await db.deleteDirector(d.id!);
      loadDirectors();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Directors")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child:
            directors.isEmpty
                ? Center(child: Text('No directors found.'))
                : ListView.separated(
                  itemCount: directors.length,
                  separatorBuilder: (_, __) => Divider(),
                  itemBuilder: (context, index) {
                    final d = directors[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => DirectorForm(
                                  onSaved: loadDirectors,
                                  director: d,
                                ),
                          ),
                        );
                      },
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        leading: CircleAvatar(
                          backgroundImage: FileImage(File(d.photo)),
                          radius: 28,
                        ),
                        title: Text(
                          d.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          d.bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => confirmDelete(d),
                        ),
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DirectorForm(onSaved: loadDirectors),
            ),
          );
        },
        child: Icon(Icons.person_add),
      ),
    );
  }
}
