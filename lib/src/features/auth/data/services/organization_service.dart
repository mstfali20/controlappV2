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
  final topLevelOrganizations = root.children
      .where((node) => node.classType.trim() == 'obm_organization')
      .toList();
  final organizations = topLevelOrganizations.isNotEmpty
      ? topLevelOrganizations
      : (root.classType.trim() == 'obm_organization' ? [root] : <TreeNode>[]);

  final energyConfig = treeSectionConfigs.firstWhere(
    (section) => section.id == 'energy',
    orElse: () => const TreeSectionConfig(
      id: 'energy',
      caption: 'Enerji İzleme',
      matchCaptions: [],
    ),
  );

  final energyNodes =
      _matchOrganizationNodes(organizations, energyConfig.matchCaptions);

  final sections = <SectionData>[];
  final energySection = _buildSectionData(energyConfig, energyNodes);
  if (energySection != null) {
    sections.add(energySection);
  }

  for (final section in treeSectionConfigs) {
    if (section.id == energyConfig.id) {
      continue;
    }

    var matched = <String, TreeNode>{};
    if (section.id == 'utilities') {
      matched = _resolveUtilitiesNodes(organizations, energyNodes.values);
    } else {
      matched = _matchOrganizationNodes(organizations, section.matchCaptions);
    }
    if (matched.isEmpty && energyNodes.isNotEmpty) {
      if (section.id == 'renewable') {
        matched = _fallbackFromEnergy(
          energyNodes.values,
          _containsGesDevices,
        );
      }
    }

    final sectionData = _buildSectionData(section, matched);
    if (sectionData != null) {
      sections.add(sectionData);
    }
  }

  sectionList.addAll(sections);
}

bool _organizationHasDevice(TreeNode node) {
  for (final child in node.walk()) {
    if (child.classType.trim() == 'obm_device') {
      return true;
    }
  }
  return false;
}

Map<String, TreeNode> _matchOrganizationNodes(
  List<TreeNode> organizations,
  List<String> matchCaptions,
) {
  final matched = <String, TreeNode>{};
  for (final node in organizations) {
    final caption = node.caption.trim();
    if (matchCaptions.contains(caption) && _organizationHasDevice(node)) {
      matched[node.id] = node;
    }
  }
  return matched;
}

SectionData? _buildSectionData(
  TreeSectionConfig section,
  Map<String, TreeNode> nodes,
) {
  if (nodes.isEmpty) {
    return null;
  }
  final organizations = nodes.values
      .map(
        (node) => OrganizationData(
          node.id,
          node.caption.trim(),
          displayCaption: displayCaptionForSection(section.id, node.caption),
        ),
      )
      .toList()
    ..sort((a, b) => a.displayCaption.compareTo(b.displayCaption));

  return SectionData(
    id: section.id,
    caption: section.caption,
    organizations: organizations,
  );
}

Map<String, TreeNode> _fallbackFromEnergy(
  Iterable<TreeNode> energyNodes,
  bool Function(TreeNode node) predicate,
) {
  final matched = <String, TreeNode>{};
  for (final node in energyNodes) {
    if (predicate(node)) {
      matched[node.id] = node;
    }
  }
  return matched;
}

Map<String, TreeNode> _resolveUtilitiesNodes(
  List<TreeNode> topLevelOrganizations,
  Iterable<TreeNode> energyNodes,
) {
  final topLevelRoots = topLevelOrganizations
      .where((node) => _hasUtilitiesSectionCaption(node.caption))
      .toList();
  final fromTopLevel = _collectUtilitiesOrganizations(topLevelRoots);
  final energyRoots = _findUtilitiesRootsInEnergy(energyNodes);
  final fromEnergy = _collectUtilitiesOrganizations(energyRoots);

  final merged = <String, TreeNode>{}
    ..addAll(fromTopLevel)
    ..addAll(fromEnergy);

  if (!_containsUtilitiesCaption(merged, 'klima santrali izleme sistemi')) {
    final climate = _findTopLevelOrganization(
      topLevelOrganizations,
      'Klima Santrali İzleme Sistemi',
    );
    if (climate != null && _organizationHasDevice(climate)) {
      merged.putIfAbsent(climate.id, () => climate);
    }
  }

  return merged;
}

Iterable<TreeNode> _findUtilitiesRootsInEnergy(Iterable<TreeNode> energyNodes) {
  final roots = <TreeNode>[];
  for (final energyNode in energyNodes) {
    for (final child in energyNode.children) {
      if (child.classType.trim() != 'obm_organization') {
        continue;
      }
      if (_hasUtilitiesSectionCaption(child.caption)) {
        roots.add(child);
      }
    }
  }
  return roots;
}

Map<String, TreeNode> _collectUtilitiesOrganizations(Iterable<TreeNode> roots) {
  final matched = <String, TreeNode>{};
  for (final root in roots) {
    for (final child in root.children) {
      if (child.classType.trim() != 'obm_organization') {
        continue;
      }
      if (!_isUtilitiesOrganizationCaption(child.caption)) {
        continue;
      }
      if (_organizationHasDevice(child)) {
        matched.putIfAbsent(child.id, () => child);
      }
    }
  }
  return matched;
}

TreeNode? _findTopLevelOrganization(
  List<TreeNode> topLevelOrganizations,
  String caption,
) {
  final target = caption.trim();
  for (final node in topLevelOrganizations) {
    if (node.caption.trim() == target) {
      return node;
    }
  }
  return null;
}

bool _containsGesDevices(TreeNode node) {
  for (final entry in node.walk()) {
    if (entry.classType.trim() != 'obm_device' &&
        entry.classType.trim() != 'obm_organization') {
      continue;
    }
    if (_hasGesCaption(entry.caption)) {
      return true;
    }
  }
  return false;
}

bool _containsUtilitiesDevices(TreeNode node) {
  for (final entry in node.walk()) {
    if (entry.classType.trim() != 'obm_device' &&
        entry.classType.trim() != 'obm_organization') {
      continue;
    }
    if (_hasUtilitiesCaption(entry.caption)) {
      return true;
    }
  }
  return false;
}

bool _hasGesCaption(String caption) {
  return RegExp(r'\bges\b', caseSensitive: false).hasMatch(caption);
}

bool _hasUtilitiesCaption(String caption) {
  final normalized = caption.toLowerCase();
  return normalized.contains('klima') ||
      normalized.contains('kazan') ||
      normalized.contains('kompres');
}

bool _isUtilitiesOrganizationCaption(String caption) {
  final normalized = caption.trim().toLowerCase();
  return normalized == 'kazan izleme sistemi' ||
      normalized == 'kompresör izleme sistemi' ||
      normalized == 'kompresor izleme sistemi' ||
      normalized == 'klima santrali izleme sistemi';
}

bool _hasUtilitiesSectionCaption(String caption) {
  final normalized = caption.toLowerCase();
  return normalized.contains('yardımcı tesis') ||
      normalized.contains('yardimci tesis');
}

bool _containsUtilitiesCaption(
  Map<String, TreeNode> nodes,
  String caption,
) {
  final normalized = caption.trim().toLowerCase();
  for (final node in nodes.values) {
    if (node.caption.trim().toLowerCase() == normalized) {
      return true;
    }
  }
  return false;
}
