import 'dart:convert';
import 'dart:io'; // Add this import for Platform class
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart'; // to detect file type

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:sizzle_share/models/comment.dart';
import 'package:sizzle_share/models/mealPlanner.dart';
import 'package:sizzle_share/models/recipe.dart';
import 'package:sizzle_share/models/recipeStatus.dart';
import 'package:sizzle_share/models/user.dart';
import 'package:sizzle_share/providers/recipe_status_provider/recipe_status_provider.dart';

int counter = 0;
ValueNotifier<Recipe?> rateChange = ValueNotifier<Recipe?>(null);

class ApiService {
  late Dio dio;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  String? _authToken;

  // Base URLs
  static const String userBaseUrl = 'http://192.168.1.181:3000/api/users';
  static const String recipeBaseUrl = 'http://192.168.1.181:3000/api/recipes';
  static const String favoritesBaseUrl = 'http://192.168.1.181:3000/users';
  static const String commentBaseUrl = 'http://192.168.1.181:3000/api/comments';
  static const String mealPlannerBaseUrl =
      'http://192.168.1.181:3000/api/mealplanner';
  ApiService() {
    dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<void> init() async {
    _authToken = null;

    _authToken = await storage.read(key: 'jwt_token');
    if (_authToken != null) {
      dio.options.headers['Authorization'] = 'Bearer $_authToken';
    }
  }

// --------------------user-----------------

  // Future<void> initiateSignup({
  //   required String name,
  //   required String email,
  //   required String password,
  //   String? userAvatar,
  //   List<String> allergyOptions = const [],
  //   List<String> preferenceOptions = const [],
  // }) async {
  //   try {
  //     final response = await dio.post(
  //       '$userBaseUrl/signup',
  //       data: {
  //         'name': name,
  //         'email': email,
  //         'password': password,
  //         'userAvatar': userAvatar ?? 'default-avatar',
  //         'allergyOptions': allergyOptions,
  //         'preferenceOptions': preferenceOptions,
  //       },
  //     );

  //     if (response.statusCode != 200) {
  //       throw Exception(
  //           response.data['message'] ?? 'Failed to initiate signup');
  //     }
  //   } on DioException catch (e) {
  //     // Handle email already exists case
  //     if (e.response?.data['message']
  //             ?.toString()
  //             .toLowerCase()
  //             .contains('already exists') ??
  //         false) {
  //       throw Exception(
  //           'This email is already registered. Please use a different email or log in.');
  //     }
  //     // Special handling for "already sent" case
  //     if (e.response?.data['message']?.contains('already been sent') ?? false) {
  //       return; // Not an error for our flow
  //     }
  //     throw Exception(
  //         e.response?.data['message'] ?? 'Signup initiation failed');
  //   }
  // }

  // Future<(User, String)> verifyEmailWithOtp({
  //   required String email,
  //   required String otp,
  // }) async {
  //   try {
  //     // Create a clean Dio instance without auth headers
  //     final cleanDio = Dio();
  //     cleanDio.options.connectTimeout = const Duration(seconds: 30);
  //     cleanDio.options.receiveTimeout = const Duration(seconds: 30);

  //     final response = await cleanDio.post(
  //       '$userBaseUrl/verify-email',
  //       data: {
  //         'email': email.trim().toLowerCase(),
  //         'code': otp,
  //       },
  //     );

  //     if (response.statusCode == 201) {
  //       final data = response.data as Map<String, dynamic>;
  //       final token = data['token'] as String;
  //       final user = User.fromJson(data['user']);

  //       // Store token for future requests
  //       _authToken = token;
  //       await storage.write(key: 'jwt_token', value: token);
  //       setAuthToken(token);

  //       return (user, token);
  //     } else {
  //       throw Exception(response.data['message'] ?? 'Verification failed');
  //     }
  //   } on DioException catch (e) {
  //     throw Exception(e.response?.data['message'] ??
  //         'Failed to verify email. Please try again.');
  //   }
  // }

  // Future<void> resendVerificationCode(String email) async {
  //   try {
  //     // Create a clean Dio instance without auth headers
  //     final cleanDio = Dio();
  //     cleanDio.options.connectTimeout = const Duration(seconds: 30);
  //     cleanDio.options.receiveTimeout = const Duration(seconds: 30);

  //     await cleanDio.post(
  //       '$userBaseUrl/resend-verification-code',
  //       data: {'email': email.trim().toLowerCase()},
  //     );
  //   } on DioException catch (e) {
  //     throw Exception(
  //         e.response?.data['message'] ?? 'Failed to resend verification code');
  //   }
  // }

  // b3d akher ta3del
  // Future<void> initiateSignup({
  //   required String name,
  //   required String email,
  //   required String password,
  //   String? userAvatar,
  //   List<String> allergyOptions = const [],
  //   List<String> preferenceOptions = const [],
  // }) async {
  //   try {
  //     final response = await dio.post(
  //       '$userBaseUrl/signup',
  //       data: {
  //         'name': name,
  //         'email': email,
  //         'password': password,
  //         'userAvatar': userAvatar ?? 'default-avatar',
  //         'allergyOptions': allergyOptions,
  //         'preferenceOptions': preferenceOptions,
  //       },
  //     );

  //     if (response.statusCode != 200) {
  //       throw Exception(
  //           response.data['message'] ?? 'Failed to initiate signup');
  //     }
  //   } on DioException catch (e) {
  //     // Handle email validation errors
  //     if (e.response?.data['message']?.toString().contains('not valid') ??
  //         false) {
  //       throw Exception('Please use a valid email address');
  //     }
  //     // Handle email already exists case
  //     if (e.response?.data['message']
  //             ?.toString()
  //             .toLowerCase()
  //             .contains('already registered') ??
  //         false) {
  //       throw Exception('This email is already registered. Please log in.');
  //     }
  //     // Handle pending verification case
  //     if (e.response?.data['message']?.contains('already been sent') ?? false) {
  //       throw Exception(
  //           'A verification code was already sent. Please check your email or wait before requesting a new one.');
  //     }
  //     throw Exception(
  //         e.response?.data['message'] ?? 'Signup initiation failed');
  //   }
  // }
  // Future<void> initiateSignup({
  //   required String name,
  //   required String email,
  //   required String password,
  //   String? userAvatar,
  //   List<String> allergyOptions = const [],
  //   List<String> preferenceOptions = const [],
  // }) async {
  //   try {
  //     final response = await dio.post(
  //       '$userBaseUrl/signup',
  //       data: {
  //         'name': name,
  //         'email': email,
  //         'password': password,
  //         'userAvatar': userAvatar ?? 'default-avatar',
  //         'allergyOptions': allergyOptions,
  //         'preferenceOptions': preferenceOptions,
  //       },
  //     );

  //     if (response.statusCode != 200) {
  //       throw Exception(
  //           response.data['message'] ?? 'Failed to initiate signup');
  //     }
  //   } on DioException catch (e) {
  //     // Handle email validation errors
  //     if (e.response?.data['message']?.toString().contains('not valid') ??
  //         false) {
  //       throw Exception('Please use a valid email address');
  //     }
  //     // Handle email already exists case
  //     if (e.response?.data['message']
  //             ?.toString()
  //             .toLowerCase()
  //             .contains('already registered') ??
  //         false) {
  //       throw Exception('This email is already registered. Please log in.');
  //     }
  //     // Handle pending verification case
  //     if (e.response?.data['message']?.contains('already been sent') ?? false) {
  //       // Only allow proceeding if the email exists
  //       if (e.response?.statusCode == 200) {
  //         return; // Not an error for our flow
  //       }
  //       throw Exception(
  //           'A verification code was already sent. Please check your email or wait before requesting a new one.');
  //     }
  //     throw Exception(
  //         e.response?.data['message'] ?? 'Signup initiation failed');
  //   }
  // }

  Future<void> initiateSignup({
    required String name,
    required String email,
    required String password,
    String? userAvatar,
    List<String> allergyOptions = const [],
    List<String> preferenceOptions = const [],
  }) async {
    try {
      final response = await dio.post(
        '$userBaseUrl/signup',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'userAvatar': userAvatar ?? 'default-avatar',
          'allergyOptions': allergyOptions,
          'preferenceOptions': preferenceOptions,
        },
      );

      // Only consider status code 200 as success
      if (response.statusCode == 200) {
        return;
      }
      // For any other status code, throw an exception
      throw Exception(response.data['message'] ?? 'Failed to initiate signup');
    } on DioException catch (e) {
      // Handle email validation errors
      if (e.response?.statusCode == 400) {
        if (e.response?.data['message']?.toString().contains('not valid') ??
            false) {
          throw Exception('Please use a valid email address');
        }
        if (e.response?.data['message']
                ?.toString()
                .toLowerCase()
                .contains('already registered') ??
            false) {
          throw Exception('This email is already registered. Please log in.');
        }
        if (e.response?.data['message']
                ?.toString()
                .contains('Invalid email format') ??
            false) {
          throw Exception('Please enter a valid email address');
        }
      }
      // Handle pending verification case
      if (e.response?.data['message']?.contains('already been sent') ?? false) {
        // Only allow proceeding if the email exists
        if (e.response?.statusCode == 200) {
          return; // Not an error for our flow
        }
        throw Exception(
            'A verification code was already sent. Please check your email or wait before requesting a new one.');
      }
      throw Exception(
          e.response?.data['message'] ?? 'Signup initiation failed');
    }
  }

  Future<(User, String)> verifyEmailWithOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final cleanDio = Dio();
      cleanDio.options.connectTimeout = const Duration(seconds: 30);
      cleanDio.options.receiveTimeout = const Duration(seconds: 30);

      final response = await cleanDio.post(
        '$userBaseUrl/verify-email',
        data: {
          'email': email.trim().toLowerCase(),
          'code': otp,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final token = data['token'] as String;
        final user = User.fromJson(data['user']);

        _authToken = token;
        await storage.write(key: 'jwt_token', value: token);
        setAuthToken(token);

        return (user, token);
      } else {
        throw Exception(response.data['message'] ?? 'Verification failed');
      }
    } on DioException catch (e) {
      // Handle specific error cases
      if (e.response?.data['message']
              ?.toString()
              .contains('Invalid or expired') ??
          false) {
        throw Exception(
            'The code is invalid or has expired. Please request a new one.');
      }
      throw Exception(e.response?.data['message'] ??
          'Failed to verify email. Please try again.');
    }
  }

  Future<void> resendVerificationCode(String email) async {
    try {
      final cleanDio = Dio();
      cleanDio.options.connectTimeout = const Duration(seconds: 30);
      cleanDio.options.receiveTimeout = const Duration(seconds: 30);

      final response = await cleanDio.post(
        '$userBaseUrl/resend-verification-code',
        data: {'email': email.trim().toLowerCase()},
      );

      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to resend code');
      }
    } on DioException catch (e) {
      if (e.response?.data['message']
              ?.toString()
              .contains('No pending signup') ??
          false) {
        throw Exception(
            'No pending verification found. Please start the signup process again.');
      }
      throw Exception(
          e.response?.data['message'] ?? 'Failed to resend verification code');
    }
  }

// //nosa
//   Future<(User, String)> signupUser({
//     required String name,
//     required String email,
//     required String password,
//     String? userAvatar,
//     List<String>? allergyOptions,
//     List<String>? preferenceOptions,
//   }) async {
//     try {
//       final response = await dio.post(
//         '$userBaseUrl/signup',
//         data: {
//           'name': name.trim(),
//           'email': email.trim().toLowerCase(),
//           'password': password,
//           if (userAvatar != null) 'userAvatar': userAvatar,
//           'allergyOptions': allergyOptions ?? [],
//           'preferenceOptions': preferenceOptions ?? [],
//         },
//         options: Options(headers: {'Content-Type': 'application/json'}),
//       );

//       final responseData = response.data as Map<String, dynamic>;
//       final token = responseData['token'] as String;

//       // Save the token and set it in the Dio instance
//       await storage.write(key: 'jwt_token', value: token);
//       setAuthToken(token);

//       return (
//         User.fromJson(responseData['user']),
//         token,
//       );
//     } on DioException catch (e) {
//       if (e.response?.statusCode == 400) {
//         final message = e.response?.data['message'] ?? 'Validation failed';
//         throw Exception(message);
//       }
//       rethrow;
//     }
//   }

  Future<(User, String)> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '$userBaseUrl/login',
        data: {
          'email': email.trim().toLowerCase(),
          'password': password.trim(),
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final data = response.data as Map<String, dynamic>;
      print('Login response: $data');

      final token = data['token'];
      if (token == null || token is! String) {
        throw Exception('Token missing from login response');
      }

      final userJson = data['user'];
      if (userJson == null) {
        throw Exception('User data missing from login response');
      }

      final user = User.fromJson(userJson);
      _authToken = token;
      await storage.write(key: 'jwt_token', value: token);
      setAuthToken(token);

      return (user, token);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Login failed';
      throw Exception(message);
    }
  }

  Future<void> logout(context) async {
    Phoenix.rebirth(context);
    await storage.delete(key: 'jwt_token');
    _authToken = null;
    dio.options.headers.remove('Authorization');
  }

  void setAuthToken(String? token) {
    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      dio.options.headers.remove('Authorization');
    }
  }

  Future<Response> authenticatedRequest(
    String method,
    String endpoint, {
    dynamic data,
  }) async {
    final token = _authToken ?? await storage.read(key: 'jwt_token');
    print('token:');
    print(token);
    return dio.request(
      '$userBaseUrl/$endpoint',
      data: data,
      options: Options(
        method: method,
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
  }

  Future<void> _ensureAuthenticated() async {
    if (_authToken == null) {
      _authToken = await storage.read(key: 'jwt_token');
      if (_authToken != null) {
        print('tokenData:');
        print(_authToken.toString());
        dio.options.headers['Authorization'] = 'Bearer $_authToken';
      } else {
        throw Exception('No authentication token, access denied');
      }
    }
  }

  Future<User> getCurrentUser() async {
    try {
      await _ensureAuthenticated();
      final response = await dio.get('$userBaseUrl/me');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
          'Failed to fetch current user: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<void> toggleFavorite(String recipeId) async {
    try {
      await _ensureAuthenticated();
      // await dio.put(

      //   '$userBaseUrl/favorite',
      //   data: {'recipeId': recipeId},
      // );
      await dio.post(
        '$userBaseUrl/favorites/toggle',
        data: {'recipeId': recipeId},
      );
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to toggle favorite');
    }
  }

  Future<List<Recipe>> getFavoriteRecipes() async {
    try {
      await _ensureAuthenticated();

      // Get list of user's favorite recipes (IDs)
      final favResponse = await dio.get('$userBaseUrl/favorites');
      final favorites = favResponse.data['favorites'] as List<dynamic>? ?? [];

      final recipeIds =
          favorites.map((fav) => fav['recipeId'].toString()).toList();

      List<Recipe> fullRecipes = [];

      for (final id in recipeIds) {
        try {
          final res = await dio.get('$recipeBaseUrl/$id');
          fullRecipes.add(Recipe.fromJson(res.data));
        } catch (_) {
          // Skip broken or deleted recipes
          continue;
        }
      }

      return fullRecipes;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch favorite recipes');
    }
  }

  Future<Map<String, dynamic>> getFavoriteStatusAndRating(
      String recipeId) async {
    try {
      await _ensureAuthenticated(); // Ensure token is available

      final response = await dio.get('$userBaseUrl/favorites/status/$recipeId');
      print('favourite1::');
      print(response.toString());
      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'isFavorite': data['isFavorite'] ?? false,
          'userRating': (data['userRating'] != null)
              ? (data['userRating'] as num).toDouble()
              : 0.0,
        };
      } else {
        throw Exception('Failed to get favorite status and rating');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch status');
    }
  }

  Future<User> getUserById(String userId) async {
    try {
      await _ensureAuthenticated(); // ensures token is available & attached

      final response = await dio.get('$userBaseUrl/$userId');

      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch user: ${e.message}',
      );
    }
  }

  Future<double> rateRecipe(String recipeId, double rate) async {
    try {
      await _ensureAuthenticated();

      final response = await dio.post(
        '$recipeBaseUrl/$recipeId/rate',
        data: {'rate': rate},
      );

      return (response.data['averageRate'] as num).toDouble();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to rate recipe');
    }
  }

  Future<Comment> createComment(String recipeId, String content) async {
    try {
      await _ensureAuthenticated();

      final response = await dio.post(
        '$commentBaseUrl',
        data: {
          'recipeId': recipeId,
          'content': content,
        },
      );

      return Comment.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error creating comment: ${e.message}',
      );
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _ensureAuthenticated();

      final response = await dio.delete('$commentBaseUrl/$commentId');

      if (response.statusCode == 200) {
        print(response.data['message'] ?? 'Comment deleted');
      } else {
        throw Exception('Failed to delete comment');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error deleting comment',
      );
    }
  }

  // Future<void> createRecipe({
  //   required String title,
  //   required List<String> description,
  //   required String totalTime,
  //   required String cuisine,
  //   required List<Map<String, Object>> ingredients,
  //   required List<String> category,
  //   Uint8List? imageBytes,
  //   String? imageFileName, // e.g., "photo.png"
  // }) async {
  //   try {
  //     await _ensureAuthenticated();

  //     MediaType? contentType;
  //     if (imageBytes != null && imageFileName != null) {
  //       final mimeType = lookupMimeType(imageFileName, headerBytes: imageBytes);
  //       if (mimeType != null) {
  //         final parts = mimeType.split('/');
  //         contentType = MediaType(parts[0], parts[1]);
  //       }
  //     }

  //     final formData = FormData.fromMap({
  //       'recipeName': title,
  //       'description': jsonEncode(description),
  //       'totalTime': totalTime,
  //       'cuisine': cuisine,
  //       'ingredients': jsonEncode(ingredients),
  //       'category': jsonEncode(category),
  //       if (imageBytes != null && contentType != null)
  //         'image': MultipartFile.fromBytes(
  //           imageBytes,
  //           filename: imageFileName,
  //           contentType: contentType,
  //         ),
  //     });

  //     final response = await dio.post(
  //       '$recipeBaseUrl', // ✅ fixed: no /create in backend
  //       data: formData,
  //       options: Options(
  //         headers: {
  //           'Content-Type': 'multipart/form-data',
  //         },
  //       ),
  //     );

  //     if (response.statusCode != 201) {
  //       throw Exception('Failed to create recipe');
  //     }
  //   } on DioException catch (e) {
  //     throw Exception(
  //       e.response?.data['message'] ?? 'Error creating recipe',
  //     );
  //   }
  // }

  Future<void> createRecipe({
    required String title,
    required List<String> description,
    required String totalTime,
    required String cuisine,
    required List<Map<String, dynamic>>
        ingredients, // Changed from Object to dynamic
    required List<String> category,
    Uint8List? imageBytes,
    String? imageFileName,
  }) async {
    try {
      await _ensureAuthenticated();

      // Process ingredients to combine quantity and unit
      final processedIngredients = ingredients.map((ing) {
        String quantity = ing['quantity'] ?? '';
        String unit = ing['unit'] ?? '-';
        String customUnit = ing['customUnit'] ?? '';
        String name = ing['name'] ?? '';

        // Combine quantity and unit
        String combinedQuantity = quantity;
        if (unit != '-') {
          combinedQuantity += (unit == 'other') ? customUnit : unit;
        }

        return {
          'quantity': combinedQuantity,
          'name': name,
        };
      }).toList();

      MediaType? contentType;
      if (imageBytes != null && imageFileName != null) {
        final mimeType = lookupMimeType(imageFileName, headerBytes: imageBytes);
        if (mimeType != null) {
          final parts = mimeType.split('/');
          contentType = MediaType(parts[0], parts[1]);
        }
      }

      final formData = FormData.fromMap({
        'recipeName': title,
        'description': jsonEncode(description),
        'totalTime': totalTime,
        'cuisine': cuisine,
        'ingredients':
            jsonEncode(processedIngredients), // Send processed ingredients
        'category': jsonEncode(category),
        if (imageBytes != null && contentType != null)
          'image': MultipartFile.fromBytes(
            imageBytes,
            filename: imageFileName,
            contentType: contentType,
          ),
      });

      final response = await dio.post(
        '$recipeBaseUrl',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create recipe');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error creating recipe',
      );
    }
  }

  Future<Comment> updateComment(String commentId, String newContent) async {
    try {
      await _ensureAuthenticated();

      final response = await dio.put(
        '$commentBaseUrl/$commentId',
        data: {'content': newContent},
      );

      return Comment.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to update comment',
      );
    }
  }

  Future<List<Comment>> getCommentsByRecipeId(String recipeId) async {
    final response = await dio.get('$commentBaseUrl/$recipeId');
    final data = response.data as List;
    return data.map((json) => Comment.fromJson(json)).toList();
  }

//SHOPPING LIST
  Future<List<ShoppingItem>> getShoppingList() async {
    try {
      await _ensureAuthenticated();

      final response = await dio.get('$userBaseUrl/shopping-list');
      final list = response.data['shoppingList'] as List<dynamic>;

      return list.map((item) => ShoppingItem.fromJson(item)).toList();
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch shopping list');
    }
  }

  Future<void> addToShoppingList(String ingredientName) async {
    try {
      await _ensureAuthenticated();

      final trimmedName = ingredientName.toLowerCase().trim();

      final response = await dio.post(
        '$userBaseUrl/shopping-list/add',
        data: {'ingredName': trimmedName},
      );

      print(response.data['message']);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to add to shopping list',
      );
    }
  }

  Future<void> removeFromShoppingList(String ingredientName) async {
    try {
      await _ensureAuthenticated();

      final trimmedName = ingredientName.toLowerCase().trim();

      await dio.delete(
        '$userBaseUrl/shopping-list/remove',
        data: {'ingredName': trimmedName},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to remove ingredient');
    }
  }

  Future<void> updateShoppingListItem(String ingredientName) async {
    try {
      await _ensureAuthenticated();

      final trimmedName = ingredientName.toLowerCase().trim();

      await dio.patch(
        '$userBaseUrl/shopping-list/update',
        data: {'ingredName': trimmedName},
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Failed to update shopping list item status',
      );
    }
  }

  Future<Recipe> getRecipeById(String recipeId) async {
    final response = await dio.get('$recipeBaseUrl/$recipeId');
    if (response.data is Map) {
      return Recipe.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('Invalid response format');
    }
  }

  Future<RecipeStatus> getRecipeStatus(String recipeId) async {
    try {
      await _ensureAuthenticated();
      final response = await dio.get('$userBaseUrl/favorites/status/$recipeId');
      return RecipeStatus.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch recipe status');
    }
  }

//nosa
  Future<List<Recipe>> getHighRatedRecipes(double minRating) async {
    try {
      final response = await dio.get('$recipeBaseUrl/rate/$minRating');
      final data = response.data as List;
      return data.map((json) => Recipe.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Failed to fetch high rated recipes');
    }
  }

  Future<Recipe> getRecipeWithUserData(String recipeId) async {
    try {
      await _ensureAuthenticated();
      final response = await dio.get('$recipeBaseUrl/$recipeId');
      final recipe = Recipe.fromJson(response.data);

      // Get favorite status and rating
      final statusResponse =
          await dio.get('$userBaseUrl/favorites/status/$recipeId');
      final statusData = statusResponse.data;

      return Recipe.fromJson({
        ...response.data,
        'isFavorite': statusData['isFavorite'] ?? false,
        'userRating': statusData['userRating']?.toDouble(),
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ??
          'Failed to fetch recipe with user data');
    }
  }
  // }

  // // Add this method to your ApiService class
  // Future<List<Recipe>> getRecommendedRecipes({int limit = 6}) async {
  //   try {
  //     await _ensureAuthenticated();

  //     final response = await dio.get(
  //       '$userBaseUrl/recommendations',
  //       queryParameters: {'limit': limit},
  //     );

  //     if (response.statusCode == 200) {
  //       final data = response.data as Map<String, dynamic>;
  //       if (data['recipes'] == null || data['recipes'].isEmpty) {
  //         throw Exception('No recommendations available');
  //       }
  //       return (data['recipes'] as List)
  //           .map((json) => Recipe.fromJson(json))
  //           .toList();
  //     } else {
  //       throw Exception(
  //           response.data['message'] ?? 'Failed to get recommendations');
  //     }
  //   } on DioException catch (e) {
  //     throw Exception(
  //       e.response?.data['message'] ??
  //           'Failed to get recommendations: ${e.message}',
  //     );
  //   }
  // }

  // Future<List<Recipe>> getRecipesByCategory(String category) async {
  //   try {
  //     final response = await dio.get('$recipeBaseUrl/category/$category');

  //     if (response.statusCode == 200) {
  //       final data = response.data as List<dynamic>;
  //       return data.map((json) => Recipe.fromJson(json)).toList();
  //     } else if (response.statusCode == 404) {
  //       // No recipes found for the category
  //       return [];
  //     } else {
  //       throw Exception(
  //         response.data['message'] ?? 'Failed to load recipes by category',
  //       );
  //     }
  //   } on DioException catch (e) {
  //     throw Exception(
  //       e.response?.data['message'] ??
  //           'Failed to fetch recipes by category: ${e.message}',
  //     );
  //   }
  // }

  Future<List<Recipe>> getRecipesByCategory(String category) async {
    try {
      final response = await dio.get('$recipeBaseUrl/category/$category');

      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        return data.map((json) => Recipe.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        // No recipes found for the category
        return [];
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to load recipes by category',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Failed to fetch recipes by category: ${e.message}',
      );
    }
  }

  Future<User> updateUser(Map<String, dynamic> updates) async {
    try {
      await _ensureAuthenticated();

      final response = await dio.patch(
        '$userBaseUrl/update',
        data: updates,
      );

      return User.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Failed to update user';
      throw Exception('Error updating user: $message');
    }
  }

  Future<void> deleteCurrentUser() async {
    try {
      await _ensureAuthenticated();

      final response = await dio.delete('$userBaseUrl/delete');

      if (response.statusCode == 200) {
        print(response.data['message'] ?? 'User deleted');
      } else {
        throw Exception('Failed to delete user');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error deleting user',
      );
    }
  }

  Future<List<Recipe>> getRecipesByUser() async {
    try {
      await _ensureAuthenticated();
      final response =
          await dio.get('$userBaseUrl/recipes'); // Changed endpoint

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map && data['recipes'] is List) {
          return (data['recipes'] as List)
              .map((json) => Recipe.fromJson(json))
              .toList();
        } else if (data is List) {
          return (data as List).map((json) => Recipe.fromJson(json)).toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to fetch user recipes');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Failed to fetch user recipes: ${e.message}',
      );
    }
  }

//-------------------meal planner--------

  /// new one youm el etne :
  Future<void> addMealToPlanner({
    required DateTime date,
    required String mealType,
    required String recipeId,
  }) async {
    try {
      await _ensureAuthenticated();

      print('Attempting to add meal with data:');
      print('Date: ${date.toIso8601String()}');
      print('Meal Type: $mealType');
      print('Recipe ID: $recipeId');

      final response = await dio.post(
        '$mealPlannerBaseUrl/add-meal',
        data: {
          'date': date.toIso8601String(),
          'mealType': mealType.toLowerCase(),
          'recipeId': recipeId,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode != 200) {
        throw Exception(
          'Server error: ${response.data['message'] ?? 'Unknown error'}',
        );
      }
    } on DioException catch (e) {
      print('DioError occurred: ${e.message}');
      print('Response data: ${e.response?.data}');
      print('Status code: ${e.response?.statusCode}');

      final errorMessage = e.response?.data['message'] ??
          e.message ??
          'Unknown error (check server logs)';

      throw Exception('Failed to add meal: $errorMessage');
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  // isa de el sa7 :
  Future<MealPlanner> getMealPlanner() async {
    try {
      await _ensureAuthenticated();
      final response =
          await dio.get('$mealPlannerBaseUrl/user'); // Already matches backend
      return MealPlanner.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
          'Failed to load planner: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<void> deleteMeal({
    required DateTime date,
    required String mealType,
  }) async {
    try {
      await _ensureAuthenticated();
      final response = await dio.delete(
        '$mealPlannerBaseUrl/delete-meal',
        data: {
          'date': date.toIso8601String(),
          'mealType': mealType.toLowerCase(),
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete meal: ${response.data['message']}');
      }
    } on DioException catch (e) {
      debugPrint('Delete meal error: ${e.response?.data}');
      throw Exception(
          'Failed to delete meal: ${e.response?.data['message'] ?? e.message}');
    }
  }

  Future<Recipe> updateRecipe({
    required String recipeId,
    required String title,
    required List<String> description,
    required String totalTime,
    required String cuisine,
    required List<Map<String, String>> ingredients,
    required List<String> category,
    Uint8List? imageBytes,
    String? imageFileName,
    bool removeImage = false,
  }) async {
    try {
      await _ensureAuthenticated();
      final formData = FormData();

      // Add basic fields
      formData.fields.addAll([
        MapEntry('recipeName', title),
        MapEntry('description', jsonEncode(description)),
        MapEntry('totalTime', totalTime.toString()),
        MapEntry('cuisine', cuisine),
        MapEntry('ingredients', jsonEncode(ingredients)),
        MapEntry('category', jsonEncode(category)),
        MapEntry('removeImage', removeImage.toString()),
      ]);

      // Handle image upload if present
      if (imageBytes != null && imageFileName != null && !removeImage) {
        final mimeType = lookupMimeType(imageFileName);
        if (mimeType != null) {
          formData.files.add(MapEntry(
            'image',
            await MultipartFile.fromBytes(
              imageBytes,
              filename: imageFileName,
              contentType: mimeType != null ? MediaType.parse(mimeType) : null,
            ),
          ));
        }
      }

      final response = await dio.patch(
        '$recipeBaseUrl/$recipeId',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      if (response.statusCode == 200) {
        return Recipe.fromJson(response.data);
      } else {
        throw Exception('Failed to update recipe');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error updating recipe');
    }
  }

// In api_service.dart
  Future<void> deleteRecipe(String recipeId) async {
    try {
      await _ensureAuthenticated();
      await dio.delete('$recipeBaseUrl/$recipeId');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to delete recipe',
      );
    }
  }

  // Add this method to your ApiService class
  Future<List<Recipe>> getRecommendedRecipes({int limit = 6}) async {
    try {
      await _ensureAuthenticated();

      final response = await dio.get(
        '$userBaseUrl/recommendations/smart',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['recipes'] == null || data['recipes'].isEmpty) {
          throw Exception('No recommendations available');
        }
        return (data['recipes'] as List)
            .map((json) => Recipe.fromJson(json))
            .toList();
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to get recommendations');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Failed to get recommendations: ${e.message}',
      );
    }
  }

  static Future<List<Recipe>> staticSearchRecipes({
    String? query,
    double? minRate,
    double? maxRate,
    int? maxCookingTime,
  }) async {
    try {
      // Create a temporary Dio instance just for this search
      final tempDio = Dio();
      tempDio.options.connectTimeout = const Duration(seconds: 30);
      tempDio.options.receiveTimeout = const Duration(seconds: 30);

      // Add auth token if available
      final storage = const FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');
      if (token != null) {
        tempDio.options.headers['Authorization'] = 'Bearer $token';
      }

      // Build query parameters
      final Map<String, dynamic> queryParams = {};

      // Only add query if it's not null and not empty
      if (query != null && query.trim().isNotEmpty) {
        queryParams['q'] = query.trim();
      }

      // Handle rate range
      if (minRate != null || maxRate != null) {
        if (minRate != null) queryParams['minRate'] = minRate.toString();
        if (maxRate != null) queryParams['maxRate'] = maxRate.toString();
      }

      // Handle cooking time
      if (maxCookingTime != null) {
        queryParams['maxCookingTime'] = maxCookingTime.toString();
      }

      final response = await tempDio.get(
        '$recipeBaseUrl/filter/search',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle both array response and object with 'recipes' property
        if (data is List) {
          return data.map((json) => Recipe.fromJson(json)).toList();
        } else if (data is Map && data['recipes'] is List) {
          return (data['recipes'] as List)
              .map((json) => Recipe.fromJson(json))
              .toList();
        }

        // Log unexpected format
        debugPrint('Unexpected search response format: ${data.runtimeType}');
        return [];
      }

      // Log non-200 status
      debugPrint('Search request failed with status: ${response.statusCode}');
      return [];
    } on DioException catch (e) {
      // Handle different Dio error types
      if (e.response != null) {
        debugPrint(
            'Search API error: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        debugPrint('Search network error: ${e.message}');
      }
      return [];
    } catch (e) {
      debugPrint('Unexpected search error: $e');
      return [];
    }
  }

  Future<List<Recipe>> searchRecipes({
    String? query,
    double? minRate,
    double? maxRate,
    int? maxCookingTime,
  }) async {
    try {
      // Build query parameters
      final Map<String, dynamic> queryParams = {};
      if (query != null && query.trim().isNotEmpty) {
        queryParams['q'] = query.trim();
      }
      if (minRate != null) queryParams['minRate'] = minRate.toString();
      if (maxRate != null) queryParams['maxRate'] = maxRate.toString();
      if (maxCookingTime != null)
        queryParams['maxCookingTime'] = maxCookingTime.toString();

      final response = await dio.get(
        '$recipeBaseUrl/search',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map && data['recipes'] is List) {
          return (data['recipes'] as List)
              .map((json) => Recipe.fromJson(json))
              .toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception(response.data['message'] ?? 'Search failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error');
    }
  }

  Future<List<Recipe>> getRecipesByCategoryWithSubFilters(
    String mainCategory,
    List<String> subCategories,
  ) async {
    try {
      final response = await dio.get('$recipeBaseUrl/category/$mainCategory');

      if (response.statusCode == 200) {
        dynamic responseData = response.data;
        List<dynamic> recipesData = [];

        if (responseData is List) {
          recipesData = responseData;
        } else if (responseData is Map && responseData.containsKey('recipes')) {
          recipesData = responseData['recipes'];
        } else {
          throw Exception('Unexpected response format');
        }

        List<Recipe> allRecipes = recipesData
            .map((json) => Recipe.fromJson(json as Map<String, dynamic>))
            .toList();

        if (subCategories.isNotEmpty) {
          allRecipes = allRecipes.where((recipe) {
            return recipe.category.any((cat) => subCategories.contains(cat));
          }).toList();
        }

        return allRecipes;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load recipes');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch recipes: ${e.message}',
      );
    }
  }
}
