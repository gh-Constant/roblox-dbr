#!/bin/sh

set -e

# If Packages aren't installed, install them.
if [ ! -d "Packages" ]; then
    sh scripts/install-packages.sh
fi

rojo sourcemap default.project.json -o sourcemap.json

ROBLOX_DEV=false darklua process --config .darklua.json src/ dist/

# Copy remote folders with meta.json files
mkdir -p dist/Common/Matchmaking/Remotes
cp -r src/Common/Matchmaking/Remotes/* dist/Common/Matchmaking/Remotes/

rojo build build.project.json -o RobloxProjectTemplate.rbxl
