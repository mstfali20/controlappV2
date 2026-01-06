import 'package:controlapp/const/Color.dart';
import 'package:flutter/material.dart';

class UnitSelectionWidget extends StatelessWidget {
  final String selectedUnit;
  final String degerValue;
  final String birimValue;
  final VoidCallback onTap;

  const UnitSelectionWidget({
    super.key,
    required this.selectedUnit,
    required this.degerValue,
    required this.birimValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 80,
            height: 35,
            decoration: BoxDecoration(
              color: contolblue,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 150),
                  alignment: selectedUnit == degerValue
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 40,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      selectedUnit,
                      style: const TextStyle(
                        color: contolblue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          birimValue,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: Text(
                          degerValue,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
