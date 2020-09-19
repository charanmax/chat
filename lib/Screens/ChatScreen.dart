import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Widgets/MessageBubble.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  FirebaseUser _user;
  DocumentSnapshot _documentSnapshot;
  String currentUser;
  bool _isInit = true;
  final _controller = TextEditingController();
  final PreferredSizeWidget _appbar = AppBar(
    title: Text('Chat Screen'),
    actions: <Widget>[
      DropdownButton(
          icon: const Icon(Icons.more_vert),
          onChanged: (identifier) {
            if (identifier == 'logout') {
              FirebaseAuth.instance.signOut();
            }
          },
          items: [
            DropdownMenuItem(
              value: 'logout',
              child: Container(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.exit_to_app),
                    SizedBox(
                      width: 10,
                    ),
                    Text('LogOut')
                  ],
                ),
              ),
            )
          ])
    ],
  );
  @override
  @override
  void didChangeDependencies() async {
    if (_isInit) {
      _user = await FirebaseAuth.instance.currentUser();
      _documentSnapshot = await Firestore.instance
          .collection('/users')
          .document(_user.uid)
          .get();
      _isInit = false;
    }
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  var _newMessage;
  void _sendMessage() async {
    if (_newMessage == null) {
      return;
    }
    FocusScope.of(context).requestFocus(FocusNode());
    _controller.clear();

    await Firestore.instance.collection('/chat').add({
      'createdAt': Timestamp.now(),
      'text': _newMessage,
      'userName': _documentSnapshot['username'],
      'userId': _user.uid,
      'image': _documentSnapshot['url'],
    });
    _newMessage = null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _appbar,
        body: FutureBuilder(
          future: FirebaseAuth.instance.currentUser(),
          builder: (ctx, userSnapshot) =>
              userSnapshot.connectionState == ConnectionState.waiting
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : StreamBuilder(
                      stream: Firestore.instance
                          .collection('/chat')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) => snapshot.data == null
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : Column(
                              children: <Widget>[
                                Expanded(
                                  child: ListView.builder(
                                    reverse: true,
                                    itemCount: snapshot.data.documents.length,
                                    itemBuilder: (c, i) => MessageBubble(
                                        snapshot.data.documents[i]['text'],
                                        snapshot.data.documents[i]['userName'],
                                        userSnapshot.data.uid ==
                                            snapshot.data.documents[i]
                                                ['userId'],
                                        snapshot.data.documents[i]['image']),
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: TextField(
                                        controller: _controller,
                                        onChanged: (val) => _newMessage = val,
                                        decoration: InputDecoration(
                                            labelText: 'Send a Message'),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.send),
                                      color: Theme.of(context).primaryColor,
                                      onPressed: _sendMessage,
                                    )
                                  ],
                                )
                              ],
                            ),
                    ),
        ),
      ),
    );
//    floatingActionButton: FloatingActionButton(
//    child: Icon(Icons.add),
//    onPressed: () {
//    Firestore.instance
//        .collection('/chat/g1PuzvVRleSSECiFkZex/messages')
//        .add({'text': 'hi there'});
//    },
//    ),;
  }
}
