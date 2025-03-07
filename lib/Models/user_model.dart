class UserData {
  String? id;
  String fullName;
  String userName;
  String email;
  String role;
  bool deleted;

  UserData(
      {this.id,
      required this.fullName,
      required this.email,
      required this.userName,
      required this.role,
      this.deleted = false});

  factory UserData.fromJson(Map<String, dynamic> json, String? userId) {
    return UserData(
        id: userId,
        fullName: json['full_name'] ?? "",
        userName: json['user_name'] ?? "",
        email: json['email'] ?? "",
        deleted: json['deleted'] ?? false,
        role: json['role'] ?? "user");
  }
}
