import 'dart:convert';

class TreeNode {
  String id;
  String caption;
  String title;
  String deviceType;
  String category;
  String kwa;
  String akim;
  String classType;
  String subuhar;

  List<TreeNode> children;

  TreeNode({
    required this.id,
    required this.caption,
    required this.title,
    required this.deviceType,
    required this.children,
    required this.category,
    required this.kwa,
    required this.akim,
    required this.classType,
    required this.subuhar,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caption': caption,
      'title': title,
      'deviceType': deviceType,
      'category': category,
      'kwa': kwa,
      'akim': akim,
      'class': classType,
      'subuhar': subuhar,
      'children': children
          .map((child) => child.toJson())
          .toList(), // children listeyi JSON'a çevir
    };
  }

  factory TreeNode.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'];
    final parsedChildren = <TreeNode>[];
    if (rawChildren is List) {
      for (final child in rawChildren) {
        if (child is Map) {
          parsedChildren.add(
            TreeNode.fromJson(Map<String, dynamic>.from(child)),
          );
        }
      }
    }

    return TreeNode(
      id: json['id']?.toString() ?? '',
      caption: json['caption']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      deviceType: json['deviceType']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      kwa: json['kwa']?.toString() ?? '',
      akim: json['akim']?.toString() ?? '',
      classType:
          json['classType']?.toString() ?? json['class']?.toString() ?? '',
      subuhar: json['subuhar']?.toString() ?? '',
      children: parsedChildren,
    );
  }

  static TreeNode empty() {
    return TreeNode(
      id: '',
      caption: '',
      title: '',
      deviceType: '',
      category: '',
      kwa: '',
      akim: '',
      classType: '',
      subuhar: '',
      children: const [],
    );
  }

  Iterable<TreeNode> walk() sync* {
    yield this;
    for (final child in children) {
      yield* child.walk();
    }
  }

  TreeNode? findById(String id) {
    if (id.isEmpty) {
      return null;
    }
    for (final node in walk()) {
      if (node.id == id) {
        return node;
      }
    }
    return null;
  }

  static TreeNode? parseTree(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) {
        return TreeNode.fromJson(decoded);
      }
      if (decoded is List && decoded.isNotEmpty) {
        final first = decoded.first;
        if (first is Map) {
          return TreeNode.fromJson(Map<String, dynamic>.from(first));
        }
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  static List<TreeNode> parseTreeNodes(String raw) {
    final root = parseTree(raw);
    if (root == null) {
      return const [];
    }
    return root.walk().toList();
  }
}
