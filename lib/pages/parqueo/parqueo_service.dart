import 'package:cloud_firestore/cloud_firestore.dart';
import '../parqueo/parqueo.dart';

class ParqueoService {
  final _db = FirebaseFirestore.instance;

  Future<List<Parqueo>> getParqueos() async {
    final snapshot = await _db.collection('parqueos').get();

    //check if gets parkings info
    print('Documentos encontrados: ${snapshot.docs.length}');
    return snapshot.docs.map((doc) {
      return Parqueo.fromMap(doc.id, doc.data());
    }).toList();
  }
}
