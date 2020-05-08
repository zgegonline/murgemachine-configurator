import 'package:flutter/material.dart';
import 'DrinksListView.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drinks List',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Drinks List'),
        ),
        body: Center(
          child: DrinksListView(),
        ),
      ),
    );
  }
}
