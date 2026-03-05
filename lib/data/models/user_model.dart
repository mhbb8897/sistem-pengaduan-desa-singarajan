// class UserModel {
//   final String id;
//   final String name;
//   final String email;
//   // final String? photoUrl;

//   UserModel({
//     required this.id,
//     required this.name,
//     required this.email,
//     // this.photoUrl,
//   });

//   // Factory untuk membuat objek dari JSON (jika dari API)
//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       id: json['id'] ?? '',
//       name: json['name'] ?? 'Pengguna',
//       email: json['email'] ?? '',
//       // photoUrl: json['photo_url'],
//     );
//   }
// }

class UserModel {
  final String id;
  final String name;
  final String email;
  // final String? phone;
  // final String? photoUrl;
  // final String? token;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    // this.phone,
    // this.photoUrl,
    // this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Pengguna',
      email: json['email'] ?? '',
      // phone: json['phone'],
      // photoUrl: json['photo_url'],
      // token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      // 'phone': phone,
      // 'photo_url': photoUrl,
      // 'token': token,
    };
  }
}
