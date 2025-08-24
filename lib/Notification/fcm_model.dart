class FCMModel {
  Data? data;
  NotificationData? notification;
  String? token;
  ApnsConfig? apns;

  FCMModel({this.data, this.notification, this.token, this.apns});

  FCMModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    notification = json['notification'] != null
        ? NotificationData.fromJson(json['notification'])
        : null;
    token = json['token'];
    apns = json['apns'] != null ? ApnsConfig.fromJson(json['apns']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    if (notification != null) {
      data['notification'] = notification!.toJson();
    }
    if (apns != null) {
      data['apns'] = apns!.toJson();
    }
    data['token'] = token;
    return data;
  }
}

class Data {
  String? userId;
  String? remoteId;
  String? name;
  String? profileImage;
  String? title;
  String? body;
  String? type;
  String? chatId;  // Added for chat navigation

  Data(
      {this.userId,
      this.remoteId,
      this.name,
      this.profileImage,
      this.title,
      this.body,
      this.type,
      this.chatId});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    remoteId = json['remote_id'];
    name = json['name'];
    profileImage = json['profile_image'];
    title = json['title'];
    body = json['body'];
    type = json['type'];
    chatId = json['chat_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['remote_id'] = remoteId;
    data['name'] = name;
    data['profile_image'] = profileImage;
    data['title'] = title;
    data['body'] = body;
    data['type'] = type;
    if (chatId != null) data['chat_id'] = chatId;
    return data;
  }
}

class NotificationData {
  String? title;
  String? body;

  NotificationData({this.title, this.body});

  NotificationData.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    body = json['body'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['body'] = body;
    return data;
  }
}

class ApnsConfig {
  ApnsPayload? payload;

  ApnsConfig({this.payload});

  ApnsConfig.fromJson(Map<String, dynamic> json) {
    payload =
        json['payload'] != null ? ApnsPayload.fromJson(json['payload']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (payload != null) {
      data['payload'] = payload!.toJson();
    }
    return data;
  }
}

class ApnsPayload {
  Aps? aps;

  ApnsPayload({this.aps});

  ApnsPayload.fromJson(Map<String, dynamic> json) {
    aps = json['aps'] != null ? Aps.fromJson(json['aps']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (aps != null) {
      data['aps'] = aps!.toJson();
    }
    return data;
  }
}

class Aps {
  int? badge;
  String? sound;
  dynamic alert;
  bool? contentAvailable;
  bool? mutableContent;

  Aps(
      {this.badge,
      this.sound,
      this.alert,
      this.contentAvailable,
      this.mutableContent});

  Aps.fromJson(Map<String, dynamic> json) {
    badge = json['badge'];
    sound = json['sound'];
    alert = json['alert'];
    contentAvailable = json['content-available'];
    mutableContent = json['mutable-content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (badge != null) {
      data['badge'] = badge;
    }
    if (sound != null) {
      data['sound'] = sound;
    }
    if (alert != null) {
      data['alert'] = alert;
    }
    if (contentAvailable != null) {
      data['content-available'] = contentAvailable! ? 1 : 0;
    }
    if (mutableContent != null) {
      data['mutable-content'] = mutableContent! ? 1 : 0;
    }
    return data;
  }
}
