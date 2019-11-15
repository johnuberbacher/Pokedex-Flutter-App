import 'dart:async';
import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController editingController = TextEditingController();
  String url = 'https://pokeapi.co/api/v2/pokemon/?limit=151';
  List data;

  Future<String> makeRequest() async {
    var response = await http.get(Uri.encodeFull(url), headers: {"Accept": "application/json"});

    setState(() {
      var extractData = json.decode(response.body);
      data = extractData["results"];
    });
  }

  @override
  void initState() {
    super.initState();
    makeRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokemon List'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
            },
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                onChanged: (value) {},
                decoration: InputDecoration(
                  labelText: "Search",
                  hintText: "Search",
                  contentPadding: const EdgeInsets.all(10.0),
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(6.0))),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: data == null ? 0 : data.length,
                  itemBuilder: (BuildContext context, i) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.black12,
                        backgroundImage: AssetImage('assets/sprites/$i.png'), // no matter how big it is, it won't overflow
                      ),
                      title: new Text(StringUtils.capitalize(data[i]["name"])),
                      // subtitle: Text(data[i]["url"]),
                      //  leading:  CircleAvatar(
                      // backgroundImage:
                      //  NetworkImage(data[i]["picture"]["thumbnail"]),
                      //  ),
                      onTap: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (BuildContext context) => SecondPage(data[i])));
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  Map data;

  SecondPage(this.data);

  _SecondState createState() => _SecondState();
}

class _SecondState extends State<SecondPage> {
  @override
  void initState() {
    super.initState();
    _fetchPost();
  }

  Map post;
  bool isLoad = true;

  _fetchPost() async {
    setState(() {
      isLoad = true;
    });
    var url = widget.data["url"];
    debugPrint(url);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      post = json.decode(response.body.toString());
      setState(() {
        isLoad = false;
      });
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
        title: Text(StringUtils.capitalize(widget.data['name'])),
        elevation: 0.0,
      ),
      body: _buildPokemon(context),
    );
  }

  Widget _buildPokemon(BuildContext context) {
    if (isLoad) return Center(child: CircularProgressIndicator());
    return Scaffold(
      backgroundColor: Colors.red,
      body: (
          Column(
              children: <Widget>[
                Container(
                  child: Container(
                    height: 90.0,
                    color: Colors.red,
                  ),
                ),
                Expanded(
                    child: Container(
                      constraints: BoxConstraints.expand(),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular((30.0)),
                            topRight: Radius.circular((30.0)),
                          )
                      ),
                      child: new Column(
                        //mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            transform: Matrix4.translationValues(0.0, -75.0, 0.0),
                            margin: const EdgeInsets.all(10.0),
                            padding: EdgeInsets.all(10),
                            child: Image.asset(
                              'assets/images/' + post['id'].toString() + '.png',
                              fit: BoxFit.contain,
                              alignment: new Alignment(-1.0, -5.0),
                              width: 250,
                              height: 250,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(10.0),
                            padding: EdgeInsets.all(10),
                            child: Text(
                              StringUtils.capitalize(post['name']),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35,),
                            ),
                          ),
                          Text(
                            'Height',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18,),
                          ),
                          Text(double.parse((post['height'] * 0.32 ).toStringAsFixed(2)).toString() + 'ft  =  ' + double.parse((post['height'] * 10).toStringAsFixed(2)).toString() + 'm'),
                          // Text('type ' + post['types'][0]['type']['name'].toString()),
                          // Image.network(post['sprites']['front_default'])
                        ],
                      ),
                    )
                ),
              ]
          )
      ),
    );
  }
}