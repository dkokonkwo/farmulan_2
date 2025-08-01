import 'package:farmulan/utils/constants/icons.dart';
import 'package:flutter/material.dart';

import '../utils/constants/colors.dart';

class ChartDropdown extends StatefulWidget {
  final ValueChanged<int> onChange;
  const ChartDropdown({super.key, required this.onChange});

  @override
  State<ChartDropdown> createState() => _ChartDropdownState();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class _ChartDropdownState extends State<ChartDropdown> {
  final List<String> titleList = <String>[
    'Temperature',
    'Humidity',
    'Soil Moisture',
    'Light Intensity',
  ];

  late final List<MenuEntry> menuEntries;

  String dropdownValue = '';

  @override
  void initState() {
    super.initState();
    dropdownValue = titleList.first;
    menuEntries = titleList.map((name) {
      return DropdownMenuEntry<String>(
        value: name,
        label: name,
        labelWidget: Text(
          name,
          style: TextStyle(
            fontFamily: 'Zen Kaku Gothic Antique',
            fontSize: 17,
            color: AppColors.regularText,
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2.6),
      width: width / 2.5,
      decoration: BoxDecoration(
        color: Color(0xffDBE0E7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton(
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        isExpanded: true,
        borderRadius: BorderRadius.circular(22),
        icon: Icon(
          AppIcons.downArrow,
          color: AppColors.regularText.withValues(alpha: 0.6),
        ),
        iconSize: 20,
        dropdownColor: Colors.white,
        menuWidth: width / 2.4,
        value: dropdownValue,
        items: List.generate(
          titleList.length,
          (index) => DropdownMenuItem<String>(
            value: titleList[index],
            child: Text(
              titleList[index],
              style: TextStyle(
                fontFamily: 'Zen Kaku Gothic Antique',
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: AppColors.regularText.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
        onChanged: (String? newValue) {
          if (newValue != null) {
            final index = titleList.indexOf(newValue);
            widget.onChange(index);
            setState(() {
              dropdownValue = newValue;
            });
          }
        },
      ),
    );
  }
}
