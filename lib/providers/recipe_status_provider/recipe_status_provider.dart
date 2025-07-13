import 'package:flutter/material.dart';
import 'package:sizzle_share/models/recipeStatus.dart';
import 'package:sizzle_share/services/api_service.dart';

class RecipeStatusProvider extends ChangeNotifier {
  Map<String, RecipeStatus> _recipeStatuses = {};

  Map<String, RecipeStatus> get recipeStatuses => _recipeStatuses;
  final ApiService apiService = ApiService();

  RecipeStatus? getStatus(String recipeId) {
    return _recipeStatuses[recipeId];
  }

  void updateStatus(String recipeId, RecipeStatus status) {
    _recipeStatuses[recipeId] = status;
    notifyListeners();
  }

  void clearStatuses() {
    _recipeStatuses.clear();
    notifyListeners();
  }
  // void toggleFavorite(String recipeId) {
  //   if (_recipeStatuses.containsKey(recipeId)) {
  //     _recipeStatuses[recipeId]!.isFavorite = !_recipeStatuses[recipeId]!.isFavorite;
  //     notifyListeners();
  //   }
  // }

  // void updateRating(String recipeId, double newRating) {
  //   if (_recipeStatuses.containsKey(recipeId)) {
  //     _recipeStatuses[recipeId]!.userRating = newRating;
  //     notifyListeners();
  //   }
  // }

  Future<void> fetchStatus(String recipeId) async {
    try {
      final status = await apiService.getRecipeStatus(recipeId);
      _recipeStatuses[recipeId] = status;
      notifyListeners();
    } catch (e) {
      print('Error fetching status: $e');
    }
  }

  // Future<void> toggleFavorite(String recipeId, {VoidCallback? onStatusChanged}) async {
  //   try {
  //     await apiService.toggleFavorite(recipeId);
  //     _recipeStatuses[recipeId]!.isFavorite = !_recipeStatuses[recipeId]!.isFavorite;
  //     notifyListeners();
  //   } catch (e) {
  //     print('Error toggling favorite: $e');
  //   }
  // }

  Future<void> toggleFavorite(String recipeId,
      {VoidCallback? onStatusChanged}) async {
    try {
      await apiService.toggleFavorite(recipeId);

      // Toggle local status
      if (_recipeStatuses.containsKey(recipeId)) {
        _recipeStatuses[recipeId]!.isFavorite =
            !_recipeStatuses[recipeId]!.isFavorite;
        notifyListeners();
        onStatusChanged?.call();
      }

      // ✅ Trigger optional callback to refresh ProfilePage
      // if (onStatusChanged != null) {
      //   onStatusChanged();
      // }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  Future<void> updateRating(String recipeId, double newRating) async {
    try {
      await apiService.rateRecipe(recipeId, newRating);
      _recipeStatuses[recipeId]!.userRating = newRating;
      notifyListeners();
    } catch (e) {
      print('Error updating rating: $e');
    }
  }

  void setInitialStatuses(Map<String, RecipeStatus> statuses) {
    _recipeStatuses = statuses;
    notifyListeners();
  }
}
