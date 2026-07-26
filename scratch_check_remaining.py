import os
from pathlib import Path

catalog_dir = Path("/home/raver1975/lean/Catalog")

non_lean = []
lean = []

for root, dirs, files in os.walk(catalog_dir):
    for f in files:
        if f.endswith(".lean"):
            lean.append(Path(root) / f)
        else:
            non_lean.append(Path(root) / f)

print(f"Remaining Lean files in Catalog: {len(lean)}")
print(f"Remaining non-Lean files in Catalog: {len(non_lean)}")
print("Remaining non-Lean files:")
for f in non_lean:
    print(f"  {f.relative_to(catalog_dir)}")
