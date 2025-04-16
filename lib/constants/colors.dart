import 'package:flutter/material.dart';

const kOrangeColor = Color(0xFFC85250);
const kPinkColor = Color(0xFFBF5378); //Register Page Topic
const kPeachColor = Color(0xFFFF9191);
const kPurpleColor = Color(0xFF954582);
const kDarkPinkColor = Color(0xFFCA1F4B);
const kRedColor = Color(0xFFC23030);
const kCreamColor = Color(0xFFFF8D8D);
const kMainButtonColor = Color(0xFFC85250); //Main Buttons and App Name
const kButtonColor2 = Color(0xFFDD4040); //Matches page buttons
const kProfileIcon = Color(0xFF8C1A11);

//Home Page Red Color Types
const kHomeColor1 = Color(0xFFFF0000); //Left Top Widget
const kHomeColor2 = Color(0xFFC23030); //Right Top Widget
const kHomeColor3 = Color(0xFFBB2121); // Sub Topic for Home and Matches Pages
const kHomeColor4 = Color(0xFFC41F16); //Dates

const kGradientLogin = LinearGradient(
  colors: [kOrangeColor, kPinkColor],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

const kGradientRegister = LinearGradient(
  colors: [kPinkColor, kPeachColor],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

const kGradientHome = LinearGradient(
  colors: [kPurpleColor, kDarkPinkColor],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

const kGradientNavBar = LinearGradient(
  colors: [kPurpleColor, kOrangeColor],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

const kProfilePage = LinearGradient(
  colors: [kPeachColor, kRedColor],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);
