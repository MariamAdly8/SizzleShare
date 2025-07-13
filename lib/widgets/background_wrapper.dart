import 'package:flutter/material.dart';

class BackgroundWrapper extends StatelessWidget {
  final Widget child;
  final String imagePath;

  const BackgroundWrapper({
    super.key,
    required this.child,
    this.imagePath = 'assets/images/bg.png', // Your default background
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
            child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          cacheWidth: (MediaQuery.of(context).size.width * 2).toInt(),
        )),
        // Semi-transparent overlay (optional)
        Positioned.fill(
          child: Container(
            color: Colors.white.withOpacity(0.1), // Adjust opacity as needed
          ),
        ),
        // Your content
        child,
      ],
    );
  }
}


// import 'package:flutter/material.dart';

// class BackgroundWrapper extends StatelessWidget {
//   final Widget child;
//   final String imagePath;

//   const BackgroundWrapper({
//     super.key,
//     required this.child,
//     this.imagePath = 'assets/images/bg.png', // Your default background
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       type: MaterialType.transparency, // Preserves transparency
//       child: Stack(
//         children: [
//           // Background Image
//           Positioned.fill(
//             child: Image.asset(
//               imagePath,
//               fit: BoxFit.cover,
//               cacheWidth: (MediaQuery.of(context).size.width * 2).toInt(),
//             ),
//           ),
//           // Semi-transparent overlay (optional)
//           Positioned.fill(
//             child: Container(
//               color: Colors.white.withOpacity(0.1), // Adjust opacity as needed
//             ),
//           ),
//           // Your content
//           child,
//         ],
//       ),
//     );
//   }
// }