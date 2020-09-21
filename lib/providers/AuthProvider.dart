import 'dart:convert' show json;

import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:http/http.dart' show post;

import '../providers/db_provider.dart';
import '../model/auth.dart';
import '../providers/helper.dart';

class AuthProvider with ChangeNotifier {
  String _user;
  String _token;
  String _expiresIn;
  final String url = Helper.host + "/lin_info/users/login";
  DatabaseHelper _databaseHelper = DatabaseHelper();

  String get user => _user;
  String get token => _token;

  Future<bool> login(String id, String pw) async {
    try {
      final response = await post(
        url,
        body: json.encode({"id": id, "password": pw}),
      ).timeout(Duration(seconds: 50));

      if (response.statusCode == 200) {
        _token = response.headers['authorization'];
        _user = id;
        _expiresIn = response.headers['expiresin'];
        await _databaseHelper.initializeDatabase().then((value) {
          _databaseHelper.addAuthUser(new Auth(_user, _token, _expiresIn));
        });

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
