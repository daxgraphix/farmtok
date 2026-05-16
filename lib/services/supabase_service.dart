import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  static Future<void> initialize() async {
    try {
      final url = dotenv.env['SUPABASE_URL'] ?? 'https://jnrdboijomepkfrziifn.supabase.co';
      final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpucmRib2lqb21lcGtmcnppaWZuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg3NDY4NDksImV4cCI6MjA5NDMyMjg0OX0.NNxI8fF2Do70mU2RBe8xGWFdigecIycXL7Qo3trf3Yo';

      if (url.isEmpty || anonKey.isEmpty) {
        throw Exception('Supabase URL or anon key is empty');
      }

      debugPrint('Initializing Supabase with URL: $url');
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );
      debugPrint('Supabase initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Supabase: $e');
      // Don't rethrow for now to allow app to continue
    }
  }

  // Authentication methods
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: userData,
    );
    return response;
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static User? get currentUser => client.auth.currentUser;

  // Database operations
  static Future<List<Map<String, dynamic>>> getCropScans(String userId) async {
    final response = await client
        .from('crop_scans')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return response;
  }

  static Future<void> saveCropScan(Map<String, dynamic> scanData) async {
    await client.from('crop_scans').insert(scanData);
  }

  static Future<void> saveChatMessage(Map<String, dynamic> chatData) async {
    await client.from('ai_chats').insert(chatData);
  }

  static Future<List<Map<String, dynamic>>> getChatHistory(String userId) async {
    final response = await client
        .from('ai_chats')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);
    return response;
  }

  static Future<void> saveWeatherLog(Map<String, dynamic> weatherData) async {
    await client.from('weather_logs').insert(weatherData);
  }
}