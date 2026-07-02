#!/bin/bash
cd ~/lean/Aether
tmux new-session -d -s aether_tick 'bash -c "/usr/bin/python3 aether_tick.py --loop --ollama-cloud --max-inflight 9 --novelty-slots 2 --interval 900 >> .aether_workspace/aether_daemon.log 2>&1"'
