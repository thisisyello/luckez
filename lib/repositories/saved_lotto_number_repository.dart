import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:randomlottonumber/models/saved_lotto_number.dart';

class SavedLottoNumberRepository {
  SavedLottoNumberRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<SavedLottoNumber>> watchSavedNumbers(String userId) {
    return _savedNumbersCollection(userId).orderBy('createdAt').snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => SavedLottoNumber.fromMap(doc.id, doc.data()),
              )
              .toList(),
        );
  }

  Future<void> save(String userId, SavedLottoNumber savedNumber) {
    return _savedNumbersCollection(userId)
        .doc(savedNumber.id)
        .set(savedNumber.toMap());
  }

  Future<void> update(String userId, SavedLottoNumber savedNumber) {
    return _savedNumbersCollection(userId)
        .doc(savedNumber.id)
        .update(savedNumber.toMap());
  }

  Future<void> delete(String userId, String savedNumberId) {
    return _savedNumbersCollection(userId).doc(savedNumberId).delete();
  }

  CollectionReference<Map<String, dynamic>> _savedNumbersCollection(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('savedNumbers');
  }
}
