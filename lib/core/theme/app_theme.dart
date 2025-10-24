import 'package:flutter/material.dart';
import 'package:subscriptions_app/core/theme/color.dart';

ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: ColorsManager.kPrimaryColor,
    primary: ColorsManager.kPrimaryColor,
    onPrimary: Colors.white,
    secondary: ColorsManager.dark,
    primaryContainer: ColorsManager.textFormField,
    onPrimaryContainer: ColorsManager.textFormFieldDark,
    // tertiary: ColorsManager.appBarColorDarek,
    tertiary: const Color(0xffEAEAEA),
    tertiaryContainer: const Color(0xffE6E6E6),
    onTertiaryContainer: Colors.white,
  ),
  useMaterial3: true,
  //  brightness: Brightness.dark,
  appBarTheme: const AppBarTheme(
    // systemOverlayStyle: SystemUiOverlayStyle(
    //   statusBarColor: ColorsManager.backgroundColorDark,
    //   statusBarIconBrightness: Brightness.dark,
    // ),
    centerTitle: true,
    backgroundColor: ColorsManager.appBarColor,
    surfaceTintColor: ColorsManager.appBarColor,
    titleTextStyle: TextStyle(
      color: ColorsManager.dark,
      fontSize: 16,
      // fontWeight: FontWeightHelper.bold,
    ),
  ),
  visualDensity: VisualDensity.comfortable,
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
  ),
  scaffoldBackgroundColor: Colors.white,
  // primaryTextTheme: Typography.whiteCupertino
);

ThemeData darkTheme = ThemeData(
  scaffoldBackgroundColor: ColorsManager.backgroundColorDark,
  colorScheme: ColorScheme.fromSeed(
    // brightness: Brightness.dark,
    seedColor: ColorsManager.kPrimaryColor,
    primary: ColorsManager.kPrimaryColor,
    onPrimary: ColorsManager.dark,
    secondary: ColorsManager.white,
    primaryContainer: ColorsManager.textFormFieldDark,
    onPrimaryContainer: ColorsManager.textFormFieldDark,
    tertiary: const Color(0xff1E1E1E),
    onTertiaryContainer: const Color(0xff1E1E1E),
    tertiaryContainer: Colors.grey[800],
  ),
  appBarTheme: const AppBarTheme(
    // systemOverlayStyle: SystemUiOverlayStyle(
    //   statusBarColor: ColorsManager.backgroundColorDark,
    //   statusBarIconBrightness: Brightness.light,
    // ),
    iconTheme: IconThemeData(color: ColorsManager.kPrimaryColor),
    centerTitle: true,
    backgroundColor: ColorsManager.appBarColorDarek,
    surfaceTintColor: ColorsManager.appBarColorDarek,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 16,
      // fontWeight: FontWeightHelper.bold,
      fontFamily: 'Tajawal',
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(type: BottomNavigationBarType.fixed, elevation: 20.0),
);
