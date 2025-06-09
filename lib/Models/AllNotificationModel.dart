class AllNotificationModel {
  bool? status;
  List<Data>? data;

  AllNotificationModel({this.status, this.data});

  AllNotificationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? message;
  String? timestamp; // Added timestamp field

  Data({this.id, this.message, this.timestamp});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    message = json['message'].toString();
    timestamp = json['timestamp']; // Assuming server provides this
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['message'] = this.message;
    data['timestamp'] = this.timestamp;
    return data;
  }
}
