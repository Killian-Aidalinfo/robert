# Image de Robert : Hermes Agent officiel + outils de démo.
FROM nousresearch/hermes-agent:v0.22.2@sha256:36099926da316742423544e055d4734777105ffe6341873af5459b957d0c2919

# Garder l'utilisateur root : l'entrypoint s6 abaisse lui-même les privilèges.
USER root

# CLI Scaleway (scw) — binaire officiel, vérifié par son SHA256.
ARG SCW_VERSION=2.65.1
ARG SCW_SHA256=b9ced8bc52c27baba76136a24e65a5e0abd53e9499edf02226513977d45da503
RUN curl -fsSL -o /usr/local/bin/scw \
      "https://github.com/scaleway/scaleway-cli/releases/download/v${SCW_VERSION}/scaleway-cli_${SCW_VERSION}_linux_amd64" \
    && echo "${SCW_SHA256}  /usr/local/bin/scw" | sha256sum -c - \
    && chmod 0755 /usr/local/bin/scw

# CLI GitHub (gh) — archive officielle, vérifiée par son SHA256.
# Authentification par la variable GH_TOKEN du .env, utilisée par les skills github/* de Hermes.
ARG GH_VERSION=2.102.0
ARG GH_SHA256=bb766f710eef8ede859c18578c72c327597cd4c8a85b06001b1f3843c6019386
RUN curl -fsSL -o /tmp/gh.tar.gz \
      "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz" \
    && echo "${GH_SHA256}  /tmp/gh.tar.gz" | sha256sum -c - \
    && tar -xzf /tmp/gh.tar.gz -C /tmp \
    && install -m 0755 "/tmp/gh_${GH_VERSION}_linux_amd64/bin/gh" /usr/local/bin/gh \
    && rm -rf /tmp/gh.tar.gz "/tmp/gh_${GH_VERSION}_linux_amd64"

# tmux : requis par le skill claude-code pour piloter les sessions interactives.
RUN apt-get update \
    && apt-get install -y --no-install-recommends tmux \
    && rm -rf /var/lib/apt/lists/*

# Claude Code, version figée. La mise à jour se fait en changeant la version ici
# (l'auto-updater est coupé dans docker-compose.yml). Connexion conservée dans
# /opt/data/.claude, le HOME de l'utilisateur hermes.
ARG CLAUDE_CODE_VERSION=2.1.303
RUN npm install -g "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}" \
    && npm cache clean --force
