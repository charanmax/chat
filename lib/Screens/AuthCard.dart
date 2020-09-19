import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum AuthMode { Signup, Login }

class AuthCard extends StatefulWidget {
  final Function authenticateUser;
  final bool isLoading;

  AuthCard(this.authenticateUser, this.isLoading);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _opacity;
  ImagePicker _imagePicker = ImagePicker();
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    // TODO: implement initState
    super.initState();
  }

  File userImage;

  Future<void> _selectImage() async {
    final pickedImage = await _imagePicker.getImage(
        source: ImageSource.camera, imageQuality: 50, maxWidth: 140);
    if (pickedImage == null) {
      return;
    }
    setState(() {
      userImage = File(pickedImage.path);
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, dynamic> _authData = {
    'email': '',
    'password': '',
    'userName': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  void _submit(AuthMode authMode) async {
    bool isLogin;
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    if (_authMode == AuthMode.Signup && userImage == null) {
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Oops!'),
          content: Text('Pick an Image'),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(c).pop();
              },
            )
          ],
        ),
      );
      return;
    }
    isLogin = authMode.toString().substring(9) == 'Login' ? true : false;

    _formKey.currentState.save();
    widget.authenticateUser(_authData['userName'], _authData['email'],
        _authData['password'], isLogin, userImage);

//    setState(() {
//      _isLoading = true;
//    });
////    try {
////      if (_authMode == AuthMode.Login) {
////        await Provider.of<Login>(context, listen: false)
////            .signIn(_authData['email'], _authData['password']);
////      } else {
////        await Provider.of<Login>(context, listen: false)
////            .signUp(_authData['email'], _authData['password']);
////      }
////    } on HttpException catch (error) {
////      var errorMessage = 'Authentication Failed';
////      if (error.toString().contains('EMAIL_EXISTS')) {
////        errorMessage = 'The entered email is already in use';
////      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
////        errorMessage = 'The entered email is not found';
////      } else if (error.toString().contains('INVALID_EMAIL')) {
////        errorMessage = 'The entered email is invalid';
////      } else if (error.toString().contains('WEAK_PASSWORD')) {
////        errorMessage = 'The entered password is Weak';
////      } else if (error.toString().contains('INVALID_PASSWORD')) {
////        errorMessage = 'Password is incorrect';
////      }
////      _showError(errorMessage);
////    } catch (error) {
////      var errorMessage =
////          'Sorry,Could not Authenticate you,Please Check Your Network';
////      _showError(errorMessage);
////    }
//    setState(() {
//      _isLoading = false;
//    });
//  }
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
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
        height: _authMode == AuthMode.Signup ? 500 : 280,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                if (_authMode == AuthMode.Signup)
                  FadeTransition(
                      opacity: _opacity,
                      child: Container(
                        height: 100,
                        width: 100,
                        child: CircleAvatar(
                          child: userImage == null
                              ? GestureDetector(
                                  onTap: _selectImage,
                                  child: Text('Pick Image'),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: Image.file(
                                    userImage,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                        ),
                      )),
                if (_authMode == AuthMode.Signup)
                  FadeTransition(
                    opacity: _opacity,
                    child: TextFormField(
                        enabled: _authMode == AuthMode.Signup,
                        onSaved: (value) {
                          _authData['userName'] = value.trim();
                        },
                        decoration: InputDecoration(
                            labelText: 'UserName',
                            labelStyle: TextStyle(
                              color: Colors.white,
                            )),
                        validator: (val) {
                          if (val.length < 6) {
                            return 'Please Enter a minimum of 6 characters';
                          }
                          return null;
                        }),
                  ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'E-Mail',
                      labelStyle: TextStyle(
                        color: Colors.white,
                      )),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value.trim();
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        color: Colors.white,
                      )),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value.trim();
                  },
                ),
                if (_authMode == AuthMode.Signup)
                  FadeTransition(
                    opacity: _opacity,
                    child: TextFormField(
                      enabled: _authMode == AuthMode.Signup,
                      decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: TextStyle(
                            color: Colors.white,
                          )),
                      obscureText: true,
                      validator: _authMode == AuthMode.Signup
                          ? (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match!';
                              }
                              return null;
                            }
                          : null,
                    ),
                  ),
                SizedBox(
                  height: 20,
                ),
                if (widget.isLoading)
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                if (!widget.isLoading)
                  RaisedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: () {
                      _submit(_authMode);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                if (!widget.isLoading)
                  FlatButton(
                    child: Text(
                        '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                    onPressed: _switchAuthMode,
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textColor: Theme.of(context).primaryColor,
                  ),
                FlatButton(
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                  child: Text(
                    'FORGOT PASSWORD',
                    style: TextStyle(),
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                              title: Text(
                                'Enter your Email',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              content: TextField(
                                decoration: InputDecoration(labelText: 'Email'),
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('Submit'),
                                  onPressed: () {
                                    Scaffold.of(context).showSnackBar(
                                      SnackBar(
                                        duration: Duration(seconds: 2),
                                        elevation: 15,
                                        content: Text(
                                            'A link to reset password is sent to your mail'),
                                      ),
                                    );
                                    Navigator.of(ctx).pop();
                                  },
                                )
                              ],
                            ));
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
