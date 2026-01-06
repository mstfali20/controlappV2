import 'package:controlapp/data/tree_node.dart';

TreeNode? findFirstDevice(
  TreeNode root, {
  List<String> preferredCaptions = const [],
}) {
  final devices = <TreeNode>[];

  void traverse(TreeNode node) {
    if (node.classType.trim() == 'obm_device') {
      devices.add(node);
    }
    for (final child in node.children) {
      traverse(child);
    }
  }

  traverse(root);
  if (devices.isEmpty) {
    return null;
  }

  if (preferredCaptions.isNotEmpty) {
    for (final caption in preferredCaptions) {
      final normalized = caption.trim();
      for (final device in devices) {
        if (device.caption.trim() == normalized) {
          return device;
        }
      }
    }
  }

  return devices.first;
}
