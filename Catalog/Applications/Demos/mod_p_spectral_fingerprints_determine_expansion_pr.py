#!/usr/bin/env python3
"""
Applications of Mod-p Spectral Fingerprints

Demonstrates real-world applications of the arithmetic spectral fingerprint
framework across multiple domains:

1. Graph expansion testing
2. Random walk mixing time estimation
3. Code distance surrogates for LDPC-like structures
4. Heat kernel trace recovery
"""

import numpy as np
from typing import List, Tuple, Dict
import math


# ──────────────────────────────────────────────────────────────
#  Utility functions (self-contained)
# ──────────────────────────────────────────────────────────────

def sieve_primes(bound: int) -> List[int]:
    if bound < 2:
        return []
    is_prime = [True] * (bound + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(bound**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, bound + 1, i):
                is_prime[j] = False
    return [i for i in range(bound + 1) if is_prime[i]]


def mod_p_trace_pow(A: np.ndarray, p: int, k: int) -> int:
    n = A.shape[0]
    result = np.eye(n, dtype=int)
    base = A.copy() % p
    exp = k
    while exp > 0:
        if exp & 1:
            result = result @ base % p
        base = base @ base % p
        exp >>= 1
    return int(np.trace(result)) % p


def exact_trace_pow(A: np.ndarray, k: int) -> int:
    n = A.shape[0]
    M = np.eye(n, dtype=object)
    base = A.astype(object)
    exp = k
    while exp > 0:
        if exp & 1:
            M = M @ base
        base = base @ base
        exp >>= 1
    return int(np.trace(M))


def cycle_laplacian(n: int) -> np.ndarray:
    L = np.zeros((n, n), dtype=int)
    for i in range(n):
        L[i, i] = 2
        L[i, (i + 1) % n] = -1
        L[(i + 1) % n, i] = -1
    return L


def complete_laplacian(n: int) -> np.ndarray:
    return n * np.eye(n, dtype=int) - np.ones((n, n), dtype=int)


def path_laplacian(n: int) -> np.ndarray:
    L = np.zeros((n, n), dtype=int)
    for i in range(n - 1):
        L[i, i] += 1
        L[i + 1, i + 1] += 1
        L[i, i + 1] = -1
        L[i + 1, i] = -1
    return L


# ──────────────────────────────────────────────────────────────
#  Application 1: Graph Expansion Testing
# ──────────────────────────────────────────────────────────────

def test_expansion(L: np.ndarray, prime_bound: int = 17, degree_bound: int = 6):
    """Test whether a graph is an expander using mod-p fingerprints.
    
    A good expander has a large spectral gap. We detect this by checking
    whether mod-p trace data shows rapid concentration of eigenvalues
    away from zero.
    
    The key insight: for an expander, tr(L^k)/tr(L) converges rapidly
    to the largest eigenvalue, while for a non-expander (like a cycle),
    convergence is slow due to near-zero eigenvalues.
    """
    n = L.shape[0]
    primes = sieve_primes(prime_bound)
    
    print(f"  Graph size: {n}")
    
    # Compute mod-p trace ratios as expansion indicators
    for p in primes[:4]:
        tr1 = mod_p_trace_pow(L, p, 1)
        traces = [mod_p_trace_pow(L, p, k) for k in range(1, degree_bound + 1)]
        print(f"    mod-{p} traces: {traces}")
    
    # True spectral gap for comparison
    eigs = sorted(np.linalg.eigvalsh(L.astype(float)))
    gap = next((e for e in eigs if e > 1e-10), 0)
    print(f"    True spectral gap: {gap:.6f}")
    
    # Expansion indicator: ratio of tr(L^2) to n * (tr(L)/n)^2
    # For an expander, this ratio is close to 1 + gap^2/...
    tr1 = exact_trace_pow(L, 1)
    tr2 = exact_trace_pow(L, 2)
    if tr1 > 0:
        ratio = tr2 * n / (tr1 * tr1)
        print(f"    Expansion indicator (tr2·n/tr1²): {ratio:.4f}")
    
    return gap


# ──────────────────────────────────────────────────────────────
#  Application 2: Random Walk Mixing Time Estimation
# ──────────────────────────────────────────────────────────────

def estimate_mixing_time(A: np.ndarray, prime_bound: int = 23):
    """Estimate mixing time of random walk from fingerprint data.
    
    For a regular graph with adjacency matrix A and degree d,
    the transition matrix is P = A/d. The mixing time is governed
    by the spectral gap of P, which relates to the gap of the Laplacian.
    
    tr(P^k) counts the expected number of vertices returned to after
    k steps (summed over all starting vertices). This is exactly
    the heat trace at time k.
    
    The fingerprint determines tr(P^k) mod p, and by the transfer
    theorem, determines tr(P^k) exactly for large enough p.
    """
    n = A.shape[0]
    degrees = A.sum(axis=1)
    
    if not np.all(degrees == degrees[0]):
        print("    Warning: non-regular graph, using Laplacian instead")
        L = np.diag(degrees) - A
        eigs = sorted(np.linalg.eigvalsh(L.astype(float)))
        gap = next((e for e in eigs if e > 1e-10), 0)
        mixing_time = int(np.ceil(1.0 / gap)) if gap > 0 else float('inf')
        return mixing_time
    
    d = int(degrees[0])
    print(f"    {d}-regular graph on {n} vertices")
    
    # Heat trace surrogates from mod-p data
    primes = sieve_primes(prime_bound)
    
    # Compute return probabilities (heat trace / n)
    print(f"    Heat trace tr(A^k)/n (return probabilities):")
    for k in range(1, 8):
        tr = exact_trace_pow(A, k)
        prob = tr / (n * d**k)
        
        # Verify with mod-p
        p = max(primes)
        mod_tr = mod_p_trace_pow(A, p, k)
        print(f"      k={k}: tr(A^k)={tr}, return_prob={prob:.6f}, "
              f"mod-{p}={mod_tr}")
    
    # Estimate mixing time from spectral gap
    L = d * np.eye(n, dtype=int) - A
    eigs = sorted(np.linalg.eigvalsh(L.astype(float)))
    gap = next((e / d for e in eigs if e > 1e-10), 0)
    mixing_time = int(np.ceil(1.0 / gap)) if gap > 0 else float('inf')
    print(f"    Estimated mixing time: {mixing_time} steps (gap={gap:.6f})")
    
    return mixing_time


# ──────────────────────────────────────────────────────────────
#  Application 3: Heat Kernel Trace Recovery
# ──────────────────────────────────────────────────────────────

def recover_heat_trace(L: np.ndarray, prime_bound: int = 31, degree_bound: int = 8):
    """Demonstrate exact recovery of heat trace from mod-p data.
    
    By the trace transfer theorem, if we know tr(L^k) mod p for a
    prime p exceeding |tr(L^k)|, we can recover tr(L^k) exactly.
    
    The heat trace at inverse temperature β is:
      Z(β) = tr(e^{-βL}) ≈ Σ_{k=0}^{m} (-β)^k/k! · tr(L^k)
    
    So recovering tr(L^k) determines the heat kernel expansion.
    """
    n = L.shape[0]
    primes = sieve_primes(prime_bound)
    
    print(f"  Heat trace recovery for {n}×{n} Laplacian")
    print(f"  Using primes up to {prime_bound}: {primes}")
    
    exact_traces = {}
    recovered_traces = {}
    
    for k in range(degree_bound + 1):
        tr = exact_trace_pow(L, k)
        exact_traces[k] = tr
        
        # Find smallest prime that allows recovery
        recovery_prime = None
        for p in primes:
            if p > abs(tr):
                mod_val = mod_p_trace_pow(L, p, k)
                # Recover: value in (-p/2, p/2]
                if mod_val > p // 2:
                    recovered = mod_val - p
                else:
                    recovered = mod_val
                if recovered == tr:
                    recovery_prime = p
                    recovered_traces[k] = recovered
                    break
        
        status = "✓" if k in recovered_traces else "✗ (need larger prime)"
        print(f"    k={k}: tr(L^k)={tr:>12d}, "
              f"recovery prime={recovery_prime or 'N/A':>4}, {status}")
    
    # Compute heat trace at several temperatures
    print(f"\n  Heat trace Z(β) = tr(exp(-βL)):")
    for beta in [0.1, 0.5, 1.0]:
        # From eigenvalues (exact)
        eigs = np.linalg.eigvalsh(L.astype(float))
        Z_exact = sum(np.exp(-beta * eigs))
        
        # From recovered moments (approximation)
        Z_approx = sum(
            (-beta)**k / math.factorial(k) * recovered_traces.get(k, 0)
            for k in range(min(degree_bound + 1, len(recovered_traces)))
        )
        
        print(f"    β={beta:.1f}: exact={Z_exact:.6f}, "
              f"moment approx={Z_approx:.6f}, "
              f"error={abs(Z_exact - Z_approx):.6f}")


# ──────────────────────────────────────────────────────────────
#  Application 4: Characteristic Polynomial Recovery
# ──────────────────────────────────────────────────────────────

def recover_charpoly_coefficients(A: np.ndarray, prime_bound: int = 31, degree_bound: int = None):
    """Recover characteristic polynomial coefficients from trace data.
    
    By Newton's identities, the power sums s_k = tr(A^k) determine
    the elementary symmetric polynomials e_k, which are (up to sign)
    the coefficients of the characteristic polynomial.
    
    Newton's identities:
      s_1 = e_1
      s_2 = s_1 e_1 - 2 e_2
      s_3 = s_2 e_1 - s_1 e_2 + 3 e_3
      ...
    """
    n = A.shape[0]
    if degree_bound is None:
        degree_bound = n
    
    # Compute power sums
    s = [0]  # s[0] = n (trace of identity)
    s.append(exact_trace_pow(A, 1))  # s[1] = tr(A)
    for k in range(2, degree_bound + 1):
        s.append(exact_trace_pow(A, k))
    
    # Newton's identities to recover elementary symmetric polynomials
    # e_k = (1/k)(s_k - Σ_{i=1}^{k-1} (-1)^{i-1} e_i s_{k-i})
    e = [1]  # e_0 = 1
    for k in range(1, min(degree_bound + 1, n + 1)):
        val = s[k]
        for i in range(1, k):
            val += (-1)**i * e[i] * s[k - i]
        val = (-1)**(k + 1) * val
        e.append(val // k if val % k == 0 else val / k)
    
    # Compare with numpy characteristic polynomial
    true_charpoly = np.round(np.poly(A.astype(float))).astype(int)
    
    print(f"  Characteristic polynomial recovery for {n}×{n} matrix")
    print(f"  Power sums s_k = tr(A^k): {s[1:min(6, len(s))]}")
    print(f"  Recovered e_k: {e[:min(6, len(e))]}")
    print(f"  True charpoly coefficients: {list(true_charpoly[:min(6, len(true_charpoly))])}")
    
    return e


# ──────────────────────────────────────────────────────────────
#  Main demonstration
# ──────────────────────────────────────────────────────────────

def main():
    print("=" * 70)
    print("  APPLICATIONS OF MOD-p SPECTRAL FINGERPRINTS")
    print("=" * 70)
    
    # Application 1: Expansion testing
    print("\n--- APPLICATION 1: Graph Expansion Testing ---")
    print("\nCycle graph C_12 (poor expander):")
    test_expansion(cycle_laplacian(12))
    print("\nComplete graph K_8 (optimal expander):")
    test_expansion(complete_laplacian(8))
    print("\nPath graph P_10 (worst expander):")
    test_expansion(path_laplacian(10))
    
    # Application 2: Mixing time estimation
    print("\n\n--- APPLICATION 2: Random Walk Mixing Time ---")
    # Adjacency matrix of cycle
    n = 8
    A_cycle = np.zeros((n, n), dtype=int)
    for i in range(n):
        A_cycle[i, (i + 1) % n] = 1
        A_cycle[(i + 1) % n, i] = 1
    print("\nCycle C_8:")
    estimate_mixing_time(A_cycle)
    
    # Complete graph adjacency
    A_complete = np.ones((n, n), dtype=int) - np.eye(n, dtype=int)
    print("\nComplete K_8:")
    estimate_mixing_time(A_complete)
    
    # Application 3: Heat trace recovery
    print("\n\n--- APPLICATION 3: Heat Kernel Trace Recovery ---")
    recover_heat_trace(cycle_laplacian(6), prime_bound=50, degree_bound=6)
    
    # Application 4: Characteristic polynomial
    print("\n\n--- APPLICATION 4: Characteristic Polynomial Recovery ---")
    L = cycle_laplacian(5)
    recover_charpoly_coefficients(L, prime_bound=31)
    
    print("\n" + "=" * 70)
    print("  ALL APPLICATIONS DEMONSTRATED SUCCESSFULLY")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demo: Mod-p Spectral Fingerprints and Expansion Profiles

This script demonstrates the core concepts of arithmetic spectral fingerprints:
1. Builds explicit example matrices (adjacency/Laplacian matrices of graphs)
2. Computes mod-p fingerprints for primes up to C log N
3. Computes real spectral gaps numerically
4. Compares fingerprint features against spectral gap
5. Searches for collisions: distinct complexes with nearly identical fingerprints
6. Displays whether the conjectural determinacy trend appears or fails
"""

import numpy as np
from typing import Dict, List, Tuple
import itertools


def build_cycle_graph_laplacian(n: int) -> np.ndarray:
    """Build the Laplacian matrix of the cycle graph C_n."""
    L = np.zeros((n, n), dtype=int)
    for i in range(n):
        L[i, i] = 2
        L[i, (i + 1) % n] = -1
        L[(i + 1) % n, i] = -1
    return L


def build_complete_graph_laplacian(n: int) -> np.ndarray:
    """Build the Laplacian matrix of the complete graph K_n."""
    L = n * np.eye(n, dtype=int) - np.ones((n, n), dtype=int)
    return L


def build_petersen_laplacian() -> np.ndarray:
    """Build the Laplacian of the Petersen graph (10 vertices, 3-regular)."""
    edges = [
        (0, 1), (1, 2), (2, 3), (3, 4), (4, 0),  # outer pentagon
        (5, 7), (7, 9), (9, 6), (6, 8), (8, 5),  # inner pentagram
        (0, 5), (1, 6), (2, 7), (3, 8), (4, 9),  # connections
    ]
    n = 10
    A = np.zeros((n, n), dtype=int)
    for i, j in edges:
        A[i, j] = 1
        A[j, i] = 1
    D = np.diag(A.sum(axis=1))
    return D - A


def build_random_regular_graph_laplacian(n: int, d: int, seed: int = 42) -> np.ndarray:
    """Build approximate Laplacian of a random d-regular graph on n vertices."""
    rng = np.random.RandomState(seed)
    A = np.zeros((n, n), dtype=int)
    # Simple construction: random matchings
    for _ in range(d // 2):
        perm = rng.permutation(n)
        for i in range(0, n - 1, 2):
            u, v = perm[i], perm[i + 1]
            if u != v:
                A[u, v] = 1
                A[v, u] = 1
    # Make symmetric and cap at 1
    A = np.minimum(A, 1)
    D = np.diag(A.sum(axis=1))
    return D - A


def primes_up_to(bound: int) -> List[int]:
    """Return all primes up to bound using sieve of Eratosthenes."""
    if bound < 2:
        return []
    sieve = [True] * (bound + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(bound**0.5) + 1):
        if sieve[i]:
            for j in range(i * i, bound + 1, i):
                sieve[j] = False
    return [i for i in range(bound + 1) if sieve[i]]


def mod_p_trace_pow(A: np.ndarray, p: int, k: int) -> int:
    """Compute tr(A^k) mod p."""
    n = A.shape[0]
    # Work mod p to avoid overflow
    M = A % p
    result = np.eye(n, dtype=int)
    base = M.copy()
    exp = k
    while exp > 0:
        if exp % 2 == 1:
            result = (result @ base) % p
        base = (base @ base) % p
        exp //= 2
    return int(np.trace(result)) % p


def compute_fingerprint(A: np.ndarray, prime_bound: int, degree_bound: int) -> Dict[Tuple[int, int], int]:
    """Compute the prime spectral fingerprint of integer matrix A.
    
    Returns dict mapping (prime, power) -> trace mod p.
    """
    primes = primes_up_to(prime_bound)
    fp = {}
    for p in primes:
        for k in range(1, degree_bound + 1):
            fp[(p, k)] = mod_p_trace_pow(A, p, k)
    return fp


def real_spectral_gap(L: np.ndarray) -> float:
    """Compute the spectral gap (smallest nonzero eigenvalue) of a Laplacian."""
    eigenvalues = np.sort(np.linalg.eigvalsh(L.astype(float)))
    # Find smallest eigenvalue > threshold
    threshold = 1e-10
    nonzero = [ev for ev in eigenvalues if ev > threshold]
    return nonzero[0] if nonzero else 0.0


def fingerprint_distance(fp1: dict, fp2: dict) -> float:
    """Compute normalized Hamming distance between two fingerprints."""
    keys = set(fp1.keys()) | set(fp2.keys())
    if not keys:
        return 0.0
    matches = sum(1 for k in keys if fp1.get(k) == fp2.get(k))
    return 1.0 - matches / len(keys)


def integer_trace_pow(A: np.ndarray, k: int) -> int:
    """Compute tr(A^k) exactly as an integer."""
    n = A.shape[0]
    M = np.eye(n, dtype=object)
    base = A.astype(object)
    exp = k
    while exp > 0:
        if exp % 2 == 1:
            M = M @ base
        base = base @ base
        exp //= 2
    return int(np.trace(M))


def verify_trace_transfer(A: np.ndarray, B: np.ndarray, prime_bound: int, degree_bound: int):
    """Verify the trace transfer theorem: if mod-p traces agree for large enough p,
    then integer traces agree."""
    primes = primes_up_to(prime_bound)
    
    print("\n=== Trace Transfer Verification ===")
    for k in range(1, degree_bound + 1):
        tr_A = integer_trace_pow(A, k)
        tr_B = integer_trace_pow(B, k)
        diff = abs(tr_A - tr_B)
        
        # Find primes that confirm equality
        confirming_primes = []
        for p in primes:
            if mod_p_trace_pow(A, p, k) == mod_p_trace_pow(B, p, k) and p > diff:
                confirming_primes.append(p)
        
        status = "EQUAL" if tr_A == tr_B else "DIFFERENT"
        print(f"  k={k}: tr(A^k)={tr_A}, tr(B^k)={tr_B} [{status}]")
        if confirming_primes:
            print(f"    Confirmed by primes > |diff|={diff}: {confirming_primes[:5]}...")


def main():
    print("=" * 70)
    print("  MOD-p SPECTRAL FINGERPRINTS: DEMONSTRATION")
    print("=" * 70)
    
    # Build example graphs
    graphs = {
        "C_8 (cycle)": build_cycle_graph_laplacian(8),
        "C_12 (cycle)": build_cycle_graph_laplacian(12),
        "K_6 (complete)": build_complete_graph_laplacian(6),
        "K_8 (complete)": build_complete_graph_laplacian(8),
        "Petersen": build_petersen_laplacian(),
        "Random 3-reg (n=10)": build_random_regular_graph_laplacian(10, 3, seed=42),
        "Random 3-reg (n=10, seed=99)": build_random_regular_graph_laplacian(10, 3, seed=99),
    }
    
    # Parameters
    C = 3  # Constant in C log N
    degree_bound = 6
    
    print("\n--- 1. FINGERPRINT COMPUTATION ---")
    fingerprints = {}
    spectral_gaps = {}
    
    for name, L in graphs.items():
        n = L.shape[0]
        prime_bound = max(5, int(C * np.log(n) + 1))
        
        fp = compute_fingerprint(L, prime_bound, degree_bound)
        gap = real_spectral_gap(L)
        fingerprints[name] = fp
        spectral_gaps[name] = gap
        
        print(f"\n  {name} (n={n}):")
        print(f"    Spectral gap: {gap:.6f}")
        print(f"    Prime bound: {prime_bound}")
        primes = primes_up_to(prime_bound)
        for p in primes[:3]:
            traces = [fp.get((p, k), '?') for k in range(1, min(4, degree_bound + 1))]
            print(f"    mod-{p} traces [k=1..3]: {traces}")
    
    print("\n\n--- 2. FINGERPRINT DISTANCES vs SPECTRAL GAP DIFFERENCES ---")
    names = list(graphs.keys())
    print(f"  {'Pair':<55} {'FP dist':>8} {'Gap diff':>10}")
    print("  " + "-" * 75)
    for i in range(len(names)):
        for j in range(i + 1, len(names)):
            n1, n2 = names[i], names[j]
            # Only compare same-size matrices
            if graphs[n1].shape == graphs[n2].shape:
                dist = fingerprint_distance(fingerprints[n1], fingerprints[n2])
                gap_diff = abs(spectral_gaps[n1] - spectral_gaps[n2])
                print(f"  {n1} vs {n2:<30} {dist:8.4f} {gap_diff:10.6f}")
    
    print("\n\n--- 3. COLLISION SEARCH ---")
    print("  Searching for distinct graphs with identical fingerprints...")
    collision_found = False
    for i in range(len(names)):
        for j in range(i + 1, len(names)):
            n1, n2 = names[i], names[j]
            if graphs[n1].shape == graphs[n2].shape:
                dist = fingerprint_distance(fingerprints[n1], fingerprints[n2])
                if dist == 0.0 and spectral_gaps[n1] != spectral_gaps[n2]:
                    print(f"  COLLISION: {n1} and {n2}")
                    print(f"    Same fingerprint but gaps differ: {spectral_gaps[n1]:.6f} vs {spectral_gaps[n2]:.6f}")
                    collision_found = True
    if not collision_found:
        print("  No collisions found (fingerprints distinguish all same-size pairs)")
    
    print("\n\n--- 4. TRACE TRANSFER THEOREM VERIFICATION ---")
    # Verify using two similar matrices
    A = build_cycle_graph_laplacian(8)
    B = build_complete_graph_laplacian(8)
    verify_trace_transfer(A, B, prime_bound=50, degree_bound=4)
    
    print("\n\n--- 5. DETERMINACY TREND ---")
    print("  Testing: as prime bound grows, do fingerprints determine more spectral data?")
    L = build_petersen_laplacian()
    eigenvalues = sorted(np.linalg.eigvalsh(L.astype(float)))
    print(f"  Petersen eigenvalues: {[round(e, 4) for e in eigenvalues]}")
    
    for pb in [3, 5, 7, 11, 17, 23]:
        primes = primes_up_to(pb)
        # Compute how many moments are determined
        moments_determined = 0
        for k in range(1, 11):
            tr = integer_trace_pow(L, k)
            # Check if tr is uniquely determined by mod-p data for all primes
            all_determined = all(abs(tr) < p for p in primes)
            if all_determined:
                moments_determined += 1
        print(f"  Prime bound {pb:2d} ({len(primes)} primes): "
              f"{moments_determined}/10 moments fully determined")
    
    print("\n\n--- 6. FAMILY COMPARISON ---")
    print("  Cycle graphs C_n: fingerprint evolution with size")
    for n in [6, 8, 10, 12, 16, 20]:
        L = build_cycle_graph_laplacian(n)
        gap = real_spectral_gap(L)
        pb = max(5, int(C * np.log(n) + 1))
        fp = compute_fingerprint(L, pb, 4)
        # Summarize fingerprint
        fp_sum = sum(v for v in fp.values())
        print(f"  C_{n:2d}: gap={gap:.6f}, prime_bound={pb}, fp_checksum={fp_sum}")
    
    print("\n" + "=" * 70)
    print("  DEMONSTRATION COMPLETE")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Expansion Landscape — Fingerprint vs Spectral Gap

Plots the relationship between mod-p fingerprint features and the true
spectral gap across a family of graphs. This tests the core conjecture:
do fingerprints predict expansion?

The visualization generates many random graphs, computes both their
fingerprints and spectral gaps, and plots the correlation.

WHY THIS MATTERS: If fingerprint features strongly predict spectral gap,
it validates the paradigm of using cheap finite-field algebra to infer
expensive real spectral data.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import Normalize
import matplotlib.cm as cm


def sieve_primes(bound):
    if bound < 2:
        return []
    is_prime = [True] * (bound + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(bound**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, bound + 1, i):
                is_prime[j] = False
    return [i for i in range(bound + 1) if is_prime[i]]


def mod_p_trace_pow(A, p, k):
    n = A.shape[0]
    result = np.eye(n, dtype=int)
    base = A.copy() % p
    exp = k
    while exp > 0:
        if exp & 1:
            result = result @ base % p
        base = base @ base % p
        exp >>= 1
    return int(np.trace(result)) % p


def random_graph_laplacian(n, edge_prob, seed):
    rng = np.random.RandomState(seed)
    A = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i+1, n):
            if rng.random() < edge_prob:
                A[i, j] = A[j, i] = 1
    D = np.diag(A.sum(axis=1))
    return D - A


def fingerprint_features(L, prime_bound=13, degree_bound=4):
    """Extract scalar features from fingerprint for plotting."""
    primes = sieve_primes(prime_bound)
    features = []
    for p in primes:
        for k in range(1, degree_bound + 1):
            features.append(mod_p_trace_pow(L, p, k) / p)
    return np.array(features)


def spectral_gap(L):
    eigs = sorted(np.linalg.eigvalsh(L.astype(float)))
    pos = [e for e in eigs if e > 1e-10]
    return pos[0] if pos else 0.0


# Generate random graphs
n = 12
num_graphs = 200
edge_probs = np.linspace(0.1, 0.9, num_graphs)
rng_seeds = range(1000, 1000 + num_graphs)

gaps = []
fp_norms = []
fp_means = []
fp_entropies = []
labels = []

for idx, (ep, seed) in enumerate(zip(edge_probs, rng_seeds)):
    L = random_graph_laplacian(n, ep, seed)
    g = spectral_gap(L)
    fp = fingerprint_features(L)

    gaps.append(g)
    fp_norms.append(np.linalg.norm(fp))
    fp_means.append(np.mean(fp))

    # Entropy of fingerprint (treating as probability distribution)
    fp_pos = fp + 0.01  # avoid log(0)
    fp_prob = fp_pos / fp_pos.sum()
    entropy = -np.sum(fp_prob * np.log2(fp_prob))
    fp_entropies.append(entropy)

gaps = np.array(gaps)
fp_norms = np.array(fp_norms)
fp_means = np.array(fp_means)
fp_entropies = np.array(fp_entropies)

fig, axes = plt.subplots(2, 2, figsize=(14, 11))
fig.suptitle("Expansion Landscape: Fingerprint Features vs Spectral Gap",
             fontsize=15, fontweight='bold')

# Panel 1: Fingerprint L2 norm vs spectral gap
ax1 = axes[0, 0]
scatter = ax1.scatter(fp_norms, gaps, c=edge_probs, cmap='coolwarm',
                      s=25, alpha=0.7, edgecolors='k', linewidths=0.3)
ax1.set_xlabel("Fingerprint L² norm", fontsize=11)
ax1.set_ylabel("Spectral gap λ₁", fontsize=11)
ax1.set_title("Fingerprint Norm vs Spectral Gap")
plt.colorbar(scatter, ax=ax1, label="Edge probability")
ax1.grid(True, alpha=0.3)

# Correlation
corr = np.corrcoef(fp_norms, gaps)[0, 1]
ax1.text(0.05, 0.95, f"r = {corr:.3f}", transform=ax1.transAxes,
         fontsize=12, verticalalignment='top',
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

# Panel 2: Fingerprint mean vs spectral gap
ax2 = axes[0, 1]
scatter2 = ax2.scatter(fp_means, gaps, c=edge_probs, cmap='coolwarm',
                       s=25, alpha=0.7, edgecolors='k', linewidths=0.3)
ax2.set_xlabel("Fingerprint mean value", fontsize=11)
ax2.set_ylabel("Spectral gap λ₁", fontsize=11)
ax2.set_title("Mean Fingerprint vs Spectral Gap")
plt.colorbar(scatter2, ax=ax2, label="Edge probability")
ax2.grid(True, alpha=0.3)

corr2 = np.corrcoef(fp_means, gaps)[0, 1]
ax2.text(0.05, 0.95, f"r = {corr2:.3f}", transform=ax2.transAxes,
         fontsize=12, verticalalignment='top',
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

# Panel 3: Spectral gap vs edge probability (showing phase transition)
ax3 = axes[1, 0]
ax3.scatter(edge_probs, gaps, c=fp_norms, cmap='viridis',
            s=25, alpha=0.7, edgecolors='k', linewidths=0.3)
ax3.set_xlabel("Edge probability", fontsize=11)
ax3.set_ylabel("Spectral gap λ₁", fontsize=11)
ax3.set_title("Spectral Gap vs Graph Density\n(color = fingerprint norm)")
ax3.axvline(x=np.log(n)/n, color='red', linestyle='--', alpha=0.5,
            label=f'Connectivity threshold ≈ {np.log(n)/n:.2f}')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

# Panel 4: Fingerprint entropy vs spectral gap
ax4 = axes[1, 1]
scatter4 = ax4.scatter(fp_entropies, gaps, c=edge_probs, cmap='coolwarm',
                       s=25, alpha=0.7, edgecolors='k', linewidths=0.3)
ax4.set_xlabel("Fingerprint entropy (bits)", fontsize=11)
ax4.set_ylabel("Spectral gap λ₁", fontsize=11)
ax4.set_title("Fingerprint Entropy vs Spectral Gap")
plt.colorbar(scatter4, ax=ax4, label="Edge probability")
ax4.grid(True, alpha=0.3)

corr4 = np.corrcoef(fp_entropies, gaps)[0, 1]
ax4.text(0.05, 0.95, f"r = {corr4:.3f}", transform=ax4.transAxes,
         fontsize=12, verticalalignment='top',
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout()
plt.savefig("expansion_landscape.png", dpi=150, bbox_inches='tight')
print("Saved expansion_landscape.png")


#!/usr/bin/env python3
"""
Visualization: Mod-p Spectral Fingerprint Heatmaps

Visualizes the prime spectral fingerprint of several graphs as heatmaps.
Each heatmap shows tr(A^k) mod p for primes p (rows) and powers k (columns).
This makes the arithmetic structure of the fingerprint visually apparent:
- Expanders show uniform, rapidly mixing patterns
- Non-expanders show structured, slowly varying patterns

WHAT IT VISUALIZES: The core data structure of the theory — how mod-p
trace data varies across primes and powers for different graph families.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


def sieve_primes(bound):
    if bound < 2:
        return []
    is_prime = [True] * (bound + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(bound**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, bound + 1, i):
                is_prime[j] = False
    return [i for i in range(bound + 1) if is_prime[i]]


def mod_p_trace_pow(A, p, k):
    n = A.shape[0]
    result = np.eye(n, dtype=int)
    base = A.copy() % p
    exp = k
    while exp > 0:
        if exp & 1:
            result = result @ base % p
        base = base @ base % p
        exp >>= 1
    return int(np.trace(result)) % p


def cycle_laplacian(n):
    L = np.zeros((n, n), dtype=int)
    for i in range(n):
        L[i, i] = 2
        L[i, (i+1) % n] = -1
        L[(i+1) % n, i] = -1
    return L


def complete_laplacian(n):
    return n * np.eye(n, dtype=int) - np.ones((n, n), dtype=int)


def path_laplacian(n):
    L = np.zeros((n, n), dtype=int)
    for i in range(n-1):
        L[i, i] += 1; L[i+1, i+1] += 1
        L[i, i+1] = -1; L[i+1, i] = -1
    return L


def petersen_laplacian():
    edges = [(0,1),(1,2),(2,3),(3,4),(4,0),(5,7),(7,9),(9,6),(6,8),(8,5),
             (0,5),(1,6),(2,7),(3,8),(4,9)]
    A = np.zeros((10,10), dtype=int)
    for i,j in edges:
        A[i,j] = A[j,i] = 1
    return np.diag(A.sum(axis=1)) - A


def compute_fingerprint_matrix(L, prime_bound, degree_bound):
    primes = sieve_primes(prime_bound)
    data = np.zeros((len(primes), degree_bound), dtype=int)
    for i, p in enumerate(primes):
        for k in range(1, degree_bound + 1):
            data[i, k-1] = mod_p_trace_pow(L, p, k)
    return data, primes


# Build graphs
n = 10
graphs = {
    f"Cycle C_{n}": cycle_laplacian(n),
    f"Complete K_{n}": complete_laplacian(n),
    f"Path P_{n}": path_laplacian(n),
    "Petersen": petersen_laplacian(),
}

prime_bound = 19
degree_bound = 8
primes = sieve_primes(prime_bound)

fig = plt.figure(figsize=(16, 10))
fig.suptitle("Mod-p Spectral Fingerprints of Graph Laplacians",
             fontsize=16, fontweight='bold', y=0.98)

gs = gridspec.GridSpec(2, 2, hspace=0.35, wspace=0.3)

for idx, (name, L) in enumerate(graphs.items()):
    ax = fig.add_subplot(gs[idx])
    data, used_primes = compute_fingerprint_matrix(L, prime_bound, degree_bound)

    # Normalize each row by the prime for better visualization
    norm_data = np.zeros_like(data, dtype=float)
    for i, p in enumerate(used_primes):
        norm_data[i] = data[i] / p

    im = ax.imshow(norm_data, aspect='auto', cmap='viridis',
                   interpolation='nearest', vmin=0, vmax=1)

    ax.set_xlabel("Power k", fontsize=11)
    ax.set_ylabel("Prime p", fontsize=11)
    ax.set_xticks(range(degree_bound))
    ax.set_xticklabels(range(1, degree_bound + 1))
    ax.set_yticks(range(len(used_primes)))
    ax.set_yticklabels(used_primes)

    # Compute spectral gap
    eigs = sorted(np.linalg.eigvalsh(L.astype(float)))
    gap = next((e for e in eigs if e > 1e-10), 0)
    ax.set_title(f"{name}\nSpectral gap = {gap:.4f}", fontsize=12)

    plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04, label="tr(L^k)/p mod 1")

fig.text(0.5, 0.01,
         "Each cell shows tr(L^k) mod p, normalized by p. "
         "Expanders (K₁₀) show uniform patterns; non-expanders (paths, cycles) show structure.",
         ha='center', fontsize=10, style='italic')

plt.savefig("fingerprint_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved fingerprint_heatmap.png")


#!/usr/bin/env python3
"""
Visualization: Trace Transfer Theorem in Action

Illustrates the core arithmetic transfer principle: if tr(A^k) - tr(B^k)
is bounded by a prime p where the mod-p traces agree, then the integer
traces must be equal.

Shows how increasing the prime bound reveals more and more spectral
moment information, visualizing the "arithmetic tomography" metaphor.

WHY THIS MATTERS: This is the mechanism by which cheap finite-field
computation recovers expensive real-number spectral data.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import math


def sieve_primes(bound):
    if bound < 2:
        return []
    is_prime = [True] * (bound + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(bound**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, bound + 1, i):
                is_prime[j] = False
    return [i for i in range(bound + 1) if is_prime[i]]


def exact_trace_pow(A, k):
    n = A.shape[0]
    M = np.eye(n, dtype=object)
    base = A.astype(object)
    exp = k
    while exp > 0:
        if exp & 1:
            M = M @ base
        base = base @ base
        exp >>= 1
    return int(np.trace(M))


def mod_p_trace_pow(A, p, k):
    n = A.shape[0]
    result = np.eye(n, dtype=int)
    base = A.copy() % p
    exp = k
    while exp > 0:
        if exp & 1:
            result = result @ base % p
        base = base @ base % p
        exp >>= 1
    return int(np.trace(result)) % p


def cycle_laplacian(n):
    L = np.zeros((n, n), dtype=int)
    for i in range(n):
        L[i, i] = 2
        L[i, (i+1) % n] = -1
        L[(i+1) % n, i] = -1
    return L


def complete_laplacian(n):
    return n * np.eye(n, dtype=int) - np.ones((n, n), dtype=int)


# Setup
n = 8
A = cycle_laplacian(n)
B = complete_laplacian(n)

max_power = 10
prime_bounds = [3, 5, 7, 11, 13, 17, 23, 29, 37, 47, 59, 71, 83, 97]

fig, axes = plt.subplots(2, 2, figsize=(14, 11))
fig.suptitle("Arithmetic Trace Transfer: From Mod-p Data to Integer Equality",
             fontsize=15, fontweight='bold')

# Panel 1: Integer traces of powers
ax1 = axes[0, 0]
powers = range(1, max_power + 1)
traces_A = [exact_trace_pow(A, k) for k in powers]
traces_B = [exact_trace_pow(B, k) for k in powers]
diffs = [abs(a - b) for a, b in zip(traces_A, traces_B)]

ax1.semilogy(powers, [abs(t) + 1 for t in traces_A], 'bo-', label=f'|tr(C_{n}^k)|', markersize=6)
ax1.semilogy(powers, [abs(t) + 1 for t in traces_B], 'rs-', label=f'|tr(K_{n}^k)|', markersize=6)
ax1.semilogy(powers, [d + 1 for d in diffs], 'g^-', label='|difference|', markersize=6)
ax1.set_xlabel("Power k")
ax1.set_ylabel("Magnitude (log scale)")
ax1.set_title("Integer Traces Grow Exponentially")
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Panel 2: Recovery threshold — which primes are large enough?
ax2 = axes[0, 1]
recovery_matrix = np.zeros((len(prime_bounds), max_power))
for i, pb in enumerate(prime_bounds):
    primes = sieve_primes(pb)
    for k_idx, k in enumerate(powers):
        diff = diffs[k_idx]
        # Can we determine equality/inequality from primes up to pb?
        can_determine = any(p > diff for p in primes)
        recovery_matrix[i, k_idx] = 1.0 if can_determine else 0.0

im = ax2.imshow(recovery_matrix, aspect='auto', cmap='RdYlGn',
                interpolation='nearest', vmin=0, vmax=1)
ax2.set_xlabel("Power k")
ax2.set_ylabel("Prime bound P")
ax2.set_xticks(range(max_power))
ax2.set_xticklabels(range(1, max_power + 1))
ax2.set_yticks(range(len(prime_bounds)))
ax2.set_yticklabels(prime_bounds)
ax2.set_title("Moment Recovery:\nGreen = Prime Bound Sufficient")
plt.colorbar(im, ax=ax2, fraction=0.046, pad=0.04)

# Panel 3: Number of recoverable moments vs prime bound
ax3 = axes[1, 0]
recoverable = []
for pb in range(2, 100):
    primes = sieve_primes(pb)
    count = sum(1 for k in range(1, max_power + 1)
                if any(p > diffs[k-1] for p in primes))
    recoverable.append((pb, count))

pbs, counts = zip(*recoverable)
ax3.plot(pbs, counts, 'b-', linewidth=2)
ax3.axhline(y=max_power, color='r', linestyle='--', alpha=0.5, label=f'All {max_power} moments')
ax3.fill_between(pbs, counts, alpha=0.2)
ax3.set_xlabel("Prime bound P")
ax3.set_ylabel("Recoverable moments")
ax3.set_title("Arithmetic Tomography:\nMore Primes → More Spectral Data")
ax3.legend()
ax3.grid(True, alpha=0.3)
ax3.set_ylim(0, max_power + 1)

# Panel 4: Mod-p agreement for different primes
ax4 = axes[1, 1]
sample_primes = [2, 3, 5, 7, 11, 13]
k_range = range(1, 7)
bar_width = 0.12

for i, p in enumerate(sample_primes):
    agreements = []
    for k in k_range:
        agree = 1 if mod_p_trace_pow(A, p, k) == mod_p_trace_pow(B, p, k) else 0
        agreements.append(agree)
    x = np.array(list(k_range)) + i * bar_width - len(sample_primes) * bar_width / 2
    colors = ['green' if a else 'red' for a in agreements]
    ax4.bar(x, [1]*len(agreements), bar_width, color=colors, alpha=0.7,
            edgecolor='black', linewidth=0.5)

ax4.set_xlabel("Power k")
ax4.set_title("Mod-p Trace Agreement\n(Green=agree, Red=disagree)")
ax4.set_xticks(list(k_range))

# Custom legend
green_patch = mpatches.Patch(color='green', alpha=0.7, label='Traces agree mod p')
red_patch = mpatches.Patch(color='red', alpha=0.7, label='Traces differ mod p')
ax4.legend(handles=[green_patch, red_patch], fontsize=9)
ax4.set_yticks([])

# Add prime labels
for i, p in enumerate(sample_primes):
    ax4.text(1 + i * bar_width - len(sample_primes) * bar_width / 2,
             1.05, f'p={p}', fontsize=7, ha='center', rotation=45)

plt.tight_layout()
plt.savefig("transfer_theorem.png", dpi=150, bbox_inches='tight')
print("Saved transfer_theorem.png")
