#!/usr/bin/env bash

for s in raft0 raft1 raft2
do
  ssh -o "StrictHostKeyChecking no" ubuntu@${s} "cd ~/raft-bench && rm -rf wal-* && killall -9 raftbench && git pull && /usr/local/go/bin/go build" &
done

# exit when any command fails
set -e

for s in raft0 raft1 raft2
do
  ssh -o "StrictHostKeyChecking no" ubuntu@${s} "cd ~/raft-bench && /usr/local/go/bin/go build" &
done

sleep 5

ssh ubuntu@raft0 "cd ~/raft-bench && ./raftbench --engine dragonboat --cluster http://raft0:12379,http://raft1:22379,http://raft2:32379 --id 1 --mil 1000 --firstWait 5000 --step 1 --maxTries 2 --test --logfile dragonboat.csv" &
ssh ubuntu@raft1 "cd ~/raft-bench && ./raftbench --engine dragonboat --cluster http://raft0:12379,http://raft1:22379,http://raft2:32379 --id 2" &
ssh ubuntu@raft2 "cd ~/raft-bench && ./raftbench --engine dragonboat --cluster http://raft0:12379,http://raft1:22379,http://raft2:32379 --id 3"

