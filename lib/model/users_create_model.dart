class UsersCreateModel {
  UsersCreateModel({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.registerDate,
    this.updatedDate,
  });

  UsersCreateModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    firstName = json["firstName"];
    lastName = json["lastName"];
    email = json["email"];
    registerDate = json["registerDate"];
    updatedDate = json["updatedDate"];
  }

  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? registerDate;
  String? updatedDate;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map["id"] = id;
    map["firstName"] = firstName;
    map["lastName"] = lastName;
    map["email"] = email;
    map["registerDate"] = registerDate;
    map["updatedDate"] = updatedDate;
    return map;
  }
}
