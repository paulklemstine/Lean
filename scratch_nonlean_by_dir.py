import os
from pathlib import Path

catalog_dir = Path("/home/raver1975/lean/Catalog")

non_lean = []
for root, dirs, files in os.walk(catalog_dir):
    for f in files:
        if not f.endswith(".lean"):
            full_path = Path(root) / f
            non_lean.append(full_path.relative_to(catalog_dir))

print(f"Total non-lean files in Catalog: {len(non_lean)}")

# Group by directory prefix (first component)
by_dir = {}
for p in non_lean:
    top = p.parts[0] if len(p.parts) > 1 else "."
    by_dir[top] = by_dir.get(top, 0) + 1

for top, count in sorted(by_dir.items(), key=lambda x: x[1], reverse=True):
    print(f"  {top}: {count} non-lean files")
