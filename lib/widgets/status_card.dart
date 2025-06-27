import 'package:flutter/material.dart';

Widget StatusCard({
  required String title,
  required int count,
  required bool isActive,
  required VoidCallback onTap,
  required Color color,
}) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.grey,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
