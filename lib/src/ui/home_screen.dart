import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core_ogabekdev/service/notification_service.dart';
import 'package:firebase_core_ogabekdev/service/storage_service.dart';
import 'package:firebase_core_ogabekdev/src/ui/model/user_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerAge = TextEditingController();
  final TextEditingController _controllerBirthdate = TextEditingController();

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
        leading: TextField(
          controller: _controller,
        ),
        actions: [
          IconButton(
              onPressed: () {
                final name = _controller.text;
                createUser(name: name);
              },
              icon: Icon(Icons.add)),
        ],
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
          SizedBox(
            height: 16,
          ),
          Container(
            margin: EdgeInsets.only(left: 16, right: 16),
            width: MediaQuery.of(context).size.width,
            color: Colors.grey,
            child: TextField(
              controller: _controllerName,
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Container(
            margin: EdgeInsets.only(left: 16, right: 16),
            width: MediaQuery.of(context).size.width,
            color: Colors.grey,
            child: TextField(
              controller: _controllerAge,
            ),
          ),
          SizedBox(
            height: 16,
          ),
          Container(
            margin: EdgeInsets.only(left: 16, right: 16),
            width: MediaQuery.of(context).size.width,
            color: Colors.grey,
            child: TextField(
              controller: _controllerBirthdate,
            ),
          ),
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

  Future<void> createUser({required String name}) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc('1');

    final user = User(
      id: docUser.id,
      name: name,
      age: 21,
      birthday: DateTime(2001, 7, 28),
    );

    final json = user.toJson();

    await docUser.set(json);
  }
}
