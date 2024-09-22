import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UserStatusService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _realtimeDb = FirebaseDatabase.instance;

  Future<void> updateUserStatus(String userId, bool isOnline) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      Map<String, dynamic> userRole = userDoc.data() as Map<String, dynamic>;

      String collectionName = userRole['role'] == 'driver' ? 'driver' : 'account';

      await _firestore.collection(collectionName).doc(userId).update({
        'online': isOnline,
        'last_seen': FieldValue.serverTimestamp(),
      });
    }
  }

  void monitorUserConnection() {
    User? user = _auth.currentUser;
    if (user != null) {
      // Tham chiếu đến trạng thái kết nối và trạng thái của người dùng trong Realtime Database
      DatabaseReference connectedRef = _realtimeDb.ref(".info/connected");
      DatabaseReference userStatusRef = _realtimeDb.ref('status/${user.uid}');

      // Kiểm tra xem node của người dùng đã tồn tại hay chưa
      userStatusRef.get().then((snapshot) {
        if (!snapshot.exists) {
          // Nếu không tồn tại, tạo node mới với trạng thái mặc định
          userStatusRef.set({
            'online': true,
            // Cập nhật thời gian hiện tại
            'last_seen': ServerValue.timestamp,
          }).then((_) {
            print("Node created for user: ${user.uid}");
          }).catchError((error) {
            print("Error creating node: $error");
          });
        }

        // Lắng nghe sự kiện kết nối của người dùng
        connectedRef.onValue.listen((event) {
          final bool isConnected = event.snapshot.value as bool;

          if (isConnected) {
            // Cập nhật trạng thái online khi người dùng kết nối
            userStatusRef.update({
              'online': true,
              'last_seen': ServerValue.timestamp,
            });

            // Thiết lập sự kiện onDisconnect để cập nhật offline khi ngắt kết nối
            userStatusRef.onDisconnect().update({
              'online': false,
              // Cập nhật thời gian ngắt kết nối
              'last_seen': ServerValue.timestamp,
            }).then((_) {
              print('onDisconnect event set for ${user.uid}');
            }).catchError((error) {
              print('Failed to set onDisconnect: $error');
            });

          } else {
            // Cập nhật trạng thái offline khi không có kết nối
            userStatusRef.update({
              'online': false,
              // Cập nhật thời gian ngắt kết nối
              'last_seen': ServerValue.timestamp,
            });
          }
        });
      }).catchError((error) {
        print("Failed to check or create user status: $error");
      });
    }
  }
}
