import 'package:carousel_slider/carousel_slider.dart';
import 'package:farmulan_2/home/home_banner.dart';
import 'package:farmulan_2/utils/constants/colors.dart';
import 'package:farmulan_2/utils/constants/sensor_chart.dart';
import 'package:flutter/material.dart';

class HomeCarousel extends StatefulWidget {
  const HomeCarousel({super.key});

  @override
  State<HomeCarousel> createState() => _HomeCarouselState();
}

class _HomeCarouselState extends State<HomeCarousel> {
  int _currentIndex = 0;

  final List<Widget> _items = const [HomeBanner(), ChartWrapper()];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height / (844 / 215);
    return Column(
      children: [
        CarouselSlider(
          items: _items,
          options: CarouselOptions(
            clipBehavior: Clip.none,
            height: height,
            enlargeCenterPage: true,
            enlargeFactor: 0.2,
            viewportFraction: 0.9,
            autoPlay: true,
            autoPlayAnimationDuration: Duration(milliseconds: 1500),
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        const SizedBox(height: 35),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_items.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentIndex == index ? 20 : 10,
              height: 8,
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? AppColors.white
                    : AppColors.subheadingText,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class ChartWrapper extends StatefulWidget {
  const ChartWrapper({super.key});

  @override
  State<ChartWrapper> createState() => _ChartWrapperState();
}

class _ChartWrapperState extends State<ChartWrapper> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: 0,
            color: AppColors.primary.withValues(alpha: 0.13),
          ),
        ],
      ),
      child: LineChartSample2(),
    );
  }
}
