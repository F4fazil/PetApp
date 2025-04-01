class Animal {
  final String id;
  final String name;
  final String origin;
  final String temperament;
  final String lifeSpan;
  final Map<String, String> weight;
  final String image; // Changed from imageUrl to image
  final String foodRecommendation;

  Animal({
    required this.id,
    required this.name,
    required this.origin,
    required this.temperament,
    required this.lifeSpan,
    required this.weight,
    required this.image,
    required this.foodRecommendation,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'],
      name: json['name'],
      origin: json['origin'],
      temperament: json['temperament'],
      lifeSpan: json['life_span'],
      weight: Map<String, String>.from(json['weight']),
      image: json['image'], // Matches the 'image' key in the JSON
      foodRecommendation: json['food_recommendation'],
    );
  }
}
