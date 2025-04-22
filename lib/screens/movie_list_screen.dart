import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';
import 'movie_form.dart';

class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final db = DatabaseHelper();
  List<Movie> movies = [];
  bool isLoading = true;

  Future<void> loadMovies() async {
    setState(() {
      isLoading = true;
    });

    final data = await db.getAllMovies();

    setState(() {
      movies = data;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Movie Collection"), elevation: 0),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : movies.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.movie_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      "No movies added yet",
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Tap + to add your first movie",
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  return MovieCard(movie: movies[index], onRefresh: loadMovies);
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MovieForm(onSaved: loadMovies)),
          );
        },
        child: Icon(Icons.add),
        tooltip: "Add Movie",
      ),
    );
  }
}
