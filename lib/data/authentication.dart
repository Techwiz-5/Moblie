import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> signUpUser({required String name, required String email, required String password, required String phone}) async{
    String res = 'Something went wrong';
    try{
      if(name.isNotEmpty || email.isNotEmpty || password.isNotEmpty || phone.isNotEmpty){
        UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'name': name,
          'email': email,
          'phone': phone,
          'role': 'user',
          'uid': credential.user!.uid,
        });
        res = 'Successfully';
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> loginUser({required String email, required String password}) async{
    String res = 'Something went wrong';
    try{
      if(email.isNotEmpty || password.isNotEmpty){
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        res = 'Successfully';
      }
      else {
        res = 'Please enter all the field';
      }
    } catch (e) {
      return e.toString();
    }
    return res;
  }

  Future<void> logout() async{
    await _auth.signOut();
  }
}