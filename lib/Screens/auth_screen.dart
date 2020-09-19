import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Screens/AuthCard.dart';

class AuthScreen extends StatefulWidget {
  static const id = '/auth';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  final _auth = FirebaseAuth.instance;

  void _showError(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              title: Text(
                'Oops! An Error Occurred',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              elevation: 10,
              content: Text(
                message,
                textAlign: TextAlign.center,
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ));
  }

  Future<void> authenticateUser(String userName, String email, String password,
      bool isLogin, File userImage) async {
    AuthResult _authResult;
    try {
      setState(() {
        _isLoading = true;
      });
      isLogin
          ? _authResult = await _auth.signInWithEmailAndPassword(
              email: email, password: password)
          : _authResult = await _auth.createUserWithEmailAndPassword(
              email: email, password: password);
      if (!isLogin) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child(_authResult.user.uid + '.jpg');
        final url = await ref.putFile(userImage).onComplete;
        final userImageUrl = await url.ref.getDownloadURL();
        await Firestore.instance
            .collection('users')
            .document(_authResult.user.uid)
            .setData({
          'username': userName,
          'email': email,
          'url': userImageUrl,
        });
      }
    } on PlatformException catch (error) {
      var message = 'An error Occurred!Please Check you Credentials';
      if (error.message != null) {
        message = error.message;
      }
      _showError(message);
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      print(err);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.7),
                  Colors.red.withOpacity(0.7),
//                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
//                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 1.0],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    child: TypewriterAnimatedTextKit(
                        speed: Duration(milliseconds: 500),
                        repeatForever: true,
                        onTap: () {
                          print("Tap Event");
                        },
                        text: ['FlashChat'],
                        textStyle: GoogleFonts.pacifico(
                          color: Colors.white,
                          fontSize: 40,
                        ),
                        textAlign: TextAlign.center,
                        alignment: AlignmentDirectional
                            .topStart // or Alignment.topLeft
                        ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(authenticateUser, _isLoading),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
