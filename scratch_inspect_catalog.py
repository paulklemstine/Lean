import os
from pathlib import Path

catalog_dir = Path("/home/raver1975/lean/Catalog")

non_lean_files = []
lean_files = []

for root, dirs, files in os.walk(catalog_dir):
    for f in files:
        full_path = Path(root) / f
        rel_path = full_path.relative_to(catalog_dir)
        if f.endswith(".lean"):
            lean_files.append(rel_path)
        else:
            non_lean_files.append(rel_path)

print(f"Total Lean files in Catalog: {len(lean_files)}")
print(f"Total non-Lean files in Catalog: {len(non_lean_files)}")

# Group non-lean files by top-level directory or extension
ext_counts = {}
for p in non_lean_files:
    ext = p.suffix if p.suffix else "(no ext)"
    ext_counts[ext] = ext_counts.get(ext, 0) + 1

print("\nNon-Lean file extensions count:")
for ext, count in sorted(ext_counts.items(), key=lambda x: x[1], reverse=True):
    print(f"  {ext}: {count}")

print("\nSample non-Lean files (up to 50):")
for p in non_lean_files[:50]:
    print(f"  {p}")
