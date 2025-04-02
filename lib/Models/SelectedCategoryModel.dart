class SelectedCategoryModel {
  int? id;
  String? name;
  String? icon;
  int? type;

  SelectedCategoryModel({this.id, this.name,this.type, this.icon});

  SelectedCategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'].toString();
    icon = json['icon'].toString();
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['icon'] = this.icon;
    data['type'] = this.type;
    return data;
  }
}