import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;

import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Downloader {
  BuildContext context;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String fileName;

  var onReceiveProgress;

  Downloader(
      {required BuildContext this.context,
      required String this.fileName,
      required onReceiveProgress}) {
    print("constructor call");
    DownloadInit();
  }

  void DownloadInit() {
    print("Download init start");
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    print(flutterLocalNotificationsPlugin);
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = IOSInitializationSettings();
    final initSettings = InitializationSettings(android: android, iOS: iOS);

    flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: _onSelectNotification);
    print("Download init end");
  }

  Future<void> _onSelectNotification(String? json) async {
    final obj = jsonDecode(json!);

    if (obj['isSuccess']) {
      OpenFile.open(obj['filePath']);
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('${obj['error']}'),
        ),
      );
    }
  }

  download(String fileUrl, void onReceive(int? received, int? total)) async {
    var permission = await Permission.storage.request();
    if (permission.isGranted) {
      _download(fileName, fileUrl, onReceive);
    } else {
      print("Sin permisos");
    }
  }

  Future<Directory?> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      return await DownloadsPathProvider.downloadsDirectory;
    }

    // in this example we are using only Android and iOS so I can assume
    // that you are not trying it for other platforms and the if statement
    // for iOS is unnecessary

    // iOS directory visible to user
    return await getApplicationDocumentsDirectory();
  }

  _download(
      fileName, fileUrl, void onReceive(int? received, int? total)) async {
    final dir = await _getDownloadDirectory();

    final savePath = path.join(dir!.path, fileName);
    await _startDownload(savePath, fileUrl, onReceive);
  }

  Future<void> _startDownload(String savePath, String fileUrl,
      void onReceive(int? received, int? total)) async {
    print("Executed");
    Map<String, dynamic> result = {
      'isSuccess': false,
      'filePath': null,
      'error': null,
    };
    try {
      print(fileUrl);
      var _dio = Dio();
      final response =
          await _dio.download(fileUrl, savePath, onReceiveProgress: onReceive);
      result['isSuccess'] = response.statusCode == 200;
      result['filePath'] = savePath;
    } catch (ex) {
      result['error'] = ex.toString();
    } finally {
      print(result);
      await _showNotification(result);
    }
  }

  Future<void> _showNotification(Map<String, dynamic> downloadStatus) async {
    print(flutterLocalNotificationsPlugin);
    print("Ejecutando show notification");
    final android = AndroidNotificationDetails(
        'channel id',
        'channel name'
            'channel description',
        priority: Priority.high,
        importance: Importance.max);
    final iOS = IOSNotificationDetails();
    final platform = NotificationDetails(android: android, iOS: iOS);
    final json = jsonEncode(downloadStatus);
    final isSuccess = downloadStatus['isSuccess'];

    await flutterLocalNotificationsPlugin.show(
        0, // notification id
        isSuccess ? 'Success' : 'Failure',
        isSuccess
            ? 'File has been downloaded successfully!'
            : 'There was an error while downloading the file.',
        platform,
        payload: json);
  }
}
