import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:controlapp/data/historyModel.dart';
import 'package:http/http.dart' as http;

class HistoryPost {
  Future<List<HistoryData>> fetchHistoryApi(String username, String password,
      String serial, String labelcod, String period) async {
    try {
      var url = Uri.parse(
          'http://web.controlapp.net.tr/modules/energy_management/mobile/device_monitor.php?username=$username&password=$password&device_id=$serial&label_code=$labelcod&period=$period');

      log(url.toString());
      var res = await http.post(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
        },
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8.decode(res.bodyBytes));

        final List<dynamic> jsonData = jsonResponse['Data'];
        final List<HistoryData> responseJson = jsonData
            .map<HistoryData>((data) => HistoryData.fromJson(data))
            .toList();
        log(responseJson.toString());
        return responseJson;
      } else {
        return [];
      }
    } catch (e) {
      print("Catche düştü: $e");
      throw Exception('Failed to load data: $e');
    }
  }
}
