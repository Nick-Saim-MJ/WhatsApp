import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/message_request.dart';
import '../models/message_response.dart';
import '../models/api_response.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api'; // Para emulador Android
  // static const String baseUrl = 'http://localhost:8080/api'; // Para iOS Simulator
  // static const String baseUrl = 'https://your-backend-url.com/api'; // Para producción

  static Future<ApiResponse<MessageResponse>> sendTextMessage({
    required String phoneNumber,
    required String textMessage,
  }) async {
    try {
      final request = MessageRequest(
        phoneNumber: phoneNumber,
        textMessage: textMessage,
      );

      final response = await http.post(
        Uri.parse('$baseUrl/messages/send-text'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(MessageResponse.fromJson(data));
      } else {
        return ApiResponse.error('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      return ApiResponse.error('Error de conexión: $e');
    }
  }

  static Future<ApiResponse<MessageResponse>> sendMessageWithFile({
    required String phoneNumber,
    String? textMessage,
    required File file,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/messages/send-with-file'),
      );

      // Agregar campos
      request.fields['phoneNumber'] = phoneNumber;
      if (textMessage != null && textMessage.isNotEmpty) {
        request.fields['textMessage'] = textMessage;
      }

      // Agregar archivo
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(MessageResponse.fromJson(data));
      } else {
        return ApiResponse.error('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      return ApiResponse.error('Error enviando archivo: $e');
    }
  }

  static Future<ApiResponse<List<MessageResponse>>> getMessageHistory(String phoneNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages/history/$phoneNumber'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final messages = data.map((json) => MessageResponse.fromJson(json)).toList();
        return ApiResponse.success(messages);
      } else {
        return ApiResponse.error('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      return ApiResponse.error('Error obteniendo historial: $e');
    }
  }
}