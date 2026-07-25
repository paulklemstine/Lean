#!/usr/bin/env python3
"""Compilation and diagnostic repair CLI for catalog Lean files.

Runs the Lean compiler across Catalog/ files, collects diagnostics,
and repairs import paths, syntax errors, and unclosed namespace/section blocks.
"""

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path

ELAN_LEAN = os.path.expanduser("~/.elan/bin/lean")
ELAN_LAKE = os.path.expanduser("~/.elan/bin/lake")

def get_lean_binary():
    if os.path.exists(ELAN_LEAN):
        return ELAN_LEAN
    return "lean"

def get_lake_binary():
    if os.path.exists(ELAN_LAKE):
        return ELAN_LAKE
    return "lake"

def build_module_index(catalog_root: Path) -> dict:
    """Build a mapping of module names and file basenames to full relative Lean paths under Catalog/."""
    index = {} # module_name -> relative_file_path (e.g. 'Novelty.RamseyTheory.Foo' -> 'Novelty/RamseyTheory/Foo.lean')
    basename_map = {} # 'Foo.lean' -> 'Novelty.RamseyTheory.Foo'

    for root, dirs, files in os.walk(catalog_root):
        for f in files:
            if f.endswith('.lean'):
                full_p = Path(root) / f
                rel_p = full_p.relative_to(catalog_root)
                parts = list(rel_p.parts)
                parts[-1] = parts[-1][:-5] # strip .lean
                mod_name = ".".join(parts)
                
                index[mod_name] = rel_p
                index[f"Catalog.{mod_name}"] = rel_p
                basename_map[f] = mod_name

    return index, basename_map

def check_file_imports(filepath: Path, module_index: dict, basename_map: dict) -> list:
    """Check for broken or outdated imports in a single Lean file."""
    fixes = [] # (line_num, old_import, new_import)

    try:
        content = filepath.read_text(encoding='utf-8', errors='replace')
        lines = content.splitlines()

        for idx, line in enumerate(lines):
            l_strip = line.strip()
            if l_strip.startswith('import '):
                imp_target = l_strip[7:].strip()
                # Skip Mathlib, Init, Lean standard modules
                if imp_target.startswith(('Mathlib', 'Init', 'Lean')):
                    continue

                # If import target is not in module_index
                if imp_target not in module_index:
                    # Check if target ends with a filename we know
                    fname = imp_target.split('.')[-1] + '.lean'
                    if fname in basename_map:
                        new_target = basename_map[fname]
                        fixes.append((idx, imp_target, new_target))
    except Exception:
        pass

    return fixes

def repair_imports_and_namespaces(catalog_root: Path, apply: bool = False):
    """Scan all Lean files under Catalog/ for broken imports and unclosed namespace blocks."""
    print("[CompileFix] Scanning Catalog/ for broken imports and syntax structures...")
    module_index, basename_map = build_module_index(catalog_root)

    all_lean_files = list(catalog_root.rglob("*.lean"))
    files_with_import_fixes = 0
    files_with_namespace_fixes = 0

    for filepath in all_lean_files:
        try:
            content = filepath.read_text(encoding='utf-8', errors='replace')
            lines = content.splitlines(keepends=True)
            modified = False

            # 1. Import Fixes
            new_lines = []
            for line in lines:
                l_strip = line.strip()
                if l_strip.startswith('import '):
                    imp_target = l_strip[7:].strip()
                    if not imp_target.startswith(('Mathlib', 'Init', 'Lean')) and imp_target not in module_index:
                        fname = imp_target.split('.')[-1] + '.lean'
                        if fname in basename_map:
                            new_mod = basename_map[fname]
                            line = line.replace(imp_target, new_mod)
                            modified = True
                new_lines.append(line)

            # 2. Namespace & Section Closure Fixes
            open_namespaces = []
            open_sections = []
            for line in new_lines:
                l_strip = line.strip()
                if l_strip.startswith('namespace '):
                    ns = l_strip[10:].strip()
                    open_namespaces.append(ns)
                elif l_strip.startswith('section'):
                    sec = l_strip[7:].strip()
                    open_sections.append(sec)
                elif l_strip.startswith('end '):
                    end_target = l_strip[4:].strip()
                    if open_namespaces and open_namespaces[-1] == end_target:
                        open_namespaces.pop()
                    elif open_sections and open_sections[-1] == end_target:
                        open_sections.pop()

            # If unclosed namespaces remain at end of file, append closing 'end' statements
            if open_namespaces or open_sections:
                if apply:
                    for sec in reversed(open_sections):
                        new_lines.append(f"\nend {sec}\n")
                    for ns in reversed(open_namespaces):
                        new_lines.append(f"\nend {ns}\n")
                    modified = True
                    files_with_namespace_fixes += 1

            if modified and apply:
                filepath.write_text("".join(new_lines), encoding='utf-8')
                files_with_import_fixes += 1

        except Exception as e:
            pass

    print(f"[CompileFix Scan Complete]")
    print(f"  Total Lean files scanned: {len(all_lean_files)}")
    print(f"  Files with repaired imports: {files_with_import_fixes}")
    print(f"  Files with repaired namespace closures: {files_with_namespace_fixes}")

def run_lean_check(catalog_root: Path, max_files: int = 100):
    """Run Lean compiler on a sample of files to verify diagnostics."""
    lean_bin = get_lean_binary()
    print(f"[CompileFix] Running Lean compiler check using {lean_bin}...")
    
    all_files = list(catalog_root.rglob("*.lean"))[:max_files]
    passed = 0
    failed = 0

    for f in all_files:
        cmd = [lean_bin, "-R", str(catalog_root), str(f)]
        res = subprocess.run(cmd, capture_output=True, text=True, errors='replace', timeout=10)
        if res.returncode == 0:
            passed += 1
        else:
            failed += 1

    print(f"[Compile Check Sample ({len(all_files)} files)] Passed: {passed}, Failed: {failed}")

def main():
    parser = argparse.ArgumentParser(description="Compile and fix catalog Lean files")
    parser.add_argument('--catalog-root', default='Catalog', help="Catalog root directory")
    parser.add_argument('--apply', action='store_true', help="Execute import & syntax repairs")
    parser.add_argument('--check-compiler', action='store_true', help="Run Lean compiler check")
    args = parser.parse_args()

    catalog_root = Path(args.catalog_root).resolve()
    repair_imports_and_namespaces(catalog_root, apply=args.apply)

    if args.check_compiler:
        run_lean_check(catalog_root)

if __name__ == '__main__':
    main()
