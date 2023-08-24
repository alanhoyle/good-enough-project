#! /usr/bin/env bash

git init
git add .
git commit -a -m "initial cookiecutter commit"

# cd bin

set -eu

# install micromamba
# based on https://raw.githubusercontent.com/mamba-org/micromamba-releases/main/install.sh
# from https://mamba.readthedocs.io/en/latest/micromamba-installation.html
# micromamba's install is "${SHELL}" <(curl -L micro.mamba.pm/install.sh)


# Fallbacks
BIN_FOLDER="bin"
PREFIXLOCATION="bin/micromamba"
# INIT_YES="no"
CONDA_FORGE_YES="no"

# Computing artifact location
ARCH="$(uname -m)"
OS="$(uname)"

if [[ "$OS" == "Linux" ]]; then
  PLATFORM="linux"
  if [[ "$ARCH" == "aarch64" ]]; then
    ARCH="aarch64"
  elif [[ $ARCH == "ppc64le" ]]; then
    ARCH="ppc64le"
  else
    ARCH="64"
  fi
elif [[ "$OS" == "Darwin" ]]; then
  PLATFORM="osx"
  if [[ "$ARCH" == "arm64" ]]; then
    ARCH="arm64"
  else
    ARCH="64"
  fi
elif [[ "$OS" =~ "NT" ]]; then
  PLATFORM="win"
  ARCH="64"
else
  echo "Failed to detect your OS" >&2
  exit 1
fi

if [[ "${VERSION:-}" == "" ]]; then
  RELEASE_URL="https://github.com/mamba-org/micromamba-releases/releases/latest/download/micromamba-${PLATFORM}-${ARCH}"
else
  RELEASE_URL="https://github.com/mamba-org/micromamba-releases/releases/download/micromamba-${VERSION}/micromamba-${PLATFORM}-${ARCH}"
fi


# Downloading artifact
mkdir -p "${BIN_FOLDER}"
curl "${RELEASE_URL}" -o "${BIN_FOLDER}/micromamba" -fsSL --compressed ${CURL_OPTS:-}
chmod +x "${BIN_FOLDER}/micromamba"

# Initializing conda-forge
if [[ "$CONDA_FORGE_YES" == "" || "$CONDA_FORGE_YES" == "y" || "$CONDA_FORGE_YES" == "Y" || "$CONDA_FORGE_YES" == "yes" ]]; then
  "${BIN_FOLDER}/micromamba" config append channels conda-forge
  "${BIN_FOLDER}/micromamba" config append channels bioconda
  "${BIN_FOLDER}/micromamba" config append channels nodefaults
  "${BIN_FOLDER}/micromamba" config set channel_priority strict
fi