import 'package:cloud_firestore/cloud_firestore.dart';

Future<int> getLastID(
    {required String collectionName, required String primaryKey}) async {
  try {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    QuerySnapshot<Map<String, dynamic>> snapshot = await firebaseFirestore
        .collection(collectionName)
        .orderBy(primaryKey, descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      String? idString = snapshot.docs.first[primaryKey] as String?;
      if (idString != null && int.tryParse(idString) != null) {
        return int.parse(idString);
      }
    }
    return 0;
  } catch (e) {
    throw ('Error getting $primaryKey : $e');
  }
}
