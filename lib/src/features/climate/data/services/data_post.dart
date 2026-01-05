import 'dart:convert';
import 'dart:io';
import 'package:controlapp/const/data.dart';
import 'package:controlapp/data/model.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class DataPost {
  List<DataModel> dataList = [];

  Future fetchDataApi(String username, String password, String serial) async {
    try {
      var res = await http.post(
        Uri.parse(
            'http://web.controlapp.net.tr/modules/energy_management/mobile/io_sensor_value_current_data.php?username=$username&password=$password&l=tr_TR&device_id=$serial'),
        headers: {
          HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
        },
      ).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final responseJson = DataModel.fromJson(jsonDecode(
          utf8.decode(res.bodyBytes),
        ));

        if (responseJson.errorCode == 0) {
          dataList.add(responseJson);
          for (var dataModel in dataList) {
            if (dataModel.data != null) {
              for (var item in dataModel.data!) {
                var parts = item.split('=');
                if (parts.length == 2) {
                  String key = parts[0];
                  String value = parts[1];
                  // Anahtar ve değerleri map'e ekleyelim
                  anaAnlikVeriMap[key] = value;
                }
              }
            }
          }

          print(responseJson.data);
          return [responseJson.errorCode, responseJson.errorDescription];
        } else {
          // print(responseJson.errorCode);
          return [responseJson.errorCode, responseJson.errorDescription];
        }
        // return DataModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      // print("sdadad");
      String errorText = e.toString();
      if (errorText.contains("TimeoutException")) {
        return [5, "Sunucuyla Ulaşılamıyor."];
      } else {
        return [5, "İnternet Bağlantınızı Kontrol edin"];
      }
    }
  }
}
