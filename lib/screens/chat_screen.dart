import 'package:chat_app/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String sender;

  ChatScreen({required this.chatRoomId, required this.sender});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  DatabaseMethods databaseMethods = DatabaseMethods();
  TextEditingController messageController = TextEditingController();
  ScrollController messageScrollController = ScrollController();
  Stream<QuerySnapshot>? chatMessagesStream;

  Widget Messenger() {
    return StreamBuilder<QuerySnapshot>(
        stream: chatMessagesStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
              controller: messageScrollController,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return MessageTile(
                    snapshot.data!.docs[index]['message'],
                    snapshot.data!.docs[index]['sender'] ==
                        Constants.currentUser);
              })
              : Container();
        });
  }

  sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        'message': messageController.text,
        'sender': Constants.currentUser,
        'time': DateTime
            .now()
            .millisecondsSinceEpoch,
      };
      databaseMethods.addMessages(widget.chatRoomId, messageMap);
      messageController.clear();
    }
  }

  getMessages() {
    databaseMethods.getMessages(widget.chatRoomId);
  }

  @override
  void initState() {
    databaseMethods.getMessages(widget.chatRoomId).then((value) {
      setState(() {
        chatMessagesStream = value;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.sender}'),
      ),
      body: Container(
        child: Stack(
          children: [
            Messenger(),
            Container(
              alignment: AlignmentDirectional.bottomCenter,
              child: Container(
                color: Color(0x54FFFFFF),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                          controller: messageController,
                          style: mediumTextFieldStyle(),
                          decoration: InputDecoration.collapsed(
                            hintText: 'Message...',
                            hintStyle:
                            TextStyle(color: Colors.white54, fontSize: 17),
                            border: InputBorder.none,
                          ),
                        )),
                    GestureDetector(
                      onTap: () {
                        messageScrollController.animateTo(
                            messageScrollController.position.maxScrollExtent,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.ease);
                        sendMessage();
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
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool currentSender;

  MessageTile(this.message, this.currentSender);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
            left: currentSender ? 42 : 24, right: currentSender ? 24 : 42),
        margin: EdgeInsets.symmetric(vertical: 8),
        width: MediaQuery
            .of(context)
            .size
            .width,
        alignment: currentSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: currentSender
                    ? [const Color(0xff007EF4), const Color(0xff2A75BC)]
                    : [const Color(0x1AFFFFFF), const Color(0x1AFFFFFF)],
              ),
              borderRadius: currentSender
                  ? BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomLeft: Radius.circular(23))
                  : BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomRight: Radius.circular(23))),
          child: Text(
            message,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
