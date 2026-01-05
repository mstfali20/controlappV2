import 'dart:core';

import 'dart:ui';

class PopularTopicsModel {
  final String title;
  final String para;
  final int post;
  final List<Color> color;
  PopularTopicsModel(
      {required this.title,
      required this.para,
      required this.color,
      required this.post});
}

List<PopularTopicsModel> topicsList = [
  PopularTopicsModel(
      title: "Önceki Ay",
      para: '123123',
      post: 30,
      color: [const Color(0xff7043bb), const Color(0xff5b33ae)]),
  PopularTopicsModel(
      title: "Önceki Hafta",
      para: '123123',
      post: 45,
      color: [const Color(0xff4a7dce), const Color(0xff3161cd)]),
  PopularTopicsModel(
      title: "Önceki Gün",
      para: '1231231',
      post: 22,
      color: [const Color(0xff3fd7fc), const Color(0xff31c3ee)])
];
