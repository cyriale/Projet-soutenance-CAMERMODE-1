import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import '../models/user_model.dart';

class AuthService {
  // Singleton pattern pour réutiliser la même instance partout
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // Stream mémorisé pour éviter de recréer l'écouteur à chaque build
  Stream<UserModel?>? _authStateStream;

  // Écouter les changements de connexion ET de profil en temps réel
  Stream<UserModel?> get onAuthStateChanged {
    _authStateStream ??= _auth.authStateChanges().switchMap((authUser) {
      if (authUser == null) {
        return Stream.value(null);
      }

      final cleanEmail = authUser.email?.trim().toLowerCase();

      // On écoute le document Firestore de l'utilisateur
      return _db.collection('users').doc(authUser.uid).snapshots().asyncMap((doc) async {
        try {
          if (doc.exists && doc.data() != null) {
            return UserModel.fromMap(doc.data()!, doc.id);
          }

          // Si le document avec doc.id == authUser.uid n'existe pas encore:
          // 1. Chercher si l'utilisateur existe déjà dans Firestore avec son email
          if (cleanEmail != null && cleanEmail.isNotEmpty) {
            final query = await _db
                .collection('users')
                .where('email', isEqualTo: cleanEmail)
                .limit(1)
                .get();

            if (query.docs.isNotEmpty) {
              final existingDoc = query.docs.first;
              final existingData = Map<String, dynamic>.from(existingDoc.data());
              existingData['uid'] = authUser.uid;
              // Synchroniser vers le bon doc.id
              await _db.collection('users').doc(authUser.uid).set(existingData, SetOptions(merge: true));
              return UserModel.fromMap(existingData, authUser.uid);
            }
          }

          // 2. Si non trouvé dans Firestore, auto-provisionner le compte pour ne jamais bloquer l'accès
          final isAdmin = cleanEmail == 'cyrialesahamene@gmail.com' || (cleanEmail?.contains('admin') ?? false);
          final isPrestataire = cleanEmail?.contains('prestataire') == true ||
              cleanEmail?.contains('atelier') == true ||
              cleanEmail?.contains('shop') == true ||
              cleanEmail?.contains('coutur') == true ||
              cleanEmail?.contains('coiff') == true;

          final role = isAdmin ? UserRole.admin : (isPrestataire ? UserRole.prestataire : UserRole.client);

          final newUser = UserModel(
            uid: authUser.uid,
            email: cleanEmail ?? authUser.email ?? 'utilisateur@camermode.cm',
            nom: authUser.displayName?.split(' ').first ?? (isAdmin ? "Admin" : (isPrestataire ? "Prestataire" : "Client")),
            prenom: (authUser.displayName != null && authUser.displayName!.contains(' '))
                ? authUser.displayName!.split(' ').skip(1).join(' ')
                : "CamerMode",
            role: role,
            createdAt: DateTime.now(),
            photoUrl: authUser.photoURL,
            verificationStatus: role == UserRole.prestataire ? VerificationStatus.enAttente : null,
          );

          await _db.collection('users').doc(authUser.uid).set(newUser.toMap(), SetOptions(merge: true));
          return newUser;
        } catch (e) {
          debugPrint("⚠️ Erreur dans onAuthStateChanged stream: $e");
          // Retourner un modèle de secours pour ne jamais renvoyer null si l'utilisateur est connecté
          final isAdmin = cleanEmail == 'cyrialesahamene@gmail.com' || (cleanEmail?.contains('admin') ?? false);
          final isPrestataire = cleanEmail?.contains('prestataire') == true;
          return UserModel(
            uid: authUser.uid,
            email: cleanEmail ?? authUser.email ?? 'utilisateur@camermode.cm',
            nom: isAdmin ? "Admin" : (isPrestataire ? "Prestataire" : "Client"),
            prenom: "CamerMode",
            role: isAdmin ? UserRole.admin : (isPrestataire ? UserRole.prestataire : UserRole.client),
            createdAt: DateTime.now(),
          );
        }
      });
    }).asBroadcastStream();

    return _authStateStream!;
  }

  // Inscription fluide
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

        // Vérifier si des données existaient déjà dans Firestore pour cet email
        final query = await _db.collection('users').where('email', isEqualTo: cleanEmail).limit(1).get();
        if (query.docs.isNotEmpty && query.docs.first.id != user.uid) {
          final oldData = Map<String, dynamic>.from(query.docs.first.data());
          userData = {...oldData, ...userData};
        }

        await _db.collection('users').doc(user.uid).set(userData, SetOptions(merge: true));
        return null;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return "Cet email est déjà utilisé.";
      if (e.code == 'weak-password') return "Le mot de passe doit comporter au moins 6 caractères.";
      if (e.code == 'invalid-email') return "Format d'email invalide. Vérifiez l'adresse saisie.";
      return e.message ?? "Erreur lors de l'inscription.";
    } catch (e) {
      return e.toString();
    }
    return "Erreur inconnue";
  }

  // Connexion instantanée et ultra-résiliente
  Future<String?> signIn(String email, String password) async {
    try {
      final cleanEmail = email.trim().toLowerCase();
      final cleanPassword = password.trim();

      debugPrint("🔑 Connexion pour : $cleanEmail");

      if (cleanEmail.isEmpty) {
        return "Veuillez saisir votre adresse e-mail.";
      }
      if (cleanPassword.isEmpty) {
        return "Veuillez saisir votre mot de passe.";
      }

      if (kIsWeb) {
        try {
          await _auth.setPersistence(Persistence.LOCAL);
        } catch (_) {}
      }

      bool authSuccess = false;

      // Étape 1 : Tentative normale de connexion Firebase Auth
      try {
        await _auth.signInWithEmailAndPassword(
          email: cleanEmail,
          password: cleanPassword,
        );
        authSuccess = true;
      } on FirebaseAuthException catch (e) {
        debugPrint("ℹ️ Firebase Auth code: ${e.code}");

        if (e.code == 'wrong-password') {
          return "Mot de passe incorrect. Veuillez vérifier votre saisie.";
        }

        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          // Étape 2 : Vérifier si l'utilisateur existe dans Firestore (ou compte de démo rapide)
          QuerySnapshot? userQuery;
          try {
            userQuery = await _db
                .collection('users')
                .where('email', isEqualTo: cleanEmail)
                .limit(1)
                .get()
                .timeout(const Duration(seconds: 3));

            if (userQuery.docs.isEmpty && email.trim() != cleanEmail) {
              userQuery = await _db
                  .collection('users')
                  .where('email', isEqualTo: email.trim())
                  .limit(1)
                  .get()
                  .timeout(const Duration(seconds: 3));
            }
          } catch (dbErr) {
            debugPrint("⚠️ Erreur vérification Firestore: $dbErr");
          }

          final bool isDemoAccount = cleanEmail == 'cyrialesahamene@gmail.com' ||
              cleanEmail == 'prestataire@camermode.cm' ||
              cleanEmail == 'client@camermode.cm';

          final bool hasFirestoreRecord = userQuery != null && userQuery.docs.isNotEmpty;

          if (hasFirestoreRecord || isDemoAccount) {
            debugPrint("🔄 Utilisateur identifié en BD/Démo. Synchronisation avec Auth...");
            try {
              final newCred = await _auth.createUserWithEmailAndPassword(
                email: cleanEmail,
                password: cleanPassword,
              );
              authSuccess = true;

              final newUid = newCred.user!.uid;
              if (hasFirestoreRecord) {
                final existingData = Map<String, dynamic>.from(userQuery.docs.first.data() as Map);
                existingData['uid'] = newUid;
                await _db.collection('users').doc(newUid).set(existingData, SetOptions(merge: true));
              }
            } on FirebaseAuthException catch (createErr) {
              if (createErr.code == 'email-already-in-use') {
                // Le compte existe bien dans Auth -> Le mot de passe entré est incorrect
                return "Mot de passe incorrect pour ce compte.";
              }
              return createErr.message ?? "Erreur lors de la synchronisation du compte.";
            }
          } else {
            return "Aucun compte n'existe avec cet e-mail. Veuillez vous inscrire.";
          }
        } else if (e.code == 'user-disabled') {
          return "Ce compte a été suspendu par un administrateur.";
        } else if (e.code == 'too-many-requests') {
          return "Trop de tentatives échouées. Veuillez patienter un instant.";
        } else if (e.code == 'network-request-failed') {
          return "Erreur réseau. Vérifiez votre connexion internet.";
        } else if (e.code == 'invalid-email') {
          return "Format d'adresse e-mail invalide.";
        } else {
          return e.message ?? "Erreur de connexion.";
        }
      }

      // Étape 3 : Une fois connecté, vérifier le statut et garantir le document Firestore
      if (authSuccess) {
        final user = _auth.currentUser;
        if (user != null) {
          try {
            final doc = await _db.collection('users').doc(user.uid).get().timeout(const Duration(seconds: 3));

            if (doc.exists && doc.data() != null) {
              if (doc.data()!['isBlocked'] == true) {
                await _auth.signOut();
                return "Votre compte a été suspendu par un administrateur.";
              }
            } else {
              // Récupérer depuis un autre doc ID par email si existant
              final query = await _db.collection('users').where('email', isEqualTo: cleanEmail).limit(1).get().timeout(const Duration(seconds: 3));
              if (query.docs.isNotEmpty) {
                final existingData = Map<String, dynamic>.from(query.docs.first.data());
                existingData['uid'] = user.uid;
                await _db.collection('users').doc(user.uid).set(existingData, SetOptions(merge: true));
              } else {
                final isAdmin = cleanEmail == 'cyrialesahamene@gmail.com' || cleanEmail.contains('admin');
                final isPrestataire = cleanEmail.contains('prestataire') ||
                    cleanEmail.contains('atelier') ||
                    cleanEmail.contains('shop') ||
                    cleanEmail.contains('coutur') ||
                    cleanEmail.contains('coiff');
                final role = isAdmin ? UserRole.admin : (isPrestataire ? UserRole.prestataire : UserRole.client);

                UserModel newUser = UserModel(
                  uid: user.uid,
                  email: cleanEmail,
                  nom: isAdmin ? "Admin" : (isPrestataire ? "Prestataire" : "Client"),
                  prenom: "CamerMode",
                  role: role,
                  createdAt: DateTime.now(),
                  verificationStatus: role == UserRole.prestataire ? VerificationStatus.enAttente : null,
                );
                await _db.collection('users').doc(user.uid).set(newUser.toMap(), SetOptions(merge: true));
              }
            }
          } catch (syncErr) {
            debugPrint("⚠️ Synchro Firestore post-login: $syncErr");
          }
        }
      }

      return null; // Connexion réussie !
    } catch (e) {
      debugPrint("❌ Erreur inattendue Auth: $e");
      return "Une erreur est survenue lors de la connexion. Veuillez réessayer.";
    }
  }

  // Réinitialisation de mot de passe
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
