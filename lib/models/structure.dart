// lib/models/structure.dart
class Structure {
  String name;
  String? icon;
  String? color;
  int? index;

   Structure({
    required this.name,
    this.icon,
    this.color,
    this.index,
  });

  factory Structure.fromMapStructure(Map<String, dynamic> map) {
    return Structure(
      name: map['name'] as String, // Ensure type safety
      icon: map['icon'] as String?,
      color: map['color'] as String?,
      index: map['index'] != null ? (map['index'] as num).toInt() : null,
    );
  }
  Map<String, dynamic> toMapStructure() {
    return {
      'name': name,
      'icon': icon, 
      'color': color,
      'index': index,
    };
  }
}