import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../Controllers/home_controller.dart';
class UserPreferences {
  static const _saveHistory = 'saveHistory';
  setSaveHistory(String data) async {
    bool isMatchAddress=false;
    for (var element in beforeData) {
      if(jsonDecode(element)["address"]==jsonDecode(data)["address"]){
        isMatchAddress=true;
        return;
      }
    }
    if(!isMatchAddress){
      if(beforeData.length==5){
        beforeData.removeAt(4);
        beforeData.add(data);
      }else{
        beforeData.add(data);
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setStringList(_saveHistory, beforeData);
    }

  }
  Future<List<String>> getSaveHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_saveHistory) ?? <String>[];
  }
}
