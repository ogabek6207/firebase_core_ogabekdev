import 'package:file_picker/file_picker.dart';
import 'package:firebase_core_ogabekdev/service/notification_service.dart';
import 'package:firebase_core_ogabekdev/service/storage_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    _initFirebase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Storage storage = Storage();

    return Scaffold(
      appBar: AppBar(
        leading: FloatingActionButton(
          onPressed: () {
            notificationService.showNotification(
                13232332, "sdscsf", "sfv sf vfsv");
          },
        ),
      ),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () async {
                final results = await FilePicker.platform.pickFiles(
                  allowMultiple: false,
                  type: FileType.custom,
                  allowedExtensions: ['png', 'jpg'],
                );
                if (results == null) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Text("No file selected."),
                    ),
                  );
                  return;
                }
                final path = results.files.single.path;
                final fileName = results.files.single.name;
                storage.uploadFile(path!, fileName);
              },
              child: const Text("Upload file"),
            ),
          ),
          // FutureBuilder(future: storage.listFiles(),
          //   builder: (BuildContext context, AsyncSnapshot<>),
          // ),
        ],
      ),
    );
  }

  Future<void> _initFirebase() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print(token);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        notificationService.showNotification(
          notification.hashCode,
          notification.title ?? "",
          notification.body ?? "",
        );
      }
    });

    // FirebaseMessaging.onMessageOpenedApp.listen(
    //   (RemoteMessage message) {
    //     print("A new OnMessageOpenedApp event was published! ");
    //
    //     RemoteNotification? notification = message.notification;
    //     AndroidNotification? android = message.notification?.android;
    //     if (notification != null && android != null) {
    //       showDialog(
    //         context: context,
    //         builder: (_) {
    //           return AlertDialog(
    //             title: Text(notification.title!),
    //             content: SingleChildScrollView(
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Text(notification.body!),
    //                 ],
    //               ),
    //             ),
    //           );
    //         },
    //       );
    //     }
    //   },
    // );
  }
}
