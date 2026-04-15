#!/usr/bin/env python3
"""Theorem Catalog System — unified CLI.

Commands:
  extract   Scan existing .lean files into the master database
  rescan   Incrementally update the database (new/modified files only) and rebuild
  build     Generate canonical .lean source from the database
  validate  Check build output for correctness
  all       Run the full pipeline (extract → build → validate)
"""

import argparse
import subprocess
import sys
import os
from pathlib import Path

TOOLS_DIR = Path(__file__).parent


def cmd_extract(args):
    """Run extraction."""
    from extract_catalog import scan_catalog
    import json, time

    print(f"Extracting from {args.source}...")
    catalog = scan_catalog(args.source, verbose=args.verbose)

    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)

    with open(output, 'w', encoding='utf-8') as f:
        json.dump(catalog, f, indent=2, ensure_ascii=False)

    meta = catalog["metadata"]
    print(f"\nExtraction complete")
    print(f"  Files:              {meta['total_files']}")
    print(f"  Declarations:       {meta['total_declarations']}")
    print(f"  Theorems/lemmas:    {meta['total_theorems']}")
    print(f"  Definitions:        {meta['total_defs']}")
    print(f"  Structures/classes: {meta['total_structures']}")
    print(f"  Duplicate groups:   {meta['total_duplicate_groups']}")
    print(f"  Canonical:          {meta['total_canonical']}")
    print(f"  Domains:            {len(catalog['domains'])}")
    print(f"  Output: {output}")


def cmd_build(args):
    """Run build."""
    from build_catalog import CatalogBuilder
    import json

    print(f"Building from {args.db}...")
    with open(args.db, 'r', encoding='utf-8') as f:
        db = json.load(f)

    builder = CatalogBuilder(
        db=db,
        output_dir=args.output_dir,
        shared_threshold=args.shared_threshold,
        module_prefix=args.prefix,
        verbose=args.verbose,
    )
    builder.build()
    print(f"\nBuild output: {args.output_dir}")


def cmd_validate(args):
    """Run validation."""
    from validate_catalog import validate_build

    print(f"Validating {args.build_dir}...")
    success = validate_build(args.build_dir, args.db, verbose=args.verbose)
    return 0 if success else 1


def cmd_rescan(args):
    """Incrementally rescan source for new/modified theorems, update DB, and rebuild."""
    from extract_catalog import scan_incremental
    from build_catalog import CatalogBuilder
    import json, time

    db_path = Path(args.db)

    # Step 1: Load existing database
    print(f"Loading existing database from {db_path}...")
    with open(db_path, 'r', encoding='utf-8') as f:
        existing_db = json.load(f)

    old_meta = existing_db.get("metadata", {})
    old_total = old_meta.get("total_declarations", 0)
    old_files = old_meta.get("total_files", 0)
    print(f"  Existing: {old_total} declarations from {old_files} files")

    # Step 2: Run incremental scan
    print(f"\nRescanning {args.source} for changes...")
    start = time.time()
    catalog = scan_incremental(args.source, existing_db, verbose=args.verbose)
    elapsed = time.time() - start

    # Step 3: Save updated database
    catalog["metadata"]["extraction_duration_seconds"] = round(elapsed, 2)
    with open(db_path, 'w', encoding='utf-8') as f:
        json.dump(catalog, f, indent=2, ensure_ascii=False)

    new_meta = catalog["metadata"]
    print(f"\nRescan complete in {elapsed:.1f}s")
    print(f"  Files:              {new_meta['total_files']}")
    print(f"  Declarations:       {new_meta['total_declarations']} (was {old_total})")
    print(f"  Theorems/lemmas:    {new_meta['total_theorems']}")
    print(f"  Definitions:        {new_meta['total_defs']}")
    print(f"  Structures/classes: {new_meta['total_structures']}")
    print(f"  Duplicate groups:   {new_meta['total_duplicate_groups']}")
    print(f"  Canonical:          {new_meta['total_canonical']}")
    delta = new_meta['total_declarations'] - old_total
    if delta > 0:
        print(f"  New declarations:   +{delta}")
    elif delta < 0:
        print(f"  Removed declarations: {delta}")

    # Step 4: Auto-rebuild
    print(f"\n{'=' * 60}")
    print("REBUILDING from updated database...")
    print("=" * 60)

    builder = CatalogBuilder(
        db=catalog,
        output_dir=args.output_dir,
        shared_threshold=args.shared_threshold,
        module_prefix=args.prefix,
        verbose=args.verbose,
    )
    builder.build()

    print(f"\nDone. Database: {db_path}")
    print(f"      Build:    {args.output_dir}")
    return 0


def cmd_all(args):
    """Run full pipeline."""
    db_path = str(TOOLS_DIR / "output" / "catalog.json")

    # Extract
    print("=" * 60)
    print("PHASE 1: EXTRACT")
    print("=" * 60)
    extract_args = argparse.Namespace(
        source=args.source,
        output=db_path,
        verbose=args.verbose,
    )
    cmd_extract(extract_args)

    # Build
    print("\n" + "=" * 60)
    print("PHASE 2: BUILD")
    print("=" * 60)
    build_args = argparse.Namespace(
        db=db_path,
        output_dir=args.output_dir,
        shared_threshold=args.shared_threshold,
        prefix=args.prefix,
        verbose=args.verbose,
    )
    cmd_build(build_args)

    # Validate
    print("\n" + "=" * 60)
    print("PHASE 3: VALIDATE")
    print("=" * 60)
    val_args = argparse.Namespace(
        build_dir=args.output_dir,
        db=db_path,
        verbose=args.verbose,
    )
    rc = cmd_validate(val_args)

    return rc


def main():
    parser = argparse.ArgumentParser(
        description="Theorem Catalog System",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 tools/catalog.py extract --source Catalog/ --output tools/output/catalog.json
  python3 tools/catalog.py rescan --source Catalog/ --db tools/output/catalog.json --output-dir CatalogBuild/
  python3 tools/catalog.py build --db tools/output/catalog.json --output-dir CatalogBuild/
  python3 tools/catalog.py validate --build-dir CatalogBuild/ --db tools/output/catalog.json
  python3 tools/catalog.py all --source Catalog/ --output-dir CatalogBuild/
        """,
    )
    subparsers = parser.add_subparsers(dest='command', help='Command to run')

    # Extract
    p_extract = subparsers.add_parser('extract', help='Scan .lean files into database')
    p_extract.add_argument('--source', required=True, help='Catalog root directory')
    p_extract.add_argument('--output', required=True, help='Output JSON path')
    p_extract.add_argument('--verbose', '-v', action='store_true')

    # Build
    p_build = subparsers.add_parser('build', help='Generate source from database')
    p_build.add_argument('--db', required=True, help='Catalog database JSON')
    p_build.add_argument('--output-dir', required=True, help='Output directory')
    p_build.add_argument('--shared-threshold', type=int, default=5,
                         help='Min occurrences for shared module (default: 5)')
    p_build.add_argument('--prefix', default='CatalogBuild',
                         help='Module path prefix (default: CatalogBuild)')
    p_build.add_argument('--verbose', '-v', action='store_true')

    # Validate
    p_validate = subparsers.add_parser('validate', help='Validate build output')
    p_validate.add_argument('--build-dir', required=True, help='Build output directory')
    p_validate.add_argument('--db', required=True, help='Catalog database JSON')
    p_validate.add_argument('--verbose', '-v', action='store_true')

    # Rescan
    p_rescan = subparsers.add_parser('rescan',
                                      help='Incrementally update database and rebuild')
    p_rescan.add_argument('--source', required=True, help='Catalog root directory')
    p_rescan.add_argument('--db', required=True, help='Catalog database JSON (will be updated)')
    p_rescan.add_argument('--output-dir', required=True, help='Build output directory')
    p_rescan.add_argument('--shared-threshold', type=int, default=5,
                          help='Min occurrences for shared module (default: 5)')
    p_rescan.add_argument('--prefix', default='CatalogBuild',
                          help='Module path prefix (default: CatalogBuild)')
    p_rescan.add_argument('--verbose', '-v', action='store_true')

    # All
    p_all = subparsers.add_parser('all', help='Run full pipeline')
    p_all.add_argument('--source', required=True, help='Catalog root directory')
    p_all.add_argument('--output-dir', required=True, help='Build output directory')
    p_all.add_argument('--shared-threshold', type=int, default=5)
    p_all.add_argument('--prefix', default='CatalogBuild')
    p_all.add_argument('--verbose', '-v', action='store_true')

    args = parser.parse_args()

    if args.command is None:
        parser.print_help()
        sys.exit(1)

    if args.command == 'extract':
        cmd_extract(args)
    elif args.command == 'rescan':
        rc = cmd_rescan(args)
        sys.exit(rc)
    elif args.command == 'build':
        cmd_build(args)
    elif args.command == 'validate':
        rc = cmd_validate(args)
        sys.exit(rc)
    elif args.command == 'all':
        rc = cmd_all(args)
        sys.exit(rc)


if __name__ == '__main__':
    main()