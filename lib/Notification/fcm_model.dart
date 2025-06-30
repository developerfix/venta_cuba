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

  Data(
      {this.userId,
      this.remoteId,
      this.name,
      this.profileImage,
      this.title,
      this.body,
      this.type});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    remoteId = json['remote_id'];
    name = json['name'];
    profileImage = json['profile_image'];
    title = json['title'];
    body = json['body'];
    type = json['type'];
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



















// class FCMModel {
// String? clickAction;
// String? priority;
// Data? data;
// Notifications? notification;
// Android? android;
// Apns? apns;
// String? to;
//
// FCMModel(
//     {this.clickAction,
//       this.priority,
//       this.data,
//       this.notification,
//       this.android,
//       this.apns,
//       this.to});
//
// FCMModel.fromJson(Map<String, dynamic> json) {
// clickAction = json['click_action'];
// priority = json['priority'];
// data = json['data'] != null ? Data.fromJson(json['data']) : null;
// notification = json['notification'] != null
// ? Notifications.fromJson(json['notification'])
//     : null;
// android =
// json['android'] != null ? Android.fromJson(json['android']) : null;
// apns = json['apns'] != null ? Apns.fromJson(json['apns']) : null;
// to = json['to'];
// }
//
// Map<String, dynamic> toJson() {
//   final Map<String, dynamic> data = <String, dynamic>{};
//   data['click_action'] = clickAction;
//   data['priority'] = priority;
//   if (this.data != null) {
//     data['data'] = this.data!.toJson();
//   }
//   if (notification != null) {
//     data['notification'] = notification!.toJson();
//   }
//   if (android != null) {
//     data['android'] = android!.toJson();
//   }
//   if (apns != null) {
//     data['apns'] = apns!.toJson();
//   }
//   data['to'] = to;
//   return data;
// }
// }
// class Data {
//   String? id;
//   String? uid;
//   String? myuid;
//   String? clientuid;
//   String? name;
//   String? status;
//   String? title;
//   String? appointmentStatus;
//   String? body;
//   String? type;
//
//   Data({this.id, this.uid, this.status, this.title,this.appointmentStatus, this.body, this.type, this.myuid, this.clientuid, this.name});
//
//   Data.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     myuid = json['myuid'];
//     name = json['name'];
//     clientuid = json['clientuid'];
//     uid = json['uid'];
//     status = json['status'];
//     title = json['title'];
//     appointmentStatus = json['appointmentStatus'];
//     body = json['body'];
//     type = json['type'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['uid'] = uid;
//     data['clientuid'] = clientuid;
//     data['name'] = name;
//     data['myuid'] = myuid;
//     data['status'] = status;
//     data['title'] = title;
//     data['appointmentStatus'] = appointmentStatus;
//     data['body'] = body;
//     data['type'] = type;
//     return data;
//   }
// }
// class NotificationA {
//   String? clickAction;
//
//   NotificationA({this.clickAction});
//
//   NotificationA.fromJson(Map<String, dynamic> json) {
//     clickAction = json['click_action'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['click_action'] = clickAction;
//     return data;
//   }
// }
// class Notifications {
//   String? title;
//   String? body;
//   dynamic sound;
//
//   Notifications({this.title, this.body, this.sound});
//
//   Notifications.fromJson(Map<String, dynamic> json) {
//     title = json['title'];
//     body = json['body'];
//     sound = json['sound'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['title'] = title;
//     data['sound'] = sound;
//     data['body'] = body;
//     return data;
//   }
// }
//
// class Android {
//   String? ttl;
//   NotificationA? notification;
//
//   Android({this.ttl, this.notification});
//
//   Android.fromJson(Map<String, dynamic> json) {
//     ttl = json['ttl'];
//     notification = json['notification'] != null
//         ? NotificationA.fromJson(json['notification'])
//         : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['ttl'] = ttl;
//     if (notification != null) {
//       data['notification'] = notification!.toJson();
//     }
//     return data;
//   }
// }
//
//
// class Apns {
//   Headers? headers;
//   Payload? payload;
//
//   Apns({this.headers, this.payload});
//
//   Apns.fromJson(Map<String, dynamic> json) {
//     headers =
//     json['headers'] != null ? Headers.fromJson(json['headers']) : null;
//     payload =
//     json['payload'] != null ? Payload.fromJson(json['payload']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     if (headers != null) {
//       data['headers'] = headers!.toJson();
//     }
//     if (payload != null) {
//       data['payload'] = payload!.toJson();
//     }
//     return data;
//   }
// }
//
// class Headers {
//   String? apnsPriority;
//
//   Headers({this.apnsPriority});
//
//   Headers.fromJson(Map<String, dynamic> json) {
//     apnsPriority = json['apns-priority'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['apns-priority'] = apnsPriority;
//     return data;
//   }
// }
//
// class Payload {
//   Aps? aps;
//
//   Payload({this.aps});
//
//   Payload.fromJson(Map<String, dynamic> json) {
//     aps = json['aps'] != null ? Aps.fromJson(json['aps']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     if (aps != null) {
//       data['aps'] = aps!.toJson();
//     }
//     return data;
//   }
// }
//
// class Aps {
//   String? category;
//   String? sound;
//
//   Aps({this.category,this.sound});
//
//   Aps.fromJson(Map<String, dynamic> json) {
//     category = json['category'];
//     sound = json['sound'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['category'] = category;
//     data['sound'] = sound;
//     return data;
//   }
// }