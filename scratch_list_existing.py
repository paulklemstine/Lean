import os
from pathlib import Path

catalog_dir = Path("/home/raver1975/lean/Catalog")

lean_files = []
for root, dirs, files in os.walk(catalog_dir):
    rel_root = Path(root).relative_to(catalog_dir)
    if len(rel_root.parts) > 0 and (rel_root.parts[0] == ".lake" or any(p.lower() == "packages" for p in rel_root.parts)):
        continue
    for f in files:
        if f.endswith(".lean"):
            lean_files.append(Path(root) / f)

print(f"Total existing Lean files now: {len(lean_files)}")
print("Sample existing Lean files:")
for p in lean_files[:10]:
    print(f"  {p.relative_to(catalog_dir)}")
