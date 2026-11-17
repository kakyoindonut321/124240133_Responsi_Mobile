import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _validEmail = 'abelyo@gmail.com';
  static const String _validPassword = '123';

  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyEmail = 'email';

  // Cek kredensial (belum menyimpan apa-apa)
  bool validate(String email, String password) {
    return email == _validEmail && password == _validPassword;
  }

  // Simpan sesi setelah login berhasil
  Future<void> saveSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyEmail, email);
  }

  // Dipakai main.dart untuk menentukan halaman awal
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Dipakai Profile Page
  Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail) ?? '-';
  }

  // Logout = hapus sesi
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyEmail);
  }
}
