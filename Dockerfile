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
