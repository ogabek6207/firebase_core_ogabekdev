import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class Storage {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<void> uploadFile(String filePath, String fileName) async {
    File file = File(filePath);
    try {
      await storage.ref('test/$fileName').putFile(file);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<ListResult> listFiles() async {
    ListResult result = await storage.ref('test').listAll();
    for (var ref in result.items) {
      if (kDebugMode) {
        print('Found file: $ref');
      }
    }
    return result;
  }
}
