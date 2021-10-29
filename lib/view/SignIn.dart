import 'package:chat_app_firebase/helper/helperFun.dart';
import 'package:chat_app_firebase/services/auth.dart';
import 'package:chat_app_firebase/services/database.dart';
import 'package:chat_app_firebase/view/chatRoom.dart';
import 'package:chat_app_firebase/view/forgetPass.dart';
import 'package:chat_app_firebase/widget/Widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  final Function toggle;
  SignIn(this.toggle);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController emailTxEditCon, passwordTxEditCon;
  final formkey = GlobalKey<FormState>();
  AuthMetods authMetods = new AuthMetods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  bool isLoading = false;
  QuerySnapshot userInfoSnapshot;
  String errorMs;

  @override
  void initState() {
    super.initState();
    emailTxEditCon = new TextEditingController();
    passwordTxEditCon = new TextEditingController();
  }

  signIn() async {
    if (formkey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      try {
        await authMetods
            .signInWithEandP(emailTxEditCon.text, passwordTxEditCon.text)
            .then((value) async {
          if (value == "ERROR_USER_NOT_FOUND" ||
              value == "ERROR_WRONG_PASSWORD") {
            setState(() {
              errorMs = value == "ERROR_USER_NOT_FOUND"
                  ? "Email Not Register Please click on Register now"
                  : "Invalid Password";
              isLoading = false;
              passwordTxEditCon.text = "";
            });
          } else if (value != null) {
            errorMs = null;
            userInfoSnapshot =
                await databaseMethods.getByUserEmail(emailTxEditCon.text);
            if (userInfoSnapshot.documents.length > 0) {
              HelperFunction.saveUName(
                  userInfoSnapshot.documents[0].data["name"]);
              HelperFunction.saveUEmail(
                  userInfoSnapshot.documents[0].data["email"]);
              HelperFunction.saveLogin(true);
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => ChatRoom()));
            }
          } else {
            setState(() {
              isLoading = false;
            });
          }
        });
      } catch (e) {
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height - 90,
                padding: EdgeInsets.symmetric(horizontal: 24),
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Form(
                      key: formkey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            validator: (val) {
                              return RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(val)
                                  ? null
                                  : "Please Enter Correct Email";
                            },
                            controller: emailTxEditCon,
                            style: simpleStyle(),
                            decoration:
                                textFieldDec("email", Icons.perm_identity),
                          ),
                          TextFormField(
                            obscureText: true,
                            validator: (val) {
                              return val.length > 6
                                  ? null
                                  : "Please provide password 6+ word";
                            },
                            controller: passwordTxEditCon,
                            style: simpleStyle(),
                            decoration: textFieldDec("password", Icons.lock),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ForgetPass()));
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Text(
                              "Forgot Password",
                              style: simpleStyle(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Visibility(
                        child: Text(
                          errorMs != null ? errorMs : "",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        visible: errorMs != null ? true : false),
                    SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        signIn();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              const Color(0xff007EF4),
                              const Color(0xff2A75BC)
                            ]),
                            borderRadius: BorderRadius.circular(30)),
                        child: Text("Sing In ", style: mediumStyle()),
                      ),
                    ),
                    SizedBox(height: 16),
                    InkWell(
                      onTap: () => authMetods.googleSingIn(),
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30)),
                        child: Text("Sing In with Google ",
                            style: TextStyle(
                              color: CustomTheme.textColor,
                              fontSize: 17,
                            )),
                      ),
                    ),
                    SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Text("Don't have account? ", style: mediumStyle()),
                        GestureDetector(
                          onTap: () {
                            widget.toggle();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 5),
                            child: Text("Register now",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  decoration: TextDecoration.underline,
                                )),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
            ),
    );
  }
}
