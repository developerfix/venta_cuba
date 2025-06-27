class ListingModel {
  int? id;
  String? userId;
  String? itemId;
  String? categoryId;
  String? subCategoryId;
  String? subSubCategoryId;
  String? title;
  List<String>? gallery;
  String? price;
  String? currency;
  String? description;
  String? address;
  String? longitude;
  String? latitude;
  String? updatedAt;
  List? tag;
  AdditionalFeatures? additionalFeatures;
  String? averageRating;
  String? status;
  String? soldStatus;
  String? isFavorite;
  String? isSellerFavorite;
  String? businessStatus;
  User? user;
  Category? category;
  SubCategory? subCategory;
  SubSubCategory? subSubCategory;

  ListingModel(
      {this.id,
      this.userId,
      this.currency,
      this.categoryId,
      this.subCategoryId,
      this.subSubCategoryId,
      this.title,
      this.latitude,
      this.longitude,
      this.gallery,
      this.price,
      this.businessStatus,
      this.description,
      this.address,
      this.tag,
      this.itemId,
      this.additionalFeatures,
      this.averageRating,
      this.status,
      this.soldStatus,
      this.isFavorite,
      this.isSellerFavorite,
      this.user,
      this.category,
      this.subCategory,
      this.updatedAt,
      this.subSubCategory});

  ListingModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'].toString();
    currency = json['currency'].toString();
    categoryId = json['category_id'].toString();
    subCategoryId = json['sub_category_id'].toString();
    subSubCategoryId = json['sub_sub_category_id'].toString();
    title = json['title'].toString();
    ;
    businessStatus = json['business_status'].toString();
    itemId = json['item_id'].toString();
    ;
    longitude = json['longitude'].toString();
    latitude = json['latitude'].toString();
    if (json['gallery'] != null) {
      gallery = json['gallery'].cast<String>();
    }
    price = json['price'].toString();
    description = json['description'];
    updatedAt = json['updated_at'];
    address = json['address'];
    tag = json['tag'];
    additionalFeatures = json['additional_features'] != null
        ? new AdditionalFeatures.fromJson(json['additional_features'])
        : null;
    averageRating = json['average_rating'].toString();
    ;
    status = json['status'].toString();
    soldStatus = json['sold_status'].toString();
    isFavorite = json['isFavorite'].toString();
    isSellerFavorite = json['isFavoriteSeller'].toString() ?? "0";
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
    category = json['category'] != null
        ? new Category.fromJson(json['category'])
        : null;
    subCategory = json['sub_category'] != null
        ? new SubCategory.fromJson(json['sub_category'])
        : null;
    subSubCategory = json['sub_sub_category'] != null
        ? new SubSubCategory.fromJson(json['sub_sub_category'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['item_id'] = this.itemId;
    data['currency'] = this.currency;
    data['category_id'] = this.categoryId;
    data['sub_category_id'] = this.subCategoryId;
    data['sub_sub_category_id'] = this.subSubCategoryId;
    data['title'] = this.title;
    data['longitude'] = this.longitude;
    data['latitude'] = this.latitude;
    data['gallery'] = this.gallery;
    data['price'] = this.price;
    data['business_status'] = this.businessStatus;
    data['description'] = this.description;
    data['address'] = this.address;
    data['updated_at'] = this.updatedAt;
    data['tag'] = this.tag;
    if (this.additionalFeatures != null) {
      data['additional_features'] = this.additionalFeatures!.toJson();
    }
    data['average_rating'] = this.averageRating;
    data['status'] = this.status;
    data['sold_status'] = this.soldStatus;
    data['isFavorite'] = this.isFavorite;
    data['isSellerFavorite'] = this.isSellerFavorite;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    if (this.category != null) {
      data['category'] = this.category!.toJson();
    }
    if (this.subCategory != null) {
      data['sub_category'] = this.subCategory!.toJson();
    }
    if (this.subSubCategory != null) {
      data['sub_sub_category'] = this.subSubCategory!.toJson();
    }
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

class ListingDetails {
  String? make;
  String? model;
  String? furnished;
  String? jobType;

  ListingDetails({this.make, this.model, this.furnished, this.jobType});

  ListingDetails.fromJson(Map<String, dynamic> json) {
    make = json['make'].toString();
    model = json['model'].toString();
    furnished = json['furnished'].toString();
    jobType = json['job_type'].toString();
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
  String? website;
  String? condition;
  String? fulfillment;
  String? payment;

  OptionalDetails(
      {this.phoneNumber,
      this.website,
      this.condition,
      this.fulfillment,
      this.payment});

  OptionalDetails.fromJson(Map<String, dynamic> json) {
    phoneNumber =
        json['phone_number'] != null ? json['phone_number'].toString() : null;
    website = json['website'] != null ? json['website'].toString() : null;
    condition = json['condition'] != null ? json['condition'].toString() : null;
    fulfillment =
        json['fulfillment'] != null ? json['fulfillment'].toString() : null;
    payment = json['payment'] != null ? json['payment'].toString() : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['phone_number'] = this.phoneNumber;
    data['website'] = this.website;
    data['condition'] = this.condition;
    data['fulfillment'] = this.fulfillment;
    data['payment'] = this.payment;
    return data;
  }
}

class User {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? deviceToken;
  String? phone;
  String? profileImage;
  String? businessLogo;
  String? businessName;
  String? businessAddress;
  String? businessProvince;
  String? businessCity;
  String? instagramLink;
  String? facebookLink;
  String? pinterestLink;
  String? twitterLink;
  String? linkedinLink;
  String? youtubeLink;
  String? tiktokLink;

  String? businessInstagramLink;
  String? businessFacebookLink;
  String? businessPinterestLink;
  String? businessTwitterLink;
  String? businessLinkedinLink;
  String? businessYoutubeLink;
  String? businessTiktokLink;
  String? averageRating;
  String? allNotifications;
  String? bumpUpNotification;
  String? saveSearchNotification;
  String? messageNotification;
  String? marketingNotification;
  String? reviewsNotification;
  String? accountDuration;

  User(
      {this.id,
      this.firstName,
      this.lastName,
      this.email,
      this.phone,
      this.profileImage,
      this.businessLogo,
      this.businessName,
      this.businessAddress,
      this.businessProvince,
      this.businessCity,
      this.deviceToken,
      this.instagramLink,
      this.facebookLink,
      this.pinterestLink,
      this.twitterLink,
      this.linkedinLink,
      this.tiktokLink,
      this.youtubeLink,
      this.businessYoutubeLink,
      this.businessTiktokLink,
      this.businessPinterestLink,
      this.businessTwitterLink,
      this.businessLinkedinLink,
      this.businessFacebookLink,
      this.businessInstagramLink,
      this.averageRating,
      this.allNotifications,
      this.bumpUpNotification,
      this.saveSearchNotification,
      this.messageNotification,
      this.marketingNotification,
      this.reviewsNotification,
      this.accountDuration});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    firstName = json['first_name'].toString();
    lastName = json['last_name'].toString();
    email = json['email'].toString();
    phone = json['phone'].toString();
    deviceToken = json['device_token'].toString();
    profileImage = json['profile_image'].toString();
    businessLogo = json['business_logo'].toString();
    businessName = json['business_name'].toString();
    businessAddress = json['business_address'].toString();
    businessProvince = json['business_province'].toString();
    businessCity = json['business_city'].toString();
    instagramLink = json['instagram_link'].toString();
    facebookLink = json['facebook_link'].toString();
    pinterestLink = json['pinterest_link'].toString();
    twitterLink = json['twitter_link'].toString();
    linkedinLink = json['linkedin_link'].toString();
    tiktokLink = json['tiktok_link'].toString();
    youtubeLink = json['youtube_link'].toString();

    businessInstagramLink = json['business_instagram_link'].toString();
    businessFacebookLink = json['business_facebook_link'].toString();
    businessPinterestLink = json['business_pinterest_link'].toString();
    businessTiktokLink = json['business_twitter_link'].toString();
    businessLinkedinLink = json['business_linkedin_link'].toString();
    businessTiktokLink = json['business_tiktok_link'].toString();
    businessYoutubeLink = json['business_youtube_link'].toString();
    averageRating = json['average_rating'].toString();
    allNotifications = json['all_notifications'].toString();
    bumpUpNotification = json['bump_up_notification'].toString();
    saveSearchNotification = json['save_search_notification'].toString();
    messageNotification = json['message_notification'].toString();
    marketingNotification = json['marketing_notification'].toString();
    reviewsNotification = json['reviews_notification'].toString();
    accountDuration = json['account_duration'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['device_token'] = this.deviceToken;
    data['profile_image'] = this.profileImage;
    data['business_logo'] = this.businessLogo;
    data['business_name'] = this.businessName;
    data['business_address'] = this.businessAddress;
    data['business_province'] = this.businessProvince;
    data['business_city'] = this.businessCity;
    data['instagram_link'] = this.instagramLink;
    data['facebook_link'] = this.facebookLink;
    data['pinterest_link'] = this.pinterestLink;
    data['twitter_link'] = this.twitterLink;
    data['linkedin_link'] = this.linkedinLink;
    data['youtube_link'] = this.youtubeLink;
    data['tiktok_link'] = this.tiktokLink;
    data['business_instagram_link'] = this.businessInstagramLink;
    data['business_facebook_link'] = this.businessFacebookLink;
    data['business_pinterest_link'] = this.businessPinterestLink;
    data['business_twitter_link'] = this.businessTwitterLink;
    data['business_linkedin_link'] = this.businessLinkedinLink;
    data['business_youtube_link'] = this.businessYoutubeLink;
    data['business_tiktok_link'] = this.businessTiktokLink;
    data['average_rating'] = this.averageRating;
    data['all_notifications'] = this.allNotifications;
    data['bump_up_notification'] = this.bumpUpNotification;
    data['save_search_notification'] = this.saveSearchNotification;
    data['message_notification'] = this.messageNotification;
    data['marketing_notification'] = this.marketingNotification;
    data['reviews_notification'] = this.reviewsNotification;
    data['account_duration'] = this.accountDuration;
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
    ;
    name = json['name'].toString();
    ;
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
    ;
    subCategoryId = json['sub_category_id'].toString();
    ;
    name = json['name'].toString();
    ;
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
