import 'package:chat_app_firebase/services/auth.dart';
import 'package:chat_app_firebase/services/database.dart';
import 'package:chat_app_firebase/widget/Widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPhone extends StatefulWidget {
  final Function toggle;
  SignUpPhone(this.toggle);

  @override
  _SignUpPhoneState createState() => _SignUpPhoneState();
}

class _SignUpPhoneState extends State<SignUpPhone> {
  final formkey = GlobalKey<FormState>();
  bool isLoading = false;
  String smsCode, verificationId;
  AuthMetods authMetods = new AuthMetods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController userNameTxEditCon, phoneTxEditCon, passwordTxEditCon;

  @override
  void initState() {
    super.initState();
    userNameTxEditCon = new TextEditingController();
    phoneTxEditCon = new TextEditingController();
    passwordTxEditCon = new TextEditingController();
  }

  Future<void> verifyPhone() async {
    if (formkey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      final PhoneCodeAutoRetrievalTimeout autoRetrieval = (String verId) {
        this.verificationId = verId;
      };

      final PhoneCodeSent smsCodeSend = (String verId, [int forceCodeResend]) {
        this.verificationId = verId;
        smsCodeDialog(context).then((val) {
          print("Sing IN");
        });
      };

      final PhoneVerificationCompleted verifySccess = (AuthCredential user) {
        print("verified");
      };

      final PhoneVerificationFailed verifyFaild = (AuthException exception) {
        print("${exception.message}");
      };

      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: "+91" + phoneTxEditCon.text,
          timeout: Duration(seconds: 5),
          verificationCompleted: verifySccess,
          verificationFailed: verifyFaild,
          codeSent: smsCodeSend,
          codeAutoRetrievalTimeout: autoRetrieval);
    }
  }

  Future<bool> smsCodeDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text("Enter Verification Code"),
            content: TextField(
              onChanged: (value) {
                this.smsCode = value;
              },
            ),
            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    FirebaseAuth.instance.currentUser().then((user) async {
                      if (user != null) {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacementNamed('/ChatRoom');
                      } else {
                        Navigator.of(context).pop();
                        //this line error
                        await authMetods
                            .signInWithPhone(this.verificationId, this.smsCode)
                            .then((user) {
                          if (user != null) {
                            authMetods.saveUserData(
                                user, userNameTxEditCon.text);
                            Navigator.of(context)
                                .pushReplacementNamed('/ChatRoom');
                          }
                          print(user.uid);
                        });
                      }
                    });
                  },
                  child: Text("Done"))
            ],
          );
        });
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
                                  ? "Please Provider User Name is greater than 4 letter"
                                  : null;
                            },
                            controller: userNameTxEditCon,
                            style: simpleStyle(),
                            decoration:
                                textFieldDec("User Name", Icons.perm_identity),
                          ),
                          TextFormField(
                            controller: phoneTxEditCon,
                            style: simpleStyle(),
                            decoration: InputDecoration(
                              prefixText: "+91 ",
                              prefixIcon:
                                  Icon(Icons.phone, color: Colors.white),
                              hintText: "Phone No",
                              hintStyle: TextStyle(color: Colors.white54),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (String val) {
                              if (val.isEmpty) {
                                return "Phone No (+91 xxx-xxx-xxxx)";
                              } else if (val.length < 10) {
                                return "Phone 10 Digit only";
                              }
                            },
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
                            decoration: textFieldDec("Password", Icons.lock),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    InkWell(
                      onTap: verifyPhone,
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
                        child: Text("Sing Up Phone ", style: biggerTextStyle()),
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
