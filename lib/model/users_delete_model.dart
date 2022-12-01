class UsersDeleteModel {
  UsersDeleteModel({
    this.id,
  });

  UsersDeleteModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
  }

  String? id;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map["id"] = id;
    return map;
  }
}
