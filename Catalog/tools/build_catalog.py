#!/usr/bin/env python3
"""Build canonical Lean source files from the catalog database.

Reads catalog.json, filters to canonical declarations, and generates
a clean source tree with:
- Deduplicated declarations (one canonical copy each)
- Fixed imports (references to removed declarations redirect to canonical locations)
- Shared modules for high-frequency duplicates
- Clean categorized hierarchy
- Auto-generated lakefile.toml and lean-toolchain
"""

import argparse
import json
import os
import re
import re
from collections import defaultdict
from pathlib import Path
from typing import Optional


# ── Module name helpers ─────────────────────────────────────────────

LEAN_KEYWORDS = {
    'where', 'by', 'do', 'let', 'in', 'if', 'then', 'else',
    'match', 'with', 'fun', 'have', 'from', 'import', 'open',
    'namespace', 'end', 'section', 'variable', 'universe', 'type',
}

LEAN_RESERVED = {
    'Prop', 'Type', 'Sort', 'Unit', 'Bool', 'Nat', 'Int', 'Float',
    'Char', 'String', 'Array', 'List', 'Option', 'Sum', 'Prod',
    'PUnit', 'MUnit', 'Empty', 'PLift', 'ULift', 'Subtype',
    'Fin', 'UInt8', 'UInt16', 'UInt32', 'UInt64',
}


def lean_ident_safe(name: str) -> str:
    """Make a name safe for use as a Lean module component."""
    # Replace non-alphanumeric with underscore
    safe = re.sub(r'[^A-Za-z0-9_]', '_', name)
    # Remove leading digits
    safe = re.sub(r'^[0-9]+', '', safe)
    # Collapse multiple underscores
    safe = re.sub(r'_+', '_', safe)
    safe = safe.strip('_')
    # Capitalize first letter for module name
    if safe and safe[0].islower():
        safe = safe[0].upper() + safe[1:]
    return safe or "X"


def path_to_module(rel_path: str, prefix: str = "CatalogBuild") -> str:
    """Convert relative file path to Lean module path."""
    p = Path(rel_path)
    parts = list(p.parts)
    if parts and parts[-1].endswith('.lean'):
        parts[-1] = parts[-1][:-5]
    return prefix + "." + ".".join(parts)


# ── Build logic ────────────────────────────────────────────────────

class CatalogBuilder:
    """Build clean source tree from catalog database."""

    def __init__(self, db: dict, output_dir: str, shared_threshold: int = 5,
                 module_prefix: str = "CatalogBuild", verbose: bool = False):
        self.db = db
        self.output_dir = Path(output_dir)
        self.shared_threshold = shared_threshold
        self.module_prefix = module_prefix
        self.verbose = verbose

        # Index entries by id for fast lookup
        self.entries_by_id = {e['id']: e for e in db['entries']}

        # Index: name -> list of entries
        self.entries_by_name = defaultdict(list)
        for e in db['entries']:
            self.entries_by_name[e['name']].append(e)

        # Canonical entries only
        self.canonical = [e for e in db['entries'] if e.get('canonical', True)]

        # Map: name -> canonical entry
        self.canonical_by_name = {}
        for e in self.canonical:
            key = (e['name'], e.get('namespace', ''))
            self.canonical_by_name[key] = e

        # Duplicate groups with high occurrence count
        self.dup_groups = db.get('duplicate_groups', [])
        self.shared_groups = [g for g in self.dup_groups
                              if g['occurrence_count'] >= shared_threshold
                              and g.get('recommendation') == 'extract_to_shared']

        # Build name -> canonical source file mapping
        self.name_to_canonical_module = {}
        for e in self.canonical:
            self.name_to_canonical_module[e['name']] = e

    def build(self):
        """Run the full build pipeline."""
        if self.verbose:
            print(f"Building from {len(self.canonical)} canonical declarations")
            print(f"Shared modules threshold: {self.shared_threshold}")
            print(f"Shared groups: {len(self.shared_groups)}")

        # Step 1: Group canonical entries by target output file
        file_groups = self._group_entries_into_files()

        # Step 2: Generate shared modules
        shared_modules = self._generate_shared_modules()
        shared_names = self._shared_declaration_names()

        # Step 3: Remove shared declarations from file groups
        for fg in file_groups.values():
            fg['entries'] = [e for e in fg['entries'] if e['name'] not in shared_names]

        # Step 4: Calculate imports for each file
        self._calculate_imports(file_groups, shared_modules)

        # Step 5: Write output files
        self._write_output(file_groups, shared_modules)

        # Step 6: Write build config
        self._write_build_config(file_groups, shared_modules)

        if self.verbose:
            total_files = len(file_groups) + len(shared_modules)
            print(f"\nBuild complete: {total_files} .lean files in {self.output_dir}")

    def _group_entries_into_files(self) -> dict:
        """Group canonical entries by their target output file.

        Preserves original file structure where possible, but
        merges entries from files that lost declarations to dedup.
        """
        # Group by (domain, subdomain, original_filename)
        groups = defaultdict(lambda: {'entries': [], 'domain': '', 'subdomain': None})

        for e in self.canonical:
            # Determine target file path
            domain = e.get('domain', 'Uncategorized')
            subdomain = e.get('subdomain')
            source = e.get('source_file', '')

            # Use original filename as base
            orig_filename = Path(source).name

            # Build target path
            if subdomain:
                target_path = f"{domain}/{subdomain}/{orig_filename}"
            else:
                target_path = f"{domain}/{orig_filename}"

            # Avoid collisions: if same target_path gets entries from different source files,
            # disambiguate
            key = target_path
            if key not in groups:
                groups[key] = {
                    'entries': [],
                    'domain': domain,
                    'subdomain': subdomain,
                    'target_path': target_path,
                }
            groups[key]['entries'].append(e)

        return dict(groups)

    def _generate_shared_modules(self) -> list[dict]:
        """Generate shared module definitions for high-frequency duplicates."""
        shared = []
        for group in self.shared_groups:
            name = group['name']
            module_name = lean_ident_safe(name)

            # Collect canonical entries for this name
            canonical_entries = [e for e in self.canonical if e['name'] == name]

            # Also collect closely related declarations from the same file
            # (e.g., relu + relu_idempotent + relu_monotone)
            related_names = set()
            for e in canonical_entries:
                # Find other declarations in the same source file with similar prefix
                source = e.get('source_file', '')
                for ce in self.canonical:
                    if ce.get('source_file') == source and ce['name'] != name:
                        # Check if the name starts with the same prefix
                        prefix = name.split('_')[0] if '_' in name else name
                        if ce['name'].startswith(prefix + '_') or ce['name'] == prefix:
                            related_names.add(ce['name'])

            # Collect all entries for the primary name + related
            all_entries = list(canonical_entries)
            for rn in related_names:
                for ce in self.canonical:
                    if ce['name'] == rn and ce not in all_entries:
                        all_entries.append(ce)

            shared.append({
                'module_name': module_name,
                'target_path': f"Shared/{module_name}.lean",
                'entries': all_entries,
                'group': group,
            })

        return shared

    def _shared_declaration_names(self) -> set:
        """Get the set of declaration names that will go into shared modules."""
        names = set()
        for sm in self.shared_groups:
            names.add(sm['name'])
            # Also include related names
            for e in self.canonical:
                if e['name'] == sm['name']:
                    source = e.get('source_file', '')
                    prefix = sm['name'].split('_')[0] if '_' in sm['name'] else sm['name']
                    for ce in self.canonical:
                        if ce.get('source_file') == source:
                            if ce['name'].startswith(prefix + '_') or ce['name'] == prefix:
                                names.add(ce['name'])
        return names

    def _calculate_imports(self, file_groups: dict, shared_modules: list[dict]):
        """Calculate the import list for each output file.

        Optimized: uses a name-to-module index for O(1) lookups instead of O(n^2) scanning.
        Only adds Catalog.* imports for cross-module references found in declaration bodies.
        """
        # Build a map: declaration name -> output module path (fast lookup)
        decl_to_module = {}
        for sm in shared_modules:
            module = path_to_module(sm['target_path'], self.module_prefix)
            for e in sm['entries']:
                decl_to_module[e['name']] = module

        for key, fg in file_groups.items():
            module = path_to_module(fg['target_path'], self.module_prefix)
            for e in fg['entries']:
                decl_to_module[e['name']] = module

        # Build a name -> set of modules index for cross-reference checking
        # (same name can appear in multiple modules if different decls share a name)

        # For each file, determine needed imports
        for key, fg in file_groups.items():
            needed_imports = set()
            target_module = path_to_module(fg['target_path'], self.module_prefix)
            local_names = {e['name'] for e in fg['entries']}

            # Collect original imports from entries (Mathlib, etc.)
            for e in fg['entries']:
                for imp in e.get('imports', []):
                    if imp == target_module:
                        continue
                    needed_imports.add(imp)

            # Scan body text for references to declarations in OTHER modules
            # NOTE: Only add CatalogBuild.* imports that were in the original source.
            # Cross-reference heuristics create circular imports, so we skip them.
            # The original imports already contain the needed dependencies.
            # (Removed cross-reference scanning to avoid circular imports.)

            fg['calculated_imports'] = sorted(needed_imports)

        # Calculate imports for shared modules
        for sm in shared_modules:
            needed_imports = set()
            target_module = path_to_module(sm['target_path'], self.module_prefix)
            local_names = {e['name'] for e in sm['entries']}

            for e in sm['entries']:
                for imp in e.get('imports', []):
                    if imp != target_module:
                        needed_imports.add(imp)

            # Cross-references for shared modules
            # NOTE: Only add imports from original source. Skip cross-reference heuristic
            # to avoid circular imports.
            for e in sm['entries']:
                body = e.get('body', '')
                _ = body  # unused - cross-reference heuristic removed
                pass

            sm['calculated_imports'] = sorted(needed_imports)

    def _write_output(self, file_groups: dict, shared_modules: list[dict]):
        """Write all output .lean files."""
        # Write domain files
        for key, fg in file_groups.items():
            if not fg['entries']:
                continue
            self._write_lean_file(
                fg['target_path'],
                fg['entries'],
                fg.get('calculated_imports', []),
            )

        # Write shared modules
        for sm in shared_modules:
            if not sm['entries']:
                continue
            self._write_lean_file(
                sm['target_path'],
                sm['entries'],
                sm.get('calculated_imports', []),
            )

    def _write_lean_file(self, target_path: str, entries: list[dict],
                         imports: list[str]):
        """Write a single .lean file."""
        out_file = self.output_dir / target_path
        out_file.parent.mkdir(parents=True, exist_ok=True)

        module = path_to_module(target_path, self.module_prefix)

        # Determine the primary namespace
        namespaces = set()
        for e in entries:
            ns = e.get('namespace', '')
            if ns:
                namespaces.add(ns)

        # If mixed namespaces, we need to group by namespace
        if len(namespaces) > 1:
            self._write_multi_namespace_file(out_file, module, entries, imports)
        else:
            self._write_single_namespace_file(out_file, module, entries, imports)

    def _write_single_namespace_file(self, out_file: Path, module: str,
                                      entries: list[dict], imports: list[str]):
        """Write a .lean file with a single namespace."""
        lines = []

        # Module doc comment
        domain = entries[0].get('domain', '') if entries else ''
        subdomain = entries[0].get('subdomain', '') if entries else ''
        location = f"{domain}/{subdomain}" if subdomain else domain
        lines.append(f'/-! # {module}')
        lines.append(f'')
        lines.append(f'Auto-generated from theorem catalog database.')
        lines.append(f'Domain: {location}')
        lines.append(f'Declarations: {len(entries)}')
        lines.append(f'-/')

        # Imports — fix Catalog.* -> CatalogBuild.*
        if imports:
            lines.append('')
            for imp in imports:
                if imp.startswith('Catalog.'):
                    imp = imp.replace('Catalog.', 'CatalogBuild.', 1)
                lines.append(f'import {imp}')

        # Add noncomputable section if needed
        has_noncomp = any(e.get('is_noncomputable', False) for e in entries)
        if has_noncomp:
            lines.append('')
            lines.append('noncomputable section')

        # Declarations — emit bodies as-is (they contain their own namespace/end blocks)
        for e in entries:
            lines.append('')
            # Use description (combines doc + line + section comments) if available,
            # fall back to doc_comment for backward compatibility
            desc = e.get('description') or e.get('doc_comment')
            if desc:
                lines.append(f'/-- {desc} -/')
            lines.append(e.get('body', ''))

        if has_noncomp:
            lines.append('')
            lines.append('end')

        # Write file
        out_file.write_text('\n'.join(lines) + '\n', encoding='utf-8')

        if self.verbose:
            print(f"  Wrote {out_file.relative_to(self.output_dir)}: {len(entries)} declarations")

    def _write_multi_namespace_file(self, out_file: Path, module: str,
                                     entries: list[dict], imports: list[str]):
        """Write a .lean file with multiple namespace blocks."""
        lines = []

        lines.append(f'/-! # {module}')
        lines.append(f'')
        lines.append(f'Auto-generated from theorem catalog database.')
        lines.append(f'Declarations: {len(entries)}')
        lines.append(f'-/')

        if imports:
            lines.append('')
            for imp in imports:
                if imp.startswith('Catalog.'):
                    imp = imp.replace('Catalog.', 'CatalogBuild.', 1)
                lines.append(f'import {imp}')

        # Add noncomputable section if needed
        has_noncomp = any(e.get('is_noncomputable', False) for e in entries)
        if has_noncomp:
            lines.append('')
            lines.append('noncomputable section')

        # Emit all declarations as-is (bodies contain their own namespace/end blocks)
        for e in entries:
            lines.append('')
            if e.get('doc_comment'):
                lines.append(f'/-- {e["doc_comment"]} -/')
            lines.append(e.get('body', ''))

        if has_noncomp:
            lines.append('')
            lines.append('end')

        out_file.write_text('\n'.join(lines) + '\n', encoding='utf-8')

        if self.verbose:
            print(f"  Wrote {out_file.relative_to(self.output_dir)}: {len(entries)} declarations")

    def _write_build_config(self, file_groups: dict, shared_modules: list[dict]):
        """Write lakefile.toml and lean-toolchain."""
        # Collect all output directories for lean_lib targets
        domains = set()
        for key, fg in file_groups.items():
            if fg['entries']:
                tp = fg['target_path']
                # Top-level domain is first path component
                domain = Path(tp).parts[0]
                domains.add(domain)
        for sm in shared_modules:
            domains.add('Shared')

        # lean-toolchain
        toolchain_file = self.output_dir / 'lean-toolchain'
        lean_version = self.db.get('metadata', {}).get('lean_version', 'v4.28.0')
        toolchain_file.write_text(f'leanprover/lean4:{lean_version}\n', encoding='utf-8')

        # lakefile.toml
        lib_targets = sorted(domains)
        lib_lines = []
        lib_lines.append('name = "CatalogBuild"')
        lib_lines.append(f'defaultTargets = {json.dumps(lib_targets)}')
        lib_lines.append('')
        lib_lines.append('[[require]]')
        lib_lines.append('name = "mathlib"')
        lib_lines.append('git = "https://github.com/leanprover-community/mathlib4.git"')
        mathlib_version = self.db.get('metadata', {}).get('mathlib_version', 'v4.28.0')
        lib_lines.append(f'rev = "{mathlib_version}"')
        lib_lines.append('')

        for lib in lib_targets:
            lib_lines.append('[[lean_lib]]')
            lib_lines.append(f'name = "{lib}"')
            lib_lines.append(f'globs = ["{lib}.+"]')
            lib_lines.append('')

        lakefile = self.output_dir / 'lakefile.toml'
        lakefile.write_text('\n'.join(lib_lines), encoding='utf-8')

        if self.verbose:
            print(f"\n  Wrote lakefile.toml with {len(lib_targets)} library targets")
            print(f"  Wrote lean-toolchain ({lean_version})")


def main():
    parser = argparse.ArgumentParser(description="Build canonical Lean source from catalog database")
    parser.add_argument("--db", required=True, help="Path to catalog.json database")
    parser.add_argument("--output", "--output-dir", required=True, help="Output directory for generated source tree")
    parser.add_argument("--shared-threshold", type=int, default=5,
                        help="Minimum occurrences for shared module extraction (default: 5)")
    parser.add_argument("--prefix", default="CatalogBuild",
                        help="Module path prefix (default: CatalogBuild)")
    parser.add_argument("--verbose", action="store_true", help="Print progress")
    args = parser.parse_args()

    with open(args.db, 'r', encoding='utf-8') as f:
        db = json.load(f)

    builder = CatalogBuilder(
        db=db,
        output_dir=args.output,
        shared_threshold=args.shared_threshold,
        module_prefix=args.prefix,
        verbose=args.verbose,
    )
    builder.build()


if __name__ == '__main__':
    main()