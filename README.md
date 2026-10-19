# Robert

Agent IA de démonstration pour les étudiants MAALSI du CESI Nancy. Robert est un [Hermes Agent](https://github.com/NousResearch/hermes-agent) branché sur Discord : il gère de l'infrastructure, du code et Claude Code en direct, toujours avec le sourire.

## Contenu

| Fichier | Rôle |
|---|---|
| `config/SOUL.md` | Personnalité de Robert, injectée en tête du prompt système |
| `config/config.example.yaml` | `config.yaml` de Hermes, secrets retirés |
| `config/hindsight.example.json` | Branchement de Robert sur Hindsight, à copier dans `data/hindsight/config.json` |
| `config/hindsight.env.example` | Clés de Hindsight, à copier dans `hindsight/.env` |
| `docker-compose.yml` | Conteneurs `robert` (Hermes) et `robert-hindsight` (mémoire), versions figées |
| `.env.example` | Variables secrètes attendues dans `data/.env` |

Les secrets (`data/.env`, `data/auth.json`, `hindsight/`, mot de passe du dashboard) ne sont jamais dans ce dépôt.

## Mémoire (Hindsight)

Robert retient les faits de ses conversations dans [Hindsight](https://hindsight.vectorize.io), auto-hébergé dans le conteneur `robert-hindsight` (banque `robert`). Hindsight extrait les faits avec `gpt-5.6-luna` via l'abonnement ChatGPT, sur une connexion Codex dédiée stockée dans `hindsight/codex/`, distincte de celle de Robert pour qu'ils ne se déconnectent pas mutuellement.

Mise en place, après le déploiement de Robert :

```sh
mkdir -p hindsight/codex && chown 1000:1000 hindsight/codex
cp config/hindsight.env.example hindsight/.env    # puis remplir les clés
docker run --rm -it --user 1000:1000 -e HOME=/tmp -e CODEX_HOME=/codex \
  -v "$PWD/hindsight/codex:/codex" node:22 npx -y @openai/codex login --device-auth
mkdir -p data/hindsight && cp config/hindsight.example.json data/hindsight/config.json   # y mettre la clé API
chown -R 10000:10000 data/hindsight
docker compose up -d
docker exec robert hermes config set memory.provider hindsight
docker exec robert hermes plugins install hindsight --yes-deps
docker compose restart robert
```

L'interface web (le « cerveau » de Robert) écoute sur `127.0.0.1:9999` : `ssh -L 9999:localhost:9999 root@<serveur>` puis http://localhost:9999, avec le mot de passe `HINDSIGHT_CP_ACCESS_KEY`.

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
