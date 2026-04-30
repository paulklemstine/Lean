#!/usr/bin/env python3
"""Analyze Catalog .lean file distribution and detect duplicates."""
from pathlib import Path
from collections import defaultdict
import hashlib

catalog = Path("/home/raver1975/lean/Catalog")

# Count per top-level directory (excluding .lake)
dir_counts = defaultdict(int)
all_files = []
for f in catalog.rglob("*.lean"):
    if ".lake" in f.parts:
        continue
    rel = f.relative_to(catalog)
    top = rel.parts[0] if len(rel.parts) > 1 else "(root)"
    dir_counts[top] += 1
    all_files.append(f)

print("=== .lean files per top-level directory (excluding .lake) ===")
for d, c in sorted(dir_counts.items(), key=lambda x: -x[1]):
    print(f"  {c:5d}  {d}")
print(f"\n  TOTAL: {len(all_files)}")

# Check for duplicate filenames
print("\n=== Duplicate filenames ===")
name_map = defaultdict(list)
for f in all_files:
    name_map[f.name].append(str(f.relative_to(catalog)))

dupes = {k: v for k, v in name_map.items() if len(v) > 1}
print(f"  {len(dupes)} filenames appear more than once")
for name, paths in sorted(dupes.items(), key=lambda x: -len(x[1]))[:15]:
    print(f"\n  {name} ({len(paths)} copies):")
    for p in paths[:5]:
        print(f"    - {p}")
    if len(paths) > 5:
        print(f"    ... and {len(paths)-5} more")

# Check for content-identical duplicates
print("\n=== Content-identical duplicates ===")
hash_map = defaultdict(list)
for f in all_files:
    h = hashlib.md5(f.read_bytes()).hexdigest()
    hash_map[h].append(str(f.relative_to(catalog)))

content_dupes = {k: v for k, v in hash_map.items() if len(v) > 1}
total_wasted = sum(len(v) - 1 for v in content_dupes.values())
print(f"  {len(content_dupes)} unique contents appear in {total_wasted} extra copies")
for h, paths in sorted(content_dupes.items(), key=lambda x: -len(x[1]))[:10]:
    print(f"\n  [{len(paths)} copies]:")
    for p in paths[:4]:
        print(f"    - {p}")
    if len(paths) > 4:
        print(f"    ... and {len(paths)-4} more")
