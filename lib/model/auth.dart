class Auth {
  String user;
  String token;
  String expiresIn;

  String get auser => this.user;
  String get atoken => this.token;

  Auth(this.user, this.token, this.expiresIn);

  Map<String, dynamic> toMapFromDb() {
    var map = <String, dynamic>{
      "user": user,
      "token": token,
      "expiresIn": expiresIn,
    };
    return map;
  }

  Auth.fromMapToDb(Map<String, dynamic> map)
      : user = map["user"],
        token = map["token"],
        expiresIn = map["expiresIn"];
}
