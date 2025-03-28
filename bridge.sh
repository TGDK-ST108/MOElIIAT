#!/usr/bin/env sh

REMOTE_PAIR_HOST="your-pc-ip"
REMOTE_PAIR_PORT="55555"
PAIR_TARGET="10.252.5.102:42123"
PAIR_CODE="829108"

echo "[TGDK] Sending pairing request to $REMOTE_PAIR_HOST"

curl -X POST "http://$REMOTE_PAIR_HOST:$REMOTE_PAIR_PORT/pair" \
  -d "target=$PAIR_TARGET&code=$PAIR_CODE"