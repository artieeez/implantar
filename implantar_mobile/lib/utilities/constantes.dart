import 'package:flutter/material.dart';

final kPrimaryColor = const Color(0xFFacc99b);
final kAccentColor = Colors.white;

final kFont1 = TextStyle(
  color: Colors.white,
);

final kFont2 = TextStyle(
  color: kPrimaryColor,
  fontFamily: 'CormorantGaramond',
  fontWeight: FontWeight.w500,
  fontSize: 30.0,
);

final kFont3 = TextStyle(
  color: Colors.black,
  fontFamily: 'IstokWeb',
  fontWeight: FontWeight.w400,
);

final kHintTextStyle = TextStyle(
  color: Colors.white54,
  fontFamily: 'OpenSans',
);

final kLabelStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontFamily: 'OpenSans',
);

final kBoxDecorationStyle = BoxDecoration(
  color: kPrimaryColor,
  borderRadius: BorderRadius.circular(10.0),
  boxShadow: [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ],
);
