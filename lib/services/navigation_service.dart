import 'package:flutter/material.dart';

class NavigationService {
  // Navigation key is kind of holding the state of our navigator
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Replace the screen (page)
  void removeAndNavigateToRoute(String route){
    navigatorKey.currentState?.popAndPushNamed(route);
  }

  // Push the screen (page) via name
  void navigateToRoute(String route){
    navigatorKey.currentState?.pushNamed(route);
  }

  // Push the screen (page)
  void navigateToPage(Widget page){
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (BuildContext context){
        return page;
      }),
    );
  }

  void goBack(){
    navigatorKey.currentState?.pop();
  }
}
