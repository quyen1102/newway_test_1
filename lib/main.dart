import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lazy_load_refresh_indicator/lazy_load_refresh_indicator.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:newway_test_1/models/movie.dart';
import 'package:newway_test_1/models/movies.dart';
import 'package:provider/provider.dart';

import 'dart:developer' as dev;

import 'provider/movie_provider.dart';

void main() {
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => MovieProvider()),
        ],
        child: const MyApp(),
      ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  final String baseImagePath = 'https://image.tmdb.org/t/p/w500/';
  int page = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var listMovie = Provider.of<MovieProvider>(context, listen: false);
    listMovie.setListMovieIsEmpty;
    page = 1;
    _loadMoreData();

  }

  Future<void> _getMovieData() async {
    var listMovie = Provider.of<MovieProvider>(context, listen: false);
    print(page);
    final response = await http
        .get(Uri.parse(
        'https://api.themoviedb.org/3/discover/movie?api_key=26763d7bf2e94098192e629eb975dab0&page=$page'));
    try {
      await listMovie.changeListMovie(
          ListMovie.fromJson(jsonDecode(response.body)));
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      dev.log(err.toString());
    }
  }

  _loadMoreData() {
    if (_isLoading) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    _getMovieData();
  }
  Future<void> onRefresh() async {
    page = 1;
    _isLoading = false;
    _getMovieData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Popular list"),
      ),
      body:  Consumer<MovieProvider>(
        builder: (context, value, child) {
          return LazyLoadRefreshIndicator(
            isLoading: _isLoading,
            onEndOfPage: () {
              page = page + 1;
              _loadMoreData();
            },
            onRefresh: onRefresh,
            child: GridView.builder(
                padding: const EdgeInsets.symmetric(
                    vertical: 20, horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20.0,
                  crossAxisSpacing: 20.0,
                  childAspectRatio: 2 / 3,
                ),
                itemCount: value.listMovie.length,
                itemBuilder: (BuildContext context, int index) {
                  return _renderItemCard(value.listMovie[index]);
                }
            ),
          );
        },
      ),
    );
  }

  Widget _renderItemCard(Movie movie) {
    final String image = '$baseImagePath${movie.poster_path}';
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                  color: Color.fromRGBO(139, 146, 165, 0.2),
                  spreadRadius: 3,
                  blurRadius: 10,
                  offset: Offset(0, 0.75)
              ),
            ],
            image: DecorationImage(
              image: NetworkImage(image),
              fit: BoxFit.fill,
            ),
          ),
        ),
        Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Column(
              children: [
                Container(
                  height: 30,
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 16),
                  child: Text("${_getYearRelease(movie.release_date)}",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  height: 45,
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(movie.title.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9)
                    ),
                  ),
                ),

              ],
            )),
        Positioned(
            top: 10,
            right: 10,
            child: _renderBadgeCircle(movie.vote_average))
      ],
    );
  }

  Container _renderBadgeCircle(num voteRate) {
    final int preRateNum = voteRate.floor();
    final num subRateNum = ((voteRate - preRateNum) * 10).floor();
    return Container(
        width: 35,
        height: 35,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment(0.8, 1),
            colors: <Color>[
              Color(0xff1f005c),
              Color(0xff5b0060),
              Color(0xff870160),
              Color(0xffac255e),
              Color(0xffca485c),
              Color(0xffe16b5c),
              Color(0xfff39060),
              Color(0xffffb56b),
            ],
            tileMode: TileMode.mirror,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$preRateNum",
                style:  TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.9)
                ),
              ),
              const Text(".",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70
                ),
              ),
              Text("$subRateNum",
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70
                ),
              ),
            ],
          ),
        ),
      );
  }

  _getYearRelease(String data) {
    return data.split("-").first;
  }
  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: const Center(
        child: Opacity(
          opacity:1,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}


