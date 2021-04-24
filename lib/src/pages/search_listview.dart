import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class SearchListViewExample extends StatefulWidget {
  @override
  _SearchListViewExampleState createState() => _SearchListViewExampleState();
}

class _SearchListViewExampleState extends State<SearchListViewExample> {
  List<String> dogsBreedList = List<String>();
  List<String> tempList = List<String>();
  bool isLoading = true;
  List rs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
   
        appBar: new AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          elevation: 0.0,
          title: new Text('Search',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              )),
        ),
        body: Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _searchBar(),
                  Expanded(
                    flex: 1,
                    child: _mainData(),
                  )
                ],
              ),
            )));
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(38.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          offset: const Offset(0, 2),
                          blurRadius: 8.0),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 4, bottom: 4),
                    child: InkWell(
                      child: TextField(
                        onChanged: (text) {
                          text == "" ? isLoading = true : _fetchDogsBreed(text);
                        },
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                        cursorColor:Colors.blue,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search...',
                        ),
                      ),
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }

  Widget _mainData() {
    return Center(
      child: isLoading
          ? CircularProgressIndicator()
          : ListView.builder(
          itemCount: rs.length,
          itemBuilder: (context, index) {
            return Container(
              color: Colors.white,
              child: ListTile(
                  onTap: () {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) =>
                    //             profileScreen(
                    //                 rs[index]["familyname"],
                    //                 rs[index]["profileimage"],
                    //                 rs[index]["familyleader"],
                    //                 rs[index]["familyid"],
                    //                 rs[index]["familycontact"],
                    //                 rs[index]["address"])));
                  },
                  subtitle: Text(rs[index]["pickup_point_name"]),
                  title: Text(
                    rs[index]["pickup_point_name"],
                  )),
            );
          }),
    );
  }

  _filterDogList(String text) {
    if (text.isEmpty) {
      setState(() {
        dogsBreedList = tempList;
      });
    } else {
      final List<String> filteredBreeds = List<String>();
      tempList.map((breed) {
        if (breed.contains(text.toString().toUpperCase())) {
          filteredBreeds.add(breed);
        }
      }).toList();
      setState(() {
        dogsBreedList = filteredBreeds;
      });
    }
  }

  _fetchDogsBreed(String text) async {
    Map data;

    setState(() {
      isLoading = true;
    });
    tempList = List<String>();
    final response = await http.get(
        'https://marketing.rexxtechnologies.com/sda/index.php/Searchbox/searchAll?search=$text');
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      data = jsonDecode(response.body);

      /*data["result"].forEach((breed, subbreed) {
        rs.add(breed.toString().toUpperCase());
      });*/
    } else {
      throw Exception("Failed to load Dogs Breeds.");
    }
    setState(() {
      rs = data["result"];
      print(rs);
      // dogsBreedList = rs;
      isLoading = false;
    });
  }
}

