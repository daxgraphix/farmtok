import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class AIService {
  // Primary: Groq (fast, good quality)
  static const String _groqUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _groqModel = 'llama3-8b-8192';

  // Fallback 1: OpenRouter (multiple free models)
  static const String _openRouterUrl = 'https://openrouter.ai/api/v1/chat/completions';

  // Fallback 2: Together AI (free tier available)
  static const String _togetherUrl = 'https://api.together.xyz/v1/chat/completions';

  // Fallback 3: Hugging Face Inference API (free)
  static const String _huggingFaceUrl = 'https://api-inference.huggingface.co/models/';

  // Current provider tracking
  static String _currentProvider = 'groq';
  static int _retryCount = 0;
  static const int _maxRetries = 3;

  // Getter for current provider (for testing)
  static String get currentProvider => _currentProvider;

  static Future<Map<String, dynamic>> analyzeCropDisease(String imagePath) async {
    final inputImage = InputImage.fromFile(File(imagePath));
    final imageLabeler = GoogleMlKit.vision.imageLabeler(); // ignore: deprecated_member_use

    try {
      final labels = await imageLabeler.processImage(inputImage);

      // Simple disease detection based on labels
      // In a real app, this would use a trained model for crop diseases
      String diseaseName = 'Healthy Plant';
      double confidence = 0.9;
      String treatment = 'No treatment needed';
      String prevention = 'Continue good farming practices';

      for (final label in labels) {
        if (label.label.toLowerCase().contains('leaf') && label.confidence > 0.7) {
          // Check for common symptoms in labels (simplified)
          diseaseName = 'Potential Leaf Disease';
          confidence = label.confidence;
          treatment = 'Consult local agricultural extension service';
          prevention = 'Monitor plant health regularly';
          break;
        }
      }

      return {
        'disease_name': diseaseName,
        'confidence': confidence,
        'treatment': treatment,
        'prevention': prevention
      };
    } catch (e) {
      // Fallback to mock data if ML fails
      return {
        'disease_name': 'Analysis Failed',
        'confidence': 0.0,
        'treatment': 'Try again with a clearer image',
        'prevention': 'Ensure good lighting for photos'
      };
    } finally {
      imageLabeler.close();
    }
  }

  static Future<String> chatWithAI(String message, String userId) async {
    _retryCount = 0;

    // Try multiple providers in order
    while (_retryCount < _maxRetries) {
      try {
        String result;

        switch (_currentProvider) {
          case 'groq':
            result = await _tryGroqProvider(message);
            break;
          case 'openrouter':
            result = await _tryOpenRouterProvider(message);
            break;
          case 'together':
            result = await _tryTogetherProvider(message);
            break;
          case 'huggingface':
            result = await _tryHuggingFaceProvider(message);
            break;
          default:
            result = _getFallbackResponse(message);
        }

        if (result.isNotEmpty && !result.contains('error') && !result.contains('failed')) {
          _retryCount = 0; // Reset retry count on success
          return result;
        }

        // Try next provider
        _switchToNextProvider();
        _retryCount++;

      } catch (e) {
        debugPrint('AI Provider $_currentProvider failed: $e');
        _switchToNextProvider();
        _retryCount++;
      }
    }

    // All providers failed, return fallback
    return _getFallbackResponse(message);
  }

  static void _switchToNextProvider() {
    final openRouterKey = dotenv.env['OPENROUTER_API_KEY'];
    final hasOpenRouter = openRouterKey != null && openRouterKey.isNotEmpty && openRouterKey != 'sk-or-v1-placeholder';

    switch (_currentProvider) {
      case 'groq':
        _currentProvider = hasOpenRouter ? 'openrouter' : 'together';
        break;
      case 'openrouter':
        _currentProvider = 'together';
        break;
      case 'together':
        _currentProvider = 'huggingface';
        break;
      case 'huggingface':
        _currentProvider = 'groq'; // Cycle back
        break;
    }
    debugPrint('Switching to AI provider: $_currentProvider');
  }

  static Future<String> _tryGroqProvider(String message) async {
    final apiKey = dotenv.env['GROQ_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Groq API key not configured');
    }

    const systemPrompt = '''
You are an agricultural AI expert helping Tanzanian farmers using simple English and Swahili.
Provide practical farming advice, disease prevention, irrigation guidance, fertilizer recommendations, and weather-based farming decisions.
Keep responses concise and actionable.
''';

    final response = await http.post(
      Uri.parse(_groqUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _groqModel,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': message}
        ],
        'max_tokens': 500,
        'temperature': 0.7,
      }),
    ).timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices']?[0]?['message']?['content'];
      if (content != null && content.toString().trim().isNotEmpty) {
        return content.toString().trim();
      }
    }

    throw Exception('Groq API returned status ${response.statusCode}');
  }

  static Future<String> _tryOpenRouterProvider(String message) async {
    final apiKey = dotenv.env['OPENROUTER_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'sk-or-v1-placeholder') {
      debugPrint('OpenRouter API key not configured, skipping...');
      throw Exception('OpenRouter API key not configured');
    }

    const systemPrompt = '''
You are an agricultural AI expert helping Tanzanian farmers using simple English and Swahili.
Provide practical farming advice, disease prevention, irrigation guidance, fertilizer recommendations, and weather-based farming decisions.
Keep responses concise and actionable.
''';

    debugPrint('Trying OpenRouter with API key: ${apiKey.substring(0, 20)}...');

    final response = await http.post(
      Uri.parse(_openRouterUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
        'HTTP-Referer': 'https://farmtok.app', // Optional: for rankings
        'X-Title': 'FarmTok AI Assistant', // Optional: for rankings
      },
      body: jsonEncode({
        'model': 'meta-llama/llama-3.2-3b-instruct:free', // Free model
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': message}
        ],
        'max_tokens': 500,
        'temperature': 0.7,
      }),
    ).timeout(const Duration(seconds: 20));

    debugPrint('OpenRouter response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices']?[0]?['message']?['content'];
      if (content != null && content.toString().trim().isNotEmpty) {
        debugPrint('OpenRouter response successful');
        return content.toString().trim();
      }
    } else {
      debugPrint('OpenRouter API error: ${response.body}');
    }

    throw Exception('OpenRouter API failed with status ${response.statusCode}');
  }

  static Future<String> _tryTogetherProvider(String message) async {
    // Together AI free tier
    const systemPrompt = '''
You are an agricultural AI expert helping Tanzanian farmers.
Provide practical farming advice in simple English.
Keep responses concise and actionable.
''';

    final response = await http.post(
      Uri.parse(_togetherUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer 0000000000000000000000000000000000000000', // Placeholder for free tier
      },
      body: jsonEncode({
        'model': 'mistralai/Mistral-7B-Instruct-v0.1',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': message}
        ],
        'max_tokens': 300,
        'temperature': 0.7,
      }),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices']?[0]?['message']?['content'];
      if (content != null && content.toString().trim().isNotEmpty) {
        return content.toString().trim();
      }
    }

    throw Exception('Together AI failed');
  }

  static Future<String> _tryHuggingFaceProvider(String message) async {
    // Hugging Face free inference API
    const model = 'microsoft/DialoGPT-medium';

    final response = await http.post(
      Uri.parse('$_huggingFaceUrl$model'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'inputs': {
          'past_user_inputs': ['Hello, I am a farmer.'],
          'generated_responses': ['Hello! I\'m here to help with farming advice.'],
          'text': message,
        },
        'parameters': {
          'max_length': 100,
          'temperature': 0.7,
        },
      }),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty) {
        final generatedText = data[0]['generated_text'];
        if (generatedText != null) {
          // Extract just the AI response part
          final response = generatedText.toString().split('farmer. ').last;
          return response.trim();
        }
      }
    }

    throw Exception('Hugging Face API failed');
  }

  static String _getFallbackResponse(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('disease') || lowerMessage.contains('sick') || lowerMessage.contains('problem')) {
      return 'For crop diseases, ensure proper spacing between plants for air circulation, avoid overhead watering, and use certified disease-free seeds. If symptoms persist, consult your local agricultural extension officer.';
    } else if (lowerMessage.contains('water') || lowerMessage.contains('irrigation')) {
      return 'Water your crops early in the morning or late afternoon to reduce evaporation. Check soil moisture by inserting your finger 2-3 inches deep. Most crops need 1-2 inches of water per week.';
    } else if (lowerMessage.contains('fertilizer') || lowerMessage.contains('nutrient')) {
      return 'Use organic fertilizers like compost and manure. Test your soil pH - most crops prefer slightly acidic to neutral soil (pH 6.0-7.0). Apply fertilizers based on your crop\'s specific needs.';
    } else if (lowerMessage.contains('weather') || lowerMessage.contains('rain')) {
      return 'Monitor weather forecasts regularly. Plant drought-resistant varieties in dry areas. Use mulch to retain soil moisture. Harvest before heavy rains to prevent crop damage.';
    } else {
      return 'I\'m here to help with your farming questions! Ask me about crop diseases, irrigation, fertilizers, weather planning, or any other agricultural concerns. For specific advice, consult your local agricultural extension services.';
    }
  }

  static Future<String> getFarmingTip() async {
    const tips = [
      'Water your crops early in the morning to reduce evaporation',
      'Rotate crops to prevent soil depletion and pest buildup',
      'Use organic matter to improve soil fertility',
      'Monitor weather forecasts for optimal planting times',
      'Keep records of your farming activities for better planning'
    ];

    // Return random tip (in real app, could use AI to generate personalized tips)
    return tips[DateTime.now().millisecondsSinceEpoch % tips.length];
  }
}