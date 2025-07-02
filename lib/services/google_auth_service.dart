import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleAuthService {
  static const String baseUrl = 'http://127.0.0.1:8000';
  
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
    // Add your Google OAuth client ID here
    clientId: '718226045674-at653ipmf2hdu79tf3a05tcc5pkb85k3.apps.googleusercontent.com',
  );

  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      // Send the access token to your Django backend
      final response = await http.post(
        Uri.parse('$baseUrl/api/google/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'access_token': googleAuth.accessToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'token': data['token'],
          'user': data['user'],
          'role': data['role'],
          'isNewUser': data['is_new_user'] ?? false,
        };
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Google authentication failed');
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Error signing out from Google: $e');
    }
  }

  static Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  static GoogleSignInAccount? getCurrentUser() {
    return _googleSignIn.currentUser;
  }
}