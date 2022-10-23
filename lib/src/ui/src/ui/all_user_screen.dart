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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All User"),
      ),
      body: StreamBuilder<QuerySnapshot<User>>(
        stream: getUsers.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          return ListView.builder(
            itemCount: data.docs.length,
            itemBuilder: (context, index) {
              return buildUser(data.docs[index].data());
            },
          );
        },
      ),
    );
  }

  Widget buildUser(User user) => ListTile(
        leading: CircleAvatar(
          child: Text('${user.age}'),
        ),
        title: Text(user.name),
        subtitle: Text(user.birthday.toIso8601String()),
      );

  final getUsers =
      FirebaseFirestore.instance.collection('users').withConverter<User>(
            fromFirestore: (snapshots, _) => User.fromJson(snapshots.data()!),
            toFirestore: (movie, _) => movie.toJson(),
          );
}
