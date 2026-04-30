#!/usr/bin/env python3
"""Deduplicate and reorganize the Lean Catalog.

Strategy:
1. Hash every .lean file (excluding .lake)
2. Group content-identical files
3. For each group, pick the "canonical" copy using priority rules:
   - Prefer shallower paths (fewer directory levels)
   - Prefer paths where the top-level domain matches the file content
   - Prefer paths without nested domain stuttering (e.g. Tropical/Tropical/)
4. Remove all non-canonical copies
5. Clean up empty directories
6. Report results
"""

import hashlib
import shutil
import sys
from collections import defaultdict
from pathlib import Path

CATALOG = Path("/home/raver1975/lean/Catalog")
BACKUP = Path("/home/raver1975/lean/Catalog_backup_dedup")

# Known top-level domains (for scoring path quality)
DOMAINS = {
    "Algebra", "Bridges", "Computation", "Cryptography", "EML",
    "Geometry", "Logic", "MachineLearning", "Physics", "Pythagorean",
    "Shared", "Speculative", "Tropical",
}

# Directories that are NOT research domains (don't move lean files here)
NON_DOMAIN_DIRS = {"Applications", "ResearchOutput", "Tools"}


def hash_file(path: Path) -> str:
    return hashlib.md5(path.read_bytes()).hexdigest()


def path_depth(rel: Path) -> int:
    return len(rel.parts)


def has_stutter(rel: Path) -> bool:
    """Check for nested domain stuttering like Pythagorean/Pythagorean/."""
    parts = rel.parts
    for i in range(len(parts) - 1):
        if parts[i] == parts[i + 1]:
            return True
    return False


def domain_from_content(path: Path) -> str:
    """Try to guess the domain from file content keywords."""
    try:
        text = path.read_text(errors="ignore").lower()
    except Exception:
        return ""

    scores = {}
    domain_keywords = {
        "Tropical": ["tropical", "trop", "semiring", "min_plus", "max_plus"],
        "Pythagorean": ["pythagorean", "berggren", "triple", "pythagorean_triple"],
        "EML": ["eml", "emergent", "meta_language", "exponential_multiplicative"],
        "Algebra": ["algebra", "ring", "group", "field", "module", "polynomial"],
        "Cryptography": ["crypto", "dilithium", "lattice", "cipher", "encrypt"],
        "Physics": ["quantum", "photon", "lorentz", "spacetime", "hamiltonian"],
        "MachineLearning": ["neural", "gradient", "backprop", "mnist", "training"],
        "Logic": ["logic", "decidab", "computable", "halting", "godel"],
        "Computation": ["computation", "complexity", "automata", "turing"],
        "Bridges": ["bridge", "spb", "connection", "cross_domain"],
        "Geometry": ["geometry", "manifold", "curvature", "metric_space"],
        "Shared": ["shared", "common", "utility"],
        "Speculative": ["speculative", "conjecture", "hypothe"],
    }

    for domain, keywords in domain_keywords.items():
        score = sum(text.count(kw) for kw in keywords)
        if score > 0:
            scores[domain] = score

    if scores:
        return max(scores, key=scores.get)
    return ""


def pick_canonical(paths: list[Path]) -> Path:
    """Pick the best canonical path from a group of content-identical files.
    
    Priority (highest first):
    1. No domain stutter (e.g. avoid Tropical/Tropical/)
    2. Shallowest path depth
    3. Top-level dir is a known domain
    4. Top-level dir matches content domain
    """
    # Score each path (lower is better)
    def score(p: Path) -> tuple:
        rel = p.relative_to(CATALOG)
        top = rel.parts[0] if len(rel.parts) > 1 else ""
        stutter = has_stutter(rel)
        depth = path_depth(rel)
        is_domain = top in DOMAINS
        in_non_domain = top in NON_DOMAIN_DIRS

        return (
            stutter,           # False < True (prefer no stutter)
            in_non_domain,     # False < True (prefer domain dirs)
            depth,             # Shallower is better
            not is_domain,     # False < True (prefer known domains)
            str(rel),          # Tiebreaker: alphabetical
        )

    paths.sort(key=score)
    return paths[0]


def main():
    dry_run = "--dry-run" in sys.argv
    
    if dry_run:
        print("=== DRY RUN MODE (no files will be modified) ===\n")
    
    # Step 1: Collect all .lean files (excluding .lake)
    print("Scanning Catalog for .lean files...")
    all_files = []
    for f in CATALOG.rglob("*.lean"):
        if ".lake" in f.parts:
            continue
        all_files.append(f)
    print(f"  Found {len(all_files)} .lean files (excluding .lake)")

    # Step 2: Hash and group
    print("Hashing files...")
    hash_groups = defaultdict(list)
    for f in all_files:
        h = hash_file(f)
        hash_groups[h].append(f)

    unique_count = len(hash_groups)
    dup_groups = {h: paths for h, paths in hash_groups.items() if len(paths) > 1}
    total_dupes = sum(len(paths) - 1 for paths in dup_groups.values())
    
    print(f"  {unique_count} unique file contents")
    print(f"  {len(dup_groups)} groups with duplicates")
    print(f"  {total_dupes} files to remove")

    # Step 3: Back up (only if not dry run)
    if not dry_run:
        print(f"\nBacking up Catalog to {BACKUP}...")
        if BACKUP.exists():
            print("  Backup already exists, skipping backup step")
        else:
            # Only back up .lean files to save space
            for f in all_files:
                rel = f.relative_to(CATALOG)
                dst = BACKUP / rel
                dst.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(f, dst)
            print(f"  Backed up {len(all_files)} files")

    # Step 4: Pick canonical and remove duplicates
    print("\nDeduplicating...")
    removed = 0
    kept_canonical = []
    
    for h, paths in dup_groups.items():
        canonical = pick_canonical(paths)
        kept_canonical.append(canonical)
        
        for p in paths:
            if p == canonical:
                continue
            rel = p.relative_to(CATALOG)
            can_rel = canonical.relative_to(CATALOG)
            
            if dry_run:
                if removed < 30:  # Only show first 30 in dry run
                    print(f"  REMOVE: {rel}")
                    print(f"    KEEP: {can_rel}")
            else:
                p.unlink()
            removed += 1

    print(f"\n  {'Would remove' if dry_run else 'Removed'}: {removed} duplicate files")
    print(f"  Kept: {unique_count} unique files")

    # Step 5: Clean up empty directories
    if not dry_run:
        print("\nCleaning empty directories...")
        cleaned = 0
        for dirpath in sorted(CATALOG.rglob("*"), reverse=True):
            if dirpath.is_dir() and ".lake" not in dirpath.parts:
                try:
                    if not any(dirpath.iterdir()):
                        dirpath.rmdir()
                        cleaned += 1
                except OSError:
                    pass
        print(f"  Removed {cleaned} empty directories")

    # Step 6: Final report
    if not dry_run:
        remaining = list(f for f in CATALOG.rglob("*.lean") if ".lake" not in f.parts)
        print(f"\n=== FINAL CATALOG STATE ===")
        print(f"  Total .lean files: {len(remaining)}")
        
        # Per-domain counts
        domain_counts = defaultdict(int)
        for f in remaining:
            rel = f.relative_to(CATALOG)
            top = rel.parts[0] if len(rel.parts) > 1 else "(root)"
            domain_counts[top] += 1
        
        for d, c in sorted(domain_counts.items(), key=lambda x: -x[1]):
            print(f"    {c:5d}  {d}")
    
    print("\nDone!")


if __name__ == "__main__":
    main()
