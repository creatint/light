import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/system.dart';
import '../utils/constants.dart';

enum BackgroundType { color, image, texture }

class Style {
  Style._internal({
    this.id,
    this.backgroundType,
    this.fontColor,
    this.backgroundColor,
    this.imageUri,
  });

  Style.fromJson(Map<String, dynamic> json)
      : this.id = int.parse(json['id']),
        this.backgroundType = BackgroundType.values
                .firstWhere((v) => v.toString() == json['backgroundType']) ??
            BackgroundType.color,
        this.fontColor = new Color(int.parse(json['font_color'])),
        this.backgroundColor = new Color(int.parse(json['background_color'])),
        this.imageUri = json['image_uri'];

  operator [](int index) {
    if (index <= (_styles.length - 1)) {
      return _styles[index];
    }
    return null;
  }

  static List<Style> init() {
    if (null == _styles) {
      List<String> raw = service.getStringList(styles_key);
      if (null == raw || raw.isEmpty) {
        _styles = [
          new Style._internal(
              id: 0,
              backgroundColor: const Color(0xffffffff),
              fontColor: const Color(0xff424142),
              backgroundType: BackgroundType.color)
        ];
      } else {
        _styles = raw
            .map((String value) => new Style.fromJson(json.decode(value)))
            .toList();
      }
    }
    return _styles;
  }

  static SystemService service = new SystemService();

  static List<Style> _styles;

  final int id;
  final BackgroundType backgroundType;
  final Color fontColor;
  final Color backgroundColor;
  final String imageUri;

  BoxFit get fit => backgroundColor == BackgroundType.image
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
    return _fontSize;
  }

  static double get height {
    if (null == _height) {
      _height = service.getDouble(line_height) ?? 1.2;
    }
    return _height;
  }

  static FontWeight get fontWeight {
    if (null == _fontWeight) {
      if (null != service.getString(font_weight)) {
        _fontWeight = FontWeight.values.firstWhere(
                (v) => v.toString() == service.getString(font_weight)) ??
            FontWeight.normal;
      } else {
        _fontWeight = FontWeight.normal;
      }
    }
    return _fontWeight;
  }

  static String get fontFamily {
    if (null == _fontFamily) {
      _fontFamily = service.getString(font_family) ?? null;
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
}
