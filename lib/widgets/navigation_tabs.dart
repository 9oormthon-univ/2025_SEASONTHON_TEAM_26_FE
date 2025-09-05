import 'package:flutter/material.dart';

class NavigationTabs extends StatelessWidget {
  final VoidCallback? onBusStatusPressed;
  final VoidCallback? onBusApplicationPressed;
  final bool isBusApplicationSelected;

  const NavigationTabs({
    super.key,
    this.onBusStatusPressed,
    this.onBusApplicationPressed,
    this.isBusApplicationSelected = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 버스 현황 탭
        Expanded(
          child: GestureDetector(
            onTap: onBusStatusPressed,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: isBusApplicationSelected ? Colors.white : Color(0xFFF97316),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0xFFF97316), width: 1),
              ),
              child: Center(
                child: Text(
                  '버스 현황',
                  style: TextStyle(
                    color: isBusApplicationSelected ? Color(0xFFF97316) : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        // 버스 신청 탭
        Expanded(
          child: GestureDetector(
            onTap: onBusApplicationPressed,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: isBusApplicationSelected ? Color(0xFFF97316) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Color(0xFFF97316), width: 1),
              ),
              child: Center(
                child: Text(
                  '버스 신청',
                  style: TextStyle(
                    color: isBusApplicationSelected ? Colors.white : Color(0xFFF97316),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
