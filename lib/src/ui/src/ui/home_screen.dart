import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core_ogabekdev/service/notification_service.dart';
import 'package:firebase_core_ogabekdev/service/storage_service.dart';
import 'package:firebase_core_ogabekdev/src/ui/model/user_model.dart';
import 'package:firebase_core_ogabekdev/src/ui/src/ui/all_user_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerAge = TextEditingController();
  DateTime startDay = DateTime.now();

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
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AllUserScreen()));
            },
            child: Container(
                color: Colors.transparent,
                child: const Center(child: Text("All User"))),
          ),
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
          const SizedBox(
            height: 16,
          ),
          Container(
            padding: const EdgeInsets.only(left: 8, right: 8),
            margin: const EdgeInsets.only(left: 16, right: 16),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _controllerName,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Container(
            padding: const EdgeInsets.only(left: 8, right: 8),
            margin: const EdgeInsets.only(left: 16, right: 16),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _controllerAge,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                currentFocus.focusedChild?.unfocus();
              }
              DatePicker.showDatePicker(
                context,
                showTitleActions: true,
                minTime: DateTime(1900, 10, 08),
                maxTime: DateTime.now(),
                onConfirm: (date) {
                  startDay = date;
                  setState(() {});
                },
                currentTime: startDay,
                locale: LocaleType.en,
              );
            },
            child: Container(
              margin: const EdgeInsets.only(left: 16, right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    "${startDay.year}-${startDay.month}-${startDay.day}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontStyle: FontStyle.normal,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          GestureDetector(
            onTap: () {
              final user = User(
                name: _controllerName.text,
                age: int.parse(_controllerAge.text),
                birthday: startDay,
              );
              createUser(user);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AllUserScreen(),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(left: 16, right: 16),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              height: 48,
              child: const Center(
                child: Text(
                  "Add User",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initFirebase() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (kDebugMode) {
      print(token);
    }
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
  }

  Future createUser(User user) async {
    final docUser =
        FirebaseFirestore.instance.collection('users').doc(user.name);
    user.id = docUser.id;
    await docUser.set(user.toJson());
  }
}
