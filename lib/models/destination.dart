class Destination {
  final int? id;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String openingTime;
  final String closingTime;
  final String imagePath;
  final bool isFavorite;

  Destination({
    this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.openingTime,
    required this.closingTime,
    required this.imagePath,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'image_path': imagePath,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  factory Destination.fromMap(Map<String, dynamic> map) {
    return Destination(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      address: map['address'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      openingTime: map['opening_time'],
      closingTime: map['closing_time'],
      imagePath: map['image_path'],
      isFavorite: map['is_favorite'] == 1,
    );
  }
}
