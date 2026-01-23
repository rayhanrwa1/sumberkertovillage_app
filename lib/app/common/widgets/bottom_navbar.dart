import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:sumberkerto_smart_village/app/core/const/color_const.dart';
import 'package:sumberkerto_smart_village/app/core/const/google_text_style_const.dart';

class TBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const TBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  void _onTapItem(int index) {
    if (index == currentIndex) return;
    onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TColorsConst.white,
        boxShadow: [
          BoxShadow(
            color: TColorsConst.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _item(
                index: 0,
                label: 'Beranda',
                icon: PhosphorIcons.house(PhosphorIconsStyle.bold),
                iconFilled: PhosphorIcons.house(PhosphorIconsStyle.fill),
              ),
              _item(
                index: 1,
                label: 'Riwayat',
                icon: PhosphorIcons.clockCounterClockwise(
                  PhosphorIconsStyle.bold,
                ),
                iconFilled: PhosphorIcons.clockCounterClockwise(
                  PhosphorIconsStyle.fill,
                ),
              ),
              _item(
                index: 2,
                label: 'Profile',
                icon: PhosphorIcons.user(PhosphorIconsStyle.bold),
                iconFilled: PhosphorIcons.user(PhosphorIconsStyle.fill),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item({
    required int index,
    required String label,
    required IconData icon,
    required IconData iconFilled,
  }) {
    final bool isActive = index == currentIndex;

    return Expanded(
      child: InkWell(
        onTap: () => _onTapItem(index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? TColorsConst.blue500.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? iconFilled : icon,
                size: 24,
                color: isActive
                    ? TColorsConst.blue500
                    : TColorsConst.neutral400,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TGoogleTextStyleConst.inter14Medium.copyWith(
                  color: isActive
                      ? TColorsConst.blue500
                      : TColorsConst.neutral400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
