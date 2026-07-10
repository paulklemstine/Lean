#!/usr/bin/env python3
"""Scan for broken package JSON files that have no 'title' field."""
import json, os

broken = []
for f in sorted(os.listdir(".")):
    if not f.endswith(".json"):
        continue
    if f in ("lineage.json", "future_directions.json"):
        continue
    try:
        with open(f) as fh:
            d = json.load(fh)
        if not d.get("title"):
            broken.append((f, list(d.keys())[:5]))
    except Exception as e:
        broken.append((f, [f"PARSE ERROR: {e}"]))

if broken:
    print(f"Found {len(broken)} broken package(s):")
    for name, keys in broken:
        print(f"  {name}  keys={keys}")
else:
    print("All packages look good!")
