import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String API_URL_AVAILABLE_COCKTAILS =
    'http://192.168.1.150:2636/available-cocktails';
const String API_URL_REQUEST_COCKTAIL =
    'http://192.168.1.150:2636/request-cocktail';

class Cocktail {
  final int id;
  final String name;
  final Light light;
  final List<Ingredient> ingredients;

  Cocktail({this.id, this.name, this.light, this.ingredients});

  factory Cocktail.fromJson(Map<String, dynamic> json) {
    var list = json['ingredients'] as List;
    List<Ingredient> ingredientsList =
        list.map((i) => Ingredient.fromJson(i)).toList();

    return Cocktail(
        id: json['id'],
        name: json['name'],
        light: Light.fromJson(json['light']),
        ingredients: ingredientsList);
  }
}

class Light {
  final Color color;
  final String effect;

  Light({this.color, this.effect});

  factory Light.fromJson(Map<String, dynamic> json) {
    return Light(color: hexToColor(json['color']), effect: json['effect']);
  }
}

/// Construct a color from a hex code string, of the format #RRGGBB.
Color hexToColor(String code) {
  return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

class Ingredient {
  final String id;
  final int part;

  Ingredient({this.id, this.part});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(id: json['id'], part: json['part']);
  }
}

class CocktailsGridView extends StatefulWidget {
  @override
  _CocktailsGridViewState createState() => _CocktailsGridViewState();
}

enum Size { SIZE_25, SIZE_50 }

class _CocktailsGridViewState extends State<CocktailsGridView> {
  Widget build(BuildContext context) {
    return FutureBuilder<List<Cocktail>>(
        future: _fetchCocktails(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Cocktail> data = snapshot.data;
            return _cocktailsGridView(data);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return CircularProgressIndicator();
        });
  }

  Future<List<Cocktail>> _fetchCocktails() async {
    final response = await http.get(API_URL_AVAILABLE_COCKTAILS);

    if (response.statusCode == 200) {
      Map data = jsonDecode(response.body);
      List jsonCocktails = data["cocktails"];

      return jsonCocktails
          .map((cocktail) => new Cocktail.fromJson(cocktail))
          .toList();
    } else {
      throw Exception('Failed to load cocktails from the API');
    }
  }

  GridView _cocktailsGridView(data) {
    return GridView.builder(
        itemCount: data.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 5, crossAxisSpacing: 5),
        itemBuilder: (context, index) {
          return _cocktailTile(
              data[index].id, data[index].name, data[index].light.color);
        });
  }

  GridTile _cocktailTile(int id, String name, Color color) {
    return GridTile(
      child: InkResponse(
        enableFeedback: true,
        onTap: () => _tileClicked(id),
        child: Container(
            child: Column(children: [
              Text(
                name,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                    color: Colors.black),
              ),
              Expanded(
                child: ColorFiltered(
                    child: Image.asset("images/soft-drink.png"),
                    colorFilter: ColorFilter.mode(color, BlendMode.modulate)),
              ),
              Text(
                "id : " + id.toString(),
                style: TextStyle(fontWeight: FontWeight.w200),
              )
            ]),
            decoration: BoxDecoration(border: Border.all(width: 1))),
      ),
    );
  }

  Future _tileClicked(int id) async {
    debugPrint("Tile tapped : " + id.toString());
    switch (await showDialog(
        context: context,
        child: SimpleDialog(
          title: Text("Cocktail Preparation :" + id.toString()),
          children: <Widget>[
            new SimpleDialogOption(
              child: Text("25cl"),
              onPressed: () => Navigator.pop(context, Size.SIZE_25),
            ),
            new SimpleDialogOption(
              child: Text("50cl"),
              onPressed: () => Navigator.pop(context, Size.SIZE_50),
            )
          ],
        ))) {
      case Size.SIZE_25:
        debugPrint(id.toString() + " -> 25cl");
        http.Response response = await _requestCocktail(id, 25);
        debugPrint(id.toString() + " requested" + response.body);
        break;
      case Size.SIZE_50:
        debugPrint(id.toString() + " -> 50cl");
        _requestCocktail(id, 50);
        break;
    }
  }

  Future<http.Response> _requestCocktail(int id, int size) async {
    return http.post(
      API_URL_REQUEST_COCKTAIL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "cocktailId": id,
        "size": size,
        "light": {"color": "#ff00ff", "effect": "fixed"}
      }),
    );
  }
}
