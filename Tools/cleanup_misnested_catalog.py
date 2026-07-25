#!/usr/bin/env python3
"""Cleanup Misnested Catalog Files.

Relocates any legacy misnested files in Catalog (e.g. Catalog/Bridges/Catalog/...,
Catalog/Cryptography/Catalog/..., Catalog/Logic/Catalog/...) to their clean,
normalized paths, and removes empty legacy directories.
"""

import os
import re
import shutil
from pathlib import Path

KNOWN_DOMAINS = {
    "Algebra", "Applications", "Bridges", "Combinatorics", "Computation", "Cryptography",
    "EML", "Geometry", "Logic", "MachineLearning", "Novelty", "NumberTheory", "Physics",
    "Probability", "Pythagorean", "Shared", "Speculative", "Tropical",
}

def normalize_catalog_rel_path(path_str: str) -> str:
    path = path_str.replace("\\", "/").lstrip("/")

    # Strip structural prefixes
    path = re.sub(r'^(?:extracted/Catalog/|Catalog/|Bridges/Catalog/|FINAL/Catalog/|output-final_aristotle/Catalog/|[0-9a-f]+_aristotle/Catalog/)', '', path)
    path = re.sub(r'^(?:[0-9a-f]+_aristotle|output-final_aristotle|FINAL)/', '', path)

    # Strip interior Catalog or FINAL
    while '/Catalog/' in path:
        path = path.replace('/Catalog/', '/')
    while '/FINAL/' in path:
        path = path.replace('/FINAL/', '/')
    if path.startswith('Catalog/'):
        path = path[len('Catalog/'):]
    if path.startswith('FINAL/'):
        path = path[len('FINAL/'):]

    parts = [p for p in path.split('/') if p]
    if not parts:
        return path_str

    # Filter out interior 'Catalog' or 'FINAL'
    cleaned = [p for p in parts if p not in ("Catalog", "FINAL")]
    if not cleaned:
        return path_str

    deduped = [cleaned[0]]
    for i in range(1, len(cleaned)):
        if cleaned[i] == deduped[-1] and cleaned[i] in KNOWN_DOMAINS:
            continue
        if len(deduped) == 1 and deduped[0] == "Bridges" and cleaned[i] in KNOWN_DOMAINS and cleaned[i] != "Bridges":
            deduped = [cleaned[i]]
            continue
        deduped.append(cleaned[i])

    return "/".join(deduped)

def main():
    catalog_root = Path(__file__).resolve().parent.parent / "Catalog"
    print(f"[Cleanup] Scanning Catalog root at: {catalog_root}")

    relocated_count = 0
    # Search for files with 'Catalog' or 'FINAL' in their sub-path
    for p in list(catalog_root.rglob("*")):
        if not p.is_file():
            continue
        rel = p.relative_to(catalog_root)
        parts = rel.parts
        # If 'Catalog' or 'FINAL' appears inside sub-parts (not as root), or if doubled domain like Bridges/Cryptography/...
        has_misnesting = False
        if len(parts) > 1 and ("Catalog" in parts[1:] or "FINAL" in parts[1:]):
            has_misnesting = True
        elif len(parts) >= 3 and parts[0] == "Bridges" and parts[1] in KNOWN_DOMAINS and parts[1] != "Bridges":
            has_misnesting = True

        if has_misnesting:
            target_rel = normalize_catalog_rel_path(str(rel))
            target_full = catalog_root / target_rel

            if target_full != p:
                print(f"[Move] {rel} -> {target_rel}")
                target_full.parent.mkdir(parents=True, exist_ok=True)
                if target_full.exists():
                    # Keep newer file or append content if needed
                    p.unlink()
                else:
                    shutil.move(str(p), str(target_full))
                relocated_count += 1

    # Remove empty subdirectories under Catalog
    empty_dir_count = 0
    for d in sorted(list(catalog_root.rglob("*")), reverse=True):
        if d.is_dir() and not list(d.iterdir()):
            try:
                d.rmdir()
                empty_dir_count += 1
            except Exception:
                pass

    print(f"[Cleanup] Complete: Relocated {relocated_count} misnested files, removed {empty_dir_count} empty directories.")

if __name__ == '__main__':
    main()
