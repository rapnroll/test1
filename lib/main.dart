import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart' ;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  await Permission.camera.request();
  await Permission.microphone.request();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: InAppWebViewPage()
    );
  }
}

class InAppWebViewPage extends StatefulWidget {
  @override
  _InAppWebViewPageState createState() => new _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  InAppWebViewController _webViewController;
  double progress = 0;


  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);


    return WillPopScope(
        onWillPop: () async {
      final value = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Are you sure you want to exit?'),
              actions: <Widget>[
                FlatButton(
                  child: Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                FlatButton(
                  child: Text('Yes, exit'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          }
      );

      return value == true;
    },
    child: Scaffold(
        body: Container(
            child: Column(children: <Widget>[
              progress < 100.0
                  ? LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white,
                valueColor:
                AlwaysStoppedAnimation<Color>(Colors.green[800]),
          
              )
                  : Center(),
              Expanded(
                child: Container(
                  child: InAppWebView(
                      initialUrlRequest: URLRequest(
                          url: Uri.parse("https://www.healttest.com/app/")),

                      initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          mediaPlaybackRequiresUserGesture: false,
                        //  debuggingEnabled: true,
                        ),
                      ),
                      onWebViewCreated: (InAppWebViewController controller) {
                        _webViewController = controller;
                      },

                      onProgressChanged: (_, load) {
                        setState(() {
                          progress = load / 100;
                        });
                      },


                      androidOnPermissionRequest: (InAppWebViewController controller, String origin, List<String> resources) async {
                        return PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT);
                      }
                  ),
                ),
              ),
            ]))
    ),
    );
  }


}

