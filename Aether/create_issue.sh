#!/bin/bash
gh issue create \
  --title 'Injected Direction: Prove Fermats Little Theorem for p=5' \
  --body $'## Conjecture\nProve that for any integer a, a^5 - a is an integer multiple of 5.\n## Test\nN/A\n## Impact\nTests basic number theory capabilities.' \
  --label 'approved-direction'
