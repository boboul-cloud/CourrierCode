<p align="center">
  <img src="image_1.png" alt="CourrierCode Logo" width="120" height="120">
</p>

<h1 align="center">CourrierCode</h1>

<p align="center">
  <strong>Encodez vos messages secrets en séquences numériques</strong>
</p>

<p align="center">
  <a href="https://apps.apple.com/app/courriercode">
    <img src="https://img.shields.io/badge/App_Store-0D96F6?style=for-the-badge&logo=app-store&logoColor=white" alt="App Store">
  </a>
  <img src="https://img.shields.io/badge/iOS-17.0+-000000?style=for-the-badge&logo=ios&logoColor=white" alt="iOS 17+">
  <img src="https://img.shields.io/badge/Swift-5.9-FA7343?style=for-the-badge&logo=swift&logoColor=white" alt="Swift">
  <img src="https://img.shields.io/badge/SwiftUI-blue?style=for-the-badge&logo=swift&logoColor=white" alt="SwiftUI">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License MIT">
</p>

---

## 📱 À propos

**CourrierCode** est une application iOS qui transforme vos messages en codes numériques impossibles à déchiffrer sans connaître les règles secrètes. Parfaite pour les jeux de piste, chasses au trésor, ou simplement pour échanger des messages secrets avec vos proches !

<p align="center">
  <img src="Photos%20couriercodé/screenshot1.png" width="200" alt="Screenshot 1">
  <img src="Photos%20couriercodé/screenshot2.png" width="200" alt="Screenshot 2">
  <img src="Photos%20couriercodé/screenshot3.png" width="200" alt="Screenshot 3">
</p>

---

## ✨ Fonctionnalités

| Fonctionnalité | Description |
|----------------|-------------|
| 🔐 **Encodage** | Transformez n'importe quel texte en séquence de chiffres |
| 🔍 **Décodage** | Décryptez automatiquement les messages codés |
| �️ **Encodage d'images** | Transformez vos images en fichiers JSON codés |
| 📅 **Décalage quotidien** | Chaque jour utilise un décalage différent |
| 🔑 **Code secret** | Ajoutez une couche de sécurité supplémentaire |
| 🎲 **Table aléatoire** | Générez une table de correspondance personnalisée |
| 🔄 **Message inversé** | Option pour inverser le message final |
| 🌙 **Mode sombre** | Interface adaptée à vos préférences |
| 📖 **Documentation** | Guide intégré avec images zoomables |

---

## 🎯 Cas d'utilisation

- 🏴‍☠️ Jeux de piste et chasses au trésor
- 💬 Messages secrets entre amis
- 👨‍👩‍👧‍👦 Activités ludiques en famille
- 🚪 Défis d'escape game
- 🤫 Communication discrète

---

## 🛠 Installation pour les développeurs

### Prérequis

- macOS 14.0+
- Xcode 15.0+
- iOS 17.0+ (pour le déploiement)

### Cloner le projet

```bash
git clone https://github.com/boboul-cloud/CourrierCode.git
cd CourrierCode
```

### Ouvrir dans Xcode

```bash
open CourrierCode.xcodeproj
```

### Structure du projet

```
CourrierCode/
├── CourrierCode-iOS/
│   ├── ContentView.swift          # Vue principale
│   ├── CourrierCodeApp.swift      # Point d'entrée
│   ├── Components/                # Composants réutilisables
│   ├── Models/                    # Logique métier
│   │   ├── CourrierCodeur.swift   # Algorithme d'encodage
│   │   ├── Dictionnaire.swift     # Dictionnaire français
│   │   └── TableAleatoire.swift   # Génération de tables
│   ├── Theme/                     # Thème de l'application
│   └── Views/                     # Vues de l'application
├── Website/                       # Site web de support
└── AppStore/                      # Assets App Store
```

---

## 🔒 Comment ça marche ?

1. **Encodage** : Chaque lettre est convertie en nombre selon une table de correspondance
2. **Décalage** : Un décalage est appliqué selon le jour de la semaine
3. **Code secret** : Un code optionnel modifie la séquence finale
4. **Résultat** : Une séquence de chiffres séparés par des tirets

Exemple : `Bonjour` → `12-45-67-23-89-34-56`

---

## 🌐 Liens

- 📱 [App Store](https://apps.apple.com/app/courriercode)
- 🌍 [Site Web](https://boboul-cloud.github.io/CourrierCode)
- 📧 [Support](mailto:votre.email@example.com)
- 🔐 [Politique de confidentialité](Website/privacy.html)

---

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push sur la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

---

## 👨‍💻 Auteur

Développé avec ❤️ par **Robert Oulhen**

---

<p align="center">
  <sub>⭐ Si vous aimez ce projet, n'hésitez pas à lui donner une étoile !</sub>
</p>
