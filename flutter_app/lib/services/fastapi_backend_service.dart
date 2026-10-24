import 'dart:convert';
import 'package:http/http.dart' as http;

class FastAPIBackendService {
  final String baseUrl;

  FastAPIBackendService({this.baseUrl = 'http://10.0.2.2:8000'});

  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      // Fallback response if backend offline
    }
    return {'status': 'offline', 'message': 'Connecting to FastAPI backend...'};
  }

  Future<String> sendChatToBackend(String message, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message, 'user_id': userId}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] ?? 'Hello Gowrob!';
      }
    } catch (e) {
      // Return error
    }
    return 'Backend offline. Communicating via direct Gemini client.';
  }

  Future<Map<String, dynamic>> sendVisionFrame(String base64Image) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/vision/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image_base64': base64Image}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      // Handle error
    }
    return {'description': 'Vision AI offline or missing camera stream.'};
  }

  Future<bool> sendRobotCommand(String command, Map<String, dynamic> params) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/robot/control'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'command': command, 'params': params}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
