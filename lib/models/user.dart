class User {
  final int? id;
  final String username;
  final String email;
  final String password;
  final String fullName;
  final String phone;
  final String avatarPath;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
    required this.phone,
    required this.avatarPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'full_name': fullName,
      'phone': phone,
      'avatar_path': avatarPath,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      fullName: map['full_name'],
      phone: map['phone'],
      avatarPath: map['avatar_path'] ?? '',
    );
  }
}
