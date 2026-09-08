
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Récupérer tous les utilisateurs
  Stream<List<UserModel>> getAllUsers() {
    return _db.collection('users').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => UserModel.fromMap(doc.data(), doc.id)).toList());
  }

  // Bloquer ou débloquer un utilisateur
  Future<void> toggleBlockUser(String uid, bool block) async {
    await _db.collection('users').doc(uid).update({'isBlocked': block});
  }

  // Supprimer un utilisateur (Attention : cela ne supprime pas de Firebase Auth directement via le SDK client)
  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  // Récupérer les statistiques globales
  Future<Map<String, int>> getGlobalStats() async {
    final usersQuery = await _db.collection('users').get();
    final articlesQuery = await _db.collection('articles').get(); // Supposant qu'une collection articles existe
    
    int clients = 0;
    int prestataires = 0;
    
    for (var doc in usersQuery.docs) {
      if (doc.data()['role'] == 'client') clients++;
      if (doc.data()['role'] == 'prestataire') prestataires++;
    }

    return {
      'totalUsers': usersQuery.size,
      'totalClients': clients,
      'totalPrestataires': prestataires,
      'totalArticles': articlesQuery.size,
    };
  }

  // Envoyer une annonce (On crée une collection 'announcements')
  Future<void> sendAnnouncement(String title, String content) async {
    await _db.collection('announcements').add({
      'title': title,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
