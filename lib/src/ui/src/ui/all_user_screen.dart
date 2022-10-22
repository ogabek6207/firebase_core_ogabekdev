import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../model/user_model.dart';

class AllUserScreen extends StatefulWidget {
  const AllUserScreen({Key? key}) : super(key: key);

  @override
  State<AllUserScreen> createState() => _AllUserScreenState();
}

class _AllUserScreenState extends State<AllUserScreen> {
  @override
  void initState() {
    readUsers();
    super.initState();
  }

  Widget buildUser(User user) => ListTile(
        leading: CircleAvatar(
          child: Text('${user.age}'),
        ),
        title: Text(user.name),
        subtitle: Text(user.birthday.toIso8601String()),
      );

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All User"),
      ),
      body: FutureBuilder<User?>(
        future: readUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final users = snapshot.data!;
            return users == null
                ? Center(
                    child: Text("No user"),
                  )
                : buildUser(users);
          } else if (snapshot.hasError) {
            return Center(child: Text("SomeThing Error"));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Stream<List<User>> readUsers() => FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => User.fromJson(doc.data())).toList());

  Future<User?> readUser() async {
    final docUser = FirebaseFirestore.instance.collection('users').doc('1');
    final snapshot = await docUser.get();
    if (snapshot.exists) {
      return User.fromJson(snapshot.data()!);
    }
  }
}
