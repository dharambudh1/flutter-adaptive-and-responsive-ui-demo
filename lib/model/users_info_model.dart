class UsersInfoModel {
  UsersInfoModel({
    this.id,
    this.title,
    this.firstName,
    this.lastName,
    this.picture,
    this.gender,
    this.email,
    this.dateOfBirth,
    this.phone,
    this.location,
    this.registerDate,
    this.updatedDate,
  });

  UsersInfoModel.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    title = json["title"];
    firstName = json["firstName"];
    lastName = json["lastName"];
    picture = json["picture"];
    gender = json["gender"];
    email = json["email"];
    dateOfBirth = json["dateOfBirth"];
    phone = json["phone"];
    location =
        json["location"] != null ? Location.fromJson(json["location"]) : null;
    registerDate = json["registerDate"];
    updatedDate = json["updatedDate"];
  }

  String? id;
  String? title;
  String? firstName;
  String? lastName;
  String? picture;
  String? gender;
  String? email;
  String? dateOfBirth;
  String? phone;
  Location? location;
  String? registerDate;
  String? updatedDate;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map["id"] = id;
    map["title"] = title;
    map["firstName"] = firstName;
    map["lastName"] = lastName;
    map["picture"] = picture;
    map["gender"] = gender;
    map["email"] = email;
    map["dateOfBirth"] = dateOfBirth;
    map["phone"] = phone;
    if (location != null) {
      map["location"] = location?.toJson();
    }
    map["registerDate"] = registerDate;
    map["updatedDate"] = updatedDate;
    return map;
  }
}

class Location {
  Location({
    this.street,
    this.city,
    this.state,
    this.country,
    this.timezone,
  });

  Location.fromJson(Map<String, dynamic> json) {
    street = json["street"];
    city = json["city"];
    state = json["state"];
    country = json["country"];
    timezone = json["timezone"];
  }

  String? street;
  String? city;
  String? state;
  String? country;
  String? timezone;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map["street"] = street;
    map["city"] = city;
    map["state"] = state;
    map["country"] = country;
    map["timezone"] = timezone;
    return map;
  }
}
