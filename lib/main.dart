import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'user_modal.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const InfiniteScrollPackage(),
    );
  }
}

class InfiniteScrollPackage extends StatefulWidget {
  const InfiniteScrollPackage({Key? key}) : super(key: key);

  @override
  _InfiniteScrollPackageState createState() => _InfiniteScrollPackageState();
}

class _InfiniteScrollPackageState extends State<InfiniteScrollPackage> {
  static const _pageSize = 20;

  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 0);
  @override
  void initState() {
    _pagingController.addPageRequestListener((page) {
      _fetchPage(page);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await getDataFromApi(pageKey, _pageSize);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<List<Results>> getDataFromApi(int page, int skip) async {
    print("Getting More Data");
    User user = User();
    var response = await http.get(
      Uri.parse(
        "https://randomuser.me/api/?page=$page&results=$skip&seed=abc",
      ),
    );
    if (response.statusCode == 200) {
      // return a decoded body
      var decodedData = jsonDecode(response.body);
      print("hopping");
      print(decodedData);
      // data = decodedData['dataToSend'];
      user = User.fromJson(decodedData);
      return user.results!;
      //
    } else {
      // server error
      return Future.error("Server Error !");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Get Data",
        ),
      ),
      //
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _pagingController.refresh();
          _fetchPage(1);
        },
        child: Icon(
          Icons.refresh,
        ),
      ),
      //
      body: PagedListView<int, dynamic>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<dynamic>(
            itemBuilder: (context, item, index) {
          return Column(
            children: [
              Text(item['name']['first']),
              if (index == _pagingController.itemList!.length - 1)
                Container(
                  padding: EdgeInsets.all(15.0),
                  child: Text("No More Data"),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget card(String name, String imageUrl) {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.symmetric(
        horizontal: 25.0,
        vertical: 25.0,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 25.0,
        vertical: 25.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          5.0,
        ),
        border: Border.all(
          color: Colors.black,
          width: 2.0,
        ),
      ),
      child: Column(
        children: [
          //
          Image.network(
            imageUrl,
            width: 64,
          ),
          //
          SizedBox(
            height: 12.0,
          ),
          //
          Text(
            name,
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
        ],
      ),
    );
  }
}
