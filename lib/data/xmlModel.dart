import 'package:xml/xml.dart' as xml;

class XmlModel {
  String id;
  String caption;
  String title;
  String deviceType;
  String category;
  String kwa;
  String akim;
  String classType;
  String subuhar;

  List<XmlModel> children;

  XmlModel({
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

  // fromXml() metodun zaten var, o yüzden burada sadece toJson() ekliyoruz
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caption': caption,
      'title': title,
      'deviceType': deviceType,
      'category': category,
      'kwa': kwa,
      'akim': akim,
      'classType': classType,
      'subuhar': subuhar,
      'children': children
          .map((child) => child.toJson())
          .toList(), // children listeyi JSON'a çevir
    };
  }

  factory XmlModel.fromJson(Map<String, dynamic> json) {
    return XmlModel(
      id: json['id'],
      caption: json['caption'],
      title: json['title'],
      deviceType: json['deviceType'],
      category: json['category'],
      kwa: json['kwa'],
      akim: json['akim'],
      classType: json['classType'],
      subuhar: json['subuhar'],
      children: (json['children'] as List<dynamic>)
          .map((child) => XmlModel.fromJson(child))
          .toList(),
    );
  }

  factory XmlModel.fromXml(xml.XmlElement element) {
    return XmlModel(
      id: element.getAttribute('id') ?? '',
      caption: element.getAttribute('caption') ?? '',
      title: element.getAttribute('title') ?? '',
      deviceType: element.getAttribute('deviceType') ?? '',
      category: element.getAttribute('category') ?? '',
      classType: element.getAttribute('class') ?? '',
      children: element.children
          .whereType<xml.XmlElement>()
          .map((child) => XmlModel.fromXml(child))
          .toList(),
      kwa: '',
      akim: '',
      subuhar: '',
    );
  }

  static XmlModel empty() {
    return XmlModel(
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
}
