import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/director.dart';
import '../database/database_helper.dart';

class DirectorForm extends StatefulWidget {
  final VoidCallback onSaved;
  final Director? director;

  DirectorForm({required this.onSaved, this.director}); // director optional

  @override
  _DirectorFormState createState() => _DirectorFormState();
}

class _DirectorFormState extends State<DirectorForm> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String bio;
  late String photoPath;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize fields with existing director data if available
    name = widget.director?.name ?? '';
    bio = widget.director?.bio ?? '';
    photoPath = widget.director?.photo ?? '';
  }

  void saveDirector() async {
    if (_formKey.currentState!.validate() && photoPath.isNotEmpty) {
      _formKey.currentState!.save();
      final director = Director(name: name, bio: bio, photo: photoPath);

      if (widget.director == null) {
        // Insert new director
        await DatabaseHelper().insertDirector(director);
      } else {
        // Update existing director
        director.id = widget.director!.id;
        await DatabaseHelper().updateDirector(director);
      }

      widget.onSaved();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Lengkapi data dan pilih foto")));
    }
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => photoPath = picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.director == null ? "Add Director" : "Edit Director")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: photoPath.isEmpty
                    ? Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: Icon(Icons.person, size: 100),
                      )
                    : Image.file(File(photoPath), height: 150),
              ),
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: 'Name'),
                onSaved: (val) => name = val!,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                initialValue: bio,
                decoration: InputDecoration(labelText: 'Bio'),
                onSaved: (val) => bio = val!,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: saveDirector,
                child: Text(widget.director == null ? "Save Director" : "Update Director"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
