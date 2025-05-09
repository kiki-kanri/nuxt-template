#!/bin/bash

set -e

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
cd "$SCRIPT_DIR"

name='nuxt-project'

if ! tmux ls | grep -q "^$name:"; then
    tmux new-session -ds "$name"
    tmux send-keys -t "$name" 'pnpm run dev' C-m
fi
