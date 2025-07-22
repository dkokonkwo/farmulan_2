import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';

import '../utils/constants/colors.dart';

class ModalTab extends StatefulWidget {
  bool isSelected;
  final String title;
  ModalTab({super.key, required this.isSelected, required this.title});

  @override
  State<ModalTab> createState() => _ModalTabState();
}

class _ModalTabState extends State<ModalTab> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    Offset distance = Offset(4, 4);
    double blur = widget.isSelected ? 10 : 8;
    return AnimatedContainer(
      height: 43,
      width: width / 3.2,
      duration: Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: widget.isSelected ? AppColors.secondary : AppColors.darkGreen,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Color(0xff38445A),
            blurRadius: blur,
            offset: -distance,
            inset: !widget.isSelected,
          ),
          BoxShadow(
            blurRadius: blur,
            offset: distance,
            color: Color(0xff252B39),
            inset: !widget.isSelected,
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
            color: widget.isSelected
                ? AppColors.white
                : AppColors.white.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}

class ModalTabContainer extends StatefulWidget {
  const ModalTabContainer({super.key});

  @override
  State<ModalTabContainer> createState() => _ModalTabContainerState();
}

class _ModalTabContainerState extends State<ModalTabContainer> {
  List<bool> isSelected = [true, false];
  List<String> titles = ['Info', 'Farm Data'];
  int selectedIndex = 0;

  void switchTabs(int index) {
    for (int i = 0; i < isSelected.length; i++) {
      setState(() {
        selectedIndex = index;
        for (int i = 0; i < isSelected.length; i++) {
          isSelected[i] = i == index;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      child: Column(
        children: [
          SizedBox(
            width: width / 1.4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => switchTabs(0),
                  child: ModalTab(isSelected: isSelected[0], title: titles[0]),
                ),
                GestureDetector(
                  onTap: () => switchTabs(1),
                  child: ModalTab(isSelected: isSelected[1], title: titles[1]),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: width,
            child: IndexedStack(
              index: selectedIndex,
              children: [Text('Info data'), Text('Farm data')],
            ),
          ),
        ],
      ),
    );
  }
}
