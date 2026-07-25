#!/usr/bin/env python3
import os
import re
from pathlib import Path

catalog_root = Path("Catalog").resolve()

# Build mapping of all existing lean files: basename -> module_path
file_by_basename = {}
for filepath in catalog_root.rglob("*.lean"):
    rel = filepath.relative_to(catalog_root)
    parts = list(rel.parts)
    parts[-1] = parts[-1][:-5]
    mod_path = ".".join(parts)
    file_by_basename[filepath.name] = mod_path

print(f"[ImportFix] Indexed {len(file_by_basename)} Lean files in Catalog.")

fixed_count = 0
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
                    expected_rel = imp_mod.replace('.', '/') + '.lean'
                    expected_file = catalog_root / expected_rel

                    if not expected_file.exists():
                        # Try to find target file by basename
                        fname = imp_mod.split('.')[-1] + '.lean'
                        if fname in file_by_basename:
                            correct_mod = file_by_basename[fname]
                            line = line.replace(imp_mod, correct_mod)
                            modified = True

            new_lines.append(line)

        if modified:
            filepath.write_text("".join(new_lines), encoding='utf-8')
            fixed_count += 1

    except Exception:
        pass

print(f"[ImportFix Complete] Fixed missing import references in {fixed_count} Lean files.")
