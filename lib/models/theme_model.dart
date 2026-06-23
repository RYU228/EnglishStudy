import 'package:flutter/material.dart';

class ThemeModel {
  final String id;
  final String name;
  final String assetPath;
  final IconData icon;
  final Color color;

  ThemeModel({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.icon,
    required this.color,
  });

  static List<ThemeModel> getDefaultThemes() {
    return [
      ThemeModel(
        id: 'daily',
        name: '일상 회화',
        assetPath: 'assets/data/daily.json',
        icon: Icons.chat_bubble_outline_rounded,
        color: Colors.blueAccent,
      ),
      ThemeModel(
        id: 'travel',
        name: '여행',
        assetPath: 'assets/data/travel.json',
        icon: Icons.flight_takeoff_rounded,
        color: Colors.orangeAccent,
      ),
      ThemeModel(
        id: 'shopping',
        name: '쇼핑',
        assetPath: 'assets/data/shopping.json',
        icon: Icons.shopping_bag_outlined,
        color: Colors.pinkAccent,
      ),
      ThemeModel(
        id: 'restaurant',
        name: '식당',
        assetPath: 'assets/data/restaurant.json',
        icon: Icons.restaurant_rounded,
        color: Colors.greenAccent,
      ),
      ThemeModel(
        id: 'business',
        name: '비즈니스',
        assetPath: 'assets/data/business.json',
        icon: Icons.business_center_outlined,
        color: Colors.indigoAccent,
      ),
      ThemeModel(
        id: 'airport',
        name: '공항',
        assetPath: 'assets/data/airport.json',
        icon: Icons.local_airport_rounded,
        color: Colors.tealAccent,
      ),
      ThemeModel(
        id: 'hotel',
        name: '호텔',
        assetPath: 'assets/data/hotel.json',
        icon: Icons.hotel_rounded,
        color: Colors.amberAccent,
      ),
      ThemeModel(
        id: 'hospital',
        name: '병원',
        assetPath: 'assets/data/hospital.json',
        icon: Icons.local_hospital_rounded,
        color: Colors.redAccent,
      ),
    ];
  }
}
