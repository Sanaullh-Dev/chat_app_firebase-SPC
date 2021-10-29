import 'package:chat_app_firebase/helper/helperFun.dart';
import 'package:chat_app_firebase/modal/user.dart';
import 'package:chat_app_firebase/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

final AuthMetods authMetods = AuthMetods();

class AuthMetods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Firestore _db = Firestore.instance;
  final DatabaseMethods databaseMethods = new DatabaseMethods();

  Observable<FirebaseUser> user;
  Observable<Map<String, dynamic>> profile;
  PublishSubject loading = PublishSubject();

  AuthMetods() {
    user = Observable(_auth.onAuthStateChanged);

    profile = user.switchMap((FirebaseUser u) {
      if (u != null) {
        return _db
            .collection("users")
            .document(u.uid)
            .snapshots()
            .map((snap) => snap.data);
      } else {
        return Observable.just({});
      }
    });
  }

  Future<FirebaseUser> googleSingIn() async {
    loading.add(true);
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAut =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAut.idToken,
        accessToken: googleSignInAut.accessToken);
    final AuthResult authResult = await _auth.signInWithCredential(credential);

    FirebaseUser user = authResult.user;
    saveUserData(user, user.displayName);
    print("signed in " + user.displayName);
    loading.add(false);
    return user;
  }

  void saveUserData(FirebaseUser user, String name) async {
    if (user != null) {
      Map<String, dynamic> userInfo = {
        "name": name,
        "emailORphone": user.email != null ? user.email : user.phoneNumber,
        "photoUrl": user.photoUrl,
        "providerId": user.providerId,
        'lastSeen': DateTime.now(),
      };

      databaseMethods.uploadUserInfo(userInfo);
      HelperFunction.saveLogin(true);
      HelperFunction.saveUName(user.displayName);
      HelperFunction.saveUEmail(user.email);
      HelperFunction.saveUPhone(user.email);
    }
  }

  Future<FirebaseUser> signInWithPhone(verifiId, smsCode) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verifiId,
      smsCode: smsCode,
    );
    final AuthResult authResult =
        await auth.signInWithCredential(credential).catchError((e) {
      print(e.toString());
    });
    FirebaseUser user = authResult.user;
    return user;
  }

  //  void updateUserData(FirebaseUser user) async {
  //   DocumentReference ref = _db.collection("users").document(user.uid);
  //   return ref.setData({
  //     'uid': user.uid,
  //     'email': user.email,
  //     'photoURL': user.photoUrl,
  //     'displayName': user.displayName,
  //     'lastSeen': DateTime.now(),
  //   }, merge: true);
  // }

  User _userFirebaseUser(FirebaseUser user) {
    return user != null ? User(userId: user.uid) : null;
  }

  Future signInWithEandP(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser firebaseUser = result.user;
      return _userFirebaseUser(firebaseUser);
    } catch (e) {
      print(e.code.toString());
      return e.code;
    }
  }

  Future<FirebaseUser> signUpwithEandP(String email, String password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser firebaseUser = result.user;

      return firebaseUser;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future resetPassword(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
