import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_downloads/src/herlpers/downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;

import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _progress = "-";
  String fileUrl =
      "https://www.porntrex.com/get_image/14/fcfc30d39b45afa3d979760275f201af/sources/37000/37142/5107236.jpg/";
  void _onReceiveProgress(int received, int total) {
    print("Executada progreso");
    print("$received, $total");
    if (total != -1) {
      setState(() {
        _progress = (received / total * 100).toStringAsFixed(0) + "%";
        print(_progress);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var download = Downloader(
        context: context,
        fileName: "example",
        onReceiveProgress: _onReceiveProgress);
    @override
    void initState() {
      super.initState();
      download.DownloadInit();
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Download progress:',
            ),
            Text(
              '$_progress',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => download.download(fileUrl),
        tooltip: 'Download',
        child: Icon(Icons.file_download),
      ),
    );
  }
}
