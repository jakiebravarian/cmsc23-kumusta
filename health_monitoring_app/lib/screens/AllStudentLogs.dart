// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_app/providers/user_provider.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';

class AllStudentsPage extends StatefulWidget {
  const AllStudentsPage({super.key});
  @override
  AllStudentsPageState createState() => AllStudentsPageState();
}

class AllStudentsPageState extends State<AllStudentsPage> {
  TextEditingController searchController = TextEditingController();
  List<UserModel> users = [];
  List<UserModel> filteredUsers = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> allUserStream =
        context.watch<UserProvider>().allUserStream;

    allUserStream.listen((QuerySnapshot snapshot) {
      List<UserModel> updatedUsers = [];

      // Iterate over the documents in the snapshot and convert them to UserModels
      for (var doc in snapshot.docs) {
        UserModel user = UserModel.fromJson(doc.data() as Map<String, dynamic>);

        updatedUsers.add(user);
      }

      // Update the users list and filteredUsers list
      setState(() {
        users = updatedUsers;
        filteredUsers = updatedUsers;
      });
    });

    void filterUsers(String query) {
      setState(() {
        filteredUsers = users
            .where((user) =>
                user.name!.toLowerCase().contains(query.toLowerCase()) ||
                user.stdnum!.contains(query) ||
                user.college!.toLowerCase().contains(query.toLowerCase()) ||
                user.course!.toLowerCase().contains(query.toLowerCase()) ||
                user.email!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }

    searchEngine() {
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                filterUsers(value);
              },
              decoration: const InputDecoration(
                labelText: 'Search',
              ),
            ),
          ),
          ListView.builder(
            itemCount: filteredUsers.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              return ListTile(
                title: Text("${user.name}"),
                subtitle: Wrap(
                  children: [
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.deepPurple.shade200,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text("${user.college}")),
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.deepPurple.shade200,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text("${user.course}")),
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.deepPurple.shade200,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text("${user.email}")),
                    Container(
                        decoration: BoxDecoration(
                            color: Colors.deepPurple.shade200,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text("${user.stdnum}"))
                  ],
                ),
              );

              // ListTile(
              //   title: Text(user.name!),
              //   subtitle: Text(user.stdnum!),
              //   onTap: () {
              //     print("User's profile");
              //   },
              // );
            },
          ),
        ],
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("All Students"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              searchEngine(),
            ],
          ),
        ));
  }
}