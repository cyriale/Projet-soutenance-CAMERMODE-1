
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // Transformer un User Firebase en notre UserModel
  Future<UserModel?> _userFromFirebase(User? user) async {
    if (user == null) return null;
    
    DocumentSnapshot doc = await _db.collection('users').doc(user.uid).get();
    
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, user.uid);
    }
    return null;
  }

  // Écouter les changements de connexion
  Stream<UserModel?> get onAuthStateChanged {
    return _auth.authStateChanges().asyncMap(_userFromFirebase);
  }

  // Inscription avec gestion d'erreur précise
  Future<String?> signUp({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required UserRole role,
    String? businessName,
    String? businessType,
    String? photoUrl,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          nom: nom,
          prenom: prenom,
          role: role,
          createdAt: DateTime.now(),
          photoUrl: photoUrl,
        );

        Map<String, dynamic> userData = newUser.toMap();
        if (role == UserRole.prestataire) {
          userData['businessName'] = businessName;
          userData['businessType'] = businessType;
        }

        await _db.collection('users').doc(user.uid).set(userData);
        return null; // Pas d'erreur
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return "Cet email est déjà utilisé.";
      if (e.code == 'weak-password') return "Le mot de passe est trop faible.";
      if (e.code == 'invalid-email') return "L'adresse email n'est pas valide.";
      return "Erreur : ${e.message}";
    } catch (e) {
      return "Une erreur inconnue est survenue.";
    }
    return "Erreur lors de la création du compte.";
  }

  // Connexion
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return "Aucun utilisateur trouvé pour cet email.";
      if (e.code == 'wrong-password') return "Mot de passe incorrect.";
      return e.message;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Mettre à jour le profil
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }
}
