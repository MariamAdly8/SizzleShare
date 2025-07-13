import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9), // Same color as app bar
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFFFFDF9), // Background color
        selectedItemColor:
            const Color(0xFFFD5D69), // Selected item color (pink)
        unselectedItemColor: Colors.grey, // Unselected item color
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        elevation: 0, // Remove default shadow
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Shopping',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Meal Prep',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class CustomBottomNavBar extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTap;

//   const CustomBottomNavBar({
//     Key? key,
//     required this.currentIndex,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: currentIndex,
//       onTap: onTap,
//       type: BottomNavigationBarType.fixed,
//       selectedItemColor: const Color(0xFFFD5D69),
//       unselectedItemColor: Colors.grey,
//       showSelectedLabels: true,
//       showUnselectedLabels: true,
//       selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
//       items: const [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home),
//           label: 'Home',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.shopping_cart),
//           label: 'Shopping',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.add_circle_outline),
//           label: 'Create',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.calendar_today),
//           label: 'Meal Prep',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.person),
//           label: 'Profile',
//         ),
//       ],
//     );
//   }
// }

// // custom_bottom_nav_bar.dart
// import 'package:flutter/material.dart';

// class CustomBottomNavBar extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTap;
//   final VoidCallback? onReload; // Add this

//   const CustomBottomNavBar({
//     Key? key,
//     required this.currentIndex,
//     required this.onTap,
//     this.onReload, // Add this
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BottomAppBar(
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           IconButton(
//             icon: Icon(Icons.home),
//             color: currentIndex == 0 ? Color(0xFFFD5D69) : Colors.grey,
//             onPressed: () {
//               if (onReload != null)
//                 onReload!(); // Call reload before navigation
//               onTap(0);
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.shopping_cart),
//             color: currentIndex == 1 ? Color(0xFFFD5D69) : Colors.grey,
//             onPressed: () {
//               if (onReload != null) onReload!();
//               onTap(1);
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.add_circle_outline),
//             color: currentIndex == 2 ? Color(0xFFFD5D69) : Colors.grey,
//             onPressed: () {
//               if (onReload != null) onReload!();
//               onTap(2);
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.calendar_today),
//             color: currentIndex == 3 ? Color(0xFFFD5D69) : Colors.grey,
//             onPressed: () {
//               if (onReload != null) onReload!();
//               onTap(3);
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.person),
//             color: currentIndex == 4 ? Color(0xFFFD5D69) : Colors.grey,
//             onPressed: () {
//               if (onReload != null) onReload!();
//               onTap(4);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
