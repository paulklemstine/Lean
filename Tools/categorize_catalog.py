#!/usr/bin/env python3
"""Categorize loose Lean files into topic subdirectories and update import references.

Scans Catalog/{Domain}/*.lean for loose files (files sitting directly in any domain root).
Extracts topics from module headers, titles, and imports, maps them to existing
or derived topic subdirectories (Catalog/{Domain}/{Subcategory}/{Filename}.lean),
relocates the files, and updates all Lean import statements project-wide.
"""

import argparse
import os
import re
import shutil
import sys
from pathlib import Path
from collections import defaultdict

# Common topic keyword rules to map concepts to clean PascalCase subcategories
TOPIC_KEYWORDS = [
    (r'\b(ramsey|graph_coloring|chromatic|clique|independence_ratio)\b', 'RamseyTheory'),
    (r'\b(poset|order|width|antichain|dilworth|lattice)\b', 'PosetTheory'),
    (r'\b(neural|weight|activation|softplus|deep_learning|backprop)\b', 'NeuralCoding'),
    (r'\b(l_function|zeta|riemann|dirichlet|automorphic)\b', 'LFunctions'),
    (r'\b(hilbert|inner_product|banach|operator|spectral_radius)\b', 'HilbertSpace'),
    (r'\b(game|payoff|nash|equilibrium|strategy|play)\b', 'GameTheory'),
    (r'\b(braid|knot|link|jones_polynomial|homotopy)\b', 'KnotAndBraidTheory'),
    (r'\b(entropy|kolmogorov|information_theory|channel)\b', 'InformationTheory'),
    (r'\b(quantum|qubit|bb84|hamiltonian|schrodinger|entanglement)\b', 'QuantumSystems'),
    (r'\b(fluid|navier_stokes|euler_equation|viscosity|vorticity)\b', 'FluidDynamics'),
    (r'\b(collatz|syracuse|3x_plus_1)\b', 'CollatzConjecture'),
    (r'\b(berggren|pythagorean_triple|parent_descendant)\b', 'BerggrenTrees'),
    (r'\b(tropical|max_plus|min_plus|semiring)\b', 'TropicalAlgebra'),
    (r'\b(cipher|encrypt|hash|rsa|lattice_crypto|post_quantum)\b', 'Cryptography'),
    (r'\b(prime|factor|gcd|diophantine|congruence|fibonacci)\b', 'NumberTheory'),
    (r'\b(cellular_automaton|automata|turing|grid)\b', 'CellularAutomata'),
    (r'\b(graph|edge|vertex|tree|cycle|degree)\b', 'GraphTheory'),
    (r'\b(manifold|curvature|metric|geodesic|diffeomorphism)\b', 'DifferentialGeometry'),
    (r'\b(logic|kripke|modal|proof_complexity|paraconsistent)\b', 'ProofTheoryAndLogic'),
    (r'\b(probability|random|stochastic|martingale|variance)\b', 'ProbabilityAndStochastics'),
    (r'\b(group|ring|field|module|homomorphism|algebra)\b', 'AbstractAlgebra'),
]

GENERIC_SUBDIRS = {'speculative', 'shared', 'other', 'defs', 'core', 'general'}
SKIP_TOP_LEVEL = {'.lake', 'lake-packages', 'build', '.git', '__pycache__', 'node_modules'}

def pascal_case(s: str) -> str:
    """Convert string to clean PascalCase identifier."""
    s = re.sub(r'[^a-zA-Z0-9]+', ' ', s)
    words = [w.capitalize() for w in s.split() if w]
    res = "".join(words)
    return res or "General"

def extract_file_title_and_keywords(filepath: Path) -> tuple:
    """Extract docstring title and key mathematical terms from a .lean file."""
    title = ""
    content_sample = ""

    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            lines = f.readlines()[:100]
            text = "".join(lines)
            content_sample = text.lower()

            m = re.search(r'/[-!]*\s*#\s*(.+)', text)
            if m:
                title = m.group(1).strip()
            else:
                for line in lines:
                    line_s = line.strip()
                    if line_s.startswith('# '):
                        title = line_s[2:].strip()
                        break
    except Exception:
        pass

    return title, content_sample

def determine_subcategory(domain: str, fname: str, title: str, sample: str, existing_subdirs: list) -> str:
    """Determine the proper subcategory subdirectory for a loose lean file."""
    fname_stem = Path(fname).stem
    combined_text = f"{fname_stem} {title} {sample}".lower()

    # 1. Match predefined topic regexes first (most specific math topics)
    for pattern, cat_name in TOPIC_KEYWORDS:
        if re.search(pattern, combined_text, re.IGNORECASE):
            for sub in existing_subdirs:
                if sub.lower() == cat_name.lower():
                    return sub
            return cat_name

    # 2. Match non-generic existing subdirectories
    fname_lower = fname_stem.lower()
    for sub in existing_subdirs:
        if sub.lower() in GENERIC_SUBDIRS:
            continue
        if sub.lower() in fname_lower or sub.lower() in sample:
            return sub

    # 3. Derive a clean PascalCase topic name from title if available
    if title:
        clean_title = re.sub(r'\b(a|an|the|of|for|in|on|to|and|with|by|via|theorem|proof|framework|core|deepening|study)\b', '', title, flags=re.IGNORECASE)
        words = clean_title.split()[:3]
        derived = pascal_case(" ".join(words))
        if len(derived) >= 3 and len(derived) <= 30:
            return derived

    # 4. Fallback based on filename or generic existing subdirs
    derived_name = pascal_case(fname_stem)
    if derived_name and derived_name != "General":
        return derived_name

    for sub in existing_subdirs:
        if sub.lower() not in GENERIC_SUBDIRS:
            return sub

    return "GeneralTopics"

def scan_and_categorize(catalog_root: Path):
    """Scan all loose files in Catalog/ across all domain directories and assign subcategories."""
    loose_files = [] # (domain, rel_path, full_path)
    domain_subdirs = {}

    all_domains = [d.name for d in catalog_root.iterdir() if d.is_dir() and d.name not in SKIP_TOP_LEVEL]

    for domain in sorted(all_domains):
        dom_path = catalog_root / domain
        existing_subdirs = [d.name for d in dom_path.iterdir() if d.is_dir() and not d.name.startswith('.')]
        domain_subdirs[domain] = existing_subdirs

        for item in dom_path.iterdir():
            if item.is_file() and item.name.endswith('.lean'):
                loose_files.append((domain, item.relative_to(catalog_root), item))

    categorizations = [] # (src_path, target_rel_path, domain, subcategory, module_old, module_new)
    used_targets = set()

    for domain, rel_path, full_path in loose_files:
        title, sample = extract_file_title_and_keywords(full_path)
        subcat = determine_subcategory(domain, full_path.name, title, sample, domain_subdirs[domain])
        
        target_rel = Path(domain) / subcat / full_path.name
        
        counter = 1
        while (catalog_root / target_rel).exists() or str(target_rel) in used_targets:
            target_rel = Path(domain) / subcat / f"{full_path.stem}_{counter}.lean"
            counter += 1
            if counter > 50:
                break
                
        used_targets.add(str(target_rel))

        module_old = f"{domain}.{full_path.stem}"
        new_stem = target_rel.stem
        module_new = f"{domain}.{subcat}.{new_stem}"

        categorizations.append((full_path, catalog_root / target_rel, domain, subcat, module_old, module_new))

    return categorizations

def execute_categorization(catalog_root: Path, categorizations: list, apply: bool = False):
    """Move files into subcategories and refactor all Lean import statements."""
    print(f"[Categorization] Found {len(categorizations)} loose Lean files to categorize.")

    module_map = {}
    for src, dst, domain, subcat, mod_old, mod_new in categorizations:
        module_map[mod_old] = mod_new
        module_map[f"Catalog.{mod_old}"] = f"Catalog.{mod_new}"

    subcat_counts = defaultdict(int)
    for src, dst, domain, subcat, mod_old, mod_new in categorizations:
        subcat_counts[f"{domain}/{subcat}"] += 1

    print(f"[Categorization] Assigned across {len(subcat_counts)} subcategory folders.")

    if not apply:
        print("\n--- DRY RUN: Categorization Sample ---")
        for src, dst, domain, subcat, mod_old, mod_new in categorizations[:30]:
            print(f"  {src.name} -> {domain}/{subcat}/{dst.name}")
        if len(categorizations) > 30:
            print(f"  ... and {len(categorizations) - 30} more files.")
        print("\nRun with --apply to relocate files and update imports.")
        return

    # 1. Relocate files
    moved_count = 0
    for src, dst, domain, subcat, mod_old, mod_new in categorizations:
        if src.exists():
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(str(src), str(dst))
            moved_count += 1

    print(f"[Categorization] Moved {moved_count} files into subdirectories.")

    # 2. Refactor imports across all .lean files under Catalog/
    print("[Categorization] Refactoring import references across all Lean files...")
    all_lean_files = list(catalog_root.rglob("*.lean"))
    updated_files_count = 0

    for lean_path in all_lean_files:
        try:
            content = lean_path.read_text(encoding='utf-8', errors='replace')
            modified = False

            new_lines = []
            for line in content.splitlines(keepends=True):
                l_strip = line.strip()
                if l_strip.startswith('import '):
                    imp_target = l_strip[7:].strip()
                    if imp_target in module_map:
                        new_target = module_map[imp_target]
                        line = line.replace(imp_target, new_target)
                        modified = True
                new_lines.append(line)

            if modified:
                lean_path.write_text("".join(new_lines), encoding='utf-8')
                updated_files_count += 1
        except Exception as e:
            print(f"  [Warning] Failed to update imports in {lean_path}: {e}")

    print(f"[Categorization Complete]")
    print(f"  Files relocated: {moved_count}")
    print(f"  Import references updated across: {updated_files_count} Lean files")

def main():
    parser = argparse.ArgumentParser(description="Categorize loose Lean files into proper subdirectories")
    parser.add_argument('--catalog-root', default='Catalog', help="Catalog root directory")
    parser.add_argument('--apply', action='store_true', help="Execute file moves and import refactoring")
    args = parser.parse_args()

    catalog_root = Path(args.catalog_root).resolve()
    categorizations = scan_and_categorize(catalog_root)
    execute_categorization(catalog_root, categorizations, apply=args.apply)

if __name__ == '__main__':
    main()
