# Amélioration de l'Authentification, Dashboard Prestataire et IA

Ce plan vise à résoudre les problèmes d'accès au dashboard prestataire, la lenteur du système, et à s'assurer que toutes les fonctionnalités IA et de sécurité (permissions caméra) sont optimales.

## User Review Required

> [!IMPORTANT]
> Le flux de vérification des prestataires sera modifié pour permettre la resoumission de documents en cas de demande de correction par l'administrateur.
> Les permissions caméra seront demandées explicitement avant l'utilisation de l'IA ou de l'appareil photo.

## Proposed Changes

### [Core & Services]

#### [MODIFY] [auth_service.dart](file:///C:/Users/Mercy/StudioProjects/camermode/lib/services/auth_service.dart)
- Optimisation du flux d'authentification pour éviter des écritures redondantes en base.
- Utilisation de la persistance Firestore améliorée.

#### [MODIFY] [location_service.dart](file:///C:/Users/Mercy/StudioProjects/camermode/lib/services/location_service.dart)
- Intégration de `permission_handler` pour une gestion robuste des autorisations GPS.

#### [NEW] [permission_service.dart](file:///C:/Users/Mercy/StudioProjects/camermode/lib/services/permission_service.dart)
- Service centralisé pour gérer les permissions (Caméra, Galerie, Localisation, Notifications).

### [Screens & UI]

#### [MODIFY] [prestataire_registration_stepper.dart](file:///C:/Users/Mercy/StudioProjects/camermode/lib/screens/auth/prestataire_registration_stepper.dart)
- Mise à jour pour supporter le mode "Correction de dossier".
- Pré-remplissage des champs avec les données existantes.
- Demande explicite des permissions caméra avant le scan/photo.

#### [MODIFY] [bottom_navigation_bar.dart](file:///C:/Users/Mercy/StudioProjects/camermode/lib/screens/prestataire/bottom_navigation_bar.dart)
- Activation du bouton "CORRIGER MON DOSSIER" vers le stepper.

#### [MODIFY] [auth_wrapper.dart](file:///C:/Users/Mercy/StudioProjects/camermode/lib/screens/auth_wrapper.dart)
- Amélioration de la fluidité des transitions entre les rôles.

### [AI & Features]

#### [MODIFY] [measurement_service.dart](file:///C:/Users/Mercy/StudioProjects/camermode/lib/services/measurement_service.dart)
- Vérification de l'intégration des modèles ML Kit pour la reconnaissance (Pose/Face).

## Verification Plan

### Automated Tests
- `flutter test` pour vérifier les services de recommandation.
- Simulation de changement de statut admin pour vérifier la redirection prestataire.

### Manual Verification
1. Se connecter en tant que prestataire.
2. Vérifier que la position GPS est demandée correctement.
3. Vérifier que l'admin peut rejeter avec motif et que le prestataire peut corriger.
4. Tester la fluidité du switch entre dashboard Client et Prestataire.
