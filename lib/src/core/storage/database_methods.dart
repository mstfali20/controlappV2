import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future<void> updateUser(
      String userId, Map<String, dynamic> userInfoMap) async {
    try {
      // Kullanıcının belgesini al
      final userDocRef =
          FirebaseFirestore.instance.collection("User").doc(userId);
      final userDocSnapshot = await userDocRef.get();

      if (userDocSnapshot.exists) {
        // Belge mevcutsa güncelle
        await userDocRef.update(userInfoMap);
        print("Guncellendı.");
      } else {
        // Belge mevcut değilse belgeyi oluştur
        await userDocRef.set(userInfoMap);
        print("yenı kayıt");
      }
    } catch (e) {
      print("hata olustu baba: $e");
      rethrow; // Hata fırlat
    }
  }
}
