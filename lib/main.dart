import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:location/location.dart';

const secretKey = '********';

var descTextStyle = TextStyle(
  color: Colors.black,
  fontFamily: 'GenJyuuGothic',
  fontSize: 24.0,
);

//GPSクラスの定義
//後回しにする

//天気クラスの定義
class Weather {
  final double latitude;
  final double longitude;
  final String timezone;
  final Map<String, dynamic> currently;

  Weather({this.latitude, this.longitude, this.timezone, this.currently});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      latitude: json['latitude'], //緯度
      longitude: json['longitude'], //経度
      timezone: json['timezone'],
      currently: json['currently'],
    );
  }
}

Future<Weather> fetchWeather() async {
  final response = await http
      // .get('https://api.darksky.net/forecast/' + secretKey + '/34.8151,134.6853?exclude=minutely&lang=ja&units=auto');
      .get('https://dev-test.fujiya228.com/flutter/Darksky-sample2.json');
  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.

    Weather responseBody = Weather.fromJson(
        json.decode(utf8.decode(response.bodyBytes))); //日本語が文字化けするのでその対応
    print(responseBody.currently['summary']);
    return responseBody;
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Weather> weather;
  DateTime now = new DateTime.now();

  @override
  void initState() {
    super.initState();
    weather = fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    var title = '天気見ようず';
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            title,
            style: TextStyle(fontFamily: 'GenJyuuGothic'),
          ),
        ),
        backgroundColor: Colors.blue[100],
        body: Center(
          child: FutureBuilder<Weather>(
            future: weather,
            builder: (context, snapshot) {
              List<Widget> children = List<Widget>();
              List<Widget> details = List<Widget>();//初期化しないとNullで呼び出されたと怒られる
              if (snapshot.hasData) {
                Map currently = snapshot.data.currently;
                // Listに入れていく
                children = <Widget>[
                  Text(
                    '姫路の天気',
                    // textScaleFactor: 5,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.green[800],
                      fontFamily: 'GenJyuuGothic',
                      fontSize: 80,
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.blue,
                          offset: Offset(5.0, 5.0),
                        ),
                        Shadow(
                          color: Colors.green,
                          blurRadius: 10.0,
                          offset: Offset(-10.0, 5.0),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/' + currently['icon'] + '.png',
                    fit: BoxFit.contain,
                    color: Colors.white,
                    height: 200,
                  ),
                  Text(
                    currently['summary'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'GenJyuuGothic',
                        fontSize: 24,
                        color: Colors.black38),
                  ),
                ];
                // 詳細の格納
                currently.forEach((key, value) => {
                  details.add(
                    key == 'time' ? 
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            key,
                            textAlign: TextAlign.center,
                            style: descTextStyle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            DateTime.now().toUtc().toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'GenJyuuGothic', fontSize: 16,),
                          ),
                        )
                      ],
                    )
                    :
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            key,
                            textAlign: TextAlign.center,
                            style: descTextStyle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            value.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'GenJyuuGothic', fontSize: 16,),
                          ),
                        )
                      ],
                    ),
                  )
                });
                return Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Container(
                        // color: Colors.blue[100],
                        child: Column(children: children,),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: ListView(
                          children: details,
                        ),
                        decoration: BoxDecoration(
                          // color: Color.fromRGBO(240, 240, 240, 1),
                          boxShadow: [
                            const BoxShadow(
                              color: Colors.black,//shadow-color
                              offset: const Offset(0.0, 0.0),
                            ),
                            const BoxShadow(
                              color: Color.fromRGBO(240, 240, 240, 1),//bg-color
                              offset: const Offset(0.0, 0.0),
                              spreadRadius: -1.0,
                              blurRadius: 10.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]
                );
              }
              if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: initState,
        //   tooltip: 'Reload',
        //   child: Icon(Icons.add),
        //   backgroundColor: Colors.blue[100],
        // ), 
      ),
    );
  }
}
