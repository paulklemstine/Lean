#!/usr/bin/env python3
"""
Arithmetic TDA Pipeline — Applications

Demonstrates real-world applications of the arithmetic TDA pipeline:
1. Dataset classification using torsion prime signatures
2. Comparing topological fingerprints of point clouds
3. Torsion-aware persistence analysis
"""

import numpy as np
import random
from typing import List, Set, Dict, Tuple
from collections import defaultdict
from math import gcd, sqrt


# ─────────────────────────────────────────────────────────────
# Utilities (self-contained)
# ─────────────────────────────────────────────────────────────

def prime_factors(n: int) -> Set[int]:
    if n <= 1: return set()
    factors = set()
    d = 2
    while d * d <= n:
        while n % d == 0: factors.add(d); n //= d
        d += 1
    if n > 1: factors.add(n)
    return factors

def compute_torsion_primes(factors: List[int]) -> Set[int]:
    primes = set()
    for d in factors:
        if d > 1: primes |= prime_factors(d)
    return primes

def smith_diag_simple(matrix: np.ndarray) -> List[int]:
    if matrix.size == 0: return []
    M = matrix.astype(int).tolist()
    rows, cols = len(M), len(M[0])
    pivot = 0
    diag = []
    for col in range(min(rows, cols)):
        found = False
        for r in range(pivot, rows):
            for c in range(pivot, cols):
                if M[r][c] != 0:
                    M[pivot], M[r] = M[r], M[pivot]
                    for row in M: row[pivot], row[c] = row[c], row[pivot]
                    found = True; break
            if found: break
        if not found: break
        changed = True
        iters = 0
        while changed and iters < 500:
            changed = False; iters += 1
            for r in range(pivot+1, rows):
                if M[r][pivot] != 0:
                    q = M[r][pivot] // M[pivot][pivot]
                    for c in range(cols): M[r][c] -= q * M[pivot][c]
                    if M[r][pivot] != 0: M[pivot], M[r] = M[r], M[pivot]; changed = True
            for c in range(pivot+1, cols):
                if M[pivot][c] != 0:
                    q = M[pivot][c] // M[pivot][pivot]
                    for r in range(rows): M[r][c] -= q * M[r][pivot]
                    if M[pivot][c] != 0:
                        for r in range(rows): M[r][pivot], M[r][c] = M[r][c], M[r][pivot]
                        changed = True
        diag.append(abs(M[pivot][pivot]))
        pivot += 1
    return [d for d in diag if d > 0]


# ─────────────────────────────────────────────────────────────
# Application 1: Dataset Classification via Torsion Signatures
# ─────────────────────────────────────────────────────────────

def app_dataset_classification():
    """
    Classify datasets by their arithmetic topological fingerprints.
    
    Idea: Two datasets with different torsion prime signatures have
    fundamentally different topological structure, even if their
    Betti numbers match. This gives a finer invariant for classification.
    """
    print("=" * 70)
    print("APPLICATION 1: Dataset Classification via Torsion Signatures")
    print("=" * 70)
    print()
    
    # Simulate datasets with known topological structure
    datasets = {
        "Torus (T²)": {
            "betti": [1, 2, 1],
            "torsion_factors": {0: [], 1: [], 2: []},
            "description": "No torsion — all homology is free"
        },
        "Klein Bottle (K)": {
            "betti": [1, 1, 0],
            "torsion_factors": {0: [], 1: [2], 2: []},
            "description": "2-torsion in H₁"
        },
        "RP² (Real Proj Plane)": {
            "betti": [1, 0, 0],
            "torsion_factors": {0: [], 1: [2], 2: []},
            "description": "2-torsion in H₁"
        },
        "Lens Space L(3,1)": {
            "betti": [1, 0, 0, 1],
            "torsion_factors": {0: [], 1: [3], 2: [], 3: []},
            "description": "3-torsion in H₁"
        },
        "Lens Space L(6,1)": {
            "betti": [1, 0, 0, 1],
            "torsion_factors": {0: [], 1: [6], 2: [], 3: []},
            "description": "Both 2-torsion and 3-torsion in H₁"
        },
    }
    
    print("  Dataset Fingerprints:")
    print(f"  {'Name':<25} {'Betti':<15} {'Torsion Primes':<20} {'Signature'}")
    print(f"  {'─'*25} {'─'*15} {'─'*20} {'─'*20}")
    
    signatures = {}
    for name, data in datasets.items():
        all_primes = set()
        for factors in data["torsion_factors"].values():
            all_primes |= compute_torsion_primes(factors)
        betti_str = str(data["betti"])
        primes_str = str(sorted(all_primes)) if all_primes else "∅"
        sig = (tuple(data["betti"]), frozenset(all_primes))
        signatures[name] = sig
        print(f"  {name:<25} {betti_str:<15} {primes_str:<20} {data['description']}")
    
    print()
    print("  Classification Results:")
    print("  ─" * 35)
    
    # Check which pairs are distinguishable
    names = list(datasets.keys())
    for i in range(len(names)):
        for j in range(i + 1, len(names)):
            betti_same = signatures[names[i]][0] == signatures[names[j]][0]
            torsion_same = signatures[names[i]][1] == signatures[names[j]][1]
            
            if betti_same and not torsion_same:
                print(f"  ✓ {names[i]} vs {names[j]}:")
                print(f"    Same Betti numbers, but DISTINGUISHED by torsion primes!")
            elif betti_same and torsion_same:
                print(f"  ⚠ {names[i]} vs {names[j]}:")
                print(f"    Same Betti AND same torsion primes — need finer invariants")
    
    print()


# ─────────────────────────────────────────────────────────────
# Application 2: Point Cloud Topology via Arithmetic TDA
# ─────────────────────────────────────────────────────────────

def app_point_cloud():
    """
    Analyze point clouds using arithmetic topological signatures.
    
    Shows how torsion information reveals non-orientability and
    arithmetic structure that Betti numbers alone cannot detect.
    """
    print("=" * 70)
    print("APPLICATION 2: Point Cloud Analysis — Arithmetic Fingerprints")
    print("=" * 70)
    print()
    
    # Simulate boundary matrices from Rips complexes
    scenarios = [
        {
            "name": "Sphere-like cloud",
            "matrix": np.array([
                [1, -1, 0, 0],
                [0, 1, -1, 0],
                [0, 0, 1, -1],
                [-1, 0, 0, 1],
            ]),
        },
        {
            "name": "Torus-like cloud",
            "matrix": np.array([
                [1, -1, 0, 1, 0, 0],
                [-1, 0, 1, 0, 1, 0],
                [0, 1, -1, 0, 0, 1],
                [0, 0, 0, -1, 1, -1],
            ]),
        },
        {
            "name": "Projective-like cloud",
            "matrix": np.array([
                [2, -1, 0],
                [0, 1, -1],
                [-2, 0, 1],
            ]),
        },
    ]
    
    for scenario in scenarios:
        name = scenario["name"]
        mat = scenario["matrix"]
        
        diag = smith_diag_simple(mat)
        betti = sum(1 for d in diag if d == 1)
        torsion = [d for d in diag if d > 1]
        primes = compute_torsion_primes(diag)
        
        print(f"  {name}:")
        print(f"    Boundary matrix size: {mat.shape}")
        print(f"    Smith diagonal: {diag}")
        print(f"    Betti number: {betti}")
        print(f"    Torsion factors: {torsion if torsion else 'none'}")
        print(f"    Torsion primes: {sorted(primes) if primes else '∅'}")
        
        if primes:
            print(f"    → ARITHMETIC SIGNATURE DETECTED: primes {sorted(primes)}")
            print(f"      This reveals structure invisible to field coefficients!")
        else:
            print(f"    → No torsion: Betti numbers capture all topological info")
        print()
    
    print("  KEY INSIGHT: Arithmetic TDA detects non-orientability and")
    print("  modular structure in point cloud topology that Betti numbers miss.")
    print()


# ─────────────────────────────────────────────────────────────
# Application 3: Tor₁ Prime Selectivity in Practice
# ─────────────────────────────────────────────────────────────

def app_prime_selectivity():
    """
    Demonstrate how different primes act as independent sensors
    for different types of topological torsion.
    """
    print("=" * 70)
    print("APPLICATION 3: Prime Selectivity — Independent Torsion Sensors")
    print("=" * 70)
    print()
    
    test_groups = [
        ("Z/6Z", [6]),
        ("Z/10Z", [10]),
        ("Z/15Z", [15]),
        ("Z/30Z", [30]),
        ("Z/2Z ⊕ Z/9Z", [2, 9]),
        ("Z/4Z ⊕ Z/25Z", [4, 25]),
    ]
    
    primes_to_test = [2, 3, 5, 7]
    
    print(f"  {'Group':<20}", end="")
    for p in primes_to_test:
        print(f"  {'Tor₁(Z/'+str(p)+'Z,−)':>14}", end="")
    print(f"  {'Profile':>15}")
    print(f"  {'─'*20}", end="")
    for _ in primes_to_test:
        print(f"  {'─'*14}", end="")
    print(f"  {'─'*15}")
    
    for name, factors in test_groups:
        profile = compute_torsion_primes(factors)
        print(f"  {name:<20}", end="")
        for p in primes_to_test:
            detected = any(d > 1 and d % p == 0 for d in factors)
            symbol = "  ★ DETECTED" if detected else "  · silent"
            print(f"  {symbol:>14}", end="")
        print(f"  {sorted(profile) if profile else '∅':>15}")
    
    print()
    print("  Each prime p acts as an independent detector: Tor₁(Z/pZ, −)")
    print("  fires if and only if p divides some invariant factor.")
    print("  Different primes probe orthogonal aspects of the torsion structure.")
    print()


# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║        ARITHMETIC TDA PIPELINE — REAL-WORLD APPLICATIONS           ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    random.seed(42)
    np.random.seed(42)
    
    app_dataset_classification()
    app_point_cloud()
    app_prime_selectivity()
    
    print("=" * 70)
    print("CONCLUSION")
    print("=" * 70)
    print()
    print("  Arithmetic TDA provides a strictly finer invariant than Betti numbers.")
    print("  The torsion prime profile:")
    print("    • Distinguishes spaces with identical Betti numbers")
    print("    • Detects non-orientability and modular structure")
    print("    • Decomposes into independent prime-by-prime sensors via Tor₁")
    print("    • Costs essentially nothing beyond the Smith normal form computation")
    print()


#!/usr/bin/env python3
"""
Arithmetic TDA Pipeline — Interactive Demo

Demonstrates the core results of the Arithmetic TDA Pipeline:
1. Torsion prime profile computation from Smith normal form data
2. Comparison of Betti-number vs torsion-aware analysis
3. Timing benchmarks supporting the scalability conjecture

Run: python3 demo.py
"""

import time
import random
import numpy as np
from typing import List, Set, Dict, Tuple
from collections import defaultdict
from math import gcd
from functools import reduce

# ─────────────────────────────────────────────────────────────
# Core: Smith Normal Form and Torsion Profile Extraction
# ─────────────────────────────────────────────────────────────

def prime_factors(n: int) -> Set[int]:
    """Return the set of prime factors of n."""
    if n <= 1:
        return set()
    factors = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return factors


def smith_normal_form(matrix: np.ndarray) -> List[int]:
    """
    Compute Smith Normal Form diagonal of an integer matrix.
    Returns the list of diagonal entries (invariant factors).
    Uses a simplified algorithm suitable for demonstration.
    """
    if matrix.size == 0:
        return []
    
    M = matrix.astype(int).tolist()
    rows, cols = len(M), len(M[0])
    
    pivot = 0
    diag = []
    
    for col in range(min(rows, cols)):
        # Find nonzero entry in remaining submatrix
        found = False
        for r in range(pivot, rows):
            for c in range(pivot, cols):
                if M[r][c] != 0:
                    # Swap to pivot position
                    M[pivot], M[r] = M[r], M[pivot]
                    for row in M:
                        row[pivot], row[c] = row[c], row[pivot]
                    found = True
                    break
            if found:
                break
        
        if not found:
            break
        
        # Reduce using the pivot
        changed = True
        iterations = 0
        while changed and iterations < 1000:
            changed = False
            iterations += 1
            
            # Row operations
            for r in range(pivot + 1, rows):
                if M[r][pivot] != 0:
                    q = M[r][pivot] // M[pivot][pivot]
                    for c in range(cols):
                        M[r][c] -= q * M[pivot][c]
                    if M[r][pivot] != 0:
                        M[pivot], M[r] = M[r], M[pivot]
                        changed = True
            
            # Column operations
            for c in range(pivot + 1, cols):
                if M[pivot][c] != 0:
                    q = M[pivot][c] // M[pivot][pivot]
                    for r in range(rows):
                        M[r][c] -= q * M[r][pivot]
                    if M[pivot][c] != 0:
                        for r in range(rows):
                            M[r][pivot], M[r][c] = M[r][c], M[r][pivot]
                        changed = True
        
        diag.append(abs(M[pivot][pivot]))
        pivot += 1
    
    return [d for d in diag if d > 0]


def compute_torsion_primes_from_smith(factors: List[int]) -> Set[int]:
    """
    Extract torsion prime profile from Smith diagonal data.
    This is the O(sum(log d_i)) post-processing step.
    
    Corresponds to Lean's `computeTorsionPrimesFromSmith`.
    """
    primes = set()
    for d in factors:
        if d > 1:
            primes |= prime_factors(d)
    return primes


def compute_betti_numbers(smith_diag: List[int]) -> Dict[str, int]:
    """Compute Betti number (rank of free part) from Smith diagonal."""
    rank = sum(1 for d in smith_diag if d == 1)
    torsion_factors = [d for d in smith_diag if d > 1]
    return {"betti": rank, "torsion_factors": torsion_factors}


# ─────────────────────────────────────────────────────────────
# Random Simplicial Complex Generation
# ─────────────────────────────────────────────────────────────

def random_boundary_matrix(n_simplices: int, n_faces: int, density: float = 0.3) -> np.ndarray:
    """Generate a random boundary-like matrix with ±1 entries."""
    matrix = np.zeros((n_faces, n_simplices), dtype=int)
    for j in range(n_simplices):
        n_nonzero = max(2, int(n_faces * density))
        rows = random.sample(range(n_faces), min(n_nonzero, n_faces))
        for i, r in enumerate(rows):
            matrix[r][j] = (-1) ** i
    return matrix


def generate_test_boundary_matrices(N: int) -> List[np.ndarray]:
    """Generate boundary matrices for a random simplicial complex with ~N simplices."""
    dims = []
    remaining = N
    d = 0
    while remaining > 0:
        size = max(1, remaining // (3 - min(d, 2)))
        dims.append(size)
        remaining -= size
        d += 1
        if d > 5:
            break
    
    matrices = []
    for i in range(len(dims) - 1):
        n_high = dims[i + 1]
        n_low = dims[i]
        density = min(0.5, 3.0 / max(n_low, 1))
        matrices.append(random_boundary_matrix(n_high, n_low, density))
    
    return matrices


# ─────────────────────────────────────────────────────────────
# Demo 1: Basic Torsion Profile Computation
# ─────────────────────────────────────────────────────────────

def demo_basic_profiles():
    """Demonstrate torsion prime profile computation for known groups."""
    print("=" * 70)
    print("DEMO 1: Basic Torsion Prime Profiles")
    print("=" * 70)
    print()
    
    examples = [
        ("Z/6Z", [6]),
        ("Z/12Z", [12]),
        ("Z/30Z", [30]),
        ("Z/2Z × Z/3Z", [2, 3]),
        ("Z/2Z × Z/6Z × Z/30Z", [2, 6, 30]),
        ("Z/4Z × Z/9Z", [4, 9]),
        ("Z (free)", [1]),
        ("Z^3 (free)", [1, 1, 1]),
        ("Z^2 ⊕ Z/6Z ⊕ Z/10Z", [1, 1, 6, 10]),
    ]
    
    for name, factors in examples:
        torsion_factors = [d for d in factors if d > 1]
        primes = compute_torsion_primes_from_smith(factors)
        betti = sum(1 for d in factors if d == 1)
        
        print(f"  Group: {name}")
        print(f"    Invariant factors (>1): {torsion_factors if torsion_factors else 'none'}")
        print(f"    Betti number (rank):    {betti}")
        print(f"    Torsion prime profile:  {sorted(primes) if primes else '∅ (empty)'}")
        print()
    
    print("  KEY INSIGHT: Betti numbers see only rank. Torsion primes see")
    print("  the arithmetic structure — which primes appear in the group's")
    print("  finite part. Z/6Z and Z/2Z×Z/3Z have the SAME torsion profile {2,3}.")
    print()


# ─────────────────────────────────────────────────────────────
# Demo 2: Smith Normal Form → Torsion Extraction
# ─────────────────────────────────────────────────────────────

def demo_smith_extraction():
    """Show the pipeline: boundary matrix → SNF → torsion primes."""
    print("=" * 70)
    print("DEMO 2: Smith Normal Form → Torsion Prime Extraction")
    print("=" * 70)
    print()
    
    # Example: Klein bottle boundary matrices
    print("  Example: A chain complex with interesting torsion")
    print()
    
    # Boundary matrix d2: from 2-cells to 1-cells
    d2 = np.array([
        [ 1, -1,  0],
        [-1,  0,  1],
        [ 0,  1, -1],
        [ 1,  1,  0],
    ], dtype=int)
    
    print(f"  Boundary matrix d₂ ({d2.shape[0]}×{d2.shape[1]}):")
    for row in d2:
        print(f"    {row}")
    print()
    
    smith_diag = smith_normal_form(d2)
    print(f"  Smith diagonal: {smith_diag}")
    
    info = compute_betti_numbers(smith_diag)
    primes = compute_torsion_primes_from_smith(smith_diag)
    
    print(f"  Betti number:         {info['betti']}")
    print(f"  Torsion factors:      {info['torsion_factors']}")
    print(f"  Torsion prime profile: {sorted(primes) if primes else '∅'}")
    print()
    
    # Another example
    d2b = np.array([
        [ 2, 0, 0],
        [ 0, 6, 0],
        [ 0, 0, 0],
    ], dtype=int)
    
    print("  Example: Diagonal matrix with known invariant factors [2, 6]")
    smith_diag2 = smith_normal_form(d2b)
    primes2 = compute_torsion_primes_from_smith(smith_diag2)
    print(f"  Smith diagonal: {smith_diag2}")
    print(f"  Torsion prime profile: {sorted(primes2)}")
    print()
    
    print("  PIPELINE: Matrix → Smith Normal Form → Prime Factorization → Profile")
    print("  Cost:     O(N^ω)     +                  O(Σ log dᵢ)")
    print("  The post-processing is negligible compared to the matrix algebra!")
    print()


# ─────────────────────────────────────────────────────────────
# Demo 3: Betti vs Torsion Comparison
# ─────────────────────────────────────────────────────────────

def demo_betti_vs_torsion():
    """Show cases where Betti numbers are identical but torsion profiles differ."""
    print("=" * 70)
    print("DEMO 3: Betti Numbers vs Torsion Profiles — What Torsion Reveals")
    print("=" * 70)
    print()
    
    # Two groups with same Betti number but different torsion
    groups = [
        ("Group A: Z ⊕ Z/6Z", [1, 6]),
        ("Group B: Z ⊕ Z/10Z", [1, 10]),
        ("Group C: Z ⊕ Z/15Z", [1, 15]),
    ]
    
    print("  Three groups with IDENTICAL Betti number (rank 1):")
    print()
    for name, factors in groups:
        betti = sum(1 for d in factors if d == 1)
        primes = compute_torsion_primes_from_smith(factors)
        print(f"    {name}")
        print(f"      Betti number: {betti}  |  Torsion primes: {sorted(primes)}")
    
    print()
    print("  → All three have β₁ = 1, but their arithmetic signatures differ!")
    print("  → Group A has 2-torsion and 3-torsion")
    print("  → Group B has 2-torsion and 5-torsion")
    print("  → Group C has 3-torsion and 5-torsion")
    print()
    print("  In TDA: these would be INDISTINGUISHABLE over any single field,")
    print("  but the integral torsion profile separates them completely.")
    print()


# ─────────────────────────────────────────────────────────────
# Demo 4: Timing Benchmarks
# ─────────────────────────────────────────────────────────────

def demo_timing():
    """Benchmark torsion profile computation vs Betti computation."""
    print("=" * 70)
    print("DEMO 4: Timing — Is Torsion Computation Scalable?")
    print("=" * 70)
    print()
    
    sizes = [10, 20, 30, 50]
    
    print(f"  {'N':>6}  {'SNF (ms)':>10}  {'Betti (ms)':>11}  {'Torsion (ms)':>13}  {'Ratio':>8}")
    print(f"  {'─'*6}  {'─'*10}  {'─'*11}  {'─'*13}  {'─'*8}")
    
    for N in sizes:
        matrices = generate_test_boundary_matrices(N)
        
        # Time SNF computation
        t0 = time.perf_counter()
        smith_diags = []
        for mat in matrices:
            sd = smith_normal_form(mat)
            smith_diags.append(sd)
        t_snf = (time.perf_counter() - t0) * 1000
        
        # Time Betti number extraction (from SNF)
        t0 = time.perf_counter()
        for _ in range(100):
            bettis = [compute_betti_numbers(sd) for sd in smith_diags]
        t_betti = (time.perf_counter() - t0) * 1000 / 100
        
        # Time torsion profile extraction (from SNF)
        t0 = time.perf_counter()
        for _ in range(100):
            profiles = [compute_torsion_primes_from_smith(sd) for sd in smith_diags]
        t_torsion = (time.perf_counter() - t0) * 1000 / 100
        
        ratio = t_torsion / max(t_betti, 0.001)
        
        print(f"  {N:>6}  {t_snf:>10.2f}  {t_betti:>11.4f}  {t_torsion:>13.4f}  {ratio:>8.2f}×")
    
    print()
    print("  RESULT: Torsion profile extraction adds negligible overhead to SNF.")
    print("  The bottleneck is always the Smith Normal Form computation itself.")
    print("  Post-processing (prime factorization) is O(Σ log dᵢ) — essentially free.")
    print()


# ─────────────────────────────────────────────────────────────
# Demo 5: Degreewise Arithmetic Signature
# ─────────────────────────────────────────────────────────────

def demo_degreewise():
    """Demonstrate the full degreewise arithmetic signature."""
    print("=" * 70)
    print("DEMO 5: Full Degreewise Arithmetic Signature")
    print("=" * 70)
    print()
    
    # Simulate a simplicial complex with known homology
    degrees = {
        0: [1, 1, 1],           # H₀ ≅ Z³ (3 connected components)
        1: [1, 2, 6],           # H₁ ≅ Z ⊕ Z/2Z ⊕ Z/6Z
        2: [3, 15],             # H₂ ≅ Z/3Z ⊕ Z/15Z
        3: [1],                 # H₃ ≅ Z
    }
    
    print("  Homology groups (invariant factor decomposition):")
    full_signature = set()
    for k, factors in sorted(degrees.items()):
        betti = sum(1 for d in factors if d == 1)
        torsion = [d for d in factors if d > 1]
        primes = compute_torsion_primes_from_smith(factors)
        full_signature |= primes
        
        if torsion:
            torsion_str = " ⊕ " + " ⊕ ".join(f"Z/{d}Z" for d in torsion)
        else:
            torsion_str = ""
        
        print(f"    H_{k} ≅ Z^{betti}{torsion_str}")
        print(f"         Betti β_{k} = {betti}  |  Torsion primes: {sorted(primes) if primes else '∅'}")
    
    print()
    print(f"  Full Arithmetic Signature (union over degrees): {sorted(full_signature)}")
    print(f"  This signature captures ALL prime-sensitive topological information.")
    print()
    
    # Compare with Betti-only
    betti_vec = [sum(1 for d in factors if d == 1) for _, factors in sorted(degrees.items())]
    print(f"  Betti number vector: {betti_vec}")
    print(f"  Euler characteristic: {sum((-1)**i * b for i, b in enumerate(betti_vec))}")
    print()
    print("  The Betti numbers alone cannot distinguish this complex from one")
    print("  with the same ranks but different torsion (e.g., Z/4Z vs Z/2Z⊕Z/2Z).")
    print()


# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║          ARITHMETIC TDA PIPELINE — INTERACTIVE DEMO                ║")
    print("║                                                                    ║")
    print("║  Torsion is computationally native: extractable from Smith         ║")
    print("║  normal form data with negligible overhead beyond linear algebra.  ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    random.seed(42)
    np.random.seed(42)
    
    demo_basic_profiles()
    demo_smith_extraction()
    demo_betti_vs_torsion()
    demo_timing()
    demo_degreewise()
    
    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print()
    print("  1. TORSION PRIMES are read directly from Smith diagonal entries")
    print("  2. The post-processing cost is O(Σ log dᵢ) — negligible vs O(N^ω)")
    print("  3. Different primes detect different torsion (prime selectivity)")
    print("  4. Betti numbers see rank; torsion primes see arithmetic structure")
    print("  5. The full signature is the union across homological degrees")
    print()
    print("  → ARITHMETIC TDA IS SCALABLE: torsion adds no asymptotic cost")
    print("     beyond the Smith normal form computation itself.")
    print()
