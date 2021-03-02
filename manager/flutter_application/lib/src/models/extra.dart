import '../models/extra_group.dart';

import '../models/media.dart';

class Extra {
  String id;
  String extraGroupId;
  String name;
  double price;
  Media image;
  String description;
  bool checked;
  int active;
  List<ExtraGroup> extraGroups;

  Extra();

  Extra.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      extraGroupId = jsonMap['extra_group_id'] != null ? jsonMap['extra_group_id'].toString() : '0';
      name = jsonMap['name'].toString();
      price = jsonMap['price'] != null ? jsonMap['price'].toDouble() : 0;
      description = jsonMap['description'];
      checked = false;
      active = jsonMap['active'];
      extraGroups = jsonMap['extra_group'] != null ? List.from(jsonMap['extra_group']).map((element) => ExtraGroup.fromJSON(element)).toList() : null;
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0]) : new Media();
    } catch (e) {
      id = '';
      extraGroupId = '0';
      name = '';
      price = 0.0;
      description = '';
      checked = false;
      active = 0;
      extraGroups = [];
      image = new Media();
      print(e);
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["name"] = name;
    map["price"] = price;
    map["description"] = description;
    return map;
  }

  Map statusExtraOff() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["active"] = false;
    return map;
  }

  Map statusExtraOn() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["active"] = true;
    return map;
  }

  @override
  bool operator ==(dynamic other) {
    return other.id == this.id;
  }

  @override
  int get hashCode => this.id.hashCode;
}
