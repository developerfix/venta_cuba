class CheckUserPackageModel {
  bool? status;
  Data? data;

  CheckUserPackageModel({this.status, this.data});

  CheckUserPackageModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? packageId;
  String? startDate;
  String? endDate;
  String? status;
  int? remainingDays;
  int? listingCount;

  Data(
      {this.packageId,
        this.startDate,
        this.endDate,
        this.remainingDays,
        this.status,
        this.listingCount});

  Data.fromJson(Map<String, dynamic> json) {
    packageId = json['package_id'].toString();
    startDate = json['start_date'].toString();
    endDate = json['end_date'].toString();
    status = json['status'] == null ? '': json['status'].toString();
    remainingDays = json['remaining_days'];
    listingCount = json['listing_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['package_id'] = this.packageId;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['remaining_days'] = this.remainingDays;
    data['listing_count'] = this.listingCount;
    return data;
  }
}
