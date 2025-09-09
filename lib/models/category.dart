class Category {
  final String id;
  final String name;
  final String type;
  final String icon;
  final String userId; // Added userId field

  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.userId, // Added userId parameter
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'userId': userId, // Include userId in JSON
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      icon: json['icon'] ?? '💰',
      userId: json['userId'] ?? '', // Parse userId from JSON
    );
  }

  // Keep the toMap/fromMap methods if you need them for any local storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'userId': userId,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      icon: map['icon'] ?? '💰',
      userId: map['userId'] ?? '',
    );
  }
}