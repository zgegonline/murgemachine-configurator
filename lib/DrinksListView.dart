import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Drink {
  final String id;
  final String name;
  final String type;

  Drink({this.id, this.name, this.type});

  factory Drink.fromJson(Map<String, dynamic> json) {
    return Drink(id: json['id'], name: json['name'], type: json['type']);
  }
}

class DrinksListView extends StatelessWidget {
  Widget build(BuildContext context) {
    return FutureBuilder<List<Drink>>(
        future: _fetchDrinks(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Drink> data = snapshot.data;
            return _drinksListView(data);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return CircularProgressIndicator();
        });
  }

  Future<List<Drink>> _fetchDrinks() async {
    final drinksListAPIUrl = 'http://192.168.1.150:2636/drinks';
    final response = await http.get(drinksListAPIUrl);
    print(response.body);
    if (response.statusCode == 200) {
      Map data = jsonDecode(response.body);
      List jsonResponse = data["drinks"];
      print(jsonResponse);
      return jsonResponse.map((drink) => new Drink.fromJson(drink)).toList();
    } else {
      throw Exception('Failed to load drinks from API');
    }
  }

  ListView _drinksListView(data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return _drinkTile(data[index].id, data[index].name, data[index].type);
        });
  }

  ListTile _drinkTile(String id, String name, String type) {
    return ListTile(
      title: Text(name,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
          )),
      subtitle: Text(type),
    );
  }
}
