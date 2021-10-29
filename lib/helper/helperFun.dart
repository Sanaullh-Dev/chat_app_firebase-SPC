import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction {
  static String logInKey = "ISLOGIN";
  static String unameKey = "USERNAME";
  static String uemailKey = "USEREMAIL";
  static String phoneKey = "USERPHONE";

  /// saving data to sharedpreference
  static Future<bool> saveLogin(bool ckLogin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(logInKey, ckLogin);
  }

  static Future<bool> saveUName(String uName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(unameKey, uName);
  }

  static Future<bool> saveUEmail(String uEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(uemailKey, uEmail);
  }

  static Future<bool> saveUPhone(String uPhone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(uemailKey, uPhone);
  }

  /// fetching data from sharedpreference
  static Future<bool> getLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.getBool(logInKey);
  }

  static Future<String> getUName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(unameKey);
  }

  static Future<String> getUEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(uemailKey);
  }

  static Future<String> getUPhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(phoneKey);
  }
}
