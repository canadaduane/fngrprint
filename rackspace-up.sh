#!/bin/bash


N=${1:-10}
IMAGE=23cebbc9-3219-4a27-9210-d63e1af7181b
FLAVOR=4

(
  echo "Starting $N servers..."
  seq -f '%02g' 1 $N \
  | parallel --env PATH -j0 --delay 0.25 \
      ../rumm/bin/rumm create server \
           --name=research{} \
           --image_id=$IMAGE \
           --flavor_id=$FLAVOR \
) && (
  rm -f inventory.ini

  echo "[crunch]" \
  >inventory.ini

  rumm show servers \
  | fgrep ACTIVE \
  | awk '{ print $8, 'server_idx=' NR-1 }' \
  >> inventory.ini
)