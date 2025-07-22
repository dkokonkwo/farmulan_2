import 'package:farmulan/utils/constants/colors.dart';
import 'package:farmulan/utils/constants/icons.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';

class PlantDetailsAppBar extends StatefulWidget implements PreferredSizeWidget {
  final List<String> plantInfo;
  const PlantDetailsAppBar({super.key, required this.plantInfo});

  @override
  State<PlantDetailsAppBar> createState() => _PlantDetailsAppBarState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(80);
}

class _PlantDetailsAppBarState extends State<PlantDetailsAppBar> {
  void doSomething() {}
  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 80,
      backgroundColor: AppColors.pageBackground,
      centerTitle: true,
      leading: Center(
        child: NeumorphicButton(
          icon: AppIcons.leftArrow,
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        widget.plantInfo[0],
        style: 
           TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.pageHeadingText,
          ),
      ),
      actions: [
        NeumorphicButton(
          icon: AppIcons.info,
          onTap: () => showInfoDialog(context, widget.plantInfo),
        ),
        SizedBox(width: 20),
      ],
    );
  }
}

class NeumorphicButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const NeumorphicButton({super.key, required this.icon, required this.onTap});

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const bgColor = AppColors.pageBackground;
    const offset = Offset(4, 4);
    const blur = 8.0;
    final radius = BorderRadius.circular(10);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: radius,
          color: bgColor,
          boxShadow: [
            BoxShadow(
              color: AppColors.topShadow,
              blurRadius: blur,
              offset: -offset,
              inset: _pressed,
            ),
            BoxShadow(
              color: AppColors.bottomShadow,
              blurRadius: blur,
              offset: offset,
              inset: _pressed,
            ),
          ],
        ),
        child: Icon(
          widget.icon,
          color: AppColors.regularText.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

void showInfoDialog(BuildContext context, List<String> plantInfo) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: AppColors.pageBackground,
      title: Row(
        spacing: 10,
        children: [
          Icon(AppIcons.leaf, color: AppColors.regularText),
          Text(
            plantInfo[0],
            style: 
               TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.regularText,
              ),
          ),
        ],
      ),
      content: Row(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [AppColors.primaryPurple, AppColors.primaryRed],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: Icon(AppIcons.watch),
          ),
          SizedBox(width: 7),
          Text(
            'Growth Stage',
            style: 
               TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.regularText.withValues(alpha: 0.5),
              ),

          ),
          SizedBox(width: 15),
          Text(
            plantInfo[2],
            style: 
               TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.regularText.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
      actions: <Widget>[
        Text(
          'Planted ${plantInfo[1]} days ago',
          style: 
             TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.regularText,
              fontStyle: FontStyle.italic,
            ),
        ),
      ],
    ),
  );
}
