import 'package:dio/dio.dart';

/// Turns any error from the data layer into a user-facing (Uzbek) message.
///
/// [byStatus] lets a caller give a context-specific text for a status code,
/// e.g. 401 on login means "wrong password", not "session expired".
String apiErrorMessage(Object error, {Map<int, String> byStatus = const {}}) {
  if (error is! DioException) return "Noma’lum xato yuz berdi.";

  switch (error.type) {
    case DioExceptionType.connectionError:
      return "Internet ulanmagan. Iltimos, tarmoqni tekshiring.";
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return "Server javob bermadi. Keyinroq urinib ko‘ring.";
    case DioExceptionType.cancel:
      return "So‘rov bekor qilindi.";
    default:
      break;
  }

  final code = error.response?.statusCode;
  if (code == null) return "Serverga ulanib bo‘lmadi.";
  if (byStatus.containsKey(code)) return byStatus[code]!;

  if (code == 400) return "Kiritilgan ma’lumotlar noto‘g‘ri.";
  if (code == 401) return "Sessiya tugadi. Qayta kiring.";
  if (code == 403) return "Bu amal uchun ruxsat yo‘q.";
  if (code == 404) return "Ma’lumot topilmadi.";
  if (code >= 500) return "Serverda nosozlik. Keyinroq urinib ko‘ring.";
  return "Noma’lum xato ($code). Qayta urinib ko‘ring.";
}
