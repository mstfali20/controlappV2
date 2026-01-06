import 'package:controlapp/const/Color.dart';
import 'package:controlapp/const/scale_button.dart';
import 'package:flutter/material.dart';

class PeriodSelectionWidget extends StatelessWidget {
  final int selectedCategoryIndex;
  final List<String> periods;
  final Function(int) onPeriodSelected;

  const PeriodSelectionWidget({
    super.key,
    required this.selectedCategoryIndex,
    required this.periods,
    required this.onPeriodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        height: 45,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(periods.length, (index) {
            final isSelected = selectedCategoryIndex == index;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: ScaleButton(
                onTap: () => onPeriodSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: isSelected ? contolblue : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: isSelected ? Colors.white : darkColor,
                        fontSize: 16,
                      ),
                      child: Text(periods[index]),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
