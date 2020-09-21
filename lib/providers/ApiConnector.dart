import 'dart:convert' show json;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter/services.dart' show PlatformException;
import 'package:geocoder/geocoder.dart' show Address, Coordinates, Geocoder;
import 'package:geolocation/geolocation.dart'
    show
        Geolocation,
        GeolocationResult,
        Location,
        LocationPermission,
        LocationResult,
        LocationPermissionAndroid,
        LocationPermissionIOS,
        LocationAccuracy;
import 'package:get_mac/get_mac.dart' show GetMac;
import 'package:http/http.dart' show post, put;

import '../model/auth.dart';
import '../model/logginSession.dart';
import '../providers/db_provider.dart';
import '../providers/helper.dart';

class ApiConnector with ChangeNotifier {
  double lat;
  double lon;
  String address;
  Auth auth;
  String postCode;
  String mac = 'Unknown';
  List<Address> addreses;
  DatabaseHelper _databaseHelper = DatabaseHelper();
  Future<bool> openSession(String customer, String qrText, String time) async {
    bool returnVal;
    await enableLServices();
    String url = Helper.host + '/lin_info/work-session/open-session';
    try {
      final response = await post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'authorization': auth.atoken
        },
        body: json.encode(
          {
            "user_id": auth.user,
            "customer_id": customer,
            "lat": lat,
            "lan": lon,
            "address": address,
            "mac_address": mac,
            "post_code": postCode
          },
        ),
      );
      if (response.statusCode == 200) {
        _databaseHelper.addLoginSession(LoginSession(customer, qrText, time));
        returnVal = true;
      } else if (response.statusCode >= 400) {
        returnVal = false;
      } else {
        returnVal = false;
      }
    } catch (e) {
      returnVal = false;
    }
    notifyListeners();
    return returnVal;
  }

  Future<bool> closeSession(String comment) async {
    bool returnVal;
    enableLServices().then((value) async {
      print("trying to Log out");
      final url = Helper.host + '/lin_info/work-session/close-session';
      try {
        final response = await put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'authorization': auth.atoken
          },
          body: json.encode(
            {
              "user_id": auth.user,
              "closingComment": comment,
              "lat": lat,
              "lan": lon,
              "address": address,
              "mac_address": mac,
              "post_code": postCode
            },
          ),
        );
        if (response.statusCode == 200) {
          LoginSession session = await _databaseHelper.fetchLoginSession();
          await _databaseHelper.deleteLoginSession(session.cus);
          returnVal = true;
        } else {
          returnVal = false;
        }
      } catch (e) {
        returnVal = false;
      }
    });
    notifyListeners();
    return returnVal;
  }

  Future<bool> ping() async {
    bool returnVal;
    enableLServices().then((value) async {
      print("trying to ping out");
      final url = Helper.host + '/lin_info/work-session/ping';
      try {
        final response = await post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'authorization': auth.atoken
          },
          body: json.encode(
            {
              "user": auth.user,
              "lat": lat,
              "lan": lon,
              "address": address,
              "mac_address": mac,
              "post_code": postCode
            },
          ),
        );
        if (response.statusCode == 200) {
          returnVal = true;
        } else {
          returnVal = false;
        }
      } catch (e) {
        returnVal = false;
      }
    });

    return returnVal;
  }

  getPermission() async {
    final GeolocationResult result =
        await Geolocation.requestLocationPermission(
      permission: const LocationPermission(
        android: LocationPermissionAndroid.fine,
        ios: LocationPermissionIOS.always,
      ),
      openSettingsIfDenied: true,
    );

    return result;
  }

  Future<void> enableLServices() async {
    await getPermission();
    Location loc;
    DatabaseHelper _databaseHelper = DatabaseHelper();

    auth = await _databaseHelper.fetchAuthUser();

    if (Platform.isAndroid) {
      await Geolocation.enableLocationServices();
    }
    LocationResult result; //= await Geolocation.lastKnownLocation();
    Geolocation.currentLocation(accuracy: LocationAccuracy.best)
        .listen((location) async {
      result = location;
      loc = result.location;
      lat = loc.latitude;
      lon = loc.longitude;
      final coordinates = new Coordinates(loc.latitude, loc.longitude);
      addreses = await Geocoder.local
          .findAddressesFromCoordinates(coordinates)
          .catchError((e) async {
        print('error');
        addreses =
            await Geocoder.local.findAddressesFromCoordinates(coordinates);
      });
      postCode = addreses.first.postalCode;
      address = addreses.first.addressLine;
      mac = await initPlatformState();
    });
  }

  Future<String> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await GetMac.macAddress;
      return platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get Device MAC Address.';
      return platformVersion;
    }
  }
}
