import 'dart:developer';
import 'dart:io';
import 'package:controlapp/const/data.dart';
import 'package:controlapp/data/tree_node.dart';
import 'package:controlapp/src/core/config/tree_sections.dart';
import 'package:http/http.dart' as http;

// Organization veri modelini tanımlıyoruz
class OrganizationData {
  final String id;
  final String caption;
  final String displayCaption;

  OrganizationData(
    this.id,
    this.caption, {
    String? displayCaption,
  }) : displayCaption = displayCaption ?? caption;

  @override
  String toString() {
    return 'OrganizationData{id: $id, caption: $caption, displayCaption: $displayCaption}';
  }
}

class SectionData {
  final String id;
  final String caption;
  final List<OrganizationData> organizations;

  const SectionData({
    required this.id,
    required this.caption,
    required this.organizations,
  });
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
    sectionList.clear();

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

    _populateSectionsFromTree(root);
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
    sectionList.clear();
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

        _populateSectionsFromTree(root);
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

void _populateSectionsFromTree(TreeNode root) {
  final organizations = root
      .walk()
      .where((node) => node.classType.trim() == 'obm_organization')
      .toList();

  for (final section in treeSectionConfigs) {
    final matched = <String, OrganizationData>{};
    for (final node in organizations) {
      final caption = node.caption.trim();
      if (section.matchCaptions.contains(caption) &&
          _organizationHasDevice(node)) {
        matched[node.id] = OrganizationData(node.id, caption);
      }
    }
    if (matched.isEmpty) {
      continue;
    }
    final sectionOrganizations = matched.values
        .map(
          (organization) => OrganizationData(
            organization.id,
            organization.caption,
            displayCaption: displayCaptionForSection(
              section.id,
              organization.caption,
            ),
          ),
        )
        .toList()
      ..sort(
        (a, b) => a.displayCaption.compareTo(b.displayCaption),
      );
    sectionList.add(
      SectionData(
        id: section.id,
        caption: section.caption,
        organizations: sectionOrganizations,
      ),
    );
  }
}

bool _organizationHasDevice(TreeNode node) {
  for (final child in node.walk()) {
    if (child.classType.trim() == 'obm_device') {
      return true;
    }
  }
  return false;
}
