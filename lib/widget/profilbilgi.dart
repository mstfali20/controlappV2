import 'package:controlapp/const/Color.dart';
import 'package:flutter/material.dart';

class ProfilbilgiWidget extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;

  const ProfilbilgiWidget(
      {super.key, required this.icon, required this.title, required this.value});

  @override
  _ProfilbilgiWidgetState createState() => _ProfilbilgiWidgetState();
}

class _ProfilbilgiWidgetState extends State<ProfilbilgiWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            widget.icon,
            color: blue,
          ),
          const SizedBox(width: 8),
          Text(
            '${widget.title}: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: blue,
            ),
          ),
          Expanded(
            child: Text(
              widget.value, // Eğer değer null ise boş string göster
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
