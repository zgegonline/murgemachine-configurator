import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String AVAILABLE_COCKTAILS_API_URL =
    'http://192.168.1.150:2636/available-cocktails';

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

class CocktailsGridView extends StatelessWidget {
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
    final response = await http.get(AVAILABLE_COCKTAILS_API_URL);

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

  void _tileClicked(int id) {
    debugPrint("Tile tapped : " + id.toString());
  }
}
