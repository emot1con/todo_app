class TokenModel {
  final String accessToken;
  final String exp;
  final String expRefreshToken;
  final String refreshToken;
  final String role;

  TokenModel({
    required this.accessToken,
    required this.exp,
    required this.expRefreshToken,
    required this.refreshToken,
    required this.role,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) =>
      TokenModel(
        accessToken: json["accesToken"],
        exp: json["exp"],
        expRefreshToken: json["expRefreshToken"],
        refreshToken: json["refreshToken"],
        role: json["role"],
      );

  Map<String, dynamic> toJson() => {
        "accesToken": accessToken,
        "exp": exp,
        "expRefreshToken": expRefreshToken,
        "refreshToken": refreshToken,
        "role": role,
      };
}
