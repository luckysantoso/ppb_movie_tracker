class Director {
  int? id;
  final String name;
  final String bio;
  final String photo;

  Director({
    this.id,
    required this.name,
    required this.bio,
    required this.photo,
  });

  factory Director.fromMap(Map<String, dynamic> map) {
    return Director(
      id: map['id'],
      name: map['name'],
      bio: map['bio'],
      photo: map['photo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'photo': photo,
    };
  }
}
