#!/usr/bin/env python3
import os
from pathlib import Path

catalog_root = Path("Catalog")
cleaned = 0

for filepath in catalog_root.rglob("*.lean"):
    try:
        content = filepath.read_text(encoding='utf-8', errors='replace')
        if '.lake.packages.' in content:
            new_content = content.replace('.lake.packages.mathlib.Mathlib.', 'Mathlib.')
            new_content = new_content.replace('.lake.packages.mathlib.Mathlib', 'Mathlib')
            new_content = new_content.replace('import .lake.packages.mathlib.', 'import ')
            if new_content != content:
                filepath.write_text(new_content, encoding='utf-8')
                cleaned += 1
    except Exception:
        pass

print(f"Cleaned invalid .lake.packages imports across {cleaned} Lean files.")
