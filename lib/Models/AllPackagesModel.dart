class AllPackagesModel {
  bool? status;
  List<PackageData>? data;

  AllPackagesModel({this.status, this.data});

  AllPackagesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <PackageData>[];
      json['data'].forEach((v) {
        data!.add(new PackageData.fromJson(v));
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

class PackageData {
  int? id;
  String? name;
  String? description;
  String? price;
  String? type;

  PackageData({this.id, this.name, this.description, this.price, this.type});

  PackageData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'].toString();
    description = json['description'].toString();
    price = json['price'].toString();
    type = json['type'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['price'] = this.price;
    data['type'] = this.type;
    return data;
  }
}
