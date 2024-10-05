// import 'package:flutter/material.dart';
// import 'package:nasaspaceapps/pages/home.dart';
// import 'package:nasaspaceapps/providers/bottomnav.dart';
// import 'package:provider/provider.dart';

// class MyWidget extends StatelessWidget {
//   final List<Widget> _pages = [
//     MyHomePage(),
//     Center(child: Text('Page 2')),
//     Center(child: Text('Page 3')),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (context) => BottomNavBarProvider(), // Create the provider locally
//       child: Consumer<BottomNavBarProvider>(
//         builder: (context, bottomNavBarProvider, child) {
//           return Scaffold(
//             body: _pages[bottomNavBarProvider.currentIndex], // Display the current page
//             bottomNavigationBar: BottomNavigationBar(
//               backgroundColor: Colors.white,
//               currentIndex: bottomNavBarProvider.currentIndex,
//               onTap: (index) {
//                 bottomNavBarProvider.updateIndex(index);
//               },
//               selectedItemColor: Colors.green, // Set selected item color
//               unselectedItemColor: Colors.grey, // Set unselected item color
//               selectedFontSize: 14,
//               unselectedFontSize: 12,
//               selectedLabelStyle: TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//               unselectedLabelStyle: TextStyle(
//                 fontWeight: FontWeight.normal,
//               ),
//               showUnselectedLabels: true,
//               items: [
//                 BottomNavigationBarItem(
//                   icon: _buildIcon(
//                     icon: Icons.home,
//                     isSelected: bottomNavBarProvider.currentIndex == 0,
//                   ),
//                   label: 'Home',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: _buildIcon(
//                     icon: Icons.business,
//                     isSelected: bottomNavBarProvider.currentIndex == 1,
//                   ),
//                   label: 'Business',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: _buildIcon(
//                     icon: Icons.school,
//                     isSelected: bottomNavBarProvider.currentIndex == 2,
//                   ),
//                   label: 'School',
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // Helper function to build icon with circle background for selected state
//   Widget _buildIcon({required IconData icon, required bool isSelected}) {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         if (isSelected)
//           Container(
//             width: 40, // Circle diameter
//             height: 40,
//             decoration: BoxDecoration(
//               color: Colors.green.withOpacity(0.2), // Circle color
//               shape: BoxShape.circle,
//             ),
//           ),
//         Icon(icon), // The actual icon
//       ],
//     );
//   }
// }
