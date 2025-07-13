import 'package:flutter/material.dart';
import 'package:sizzle_share/pages/search_page.dart';

class SearchButton extends StatefulWidget {
  final double size;

  const SearchButton({
    super.key,
    this.size = 36.0,
  });

  @override
  State<SearchButton> createState() => _SearchButtonState();
}

class _SearchButtonState extends State<SearchButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  late Animation<double> _opacityAnimation;
  bool _isExpanded = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _sizeAnimation = Tween<double>(begin: widget.size, end: 200).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse().then((_) {
          if (_searchQuery.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(initialQuery: _searchQuery),
              ),
            );
          }
          _searchQuery = '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: _sizeAnimation.value,
          height: widget.size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: _isExpanded
              ? Row(
                  children: [
                    const SizedBox(width: 8),
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: TextField(
                          autofocus: true,
                          decoration: const InputDecoration(
                            hintText: 'Search recipes...',
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            _searchQuery = value;
                          },
                          onSubmitted: (value) {
                            _toggleSearch();
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _toggleSearch,
                    ),
                  ],
                )
              : IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _toggleSearch,
                ),
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:sizzle_share/pages/search_page.dart';

// class SearchButton extends StatefulWidget {
//   final double size;

//   const SearchButton({
//     super.key,
//     this.size = 36.0,
//   });

//   @override
//   State<SearchButton> createState() => _SearchButtonState();
// }

// class _SearchButtonState extends State<SearchButton>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _sizeAnimation;
//   late Animation<double> _opacityAnimation;
//   bool _isExpanded = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );

//     _sizeAnimation = Tween<double>(begin: widget.size, end: 200).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: Curves.easeInOut,
//       ),
//     );

//     _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: Curves.easeIn,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void _toggleSearch() {
//     setState(() {
//       _isExpanded = !_isExpanded;
//       if (_isExpanded) {
//         _controller.forward();
//       } else {
//         _controller.reverse().then((_) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const SearchScreen()),
//           );
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return Container(
//           width: _sizeAnimation.value,
//           height: widget.size,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 10,
//                 spreadRadius: 2,
//               ),
//             ],
//           ),
//           child: _isExpanded
//               ? Row(
//                   children: [
//                     const SizedBox(width: 8),
//                     const Icon(Icons.search, color: Colors.grey),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Opacity(
//                         opacity: _opacityAnimation.value,
//                         child: TextField(
//                           autofocus: true,
//                           decoration: const InputDecoration(
//                             hintText: 'Search recipes...',
//                             border: InputBorder.none,
//                           ),
//                           onSubmitted: (value) {
//                             _toggleSearch();
//                           },
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: _toggleSearch,
//                     ),
//                   ],
//                 )
//               : IconButton(
//                   icon: const Icon(Icons.search),
//                   onPressed: _toggleSearch,
//                 ),
//         );
//       },
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:sizzle_share/pages/search_page.dart';

// class SearchButton extends StatelessWidget {
//   final VoidCallback onPressed;
//   final double size;

//   const SearchButton({
//     super.key,
//     required this.onPressed,
//     this.size = 36.0,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: size,
//       height: size,
//       child: IconButton(
//         icon: const Icon(Icons.search),
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const SearchScreen()),
//           );
//         },
//       ),
      // IconButton(
      //   padding: EdgeInsets.zero,
      //   onPressed: onPressed,
      //   icon: Container(
      //     padding: const EdgeInsets.all(8),
      //     decoration: const BoxDecoration(
      //       color: Color(0xFFFFC6C9),
      //       shape: BoxShape.circle,
      //     ),
      //     child: const Icon(
      //       Icons.search_rounded,
      //       color: Color(0xFFEC888D),
      //       size: 20,
      //     ),
      //   ),
      // ),
//     );
//   }
// }
