import 'dart:convert';
import 'package:hive/hive.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  static const String FAVORITES_BOX = 'favorites';

  // Add a JSON item to favorites
  Future<void> addToFavorites(String categoryKey, Map<String, dynamic> jsonItem) async {
    final box = await Hive.openBox(FAVORITES_BOX);
    
    // Fetch existing favorites for the category
    List<Map<String, dynamic>> favorites = 
      await getFavorites(categoryKey) ?? [];
    
    // Check if item already exists by unique identifier
    bool exists = favorites.any((favItem) => 
      favItem['id'] == jsonItem['id']);
    
    if (!exists) {
      favorites.add(jsonItem);
      await box.put(categoryKey, json.encode(favorites));
    }
  }

  // Remove a JSON item from favorites
  Future<void> removeFromFavorites(String categoryKey, Map<String, dynamic> jsonItem) async {
    final box = await Hive.openBox(FAVORITES_BOX);
    
    // Fetch existing favorites for the category
    List<Map<String, dynamic>> favorites = 
      await getFavorites(categoryKey) ?? [];
    
    // Remove the item based on its unique identifier
    favorites.removeWhere((favItem) => 
      favItem['id'] == jsonItem['id']);
    
    // Update the box
    await box.put(categoryKey, json.encode(favorites));
  }

  // Get all favorites for a specific category
  Future<List<Map<String, dynamic>>?> getFavorites(String categoryKey) async {
    final box = await Hive.openBox(FAVORITES_BOX);
    
    final favoritesString = box.get(categoryKey);
    if (favoritesString != null) {
      return List<Map<String, dynamic>>.from(
        json.decode(favoritesString)
      );
    }
    return null;
  }

  // Check if a JSON item is in favorites
  Future<bool> isFavorite(String categoryKey, Map<String, dynamic> jsonItem) async {
    final favorites = await getFavorites(categoryKey);
    if (favorites == null) return false;
    
    return favorites.any((favItem) => 
      favItem['id'] == jsonItem['id']);
  }

  // Clear all favorites for a specific category
  Future<void> clearFavorites(String categoryKey) async {
    final box = await Hive.openBox(FAVORITES_BOX);
    await box.delete(categoryKey);
  }
}
