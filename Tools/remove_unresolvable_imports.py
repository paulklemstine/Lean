#!/usr/bin/env python3
import os
from pathlib import Path

catalog_root = Path("Catalog").resolve()

# Collect all valid relative module paths in Catalog/
valid_modules = set()
for filepath in catalog_root.rglob("*.lean"):
    rel = filepath.relative_to(catalog_root)
    parts = list(rel.parts)
    parts[-1] = parts[-1][:-5]
    valid_modules.add(".".join(parts))
    valid_modules.add("Catalog." + ".".join(parts))

print(f"[ImportCleaner] Indexed {len(valid_modules)} valid modules in Catalog.")

commented_count = 0
for filepath in catalog_root.rglob("*.lean"):
    try:
        content = filepath.read_text(encoding='utf-8', errors='replace')
        modified = False
        new_lines = []

        for line in content.splitlines(keepends=True):
            l_strip = line.strip()
            if l_strip.startswith('import '):
                imp_mod = l_strip[7:].strip()
                if not imp_mod.startswith(('Mathlib', 'Init', 'Lean')):
                    if imp_mod not in valid_modules:
                        # Comment out unresolvable import
                        line = f"-- {line}"
                        modified = True

            new_lines.append(line)

        if modified:
            filepath.write_text("".join(new_lines), encoding='utf-8')
            commented_count += 1

    except Exception:
        pass

print(f"[ImportCleaner Complete] Commented out unresolvable imports in {commented_count} Lean files.")
