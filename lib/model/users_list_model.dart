class UsersListModel {
  UsersListModel({
    this.data,
    this.total,
    this.page,
    this.limit,
  });

  UsersListModel.fromJson(Map<String, dynamic> json) {
    if (json["data"] != null) {
      data = <Data>[];
      for (final dynamic item in json["data"]) {
        data?.add(Data.fromJson(item));
      }
    }
    total = json["total"];
    page = json["page"];
    limit = json["limit"];
  }

  List<Data>? data;
  int? total;
  int? page;
  int? limit;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    if (data != null) {
      map["data"] = data?.map((Data v) => v.toJson()).toList();
    }
    map["total"] = total;
    map["page"] = page;
    map["limit"] = limit;
    return map;
  }
}

class Data {
  Data({
    this.id,
    this.title,
    this.firstName,
    this.lastName,
    this.picture,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    title = json["title"];
    firstName = json["firstName"];
    lastName = json["lastName"];
    picture = json["picture"];
  }

  String? id;
  String? title;
  String? firstName;
  String? lastName;
  String? picture;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map["id"] = id;
    map["title"] = title;
    map["firstName"] = firstName;
    map["lastName"] = lastName;
    map["picture"] = picture;
    return map;
  }
}
