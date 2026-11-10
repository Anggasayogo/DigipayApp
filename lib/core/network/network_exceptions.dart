import 'package:dio/dio.dart';

class NetworkExceptions {
  static String getErrorMessage(DioException e, {String fallbackMessage = 'Terjadi kesalahan pada sistem'}) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Koneksi gagal. Aplikasi DigiPay membutuhkan koneksi internet online.';
    }

    final responseData = e.response?.data;
    if (responseData is Map<String, dynamic> && responseData['message'] != null) {
      return responseData['message'].toString();
    }

    return e.message ?? fallbackMessage;
  }
}
