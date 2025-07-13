class RecipeStatus {
  // final bool isFavorite;
  // final double? userRating;


 bool isFavorite;
  double? userRating;
  RecipeStatus({required this.isFavorite, required this.userRating});

  factory RecipeStatus.fromJson(Map<String, dynamic> json) {
    return RecipeStatus(
      isFavorite: json['isFavorite'] ?? false,
      userRating: json['userRating']?.toDouble(),
    );
  }
  //nosa

  Map<String, dynamic> toJson() => {
        'isFavorite': isFavorite,
        'userRating': userRating,
      };
}
