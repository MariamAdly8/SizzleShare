// import 'package:flutter/material.dart';
// import 'package:sizzle_share/pages/LoginPage.dart';
// import 'package:sizzle_share/pages/SignupPage.dart';
// import 'package:sizzle_share/pages/splash_screen.dart';
// import 'package:sizzle_share/widgets/background_wrapper.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       builder: (context, child) {
//         return BackgroundWrapper(
//           child: Scaffold(
//             backgroundColor: Colors.transparent,
//             body: child,
//           ),
//         );
//       },
//       theme: ThemeData(
//         cardTheme: CardTheme(
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       ),
//       debugShowCheckedModeBanner: false,
//       home: SignupPage(),
//       // home: HomePage(),
//       // home: SplashScreen(),
//             // home: LoginPage(),

//       // home: ProfileScreen(),

//       // home: RecipeDetailPage(recipeId: '68196a6ce5ee43c0be0881f1'),

//       // home: const RecipeDetailPage(recipeId: '68196a6ce5ee43c0be0881f1'),
//       // home: const RecipeDetailPage(recipeId: '68196a6ce5ee43c0be0881ec'),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:sizzle_share/pages/LoginPage.dart';
import 'package:sizzle_share/pages/ProfilePage.dart';
import 'package:sizzle_share/pages/SignupPage.dart';
import 'package:sizzle_share/pages/splash_screen.dart';
import 'package:sizzle_share/providers/recipe_status_provider/recipe_status_provider.dart';
import 'package:sizzle_share/widgets/background_wrapper.dart';

void main() {
  runApp(Phoenix(child:const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecipeStatusProvider()),
      ],
      child: MaterialApp(
        builder: (context, child) {
          return BackgroundWrapper(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: child,
            ),
          );
        },
        theme: ThemeData(
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        // home: SignupPage(),
        // home: HomePage(),
        home: SplashScreen(),
        // home: LoginPage(),

        // home: ProfileScreen(),

        // home: RecipeDetailPage(recipeId: '68196a6ce5ee43c0be0881f1'),

        // home: const RecipeDetailPage(recipeId: '68196a6ce5ee43c0be0881f1'),
        // home: const RecipeDetailPage(recipeId: '68196a6ce5ee43c0be0881ec'),
      ),
    );
  }
}
