class AllPromoCodesModel {
  bool? status;
  List<PromoCode>? message;

  AllPromoCodesModel({this.status, this.message});

  AllPromoCodesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['message'] != null) {
      message = <PromoCode>[];
      json['message'].forEach((v) {
        message!.add(new PromoCode.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.message != null) {
      data['message'] = this.message!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PromoCode {
  int? id;
  String? promoCode;
  String? status;

  PromoCode({this.id, this.promoCode, this.status});

  PromoCode.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    promoCode = json['promo_code'].toString();
    status = json['status'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['promo_code'] = this.promoCode;
    data['status'] = this.status;
    return data;
  }
}
