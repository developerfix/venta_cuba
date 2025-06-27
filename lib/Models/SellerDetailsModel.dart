import 'package:venta_cuba/Models/ListingModel.dart';

class SellerDetailsModel {
  bool? status;
  SellerData? data;

  SellerDetailsModel({this.status, this.data});

  SellerDetailsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? new SellerData.fromJson(json['data']) : null;
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

class SellerData {
  User? sellerAbout;
  SellerListings? sellerListings;
  SellerRatingsCount? sellerRatingsCount;
  List<SellerRatings>? sellerRatings;

  SellerData(
      {this.sellerAbout,
      this.sellerListings,
      this.sellerRatings,
      this.sellerRatingsCount});

  SellerData.fromJson(Map<String, dynamic> json) {
    sellerRatingsCount = json['seller_ratings_count'] != null
        ? new SellerRatingsCount.fromJson(json['seller_ratings_count'])
        : null;
    sellerAbout = json['seller_about'] != null
        ? new User.fromJson(json['seller_about'])
        : null;
    sellerListings = json['seller_listings'] != null
        ? new SellerListings.fromJson(json['seller_listings'])
        : null;
    if (json['seller_ratings'] != null) {
      sellerRatings = <SellerRatings>[];
      json['seller_ratings'].forEach((v) {
        sellerRatings!.add(new SellerRatings.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.sellerAbout != null) {
      data['seller_about'] = this.sellerAbout!.toJson();
    }
    if (this.sellerListings != null) {
      data['seller_listings'] = this.sellerListings!.toJson();
    }
    if (this.sellerRatings != null) {
      data['seller_ratings'] =
          this.sellerRatings!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SellerRatings {
  int? id;
  String? userId;
  String? sellerId;
  String? listingId;
  String? comment;
  String? responseTimeRating;
  String? friendlinessRating;
  String? itemAsDescribedRating;
  String? averageRating;
  String? createdTimeAgo;
  List<Users>? users;
  List<Listing>? listing;

  SellerRatings(
      {this.id,
      this.userId,
      this.sellerId,
      this.listingId,
      this.comment,
      this.responseTimeRating,
      this.friendlinessRating,
      this.itemAsDescribedRating,
      this.averageRating,
      this.createdTimeAgo,
      this.users,
      this.listing});

  SellerRatings.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'].toString();
    sellerId = json['seller_id'].toString();
    listingId = json['listing_id'].toString();
    comment = json['comment'].toString();
    responseTimeRating = json['response_time_rating'].toString();
    friendlinessRating = json['friendliness_rating'].toString();
    itemAsDescribedRating = json['item_as_described_rating'].toString();
    averageRating = json['average_rating'].toString();
    createdTimeAgo = json['created_time_ago'].toString();
    if (json['users'] != null) {
      users = <Users>[];
      json['users'].forEach((v) {
        users!.add(new Users.fromJson(v));
      });
    }
    if (json['listing'] != null) {
      listing = <Listing>[];
      json['listing'].forEach((v) {
        listing!.add(new Listing.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['seller_id'] = this.sellerId;
    data['listing_id'] = this.listingId;
    data['comment'] = this.comment;
    data['response_time_rating'] = this.responseTimeRating;
    data['friendliness_rating'] = this.friendlinessRating;
    data['item_as_described_rating'] = this.itemAsDescribedRating;
    data['average_rating'] = this.averageRating;
    if (this.users != null) {
      data['users'] = this.users!.map((v) => v.toJson()).toList();
    }
    if (this.listing != null) {
      data['listing'] = this.listing!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Users {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? province;
  String? city;
  String? profileImage;
  String? allNotifications;
  String? bumpUpNotification;
  String? saveSearchNotification;
  String? messageNotification;
  String? marketingNotification;
  String? reviewsNotification;

  Users(
      {this.id,
      this.firstName,
      this.lastName,
      this.email,
      this.phone,
      this.province,
      this.city,
      this.profileImage,
      this.allNotifications,
      this.bumpUpNotification,
      this.saveSearchNotification,
      this.messageNotification,
      this.marketingNotification,
      this.reviewsNotification});

  Users.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'].toString();
    lastName = json['last_name'].toString();
    email = json['email'].toString();
    phone = json['phone'].toString();
    province = json['province'].toString();
    city = json['city'].toString();
    profileImage = json['profile_image'].toString();
    allNotifications = json['all_notifications'].toString();
    bumpUpNotification = json['bump_up_notification'].toString();
    saveSearchNotification = json['save_search_notification'].toString();
    messageNotification = json['message_notification'].toString();
    marketingNotification = json['marketing_notification'].toString();
    reviewsNotification = json['reviews_notification'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['province'] = this.province;
    data['city'] = this.city;
    data['profile_image'] = this.profileImage;
    data['all_notifications'] = this.allNotifications;
    data['bump_up_notification'] = this.bumpUpNotification;
    data['save_search_notification'] = this.saveSearchNotification;
    data['message_notification'] = this.messageNotification;
    data['marketing_notification'] = this.marketingNotification;
    data['reviews_notification'] = this.reviewsNotification;
    return data;
  }
}

class Listing {
  int? id;
  String? userId;
  String? categoryId;
  String? subCategoryId;
  String? subSubCategoryId;
  String? title;
  List<String>? gallery;
  String? price;
  String? description;
  String? address;
  String? latitude;
  String? longitude;

  Listing(
      {this.id,
      this.userId,
      this.categoryId,
      this.subCategoryId,
      this.subSubCategoryId,
      this.title,
      this.gallery,
      this.price,
      this.description,
      this.address,
      this.latitude,
      this.longitude});

  Listing.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'].toString();
    categoryId = json['category_id'].toString();
    subCategoryId = json['sub_category_id'].toString();
    subSubCategoryId = json['sub_sub_category_id'].toString();
    title = json['title'].toString();
    gallery = json['gallery'].cast<String>();
    price = json['price'].toString();
    description = json['description'].toString();
    address = json['address'].toString();
    latitude = json['latitude'].toString();
    longitude = json['longitude'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['category_id'] = this.categoryId;
    data['sub_category_id'] = this.subCategoryId;
    data['sub_sub_category_id'] = this.subSubCategoryId;
    data['title'] = this.title;
    data['gallery'] = this.gallery;
    data['price'] = this.price;
    data['description'] = this.description;
    data['address'] = this.address;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }
}

class SellerListings {
  int? currentPage;
  List<ListingModel>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  SellerListings(
      {this.currentPage,
      this.data,
      this.firstPageUrl,
      this.from,
      this.lastPage,
      this.lastPageUrl,
      this.links,
      this.nextPageUrl,
      this.path,
      this.perPage,
      this.prevPageUrl,
      this.to,
      this.total});

  SellerListings.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    if (json['data'] != null) {
      data = <ListingModel>[];
      json['data'].forEach((v) {
        data!.add(new ListingModel.fromJson(v));
      });
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(new Links.fromJson(v));
      });
    }
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['current_page'] = this.currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = this.firstPageUrl;
    data['from'] = this.from;
    data['last_page'] = this.lastPage;
    data['last_page_url'] = this.lastPageUrl;
    if (this.links != null) {
      data['links'] = this.links!.map((v) => v.toJson()).toList();
    }
    data['next_page_url'] = this.nextPageUrl;
    data['path'] = this.path;
    data['per_page'] = this.perPage;
    data['prev_page_url'] = this.prevPageUrl;
    data['to'] = this.to;
    data['total'] = this.total;
    return data;
  }
}

class AdditionalFeatures {
  String? type;
  ListingDetails? listingDetails;
  OptionalDetails? optionalDetails;
  String? videoLink;

  AdditionalFeatures(
      {this.type, this.listingDetails, this.optionalDetails, this.videoLink});

  AdditionalFeatures.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    listingDetails = json['listing_details'] != null
        ? new ListingDetails.fromJson(json['listing_details'])
        : null;
    optionalDetails = json['optional_details'] != null
        ? new OptionalDetails.fromJson(json['optional_details'])
        : null;
    videoLink = json['video_link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    if (this.listingDetails != null) {
      data['listing_details'] = this.listingDetails!.toJson();
    }
    if (this.optionalDetails != null) {
      data['optional_details'] = this.optionalDetails!.toJson();
    }
    data['video_link'] = this.videoLink;
    return data;
  }
}

class SellerRatingsCount {
  int? oneStarRatings;
  int? twoStarRatings;
  int? threeStarRatings;
  int? fourStarRatings;
  int? fiveStarRatings;

  SellerRatingsCount(
      {this.oneStarRatings,
      this.twoStarRatings,
      this.threeStarRatings,
      this.fourStarRatings,
      this.fiveStarRatings});

  SellerRatingsCount.fromJson(Map<String, dynamic> json) {
    oneStarRatings = json['one_star_ratings'];
    twoStarRatings = json['two_star_ratings'];
    threeStarRatings = json['three_star_ratings'];
    fourStarRatings = json['four_star_ratings'];
    fiveStarRatings = json['five_star_ratings'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['one_star_ratings'] = this.oneStarRatings;
    data['two_star_ratings'] = this.twoStarRatings;
    data['three_star_ratings'] = this.threeStarRatings;
    data['four_star_ratings'] = this.fourStarRatings;
    data['five_star_ratings'] = this.fiveStarRatings;
    return data;
  }
}

class ListingDetails {
  String? make;
  String? model;
  String? furnished;
  String? jobType;

  ListingDetails({this.make, this.model, this.furnished, this.jobType});

  ListingDetails.fromJson(Map<String, dynamic> json) {
    make = json['make'];
    model = json['model'];
    furnished = json['furnished'];
    jobType = json['job_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['make'] = this.make;
    data['model'] = this.model;
    data['furnished'] = this.furnished;
    data['job_type'] = this.jobType;
    return data;
  }
}

class OptionalDetails {
  String? phoneNumber;
  String? condition;
  String? fulfillment;
  String? payment;

  OptionalDetails(
      {this.phoneNumber, this.condition, this.fulfillment, this.payment});

  OptionalDetails.fromJson(Map<String, dynamic> json) {
    phoneNumber =
        json['phone_number'] != null ? json['phone_number'].toString() : null;
    condition = json['condition'] != null ? json['condition'].toString() : null;
    fulfillment =
        json['fulfillment'] != null ? json['fulfillment'].toString() : null;
    payment = json['payment'] != null ? json['payment'].toString() : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['phone_number'] = this.phoneNumber;
    data['condition'] = this.condition;
    data['fulfillment'] = this.fulfillment;
    data['payment'] = this.payment;
    return data;
  }
}

class Category {
  int? id;
  String? name;
  String? icon;

  Category({this.id, this.name, this.icon});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    icon = json['icon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['icon'] = this.icon;
    return data;
  }
}

class SubCategory {
  int? id;
  String? categoryId;
  String? name;

  SubCategory({this.id, this.categoryId, this.name});

  SubCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryId = json['category_id'].toString();
    name = json['name'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['category_id'] = this.categoryId;
    data['name'] = this.name;
    return data;
  }
}

class SubSubCategory {
  int? id;
  String? categoryId;
  String? subCategoryId;
  String? name;

  SubSubCategory({this.id, this.categoryId, this.subCategoryId, this.name});

  SubSubCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryId = json['category_id'].toString();
    subCategoryId = json['sub_category_id'].toString();
    name = json['name'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['category_id'] = this.categoryId;
    data['sub_category_id'] = this.subCategoryId;
    data['name'] = this.name;
    return data;
  }
}

class Links {
  String? url;
  String? label;
  bool? active;

  Links({this.url, this.label, this.active});

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label'];
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['label'] = this.label;
    data['active'] = this.active;
    return data;
  }
}
