// // daaaaaaaa saaaaaaaaaaaaa7 ///

// // import 'dart:convert';

// // List<Comment> commentFromJson(String str) =>
// //     List<Comment>.from(json.decode(str).map((x) => Comment.fromJson(x)));

// // String commentToJson(List<Comment> data) =>
// //     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// // class Comment {
// //   Id id;
// //   String userId;
// //   String recipeId;
// //   String content;
// //   String date;

// //   Comment({
// //     required this.id,
// //     required this.userId,
// //     required this.recipeId,
// //     required this.content,
// //     required this.date,
// //   });

// //   factory Comment.fromJson(Map<String, dynamic> json) => Comment(
// //         id: Id.fromJson(json["_id"]),
// //         userId: _extractId(json["userId"]),
// //         recipeId: _extractId(json["recipeId"]),
// //         content: json["content"] ?? '',
// //         date: json["date"] ?? '',
// //       );

// //   Map<String, dynamic> toJson() => {
// //         "_id": id.toJson(),
// //         "userId": userId,
// //         "recipeId": recipeId,
// //         "content": content,
// //         "date": date,
// //       };

// //   static String _extractId(dynamic idField) {
// //     if (idField is Map && idField.containsKey("\$oid")) {
// //       return idField["\$oid"];
// //     } else if (idField is String) {
// //       return idField;
// //     } else {
// //       return '';
// //     }
// //   }
// // }

// // class Id {
// //   String oid;

// //   Id({
// //     required this.oid,
// //   });

// //   factory Id.fromJson(dynamic json) {
// //     if (json is Map && json.containsKey("\$oid")) {
// //       return Id(oid: json["\$oid"]);
// //     } else if (json is String) {
// //       return Id(oid: json);
// //     }
// //     return Id(oid: '');
// //   }

// //   Map<String, dynamic> toJson() => {
// //         "\$oid": oid,
// //       };
// // }

// class Comment {
//   final String userId;
//   final String recipeId;
//   final String content;
//   final DateTime date;

//   Comment({
//     required this.userId,
//     required this.recipeId,
//     required this.content,
//     required this.date,
//   });

//   factory Comment.fromJson(Map<String, dynamic> json) => Comment(
//         userId: json['userId'],
//         recipeId: json['recipeId'],
//         content: json['content'],
//         date: DateTime.parse(json['date']),
//       );

//   Map<String, dynamic> toJson() => {
//         'userId': userId,
//         'recipeId': recipeId,
//         'content': content,
//         'date': date.toIso8601String(),
//       };
// }

// class Comment {
//   final String id;
//   final String userId;
//   final String recipeId;
//   final String content;
//   final DateTime date;

//   Comment({
//     required this.id,
//     required this.userId,
//     required this.recipeId,
//     required this.content,
//     required this.date,
//   });

//   factory Comment.fromJson(Map<String, dynamic> json) {
//     return Comment(
//       id: json['_id'] ?? '',
//       userId: json['userId'],
//       recipeId: json['recipeId'],
//       content: json['content'],
//       date: DateTime.parse(json['date']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'userId': userId,
//       'recipeId': recipeId,
//       'content': content,
//       'date': date.toIso8601String(),
//     };
//   }
// }

class Comment {
  final String id;
  final String userId;
  final String recipeId;
  final String content;
  final DateTime date;

  Comment({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.content,
    required this.date,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'] ?? '',
      userId: json['userId'] is Map ? json['userId']['\$oid'] : json['userId'],
      recipeId: json['recipeId'] is Map
          ? json['recipeId']['\$oid']
          : json['recipeId'],
      content: json['content'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'recipeId': recipeId,
      'content': content,
      'date': date.toIso8601String(),
    };
  }
}
