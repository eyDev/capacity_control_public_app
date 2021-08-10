import 'dart:convert';
import 'dart:io';

import 'package:capacity_control_public_app/src/data/Constants.dart';
import 'package:capacity_control_public_app/src/models/ErrorModel.dart';
import 'package:capacity_control_public_app/src/models/PlaceModel.dart';
import 'package:device_info/device_info.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

class DataProvider {
  static final DataProvider _instancia = new DataProvider._();
  final Constants _constants = Constants();
  factory DataProvider() {
    return _instancia;
  }
  DataProvider._();

  final Map<String, String> header = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<List<Place>> searchPlaces(String query) async {
    final Uri url = Uri.http(_constants.baseUrl, '/api/place/$query');
    final http.Response response = await http.get(url);
    final Map<String, dynamic> decodedData = json.decode(response.body);
    final List<Place> places = Places().modelPlaceFromJson(decodedData['places']);
    return places;
  }

  Future<int> check(String placeID, String process) async {
    final String uniqueID = await _getId();
    final Map<String, dynamic> body = <String, dynamic>{
      'placeID': placeID,
      'deviceID': uniqueID,
    };
    final Uri url = Uri.http(_constants.baseUrl, '/api/public/$process');

    final http.Response response = await http.post(
      url,
      headers: header,
      body: jsonEncode(body),
    );

    return response.statusCode;
  }

  Future<dynamic> getPlace(String placeID) async {
    try {
      final Uri url = Uri.http(_constants.baseUrl, '/api/place/$placeID');
      final http.Response response = await http.get(url);
      if (response.statusCode != 200) {
        return _parseErrors(response);
      } else {
        return Place.fromJson(jsonDecode(response.body)['places']);
      }
    } catch (e) {
      return _localError();
    }
  }

  List<DataError> _parseErrors(http.Response response) {
    final Map<String, dynamic> decodedData = json.decode(response.body);
    final List<DataError> errors = DataErrors().modelPlaceFromJson(decodedData['errors']);
    return errors;
  }

  List<DataError> _localError() {
    return [
      DataError(
        msg: 'Error Interno, verifique la conección a internet',
        param: 'local',
        location: 'user',
      )
    ];
  }

  Future<String> _getId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      final IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor;
    } else {
      final AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId;
    }
  }
}
