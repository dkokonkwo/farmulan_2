import 'package:farmulan/utils/constants/colors.dart';
import 'package:farmulan/utils/constants/icons.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';

class BottomButtons extends StatefulWidget {
  final ValueChanged<int> changeIndex;
  const BottomButtons({super.key, required this.changeIndex});

  @override
  State<BottomButtons> createState() => _BottomButtonsState();
}

class _BottomButtonsState extends State<BottomButtons> {
  final List<IconData> iconsList = [
    AppIcons.temp,
    AppIcons.bulb,
    AppIcons.drop,
    AppIcons.calendar,
  ];
  final List<String> iconTitles = ['TEMP', 'LIGHT', 'MOISTURE', 'SCHEDULE'];
  int _currentIndex = 0;

  void toggleButton(int index) {
    setState(() {
      _currentIndex = index;
    });
    widget.changeIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Wrap(
        spacing: 15,
        children: List.generate(iconsList.length, (index) {
          return Column(
            spacing: 5,
            children: [
              GestureDetector(
                onTap: () => toggleButton(index),
                child: NeumorphicBottomButton(
                  icon: iconsList[index],
                  isSelected: _currentIndex == index,
                ),
              ),
              Text(
                iconTitles[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.regularText.withValues(alpha: 0.7),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class NeumorphicBottomButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  const NeumorphicBottomButton({
    super.key,
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width / 8.2;
    BoxShadow filler = BoxShadow(
      color: AppColors.contentColorBlack.withValues(alpha: 0),
      offset: Offset(0, 0),
      blurRadius: 0,
      spreadRadius: 0,
    );
    return Container(
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color(0xff99A0A9).withValues(alpha: 0.8),
            AppColors.white.withValues(alpha: 0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xff8E9BAE).withValues(alpha: 0.1),
            offset: Offset(4, 4),
            blurRadius: 15,
            spreadRadius: 0,
          ),
        ],
      ),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(isSelected ? 0.5 : 3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.contentColorBlack.withValues(alpha: 0.3),
                    AppColors.contentColorBlack.withValues(alpha: 0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Color(0xff8E9BAE).withValues(alpha: isSelected ? 0.2 : 0),
              offset: Offset(0, 9),
              blurRadius: 18,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: AppColors.white.withValues(alpha: isSelected ? 0.5 : 0),
              offset: Offset(1, 1),
              blurRadius: 2,
              spreadRadius: 0,
              inset: true,
            ),
          ],
        ),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.all(isSelected ? 7.5 : 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isSelected
                  ? [Color(0xff6197a8), Color(0xFF49DA57)]
                  : [AppColors.bottomShadow, AppColors.bottomShadow],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [filler, filler],
          ),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            height: width,
            width: width,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isSelected
                    ? [AppColors.primaryPurple, AppColors.primaryRed]
                    : [AppColors.bottomShadow, AppColors.bottomShadow],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [filler, filler],
            ),
            child: Center(
              child: Icon(
                icon,
                color: isSelected
                    ? AppColors.white
                    : AppColors.regularText.withValues(alpha: 0.5),
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
