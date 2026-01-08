import 'dart:developer';

import 'package:controlapp/const/data.dart';
import 'package:controlapp/data/tree_node.dart';
import 'package:controlapp/src/core/config/tree_sections.dart';
import 'package:controlapp/src/features/presentation/home/view_model/home_state.dart';

class RenewableGesTreeHelper {
  const RenewableGesTreeHelper();

  static final TreeSectionConfig _renewableSectionConfig =
      treeSectionConfigs.firstWhere(
    (section) => section.id == 'renewable',
    orElse: () => TreeSectionConfig(
      id: 'renewable',
      caption: 'Yenilenebilir Enerji',
      matchCaptions: const ['GES'],
    ),
  );

  static final List<String> _renewableSectionCaptions = {
    ..._renewableSectionConfig.matchCaptions
        .where((caption) => _normalizeCaption(caption) != 'ges'),
    _renewableSectionConfig.caption,
    'Yenilenebilir Enerji',
    'Yenilenebilir Enerji Izleme',
    'Yenilenebilir Enerji İzleme',
    'Yenilenebilir Enerji Izleme Sistemi',
    'Yenilenebilir Enerji İzleme Sistemi',
    'Renewable Energy',
    'Renewable Energy Monitoring',
    'Renewable Energy Monitoring System',
  }
      .map(_normalizeCaption)
      .where((caption) => caption.isNotEmpty)
      .toList();

  List<TreeNode> collect(TreeNode root, HomeState homeState) {
    final organization = _selectOrganization(root, homeState);
    final searchRoot = organization ?? root;
    final renewableNode = _findRenewableSectionNode(searchRoot);
    if (renewableNode != null) {
      log('renewable section found: ${renewableNode.caption}');
      final devices = _collectGesDevices(renewableNode);
      if (devices.isNotEmpty) {
        log(
          'found GES devices under renewable section: ${devices.map((device) => device.caption).join(', ')}',
        );
        return devices;
      }
    }

    final energyNode = _findEnergyNode(searchRoot);
    if (energyNode != null) {
      log('energy section found: ${energyNode.caption}');
      final devices = _collectGesDevices(energyNode);
      if (devices.isNotEmpty) {
        log(
          'found GES devices under energy section: ${devices.map((device) => device.caption).join(', ')}',
        );
        return devices;
      }
    }

    log('falling back to organization/root for GES devices');
    final fallbackDevices = _collectGesDevices(searchRoot);
    if (fallbackDevices.isNotEmpty) {
      return fallbackDevices;
    }
    log('no devices found on any candidate');
    return const [];
  }

  TreeNode? _selectOrganization(TreeNode root, HomeState homeState) {
    final selectedId =
        homeState.session?.selectedOrganizationId ?? organizationid;
    if (selectedId.isNotEmpty) {
      final node = root.findById(selectedId);
      if (node != null && node.id.isNotEmpty) {
        return node;
      }
    }

    final firmName = homeState.userSummary.firmName.trim();
    if (firmName.isNotEmpty) {
      final match = root.walk().firstWhere(
        (node) =>
            node.classType == 'obm_organization' &&
            node.caption.trim().toLowerCase() == firmName.toLowerCase(),
        orElse: () => TreeNode.empty(),
      );
      if (match.id.isNotEmpty) {
        return match;
      }
    }

    return root.children.isNotEmpty ? root.children.first : null;
  }

  TreeNode? _findEnergyNode(TreeNode organization) {
    final match = organization.walk().firstWhere(
      (node) =>
          node.classType == 'obm_organization' && _isEnergyCaption(node.caption),
      orElse: () => TreeNode.empty(),
    );
    return match.id.isNotEmpty ? match : null;
  }

  TreeNode? _findRenewableSectionNode(TreeNode root) {
    for (final node in root.walk()) {
      if (node.classType != 'obm_organization') {
        continue;
      }
      final normalized = _normalizeCaption(node.caption);
      if (normalized.isEmpty) {
        continue;
      }
      if (_renewableSectionCaptions.contains(normalized) ||
          _containsRenewableKeyword(normalized)) {
        return node;
      }
    }
    return null;
  }

  List<TreeNode> _collectGesDevices(TreeNode node) {
    if (node.classType == 'obm_organization' && _isGesCaption(node.caption)) {
      return _collectDevices(node);
    }

    final directGesOrg = node.children.firstWhere(
      (child) =>
          child.classType == 'obm_organization' && _isGesCaption(child.caption),
      orElse: () => TreeNode.empty(),
    );
    if (directGesOrg.id.isNotEmpty) {
      return _collectDevices(directGesOrg);
    }

    final nestedGesOrg = node.walk().firstWhere(
      (entry) =>
          entry.classType == 'obm_organization' && _isGesCaption(entry.caption),
      orElse: () => TreeNode.empty(),
    );
    if (nestedGesOrg.id.isNotEmpty) {
      return _collectDevices(nestedGesOrg);
    }

    final devices = <TreeNode>[];
    final seenIds = <String>{};
    for (final entry in node.walk()) {
      if (entry.classType != 'obm_device' || !_isGesCaption(entry.caption)) {
        continue;
      }
      if (entry.id.isNotEmpty && seenIds.add(entry.id)) {
        devices.add(entry);
      }
    }
    return devices;
  }

  bool _isGesCaption(String caption) {
    return RegExp(r'\bges\b', caseSensitive: false).hasMatch(caption);
  }

  bool _isEnergyCaption(String caption) {
    final normalized = _normalizeCaption(caption);
    return normalized.contains('enerji izleme') ||
        normalized.contains('enerji monitoring');
  }

  bool _containsRenewableKeyword(String normalizedCaption) {
    return normalizedCaption.contains('yenilenebilir') ||
        normalizedCaption.contains('renewable');
  }

  static String _normalizeCaption(String caption) {
    var normalized = caption.trim().toLowerCase();
    normalized = normalized.replaceAll(RegExp(r'[_\-\.\s]+'), ' ');
    normalized = normalized.replaceAll(RegExp(r'\d+'), ' ');
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    return normalized;
  }

  List<TreeNode> _collectDevices(TreeNode node) {
    final devices = <TreeNode>[];
    final seenIds = <String>{};
    for (final entry in node.walk()) {
      if (entry.classType != 'obm_device') {
        continue;
      }
      if (entry.id.isNotEmpty && seenIds.add(entry.id)) {
        devices.add(entry);
      }
    }
    return devices;
  }
}
