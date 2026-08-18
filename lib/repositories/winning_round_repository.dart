import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luckez/models/lotto_winning_round.dart';

class WinningRoundRepository {
  WinningRoundRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<LottoWinningRound>> watchWinningRounds() {
    return _winningRoundsCollection().orderBy('round').snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => LottoWinningRound.fromMap(doc.id, doc.data()),
              )
              .toList(),
        );
  }

  Future<List<LottoWinningRound>> fetchWinningRounds() async {
    final snapshot = await _winningRoundsCollection().orderBy('round').get();

    return snapshot.docs
        .map(
          (doc) => LottoWinningRound.fromMap(doc.id, doc.data()),
        )
        .toList();
  }

  Future<void> saveWinningRound(LottoWinningRound winningRound) {
    return _winningRoundsCollection()
        .doc(winningRound.round.toString())
        .set(winningRound.toMap());
  }

  CollectionReference<Map<String, dynamic>> _winningRoundsCollection() {
    return _firestore.collection('lottoWinningRounds');
  }
}
