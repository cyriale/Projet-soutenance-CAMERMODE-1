
class UserService {
  // Simule la mise à jour dans Firestore
  Future<bool> updatePhysicalProfile({
    required String uid,
    required double taille,
    required double poids,
    required String morphologie,
    required List<String> preferences,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    print("Mise à jour du profil physique pour $uid");
    
    // Ici, on enverrait les données à Firebase :
    // await _firestore.collection('users').doc(uid).update({ ... });
    
    return true; 
  }
}
