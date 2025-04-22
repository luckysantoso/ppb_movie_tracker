import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/movie.dart';
import '../models/director.dart';
import '../database/database_helper.dart';

class MovieForm extends StatefulWidget {
  final VoidCallback onSaved;
  final Movie? movie;

  MovieForm({required this.onSaved, this.movie});

  @override
  _MovieFormState createState() => _MovieFormState();
}

class _MovieFormState extends State<MovieForm> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String genre;
  late double rating;
  late String posterPath;
  late String synopsis;
  int? directorId;

  final picker = ImagePicker();
  final db = DatabaseHelper();
  List<Director> directors = [];

  @override
  void initState() {
    super.initState();
    title = widget.movie?.title ?? '';
    genre = widget.movie?.genre ?? '';
    rating = widget.movie?.rating ?? 0.0;
    posterPath = widget.movie?.poster ?? '';
    directorId = widget.movie?.directorId;
    synopsis = widget.movie?.synopsis ?? '';
    loadDirectors();
  }

  Future<void> loadDirectors() async {
    final data = await db.getAllDirectors();
    setState(() => directors = data);
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => posterPath = picked.path);
    }
  }

  void saveMovie() async {
    if (_formKey.currentState!.validate() &&
        posterPath.isNotEmpty &&
        directorId != null) {
      _formKey.currentState!.save();
      final movie = Movie(
        id: widget.movie?.id,
        title: title,
        genre: genre,
        rating: rating,
        poster: posterPath,
        directorId: directorId!,
        synopsis: synopsis,
      );

      if (widget.movie == null) {
        await db.insertMovie(movie);
      } else {
        await db.updateMovie(movie);
      }

      widget.onSaved();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lengkapi semua data dan pilih gambar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie == null ? "Add Movie" : "Edit Movie"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child:
                    posterPath.isEmpty
                        ? Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: Icon(Icons.image, size: 100),
                        )
                        : Image.file(File(posterPath), height: 200),
              ),
              TextFormField(
                initialValue: title,
                decoration: InputDecoration(labelText: 'Title'),
                onSaved: (val) => title = val!,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                initialValue: genre,
                decoration: InputDecoration(labelText: 'Genre'),
                onSaved: (val) => genre = val!,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                initialValue: rating.toString(),
                decoration: InputDecoration(labelText: 'Rating (0 - 10)'),
                keyboardType: TextInputType.number,
                onSaved: (val) => rating = double.tryParse(val!) ?? 0.0,
                validator:
                    (val) =>
                        val == null || double.tryParse(val) == null
                            ? 'Invalid'
                            : null,
              ),
              TextFormField(
                initialValue: synopsis,
                decoration: InputDecoration(labelText: 'Synopsis'),
                maxLines: 5,
                onSaved: (val) => synopsis = val!,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              DropdownButtonFormField<int>(
                value: directorId,
                decoration: InputDecoration(labelText: 'Director'),
                items:
                    directors
                        .map(
                          (d) => DropdownMenuItem(
                            child: Text(d.name),
                            value: d.id,
                          ),
                        )
                        .toList(),
                onChanged: (val) => setState(() => directorId = val),
                validator: (val) => val == null ? 'Choose director' : null,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: saveMovie,
                child: Text(
                  widget.movie == null ? 'Save Movie' : 'Update Movie',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
