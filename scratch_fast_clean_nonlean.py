import os
from pathlib import Path

catalog_dir = Path("/home/raver1975/lean/Catalog")

allowed_exact = {"lakefile.toml", "lean-toolchain", "lake-manifest.json", "lakefile.lean"}

count = 0
for root, dirs, files in os.walk(catalog_dir):
    rel_root = Path(root).relative_to(catalog_dir)
    if len(rel_root.parts) > 0:
        if rel_root.parts[0] == ".lake" or any(p.lower() == "packages" for p in rel_root.parts):
            dirs[:] = []
            continue

    for f in files:
        if f.endswith(".lean"):
            continue
        rel_file = rel_root / f
        if len(rel_file.parts) == 1 and f in allowed_exact:
            continue
        
        file_path = Path(root) / f
        try:
            file_path.unlink()
            count += 1
        except Exception:
            pass

print(f"Successfully deleted {count} non-Lean files from Catalog.")
