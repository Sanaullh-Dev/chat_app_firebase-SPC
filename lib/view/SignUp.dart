import 'package:chat_app_firebase/helper/helperFun.dart';
import 'package:chat_app_firebase/services/auth.dart';
import 'package:chat_app_firebase/services/database.dart';
import 'package:chat_app_firebase/view/chatRoom.dart';
import 'package:chat_app_firebase/widget/Widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  final Function toggle;
  SignUp(this.toggle);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final formkey = GlobalKey<FormState>();
  bool isLoading = false;
  AuthMetods authMetods = new AuthMetods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController userNameTxEditCon, emailTxEditCon, passwordTxEditCon;

  googleSignIn() {
    if (formkey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      authMetods.googleSingIn();
    }
  }

  signMeup() async {
    if (formkey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      await authMetods
          .signUpwithEandP(emailTxEditCon.text, passwordTxEditCon.text)
          .then((val) {
        if (val != null)
          // Map<String, String> userInfo = {
          //   "name": userNameTxEditCon.text,
          //   "email": emailTxEditCon.text,
          // };
          // databaseMethods.uploadUserInfo(userInfo);
          // HelperFunction.saveLogin(true);
          // HelperFunction.saveUName(userNameTxEditCon.text);
          // HelperFunction.saveUEmail(emailTxEditCon.text);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => ChatRoom()));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    userNameTxEditCon = new TextEditingController();
    emailTxEditCon = new TextEditingController();
    passwordTxEditCon = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: isLoading
          ? Center(
              child: Container(
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height - 90,
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: <Widget>[
                    Spacer(),
                    Form(
                      key: formkey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            validator: (val) {
                              return val.isEmpty || val.length < 4
                                  ? "Please Provider User Name"
                                  : null;
                            },
                            controller: userNameTxEditCon,
                            style: simpleStyle(),
                            decoration:
                                textFieldDec("user name", Icons.perm_identity),
                          ),
                          TextFormField(
                            validator: (val) {
                              return RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(val)
                                  ? null
                                  : "Enter correct email";
                            },
                            controller: emailTxEditCon,
                            style: simpleStyle(),
                            decoration: textFieldDec("email", Icons.email),
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
                    InkWell(
                      onTap: () {
                        signMeup();
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
                        child: Text("Sing Up ", style: biggerTextStyle()),
                      ),
                    ),
                    SizedBox(height: 16),
                    InkWell(
                      onTap: () => googleSignIn(),
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30)),
                        child: Text("Sing Up with Google ",
                            textAlign: TextAlign.center,
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
                        Text("Already have account? ", style: mediumStyle()),
                        GestureDetector(
                          onTap: () {
                            widget.toggle();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text("Sign In now",
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
