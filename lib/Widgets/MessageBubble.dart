import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final message;
  final userName;
  final isMe;
  final image;
  MessageBubble(this.message, this.userName, this.isMe, this.image);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(vertical: 12, horizontal: 7),
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 7),
              width: 140,
              decoration: BoxDecoration(
                color: isMe ? Colors.grey : Theme.of(context).accentColor,
                borderRadius: isMe
                    ? BorderRadius.only(
                        topRight: Radius.circular(12),
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12))
                    : BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    userName,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isMe
                            ? Colors.black
                            : Theme.of(context)
                                .accentTextTheme
                                .headline6
                                .color),
                  ),
                  Text(
                    message,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontSize: 16,
                        color: isMe
                            ? Colors.black
                            : Theme.of(context)
                                .accentTextTheme
                                .headline6
                                .color),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
            left: isMe ? null : 140,
            right: isMe ? 140 : null,
            top: 0,
            child: CircleAvatar(
              backgroundImage: NetworkImage(image),
            )),
      ],
    );
  }
}
