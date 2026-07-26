import os
from pathlib import Path

catalog_dir = Path("/home/raver1975/lean/Catalog")

applied_dir = catalog_dir / "Applied"
ext_map = {}
for root, dirs, files in os.walk(applied_dir):
    for f in files:
        ext = Path(f).suffix if Path(f).suffix else "(no ext)"
        ext_map[ext] = ext_map.get(ext, 0) + 1

print("Applied folder file extensions:")
for ext, count in sorted(ext_map.items(), key=lambda x: x[1], reverse=True):
    print(f"  {ext}: {count}")

print("\nSample files in Applied:")
sample = []
for root, dirs, files in os.walk(applied_dir):
    for f in files:
        sample.append(str(Path(root).relative_to(catalog_dir) / f))
        if len(sample) >= 20:
            break
    if len(sample) >= 20:
        break

for s in sample:
    print(f"  {s}")

