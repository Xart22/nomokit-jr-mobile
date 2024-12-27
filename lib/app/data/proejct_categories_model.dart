import 'dart:convert';

ProjectCategoriesResponseModel projectCategoriesResponseModelFromJson(
        String str) =>
    ProjectCategoriesResponseModel.fromJson(json.decode(str));

String projectCategoriesResponseModelToJson(
        ProjectCategoriesResponseModel data) =>
    json.encode(data.toJson());

class ProjectCategoriesResponseModel {
  final String status;
  final List<ProjectCategory> categories;

  ProjectCategoriesResponseModel({
    required this.status,
    required this.categories,
  });

  factory ProjectCategoriesResponseModel.fromJson(Map<String, dynamic> json) =>
      ProjectCategoriesResponseModel(
        status: json["status"],
        categories: List<ProjectCategory>.from(
            json["categories"].map((x) => ProjectCategory.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
      };
}

class ProjectCategory {
  final String name;
  final int id;

  ProjectCategory({
    required this.name,
    required this.id,
  });

  factory ProjectCategory.fromJson(Map<String, dynamic> json) =>
      ProjectCategory(
        name: json["name"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
      };
}
