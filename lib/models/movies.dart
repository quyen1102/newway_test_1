
import 'package:flutter/material.dart';
import 'package:newway_test_1/models/movie.dart';

class ListMovie extends ChangeNotifier{
  late List<Movie> _list = [];
  List<Movie> get list => _list;
//constructor
  ListMovie(List<Movie> listMove) {
    _list = listMove;
    notifyListeners();
  }
  static List<Movie> fromJson(dynamic jsons) {
    List<Movie> list = [];
    // print(jsons['results']);
    if (jsons == null) {
      return [];
    }
    for(var i in jsons['results']){
      list.add(Movie.fromJson(i));
    }
    return  list;
  }
}