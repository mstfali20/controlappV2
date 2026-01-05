import 'dart:developer';
import 'dart:io';
import 'package:controlapp/const/data.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

// Organization veri modelini tanımlıyoruz
class OrganizationData {
  final String id;
  final String caption;

  OrganizationData(this.id, this.caption);

  @override
  String toString() {
    return 'OrganizationData{id: $id, caption: $caption}';
  }
}

void populateOrganizationsFromXml({String? xmlContent}) {
  final source = xmlContent ?? xmlString;
  if (source.isEmpty) {
    return;
  }

  try {
    final document = xml.XmlDocument.parse(source);
    final nodes = document.findAllElements('node');

    organizationList.clear();
    altorganizationList.clear();

    for (final node in nodes) {
      if (node.getAttribute('class') == 'obm_organization' &&
          (node.getAttribute('caption') == enerjiIzlem ||
              node.getAttribute('caption') == iklimlendirmeIzlem ||
              node.getAttribute('caption') == boyahaneIzlem)) {
        final id = node.getAttribute('id');
        final caption = node.getAttribute('caption');
        if (id != null && caption != null) {
          organizationList.add(OrganizationData(id, caption));
        }
      }
    }
  } catch (_) {
    // parsing failed; keep existing list
  }
}

void ensureOrganizationsLoaded() {
  if (organizationList.isEmpty) {
    populateOrganizationsFromXml();
  }
}

class OrganizationService {
  Future<List<OrganizationData>> fetchOrganizations(
      String username, String password) async {
    organizationList.clear();
    xmlString = '';

    try {
      var res = await http.get(
        Uri.parse(
            "http://web.controlapp.net.tr/modules/energy_management/mobile/tree.php?username=$username&password=$password&l=tr_TR"),
        headers: {
          HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
        },
      ).timeout(const Duration(seconds: 10));

      log(password.toString());

      if (res.statusCode == 200) {
        xmlString = res.body;

        var document = xml.XmlDocument.parse(res.body);
        var nodes = document.findAllElements('node');

        for (var node in nodes) {
          if (node.getAttribute('class') == 'obm_organization' &&
              (node.getAttribute('caption') == enerjiIzlem ||
                  node.getAttribute('caption') == iklimlendirmeIzlem ||
                  node.getAttribute('caption') == boyahaneIzlem)) {
            var id = node.getAttribute('id');
            var caption = node.getAttribute('caption');

            if (id != null && caption != null) {
              // Altındaki 'obm_device' elemanlarını say
              deviceCount = node
                  .findElements('node')
                  .where((child) => child.getAttribute('class') == 'obm_device')
                  .length;

              var organizationData = OrganizationData(id, caption);
              organizationList.add(organizationData);
            }
          }
        }

        return organizationList;
      } else {
        log('Sunucu hatası: ${res.statusCode}');
        return [];
      }
    } catch (e) {
      log('Hata: $e');
      return [];
    }
  }
}
