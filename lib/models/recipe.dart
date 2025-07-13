//nosa
class Ingredient {
  final String name;
  final String quantity;

  Ingredient({required this.name, required this.quantity});

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        name: json['name'],
        quantity: json['quantity'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
      };
}

class Recipe {
  final String id;
  final String recipeName;
  final List<String> description;
  final int totalTime;
   double? averageRate;
  final String? cuisine;
  bool fav_state = false;

  // final String? imageURL;

  String? imageURL;
  final List<Ingredient> ingredients;
  final List<String> category;
  final String userId;
  final DateTime createdAt;
  final bool isFavorite;
  final double? userRating;

  final String status;
  final bool isNewStatus; // Add this to track if status is newly changed
  final DateTime statusChangedAt; // Add this to track when status changed

  Recipe({
    required this.id,
    required this.recipeName,
    required this.description,
    required this.totalTime,
    this.averageRate,
    this.cuisine,
    this.imageURL,
    required this.ingredients,
    required this.category,
    required this.userId,
    required this.createdAt,
    this.isFavorite = false,
    this.userRating,
    required this.status,
    this.isNewStatus = false,
    DateTime? statusChangedAt,
  }) : statusChangedAt = statusChangedAt ?? createdAt;

  // });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // String id;
    // if (json['_id'] is Map) {
    //   id = json['_id']['\$oid']?.toString() ?? '';
    // } else {
    //   id = json['_id']?.toString() ?? '';
    // }
    final String id = json['_id']?.toString() ?? '';

    dynamic imageData = json['imageURL'];
    String? imageUrl;

    if (imageData is Map) {
      imageUrl = imageData['secure_url'] ?? imageData['url'];
    } else if (imageData is String) {
      imageUrl = imageData;
    }

    return Recipe(
      id: id,
      recipeName: json['recipeName'] ?? '',
      description: List<String>.from(json['description'] ?? []),
      totalTime: json['totalTime'] ?? 0,
      averageRate: json['averageRate']?.toDouble(),
      cuisine: json['cuisine'],
      imageURL: imageUrl,
      ingredients: (json['ingredients'] as List?)
              ?.map((i) => Ingredient.fromJson(i))
              .toList() ??
          [],
      category: List<String>.from(json['category'] ?? []),
      userId: json['userId']?.toString() ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      isFavorite: json['isFavorite'] ?? false,
      userRating: json['userRating']?.toDouble(),

      // ... existing fields ...

      isNewStatus: json['isNewStatus'] ?? false,
      statusChangedAt: json['statusChangedAt'] != null
          ? DateTime.parse(json['statusChangedAt'])
          : DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'recipeName': recipeName,
        'description': description,
        'totalTime': totalTime,
        'averageRate': averageRate,
        'cuisine': cuisine,
        'imageURL': imageURL,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
        'category': category,
        'userId': userId,
        'createdAt': createdAt.toIso8601String(),
        'isFavorite': isFavorite,
        'userRating': userRating,

        // ... existing fields ...
        'status': status,
        'isNewStatus': isNewStatus,
        'statusChangedAt': statusChangedAt.toIso8601String(),
      };
}

// // // daaa saaaaaaaaaaaaaaaaaa7 ////

// // // import 'dart:convert';
// // // import 'package:sizzle_share/models/comment.dart';

// // // List<Recipe> recipeFromJson(String str) =>
// // //     List<Recipe>.from(json.decode(str).map((x) => Recipe.fromJson(x)));

// // // String recipeToJson(List<Recipe> data) =>
// // //     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// // // class Recipe {
// // //   Id id;
// // //   String recipeName;
// // //   double averageRate;
// // //   List<String> category;
// // //   String cuisine;
// // //   String description;
// // //   String imageUrl;
// // //   List<Ingredient> ingredients;
// // //   int totalTime;
// // //   List<Comment> comments;

// // //   Recipe({
// // //     required this.id,
// // //     required this.recipeName,
// // //     required this.averageRate,
// // //     required this.category,
// // //     required this.cuisine,
// // //     required this.description,
// // //     required this.imageUrl,
// // //     required this.ingredients,
// // //     required this.totalTime,
// // //     this.comments = const [],
// // //   });

// // //   factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
// // //         id: Id.fromJson(json["_id"]),
// // //         recipeName: json["recipeName"] ?? '',
// // //         averageRate: (json["averageRate"] ?? 0).toDouble(),
// // //         category: List<String>.from((json["category"] ?? []).map((x) => x.toString())),
// // //         cuisine: json["cuisine"] ?? '',
// // //         description: json["description"] ?? '',
// // //         imageUrl: json["imageURL"] ?? '',
// // //         ingredients: List<Ingredient>.from((json["ingredients"] ?? []).map((x) => Ingredient.fromJson(x))),
// // //         totalTime: json["totalTime"] ?? '',
// // //         comments: List<Comment>.from(
// // //           (json["comments"] ?? []).map((x) => Comment.fromJson(x)),
// // //         ),
// // //       );

// // //   Map<String, dynamic> toJson() => {
// // //         "_id": id.toJson(),
// // //         "recipeName": recipeName,
// // //         "averageRate": averageRate,
// // //         "category": List<dynamic>.from(category.map((x) => x)),
// // //         "cuisine": cuisine,
// // //         "description": description,
// // //         "imageURL": imageUrl,
// // //         "ingredients": List<dynamic>.from(ingredients.map((x) => x.toJson())),
// // //         "totalTime": totalTime,
// // //         "comments": List<dynamic>.from(comments.map((x) => x.toJson())),
// // //       };
// // // }

// // // class Id {
// // //   final String oid;

// // //   Id({
// // //     required this.oid,
// // //   });

// // //   factory Id.fromJson(dynamic json) {
// // //     if (json is String) {
// // //       return Id(oid: json);
// // //     } else if (json is Map && json.containsKey("\$oid")) {
// // //       return Id(oid: json["\$oid"]);
// // //     }
// // //     throw Exception('Invalid ID format: $json');
// // //   }

// // //   Map<String, dynamic> toJson() => {
// // //         "\$oid": oid,
// // //       };
// // // }

// // // class Ingredient {
// // //   String name;
// // //   String quantity;

// // //   Ingredient({
// // //     required this.name,
// // //     required this.quantity,
// // //   });

// // //   factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
// // //         name: json["name"] ?? '',
// // //         quantity: json["quantity"] ?? '',
// // //       );

// // //   Map<String, dynamic> toJson() => {
// // //         "name": name,
// // //         "quantity": quantity,
// // //       };
// // // }



// // class Ingredient {
// //   final String name;
// //   final String quantity;

// //   Ingredient({required this.name, required this.quantity});

// //   factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
// //         name: json['name'],
// //         quantity: json['quantity'],
// //       );

// //   Map<String, dynamic> toJson() => {
// //         'name': name,
// //         'quantity': quantity,
// //       };
// // }

// // class Recipe {
// //   final String id;
// //   final String recipeName;
// //   final List<String> description;
// //   final int totalTime;
// //    double? averageRate;
// //   final String? cuisine;
// //   final String? imageURL;
// //   final List<Ingredient> ingredients;
// //   final List<String> category;
// //   final String userId;
// //   final String status; // pending, approved, rejected
// //   final DateTime createdAt;

// //   Recipe({
// //     required this.id,
// //     required this.recipeName,
// //     required this.description,
// //     required this.totalTime,
// //     this.averageRate,
// //     this.cuisine,
// //     this.imageURL,
// //     required this.ingredients,
// //     required this.category,
// //     required this.userId,
// //     required this.status,
// //     required this.createdAt,
// //   });

// //   factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
// //         id: json['_id'],
// //         recipeName: json['recipeName'],
// //         description: List<String>.from(json['description']),
// //         totalTime: json['totalTime'],
// //         averageRate: (json['averageRate'] as num?)?.toDouble(),
// //         cuisine: json['cuisine'],
// //         // imageURL: json['imageURL'],
// //         imageURL: json['imageURL'] is String
// //     ? json['imageURL']
// //     : (json['imageURL']?['base64'] ?? ''),

// //         ingredients: (json['ingredients'] as List).map((e) => Ingredient.fromJson(e)).toList(),
// //         category: List<String>.from(json['category']),
// //         userId: json['userId'],
// //         status: json['status'],
// //         createdAt: DateTime.parse(json['createdAt']),
// //       );

// //   Map<String, dynamic> toJson() => {
// //         '_id': id,
// //         'recipeName': recipeName,
// //         'description': description,
// //         'totalTime': totalTime,
// //         'averageRate': averageRate,
// //         'cuisine': cuisine,
// //         'imageURL': imageURL,
// //         'ingredients': ingredients.map((e) => e.toJson()).toList(),
// //         'category': category,
// //         'userId': userId,
// //         'status': status,
// //         'createdAt': createdAt.toIso8601String(),
// //       };
// // }



// class Ingredient {
//   final String name;
//   final String quantity;

//   Ingredient({required this.name, required this.quantity});

//   factory Ingredient.fromJson(Map<String, dynamic> json) {
//     return Ingredient(
//       name: json['name'],
//       quantity: json['quantity'],
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'name': name,
//         'quantity': quantity,
//       };
// }

// class Recipe {
//   final String id;
//   final String recipeName;
//   final List<String> description;
//   final int totalTime;
//    double? averageRate;
//   final String? cuisine;
//   final String? imageURL; // base64 or URL
//   final List<Ingredient> ingredients;
//   final List<String> category;
//   final String userId;
//   final String status;
//   final DateTime createdAt;

//   Recipe({
//     required this.id,
//     required this.recipeName,
//     required this.description,
//     required this.totalTime,
//     this.averageRate,
//     this.cuisine,
//     this.imageURL,
//     required this.ingredients,
//     required this.category,
//     required this.userId,
//     required this.status,
//     required this.createdAt,
//   });

//   factory Recipe.fromJson(Map<String, dynamic> json) {
//       String id;
//   if (json['_id'] is Map) {
//     id = json['_id']['\$oid']?.toString() ?? '';
//   } else {
//     id = json['_id']?.toString() ?? '';
//   }
//    // Handle imageURL which might be a string or Cloudinary response object
//     dynamic imageData = json['imageURL'];
//     String? imageUrl;
    
//     if (imageData is Map) {
//       // If it's a Cloudinary response, get the secure_url
//       imageUrl = imageData['secure_url'] ?? imageData['url'];
//     } else if (imageData is String) {
//       imageUrl = imageData;
//     }
//     return Recipe(
//       // id: json['_id'],
//         // id: json['_id'] is Map ? json['_id']['\$oid'] ?? '' : json['_id'] ?? '',
// id:id,
//       recipeName: json['recipeName'],
//       description: List<String>.from(json['description']),
//       totalTime: json['totalTime'],
//       averageRate: json['averageRate']?.toDouble(),
//       cuisine: json['cuisine'],
//       // imageURL: json['imageURL'],
//             imageURL: imageUrl,

//       ingredients: (json['ingredients'] as List)
//           .map((i) => Ingredient.fromJson(i))
//           .toList(),
//       category: List<String>.from(json['category']),
//       userId: json['userId'],
//       status: json['status'],
//       createdAt: DateTime.parse(json['createdAt']),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         '_id': id,
//         'recipeName': recipeName,
//         'description': description,
//         'totalTime': totalTime,
//         'averageRate': averageRate,
//         'cuisine': cuisine,
//         'imageURL': imageURL,
//         'ingredients': ingredients.map((i) => i.toJson()).toList(),
//         'category': category,
//         'userId': userId,
//         'status': status,
//         'createdAt': createdAt.toIso8601String(),
//       };
// }
