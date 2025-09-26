class AuthProfile {
  final String provider; // google/kakao/naver
  final String id;
  final String? email;
  final String? name;
  final String? avatarUrl;
  final String accessToken;
  final String? refreshToken;

  AuthProfile({
    required this.provider,
    required this.id,
    required this.accessToken,
    this.refreshToken,
    this.email,
    this.name,
    this.avatarUrl,
  });

  @override
  String toString() {
    return 'AuthProfile(provider: $provider, id: $id, email: $email, name: $name)';
  }
}
