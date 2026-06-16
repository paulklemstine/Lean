#!/bin/bash
set -e

cd Aether && python3 backfill_aristotle_archive.py --archive-root ../Archive --max-memory-mb 7774 --download-timeout 600 --log .aether_workspace/backfill_aristotle_archive.log
