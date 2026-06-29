#!/usr/bin/env python3
"""
Pythagorean Lattice Reduction — Core Algorithms

Implements the factoring-via-Pythagorean-lattice pipeline:
1. Berggren tree BFS with congruence filtering
2. Congruence-of-squares extraction
3. GCD-based factor extraction
4. Full factoring pipeline

All algorithms include complexity analysis and correctness checks.
"""

from math import gcd, isqrt, log2
from typing import List, Tuple, Optional, Set
from collections import deque
import numpy as np
import time


# ============================================================
# Berggren Generators
# ============================================================

BERGGREN_A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=np.int64)
BERGGREN_B = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=np.int64)
BERGGREN_C = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=np.int64)
BERGGREN_GENS = [BERGGREN_A, BERGGREN_B, BERGGREN_C]

ROOT = np.array([3, 4, 5], dtype=np.int64)


# ============================================================
# Algorithm 1: Berggren BFS with Congruence Filter
# ============================================================

def berggren_bfs_congruence(
    n: int,
    max_depth: int = 20,
    max_hypotenuse: int = None
) -> List[Tuple[int, int, int, int]]:
    """
    Breadth-first search of the Berggren tree, filtering for triples
    where n | (a² - b²).

    Args:
        n: Target composite number to factor.
        max_depth: Maximum tree depth.
        max_hypotenuse: Stop when hypotenuse exceeds this bound.

    Returns:
        List of (a, b, c, depth) tuples satisfying the congruence.

    Complexity:
        Time: O(3^d) where d = max_depth
        Space: O(3^d) for the BFS frontier
    """
    if max_hypotenuse is None:
        max_hypotenuse = n * n  # reasonable default

    results = []
    queue: deque = deque()
    queue.append((ROOT, 0))

    while queue:
        triple, depth = queue.popleft()
        a, b, c = int(triple[0]), int(triple[1]), int(triple[2])

        # Check congruence condition
        if (a**2 - b**2) % n == 0:
            results.append((a, b, c, depth))

        if depth >= max_depth:
            continue

        # Generate children
        for M in BERGGREN_GENS:
            child = M @ triple
            if abs(int(child[2])) <= max_hypotenuse:
                queue.append((child, depth + 1))

    return results


# ============================================================
# Algorithm 2: Congruence-of-Squares Factor Extraction
# ============================================================

def extract_factor_from_congruence(n: int, x: int, y: int) -> Optional[int]:
    """
    Given x² ≡ y² (mod n), extract a nontrivial factor of n.

    The key identity: x² - y² = (x-y)(x+y).
    If n | (x-y)(x+y) but n ∤ (x-y) and n ∤ (x+y),
    then gcd(n, x-y) or gcd(n, x+y) is a nontrivial factor.

    Args:
        n: Composite number to factor.
        x, y: Integers with x² ≡ y² (mod n).

    Returns:
        A nontrivial factor of n, or None if degenerate.

    Complexity: O(log n) for GCD computation.
    """
    assert (x**2 - y**2) % n == 0, f"Precondition failed: {x}² ≢ {y}² (mod {n})"

    for diff in [abs(x - y), abs(x + y)]:
        d = gcd(n, diff)
        if 1 < d < n:
            return d
    return None


# ============================================================
# Algorithm 3: Full Pythagorean Lattice Factoring Pipeline
# ============================================================

def pythagorean_lattice_factor(
    n: int,
    max_depth: int = 15,
    verbose: bool = False
) -> Optional[int]:
    """
    Factor n by searching the Berggren tree for congruence-of-squares witnesses.

    Pipeline:
        1. BFS the Berggren tree for triples (a,b,c) with n | (a²-b²)
        2. For each such triple, try gcd(n, |a±b|)
        3. Return first nontrivial factor found

    Args:
        n: Composite number to factor (n > 1).
        max_depth: Maximum Berggren tree depth to search.
        verbose: Print progress information.

    Returns:
        A nontrivial factor of n, or None if none found.

    Complexity:
        Time: O(3^d · log n) where d = search depth
        Space: O(3^d)

    Note: This is an exponential-time algorithm. The theoretical interest
    lies in the *structure* of the search space (the Berggren lattice),
    not in the raw complexity. The key open question is whether lattice
    reduction can find short vectors in polynomial time.
    """
    if n <= 1:
        return None

    # Quick trial division for small factors
    for p in [2, 3, 5, 7, 11, 13]:
        if n % p == 0 and n != p:
            return p

    if verbose:
        print(f"  Searching Berggren tree (depth ≤ {max_depth}) for n = {n}...")

    queue = deque()
    queue.append((ROOT, 0))
    triples_checked = 0

    while queue:
        triple, depth = queue.popleft()
        a, b, c = int(triple[0]), int(triple[1]), int(triple[2])
        triples_checked += 1

        # Check congruence
        if (a**2 - b**2) % n == 0:
            factor = extract_factor_from_congruence(n, a, b)
            if factor is not None:
                if verbose:
                    print(f"  Found at depth {depth}: ({a}, {b}, {c})")
                    print(f"  {a}² - {b}² = {a**2 - b**2} ≡ 0 (mod {n})")
                    print(f"  Factor: {factor}")
                    print(f"  Triples checked: {triples_checked}")
                return factor

        if depth < max_depth:
            for M in BERGGREN_GENS:
                queue.append((M @ triple, depth + 1))

    if verbose:
        print(f"  No factor found after checking {triples_checked} triples.")
    return None


# ============================================================
# Algorithm 4: Euclid Parametrization Search
# ============================================================

def euclid_parametrization_factor(n: int, bound: int = None) -> Optional[int]:
    """
    Factor n by searching Euclid-parametrized triples (m²-k², 2mk, m²+k²)
    for congruences of squares mod n.

    This is complementary to the Berggren BFS approach:
    Euclid covers triples by parameter space, Berggren by tree structure.

    Args:
        n: Composite number to factor.
        bound: Search bound for parameters m, k.

    Returns:
        A nontrivial factor of n, or None.
    """
    if bound is None:
        bound = isqrt(n) + 1

    for m in range(2, bound):
        for k in range(1, m):
            if gcd(m, k) != 1 or (m - k) % 2 == 0:
                continue  # skip non-primitive

            a = m**2 - k**2
            b = 2 * m * k
            # c = m**2 + k**2

            if (a**2 - b**2) % n == 0:
                factor = extract_factor_from_congruence(n, a, b)
                if factor is not None:
                    return factor
    return None


# ============================================================
# Algorithm 5: Lattice Norm Statistics
# ============================================================

def lattice_norm_statistics(n: int, depth: int = 8) -> dict:
    """
    Compute statistics on the ℓ¹ norms of Berggren triples
    satisfying the congruence condition mod n.

    Returns dictionary with min, max, mean, count of lattice members.
    """
    members = berggren_bfs_congruence(n, max_depth=depth)

    if not members:
        return {"count": 0, "min_norm": None, "max_norm": None, "mean_norm": None}

    norms = [abs(a) + abs(b) + abs(c) for a, b, c, _ in members]

    return {
        "count": len(members),
        "min_norm": min(norms),
        "max_norm": max(norms),
        "mean_norm": sum(norms) / len(norms),
        "min_triple": members[norms.index(min(norms))][:3],
        "factor_revealing": sum(
            1 for a, b, c, _ in members
            if extract_factor_from_congruence(n, a, b) is not None
        )
    }


# ============================================================
# Benchmarks
# ============================================================

def benchmark():
    """Run factoring benchmarks on various composites."""
    print("=" * 70)
    print("BENCHMARK: Pythagorean Lattice Factoring")
    print("=" * 70)
    print(f"\n{'n':>10} {'factors':>15} {'depth':>6} {'time (ms)':>10} {'result':>10}")
    print("-" * 55)

    test_numbers = [
        15, 21, 35, 55, 77, 91, 119, 143, 187, 221, 247, 299,
        323, 391, 437, 493, 551, 667, 713, 899, 1001, 1147, 1517, 2021
    ]

    for n in test_numbers:
        start = time.time()
        factor = pythagorean_lattice_factor(n, max_depth=10)
        elapsed = (time.time() - start) * 1000

        if factor:
            print(f"{n:>10} {f'{factor}×{n//factor}':>15} {'✓':>6} {elapsed:>10.1f} {'SUCCESS':>10}")
        else:
            print(f"{n:>10} {'?':>15} {'-':>6} {elapsed:>10.1f} {'TIMEOUT':>10}")


if __name__ == "__main__":
    benchmark()

    print("\n\nLattice Statistics for n = 91 (= 7 × 13):")
    stats = lattice_norm_statistics(91, depth=8)
    for key, val in stats.items():
        print(f"  {key}: {val}")
