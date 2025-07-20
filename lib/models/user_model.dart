class AppUser {
  final String uid;
  final String? email;
  final String? displayName;

  AppUser({required this.uid, this.email, this.displayName});

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      email: map['email'],
      displayName: map['displayName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
    };
  }
}
