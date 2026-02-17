class GetEntity {
  final int id;
  final int userId;
  final String title;
  final bool completed;

  const GetEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
  });

  GetEntity copyWith({
    int? id,
    int? userId,
    String? title,
    bool? completed,
  }) {
    return GetEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }
}
