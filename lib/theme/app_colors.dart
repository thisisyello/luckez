import 'package:flutter/material.dart';

const mainColor = Color(0xFF1E1F26);
const blackColor = Color(0xff1E1E1E);
const greyColor = Color(0xff9E9E9E);
const whiteColor = Color(0xffFFFFFF);
const redColor = Color(0xFFE74C3C);

const num0Color = Color(0xffFBC400);
const num10Color = Color(0xff69C8F2);
const num20Color = Color(0xffFF7272);
const num30Color = Color(0xffAAAAAA);
const num40Color = Color(0xffB0D840);

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
