import 'dart:developer';
import 'dart:io';
import 'package:controlapp/const/data.dart';
import 'package:controlapp/data/tree_node.dart';
import 'package:http/http.dart' as http;

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

void populateOrganizationsFromTree({String? treeContent}) {
  final source = treeContent ?? treeJson;
  if (source.isEmpty) {
    return;
  }

  try {
    final root = TreeNode.parseTree(source);
    if (root == null) {
      return;
    }
    final nodes = root.walk();

    organizationList.clear();
    altorganizationList.clear();

    for (final node in nodes) {
      final normalizedClass = node.classType.trim();
      final caption = node.caption.trim();
      if (normalizedClass == 'obm_organization' &&
          (caption == enerjiIzlem ||
              caption == iklimlendirmeIzlem ||
              caption == boyahaneIzlem)) {
        final id = node.id;
        if (id.isNotEmpty && caption.isNotEmpty) {
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
    populateOrganizationsFromTree();
  }
}

class OrganizationService {
  Future<List<OrganizationData>> fetchOrganizations(
      String username, String password) async {
    organizationList.clear();
    treeJson = '';

    try {
      var res = await http.get(
        Uri.parse(
            "http://web.controlapp.net.tr/modules/energy_management/mobile/newtree.php?username=$username&password=$password&l=tr_TR"),
        headers: {
          HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
        },
      ).timeout(const Duration(seconds: 10));

      log(password.toString());

      if (res.statusCode == 200) {
        treeJson = res.body;

        final root = TreeNode.parseTree(res.body);
        if (root == null) {
          return [];
        }
        final nodes = root.walk();

        for (var node in nodes) {
          final normalizedClass = node.classType.trim();
          final caption = node.caption.trim();
          if (normalizedClass == 'obm_organization' &&
              (caption == enerjiIzlem ||
                  caption == iklimlendirmeIzlem ||
                  caption == boyahaneIzlem)) {
            final id = node.id;

            if (id.isNotEmpty && caption.isNotEmpty) {
              // Altındaki 'obm_device' elemanlarını say
              deviceCount = node.children
                  .where((child) => child.classType.trim() == 'obm_device')
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
