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
    // readUsers();
    super.initState();
  }

  Widget buildUser(User user) => ListTile(
    leading: CircleAvatar(
      child: Text('${user.age}'),
    ),
    title: Text(user.name),
    subtitle: Text(user.birthday.toIso8601String()),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All User"),
      ),
      body: FutureBuilder<User?>(
        future: readUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final users = snapshot.data!;
            // ignore: unnecessary_null_comparison
            if (users == null) {
              return const Center(
                child: Text("No user"),
              );
            } else {
              return buildUser(users);
            }
          } else if (snapshot.hasError) {
            return const Center(child: Text("SomeThing Error"));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }



  Future<User?> readUser() async {
    final docUser = FirebaseFirestore.instance.collection('users').doc('1');
    final snapshot = await docUser.get();
    if (snapshot.exists) {
      return User.fromJson(snapshot.data()!);
    }
    return null;
  }
}