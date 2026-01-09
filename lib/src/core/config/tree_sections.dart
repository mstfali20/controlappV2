class TreeSectionConfig {
  const TreeSectionConfig({
    required this.id,
    required this.caption,
    required this.matchCaptions,
  });

  final String id;
  final String caption;
  final List<String> matchCaptions;
}

const List<TreeSectionConfig> treeSectionConfigs = [
  TreeSectionConfig(
    id: 'energy',
    caption: 'Enerji İzleme',
    matchCaptions: ['Enerji İzleme Sistemi'],
  ),
  TreeSectionConfig(
    id: 'renewable',
    caption: 'Yenilenebilir Enerji',
    matchCaptions: ['GES'],
  ),
  TreeSectionConfig(
    id: 'utilities',
    caption: 'Yardımcı Tesisler',
    matchCaptions: [
      'Klima Santrali İzleme Sistemi',
      'Kazan İzleme Sistemi',
      'Kompresör İzleme Sistemi'
    ],
  ),
  TreeSectionConfig(
    id: 'production',
    caption: 'Üretim İzleme',
    matchCaptions: [
      'Boyahane',
      'Boyahane İzleme Sistemi',
      'Mermer',
      'Dokuma',
      'Dokuma Salonu',
    ],
  ),
];

const Map<String, Map<String, String>> sectionDisplayCaptionOverrides = {
  'energy': {
    'Enerji İzleme Sistemi': 'Enerji İzleme',
  },
  'renewable': {
    'GES': 'GES',
    'Enerji İzleme Sistemi': 'GES',
  },
  'utilities': {},
  'production': {
    'Boyahane İzleme Sistemi': 'Boyahane',
    'Dokuma Salonu': 'Dokuma',
  },
};

const Map<String, List<String>> sectionPreferredDeviceCaptions = {
  'renewable': [
    'GES Toplam',
    'GES Üretim Tüketim Farkı',
    'Çatı Ges',
    'Saha Ges',
  ],
  'utilities': [
    'Klima Santrali',
    'Kazan',
    'Kompresör',
  ],
  'production': [
    'Boyahane',
    'Mermer',
    'Dokuma',
    'Dokuma Salonu',
  ],
};

String displayCaptionForSection(String sectionId, String caption) {
  final overrides = sectionDisplayCaptionOverrides[sectionId];
  if (overrides == null) {
    return caption;
  }
  return overrides[caption] ?? caption;
}

List<String> preferredDeviceCaptionsForSection(String? sectionId) {
  if (sectionId == null || sectionId.isEmpty) {
    return const [];
  }
  return sectionPreferredDeviceCaptions[sectionId] ?? const [];
}
