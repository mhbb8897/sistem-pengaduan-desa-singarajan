class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? photoUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.photoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'photo_url': photoUrl,
    };
  }

  // /// ✅ Helper: Simpan user ke cache
  // Future<void> _saveUserToCache(UserModel user) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('user_cache', jsonEncode(user.toJson()));
  // }
}
