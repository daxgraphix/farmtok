import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User; // ignore: unused_import
import '../services/supabase_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<void> initialize() async {
    try {
      // Check if Supabase is initialized by trying to access the client
      final client = SupabaseService.client;
      final session = client.auth.currentSession;
      if (session?.user != null) {
        await _loadUserProfile(session!.user.id);
      }
    } catch (e) {
      debugPrint('Error initializing auth provider (Supabase may not be initialized): $e');
      _error = 'Authentication service unavailable';
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String region,
    required String district,
    required String preferredLanguage,
    required String mainCrop,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userData = {
        'full_name': fullName,
        'phone_number': phoneNumber,
        'region': region,
        'district': district,
        'preferred_language': preferredLanguage,
        'main_crop': mainCrop,
      };

      final response = await SupabaseService.signUp(
        email: email,
        password: password,
        userData: userData,
      );

      if (response.user != null) {
        // Try to save additional user data to database
        try {
          await SupabaseService.client.from('users').insert({
            'id': response.user!.id,
            ...userData,
          });
        } catch (dbError) {
          debugPrint('Could not save user data to database: $dbError');
          // Continue anyway
        }

        _currentUser = User(
          id: response.user!.id,
          fullName: fullName,
          phoneNumber: phoneNumber,
          region: region,
          district: district,
          preferredLanguage: preferredLanguage,
          mainCrop: mainCrop,
        );

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Sign up error: $e');
      _error = 'Sign up failed. Please check your connection and try again.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserProfile(response.user!.id);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Sign in error: $e');
      _error = 'Sign in failed. Please check your credentials and connection.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> signOut() async {
    await SupabaseService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      _currentUser = User.fromJson(response);
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      // Create a basic user object if database is unavailable
      _currentUser = User(
        id: userId,
        fullName: 'User',
        phoneNumber: '',
        region: '',
        district: '',
        preferredLanguage: 'English',
        mainCrop: '',
      );
      _error = 'Profile data unavailable';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}