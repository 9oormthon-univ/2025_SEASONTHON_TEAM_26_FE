import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.appBarBackground,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          children: [
            // 버스 현황 탭 (비활성화)
            Expanded(
              child: GestureDetector(
                onTap: onBusStatusPressed,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surface, // Neutral/Ivory-300
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary, width: 1), // Primary 테두리
                  ),
                  child: Center(
                    child: Text(
                      '버스 현황',
                      style: AppTextStyles.navigatorTabInactive, // 두번째 폰트 스타일
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            // 버스 신청 탭 (활성화)
            Expanded(
              child: GestureDetector(
                onTap: onBusApplicationPressed,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary, // Primary/Orange-500
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      '버스 신청',
                      style: AppTextStyles.navigatorTab, // 첫번째 폰트 스타일
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
