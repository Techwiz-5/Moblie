import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseServices {
  final auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential authCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        UserCredential userCredential = await auth.signInWithCredential(authCredential);
        User? user = userCredential.user;

        if (user != null) {
          await saveUserToFirestore(user);
        }

        return user;
      }
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> googleSignOut() async {
    await googleSignIn.signOut();
    // await auth.signOut();
  }

  Future<void> saveUserToFirestore(User user) async {
    DocumentSnapshot documentSnapshot = await _firestore.collection('users').doc(user.uid).get();

    if(!documentSnapshot.exists){
      await _firestore.collection('users').doc(user.uid).set({
        'name': user.displayName,
        'email': user.email,
        'uid': user.uid,
        'role': 'user',
      });
    }
  }
}
