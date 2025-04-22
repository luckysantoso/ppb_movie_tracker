class Movie {
  final int? id;
  final String title;
  final String genre;
  final double rating;
  final String poster;
  final int directorId;
  final String synopsis;

  Movie({
    this.id,
    required this.title,
    required this.genre,
    required this.rating,
    required this.poster,
    required this.directorId,
    required this.synopsis,
  });

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'],
      title: map['title'],
      genre: map['genre'],
      rating: map['rating'],
      poster: map['poster'],
      directorId: map['director_id'],
      synopsis: map['synopsis'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'genre': genre,
      'rating': rating,
      'poster': poster,
      'director_id': directorId,
      'synopsis': synopsis,
    };
  }
}
