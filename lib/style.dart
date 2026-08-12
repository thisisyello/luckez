import 'package:flutter/material.dart';

var mainColor = const Color(0xFF1E1F26);
var blackColor = const Color(0xff1E1E1E);
var greyColor = const Color(0xff9E9E9E);
var whiteColor = const Color(0xffFFFFFF);
var redColor = const Color(0xFFE74C3C);

var num0Color = const Color(0xffFBC400);
var num10Color = const Color(0xff69C8F2);
var num20Color = const Color(0xffFF7272);
var num30Color = const Color(0xffAAAAAA);
var num40Color = const Color(0xffB0D840);

Color getTextColor(int number) {
  if (number <= 10) {
    return num0Color;
  } else if (number <= 20) {
    return num10Color;
  } else if (number <= 30) {
    return num20Color;
  } else if (number <= 40) {
    return num30Color;
  } else {
    return num40Color;
  }
}
