import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:controlapp/const/data.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserController {
  static User? user = FirebaseAuth.instance.currentUser;

  static Future getUserData() async {
    if (user != null) {
      Map<String, dynamic>? userData;
      try {
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection("User")
            .doc(user!.uid)
            .get();
        if (userDoc.exists) {
          userData = userDoc.data();
          return userData;
        } else {
          return "";
        }
      } catch (e) {
        return "Error";
      }
    } else {
      Map<String, dynamic>? userData;
      try {
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection("User")
            .doc(fcmtokenstring)
            .get();
        if (userDoc.exists) {
          userData = userDoc.data();
          return userData;
        } else {
          return "";
        }
      } catch (e) {
        return "Error";
      }
    }
    // Firestore'dan kullanıcının tüm bilgilerini çek
  }
}
