import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // Écouter les changements de connexion ET de profil en temps réel
  Stream<UserModel?> get onAuthStateChanged {
    return _auth.authStateChanges().switchMap((user) {
      if (user == null) return Stream.value(null);
      
      // On écoute le document Firestore en temps réel
      return _db.collection('users').doc(user.uid).snapshots().asyncMap((doc) async {
        if (doc.exists) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }
        
        // Si le document n'existe pas encore (ex: inscription en cours ou admin)
        if (user.email == 'cyrialesahamene@gmail.com') {
          await _createAdminRecord(user.uid, user.email!);
          final adminDoc = await _db.collection('users').doc(user.uid).get();
          return UserModel.fromMap(adminDoc.data() as Map<String, dynamic>, adminDoc.id);
        }
        
        return null;
      });
    });
  }

  Future<void> _createAdminRecord(String uid, String email) async {
    try {
      UserModel admin = UserModel(
        uid: uid,
        email: email,
        nom: "Admin",
        prenom: "Principal",
        role: UserRole.admin,
        createdAt: DateTime.now(),
      );
      await _db.collection('users').doc(uid).set(admin.toMap());
    } catch (e) {
      debugPrint("Erreur création admin : $e");
    }
  }

  // Inscription
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
      final cleanEmail = email.trim().toLowerCase();
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        UserModel newUser = UserModel(
          uid: user.uid,
          email: cleanEmail,
          nom: nom,
          prenom: prenom,
          role: role,
          createdAt: DateTime.now(),
          photoUrl: photoUrl,
          verificationStatus: role == UserRole.prestataire ? VerificationStatus.enAttente : null,
        );

        Map<String, dynamic> userData = newUser.toMap();
        if (role == UserRole.prestataire) {
          userData['businessName'] = businessName;
          userData['businessType'] = businessType;
        }

        await _db.collection('users').doc(user.uid).set(userData);
        return null;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return "Cet email est déjà utilisé.";
      if (e.code == 'weak-password') return "Le mot de passe est trop faible.";
      if (e.code == 'invalid-email') return "Format d'email invalide. Vérifiez l'adresse saisie.";
      return e.message;
    } catch (e) {
      return e.toString();
    }
    return "Erreur inconnue";
  }

  // Connexion
  Future<String?> signIn(String email, String password) async {
    try {
      final cleanEmail = email.trim().toLowerCase();
      debugPrint("🔑 Tentative de connexion pour : $cleanEmail");
      
      if (cleanEmail.isEmpty) {
        return "Veuillez saisir votre adresse e-mail.";
      }

      // Traitement automatique des comptes de démo / test
      final isDemoAccount = cleanEmail == 'cyrialesahamene@gmail.com' ||
          cleanEmail == 'prestataire@camermode.cm' ||
          cleanEmail == 'client@camermode.cm';

      try {
        if (kIsWeb) {
          try {
            await _auth.setPersistence(Persistence.LOCAL);
          } catch (_) {}
        }
        await _auth.signInWithEmailAndPassword(email: cleanEmail, password: password);
        return null;
      } on FirebaseAuthException catch (e) {
        // Auto-création sécurisée pour les comptes de test si pas encore enregistrés
        if (isDemoAccount && (e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'invalid-email')) {
          final role = cleanEmail.contains('admin') || cleanEmail.contains('cyriale')
              ? UserRole.admin
              : (cleanEmail.contains('prestataire') ? UserRole.prestataire : UserRole.client);

          await signUp(
            email: cleanEmail,
            password: password,
            nom: role == UserRole.admin ? "Admin" : (role == UserRole.prestataire ? "Atelier" : "Client"),
            prenom: role == UserRole.admin ? "CamerMode" : "CamerMode",
            role: role,
            businessName: role == UserRole.prestataire ? "Atelier Mode Africaine" : null,
            businessType: role == UserRole.prestataire ? "Couture & Coiffure" : null,
          );
          return null;
        }
        rethrow;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ Erreur Auth: ${e.code}");
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') return "Identifiants incorrects.";
      if (e.code == 'wrong-password') return "Mot de passe incorrect.";
      if (e.code == 'invalid-email') return "Format d'email invalide. Exemple valide: utilisateur@domaine.com";
      if (e.code == 'network-request-failed') return "Erreur réseau. Vérifiez votre connexion internet.";
      return e.message ?? "Erreur de connexion.";
    } catch (e) {
      return "Une erreur inattendue est survenue.";
    }
  }

  // Réinitialisation de mot de passe (Mot de passe oublié)
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      final cleanEmail = email.trim().toLowerCase();
      if (cleanEmail.isEmpty || !cleanEmail.contains('@') || !cleanEmail.contains('.')) {
        return "Veuillez entrer une adresse email valide (ex: nom@domaine.com).";
      }
      await _auth.sendPasswordResetEmail(email: cleanEmail);
      return null; // Succès
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ Erreur Reset Password: ${e.code}");
      if (e.code == 'user-not-found') return "Aucun compte associé à cette adresse e-mail.";
      if (e.code == 'invalid-email') return "Adresse e-mail invalide.";
      return e.message ?? "Impossible d'envoyer l'e-mail de réinitialisation.";
    } catch (e) {
      return "Erreur lors de l'envoi de l'e-mail.";
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Mettre à jour le profil avec merge sécurisé
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }
}
