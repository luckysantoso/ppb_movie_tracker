import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'dart:io';
import '../screens/movie_form.dart';
import '../database/database_helper.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onRefresh;

  MovieCard({required this.movie, required this.onRefresh});

  Future<String?> fetchDirectorName(int id) async =>
      (await DatabaseHelper().getDirectorById(id))?.name ?? "Unknown";

  void showMovieDetails(BuildContext context, String directorName) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(movie.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.file(File(movie.poster), height: 200),
                SizedBox(height: 12),
                Text("Genre: ${movie.genre}"),
                Text("Rating: ${movie.rating}"),
                Text("Director: $directorName"),
                SizedBox(height: 12),
                Text(
                  "Synopsis:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(movie.synopsis),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: fetchDirectorName(movie.directorId),
      builder: (context, snapshot) {
        final directorName = snapshot.data ?? "Loading...";
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          child: InkWell(
            onTap: () {
              if (snapshot.connectionState == ConnectionState.done) {
                showMovieDetails(context, directorName);
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Image.file(
                      File(movie.poster),
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: _buildBadge(
                        Icons.star,
                        "${movie.rating}",
                        Colors.amber,
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: _buildGenreBadge(movie.genre),
                    ),
                    Positioned(
                      bottom: 60,
                      right: 16,
                      child: Row(
                        children: [
                          _buildIconButton(
                            icon: Icons.edit,
                            color: Colors.blue,
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => MovieForm(
                                        onSaved: onRefresh,
                                        movie: movie,
                                      ),
                                ),
                              );
                            },
                          ),
                          SizedBox(width: 12),
                          _buildIconButton(
                            icon: Icons.delete,
                            color: Colors.red,
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (_) => AlertDialog(
                                      title: Text("Confirm Delete"),
                                      content: Text("Delete '${movie.title}'?"),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          child: Text("Delete"),
                                        ),
                                      ],
                                    ),
                              );
                              if (confirm == true) {
                                await DatabaseHelper().deleteMovie(movie.id!);
                                onRefresh();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: Colors.white70,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                directorName,
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Synopsis",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        movie.synopsis,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          SizedBox(width: 4),
          Text(text, style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildGenreBadge(String genre) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(genre, style: TextStyle(color: Colors.white)),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return CircleAvatar(
      backgroundColor: Colors.white.withAlpha((0.8 * 255).toInt()),
      radius: 20,
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}
