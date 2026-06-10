#!/usr/bin/env python3
"""
Algorithms for Dynamical Ramanujan Analysis

Implements the core computational methods for studying squaring graphs
over finite fields and residue rings.

Algorithms:
    1. Sparse squaring graph construction
    2. Multiplicative core extraction
    3. Periodic point counting via GCD formula
    4. Idempotent enumeration via CRT
    5. Spectral analysis of squaring graphs
    6. Cheeger constant estimation
"""

import numpy as np
from math import gcd, isqrt
from typing import Dict, List, Set, Tuple, Optional
from collections import defaultdict


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 1: Sparse Squaring Graph Construction
# ═══════════════════════════════════════════════════════════════════════

def build_squaring_graph_sparse(n: int) -> Dict[int, Set[int]]:
    """
    Build the undirected squaring graph on ZMod n as an adjacency list.

    For each x in {0, ..., n-1}, compute y = x² mod n and add edges x-y.
    Excludes self-loops.

    Time: O(n)
    Space: O(n)

    Args:
        n: The modulus

    Returns:
        Dictionary mapping each vertex to its set of neighbors.

    Example:
        >>> G = build_squaring_graph_sparse(7)
        >>> sorted(G[2])  # neighbors of 2 in squaring graph mod 7
        [3, 4]
    """
    adj: Dict[int, Set[int]] = defaultdict(set)
    for x in range(n):
        y = (x * x) % n
        if x != y:
            adj[x].add(y)
            adj[y].add(x)
    return dict(adj)


def build_unit_squaring_graph(p: int) -> Dict[int, Set[int]]:
    """
    Build the unit squaring graph on (ZMod p)ˣ for prime p.

    Vertices are {1, 2, ..., p-1}. Edge x-y iff x² ≡ y or y² ≡ x (mod p).

    Time: O(p)
    Space: O(p)

    Args:
        p: An odd prime

    Returns:
        Adjacency list of the unit squaring graph.

    Example:
        >>> G = build_unit_squaring_graph(7)
        >>> sorted(G[3])
        [2]
    """
    adj: Dict[int, Set[int]] = defaultdict(set)
    for x in range(1, p):
        y = (x * x) % p
        if y != 0 and x != y:
            adj[x].add(y)
            adj[y].add(x)
    return dict(adj)


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 2: Multiplicative Core Extraction
# ═══════════════════════════════════════════════════════════════════════

def extract_multiplicative_core(n: int) -> Tuple[Set[int], Dict[int, Set[int]]]:
    """
    Extract the multiplicative core of the squaring graph on ZMod n.

    The multiplicative core consists of all units (elements coprime to n).
    For primes, this is {1, ..., p-1}. For composites, this excludes
    elements sharing a factor with n.

    Time: O(n)
    Space: O(n)

    Args:
        n: The modulus

    Returns:
        (vertices, adjacency_list) of the multiplicative core.

    Example:
        >>> V, G = extract_multiplicative_core(15)
        >>> sorted(V)
        [1, 2, 4, 7, 8, 11, 13, 14]
    """
    units = {x for x in range(1, n) if gcd(x, n) == 1}
    adj: Dict[int, Set[int]] = defaultdict(set)
    for x in units:
        y = (x * x) % n
        if y in units and x != y:
            adj[x].add(y)
            adj[y].add(x)
    return units, dict(adj)


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 3: Periodic Point Counting
# ═══════════════════════════════════════════════════════════════════════

def periodic_point_count_formula(p: int, m: int) -> int:
    """
    Compute |{x ∈ ZMod p : x^(2^m) = x}| using the GCD formula.

    By the formally verified theorem:
        count = 1 + gcd(2^m - 1, p - 1)

    This avoids iterating over all elements.

    Time: O(m + log p) — just computing 2^m and gcd
    Space: O(1)

    Args:
        p: An odd prime
        m: The iteration count (≥ 1)

    Returns:
        Number of periodic points.

    Example:
        >>> periodic_point_count_formula(7, 3)  # 1 + gcd(7, 6) = 1 + 1 = 2
        2
        >>> periodic_point_count_formula(7, 6)  # 1 + gcd(63, 6) = 1 + 3 = 4
        4
    """
    return 1 + gcd(2**m - 1, p - 1)


def periodic_point_count_brute(n: int, m: int) -> int:
    """
    Count periodic points by brute force: |{x ∈ ZMod n : x^(2^m) = x}|.

    Time: O(n · m)
    Space: O(1)
    """
    power = pow(2, m)
    return sum(1 for x in range(n) if pow(x, power, n) == x % n)


def verify_periodic_formula(max_p: int = 100, max_m: int = 10) -> bool:
    """
    Verify the periodic point formula for all primes up to max_p.

    Returns True if all checks pass.
    """
    def is_prime(n):
        if n < 2: return False
        if n < 4: return True
        if n % 2 == 0 or n % 3 == 0: return False
        i = 5
        while i * i <= n:
            if n % i == 0 or n % (i + 2) == 0: return False
            i += 6
        return True

    for p in range(3, max_p):
        if not is_prime(p):
            continue
        for m in range(1, max_m):
            formula = periodic_point_count_formula(p, m)
            brute = periodic_point_count_brute(p, m)
            if formula != brute:
                print(f"MISMATCH at p={p}, m={m}: formula={formula}, brute={brute}")
                return False
    return True


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 4: Idempotent Enumeration via CRT
# ═══════════════════════════════════════════════════════════════════════

def find_idempotents(n: int) -> List[int]:
    """
    Find all idempotents in ZMod n: elements e with e² ≡ e (mod n).

    For prime p, returns [0, 1].
    For n = p₁^a₁ · ... · pₖ^aₖ, returns 2^k idempotents (by CRT).

    Time: O(n) brute force, or O(2^ω(n)) via CRT
    Space: O(2^ω(n))

    Args:
        n: The modulus

    Returns:
        Sorted list of idempotents.

    Example:
        >>> find_idempotents(7)   # prime
        [0, 1]
        >>> find_idempotents(15)  # = 3 × 5
        [0, 1, 6, 10]
    """
    return sorted(e for e in range(n) if (e * e) % n == e)


def find_nontrivial_idempotents(n: int) -> List[int]:
    """
    Find nontrivial idempotents (≠ 0, 1) in ZMod n.

    These exist iff n has ≥ 2 distinct prime factors.
    Each nontrivial idempotent generates a squaring-invariant subset.
    """
    return [e for e in find_idempotents(n) if e != 0 and e != 1]


def idempotent_ideal(n: int, e: int) -> Set[int]:
    """
    Compute the principal ideal generated by idempotent e in ZMod n.

    Returns {r·e mod n : r ∈ ZMod n}.

    This set is squaring-invariant (formally verified).
    """
    return {(r * e) % n for r in range(n)}


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 5: Spectral Analysis
# ═══════════════════════════════════════════════════════════════════════

def adjacency_matrix(n: int, unit_only: bool = False) -> np.ndarray:
    """
    Build the adjacency matrix of the squaring graph.

    Args:
        n: The modulus
        unit_only: If True, restrict to the unit group

    Returns:
        Symmetric adjacency matrix as numpy array.
    """
    if unit_only:
        units = [x for x in range(1, n) if gcd(x, n) == 1]
        idx = {u: i for i, u in enumerate(units)}
        k = len(units)
        A = np.zeros((k, k), dtype=float)
        for x in units:
            y = (x * x) % n
            if y in idx:
                i, j = idx[x], idx[y]
                if i != j:
                    A[i][j] = 1
                    A[j][i] = 1
        return A
    else:
        A = np.zeros((n, n), dtype=float)
        for x in range(n):
            y = (x * x) % n
            if x != y:
                A[x][y] = 1
                A[y][x] = 1
        return A


def compute_spectrum(A: np.ndarray) -> np.ndarray:
    """
    Compute sorted eigenvalues of a symmetric matrix.

    Time: O(n³) via standard eigendecomposition
    Space: O(n²)

    Returns:
        Eigenvalues sorted in decreasing order.
    """
    eigs = np.linalg.eigvalsh(A)
    return np.sort(eigs)[::-1]


def spectral_data(n: int, unit_only: bool = False) -> dict:
    """
    Compute comprehensive spectral data for the squaring graph mod n.

    Returns dictionary with:
        - eigenvalues: full sorted spectrum
        - lambda_1: largest eigenvalue
        - lambda_2: second-largest |eigenvalue|
        - spectral_gap: λ₁ - |λ₂|
        - normalized_gap: spectral_gap / λ₁
    """
    A = adjacency_matrix(n, unit_only=unit_only)
    eigs = compute_spectrum(A)

    if len(eigs) == 0:
        return {"eigenvalues": eigs, "lambda_1": 0, "lambda_2": 0,
                "spectral_gap": 0, "normalized_gap": 0}

    lam1 = eigs[0]
    abs_eigs = sorted(np.abs(eigs), reverse=True)
    lam2 = abs_eigs[1] if len(abs_eigs) > 1 else 0.0

    return {
        "eigenvalues": eigs,
        "lambda_1": lam1,
        "lambda_2": lam2,
        "spectral_gap": lam1 - lam2,
        "normalized_gap": (lam1 - lam2) / lam1 if lam1 > 0 else 0,
    }


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 6: Cheeger Constant Estimation
# ═══════════════════════════════════════════════════════════════════════

def cheeger_constant_estimate(n: int, samples: int = 1000) -> float:
    """
    Estimate the Cheeger constant of the squaring graph on ZMod n
    by random sampling of vertex subsets.

    The Cheeger constant h(G) = min_{|S| ≤ n/2} |∂S| / |S|
    where ∂S is the edge boundary.

    Time: O(samples · n)
    Space: O(n)

    This is a heuristic upper bound (may not find the true minimum).
    """
    G = build_squaring_graph_sparse(n)
    best_ratio = float('inf')

    rng = np.random.default_rng(42)
    for _ in range(samples):
        # Random subset of size between 1 and n//2
        size = rng.integers(1, max(2, n // 2 + 1))
        S = set(rng.choice(n, size=size, replace=False))

        if len(S) == 0 or len(S) > n // 2:
            continue

        # Count edge boundary
        boundary = 0
        for x in S:
            for y in G.get(x, set()):
                if y not in S:
                    boundary += 1

        ratio = boundary / len(S)
        best_ratio = min(best_ratio, ratio)

    return best_ratio


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 7: Prime vs Composite Comparison
# ═══════════════════════════════════════════════════════════════════════

def prime_composite_spectral_comparison(max_n: int = 200) -> dict:
    """
    Compare spectral properties of squaring graphs for primes vs composites.

    Returns comprehensive comparison data.
    """
    def is_prime(n):
        if n < 2: return False
        if n < 4: return True
        if n % 2 == 0 or n % 3 == 0: return False
        i = 5
        while i * i <= n:
            if n % i == 0 or n % (i + 2) == 0: return False
            i += 6
        return True

    prime_data = []
    composite_data = []

    for n in range(3, max_n):
        sd = spectral_data(n, unit_only=False)
        entry = {
            "n": n,
            "lambda_2": sd["lambda_2"],
            "spectral_gap": sd["spectral_gap"],
            "normalized_gap": sd["normalized_gap"],
            "sqrt_n": np.sqrt(n),
            "ratio": sd["lambda_2"] / np.sqrt(n) if np.sqrt(n) > 0 else 0,
        }

        if is_prime(n):
            entry["type"] = "prime"
            prime_data.append(entry)
        else:
            entry["type"] = "composite"
            entry["omega"] = sum(1 for d in range(2, n) if n % d == 0 and is_prime(d))
            composite_data.append(entry)

    return {"primes": prime_data, "composites": composite_data}


# ═══════════════════════════════════════════════════════════════════════
# Self-test
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Running self-tests...")

    # Test periodic point formula
    assert verify_periodic_formula(50, 8), "Periodic point formula verification failed!"
    print("  ✓ Periodic point formula verified for all primes < 50, m < 8")

    # Test idempotent counts
    assert find_idempotents(7) == [0, 1], "Prime idempotent count wrong"
    assert len(find_idempotents(15)) == 4, "Composite idempotent count wrong (15 = 3×5)"
    assert len(find_idempotents(30)) == 8, "Composite idempotent count wrong (30 = 2×3×5)"
    print("  ✓ Idempotent enumeration verified")

    # Test squaring invariance of idempotent ideals
    for n in [6, 10, 15, 21, 30]:
        for e in find_nontrivial_idempotents(n):
            ideal = idempotent_ideal(n, e)
            for x in ideal:
                assert (x * x) % n in ideal, f"Squaring invariance failed: n={n}, e={e}, x={x}"
    print("  ✓ Idempotent ideal squaring-invariance verified")

    # Test spectral computation
    sd = spectral_data(7, unit_only=True)
    assert sd["lambda_1"] > 0, "Spectral computation failed"
    print("  ✓ Spectral analysis operational")

    print("\nAll self-tests passed! ✓")
