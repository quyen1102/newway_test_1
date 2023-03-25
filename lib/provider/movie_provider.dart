import 'package:flutter/material.dart';
import 'package:newway_test_1/models/movie.dart';

class MovieProvider with ChangeNotifier {
  List<Movie> listMovie = [];

  changeListMovie(List<Movie> newList) {
    listMovie += newList;
    notifyListeners();
  }
  setListMovieIsEmpty(List<Movie> newList) {
    listMovie = [];
    notifyListeners();
  }
}
