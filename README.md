# Tornado Cash IPFS Builder

IPFS hash generation script for Tornado UI

Works on any platform (Linux, Windows, MacOS) if the Docker Desktop is installed.

## TL;DR

Script based on https://notes.ethereum.org/@GW1ZUbNKR5iRjjKYx6_dJQ/Bk8zsJ9xj


## How to use

1. Build the docker image

```bash
docker build -t tornado-classic-ui .
```

2. Check the generated IPFS hash

```bash
docker container run --rm -it --entrypoint cat tornado-classic-ui /app/ipfs_hash.txt
```

## (Optional) Add built UI to IPFS Desktop

First, install the latest IPFS Desktop.

Then, build the docker image and run the following command

```bash
docker container run --rm tornado-classic-ui
```

You can now access the UI on your local IPFS gateway through the following

http://localhost:8080/ipfs/content_hash_here