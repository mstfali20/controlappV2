import 'package:flutter/material.dart';

class CarouselPage extends StatefulWidget {
  const CarouselPage({
    super.key,
    required this.sliderText1,
    required this.sliderTitle,
    required this.imageUrl,
  });

  final String sliderText1;
  final String sliderTitle;
  final String imageUrl;

  @override
  State<CarouselPage> createState() => _CarouselPageState();
}

class _CarouselPageState extends State<CarouselPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Column(
          children: [
            // Text(
            //   widget.sliderTitle,
            //   style: TextStyle(
            //     fontSize: 30.sp,
            //     color: white,
            //     fontWeight: FontWeight.w900,
            //   ),
            // ),
          ],
        ),
        Column(
          children: [
            Text(
              widget.sliderText1,
              style: const TextStyle(
                fontSize: 25,
                color: Colors.white,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }
}
