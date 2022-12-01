class UploadCDNModel {
  UploadCDNModel({
    this.accountId,
    this.filePath,
    this.fileUrl,
  });

  UploadCDNModel.fromJson(Map<String, dynamic> json) {
    accountId = json["accountId"];
    filePath = json["filePath"];
    fileUrl = json["fileUrl"];
  }

  String? accountId;
  String? filePath;
  String? fileUrl;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map["accountId"] = accountId;
    map["filePath"] = filePath;
    map["fileUrl"] = fileUrl;
    return map;
  }
}
