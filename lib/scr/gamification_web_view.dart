
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'Aes.dart';

class GamificationWebView extends StatefulWidget {

  final String clientId;
  final String keyValue;
  final String userID;
  final String username;
  final String keyString;
  final String baseUrl;

  const GamificationWebView({Key? keys, required this.clientId, required this.keyValue,
    required this.userID, required this.username, required this.keyString, required this.baseUrl})
      : super(key: keys);

  @override
  State<GamificationWebView> createState() => _GamificationWebViewState();
}

class _GamificationWebViewState extends State<GamificationWebView> {

  late WebViewController webViewController;

  @override
  void initState() {
    super.initState();

    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000));

    encryptJson();

  }

  void encryptJson(){

    var originalJson = """
        {
          "clientID": "${widget.clientId}",
          "key": "${widget.keyValue}",
          "userID": "${widget.userID}",
          "username": "${widget.username}",
          "utm_param1": "",
          "utm_param2": "",
          "utm_param3": "",
          "utm_param4": "",
          "utm_source":"${Platform.isAndroid ? 'Android' : 'IOS'}"
        }
    """.trim();


    final encrypted = Aes256.encrypt(originalJson, "bR5z6*r\$00p#Eno__odrEgeW");

    String encoded = base64.encode(utf8.encode(encrypted));

    debugPrint('Checking -- ${encoded}');
    var finalUrl = "${widget.baseUrl}?data=$encoded";
    debugPrint('final url -- $finalUrl');

    webViewController.loadRequest(Uri.parse(finalUrl));

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{

        var canGoBack = false;

          if(await webViewController.canGoBack()){
            webViewController.goBack();
            canGoBack = false;
          }else{
            canGoBack = true;
          }
        return canGoBack;
      },
      child: Scaffold(
        body: SafeArea(child: WebViewWidget(controller: webViewController)),
      ),
    );
  }
}
