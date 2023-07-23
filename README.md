# AI Investic - Client

Ce projet est un client web développé avec SvelteKit, Vite.js et PNPM
sous Docker, et est conçu pour afficher des biens immobiliers et fonciers
provenant d'une API interne. Le client web utilise une carte interactive
pour présenter les informations de manière conviviale.

## Configuration requise
- Build-essential - Pour utiliser les commandes Make
- Docker (version 24) - Pour lancer les conteneurs et avoir docker compose

## Installation

1. Clonez ce dépôt de code source :
   ```bash
   git clone git@github.com:ai-investic/client.git
   ```

2. Accédez au répertoire du projet :
   ```bash
   cd client
   ```

## Configuration de l'API

Pour que le client web puisse récupérer les données immobilières et foncières
depuis l'API interne, vous devez démarrer l'API Investic. Voir le repository 
https://github.com/ai-investic/api.

Assurez-vous que l'API est accessible et fournit les données attendues.

## Lancement du serveur de développement

1. Lancez le serveur de développement local à l'aide de la commande suivante :
   ```bash
   make sr up logs
   ```

   Cela démarrera le serveur de développement et vous donnera une URL locale
   à laquelle vous pouvez accéder pour visualiser le client web.

2. Ouvrez votre navigateur et accédez à l'URL suivante :
   ```
   http://localhost:5000
   ```

   Vous devriez maintenant voir le client web en action, affichant les biens
   immobiliers et fonciers sur une carte interactive.

---

Nous espérons que ce guide vous a aidé à démarrer avec le projet de client web
interactif pour la visualisation des biens immobiliers et fonciers. Si vous
avez des questions supplémentaires, n'hésitez pas à les poser.