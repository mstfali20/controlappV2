import 'package:controlapp/l10n/language_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguageBtn extends StatelessWidget {
  List<DropdownMenuItem<String>> get dropdownItems {
    return [
      DropdownMenuItem(
        value: "tr",
        child:
            Center(child: Image.asset("assets/flags/turkish.png", height: 32)),
      ),
      DropdownMenuItem(
        value: "en",
        child:
            Center(child: Image.asset("assets/flags/english.png", height: 32)),
      ),
    ];
  }

  const LanguageBtn({
    super.key,
// Parametre opsiyonel hale getirildi
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context); // Dinleyici aktif

    return Padding(
      padding: const EdgeInsets.only(
          left: 16, right: 24), // DropdownButton arasındaki boşluk
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          icon: const SizedBox.shrink(),
          value: languageProvider.locale,
          items: dropdownItems,
          onChanged: (selectedLang) {
            languageProvider.setLanguage(selectedLang!);
          },
        ),
      ),
    );
  }
}
