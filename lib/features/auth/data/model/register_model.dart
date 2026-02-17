import 'package:ntodo/features/auth/domain/entities/register_entity.dart';

class RegisterModel extends RegisterEntity {
  const RegisterModel({super.message});

  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(message: json["message"]?.toString());
  }
}
