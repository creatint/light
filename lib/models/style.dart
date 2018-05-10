import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../services/system.dart';
import '../utils/constants.dart';

enum BackgroundType { color, image, texture }

class Style {
  const Style({
    this.backgroundType,
    this.fontColor,
    this.backgroundColor,
    this.imageUri,
  });

  Style.fromJson(Map<String, dynamic> json)
      : this.backgroundType = BackgroundType.values.firstWhere(
            (v) => v.toString() == json['backgroundType'],
            orElse: () => BackgroundType.color),
        this.fontColor =
            null != json['fontColor'] ? new Color(json['fontColor']) : null,
        this.backgroundColor = null != json['backgroundColor']
            ? new Color(json['backgroundColor'])
            : null,
        this.imageUri = json['imageUri'];

  Map<String, dynamic> toJson() {
    return {
      'backgroundType': backgroundType.toString(),
      'backgroundColor': backgroundColor?.value ?? null,
      'fontColor': fontColor.value,
      'imageUri': imageUri
    };
  }

  static int _currentId;

  static int get currentId {
    if (null == _currentId) {
      if (null != service.getInt(style_current_id)) {
        _currentId = service.getInt(style_current_id);
      } else {
        currentId = 0;
        service.setInt(style_current_id, currentId);
      }
    }
    return _currentId;
  }

  static set currentId(int id) {
    _currentId = id;
    service.setInt(style_current_id, currentId);
  }

  static FutureOr<List<Style>> init() async {
    if (null == values || values.isEmpty) {
      List<dynamic> json;
      if (null != service.getString(styles_key)) {
        json = jsonDecode(service.getString(styles_key));
      }
      if (null == json || json.isEmpty) {
        /// get styles from assets
        String raw = await rootBundle.loadString('assets/styles.json');
        if (null != raw && raw.isNotEmpty) {
          json = jsonDecode(raw);
        }
        if (null == json || json.isEmpty) {
          values = [
            new Style(
                backgroundColor: const Color(0xffffffff),
                fontColor: const Color(0xff424142),
                backgroundType: BackgroundType.color)
          ];
        } else {
          values =
              json.map<Style>((value) => new Style.fromJson(value)).toList();
        }
        if (null != values) {
          json.clear();
          values.forEach((Style value) {
            json.add(value.toJson());
          });
          service.setString(styles_key, jsonEncode(json)?.toString());
        }
      } else {
        values =
            json.map((value) => new Style.fromJson(value)).toList();
      }

    }
    return values;
  }

  static SystemService _service;

  static SystemService get service {
    if (null == _service) {
      _service = new SystemService();
    }
    return _service;
  }

  static List<Style> values;

  final BackgroundType backgroundType;
  final Color fontColor;
  final Color backgroundColor;
  final String imageUri;

  // TODO: cover ? none ?
  BoxFit get fit => backgroundType == BackgroundType.image
      ? BoxFit.cover
      : backgroundType == BackgroundType.texture ? BoxFit.none : null;

  ImageRepeat get repeat => backgroundType == BackgroundType.image
      ? ImageRepeat.noRepeat
      : backgroundType == BackgroundType.texture ? ImageRepeat.repeat : null;

  DecorationImage get image => null != imageUri
      ? new DecorationImage(
          fit: fit, repeat: repeat, image: new AssetImage(imageUri))
      : null;

  DecorationImage get buttonImage => null != imageUri
      ? new DecorationImage(
          fit: fit, repeat: ImageRepeat.repeat, image: new AssetImage(imageUri))
      : null;

  /// text style

  static TextStyle _textStyle;

  static double _fontSize;

  static double _height;

  static FontWeight _fontWeight;

  static String _fontFamily;

  static TextDirection _textDirection;

  static TextAlign _textAlign;

  /// get styles

  static TextStyle get textStyle {
    if (null == _textStyle) {
      _textStyle = new TextStyle(
          fontSize: fontSize,
          height: height,
          fontWeight: fontWeight,
          fontFamily: fontFamily);
    }
    return _textStyle;
  }

  static double get fontSize {
    if (null == _fontSize) {
      _fontSize = service.getDouble(font_size) ?? 20.0;
    }
    return 18.0;
    return _fontSize;
  }

  static double get height {
    if (null == _height) {
      _height = service.getDouble(line_height) ?? 2.0;
    }
    return 1.0;
    return _height;
  }

  static FontWeight get fontWeight {
    if (null == _fontWeight) {
      if (null != service.getString(font_weight)) {
        _fontWeight = FontWeight.values.firstWhere(
            (v) => v.toString() == service.getString(font_weight),
            orElse: () => FontWeight.normal);
      } else {
        _fontWeight = FontWeight.normal;
      }
    }
    return _fontWeight;
  }

  static String get fontFamily {
    if (null == _fontFamily) {
      _fontFamily = service.getString(font_family) ?? 'HYQH';
    }
    return _fontFamily;
  }

  static get textDirection {
    if (null == _textDirection) {
      _textDirection = TextDirection.values.firstWhere(
          (v) => v.toString() == service.getString(text_direction),
          orElse: () => TextDirection.ltr);
    }
    return _textDirection;
  }

  static get textAlign {
    if (null == _textAlign) {
      if (null != service.getString(text_align)) {
        _textAlign = TextAlign.values.firstWhere(
            (v) => v.toString() == service.getString(text_align),
            orElse: () => TextAlign.left);
      } else {
        _textAlign = TextAlign.left;
      }
    }
    return _textAlign;
  }

  /// set styles

  static set textStyle(TextStyle value) {
    _textStyle = value;
    fontSize = value.fontSize;
    fontWeight = value.fontWeight;
    fontFamily = value.fontFamily;
  }

  static set fontSize(double value) {
    _fontSize = value;
    service.setDouble(font_size, value);
  }

  static set height(double value) {
    _height = value;
    service.setDouble(line_height, value);
  }

  static set fontWeight(FontWeight value) {
    _fontWeight = value;
    service.setString(font_weight, value.toString());
  }

  static set fontFamily(String value) {
    _fontFamily = value;
    service.setString(font_weight, value);
  }

  static set textDirection(TextDirection value) {
    _textDirection = value;
    service.setString(text_direction, value.toString());
  }

  static set textAlign(TextAlign value) {
    _textAlign = value;
    service.setString(text_align, value.toString());
  }

  int get hashCode =>
      hashValues(backgroundType, backgroundColor, fontColor, imageUri);

  bool operator ==(other) {
    if (other is! Style) return false;
    return hashCode == other.hashCode;
  }
}
