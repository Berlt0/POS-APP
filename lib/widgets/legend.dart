import 'package:flutter/material.dart';
import 'package:pos_app/utils/responsive.dart';



class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: Responsive.font(context, mobile: 13, tablet: 13, desktop: 14),fontWeight: FontWeight.w500, color: Colors.black)),
      ],
    );
  }
}
