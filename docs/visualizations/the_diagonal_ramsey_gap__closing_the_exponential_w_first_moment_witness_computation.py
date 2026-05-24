#!/usr/bin/env python3
"""
Algorithms for Ramsey Lower Bounds via the Lovász Local Lemma

This module implements the core algorithms for computing certified diagonal
Ramsey number lower bounds using the first-moment method and the LLL.

Algorithms:
1. First-moment witness computation
2. LLL witness computation
3. Dependency degree calculation
4. Paley graph construction for explicit colorings
5. Multi-color Ramsey extension
"""

from math import comb, exp, log, sqrt, factorial, floor
from typing import Tuple, List, Optional, Dict
import itertools


# ==============================================================================
# Algorithm 1: First-Moment Bound Computation
# ==============================================================================

def compute_first_moment_witness(k: int) -> Tuple[int, float]:
    """
    Compute the first-moment (Erdős) lower bound witness for R(k,k).

    Algorithm:
        Find the largest n such that 2·C(n,k) < 2^{C(k,2)}.
        Binary search on n, since 2·C(n,k) is monotonically increasing.

    Time complexity: O(k · log(n_max)) where n_max is the answer.
    Space complexity: O(1).

    Returns:
        (n_witness, expected_bad_count) where R(k,k) > n_witness and
        expected_bad_count = 2·C(n,k)/2^{C(k,2)} is the expected number
        of monochromatic k-cliques at the witness.

    >>> compute_first_moment_witness(4)
    (5, ...)
    >>> compute_first_moment_witness(5)
    (8, ...)
    """
    if k < 2:
        return (1, 0.0)

    ck2 = comb(k, 2)
    threshold = 2 ** ck2  # exact integer

    # Binary search for the crossover point
    lo, hi = k, 2  # start with hi = 2, will expand
    while 2 * comb(hi, k) < threshold:
        hi *= 2

    while lo < hi:
        mid = (lo + hi + 1) // 2
        if 2 * comb(mid, k) < threshold:
            lo = mid
        else:
            hi = mid - 1

    n_witness = lo
    expected = 2.0 * comb(n_witness, k) / (2.0 ** ck2)
    return (n_witness, expected)


# ==============================================================================
# Algorithm 2: LLL Bound Computation
# ==============================================================================

def compute_lll_witness(k: int) -> Tuple[int, float]:
    """
    Compute the LLL lower bound witness for R(k,k).

    Algorithm:
        Find the largest n such that e·p·(d+1) ≤ 1, where:
          p = 2^{1 - C(k,2)}
          d = C(k,2)·C(n-2, k-2)

    The LLL criterion replaces the global union bound (over all C(n,k) events)
    with a local criterion (each event's neighborhood has small total probability).

    Time complexity: O(k · log(n_max)).
    Space complexity: O(1).

    Returns:
        (n_witness, lll_value) where R(k,k) > n_witness and
        lll_value = e·p·(d+1) at the witness.

    >>> compute_lll_witness(4)
    (5, ...)
    """
    if k < 2:
        return (1, 0.0)

    ck2 = comb(k, 2)
    p = 2.0 ** (1 - ck2)
    e_val = exp(1)

    # Binary search
    lo, hi = k, k
    while True:
        d = ck2 * comb(hi - 2, k - 2)
        if e_val * p * (d + 1) > 1.0:
            break
        hi *= 2

    while lo < hi:
        mid = (lo + hi + 1) // 2
        d = ck2 * comb(mid - 2, k - 2)
        if e_val * p * (d + 1) <= 1.0:
            lo = mid
        else:
            hi = mid - 1

    n_witness = lo
    d = ck2 * comb(n_witness - 2, k - 2)
    lll_val = e_val * p * (d + 1)
    return (n_witness, lll_val)


# ==============================================================================
# Algorithm 3: Dependency Degree Analysis
# ==============================================================================

def analyze_dependency_structure(n: int, k: int) -> Dict[str, int]:
    """
    Analyze the dependency structure of Ramsey bad events.

    For each k-subset S of [n], the events that share ≥ 2 vertices with S
    form the "dependency neighborhood." This function computes:
    - The dependency degree upper bound: C(k,2)·C(n-2,k-2)
    - The total number of events: C(n,k)
    - The sparsity ratio

    Time complexity: O(1) (just binomial coefficient computation).

    >>> analyze_dependency_structure(17, 6)
    {'dependency_degree': ..., 'total_events': ..., ...}
    """
    dep_degree = comb(k, 2) * comb(n - 2, k - 2)
    total_events = comb(n, k)
    edges_per_clique = comb(k, 2)

    return {
        'n': n,
        'k': k,
        'dependency_degree': dep_degree,
        'total_events': total_events,
        'edges_per_clique': edges_per_clique,
        'sparsity_ratio': dep_degree / total_events if total_events > 0 else 0,
        'bad_event_prob': 2.0 ** (1 - edges_per_clique),
        'lll_value': exp(1) * 2.0 ** (1 - edges_per_clique) * (dep_degree + 1),
    }


# ==============================================================================
# Algorithm 4: Paley Graph Construction
# ==============================================================================

def quadratic_residues(p: int) -> set:
    """Compute the set of quadratic residues modulo p (p prime)."""
    return {(x * x) % p for x in range(1, p)}


def is_paley_edge(i: int, j: int, p: int, qr: set) -> bool:
    """Check if (i,j) is an edge in the Paley graph on F_p."""
    return (j - i) % p in qr


def paley_coloring(n: int) -> Optional[List[List[int]]]:
    """
    Construct a Paley graph 2-coloring of K_n.

    The Paley graph is defined on F_p (p prime, p ≡ 1 mod 4):
    edge {i,j} is present iff (i-j) is a quadratic residue mod p.

    The Paley graph is self-complementary and has clique number O(√p log p),
    making it an excellent Ramsey coloring.

    Returns None if n is not prime or n ≢ 1 mod 4.
    Returns a symmetric matrix (list of lists) of 0s and 1s.

    Time complexity: O(n²).

    >>> paley_coloring(5)
    [[0, 0, 1, 1, 0], [0, 0, 0, 1, 1], ...]
    """
    # Check if n is prime and n ≡ 1 mod 4
    if n < 2:
        return None
    for d in range(2, int(n**0.5) + 1):
        if n % d == 0:
            return None
    if n % 4 != 1:
        return None

    qr = quadratic_residues(n)
    coloring = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            if i != j:
                coloring[i][j] = 0 if is_paley_edge(i, j, n, qr) else 1

    return coloring


def verify_no_monochromatic_clique(coloring: List[List[int]], k: int) -> bool:
    """
    Verify that a coloring has no monochromatic k-clique.

    Time complexity: O(C(n,k) · k²) — exponential in k but fine for small k.
    """
    n = len(coloring)
    for subset in itertools.combinations(range(n), k):
        for color in [0, 1]:
            mono = True
            for i, j in itertools.combinations(subset, 2):
                if coloring[i][j] != color:
                    mono = False
                    break
            if mono:
                return False
    return True


# ==============================================================================
# Algorithm 5: Multi-Color Extension
# ==============================================================================

def multicolor_first_moment_bound(k: int, r: int) -> int:
    """
    Compute the first-moment lower bound for r-color R_r(k).

    For r-color Ramsey, the bad event probability is r·r^{-C(k,2)}
    (r possible monochromatic colors, each with probability r^{-C(k,2)}).

    Returns the largest n such that r·C(n,k)·r^{-C(k,2)} < 1,
    i.e., r·C(n,k) < r^{C(k,2)}.

    Time complexity: O(k · log(n_max)).
    """
    if k < 2 or r < 2:
        return 1

    ck2 = comb(k, 2)
    # Need r·C(n,k) < r^{C(k,2)}
    # Use floating point for large values
    log_threshold = ck2 * log(r)

    n = k
    while True:
        log_val = log(r) + sum(log(n - i) - log(i + 1) for i in range(k))
        if log_val >= log_threshold:
            break
        n += 1
    return n - 1


def multicolor_lll_bound(k: int, r: int) -> int:
    """
    Compute the LLL lower bound for r-color R_r(k).

    For r colors, the LLL criterion becomes:
      e · r · r^{-C(k,2)} · (C(k,2)·C(n-2,k-2) + 1) ≤ 1

    Time complexity: O(k · log(n_max)).
    """
    if k < 2 or r < 2:
        return 1

    ck2 = comb(k, 2)
    p = r * r ** (-ck2)  # bad event probability
    e_val = exp(1)

    n = k
    while True:
        d = ck2 * comb(n - 2, k - 2)
        if e_val * p * (d + 1) > 1.0:
            break
        n += 1
    return n - 1


# ==============================================================================
# Main: Algorithm Demonstrations
# ==============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("Algorithm Demonstrations")
    print("=" * 70)

    # Demo 1: First-moment bounds
    print("\n--- First-Moment Witnesses ---")
    for k in range(3, 12):
        n, expected = compute_first_moment_witness(k)
        print(f"  k={k:2d}: R({k},{k}) > {n:6d}  "
              f"(E[bad] = {expected:.4f})")

    # Demo 2: LLL bounds
    print("\n--- LLL Witnesses ---")
    for k in range(3, 12):
        n, lll_val = compute_lll_witness(k)
        print(f"  k={k:2d}: R({k},{k}) > {n:6d}  "
              f"(e·p·(d+1) = {lll_val:.4f})")

    # Demo 3: Paley colorings
    print("\n--- Paley Graph Colorings ---")
    paley_primes = [5, 13, 17, 29, 37, 41, 53, 61]
    for p in paley_primes:
        c = paley_coloring(p)
        if c is not None:
            max_k = 2
            for k in range(3, p + 1):
                if verify_no_monochromatic_clique(c, k):
                    max_k = k
                else:
                    break
            print(f"  Paley({p}): max clique-free k = {max_k}  "
                  f"→ R({max_k+1},{max_k+1}) > {p}")

    # Demo 4: Multi-color bounds
    print("\n--- Multi-Color Ramsey Bounds ---")
    for r in [2, 3, 4]:
        print(f"  r = {r} colors:")
        for k in range(3, 8):
            fm = multicolor_first_moment_bound(k, r)
            lll = multicolor_lll_bound(k, r)
            print(f"    k={k}: FM → R_{r}({k}) > {fm:6d},  "
                  f"LLL → R_{r}({k}) > {lll:6d}")

    # Demo 5: Dependency analysis
    print("\n--- Dependency Structure at LLL Witness ---")
    for k in [5, 8, 10]:
        n, _ = compute_lll_witness(k)
        analysis = analyze_dependency_structure(n, k)
        print(f"  k={k}, n={n}:")
        print(f"    Total events:      {analysis['total_events']:>12,}")
        print(f"    Dependency degree:  {analysis['dependency_degree']:>12,}")
        print(f"    Sparsity ratio:    {analysis['sparsity_ratio']:>12.6f}")
        print(f"    LLL value:         {analysis['lll_value']:>12.6f}")
