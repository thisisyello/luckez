class UserProfile {
  const UserProfile({
    required this.uid,
    required this.role,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  factory UserProfile.fromMap(String uid, Map<String, dynamic>? map) {
    final data = map ?? const <String, dynamic>{};

    return UserProfile(
      uid: uid,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      role: data['role'] as String? ?? 'user',
    );
  }

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String role;

  UserProfile copyWith({
    String? email,
    String? displayName,
    String? photoUrl,
    String? role,
  }) {
    return UserProfile(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
    );
  }
}
