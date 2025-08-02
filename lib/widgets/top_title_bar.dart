import 'package:flutter/material.dart';
import 'package:noa/style.dart';

AppBar topTitleBar(
    BuildContext context, String title, bool darkMode, bool showBackButton) {
  return AppBar(
    toolbarHeight: 84,
    automaticallyImplyLeading: false,
    backgroundColor: darkMode ? colorDark : colorWhite,
    scrolledUnderElevation: 0,
    title: Text(
      title,
      style: darkMode ? textStyleWhiteTitle : textStyleDarkTitle,
    ),
    centerTitle: false,
    titleSpacing: 42,
    actions: showBackButton ? [
      Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.only(right: 42),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back,
                color: darkMode ? colorWhite : colorDark),
          ))
    ] : null,
  );
}
