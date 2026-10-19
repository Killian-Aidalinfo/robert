# Robert

Agent IA de démonstration pour les étudiants MAALSI du CESI Nancy. Robert est un [Hermes Agent](https://github.com/NousResearch/hermes-agent) branché sur Discord : il gère de l'infrastructure, du code et Claude Code en direct, toujours avec le sourire.

## Contenu

| Fichier | Rôle |
|---|---|
| `config/SOUL.md` | Personnalité de Robert, injectée en tête du prompt système |
| `config/config.example.yaml` | `config.yaml` de Hermes, secrets retirés |
| `docker-compose.yml` | Conteneur `robert` (image officielle Hermes, version figée) |
| `.env.example` | Variables secrètes attendues dans `data/.env` |

Les secrets (`data/.env`, `data/auth.json`, mot de passe du dashboard) ne sont jamais dans ce dépôt.

## Déploiement

Sur un serveur avec Docker :

```sh
git clone https://github.com/Killian-Aidalinfo/robert.git /srv/robert
cd /srv/robert
mkdir -p data
cp config/SOUL.md data/SOUL.md
cp config/config.example.yaml data/config.yaml
cp .env.example data/.env      # puis remplir les valeurs
docker compose run --rm robert setup   # connexion au fournisseur de modèle, mot de passe du dashboard
docker compose up -d
```

## Exploitation

```sh
docker compose logs -f robert                     # logs
docker exec -it robert hermes                     # chat en ligne de commande
cp config/SOUL.md data/SOUL.md                    # après une modif de la personnalité
```

Un changement de `SOUL.md` s'applique à la prochaine session (`/new` sur Discord), sans redémarrage.

Le dashboard écoute sur `127.0.0.1:9119` de l'hôte. Pour y accéder : `ssh -L 9119:localhost:9119 root@<serveur>` puis http://localhost:9119.
