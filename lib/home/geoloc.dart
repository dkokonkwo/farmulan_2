// import 'package:farmulan_2/utils/constants/colors.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
//
// class GeoLocator extends StatefulWidget {
//   const GeoLocator({super.key});
//
//   @override
//   State<GeoLocator> createState() => _GeoLocatorState();
// }
//
// class _GeoLocatorState extends State<GeoLocator> {
//   String _location = 'Fetching location....';
//
//   @override
//   void initState() {
//     super.initState();
//     _getLocation();
//   }
//
//   Future<void> _getLocation() async {
//     // 1. Are services enabled?
//     if (!await Geolocator.isLocationServiceEnabled()) {
//       setState(() => _location = 'Location services are disabled.');
//       return;
//     }
//
//     // 2. Check/request permission
//     var permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied ||
//         permission == LocationPermission.deniedForever) {
//       permission = await Geolocator.requestPermission();
//     }
//
//     // 3. If still not granted, bail out
//     if (permission != LocationPermission.always &&
//         permission != LocationPermission.whileInUse) {
//       setState(() => _location = 'Location permission denied.');
//       return;
//     }
//
//     // 4. Finally, fetch the position
//     try {
//       final pos = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       setState(() {
//         _location = 'Latitude: ${pos.latitude}, Longitude: ${pos.longitude}';
//       });
//     } catch (e) {
//       setState(() => _location = 'Error retrieving location: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: AppColors.primaryRed,
//       padding: EdgeInsets.all(8),
//       child: Text(
//         _location,
//         style: TextStyle(fontSize: 20),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
// }
