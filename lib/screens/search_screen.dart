import 'package:chat_app/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/services/helper_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets.dart';
import 'chat_screen.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchTextEditingController = TextEditingController();
  DatabaseMethods databaseMethods = DatabaseMethods();
  QuerySnapshot <Map<String, dynamic>>? searchResultSnapshot;
  bool isLoading = false;

  initiateSearch() {
    databaseMethods
        .getUserByUsername(searchTextEditingController.text)
        .then((value) {
      setState(() {
        searchResultSnapshot = value;
      });
    });
  }

  createChatRoomAndStartConversation(String searchedUser){
    if (searchedUser != Constants.currentUser){
      String chatRoomId = getChatRoomId(searchedUser, Constants.currentUser);

      List<String> users = [searchedUser, Constants.currentUser];
      Map<String, dynamic> chatRoomMap = {
        "users": users,
        "chatroomId": chatRoomId
      };

      databaseMethods.createChatRoom(chatRoomId, chatRoomMap);
      Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatScreen(chatRoomId: chatRoomId, sender: searchTextEditingController.text,)));
    } else {
      print('You cannot message to yourself!');
    }
  }

  Widget SearchTile ({required String userName, required String userEmail}){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: mediumTextFieldStyle(),
              ),
              Text(
                userEmail,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    decoration: TextDecoration.none
                ),
              )
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: (){
              createChatRoomAndStartConversation(userName);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                'Message',
                style: mediumTextFieldStyle(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget searchList() {
    return searchResultSnapshot != null
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchResultSnapshot!.docs.length,
            itemBuilder: (context, index) {
              return SearchTile(
                  userEmail: searchResultSnapshot!.docs[index]["email"],
                  userName: searchResultSnapshot!.docs[index]["name"]);
            })
        : Container();
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo () async{
    Constants.currentUser = (await HelperFunctions.getUserNameSharedPreference())!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Chat'),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              color: Color(0x54FFFFFF),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    controller: searchTextEditingController,
                    style: mediumTextFieldStyle(),
                    decoration: InputDecoration.collapsed(
                      hintText: 'Search userame...',
                      hintStyle: TextStyle(color: Colors.white54, fontSize: 17),
                      border: InputBorder.none,
                    ),
                  )),
                  GestureDetector(
                    onTap: () {
                      initiateSearch();
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          const Color(0x36FFFFFF),
                          const Color(0x0FFFFFFF),
                        ]),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            searchList(),
          ],
        ),
      ),
    );
  }
}

getChatRoomId(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b\_$a";
  } else {
    return "$a\_$b";
  }
}