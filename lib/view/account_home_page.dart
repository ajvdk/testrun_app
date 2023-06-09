import 'package:flutter/material.dart';
import 'package:testrun_app/models/user.dart';
import 'package:testrun_app/services/userAPI.dart';
import 'package:testrun_app/view/updateUserForm.dart';

import 'AppBarContent.dart';
import 'addUserForm.dart';



class AccountHomePage extends StatefulWidget {
  const AccountHomePage({Key? key}) : super(key: key);

  @override
  State<AccountHomePage> createState() => _AccountHomePageState();
}

class _AccountHomePageState extends State<AccountHomePage> {
  List<User>? users;
  var isLoaded = false;

  // Show 'Failed to load user data in pop-up box'
  void showErrorMessage() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: const Text("Failed to load user data."),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Set initial state
  @override
  void initState() {
    super.initState();
    getRecord();
  }

  Future<void> getRecord() async {
    print('begin get Record');

    try {
      final userList = await UserApi().getAllUsers();
      if (userList != null) {
        setState(() {
          users = userList;
          isLoaded = true;
        });
      } else {
        showErrorMessage();
      }
    } catch (e) {
      showErrorMessage();
    }
  }

  Future<void> showMessageDialog(String title, String msg) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(
            msg,
        ),
        ),
        actions: <Widget>[
          TextButton(
        child: const Text('Ok'),
        onPressed: () => Navigator.of(context).pop(),
        ),
        ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[Colors.blueAccent, Colors.blue],
            ),
          ),
          child: const AppBarContent(),
        ),
      ),
        body: Visibility (
          visible: isLoaded,
          replacement: const Center(child: CircularProgressIndicator()),
          child: ListView.builder(
          itemCount: users?.length,
          itemBuilder: (context, index){
            // Figure out how to get padding in list tile
            return Container(
              padding: const EdgeInsets.fromLTRB(30.0, 0.0, 100.0, 20.0),
              child: ListTile(
                title: Text(users![index].name),
                subtitle: Text(users![index].contact),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // Edit Icon
                    IconButton(onPressed: () async {
                      print('user id is ${users![index].id}'); //test id retrieval
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=> updateUserForm(users![index]))
                      ).then((data) {
                        if (data!= null) {
                          showMessageDialog("Success", "$data Detail Updated Success.");
                          getRecord();
                        }

                      });
                    },
                      icon: const Icon(
                          Icons.edit,
                          color: Colors.blue
                      ),
                    ),

                    // Delete Icon
                    IconButton(onPressed: () async {
                      print('user id is ${users![index].id}'); //test id retrieval
                      var user = await UserApi().deleteUser(users![index].id);
                      showMessageDialog("Success", "$user Detail Deleted Success.");
                      getRecord();
                    },
                      icon: const Icon(
                          Icons.delete,
                          color: Colors.red
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          Navigator.push(
              context,
                MaterialPageRoute(builder: (context)=>const addUserForm())
          ).then((data) {
            if (data != null) {
              showMessageDialog("Success", "$data Detail Add Success.");
              getRecord();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}


