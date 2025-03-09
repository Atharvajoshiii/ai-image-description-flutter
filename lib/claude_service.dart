import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ClaudeService {
  final String _baseUrl = 'https://api.anthropic.com/v1/messages';
  final String _apiKey = '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';

  Future<String> analyzeImage(File image) async {
    // preparing the image
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);
    // sending request to claude
    final response = await http.post(Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01'
        },
        body: jsonEncode({
          'model': 'claude-3-opus-20240229',
          'max_tokens': 100,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'image',
                  'source': {
                    'type': 'base64',
                    'media_type': 'image/jpeg',
                    'data': base64Image
                  }
                },
                {
                  'type': 'text',
                  'text': 'Please describe what you see in this image'
                }
              ]
            }
          ]
        }));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'][0]['text'];
    }

    throw Exception("faled to analyze image : ${response.statusCode}");
  }
}
