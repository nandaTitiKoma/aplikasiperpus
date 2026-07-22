class Facility {
  final int? id;
  final String name;
  final String category;
  final String? photoUrl;
  final int stock;
  final String? notes;

  Facility({
    this.id,
    required this.name,
    required this.category,
    this.photoUrl,
    required this.stock,
    this.notes,
  });

  factory Facility.fromJson(Map<String, dynamic> json) => Facility(
    id: json['id'] as int?,
    name: json['name'] as String,
    category: json['category'] as String,
    photoUrl: json['photo_url'] as String?,
    stock: json['stock'] as int,
    notes: json['notes'] as String?,
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'name': name,
    'category': category,
    if (photoUrl != null) 'photo_url': photoUrl,
    'stock': stock,
    if (notes != null) 'notes': notes,
  };
}
