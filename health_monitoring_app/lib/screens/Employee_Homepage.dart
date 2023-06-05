// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:project_app/models/entry_model.dart';
import 'package:project_app/providers/entry_provider.dart';

import 'package:project_app/providers/user_provider.dart';
import 'package:project_app/screens/AllStudentsPage.dart';
import 'package:project_app/screens/EditEntry.dart';
import 'package:project_app/screens/Entry.dart';
import 'package:project_app/screens/UnderMonitoringStudentsPage.dart';
import 'package:project_app/screens/login.dart';
import 'package:provider/provider.dart';
import '../models/log_model.dart';
import '../models/user_model.dart';
import '../providers/log_provider.dart';

import '../providers/auth_provider.dart';
import 'AllStudentLogs.dart';
import 'QuarantinedStudentsPage.dart';
import 'RequestsPage.dart';

class EmployeeHomepage extends StatefulWidget {
  const EmployeeHomepage({super.key});
  @override
  EmployeepageState createState() => EmployeepageState();
}

class EmployeepageState extends State<EmployeeHomepage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Stream<User?> userStream = context.watch<AuthProvider>().userStream;
    Stream<QuerySnapshot> allUserStream =
        context.watch<UserProvider>().allUserStream;

    StreamBuilder allUsersListBuilder = StreamBuilder(
        stream: allUserStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error encountered! ${snapshot.error}"),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text("No Entries Found"),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data?.docs.length,
            itemBuilder: ((context, index) {
              UserModel user = UserModel.fromJson(
                  snapshot.data?.docs[index].data() as Map<String, dynamic>);

              user.id = snapshot.data?.docs[index].id;

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
                        child: Text("Is quarantined: ${user.isQuarantined}"))
                  ],
                ),
              );
            }),
          );
        });

    outlinedButtonBuilder(title, purpose) {
      return (OutlinedButton(
          onPressed: () {
            if (purpose == "all") {
              Navigator.push(
                  //get all students here
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllStudentsLogs(),
                  ));
              context.read<UserProvider>().fetchAllUsers();
            } else if (purpose == "quarantined") {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuarantinedStudentsPage(),
                  ));
              context.read<UserProvider>().fetchQuarantinedUsers();
            } else if (purpose == "monitoring") {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UnderMonitoringStudentsPage(),
                  ));
              context.read<UserProvider>().fetchUnderMonitoringUsers();
            } else if (purpose == "request") {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RequestsPage(),
                  ));
            }
            context.read<EntryProvider>().fetchEntriesRequestingForEdit();
            context.read<EntryProvider>().fetchEntriesRequestingForDelete();
            // context.read<UserProvider>().changeValueInPreexistingIllness(key);
          },
          style: OutlinedButton.styleFrom(
              shadowColor: Colors.black87,
              elevation: 4,
              backgroundColor: Colors.purple.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.purple.shade100, width: 1)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.raleway(
                      textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -.5))),
              const SizedBox(
                width: 55,
                child: Icon(Icons.person),
              )
            ],
          )));
    }

    return Column(children: [
      outlinedButtonBuilder("View All Logs", "all"),
      outlinedButtonBuilder("View Quarantined Students", "quarantined"),
      outlinedButtonBuilder("View Under Monitoring Students", "monitoring"),
      outlinedButtonBuilder("View Students Requests", "request"),
    ]);
  }
}
