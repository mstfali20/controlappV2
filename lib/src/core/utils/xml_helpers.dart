import 'package:xml/xml.dart' as xml;

xml.XmlDocument parseXmlDocument(String raw) {
  return xml.XmlDocument.parse(raw);
}

Iterable<xml.XmlElement> findNodesByClass(
  xml.XmlDocument document,
  String className,
) {
  return document.findAllElements('node').where(
        (element) => element.getAttribute('class') == className,
      );
}

String attributeOrEmpty(xml.XmlElement element, String name) {
  return element.getAttribute(name) ?? '';
}
