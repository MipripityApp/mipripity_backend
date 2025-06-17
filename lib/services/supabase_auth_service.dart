import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final supabase = Supabase.instance.client;

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      data: userData,
    );
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  bool isAuthenticated() {
    return supabase.auth.currentUser != null;
  }

  Stream<AuthState> get authStateChange => supabase.auth.onAuthStateChange;
}