class Profile {
  final String id;
  final String role;

  Profile({required this.id, required this.role});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(id: json['id'] as String, role: json['role'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'role': role};
  }
}
