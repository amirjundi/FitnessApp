class Exercise {
  final int? id;
  final int trainerId;
  final String name;
  final String muscleGroup;
  final String? description;
  final String? youtubeUrl;
  final String? thumbnailPath;

  Exercise({
    this.id,
    required this.trainerId,
    required this.name,
    required this.muscleGroup,
    this.description,
    this.youtubeUrl,
    this.thumbnailPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trainer_id': trainerId,
      'name': name,
      'muscle_group': muscleGroup,
      'description': description,
      'youtube_url': youtubeUrl,
      'thumbnail_path': thumbnailPath,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      trainerId: map['trainer_id'],
      name: map['name'],
      muscleGroup: map['muscle_group'],
      description: map['description'],
      youtubeUrl: map['youtube_url'],
      thumbnailPath: map['thumbnail_path'],
    );
  }

  Exercise copyWith({
    int? id,
    int? trainerId,
    String? name,
    String? muscleGroup,
    String? description,
    String? youtubeUrl,
    String? thumbnailPath,
  }) {
    return Exercise(
      id: id ?? this.id,
      trainerId: trainerId ?? this.trainerId,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      description: description ?? this.description,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }
}
