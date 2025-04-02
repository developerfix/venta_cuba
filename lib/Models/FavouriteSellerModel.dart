class FavouriteSellerModel {
  bool? status;
  List<Data>? data;

  FavouriteSellerModel({this.status, this.data});

  FavouriteSellerModel.fromJson(Map<String, dynamic> json) {
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
  String? sellerId;
  String? profileImage;
  String? firstName;
  String? lastName;
  String? phone;
  String? email;
  String? businessName;
  String? businessLogo;
  String? averageRating;
  String? deviceToken;
  String? type;

  Data(
      {this.sellerId,
        this.profileImage,
        this.firstName,
        this.lastName,
        this.phone,
        this.email,
        this.businessName,
        this.businessLogo,
        this.averageRating,
        this.deviceToken,
        this.type});

  Data.fromJson(Map<String, dynamic> json) {
    sellerId = json['seller_id'].toString();
    profileImage = json['profile_image'].toString();
    firstName = json['first_name'].toString();
    lastName = json['last_name'].toString();
    phone = json['phone'].toString();
    email = json['email'].toString();
    businessName = json['business_name'].toString();
    businessLogo = json['business_logo'].toString();
    averageRating = json['average_rating'].toString();
    deviceToken = json['device_token'].toString();
    type = json['type'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['seller_id'] = this.sellerId;
    data['profile_image'] = this.profileImage;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['business_name'] = this.businessName;
    data['business_logo'] = this.businessLogo;
    data['average_rating'] = this.averageRating;
    data['device_token'] = this.deviceToken;
    data['type'] = this.type;
    return data;
  }
}
