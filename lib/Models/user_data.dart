class UserData {
  bool? status;
  String? accessToken;
  String? tokenType;
  String? userId;
  String? firstName;
  String? lastName;
  String? phoneNo;
  String? email;
  String? profileImage;
  String? role;
  String? deviceToken;
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
  String? province;
  String? city;
  String? createdAt;

  UserData(
      {this.status,
      this.accessToken,
      this.tokenType,
      this.userId,
      this.firstName,
      this.lastName,
      this.phoneNo,
      this.email,
      this.profileImage,
      this.role,
      this.deviceToken,
      this.businessLogo,
      this.businessName,
      this.businessAddress,
      this.businessProvince,
      this.businessCity,
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
      this.city,
      this.province,
      this.allNotifications,
      this.bumpUpNotification,
      this.saveSearchNotification,
      this.messageNotification,
      this.marketingNotification,
      this.reviewsNotification,
      this.createdAt});

  UserData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    accessToken = json['access_token'].toString();
    tokenType = json['token_type'].toString();
    userId = json['user_id'].toString();
    firstName = json['first_name'].toString();
    lastName = json['last_name'].toString();
    phoneNo = json['phone_no'].toString();
    email = json['email'].toString();
    province = json['province'].toString();
    city = json['city'].toString();
    profileImage = json['profile_image'].toString();
    role = json['role'].toString();
    deviceToken = json['device_token'].toString();
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
    createdAt = json['created_at'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['access_token'] = this.accessToken;
    data['token_type'] = this.tokenType;
    data['user_id'] = this.userId;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['phone_no'] = this.phoneNo;
    data['email'] = this.email;
    data['province'] = this.province;
    data['city'] = this.city;
    data['profile_image'] = this.profileImage;
    data['role'] = this.role;
    data['device_token'] = this.deviceToken;
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
    data['created_at'] = this.createdAt;
    return data;
  }
}
