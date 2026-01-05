class DataModel {
  int? errorCode;
  String? errorDescription;
  List<String>? data;

  DataModel({this.errorCode, this.errorDescription, this.data});

  DataModel.fromJson(Map<String, dynamic> json) {
    errorCode = json['Error_Code'];
    errorDescription = json['Error_Description'];
    data = json['Data'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Error_Code'] = errorCode;
    data['Error_Description'] = errorDescription;
    data['Data'] = this.data;
    return data;
  }
}

class DataModell {
  int? errorCode;
  String? errorDescription;
  List<String>? data;

  DataModell({this.errorCode, this.errorDescription, this.data});

  DataModell.fromJson(Map<String, dynamic> json) {
    errorCode = json['Error_Code'];
    errorDescription = json['Error_Description'];
    data = json['Data'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Error_Code'] = errorCode;
    data['Error_Description'] = errorDescription;
    data['Data'] = this.data;
    return data;
  }
}
