import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quickbooks/quickbooks.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dart-Quickbooks example',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Dart-Quickbooks example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Quickbooks _quickbooks;
  String _redirectUri = "http://localhost";
  bool isConnected = false;

  List<dynamic> items = [];
  TextEditingController _querryController = new TextEditingController();

  double screenWidth;
  double screenHeight;

  @override
  void initState() {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    _quickbooks = new Quickbooks("sIEZZ51fCTI9VrPrPQuMfVC6WH04h8eDZod7Q61m",
        "ABrdPqJXTBDAdh8teIhGitjdVudGHRbCXYRott3W97Ocfie0XE", _redirectUri,
        debug: true, useSandbox: true);
    super.initState();
  }

  /// OAuth redirect using the Flutter Webview
  void auth() async {
    var uri = _quickbooks.prepareUri();
    print(uri);
    showDialog(
        context: context,
        builder: (context) {
          return Container(
            child: WebView(
              initialUrl: uri,
              javascriptMode: JavascriptMode.unrestricted,
              onPageStarted: (url) async {
                if (url.contains(_redirectUri)) {
                  Navigator.pop(context);
                  var newUrl = url.split("=");
                  var auth = await _quickbooks.authenticate(
                      newUrl[1].replaceAll("&state", ""), newUrl[3]);
                  setState(() {
                    if (auth) {
                      isConnected = true;
                    }
                  });
                }
              },
            ),
          );
        });
  }

  /// Disconnect the connected user
  void disconnect() async {
    await _quickbooks.disconnect().then((_) {
      setState(() {
        isConnected = false;
      });
    }, onError: (error) {
      print("RRRRRR: $error");
    });
  }

  /// Query the Quickbook online plateform
  void query() async {
    var res = await _quickbooks.runQuery(_querryController.text.toString());
    setState(() {
      items = res["Item"] ?? ["NO ITEMS WERE FOUND"];
    });
  }

  @override
  Widget build(BuildContext context) {
    this.screenHeight = MediaQuery.of(context).size.height;
    this.screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text((_quickbooks.company == null) ? widget.title : _quickbooks.company.name),
      ),
      backgroundColor: Colors.lightBlue.shade50,
      resizeToAvoidBottomInset: false,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            color: Colors.white,
            height: 190,
            padding: EdgeInsets.all(15.0),
            child: Column(
              children: [
                Text(
                  (isConnected)
                      ? "You are connected."
                      : "You are not connected",
                ),
                (isConnected)
                    ? Container(
                        width: screenWidth,
                        padding: EdgeInsets.all(15),
                        child: TextField(
                          controller: _querryController,
                          decoration: InputDecoration(
                            labelText: "Query",
                            fillColor: Colors.white,
                            border: InputBorder.none,
                            filled: true,
                          ),
                        ),
                      )
                    : Container(),
                (!isConnected)
                    ? RaisedButton(
                        onPressed: auth, child: Text("Login with Quickbooks"))
                    : RaisedButton(
                        onPressed: query,
                        child: Text("Query"),
                      ),
              ],
            ),
          ),
          Container(
            height: screenHeight - 285,
            width: screenWidth,
            padding: EdgeInsets.all(15),
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                    padding: EdgeInsets.all(15),
                    color: Colors.lightGreen.shade50,
                    child: Text(items[index].toString()));
              },
            ),
          )
        ],
      )),
      floatingActionButton: (isConnected)
          ? FloatingActionButton(
              onPressed: disconnect,
              child: Icon(Icons.logout),
            )
          : null,
    );
  }
}
