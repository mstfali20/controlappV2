import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:controlapp/data/garfikModel.dart';

class ConsumptionService {
  Future<List<HistoryGrafikData>> fetchConsumptionData({
    required String username,
    required String password,
    required String periodType,
    required String deviceId,
    required String type,
    required String totalCheckPt,
    required String term,
    required String startDate, // Eklendi
    required String endDate, // Eklendi
  }) async {
    // API URL
    const url =
        'http://web.controlapp.net.tr/modules/energy_management/mobile/consumptions.php';

    // HTTP GET isteği
    final response = await http.get(
      Uri.parse(
        '$url?username=$username&password=$password&period_type=$periodType'
        '&device_id=$deviceId&type=$type&total_check_pt=$totalCheckPt&term=$term'
        '&start_date=$startDate&end_date=$endDate', // Eklendi
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['Error_Code'] == 0) {
        // JSON verilerini modele dönüştür
        log(data['Data'].toString());
        return (data['Data'] as List)
            .map((e) => HistoryGrafikData.fromJson(e))
            .toList();
      } else {
        // Hata mesajını yakala
        throw Exception('Error: ${data["Error_Description"]}');
      }
    } else {
      // İstek başarısız olduğunda hata fırlat
      throw Exception(
          'Failed to fetch data. Status Code: ${response.statusCode}');
    }
  }
}
