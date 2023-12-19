/*
 * Copyright (c) 2020 .
 */

import 'dart:core';

import 'parents/model.dart';

class Award extends Model {
  String? _title;

  String get title => _title ?? '';

  set title(String? value) {
    _title = value;
  }

  String? _description;

  String get description => _description ?? '';

  set description(String? value) {
    _description = value;
  }

  Award({String? id, String? title, String? description}) {
    _description = description;
    _title = title;
    this.id = id;
  }

  Award.fromJson(Map<String, dynamic>? json) {
    super.fromJson(json);
    _title = transStringFromJson(json, 'title');
    _description = transStringFromJson(json, 'description');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this._title;
    data['description'] = this._description;
    return data;
  }
}
