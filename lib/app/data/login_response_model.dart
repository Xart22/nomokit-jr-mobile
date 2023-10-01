import 'dart:convert';

LoginResponseModel loginResponseModelFromJson(String str) =>
    LoginResponseModel.fromJson(json.decode(str));

String loginResponseModelToJson(LoginResponseModel data) =>
    json.encode(data.toJson());

class LoginResponseModel {
  final User user;
  final String token;

  LoginResponseModel({
    required this.user,
    required this.token,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        user: User.fromJson(json["user"]),
        token: json["token"],
      );

  Map<String, dynamic> toJson() => {
        "user": user.toJson(),
        "token": token,
      };
}

class User {
  final String id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String avatar;
  final String collageName;
  final String collageAddress;
  final String? country;
  final String city;
  final String province;
  final String? tglLahir;
  final Subscriptions? subscriptions;
  final Trial? trial;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.collageName,
    required this.collageAddress,
    this.country,
    required this.city,
    required this.province,
    required this.tglLahir,
    required this.subscriptions,
    required this.trial,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        username: json["username"],
        email: json["email"],
        phone: json["phone"],
        avatar: json["avatar"],
        collageName: json["collage_name"],
        collageAddress: json["collage_address"],
        country: json["country"],
        city: json["city"],
        province: json["province"],
        tglLahir: json["tgl_lahir"],
        subscriptions: json["subscriptions"] == null
            ? null
            : Subscriptions.fromJson(json["subscriptions"]),
        trial: json["trial"] == null ? null : Trial.fromJson(json["trial"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "username": username,
        "email": email,
        "phone": phone,
        "avatar": avatar,
        "collage_name": collageName,
        "collage_address": collageAddress,
        "country": country,
        "city": city,
        "province": province,
        "tgl_lahir": tglLahir,
        "subscriptions": subscriptions?.toJson(),
        "trial": trial?.toJson(),
      };
}

class Subscriptions {
  final int id;
  final String userId;
  final String packageId;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int isActive;
  final int sendEmail;

  Subscriptions({
    required this.id,
    required this.userId,
    required this.packageId,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.sendEmail,
  });

  factory Subscriptions.fromJson(Map<String, dynamic> json) => Subscriptions(
        id: json["id"],
        userId: json["user_id"],
        packageId: json["package_id"],
        startDate: DateTime.parse(json["start_date"]),
        endDate: DateTime.parse(json["end_date"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        isActive: json["is_active"],
        sendEmail: json["send_email"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "package_id": packageId,
        "start_date":
            "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
        "end_date":
            "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "is_active": isActive,
        "send_email": sendEmail,
      };
}

class Trial {
  final DateTime endDate;
  final int isActive;

  Trial({
    required this.endDate,
    required this.isActive,
  });

  factory Trial.fromJson(Map<String, dynamic> json) => Trial(
        endDate: DateTime.parse(json["trial_ends"]),
        isActive: json["is_active"],
      );

  Map<String, dynamic> toJson() => {
        "trial_ends":
            "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
        "is_active": isActive,
      };
}
