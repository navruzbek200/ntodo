import 'package:ntodo/features/todo/domain/entities/update_entity.dart';


class UpdateModel extends UpdateEntity {
  const UpdateModel({required super.title, required super.completed});

  factory UpdateModel.fromJson(Map<String, dynamic> json) {
    return UpdateModel(
      title: json['title']?.toString() ?? '',
      completed: json['completed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'completed': completed};
  }
}
