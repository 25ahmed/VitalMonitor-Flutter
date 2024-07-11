import 'package:flutter/material.dart';
import 'package:mdsflutter_example/AppModel.dart';
import 'package:provider/provider.dart';

import 'ScanWidget.dart';


var kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 62, 46, 122),
);

var kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 5, 99, 125),
);

void main() {
  runApp(
      ChangeNotifierProvider(
        create: (context) => AppModel(),
        child: MaterialApp(
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: kDarkColorScheme,
            cardTheme: const CardTheme().copyWith(
              color: kDarkColorScheme.secondaryContainer,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: kDarkColorScheme.primaryContainer,
                foregroundColor: kDarkColorScheme.onPrimaryContainer,
              ),
            ),
          ),
          theme: ThemeData().copyWith(
            colorScheme: kColorScheme,
            appBarTheme: const AppBarTheme().copyWith(
              // backgroundColor: kColorScheme.inversePrimary,
              // foregroundColor: kColorScheme.inverseSurface,
              backgroundColor: kColorScheme.primary,
              foregroundColor: kColorScheme.onPrimary,
            ),
            cardTheme: const CardTheme().copyWith(
              color: kColorScheme.secondaryContainer,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: kColorScheme.primaryContainer,
                foregroundColor: kColorScheme.onPrimaryContainer, // newly added
              ),
            ),
            textTheme: ThemeData().textTheme.copyWith(
              titleLarge: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: kColorScheme.onSecondaryContainer,
                  fontSize: 16
              ),
            ),
          ),
          home: ScanWidget(),
        ),
      )
  );
}
