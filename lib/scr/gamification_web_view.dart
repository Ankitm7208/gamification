
import 'dart:convert';
import 'dart:io';

import 'package:cupertino_will_pop_scope/cupertino_will_pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher_string.dart';
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




  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
      isInspectable: false,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true);

  String? finalUrl;

  bool canGoBack = true;

  @override
  void initState() {
    super.initState();

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
          "utm_source":"${Platform.isAndroid ? 'Android' : 'iOS'}"
        }
    """.trim();


    final encrypted = Aes256.encrypt(originalJson, "bR5z6*r\$00p#Eno__odrEgeW");

    String encoded = base64.encode(utf8.encode(encrypted));

    finalUrl = "${widget.baseUrl}?data=$encoded";

    // webViewController.loadUrl(urlRequest: URLRequest(url: WebUri(finalUrl)));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ConditionalWillPopScope(
      onWillPop: ()async{
        var canGoBack = false;

        if(webViewController == null){
          return true;
        }

        if(await webViewController!.canGoBack()){
          webViewController!.goBack();
          canGoBack = false;
        }else{
          canGoBack = true;
        }

        return canGoBack;
      },
      shouldAddCallback: canGoBack,
      child: Scaffold(
        body: SafeArea(child:
        InAppWebView(
          key: webViewKey,
          initialUrlRequest: URLRequest(url: WebUri(finalUrl ?? '')),
          initialSettings: settings,
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          onLoadStart: (controller, url) async{
            debugPrint('Checking taeget -- ${url}');
          },
          onPermissionRequest: (controller, request) async {
            return PermissionResponse(
                resources: request.resources,
                action: PermissionResponseAction.GRANT);
          },
          shouldOverrideUrlLoading: (controller, shouldOverrideUrlLoadingRequest) async {
            debugPrint('Checking url shouldOverrideUrlLoading -- ${shouldOverrideUrlLoadingRequest.request.url}');
            if(shouldOverrideUrlLoadingRequest.request.url.toString().contains('productAfflinkApi.php')){
              //Open other site url in external browser
              launchUrlString(shouldOverrideUrlLoadingRequest.request.url.toString(),mode: Platform.isIOS ? LaunchMode.inAppWebView : LaunchMode.externalApplication);
              return NavigationActionPolicy.CANCEL;
            }
            return NavigationActionPolicy.ALLOW;
          },
          onLoadStop: (controller, url) async {
            canGoBack = await controller.canGoBack();
            setState(() {});
          },
          onReceivedError: (controller, request, error) {
          },
          onProgressChanged: (controller, progress) async{

          },
          onUpdateVisitedHistory: (controller, url, androidIsReload) {
          },
          onConsoleMessage: (controller, consoleMessage) {
            debugPrint(consoleMessage.message);
          },
        ),
        ),
      ),
    );
  }

}
