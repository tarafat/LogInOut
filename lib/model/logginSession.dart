class LoginSession {
  String cus;
  String org;
  String time;

  LoginSession(this.cus, this.org, this.time);

  Map<String, dynamic> toMapFromDb() {
    var map = <String, dynamic>{
      "cus": cus,
      "org": org,
      "time": time,
    };
    return map;
  }

  LoginSession.fromMapToDb(Map<String, dynamic> map)
      : cus = map["cus"],
        org = map["org"],
        time = map["time"];
}
