# Dockefile from https://notes.ethereum.org/@GW1ZUbNKR5iRjjKYx6_dJQ/Bk8zsJ9xj
# FROM node:20.15.0-bullseye-slim
FROM node@sha256:8f6881869150049f8f1228a2f828c3dc1d0a012f136175f02ae46a83c0a1002b

# install wget, git and necessary certificates so we can install IPFS below
RUN apt update && apt install --yes --no-install-recommends wget git apt-transport-https ca-certificates && rm -rf /var/lib/apt/lists/*

# install IPFS
WORKDIR /home/root
RUN wget -qO - https://dist.ipfs.tech/kubo/v0.29.0/kubo_v0.29.0_linux-amd64.tar.gz | tar -xvzf - \
	&& cd kubo \
	&& ./install.sh \
	&& cd .. \
	&& rm -rf kubo
RUN ipfs init

ENV GIT_REPOSITORY=https://codeberg.org/torndao/classic-ui.git
# From development branch, double check with tornado.ws
ENV GIT_COMMIT_HASH=69312b135cb28cd94122ed3b5218001cfd8dd127

# clone the repository
RUN mkdir /app/

WORKDIR /app

# Simple hack to fetch only commit and nothing more (no need to download 1GB sized repo, only 100MB would be enough)
RUN git init && \
  git remote add origin $GIT_REPOSITORY && \
  git fetch --depth 1 origin $GIT_COMMIT_HASH && \
  git checkout $GIT_COMMIT_HASH

# install, build and prep for deployment
RUN yarn install --frozen-lockfile --ignore-scripts
RUN yarn build:lts
RUN yarn generate:lts

# add the build output to IPFS and write the hash to a file
RUN ipfs add --cid-version 1 --quieter --only-hash --recursive ./dist > ipfs_hash.txt
# print the hash for good measure in case someone is looking at the build logs
RUN cat ipfs_hash.txt

# this entrypoint file will execute `ipfs add` of the build output to the docker host's IPFS API endpoint, so we can easily extract the IPFS build out of the docker image
RUN printf '#!/bin/sh\nipfs --api /ip4/`getent ahostsv4 host.docker.internal | grep STREAM | head -n 1 | cut -d \  -f 1`/tcp/5001 add --cid-version 1 -r ./dist' >> entrypoint.sh
RUN chmod u+x entrypoint.sh

ENTRYPOINT [ "./entrypoint.sh" ]