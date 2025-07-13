//nosa
class ShoppingItem {
  final String name;
  final bool checked;

  ShoppingItem({required this.name, this.checked = false});

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        name: json['name'],
        checked: json['checked'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'checked': checked,
      };
}

class RatedRecipe {
  final String recipeId;
  final double rate;

  RatedRecipe({required this.recipeId, required this.rate});

  factory RatedRecipe.fromJson(Map<String, dynamic> json) => RatedRecipe(
        recipeId: json['recipeId']?.toString() ?? '',
        rate: (json['rate'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'recipeId': recipeId,
        'rate': rate,
      };
}

class User {
  final String id;
  final String name;
  final String email;
  final String userAvatar;
  final List<String> allergyOptions;
  final List<String> preferenceOptions;
  final String type;
  final bool banned;
  final DateTime? bannedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLogin;
  final bool active;
  final List<Map<String, dynamic>> favorites;
  final List<RatedRecipe> ratedRecipes;
  final List<ShoppingItem> shoppingList;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.userAvatar,
    required this.allergyOptions,
    required this.preferenceOptions,
    required this.type,
    required this.banned,
    this.bannedAt,
    required this.createdAt,
    this.updatedAt,
    this.lastLogin,
    required this.active,
    required this.favorites,
    required this.ratedRecipes,
    required this.shoppingList,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['_id']?.toString() ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        userAvatar: json['userAvatar'] ?? 'default-avatar',
        allergyOptions: List<String>.from(json['allergyOptions'] ?? []),
        preferenceOptions: List<String>.from(json['preferenceOptions'] ?? []),
        type: json['type'] ?? 'user',
        banned: json['banned'] ?? false,
        bannedAt: json['bannedAt'] != null
            ? DateTime.tryParse(json['bannedAt'])
            : null,
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'])
            : null,
        lastLogin: json['lastLogin'] != null
            ? DateTime.tryParse(json['lastLogin'])
            : null,
        active: json['active'] ?? true,
        favorites: List<Map<String, dynamic>>.from(json['favorites'] ?? []),
        ratedRecipes: (json['ratedRecipes'] as List?)
                ?.map((e) => RatedRecipe.fromJson(e))
                .toList() ??
            [],
        shoppingList: (json['shoppingList'] as List?)
                ?.map((e) => ShoppingItem.fromJson(e))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'email': email,
        'userAvatar': userAvatar,
        'allergyOptions': allergyOptions,
        'preferenceOptions': preferenceOptions,
        'type': type,
        'banned': banned,
        'bannedAt': bannedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'lastLogin': lastLogin?.toIso8601String(),
        'active': active,
        'favorites': favorites,
        'ratedRecipes': ratedRecipes.map((e) => e.toJson()).toList(),
        'shoppingList': shoppingList.map((e) => e.toJson()).toList(),
      };
}








































// /////// daaaaaaaaaa saaaaa7 //////
// // class User {
// //   final String id;
// //   final String name;
// //   final String email;
// //   final String type;
// //   final bool active;
// //   final List<Map<String, dynamic>> favorites;
// //   final List<Map<String, dynamic>> ratedRecipes;
// //   final List<ShoppingListItem> shoppingList;
// //   final DateTime createdAt;
// //   final DateTime updatedAt;
// //   final Map<String, bool> preferences;
// //   final Map<String, bool> allergies;

// //   User({
// //     required this.id,
// //     required this.name,
// //     required this.email,
// //     required this.type,
// //     required this.active,
// //     required this.favorites,
// //     required this.ratedRecipes,
// //     required this.shoppingList,
// //     required this.createdAt,
// //     required this.updatedAt,
// //     required this.preferences,
// //     required this.allergies,
// //   });

// //   factory User.fromJson(Map<String, dynamic> json) {
// //     return User(
// //       id: json['_id']?.toString() ?? '',
// //       name: json['name'] as String? ?? '',
// //       email: json['email'] as String? ?? '',
// //       type: json['type'] as String? ?? 'user',
// //       active: json['active'] as bool? ?? true,
// //       favorites: List<Map<String, dynamic>>.from(
// //           json['favorites']?.map((x) => x as Map<String, dynamic>) ?? []),
// //       ratedRecipes: List<Map<String, dynamic>>.from(
// //           json['ratedRecipes']?.map((x) => x as Map<String, dynamic>) ?? []),
// //       shoppingList: (json['shoppingList'] as List<dynamic>?)
// //               ?.map((item) => ShoppingListItem.fromJson(item))
// //               .toList() ??
// //           [],
// //       // createdAt: DateTime.parse(json['createdAt'].toString()),

// //         // createdAt: DateTime.parse(json['createdAt'].toString()),
// //       // updatedAt: DateTime.parse(json['updatedAt'].toString()),
// //       createdAt: json['createdAt'] != null
// //     ? DateTime.parse(json['createdAt'].toString())
// //     : DateTime.now(),

// //       // updatedAt: DateTime.parse(json['updatedAt'].toString()),
// //       updatedAt: json['updatedAt'] != null
// //     ? DateTime.parse(json['updatedAt'].toString())
// //     : DateTime.now(),
// //       preferences: Map<String, bool>.from(json['preferences'] ?? {}),
// //       allergies: Map<String, bool>.from(json['allergies'] ?? {}),
// //     );
// //   }
// // }

// // class ShoppingListItem {
// //   final String name;
// //   final bool checked;

// //   ShoppingListItem({
// //     required this.name,
// //     required this.checked,
// //   });

// //   factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
// //     return ShoppingListItem(
// //       name: json['name'] ?? '',
// //       checked: json['checked'] ?? false,
// //     );
// //   }

// //   Map<String, dynamic> toJson() {
// //     return {
// //       'name': name,
// //       'checked': checked,
// //     };
// //   }
// // }



// // class ShoppingItem {
// //   final String name;
// //   final bool checked;

// //   ShoppingItem({required this.name, this.checked = false});

// //   factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
// //         name: json['name'],
// //         checked: json['checked'] ?? false,
// //       );

// //   Map<String, dynamic> toJson() => {
// //         'name': name,
// //         'checked': checked,
// //       };
// // }

// // class RatedRecipe {
// //   final String recipeId;
// //   final double rate;

// //   RatedRecipe({required this.recipeId, required this.rate});

// //   factory RatedRecipe.fromJson(Map<String, dynamic> json) => RatedRecipe(
// //         recipeId: json['recipeId'],
// //         rate: (json['rate'] as num).toDouble(),
// //       );

// //   Map<String, dynamic> toJson() => {
// //         'recipeId': recipeId,
// //         'rate': rate,
// //       };
// // }

// // class User {
// //   final String id;
// //   final String name;
// //   final String email;
// //   final String userAvatar;
// //   final List<String> allergyOptions;
// //   final List<String> preferenceOptions;
// //   final String type;
// //   final DateTime createdAt;
// //   final DateTime? updatedAt;
// //   final DateTime? lastLogin;
// //   final bool active;
// //   final List<Map<String, dynamic>> favorites;
// //   final List<RatedRecipe> ratedRecipes;
// //   final List<ShoppingItem> shoppingList;

// //   User({
// //     required this.id,
// //     required this.name,
// //     required this.email,
// //     required this.userAvatar,
// //     required this.allergyOptions,
// //     required this.preferenceOptions,
// //     required this.type,
// //     required this.createdAt,
// //     this.updatedAt,
// //     this.lastLogin,
// //     this.active = true,
// //     this.favorites = const [],
// //     this.ratedRecipes = const [],
// //     this.shoppingList = const [],
// //   });

// //   // factory User.fromJson(Map<String, dynamic> json) => User(
// //   //       id: json['_id'],
// //   //       name: json['name'],
// //   //       email: json['email'],
// //   //       userAvatar: json['userAvatar'] ?? '',
// //   //       allergyOptions: List<String>.from(json['allergyOptions'] ?? []),
// //   //       preferenceOptions: List<String>.from(json['preferenceOptions'] ?? []),
// //   //       type: json['type'],
// //   //       createdAt: DateTime.parse(json['createdAt']),
// //   //       updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
// //   //       lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
// //   //       active: json['active'] ?? true,
// //   //       favorites: List<Map<String, dynamic>>.from(json['favorites'] ?? []),
// //   //       ratedRecipes: (json['ratedRecipes'] as List?)?.map((e) => RatedRecipe.fromJson(e)).toList() ?? [],
// //   //       shoppingList: (json['shoppingList'] as List?)?.map((e) => ShoppingItem.fromJson(e)).toList() ?? [],
// //   //     );
// // factory User.fromJson(Map<String, dynamic> json) => User(
// //   id: json['_id'] ?? '',
// //   name: json['name'] ?? '',
// //   email: json['email'] ?? '',
// //   userAvatar: json['userAvatar'] ?? 'default-avatar',
// //   allergyOptions: List<String>.from(json['allergyOptions'] ?? []),
// //   preferenceOptions: List<String>.from(json['preferenceOptions'] ?? []),
// //   type: json['type'] ?? 'user',
// //   createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
// //   updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
// //   lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
// //   active: json['active'] ?? true,
// //   favorites: List<Map<String, dynamic>>.from(json['favorites'] ?? []),
// //   ratedRecipes: (json['ratedRecipes'] as List?)?.map((e) => RatedRecipe.fromJson(e)).toList() ?? [],
// //   shoppingList: (json['shoppingList'] as List?)?.map((e) => ShoppingItem.fromJson(e)).toList() ?? [],
// // );

// //   Map<String, dynamic> toJson() => {
// //         '_id': id,
// //         'name': name,
// //         'email': email,
// //         'userAvatar': userAvatar,
// //         'allergyOptions': allergyOptions,
// //         'preferenceOptions': preferenceOptions,
// //         'type': type,
// //         'createdAt': createdAt.toIso8601String(),
// //         'updatedAt': updatedAt?.toIso8601String(),
// //         'lastLogin': lastLogin?.toIso8601String(),
// //         'active': active,
// //         'favorites': favorites,
// //         'ratedRecipes': ratedRecipes.map((e) => e.toJson()).toList(),
// //         'shoppingList': shoppingList.map((e) => e.toJson()).toList(),
// //       };
// // }

// class ShoppingItem {
//   final String name;
//   final bool checked;

//   ShoppingItem({required this.name, this.checked = false});

//   factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
//         name: json['name'],
//         checked: json['checked'] ?? false,
//       );

//   Map<String, dynamic> toJson() => {
//         'name': name,
//         'checked': checked,
//       };
// }

// class RatedRecipe {
//   final String recipeId;
//   final double rate;

//   RatedRecipe({required this.recipeId, required this.rate});

//   // factory RatedRecipe.fromJson(Map<String, dynamic> json) => RatedRecipe(
//   //       recipeId: json['recipeId'].toString(),
//   //       rate: (json['rate'] as num).toDouble(),
//   //     );
// factory RatedRecipe.fromJson(Map<String, dynamic> json) => RatedRecipe(
//   recipeId: json['recipeId'] as String,
//   rate: (json['rate'] as num).toDouble(),
// );

//   Map<String, dynamic> toJson() => {
//         'recipeId': recipeId,
//         'rate': rate,
//       };
// }

// class User {
//   final String id;
//   final String name;
//   final String email;
//   final String userAvatar;
//   final List<String> allergyOptions;
//   final List<String> preferenceOptions;
//   final String type;
//   final bool banned;
//   final DateTime? bannedAt;
//   final DateTime createdAt;
//   final DateTime? updatedAt;
//   final DateTime? lastLogin;
//   final bool active;
//   final List<Map<String, dynamic>> favorites;
//   final List<RatedRecipe> ratedRecipes;
//   final List<ShoppingItem> shoppingList;

//   User({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.userAvatar,
//     required this.allergyOptions,
//     required this.preferenceOptions,
//     required this.type,
//     required this.banned,
//     this.bannedAt,
//     required this.createdAt,
//     this.updatedAt,
//     this.lastLogin,
//     required this.active,
//     required this.favorites,
//     required this.ratedRecipes,
//     required this.shoppingList,
//   });

//   // factory User.fromJson(Map<String, dynamic> json) => User(
//   //       id: json['_id'],
//   //       name: json['name'],
//   //       email: json['email'],
//   //       userAvatar: json['userAvatar'] ?? 'default-avatar',
//   //       allergyOptions: List<String>.from(json['allergyOptions'] ?? []),
//   //       preferenceOptions: List<String>.from(json['preferenceOptions'] ?? []),
//   //       type: json['type'],
//   //       banned: json['banned'] ?? false,
//   //       bannedAt:
//   //           json['bannedAt'] != null ? DateTime.parse(json['bannedAt']) : null,
//   //       createdAt: DateTime.parse(json['createdAt']),
//   //       updatedAt: json['updatedAt'] != null
//   //           ? DateTime.parse(json['updatedAt'])
//   //           : null,
//   //       lastLogin: json['lastLogin'] != null
//   //           ? DateTime.parse(json['lastLogin'])
//   //           : null,
//   //       active: json['active'] ?? true,
//   //       favorites:
//   //           List<Map<String, dynamic>>.from(json['favorites'] ?? const []),
//   //       ratedRecipes: (json['ratedRecipes'] as List?)
//   //               ?.map((e) => RatedRecipe.fromJson(e))
//   //               .toList() ??
//   //           [],
//   //       shoppingList: (json['shoppingList'] as List?)
//   //               ?.map((e) => ShoppingItem.fromJson(e))
//   //               .toList() ??
//   //           [],
//   //     );
// factory User.fromJson(Map<String, dynamic> json) => User(
//   id: json['_id'] ?? '',
//   name: json['name'] ?? '',
//   email: json['email'] ?? '',
//   userAvatar: json['userAvatar'] ?? 'default-avatar',
//   allergyOptions: List<String>.from(json['allergyOptions'] ?? []),
//   preferenceOptions: List<String>.from(json['preferenceOptions'] ?? []),
//   type: json['type'] ?? 'user',
//   banned: json['banned'] ?? false,
//   bannedAt: json['bannedAt'] != null
//       ? DateTime.tryParse(json['bannedAt']) 
//       : null,
//   createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
//   updatedAt: json['updatedAt'] != null
//       ? DateTime.tryParse(json['updatedAt'])
//       : null,
//   lastLogin: json['lastLogin'] != null
//       ? DateTime.tryParse(json['lastLogin'])
//       : null,
//   active: json['active'] ?? true,
//   favorites: List<Map<String, dynamic>>.from(json['favorites'] ?? []),
//   // ratedRecipes: (json['ratedRecipes'] as List?)
//   //         ?.map((e) => RatedRecipe.fromJson(e))
//   //         .toList() ??
//   //     [],
//   ratedRecipes: (json['ratedRecipes'] as List?)
//     ?.map((e) => RatedRecipe.fromJson(e as Map<String, dynamic>))
//     .toList() ?? [],

//   shoppingList: (json['shoppingList'] as List?)
//           ?.map((e) => ShoppingItem.fromJson(e))
//           .toList() ??
//       [],
// );

//   Map<String, dynamic> toJson() => {
//         '_id': id,
//         'name': name,
//         'email': email,
//         'userAvatar': userAvatar,
//         'allergyOptions': allergyOptions,
//         'preferenceOptions': preferenceOptions,
//         'type': type,
//         'banned': banned,
//         'bannedAt': bannedAt?.toIso8601String(),
//         'createdAt': createdAt.toIso8601String(),
//         'updatedAt': updatedAt?.toIso8601String(),
//         'lastLogin': lastLogin?.toIso8601String(),
//         'active': active,
//         'favorites': favorites,
//         'ratedRecipes': ratedRecipes.map((e) => e.toJson()).toList(),
//         'shoppingList': shoppingList.map((e) => e.toJson()).toList(),
//       };
// }
