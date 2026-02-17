import 'package:ntodo/features/todo/domain/entities/create_entity.dart';


class CreateModel extends CreateEntity {
  const CreateModel({required super.title});

  factory CreateModel.fromJson(Map<String, dynamic> json) {
    return CreateModel(title: json['title'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'title': title};
  }
}
