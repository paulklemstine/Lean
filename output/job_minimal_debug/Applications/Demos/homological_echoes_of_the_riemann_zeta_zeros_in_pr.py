#!/usr/bin/env python3
"""
Prime Window Complex: Applications

Demonstrates real-world applications of the prime gap complex theory:
1. Model discrimination: distinguishing primes from random surrogates
2. Prime gap structure detection via topological statistics
3. Scale-dependent arithmetic-topological profiles
"""

import math
import random
from collections import defaultdict
from itertools import combinations
from typing import Dict, List, Set, Tuple


# ─────────────────────────────────────────────────────────────────────────────
# Core utilities (self-contained)
# ─────────────────────────────────────────────────────────────────────────────

def sieve(limit):
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]

def primes_in_window(n, L):
    all_p = set(sieve(n + L))
    return sorted(p for p in all_p if n <= p <= n + L - 1)

def build_graph(primes, S):
    prime_set = set(primes)
    edges = set()
    adj = defaultdict(set)
    for p in primes:
        for h in S:
            q = p + h
            if q in prime_set:
                edges.add(frozenset([p, q]))
                adj[p].add(q)
                adj[q].add(p)
    return edges, dict(adj)

def count_triangles(primes, adj):
    count = 0
    for i, p in enumerate(primes):
        for j in range(i+1, len(primes)):
            q = primes[j]
            if q not in adj.get(p, set()):
                continue
            for k in range(j+1, len(primes)):
                r = primes[k]
                if r in adj.get(p, set()) and r in adj.get(q, set()):
                    count += 1
    return count

def topological_summary(primes, S):
    edges, adj = build_graph(primes, S)
    V = len(primes)
    E = len(edges)
    T = count_triangles(primes, adj)
    chi = V - E + T
    return {'V': V, 'E': E, 'T': T, 'chi': chi}


# ─────────────────────────────────────────────────────────────────────────────
# Application 1: Model Discrimination
# ─────────────────────────────────────────────────────────────────────────────

def model_discrimination_test(
    windows: List[Tuple[int, int]],
    S: Set[int],
    num_samples: int = 500
) -> Dict:
    """
    Test whether topological statistics can distinguish actual primes
    from random surrogate models.
    
    Models compared:
    1. Actual primes (ground truth)
    2. Cramér random model: Bernoulli(1/ln(n)) at each integer
    3. Residue-constrained model: Bernoulli on odd integers only
    
    Returns statistics for each model and discrimination metrics.
    """
    results = {'actual': [], 'cramer': [], 'residue': []}
    
    for n, L in windows:
        # Actual primes
        actual_primes = primes_in_window(n, L)
        actual_stats = topological_summary(actual_primes, S)
        results['actual'].append(actual_stats)
        
        # Cramér model: each integer prime with prob 1/ln(n)
        p_cramer = 1 / math.log(max(n, 3))
        cramer_chis = []
        cramer_edges = []
        random.seed(42 + n)
        for _ in range(num_samples):
            fake_primes = sorted(
                x for x in range(n, n + L)
                if random.random() < p_cramer
            )
            if fake_primes:
                stats = topological_summary(fake_primes, S)
                cramer_chis.append(stats['chi'])
                cramer_edges.append(stats['E'])
        
        results['cramer'].append({
            'mean_chi': sum(cramer_chis)/max(len(cramer_chis),1),
            'mean_E': sum(cramer_edges)/max(len(cramer_edges),1),
            'std_chi': (sum((x - sum(cramer_chis)/max(len(cramer_chis),1))**2 
                        for x in cramer_chis)/max(len(cramer_chis),1))**0.5 if cramer_chis else 0,
        })
        
        # Residue-constrained model: only odd numbers, with adjusted density
        p_residue = 2 / math.log(max(n, 3))  # doubled since only considering odds
        residue_chis = []
        random.seed(42 + n)
        for _ in range(num_samples):
            fake_primes = sorted(
                x for x in range(n, n + L)
                if x % 2 == 1 and random.random() < p_residue
            )
            if n <= 2 < n + L:
                if random.random() < 0.5:
                    fake_primes = sorted(set(fake_primes) | {2})
            if fake_primes:
                stats = topological_summary(fake_primes, S)
                residue_chis.append(stats['chi'])
        
        results['residue'].append({
            'mean_chi': sum(residue_chis)/max(len(residue_chis),1),
            'std_chi': (sum((x - sum(residue_chis)/max(len(residue_chis),1))**2 
                        for x in residue_chis)/max(len(residue_chis),1))**0.5 if residue_chis else 0,
        })
    
    return results


# ─────────────────────────────────────────────────────────────────────────────
# Application 2: Gap Structure Detection
# ─────────────────────────────────────────────────────────────────────────────

def detect_gap_structure(n: int, L: int, max_gap: int = 30) -> Dict:
    """
    Use the filtration profile to detect structural features in the 
    prime gap distribution within a window.
    
    Returns the filtration profile and detected features.
    """
    primes = primes_in_window(n, L)
    prime_set = set(primes)
    
    # Compute pair counts for each even gap
    gap_counts = {}
    for h in range(2, max_gap + 1, 2):
        count = sum(1 for p in primes if p + h in prime_set)
        gap_counts[h] = count
    
    # Filtration profile
    profile = []
    for t in range(2, max_gap + 1, 2):
        S = set(range(2, t + 1, 2))
        stats = topological_summary(primes, S)
        profile.append({'max_gap': t, **stats})
    
    # Detect features: where does χ change sign? Where do triangles first appear?
    features = {
        'first_triangle_gap': None,
        'chi_sign_changes': [],
        'gap_richness': gap_counts,
    }
    
    prev_chi = None
    for entry in profile:
        if entry['T'] > 0 and features['first_triangle_gap'] is None:
            features['first_triangle_gap'] = entry['max_gap']
        if prev_chi is not None and prev_chi * entry['chi'] < 0:
            features['chi_sign_changes'].append(entry['max_gap'])
        prev_chi = entry['chi']
    
    features['profile'] = profile
    return features


# ─────────────────────────────────────────────────────────────────────────────
# Application 3: Scale-Dependent Analysis
# ─────────────────────────────────────────────────────────────────────────────

def scale_analysis(
    base_windows: List[int],
    L_func=None,
    S: Set[int] = None
) -> List[Dict]:
    """
    Analyze how topological statistics scale with the position in the number line.
    
    For each starting point n, computes the prime gap complex with
    window length L(n) = ⌊n^0.5⌋ and gap set S = {2, 4, 6}.
    """
    if L_func is None:
        L_func = lambda n: max(int(n**0.5), 10)
    if S is None:
        S = {2, 4, 6}
    
    results = []
    for n in base_windows:
        L = L_func(n)
        primes = primes_in_window(n, L)
        
        if not primes:
            continue
            
        stats = topological_summary(primes, S)
        density = len(primes) / L
        expected_density = 1 / math.log(max(n, 3))
        
        # Bernoulli prediction
        p = density
        E_edges = p**2 * sum(max(L - h, 0) for h in S)
        
        results.append({
            'n': n,
            'L': L,
            'density': density,
            'expected_density': expected_density,
            **stats,
            'bernoulli_edges': E_edges,
            'edge_excess': stats['E'] - E_edges,
            'normalized_chi': stats['chi'] / max(stats['V'], 1),
        })
    
    return results


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATION 1: Model Discrimination")
    print("=" * 70)
    
    windows = [(100, 100), (1000, 150), (5000, 200)]
    S = {2, 4, 6, 8, 10}
    results = model_discrimination_test(windows, S, num_samples=300)
    
    for i, (n, L) in enumerate(windows):
        actual = results['actual'][i]
        cramer = results['cramer'][i]
        residue = results['residue'][i]
        print(f"\nWindow [{n}, {n+L-1}]:")
        print(f"  Actual:  χ={actual['chi']}, E={actual['E']}")
        print(f"  Cramér:  E[χ]={cramer['mean_chi']:.1f} ± {cramer['std_chi']:.1f}, "
              f"E[E]={cramer['mean_E']:.1f}")
        print(f"  Residue: E[χ]={residue['mean_chi']:.1f} ± {residue['std_chi']:.1f}")
    
    print("\n" + "=" * 70)
    print("APPLICATION 2: Gap Structure Detection")
    print("=" * 70)
    
    features = detect_gap_structure(1000, 200)
    print(f"\nWindow [1000, 1199]:")
    print(f"  First triangle appears at max_gap = {features['first_triangle_gap']}")
    print(f"  Gap counts: {dict(sorted(features['gap_richness'].items()))}")
    print(f"  χ sign changes at: {features['chi_sign_changes']}")
    print(f"\n  Filtration profile:")
    for entry in features['profile']:
        print(f"    max_gap={entry['max_gap']:>2}: V={entry['V']:>3}, "
              f"E={entry['E']:>3}, T={entry['T']:>3}, χ={entry['chi']:>4}")
    
    print("\n" + "=" * 70)
    print("APPLICATION 3: Scale-Dependent Analysis")
    print("=" * 70)
    
    base_windows = [100, 500, 1000, 5000, 10000, 50000]
    scale_results = scale_analysis(base_windows)
    
    print(f"\n{'n':>8} | {'L':>4} | {'V':>4} | {'E':>4} | {'T':>3} | {'χ':>4} | "
          f"{'density':>7} | {'edge_excess':>11}")
    print("-" * 75)
    for r in scale_results:
        print(f"{r['n']:>8} | {r['L']:>4} | {r['V']:>4} | {r['E']:>4} | "
              f"{r['T']:>3} | {r['chi']:>4} | {r['density']:>7.4f} | "
              f"{r['edge_excess']:>+11.1f}")


#!/usr/bin/env python3
"""
Prime Window Complex: Interactive Demonstration

Constructs prime gap graphs and clique complexes for arithmetic windows,
computes topological summaries (vertex/edge/triangle counts, Euler characteristic),
and compares actual prime statistics against a Bernoulli random surrogate model.

This demonstrates the arithmetic-topological dictionary: topological invariants
of the prime gap complex equal explicit number-theoretic statistics.
"""

import math
import random
from collections import defaultdict
from itertools import combinations

# ─────────────────────────────────────────────────────────────────────────────
# Core Number Theory
# ─────────────────────────────────────────────────────────────────────────────

def sieve_of_eratosthenes(limit):
    """Return a list of primes up to `limit`."""
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]

def primes_in_window(n, L):
    """Return primes in [n, n+L-1]."""
    all_primes = set(sieve_of_eratosthenes(n + L))
    return sorted(p for p in all_primes if n <= p <= n + L - 1)

# ─────────────────────────────────────────────────────────────────────────────
# Prime Gap Graph Construction
# ─────────────────────────────────────────────────────────────────────────────

def prime_gap_graph(n, L, S):
    """
    Build the prime gap graph.
    
    Vertices: primes in [n, n+L-1]
    Edges: {p, q} where |p - q| ∈ S
    
    Returns (vertices, edges) where edges are frozensets.
    """
    primes = primes_in_window(n, L)
    vertices = set(primes)
    edges = set()
    for i, p in enumerate(primes):
        for j in range(i + 1, len(primes)):
            q = primes[j]
            if q - p in S:
                edges.add(frozenset([p, q]))
    return sorted(vertices), edges

def find_cliques(vertices, edges, k):
    """Find all k-cliques in the graph (sets of k mutually adjacent vertices)."""
    if k == 1:
        return [{v} for v in vertices]
    if k == 2:
        return [set(e) for e in edges]
    
    # Build adjacency for quick lookup
    adj = defaultdict(set)
    for e in edges:
        u, v = list(e)
        adj[u].add(v)
        adj[v].add(u)
    
    cliques = []
    for combo in combinations(sorted(vertices), k):
        is_clique = True
        for i in range(len(combo)):
            for j in range(i + 1, len(combo)):
                if combo[j] not in adj[combo[i]]:
                    is_clique = False
                    break
            if not is_clique:
                break
        if is_clique:
            cliques.append(set(combo))
    return cliques

# ─────────────────────────────────────────────────────────────────────────────
# Topological Invariants
# ─────────────────────────────────────────────────────────────────────────────

def face_counts(n, L, S, max_dim=4):
    """Compute face counts f_0, f_1, f_2, ... of the clique complex."""
    vertices, edges = prime_gap_graph(n, L, S)
    counts = {}
    counts[0] = len(vertices)
    counts[1] = len(edges)
    for d in range(2, max_dim + 1):
        cliques = find_cliques(vertices, edges, d + 1)
        counts[d] = len(cliques)
        if counts[d] == 0:
            break
    return counts

def euler_characteristic(n, L, S, max_dim=4):
    """Compute Euler characteristic χ = Σ (-1)^k f_k."""
    fc = face_counts(n, L, S, max_dim)
    return sum((-1)**k * fc[k] for k in fc)

def prime_pair_count(n, L, h):
    """Count prime pairs (p, p+h) with both in the window."""
    primes = set(primes_in_window(n, L))
    return sum(1 for p in primes if p + h in primes)

# ─────────────────────────────────────────────────────────────────────────────
# Bernoulli Surrogate Model
# ─────────────────────────────────────────────────────────────────────────────

def bernoulli_expected_edges(L, S, p):
    """Expected edge count under Bernoulli(p) prime model."""
    return p**2 * sum(max(L - h, 0) for h in S)

def bernoulli_expected_vertices(L, p):
    """Expected vertex count under Bernoulli(p) model."""
    return L * p

def bernoulli_sample_complex(n, L, S, p, num_samples=1000):
    """Sample complexes from the Bernoulli model and compute statistics."""
    euler_chars = []
    edge_counts = []
    for _ in range(num_samples):
        # Each position independently "prime" with probability p
        occupied = set()
        for i in range(L):
            if random.random() < p:
                occupied.add(n + i)
        # Build edges
        occ_sorted = sorted(occupied)
        edges = set()
        for i, a in enumerate(occ_sorted):
            for j in range(i + 1, len(occ_sorted)):
                b = occ_sorted[j]
                if b - a in S:
                    edges.add(frozenset([a, b]))
        # Triangles
        adj = defaultdict(set)
        for e in edges:
            u, v = list(e)
            adj[u].add(v)
            adj[v].add(u)
        triangles = 0
        for combo in combinations(occ_sorted, 3):
            a, b, c = combo
            if b in adj[a] and c in adj[a] and c in adj[b]:
                triangles += 1
        
        V = len(occupied)
        E = len(edges)
        T = triangles
        euler_chars.append(V - E + T)
        edge_counts.append(E)
    
    return {
        'mean_euler': sum(euler_chars) / len(euler_chars),
        'std_euler': (sum((x - sum(euler_chars)/len(euler_chars))**2 
                        for x in euler_chars) / len(euler_chars))**0.5,
        'mean_edges': sum(edge_counts) / len(edge_counts),
        'std_edges': (sum((x - sum(edge_counts)/len(edge_counts))**2 
                        for x in edge_counts) / len(edge_counts))**0.5,
    }

# ─────────────────────────────────────────────────────────────────────────────
# Filtration Profile
# ─────────────────────────────────────────────────────────────────────────────

def euler_curve(n, L, max_gap):
    """
    Compute the Euler curve: χ(K(n,L,S_t)) as t varies.
    S_t = {2, 4, ..., 2t} (even gaps up to 2t).
    """
    curve = []
    for t in range(1, max_gap // 2 + 1):
        S = set(range(2, 2*t + 1, 2))
        chi = euler_characteristic(n, L, S)
        curve.append((2*t, chi))
    return curve

def edge_filtration(n, L, max_gap):
    """Edge count as function of maximum gap."""
    curve = []
    for t in range(1, max_gap // 2 + 1):
        S = set(range(2, 2*t + 1, 2))
        _, edges = prime_gap_graph(n, L, S)
        curve.append((2*t, len(edges)))
    return curve

# ─────────────────────────────────────────────────────────────────────────────
# Main Demo
# ─────────────────────────────────────────────────────────────────────────────

def demo_basic():
    """Demonstrate basic prime gap complex construction."""
    print("=" * 70)
    print("PRIME WINDOW COMPLEX — BASIC CONSTRUCTION")
    print("=" * 70)
    
    n, L = 10, 20
    S = {2, 4, 6}
    
    primes = primes_in_window(n, L)
    vertices, edges = prime_gap_graph(n, L, S)
    
    print(f"\nWindow: [{n}, {n+L-1}]")
    print(f"Admissible gaps S = {sorted(S)}")
    print(f"Primes in window: {primes}")
    print(f"Vertex count: {len(vertices)}")
    print(f"Edge count: {len(edges)}")
    
    print(f"\nEdges:")
    for e in sorted(edges, key=lambda x: tuple(sorted(x))):
        p, q = sorted(e)
        print(f"  {{{p}, {q}}} (gap = {q-p})")
    
    # Verify Theorem 1: edge count = sum of prime pair counts
    pair_sum = sum(prime_pair_count(n, L, h) for h in S)
    print(f"\n--- Theorem 1 Verification ---")
    print(f"Edge count = {len(edges)}")
    print(f"Σ_h primePairCount(h) = {pair_sum}")
    for h in sorted(S):
        print(f"  primePairCount(h={h}) = {prime_pair_count(n, L, h)}")
    print(f"Match: {len(edges) == pair_sum} ✓" if len(edges) == pair_sum else "MISMATCH ✗")
    
    # Face counts and Euler characteristic
    fc = face_counts(n, L, S)
    chi = euler_characteristic(n, L, S)
    print(f"\n--- Euler Characteristic ---")
    for d in sorted(fc.keys()):
        print(f"  f_{d} = {fc[d]}")
    print(f"  χ = {chi}")
    print(f"  χ = V - E + T = {fc[0]} - {fc[1]} + {fc.get(2, 0)} = {chi}")

def demo_monotonicity():
    """Demonstrate monotonicity under gap set filtration (Theorem 2)."""
    print("\n" + "=" * 70)
    print("MONOTONICITY UNDER GAP-SET FILTRATION")
    print("=" * 70)
    
    n, L = 100, 100
    gap_sets = [
        {2},
        {2, 4},
        {2, 4, 6},
        {2, 4, 6, 8, 10},
        {2, 4, 6, 8, 10, 12, 14},
        set(range(2, 31, 2)),
    ]
    
    print(f"\nWindow: [{n}, {n+L-1}]")
    print(f"Primes: {primes_in_window(n, L)}\n")
    
    prev_edges = 0
    for S in gap_sets:
        _, edges = prime_gap_graph(n, L, S)
        fc = face_counts(n, L, S)
        chi = euler_characteristic(n, L, S)
        mono = "✓" if len(edges) >= prev_edges else "✗"
        print(f"S = {{2,...,{max(S)}}} (|S|={len(S)}): "
              f"V={fc[0]}, E={len(edges)} {mono}, "
              f"T={fc.get(2,0)}, χ={chi}")
        prev_edges = len(edges)

def demo_bernoulli_comparison():
    """Compare actual primes against Bernoulli random model (Theorem 4)."""
    print("\n" + "=" * 70)
    print("ARITHMETIC vs BERNOULLI COMPARISON")
    print("=" * 70)
    
    n, L = 1000, 200
    S = set(range(2, 21, 2))
    
    primes = primes_in_window(n, L)
    prime_density = len(primes) / L
    
    print(f"\nWindow: [{n}, {n+L-1}]")
    print(f"Gap set: even gaps 2..20")
    print(f"Actual prime density: {prime_density:.4f}")
    print(f"1/ln({n+L//2}) ≈ {1/math.log(n+L//2):.4f}")
    
    # Actual statistics
    _, edges = prime_gap_graph(n, L, S)
    fc = face_counts(n, L, S)
    chi_actual = euler_characteristic(n, L, S)
    
    print(f"\n--- Actual Prime Data ---")
    print(f"Vertices: {fc[0]}")
    print(f"Edges: {len(edges)}")
    print(f"Triangles: {fc.get(2, 0)}")
    print(f"Euler char: {chi_actual}")
    
    # Bernoulli prediction
    p_model = prime_density
    E_V = bernoulli_expected_vertices(L, p_model)
    E_E = bernoulli_expected_edges(L, S, p_model)
    
    print(f"\n--- Bernoulli Prediction (p = {p_model:.4f}) ---")
    print(f"E[Vertices]: {E_V:.1f}")
    print(f"E[Edges]: {E_E:.1f}")
    
    # Monte Carlo comparison
    random.seed(42)
    mc = bernoulli_sample_complex(n, L, S, p_model, num_samples=2000)
    
    print(f"\n--- Monte Carlo Bernoulli (2000 samples) ---")
    print(f"Mean edges: {mc['mean_edges']:.1f} ± {mc['std_edges']:.1f}")
    print(f"Mean Euler: {mc['mean_euler']:.1f} ± {mc['std_euler']:.1f}")
    
    # Discrepancy
    edge_discrepancy = len(edges) - mc['mean_edges']
    print(f"\n--- Arithmetic Discrepancy ---")
    print(f"Edge discrepancy (actual - Bernoulli): {edge_discrepancy:+.1f}")
    print(f"In units of σ: {edge_discrepancy / max(mc['std_edges'], 0.01):+.1f}σ")
    print(f"Euler discrepancy: {chi_actual - mc['mean_euler']:+.1f}")

def demo_euler_curve():
    """Compute and display the Euler curve for a prime window."""
    print("\n" + "=" * 70)
    print("EULER CURVE (Filtration Profile)")
    print("=" * 70)
    
    n, L = 500, 150
    max_gap = 30
    
    print(f"\nWindow: [{n}, {n+L-1}]")
    print(f"Filtration: S_t = {{2, 4, ..., 2t}}")
    print(f"Primes: {primes_in_window(n, L)}")
    print()
    
    curve = euler_curve(n, L, max_gap)
    print(f"{'max gap':>8} | {'χ':>6} | {'bar'}")
    print("-" * 50)
    for gap, chi in curve:
        bar = "█" * max(chi + 30, 0) if chi >= -30 else ""
        print(f"{gap:>8} | {chi:>6} | {bar}")

def demo_dictionary_entries():
    """Show the arithmetic-topological dictionary in action."""
    print("\n" + "=" * 70)
    print("ARITHMETIC-TOPOLOGICAL DICTIONARY")
    print("=" * 70)
    
    windows = [(100, 50), (1000, 100), (10000, 200)]
    S = {2, 4, 6}
    
    print(f"\nGap set S = {sorted(S)}")
    print(f"\n{'Window':>15} | {'V':>4} | {'E':>4} | {'T':>4} | {'χ':>4} | "
          f"{'twin':>4} | {'cousin':>6} | {'sexy':>4}")
    print("-" * 75)
    
    for n, L in windows:
        fc = face_counts(n, L, S)
        chi = euler_characteristic(n, L, S)
        twin = prime_pair_count(n, L, 2)
        cousin = prime_pair_count(n, L, 4)
        sexy = prime_pair_count(n, L, 6)
        
        print(f"[{n},{n+L-1}]{' '*(10-len(f'[{n},{n+L-1}]'))} | "
              f"{fc[0]:>4} | {fc[1]:>4} | {fc.get(2,0):>4} | {chi:>4} | "
              f"{twin:>4} | {cousin:>6} | {sexy:>4}")

if __name__ == "__main__":
    demo_basic()
    demo_monotonicity()
    demo_bernoulli_comparison()
    demo_euler_curve()
    demo_dictionary_entries()
    
    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.json from all deliverables."""
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
viz_euler = read_file('viz_euler_curve.py')
viz_edge = read_file('viz_edge_decomposition.py')
viz_disc = read_file('viz_discrepancy_scaling.py')
interactive_html = read_file('interactive_prime_complex.html')
lean_defs = read_file('Speculative/PrimeWindowComplex/Defs.lean')
lean_theorems = read_file('Speculative/PrimeWindowComplex/Theorems.lean')

package = {
    "title": "Homological Echoes of Prime Statistics: The Arithmetic-Topological Dictionary for Prime Gap Clique Complexes",
    "domain": "Topological Analytic Number Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Prime Window Complex Demo",
            "code": demo_code
        },
        {
            "name": "Applications: Model Discrimination & Scale Analysis",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Segmented Sieve for Prime Windows",
            "pseudocode": "Input: n (start), L (length)\n1. Sieve small primes up to sqrt(n+L)\n2. Mark composites in [n, n+L-1] using small primes\n3. Return unmarked positions as primes\nTime: O(L log log(n+L) + sqrt(n+L))\nSpace: O(L + sqrt(n+L))",
            "code": algorithms_code
        },
        {
            "name": "Prime Gap Graph Construction",
            "pseudocode": "Input: n, L, S (admissible gaps)\n1. Find primes P in [n, n+L-1]\n2. For each p in P, h in S: if p+h in P, add edge {p, p+h}\n3. Return (vertices, edges, adjacency)\nTime: O(V * |S|)\nSpace: O(V^2)",
            "code": algorithms_code
        },
        {
            "name": "Face Vector via Bron-Kerbosch Clique Enumeration",
            "pseudocode": "Input: graph (vertices, adjacency)\n1. Run Bron-Kerbosch with pivoting to find all maximal cliques\n2. Extract all sub-cliques organized by size\n3. f_k = number of (k+1)-cliques\nTime: O(3^(V/3)) worst case",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Euler Curve: Prime Gap Clique Complex Filtration",
            "code": viz_euler,
            "description": "Shows the Euler characteristic as the admissible gap set grows, comparing actual primes against a Bernoulli random model. The divergence reveals arithmetic structure beyond density."
        },
        {
            "name": "Edge Decomposition by Gap (Theorem 1)",
            "code": viz_edge,
            "description": "Visualizes the arithmetic-topological dictionary: edge count = sum of prime pair counts, decomposed by gap value, with Bernoulli comparison."
        },
        {
            "name": "Arithmetic Discrepancy Scaling",
            "code": viz_disc,
            "description": "Shows how the discrepancy between actual prime complex statistics and the Bernoulli model evolves as the window moves along the number line."
        }
    ],
    "interactive_demos": [
        {
            "name": "Prime Gap Complex Explorer",
            "html": interactive_html,
            "description": "Interactive graph visualization: choose a window and gap set, see the prime gap graph drawn with color-coded edges, and verify Theorem 1 (edge decomposition) in real time."
        }
    ],
    "lean_proofs": lean_defs + "\n\n-- ═══════════════════════════════════════════════════════\n-- THEOREMS FILE\n-- ═══════════════════════════════════════════════════════\n\n" + lean_theorems
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json written ({os.path.getsize('PACKAGE.json')} bytes)")


#!/usr/bin/env python3
"""
Visualization: Arithmetic Discrepancy Scaling

Shows how the discrepancy between actual prime gap complex statistics
and the Bernoulli random model grows with window position, revealing
systematic arithmetic structure beyond what density alone captures.

This is the visualization of the cross-domain theorem connecting
number theory (prime correlations) with random topology (Bernoulli flag complexes).
"""

import math
from collections import defaultdict
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# ── Self-contained utilities ──

def sieve(limit):
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]

def primes_in_window(n, L):
    all_p = set(sieve(n + L))
    return sorted(p for p in all_p if n <= p <= n + L - 1)

def compute_stats(n, L, S):
    primes = primes_in_window(n, L)
    prime_set = set(primes)
    edges = set()
    adj = defaultdict(set)
    for p in primes:
        for h in S:
            q = p + h
            if q in prime_set:
                edges.add(frozenset([p, q]))
                adj[p].add(q)
                adj[q].add(p)
    V = len(primes)
    E = len(edges)
    T = 0
    for i, p in enumerate(primes):
        for j in range(i+1, len(primes)):
            q = primes[j]
            if q not in adj.get(p, set()):
                continue
            for k in range(j+1, len(primes)):
                r = primes[k]
                if r in adj.get(p, set()) and r in adj.get(q, set()):
                    T += 1
    density = V / L if L > 0 else 0
    E_bern = density**2 * sum(max(L - h, 0) for h in S)
    return {
        'V': V, 'E': E, 'T': T, 'chi': V - E + T,
        'density': density, 'E_bernoulli': E_bern,
        'edge_disc': E - E_bern,
        'chi_norm': (V - E + T) / max(V, 1),
    }

# ── Compute for many windows ──

S = {2, 4, 6, 8, 10}
window_starts = list(range(100, 20001, 200))
L = 150

ns = []
edge_discs = []
chi_norms = []
densities = []
edge_counts = []
vertex_counts = []

for n in window_starts:
    stats = compute_stats(n, L, S)
    ns.append(n)
    edge_discs.append(stats['edge_disc'])
    chi_norms.append(stats['chi_norm'])
    densities.append(stats['density'])
    edge_counts.append(stats['E'])
    vertex_counts.append(stats['V'])

ns = np.array(ns)
edge_discs = np.array(edge_discs)
chi_norms = np.array(chi_norms)

# ── Plot ──

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Edge discrepancy
ax = axes[0, 0]
ax.plot(ns, edge_discs, 'o-', color='crimson', markersize=2, linewidth=0.8)
ax.axhline(y=0, color='gray', linewidth=1, linestyle='--')
# Running average
window_size = 10
if len(edge_discs) >= window_size:
    running_avg = np.convolve(edge_discs, np.ones(window_size)/window_size, mode='valid')
    ax.plot(ns[window_size//2:window_size//2+len(running_avg)], running_avg,
            color='navy', linewidth=2, label=f'Running avg (w={window_size})')
ax.set_xlabel('Window start n', fontsize=10)
ax.set_ylabel('Edge discrepancy (actual - Bernoulli)', fontsize=10)
ax.set_title('Edge Count Excess over Bernoulli Model', fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 2: Normalized Euler characteristic
ax = axes[0, 1]
ax.plot(ns, chi_norms, 'o-', color='forestgreen', markersize=2, linewidth=0.8)
ax.set_xlabel('Window start n', fontsize=10)
ax.set_ylabel('χ / V (normalized Euler char)', fontsize=10)
ax.set_title('Normalized Euler Characteristic', fontsize=11)
ax.grid(True, alpha=0.3)

# Panel 3: Prime density vs 1/ln(n)
ax = axes[1, 0]
expected = [1/math.log(max(n, 3)) for n in ns]
ax.plot(ns, densities, 'o', color='crimson', markersize=2, label='Actual ρ(n,L)')
ax.plot(ns, expected, '-', color='steelblue', linewidth=1.5, label='1/ln(n)')
ax.set_xlabel('Window start n', fontsize=10)
ax.set_ylabel('Prime density', fontsize=10)
ax.set_title('Prime Density in Windows', fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 4: Edge count vs Bernoulli prediction
ax = axes[1, 1]
bernoulli_edges = [d**2 * sum(max(L - h, 0) for h in S) for d in densities]
ax.scatter(bernoulli_edges, edge_counts, c=ns, cmap='viridis', s=15, alpha=0.7)
max_val = max(max(edge_counts), max(bernoulli_edges)) + 5
ax.plot([0, max_val], [0, max_val], 'k--', linewidth=1, label='y = x')
ax.set_xlabel('Bernoulli predicted edges', fontsize=10)
ax.set_ylabel('Actual edge count', fontsize=10)
ax.set_title('Actual vs Bernoulli Edge Counts\n(color = window position)', fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
cbar = plt.colorbar(ax.collections[0], ax=ax, label='Window start n')

fig.suptitle('Arithmetic Discrepancy: Primes vs Random Topology\n'
             f'S = {sorted(S)}, L = {L}',
             fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig('discrepancy_scaling.png', dpi=150, bbox_inches='tight')
print("Saved discrepancy_scaling.png")


#!/usr/bin/env python3
"""
Visualization: Edge Decomposition by Gap (Theorem 1)

Shows the fundamental arithmetic-topological dictionary entry:
the edge count of the prime gap clique complex decomposes as
    E = Σ_{h ∈ S} primePairCount(h)

Each bar shows how many edges come from each gap value, directly
connecting the topological 1-skeleton to prime pair statistics.
Also compares against the Bernoulli random prediction.
"""

import math
from collections import defaultdict
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# ── Self-contained utilities ──

def sieve(limit):
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]

def primes_in_window(n, L):
    all_p = set(sieve(n + L))
    return sorted(p for p in all_p if n <= p <= n + L - 1)

def prime_pair_count(primes, h):
    ps = set(primes)
    return sum(1 for p in primes if p + h in ps)

# ── Compute decompositions ──

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

configs = [
    (100, 100, "Small window"),
    (1000, 200, "Medium window"),
    (10000, 300, "Large window"),
    (50000, 400, "Very large window"),
]

max_gap = 30
gaps = list(range(2, max_gap + 1, 2))

for ax, (n, L, label) in zip(axes.flat, configs):
    primes = primes_in_window(n, L)
    density = len(primes) / L
    
    # Actual pair counts
    actual_counts = [prime_pair_count(primes, h) for h in gaps]
    
    # Bernoulli prediction: p² · (L - h) for each gap
    bernoulli_counts = [density**2 * max(L - h, 0) for h in gaps]
    
    x = np.arange(len(gaps))
    width = 0.35
    
    bars1 = ax.bar(x - width/2, actual_counts, width, color='crimson',
                   alpha=0.8, label='Actual primes')
    bars2 = ax.bar(x + width/2, bernoulli_counts, width, color='steelblue',
                   alpha=0.8, label='Bernoulli prediction')
    
    ax.set_xlabel('Gap h', fontsize=10)
    ax.set_ylabel('Pair count', fontsize=10)
    ax.set_title(f'{label}: [{n}, {n+L-1}]\n'
                 f'V={len(primes)}, E_actual={sum(actual_counts)}, '
                 f'E_bernoulli={sum(bernoulli_counts):.0f}',
                 fontsize=10)
    ax.set_xticks(x)
    ax.set_xticklabels(gaps, fontsize=8)
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3, axis='y')

fig.suptitle('Edge Count Decomposition: E = Σ primePairCount(h)\n'
             '(Theorem 1: Arithmetic-Topological Dictionary)',
             fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig('edge_decomposition.png', dpi=150, bbox_inches='tight')
print("Saved edge_decomposition.png")


#!/usr/bin/env python3
"""
Visualization: Euler Curve of Prime Gap Clique Complexes

Plots the Euler characteristic χ(K(n, L, S_t)) as the admissible gap set
grows from S = {2} to S = {2,4,...,max_gap}. This filtration profile is
the fundamental topological observable connecting prime statistics to
persistence theory.

The plot compares actual prime data against a Bernoulli random model,
revealing arithmetic structure invisible to density-based statistics.
"""

import math
import random
from collections import defaultdict
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# ── Self-contained prime utilities ──

def sieve(limit):
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]

def primes_in_window(n, L):
    all_p = set(sieve(n + L))
    return sorted(p for p in all_p if n <= p <= n + L - 1)

def topological_summary(primes, S):
    prime_set = set(primes)
    edges = set()
    adj = defaultdict(set)
    for p in primes:
        for h in S:
            q = p + h
            if q in prime_set:
                edges.add(frozenset([p, q]))
                adj[p].add(q)
                adj[q].add(p)
    V = len(primes)
    E = len(edges)
    T = 0
    for i, p in enumerate(primes):
        for j in range(i+1, len(primes)):
            q = primes[j]
            if q not in adj.get(p, set()):
                continue
            for k in range(j+1, len(primes)):
                r = primes[k]
                if r in adj.get(p, set()) and r in adj.get(q, set()):
                    T += 1
    return V, E, T, V - E + T

# ── Compute filtration profiles ──

def euler_filtration(n, L, max_gap):
    primes = primes_in_window(n, L)
    gaps = list(range(2, max_gap + 1, 2))
    chis = []
    for t in gaps:
        S = set(range(2, t + 1, 2))
        _, _, _, chi = topological_summary(primes, S)
        chis.append(chi)
    return gaps, chis

def bernoulli_euler_filtration(n, L, max_gap, p, num_samples=200):
    gaps = list(range(2, max_gap + 1, 2))
    mean_chis = []
    std_chis = []
    random.seed(123)
    
    for t in gaps:
        S = set(range(2, t + 1, 2))
        sample_chis = []
        for _ in range(num_samples):
            fake = sorted(x for x in range(n, n + L) if random.random() < p)
            if fake:
                _, _, _, chi = topological_summary(fake, S)
                sample_chis.append(chi)
            else:
                sample_chis.append(0)
        mean_chis.append(np.mean(sample_chis))
        std_chis.append(np.std(sample_chis))
    
    return gaps, mean_chis, std_chis

# ── Plot ──

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

windows = [(100, 100, "small"), (1000, 200, "medium"), (10000, 300, "large")]
max_gap = 30

for ax, (n, L, label) in zip(axes, windows):
    primes = primes_in_window(n, L)
    density = len(primes) / L
    
    gaps, chis = euler_filtration(n, L, max_gap)
    gaps_b, mean_b, std_b = bernoulli_euler_filtration(n, L, max_gap, density, 150)
    
    # Plot Bernoulli band
    mean_arr = np.array(mean_b)
    std_arr = np.array(std_b)
    ax.fill_between(gaps_b, mean_arr - 2*std_arr, mean_arr + 2*std_arr,
                     alpha=0.2, color='steelblue', label='Bernoulli ±2σ')
    ax.plot(gaps_b, mean_b, '--', color='steelblue', linewidth=1.5,
            label='Bernoulli mean')
    
    # Plot actual
    ax.plot(gaps, chis, 'o-', color='crimson', linewidth=2, markersize=4,
            label='Actual primes')
    
    ax.set_xlabel('Maximum gap in S', fontsize=11)
    ax.set_ylabel('Euler characteristic χ', fontsize=11)
    ax.set_title(f'Window [{n}, {n+L-1}]\n'
                 f'{len(primes)} primes, ρ={density:.3f}', fontsize=11)
    ax.legend(fontsize=8, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='gray', linewidth=0.5)

fig.suptitle('Euler Curve: Prime Gap Clique Complex Filtration',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('euler_curve.png', dpi=150, bbox_inches='tight')
print("Saved euler_curve.png")
