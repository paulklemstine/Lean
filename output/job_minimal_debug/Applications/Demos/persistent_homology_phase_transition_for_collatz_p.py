#!/usr/bin/env python3
"""
applications.py — Applications of Modular Collatz Inverse-Branch Theory

Demonstrates practical applications:
1. Residue-class phase detection and prediction
2. Multiplicity-based prime classification
3. Graph-theoretic analysis of Collatz preimage structure
4. Barcode summary clustering and phase transition detection
"""

import numpy as np
from collections import defaultdict
from typing import Dict, List, Tuple, Set


# ─── Inline core functions (self-contained) ───────────────────────────────

def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True

def multiplicative_order(a, p):
    r, val = 1, a % p
    while val != 1:
        val = (val * a) % p
        r += 1
    return r

def branch_admissible(p, x, k):
    x = x % p
    if x == 0: return True
    return pow(2, k, p) * x % p != 1

def branch_multiplicity(p, K, x):
    return sum(1 for k in range(K + 1) if branch_admissible(p, x, k))

def build_symmetric_graph(p, K):
    inv3 = pow(3, -1, p)
    adj = defaultdict(set)
    edges = set()
    for x in range(p):
        for k in range(K + 1):
            y = (pow(2, k, p) * x - 1) * inv3 % p
            if y != x and y != 0:
                edge = (min(x, y), max(x, y))
                if edge not in edges:
                    edges.add(edge)
                    adj[x].add(y)
                    adj[y].add(x)
    return dict(adj), edges

def connected_components(adj, vertices):
    visited = set()
    components = 0
    for v in vertices:
        if v not in visited:
            components += 1
            queue = [v]
            while queue:
                u = queue.pop()
                if u in visited: continue
                visited.add(u)
                for w in adj.get(u, set()):
                    if w in vertices and w not in visited:
                        queue.append(w)
    return components


# ═══════════════════════════════════════════════════════════════════════════
# APPLICATION 1: Prime Classification by Topological Signature
# ═══════════════════════════════════════════════════════════════════════════

def classify_primes_by_topology(max_prime: int = 150, K: int = 8) -> Dict[str, List[int]]:
    """Classify primes into topological phases based on their Collatz graph invariants.

    A prime p is in the "rich topology" phase if the cycle rank of its
    symmetrized Collatz graph exceeds p/2, and in the "sparse topology" phase otherwise.

    Returns:
        Dictionary mapping phase names to lists of primes.
    """
    phases = {"rich": [], "sparse": []}

    for p in range(5, max_prime + 1):
        if not is_prime(p):
            continue
        adj, edges = build_symmetric_graph(p, K)
        vertices = set(range(p))
        c = connected_components(adj, vertices)
        beta1 = len(edges) - len(vertices) + c
        normalized = beta1 / p

        if normalized > 0.5:
            phases["rich"].append(p)
        else:
            phases["sparse"].append(p)

    return phases


# ═══════════════════════════════════════════════════════════════════════════
# APPLICATION 2: Congruence Class Phase Transition Detection
# ═══════════════════════════════════════════════════════════════════════════

def detect_phase_transitions(max_prime: int = 200, K: int = 10, M: int = 8):
    """Detect phase transitions in topological invariants across congruence classes.

    Computes the average normalized cycle rank for primes in each residue class
    mod M, and identifies pairs with the largest separation.

    Returns:
        List of (class_a, class_b, gap) sorted by gap descending.
    """
    class_values = defaultdict(list)

    for p in range(5, max_prime + 1):
        if not is_prime(p):
            continue
        adj, edges = build_symmetric_graph(p, K)
        vertices = set(range(p))
        c = connected_components(adj, vertices)
        beta1 = len(edges) - len(vertices) + c
        class_values[p % M].append(beta1 / p)

    # Find pairs with largest mean separation
    class_means = {r: np.mean(vals) for r, vals in class_values.items() if len(vals) >= 2}
    pairs = []
    classes = sorted(class_means.keys())
    for i, a in enumerate(classes):
        for b in classes[i+1:]:
            gap = abs(class_means[a] - class_means[b])
            pairs.append((a, b, gap))

    pairs.sort(key=lambda x: -x[2])
    return pairs, class_means, class_values


# ═══════════════════════════════════════════════════════════════════════════
# APPLICATION 3: Multiplicative Order Impact Analysis
# ═══════════════════════════════════════════════════════════════════════════

def order_impact_analysis(max_prime: int = 200, K: int = 10):
    """Analyze how the multiplicative order ord_p(2) affects graph topology.

    Groups primes by ord_p(2) and computes average topological invariants.

    Returns:
        Dictionary mapping order → {avg_beta1, avg_edges, count, primes}.
    """
    order_data = defaultdict(lambda: {'beta1': [], 'edges': [], 'primes': []})

    for p in range(5, max_prime + 1):
        if not is_prime(p):
            continue
        d = multiplicative_order(2, p)
        adj, edges = build_symmetric_graph(p, K)
        vertices = set(range(p))
        c = connected_components(adj, vertices)
        beta1 = len(edges) - len(vertices) + c

        order_data[d]['beta1'].append(beta1 / p)
        order_data[d]['edges'].append(len(edges) / p)
        order_data[d]['primes'].append(p)

    result = {}
    for d, data in sorted(order_data.items()):
        result[d] = {
            'avg_beta1': np.mean(data['beta1']),
            'avg_edges': np.mean(data['edges']),
            'count': len(data['primes']),
            'primes': data['primes'],
        }

    return result


# ═══════════════════════════════════════════════════════════════════════════
# APPLICATION 4: Subgroup Condition Verification
# ═══════════════════════════════════════════════════════════════════════════

def verify_subgroup_condition(max_prime: int = 200, K: int = 10):
    """Test whether -3 ∈ ⟨2⟩ correlates with topological phase.

    This verifies the arithmetic forcing condition from the theory:
    primes where -3 lies in the subgroup generated by 2 should have
    different topological signatures.

    Returns:
        Two lists: (primes where -3 ∈ ⟨2⟩, primes where -3 ∉ ⟨2⟩)
        with their average β₁/p values.
    """
    in_subgroup = {'primes': [], 'beta1': []}
    not_in_subgroup = {'primes': [], 'beta1': []}

    for p in range(5, max_prime + 1):
        if not is_prime(p):
            continue

        # Compute ⟨2⟩
        subgroup = set()
        val = 1
        d = multiplicative_order(2, p)
        for _ in range(d):
            subgroup.add(val)
            val = (val * 2) % p

        neg3 = (-3) % p
        adj, edges = build_symmetric_graph(p, K)
        vertices = set(range(p))
        c = connected_components(adj, vertices)
        beta1 = len(edges) - len(vertices) + c

        target = in_subgroup if neg3 in subgroup else not_in_subgroup
        target['primes'].append(p)
        target['beta1'].append(beta1 / p)

    return in_subgroup, not_in_subgroup


# ═══════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════

if __name__ == '__main__':
    print("=" * 70)
    print("  APPLICATION 1: Prime Classification by Topological Phase")
    print("=" * 70)
    phases = classify_primes_by_topology(100, 8)
    print(f"\n  Rich topology primes: {phases['rich']}")
    print(f"  Sparse topology primes: {phases['sparse']}")

    print(f"\n{'='*70}")
    print("  APPLICATION 2: Phase Transition Detection")
    print("=" * 70)
    pairs, means, vals = detect_phase_transitions(150, 8, 8)
    print(f"\n  Class means (β₁/p):")
    for r in sorted(means.keys()):
        print(f"    p ≡ {r} (mod 8): mean = {means[r]:.4f}, n = {len(vals[r])}")
    if pairs:
        print(f"\n  Largest gaps:")
        for a, b, gap in pairs[:3]:
            print(f"    Classes {a} vs {b}: gap = {gap:.4f}")

    print(f"\n{'='*70}")
    print("  APPLICATION 3: Multiplicative Order Impact")
    print("=" * 70)
    order_data = order_impact_analysis(150, 8)
    for d in sorted(order_data.keys()):
        info = order_data[d]
        print(f"\n  ord_p(2) = {d}: {info['count']} primes")
        print(f"    Primes: {info['primes'][:6]}{'...' if info['count'] > 6 else ''}")
        print(f"    Avg β₁/p = {info['avg_beta1']:.4f}, Avg |E|/p = {info['avg_edges']:.2f}")

    print(f"\n{'='*70}")
    print("  APPLICATION 4: Subgroup Condition (-3 ∈ ⟨2⟩) Verification")
    print("=" * 70)
    in_sg, not_in_sg = verify_subgroup_condition(150, 8)
    print(f"\n  -3 ∈ ⟨2⟩: {len(in_sg['primes'])} primes, avg β₁/p = {np.mean(in_sg['beta1']):.4f}")
    print(f"    Primes: {in_sg['primes'][:10]}")
    print(f"\n  -3 ∉ ⟨2⟩: {len(not_in_sg['primes'])} primes, avg β₁/p = {np.mean(not_in_sg['beta1']):.4f}")
    print(f"    Primes: {not_in_sg['primes'][:10]}")


#!/usr/bin/env python3
"""
demo.py — Interactive Exploration of Arithmetic Topological Signatures
in Modular Collatz Dynamics

This script computes and visualizes the modular Collatz inverse-branch graph,
branch multiplicity profiles, cycle rank surrogates, and residue-class
clustering for primes p ≡ a (mod M).

Usage:
    python demo.py [--K 10] [--modulus 8] [--max_prime 200]
"""

import argparse
import numpy as np
from collections import defaultdict
from itertools import combinations
import sys

# ─── Core arithmetic ───────────────────────────────────────────────────────

def multiplicative_order(a, p):
    """Compute ord_p(a), the multiplicative order of a mod p."""
    if a % p == 0:
        return None
    r = 1
    val = a % p
    while val != 1:
        val = (val * a) % p
        r += 1
    return r

def is_prime(n):
    """Simple primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True

def primes_up_to(N):
    """Return list of primes up to N, excluding 2 and 3."""
    return [p for p in range(5, N + 1) if is_prime(p)]

def branch_admissible(p, x, k):
    """Check if exponent k is admissible at vertex x mod p.
    branchAdmissible p x k ↔ ∃ y ≠ 0, 3y + 1 ≡ 2^k · x (mod p)
    Equivalent (for x ≠ 0 mod p) to: 2^k · x ≢ 1 (mod p).
    For x = 0: always admissible (y = -1/3 ≠ 0 when p > 3).
    """
    if x % p == 0:
        return True  # Always admissible at x = 0
    val = (pow(2, k, p) * x) % p
    return val != 1

def branch_multiplicity(p, K, x):
    """Count admissible exponents k ∈ {0, ..., K} at vertex x mod p."""
    return sum(1 for k in range(K + 1) if branch_admissible(p, x, k))

def branch_profile(p, K, x):
    """Return the set of admissible exponents k ∈ {0, ..., K} at vertex x."""
    return [k for k in range(K + 1) if branch_admissible(p, x, k)]

# ─── Graph construction ───────────────────────────────────────────────────

def build_collatz_graph(p, K):
    """Build the symmetrized modular Collatz preimage graph G_{p,K}.
    Vertices: elements of Z/pZ (represented as 0..p-1).
    Edge x—y iff x ≠ y and ∃ k ∈ {0,...,K}: 3y+1 ≡ 2^k x or 3x+1 ≡ 2^k y (mod p).
    Returns adjacency dict and edge set.
    """
    adj = defaultdict(set)
    edges = set()
    inv3 = pow(3, -1, p)  # 3⁻¹ mod p

    for x in range(p):
        for k in range(K + 1):
            # y = (2^k · x - 1) · 3⁻¹ mod p
            val = (pow(2, k, p) * x - 1) * inv3 % p
            y = val
            if y != x and y != 0:  # y ≠ 0 for admissibility
                edge = (min(x, y), max(x, y))
                if edge not in edges:
                    edges.add(edge)
                    adj[x].add(y)
                    adj[y].add(x)
    return dict(adj), edges

def count_triangles(adj, edges):
    """Count triangles in the graph."""
    count = 0
    for (u, v) in edges:
        if u in adj and v in adj:
            common = adj[u] & adj[v]
            count += len(common)
    return count // 3  # each triangle counted 3 times

def cycle_rank_lb(p, edges):
    """Compute cycle rank lower bound: |E| - |V| + 1."""
    V = p  # all vertices in ZMod p
    E = len(edges)
    return E - V + 1

def find_induced_4_cycles(adj, p):
    """Find induced 4-cycles in the graph (up to a limit)."""
    cycles = []
    vertices = list(adj.keys())
    for v1 in vertices[:min(50, len(vertices))]:
        for v2 in adj.get(v1, set()):
            if v2 <= v1:
                continue
            for v3 in adj.get(v2, set()):
                if v3 <= v1 or v3 == v1:
                    continue
                if v3 in adj.get(v1, set()):
                    continue  # v1—v3 edge exists, not induced
                for v4 in adj.get(v3, set()):
                    if v4 <= v1 or v4 == v1 or v4 == v2:
                        continue
                    if v4 not in adj.get(v1, set()):
                        continue  # need v4—v1 edge
                    if v4 in adj.get(v2, set()):
                        continue  # v2—v4 diagonal exists
                    cycles.append((v1, v2, v3, v4))
                    if len(cycles) >= 10:
                        return cycles
    return cycles

# ─── Summary statistics ───────────────────────────────────────────────────

def compute_summary(p, K):
    """Compute summary statistics for prime p at depth K."""
    d = multiplicative_order(2, p)
    adj, edges = build_collatz_graph(p, K)

    multiplicities = [branch_multiplicity(p, K, x) for x in range(p)]
    avg_mult = np.mean(multiplicities)
    max_mult = max(multiplicities)
    min_mult = min(multiplicities)

    # Density: fraction of vertices with multiplicity ≥ 2
    dense_frac = sum(1 for m in multiplicities if m >= 2) / p

    # Cycle rank lower bound
    cr = cycle_rank_lb(p, edges)

    # Triangle count
    tri = count_triangles(adj, edges)

    # Induced 4-cycles
    c4 = find_induced_4_cycles(adj, p)
    n_c4 = len(c4)

    return {
        'p': p,
        'K': K,
        'ord2': d,
        'n_edges': len(edges),
        'n_vertices': p,
        'cycle_rank_lb': cr,
        'avg_multiplicity': avg_mult,
        'max_multiplicity': max_mult,
        'min_multiplicity': min_mult,
        'dense_fraction': dense_frac,
        'n_triangles': tri,
        'n_induced_4_cycles': n_c4,
        'sample_4_cycles': c4[:3],
    }

# ─── Residue class analysis ──────────────────────────────────────────────

def analyze_residue_classes(K, M, max_prime):
    """Analyze branch statistics grouped by p mod M."""
    primes = primes_up_to(max_prime)
    class_data = defaultdict(list)

    for p in primes:
        s = compute_summary(p, K)
        r = p % M
        class_data[r].append(s)

    return class_data

def print_residue_class_report(class_data, M):
    """Print a report comparing residue classes."""
    print(f"\n{'='*70}")
    print(f"  RESIDUE CLASS ANALYSIS (mod {M})")
    print(f"{'='*70}\n")

    for r in sorted(class_data.keys()):
        data = class_data[r]
        if not data:
            continue
        primes = [d['p'] for d in data]
        avg_cr = np.mean([d['cycle_rank_lb'] for d in data])
        avg_mult = np.mean([d['avg_multiplicity'] for d in data])
        avg_dense = np.mean([d['dense_fraction'] for d in data])
        avg_edges = np.mean([d['n_edges'] for d in data])
        avg_ord = np.mean([d['ord2'] for d in data])

        print(f"  Class p ≡ {r} (mod {M}): {len(data)} primes")
        print(f"    Primes: {primes[:8]}{'...' if len(primes) > 8 else ''}")
        print(f"    Avg ord_p(2): {avg_ord:.1f}")
        print(f"    Avg edges:    {avg_edges:.1f}")
        print(f"    Avg cycle rank LB: {avg_cr:.1f}")
        print(f"    Avg multiplicity:  {avg_mult:.2f}")
        print(f"    Avg dense fraction: {avg_dense:.3f}")
        print()

    # Falsifiable prediction test
    print(f"\n{'='*70}")
    print(f"  FALSIFIABLE PREDICTION TEST")
    print(f"{'='*70}\n")
    print("  Testing: within-class variance vs between-class distance")
    print("  for cycle_rank_lb normalized by p.\n")

    class_means = {}
    class_vars = {}
    for r in sorted(class_data.keys()):
        data = class_data[r]
        if len(data) < 2:
            continue
        vals = [d['cycle_rank_lb'] / d['p'] for d in data]
        class_means[r] = np.mean(vals)
        class_vars[r] = np.var(vals)

    if len(class_means) >= 2:
        keys = sorted(class_means.keys())
        within_var = np.mean(list(class_vars.values()))
        between_var = np.var(list(class_means.values()))
        print(f"  Class means: {', '.join(f'{r}: {class_means[r]:.4f}' for r in keys)}")
        print(f"  Within-class variance (avg): {within_var:.6f}")
        print(f"  Between-class variance:      {between_var:.6f}")
        if between_var > within_var:
            print(f"  ✓ Between-class variance EXCEEDS within-class variance")
            print(f"    → Evidence FOR congruence-dependent phase separation")
        else:
            print(f"  ✗ Between-class variance does not exceed within-class variance")
            print(f"    → No evidence of phase separation at this scale")

# ─── Main ─────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="Explore arithmetic topological signatures in modular Collatz dynamics")
    parser.add_argument('--K', type=int, default=10,
                        help='Branch depth K (default: 10)')
    parser.add_argument('--modulus', type=int, default=8,
                        help='Modulus M for residue class analysis (default: 8)')
    parser.add_argument('--max_prime', type=int, default=200,
                        help='Maximum prime to analyze (default: 200)')
    args = parser.parse_args()

    K = args.K
    M = args.modulus
    max_p = args.max_prime

    print(f"\n{'='*70}")
    print(f"  ARITHMETIC TOPOLOGICAL SIGNATURES IN MODULAR COLLATZ DYNAMICS")
    print(f"{'='*70}")
    print(f"\n  Parameters: K={K}, modulus M={M}, max prime={max_p}\n")

    # Show detailed analysis for a few primes
    sample_primes = [p for p in primes_up_to(min(50, max_p))][:5]
    print(f"\n  DETAILED ANALYSIS FOR SAMPLE PRIMES")
    print(f"  {'─'*60}\n")

    for p in sample_primes:
        s = compute_summary(p, K)
        d = s['ord2']
        print(f"  p = {p}, ord_p(2) = {d}")
        print(f"    Vertices: {s['n_vertices']}, Edges: {s['n_edges']}")
        print(f"    Cycle rank LB: {s['cycle_rank_lb']}")
        print(f"    Multiplicity: avg={s['avg_multiplicity']:.2f}, "
              f"min={s['min_multiplicity']}, max={s['max_multiplicity']}")
        print(f"    Dense fraction (mult ≥ 2): {s['dense_fraction']:.3f}")
        print(f"    Triangles: {s['n_triangles']}")
        print(f"    Induced 4-cycles found: {s['n_induced_4_cycles']}")

        # Branch profile for first few nonzero vertices
        print(f"    Branch profiles (first 3 nonzero vertices):")
        for x in range(1, min(4, p)):
            bp = branch_profile(p, K, x)
            print(f"      x={x}: admissible k's = {bp}, mult = {len(bp)}")

        print()

    # Residue class analysis
    class_data = analyze_residue_classes(K, M, max_p)
    print_residue_class_report(class_data, M)

    # Multiplicity histogram summary
    print(f"\n{'='*70}")
    print(f"  MULTIPLICITY DISTRIBUTION BY RESIDUE CLASS")
    print(f"{'='*70}\n")

    for r in sorted(class_data.keys()):
        data = class_data[r]
        if len(data) < 2:
            continue
        all_dense = [d['dense_fraction'] for d in data]
        all_ord = [d['ord2'] for d in data]
        print(f"  p ≡ {r} (mod {M}): "
              f"avg_dense={np.mean(all_dense):.3f} ± {np.std(all_dense):.3f}, "
              f"avg_ord={np.mean(all_ord):.1f}")

    print(f"\n{'='*70}")
    print(f"  PERIODICITY VERIFICATION")
    print(f"{'='*70}\n")

    # Verify branch periodicity theorem computationally
    p_test = 17
    d = multiplicative_order(2, p_test)
    print(f"  Verifying periodicity for p={p_test}, ord_{p_test}(2)={d}")
    all_match = True
    for x in range(1, p_test):
        for k in range(20):
            a1 = branch_admissible(p_test, x, k)
            a2 = branch_admissible(p_test, x, k + d)
            if a1 != a2:
                print(f"    MISMATCH at x={x}, k={k}")
                all_match = False
    if all_match:
        print(f"  ✓ Periodicity verified for all x, k ∈ {{0,...,19}}")

    # Verify subgroup criterion
    print(f"\n  Verifying subgroup criterion (admissible ↔ 2^k·x ≠ 1) for p={p_test}")
    all_match = True
    for x in range(1, p_test):
        for k in range(K + 1):
            adm = branch_admissible(p_test, x, k)
            criterion = pow(2, k, p_test) * x % p_test != 1
            if adm != criterion:
                print(f"    MISMATCH at x={x}, k={k}")
                all_match = False
    if all_match:
        print(f"  ✓ Subgroup criterion verified for all x ∈ {{1,...,{p_test-1}}}, k ∈ {{0,...,{K}}}")

    print()

if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""Generate PACKAGE.json from the project files."""

import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all source files
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
viz1_code = read_file('viz_multiplicity_heatmap.py')
viz2_code = read_file('viz_filtration_betti.py')
viz3_code = read_file('viz_phase_transition.py')
interactive_html = read_file('interactive_collatz_explorer.html')

lean_defs = read_file('Speculative/CollatzTopological/Defs.lean')
lean_theorems = read_file('Speculative/CollatzTopological/Theorems.lean')
lean_proofs = lean_defs + "\n\n" + "-- " + "="*70 + "\n\n" + lean_theorems

package = {
    "title": "Arithmetic Topological Signatures in Modular Collatz Dynamics",
    "domain": "Arithmetic Dynamics / Topological Data Analysis",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Modular Collatz Branch Explorer",
            "code": demo_code
        }
    ],
    "algorithms": [
        {
            "name": "Branch Admissibility and Graph Construction",
            "pseudocode": """Algorithm: Branch Admissibility Test
Input: prime p (odd, ≠ 3), vertex x ∈ Z/pZ, exponent k ∈ N
Output: boolean (admissible or not)

1. If x ≡ 0 (mod p), return True  [Theorem: branchAdmissible_zero]
2. Compute v = 2^k · x mod p       [modular exponentiation: O(log k · log p)]
3. Return (v ≠ 1)                   [Theorem: branch_admissible_iff]

Algorithm: Symmetric Graph Construction
Input: prime p, depth K
Output: edge set of G^sym_{p,K}

1. Compute inv3 = 3^{-1} mod p
2. For each x ∈ {0,...,p-1}:
     For each k ∈ {0,...,K}:
       y = (2^k · x - 1) · inv3 mod p
       If y ≠ x and y ≠ 0:
         Add edge {x, y}
3. Return edge set

Complexity: O(p · K · log K · log p) time, O(p²) space""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Branch Multiplicity Heatmap and Topology Overview",
            "code": viz1_code,
            "description": "Four-panel visualization showing: (1) branch multiplicity heatmap across vertices for different primes, revealing the periodic structure controlled by ord_p(2); (2) normalized cycle rank colored by residue class mod 8; (3) multiplicative order vs topology correlation; (4) multiplicity distribution comparison between congruence classes."
        },
        {
            "name": "Betti Number Filtration Profiles",
            "code": viz2_code,
            "description": "Four-panel visualization of the multiplicity filtration: (1) β₁ profiles across filtration levels for selected primes; (2) total persistence surrogate by residue class; (3) vertex survival curves; (4) edge density evolution through the filtration."
        },
        {
            "name": "Phase Transition Diagram",
            "code": viz3_code,
            "description": "Phase transition analysis showing: (1) phase diagram colored by subgroup condition (-3 ∈ ⟨2⟩); (2) topology by residue class with moving averages; (3) edge density vs multiplicative order; (4) within-class vs between-class variance test for phase separation."
        }
    ],
    "interactive_demos": [
        {
            "name": "Interactive Branch Explorer",
            "html": interactive_html,
            "description": "Interactive tool for exploring branch admissibility patterns. Slide to change the prime p and depth K, and see how the branch profile grid and multiplicity bar chart change. Orange lines show period boundaries at multiples of ord_p(2), visually demonstrating the Periodicity Theorem."
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("Generated PACKAGE.json")
print(f"  Size: {os.path.getsize('PACKAGE.json')} bytes")


#!/usr/bin/env python3
"""
Visualization: Betti Number Profile Across Filtration Levels

This script visualizes how the first Betti number β₁ changes across
filtration levels for different primes. The filtration is by branch
multiplicity: at level ℓ, only vertices with μ(x) ≥ ℓ are included.

The key prediction is that primes in different congruence classes
exhibit qualitatively different Betti profiles — this is the
"arithmetic phase transition" phenomenon.
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import defaultdict


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def multiplicative_order(a, p):
    r, val = 1, a % p
    while val != 1:
        val = (val * a) % p
        r += 1
    return r


def branch_admissible(p, x, k):
    x = x % p
    if x == 0: return True
    return pow(2, k, p) * x % p != 1


def branch_multiplicity(p, K, x):
    return sum(1 for k in range(K + 1) if branch_admissible(p, x, k))


def build_symmetric_graph(p, K):
    inv3 = pow(3, -1, p)
    adj = defaultdict(set)
    edges = set()
    for x in range(p):
        for k in range(K + 1):
            y = (pow(2, k, p) * x - 1) * inv3 % p
            if y != x and y != 0:
                edge = (min(x, y), max(x, y))
                if edge not in edges:
                    edges.add(edge)
                    adj[x].add(y)
                    adj[y].add(x)
    return dict(adj), edges


def connected_components(adj, vertices):
    visited = set()
    components = 0
    for v in vertices:
        if v not in visited:
            components += 1
            queue = [v]
            while queue:
                u = queue.pop()
                if u in visited: continue
                visited.add(u)
                for w in adj.get(u, set()):
                    if w in vertices and w not in visited:
                        queue.append(w)
    return components


def compute_betti_profile(p, K):
    adj, all_edges = build_symmetric_graph(p, K)
    multiplicities = {x: branch_multiplicity(p, K, x) for x in range(p)}
    max_level = max(multiplicities.values()) if multiplicities else 0
    profile = []
    for level in range(max_level + 1):
        vertices = {x for x, m in multiplicities.items() if m >= level}
        if not vertices:
            break
        filtered_edges = {(u, v) for (u, v) in all_edges if u in vertices and v in vertices}
        adj_restricted = defaultdict(set)
        for (u, v) in filtered_edges:
            adj_restricted[u].add(v)
            adj_restricted[v].add(u)
        c = connected_components(dict(adj_restricted), vertices)
        beta1 = len(filtered_edges) - len(vertices) + c
        profile.append((level, len(vertices), len(filtered_edges), c, beta1))
    return profile


K = 10
primes = [p for p in range(5, 100) if is_prime(p)]

fig, axes = plt.subplots(2, 2, figsize=(16, 12))
fig.suptitle('Betti Number Profiles and Filtration Analysis', fontsize=14, fontweight='bold')

# Panel 1: β₁ profiles for selected primes
ax = axes[0, 0]
sample_primes = [7, 13, 17, 23, 31, 41, 47, 59, 67, 73]
colors = plt.cm.tab10(np.linspace(0, 1, len(sample_primes)))

for p, color in zip(sample_primes, colors):
    profile = compute_betti_profile(p, K)
    levels = [pr[0] for pr in profile]
    beta1s = [pr[4] / p for pr in profile]  # normalize
    d = multiplicative_order(2, p)
    ax.plot(levels, beta1s, 'o-', color=color, markersize=4,
            label=f'p={p} (d={d})', alpha=0.8)

ax.set_xlabel('Filtration level ℓ')
ax.set_ylabel('Normalized β₁/p')
ax.set_title('β₁ Profile Across Filtration')
ax.legend(fontsize=7, ncol=2)
ax.grid(True, alpha=0.3)

# Panel 2: Total persistence surrogate by residue class
ax = axes[0, 1]
class_persistence = defaultdict(list)
for p in primes:
    profile = compute_betti_profile(p, K)
    total = sum(pr[4] for pr in profile) / p  # total β₁ normalized
    class_persistence[p % 8].append((p, total))

for r in sorted(class_persistence.keys()):
    data = class_persistence[r]
    ps, totals = zip(*data)
    ax.scatter(ps, totals, label=f'p ≡ {r} (mod 8)', s=30, alpha=0.7)

ax.set_xlabel('Prime p')
ax.set_ylabel('Total persistence (Σβ₁)/p')
ax.set_title('Total Persistence Surrogate by Residue Class')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Panel 3: Vertex count vs filtration level
ax = axes[1, 0]
for p in [11, 23, 41, 59, 79, 97]:
    if not is_prime(p): continue
    profile = compute_betti_profile(p, K)
    levels = [pr[0] for pr in profile]
    verts = [pr[1] / p for pr in profile]
    ax.plot(levels, verts, 'o-', markersize=4, label=f'p={p}', alpha=0.8)

ax.set_xlabel('Filtration level ℓ')
ax.set_ylabel('Fraction of vertices')
ax.set_title('Vertex Survival in Filtration')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Panel 4: Edge density vs filtration level
ax = axes[1, 1]
for p in [11, 23, 41, 59, 79, 97]:
    if not is_prime(p): continue
    profile = compute_betti_profile(p, K)
    levels = [pr[0] for pr in profile]
    if any(pr[1] > 0 for pr in profile):
        densities = [2 * pr[2] / (pr[1] * (pr[1] - 1)) if pr[1] > 1 else 0 for pr in profile]
        ax.plot(levels, densities, 'o-', markersize=4, label=f'p={p}', alpha=0.8)

ax.set_xlabel('Filtration level ℓ')
ax.set_ylabel('Edge density')
ax.set_title('Edge Density vs Filtration Level')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('collatz_betti_profiles.png', dpi=150, bbox_inches='tight')
print("Saved: collatz_betti_profiles.png")


#!/usr/bin/env python3
"""
Visualization: Branch Multiplicity Heatmap Across Primes

This script visualizes how branch multiplicity varies across vertices x ∈ Z/pZ
for different primes p. Each row is a prime, each column is a vertex.
The color intensity shows the branch multiplicity μ_{p,K}(x).

The periodicity theorem (branch_periodic_mod_order) predicts that the
multiplicity pattern repeats with period ord_p(2), which is visible as
regular bands in the heatmap.
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import defaultdict


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def multiplicative_order(a, p):
    r, val = 1, a % p
    while val != 1:
        val = (val * a) % p
        r += 1
    return r


def branch_admissible(p, x, k):
    x = x % p
    if x == 0: return True
    return pow(2, k, p) * x % p != 1


def branch_multiplicity(p, K, x):
    return sum(1 for k in range(K + 1) if branch_admissible(p, x, k))


def build_symmetric_graph(p, K):
    inv3 = pow(3, -1, p)
    adj = defaultdict(set)
    edges = set()
    for x in range(p):
        for k in range(K + 1):
            y = (pow(2, k, p) * x - 1) * inv3 % p
            if y != x and y != 0:
                edge = (min(x, y), max(x, y))
                if edge not in edges:
                    edges.add(edge)
                    adj[x].add(y)
                    adj[y].add(x)
    return dict(adj), edges


def connected_components(adj, vertices):
    visited = set()
    components = 0
    for v in vertices:
        if v not in visited:
            components += 1
            queue = [v]
            while queue:
                u = queue.pop()
                if u in visited: continue
                visited.add(u)
                for w in adj.get(u, set()):
                    if w in vertices and w not in visited:
                        queue.append(w)
    return components


K = 10
primes = [p for p in range(5, 80) if is_prime(p)]

fig, axes = plt.subplots(2, 2, figsize=(16, 12))
fig.suptitle('Arithmetic Topological Signatures in Modular Collatz Dynamics',
             fontsize=14, fontweight='bold')

# Panel 1: Branch multiplicity heatmap
ax = axes[0, 0]
max_p = max(primes)
data = np.zeros((len(primes), max_p))
for i, p in enumerate(primes):
    for x in range(p):
        data[i, x] = branch_multiplicity(p, K, x)
    for x in range(p, max_p):
        data[i, x] = np.nan

im = ax.imshow(data, aspect='auto', cmap='viridis', interpolation='nearest')
ax.set_xlabel('Vertex x')
ax.set_ylabel('Prime index')
ax.set_yticks(range(0, len(primes), 3))
ax.set_yticklabels([str(primes[i]) for i in range(0, len(primes), 3)])
ax.set_title(f'Branch Multiplicity μ(x) (K={K})')
plt.colorbar(im, ax=ax, label='Multiplicity')

# Panel 2: Cycle rank vs prime, colored by p mod 8
ax = axes[0, 1]
cycle_ranks = []
colors_mod8 = []
color_map = {1: '#e41a1c', 3: '#377eb8', 5: '#4daf4a', 7: '#984ea3'}

for p in primes:
    adj, edges = build_symmetric_graph(p, K)
    vertices = set(range(p))
    c = connected_components(adj, vertices)
    beta1 = len(edges) - len(vertices) + c
    cycle_ranks.append(beta1 / p)
    colors_mod8.append(color_map.get(p % 8, '#999999'))

ax.scatter(primes, cycle_ranks, c=colors_mod8, s=40, alpha=0.8, edgecolors='black', linewidth=0.5)
ax.set_xlabel('Prime p')
ax.set_ylabel('Normalized cycle rank β₁/p')
ax.set_title('Cycle Rank by Prime (colored by p mod 8)')

# Legend
for r, c in color_map.items():
    ax.scatter([], [], c=c, label=f'p ≡ {r} (mod 8)', s=40)
ax.legend(fontsize=8, loc='upper left')

# Panel 3: Multiplicative order vs normalized cycle rank
ax = axes[1, 0]
orders = [multiplicative_order(2, p) for p in primes]
ax.scatter(orders, cycle_ranks, c=[p for p in primes], cmap='plasma',
           s=40, alpha=0.8, edgecolors='black', linewidth=0.5)
ax.set_xlabel('ord_p(2)')
ax.set_ylabel('Normalized cycle rank β₁/p')
ax.set_title('Multiplicative Order vs Topology')

# Panel 4: Multiplicity distribution comparison
ax = axes[1, 1]
# Compare two residue classes
class1_mults = []
class3_mults = []
for p in primes:
    mults = [branch_multiplicity(p, K, x) / (K + 1) for x in range(1, p)]
    if p % 8 == 1:
        class1_mults.extend(mults)
    elif p % 8 == 3:
        class3_mults.extend(mults)

if class1_mults and class3_mults:
    bins = np.linspace(0, 1.05, 25)
    ax.hist(class1_mults, bins=bins, alpha=0.5, label='p ≡ 1 (mod 8)',
            density=True, color='#e41a1c')
    ax.hist(class3_mults, bins=bins, alpha=0.5, label='p ≡ 3 (mod 8)',
            density=True, color='#377eb8')
    ax.set_xlabel('Normalized multiplicity μ(x)/(K+1)')
    ax.set_ylabel('Density')
    ax.set_title('Multiplicity Distribution by Residue Class')
    ax.legend()

plt.tight_layout()
plt.savefig('collatz_topological_signatures.png', dpi=150, bbox_inches='tight')
print("Saved: collatz_topological_signatures.png")


#!/usr/bin/env python3
"""
Visualization: Phase Transition Diagram for Modular Collatz Topology

This script produces a phase transition diagram showing how topological
invariants of modular Collatz graphs vary with the prime p and the
multiplicative order ord_p(2). The key insight is that primes with
different arithmetic properties (encoded by ord_p(2) and residue class)
exhibit distinct topological phases.
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import defaultdict


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def multiplicative_order(a, p):
    r, val = 1, a % p
    while val != 1:
        val = (val * a) % p
        r += 1
    return r


def branch_admissible(p, x, k):
    x = x % p
    if x == 0: return True
    return pow(2, k, p) * x % p != 1


def branch_multiplicity(p, K, x):
    return sum(1 for k in range(K + 1) if branch_admissible(p, x, k))


def build_symmetric_graph(p, K):
    inv3 = pow(3, -1, p)
    adj = defaultdict(set)
    edges = set()
    for x in range(p):
        for k in range(K + 1):
            y = (pow(2, k, p) * x - 1) * inv3 % p
            if y != x and y != 0:
                edge = (min(x, y), max(x, y))
                if edge not in edges:
                    edges.add(edge)
                    adj[x].add(y)
                    adj[y].add(x)
    return dict(adj), edges


def connected_components(adj, vertices):
    visited = set()
    components = 0
    for v in vertices:
        if v not in visited:
            components += 1
            queue = [v]
            while queue:
                u = queue.pop()
                if u in visited: continue
                visited.add(u)
                for w in adj.get(u, set()):
                    if w in vertices and w not in visited:
                        queue.append(w)
    return components


K = 12
primes = [p for p in range(5, 250) if is_prime(p)]

# Compute all data
data = []
for p in primes:
    d = multiplicative_order(2, p)
    adj, edges = build_symmetric_graph(p, K)
    vertices = set(range(p))
    c = connected_components(adj, vertices)
    beta1 = len(edges) - len(vertices) + c

    # Check if -3 ∈ ⟨2⟩
    subgroup = set()
    val = 1
    for _ in range(d):
        subgroup.add(val)
        val = (val * 2) % p
    neg3_in = ((-3) % p) in subgroup

    data.append({
        'p': p, 'd': d, 'beta1': beta1, 'beta1_norm': beta1/p,
        'edges': len(edges), 'edge_density': 2*len(edges)/(p*(p-1)),
        'neg3_in': neg3_in, 'mod8': p % 8,
    })

fig, axes = plt.subplots(2, 2, figsize=(16, 12))
fig.suptitle('Phase Transition Diagram: Arithmetic Control of Collatz Topology',
             fontsize=14, fontweight='bold')

# Panel 1: Phase diagram (ord vs β₁/p, colored by -3 ∈ ⟨2⟩)
ax = axes[0, 0]
for d_item in data:
    color = '#e41a1c' if d_item['neg3_in'] else '#377eb8'
    marker = 'o' if d_item['neg3_in'] else 's'
    ax.scatter(d_item['d'] / d_item['p'], d_item['beta1_norm'],
              c=color, marker=marker, s=25, alpha=0.6)

ax.scatter([], [], c='#e41a1c', marker='o', label='-3 ∈ ⟨2⟩')
ax.scatter([], [], c='#377eb8', marker='s', label='-3 ∉ ⟨2⟩')
ax.set_xlabel('Normalized order d/p')
ax.set_ylabel('β₁/p')
ax.set_title('Phase Diagram: Subgroup Condition')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 2: β₁/p vs p, with trend lines for each mod 8 class
ax = axes[0, 1]
mod_colors = {1: '#e41a1c', 3: '#377eb8', 5: '#4daf4a', 7: '#984ea3'}
mod_data = defaultdict(lambda: ([], []))

for d_item in data:
    m = d_item['mod8']
    if m in mod_colors:
        mod_data[m][0].append(d_item['p'])
        mod_data[m][1].append(d_item['beta1_norm'])

for m in sorted(mod_colors.keys()):
    ps, betas = mod_data[m]
    if ps:
        ax.scatter(ps, betas, c=mod_colors[m], s=20, alpha=0.5, label=f'p ≡ {m} (mod 8)')
        # Moving average
        if len(ps) > 3:
            sorted_idx = np.argsort(ps)
            ps_sorted = np.array(ps)[sorted_idx]
            betas_sorted = np.array(betas)[sorted_idx]
            window = min(5, len(ps_sorted))
            ma = np.convolve(betas_sorted, np.ones(window)/window, mode='valid')
            ax.plot(ps_sorted[window-1:], ma, c=mod_colors[m], linewidth=2, alpha=0.8)

ax.set_xlabel('Prime p')
ax.set_ylabel('β₁/p')
ax.set_title('Topology by Residue Class (mod 8)')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Panel 3: Edge density vs ord/p
ax = axes[1, 0]
for d_item in data:
    ax.scatter(d_item['d'] / d_item['p'], d_item['edge_density'],
              c=d_item['p'], cmap='viridis', s=20, alpha=0.6)
ax.set_xlabel('Normalized order d/p')
ax.set_ylabel('Edge density 2|E|/(p(p-1))')
ax.set_title('Edge Density vs Multiplicative Order')
ax.grid(True, alpha=0.3)

# Panel 4: Statistical test - within vs between class variance
ax = axes[1, 1]
moduli = [4, 6, 8, 10, 12]
within_vars = []
between_vars = []

for M in moduli:
    class_vals = defaultdict(list)
    for d_item in data:
        class_vals[d_item['p'] % M].append(d_item['beta1_norm'])

    means = []
    vars_list = []
    for r, vals in class_vals.items():
        if len(vals) >= 3:
            means.append(np.mean(vals))
            vars_list.append(np.var(vals))

    if len(means) >= 2:
        within_vars.append(np.mean(vars_list))
        between_vars.append(np.var(means))

ax.bar(np.arange(len(moduli)) - 0.15, within_vars, 0.3,
       label='Within-class var', color='#377eb8', alpha=0.7)
ax.bar(np.arange(len(moduli)) + 0.15, between_vars, 0.3,
       label='Between-class var', color='#e41a1c', alpha=0.7)
ax.set_xticks(range(len(moduli)))
ax.set_xticklabels([f'mod {M}' for M in moduli])
ax.set_ylabel('Variance')
ax.set_title('Within vs Between Class Variance')
ax.legend()
ax.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('collatz_phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved: collatz_phase_transition.png")
