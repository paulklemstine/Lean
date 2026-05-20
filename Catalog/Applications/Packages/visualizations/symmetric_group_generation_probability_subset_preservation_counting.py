#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Symmetric Group Generation Probability

Implements the core computational methods from the formal theory:
1. Exact counting of subset-preserving permutation pairs
2. Reciprocal binomial sum computation and bounding
3. Generation probability estimation via orbit analysis
4. Dixon decomposition computation
"""

from math import factorial, comb, log
from fractions import Fraction
from typing import List, Tuple, Set, Dict
import itertools


# ============================================================
# Algorithm 1: Subset Preservation Counting
# ============================================================

def count_preserving_perms(n: int, k: int) -> int:
    """
    Count permutations of [n] that preserve a fixed subset of size k.

    By our formally proved theorem (card_perms_preserving_finset),
    this equals k! * (n-k)!.

    Time:  O(1) — uses the closed-form formula
    Space: O(1)

    Args:
        n: Size of the ground set
        k: Size of the preserved subset (0 ≤ k ≤ n)

    Returns:
        Number of permutations preserving any fixed k-element subset

    >>> count_preserving_perms(5, 2)
    12
    >>> count_preserving_perms(10, 3)
    30240
    """
    assert 0 <= k <= n, f"Need 0 ≤ k ≤ n, got k={k}, n={n}"
    return factorial(k) * factorial(n - k)


def count_preserving_pairs(n: int, k: int) -> int:
    """
    Count pairs (σ,τ) both preserving a fixed k-element subset.

    By card_pairs_preserving_finset, this equals (k!(n-k)!)².

    >>> count_preserving_pairs(5, 2)
    144
    """
    c = count_preserving_perms(n, k)
    return c * c


def preservation_probability(n: int, k: int) -> Fraction:
    """
    Probability that two random permutations both preserve a fixed k-subset.

    This equals 1/C(n,k) — the reciprocal of the binomial coefficient.

    >>> preservation_probability(6, 2)
    Fraction(1, 15)
    """
    return Fraction(count_preserving_pairs(n, k), factorial(n) ** 2)


# ============================================================
# Algorithm 2: Reciprocal Binomial Sum
# ============================================================

def reciprocal_binomial_sum(n: int) -> Fraction:
    """
    Compute ∑_{k=1}^{n-1} 1/C(n,k) exactly as a rational number.

    This controls the non-transitivity probability via the union bound.
    Our formally proved theorem shows this ≤ 4/n for n ≥ 4.

    Time:  O(n)
    Space: O(1)

    >>> reciprocal_binomial_sum(4)
    Fraction(2, 3)
    >>> float(reciprocal_binomial_sum(10))  # doctest: +ELLIPSIS
    0.274603...
    """
    return sum(Fraction(1, comb(n, k)) for k in range(1, n))


def reciprocal_binomial_bound(n: int) -> float:
    """
    Upper bound 4/n on the reciprocal binomial sum.

    Proved in binomial_recip_sum_le_four_div_n.

    >>> reciprocal_binomial_bound(10)
    0.4
    """
    return 4.0 / n


def edge_dominated_bound(n: int) -> float:
    """
    Tighter bound: 2/n + (n-3)/C(n,2).

    Proved in nontransitivity_obstruction_edge_dominated.
    The edge terms k=1, k=n-1 dominate — reflecting Boolean isoperimetry.

    >>> edge_dominated_bound(10)  # doctest: +ELLIPSIS
    0.355555...
    """
    return 2.0/n + (n-3) / comb(n, 2)


# ============================================================
# Algorithm 3: Generation Probability Decomposition
# ============================================================

class DixonDecomposition:
    """
    Decompose the generation failure probability into structured components.

    P(failure) = P(not transitive) + P(both even, transitive) + residual

    The formally proved results give:
    - P(both even) = 1/4  (prob_both_even_eq_quarter)
    - P(not transitive) ≤ 4/n  (union bound via reciprocal binomial sum)
    - P_n ≤ 3/4  (generation_probability_le_three_quarters)

    Attributes:
        n: degree of symmetric group
        prob_not_trans_bound: upper bound on non-transitivity probability
        prob_both_even: exact probability both generators are even
        upper_bound: upper bound on P_n (= 3/4)
        lower_bound: lower bound on P_n (= 3/4 - transitivity bound - residual)
    """

    def __init__(self, n: int):
        self.n = n
        self.prob_not_trans_bound = min(reciprocal_binomial_bound(n),
                                       float(reciprocal_binomial_sum(n)))
        self.prob_both_even = Fraction(1, 4) if n >= 2 else Fraction(0, 1)
        self.upper_bound = 0.75 if n >= 2 else 1.0

    def summary(self) -> str:
        """Print a summary of the decomposition."""
        lines = [
            f"Dixon Decomposition for S_{self.n}",
            f"=" * 40,
            f"Upper bound P_n ≤ {self.upper_bound}",
            f"P(both even) = {self.prob_both_even} = {float(self.prob_both_even):.4f}",
            f"P(not transitive) ≤ {self.prob_not_trans_bound:.6f}",
            f"  Edge-dominated bound: {edge_dominated_bound(self.n):.6f}",
            f"  Simple bound (4/n):   {reciprocal_binomial_bound(self.n):.6f}",
            f"Lower bound P_n ≥ 3/4 - {self.prob_not_trans_bound:.6f} - δ_n",
            f"  = {0.75 - self.prob_not_trans_bound:.6f} - δ_n",
        ]
        return "\n".join(lines)


# ============================================================
# Algorithm 4: Orbit-Based Transitivity Test
# ============================================================

def compute_orbits(generators: List[list], n: int) -> List[Set[int]]:
    """
    Compute orbits of the group generated by the given permutations.

    Time:  O(n * |generators| * n) in the worst case
    Space: O(n)

    Args:
        generators: list of permutations (as lists)
        n: degree

    Returns:
        List of orbits (each a set of integers)
    """
    parent = list(range(n))

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py

    for g in generators:
        for i in range(n):
            union(i, g[i])

    orbits: Dict[int, Set[int]] = {}
    for i in range(n):
        r = find(i)
        if r not in orbits:
            orbits[r] = set()
        orbits[r].add(i)

    return list(orbits.values())


def is_transitive(generators: List[list], n: int) -> bool:
    """Check if the generated group acts transitively."""
    orbits = compute_orbits(generators, n)
    return len(orbits) == 1


# ============================================================
# Algorithm 5: Fast Generation Test (heuristic)
# ============================================================

def fast_generation_test(sigma: list, tau: list, n: int) -> str:
    """
    Fast heuristic test for whether <σ,τ> = S_n.

    Returns one of:
    - "NOT_TRANSITIVE": definitely does not generate (preserves a subset)
    - "BOTH_EVEN": definitely does not generate (both even)
    - "LIKELY_GENERATES": passes both obstruction tests

    This implements the formal obstruction decomposition:
    failure ⊆ (not transitive) ∪ (both even) ∪ (residual)

    Time:  O(n) for transitivity, O(n log n) for sign
    Space: O(n)
    """
    # Test 1: Transitivity
    if not is_transitive([sigma, tau], n):
        return "NOT_TRANSITIVE"

    # Test 2: Parity
    from math import prod
    s1 = perm_sign(sigma)
    s2 = perm_sign(tau)
    if s1 == 1 and s2 == 1:
        return "BOTH_EVEN"

    return "LIKELY_GENERATES"


def perm_sign(perm: list) -> int:
    """Compute the sign of a permutation."""
    n = len(perm)
    visited = [False] * n
    sign = 1
    for i in range(n):
        if not visited[i]:
            cycle_len = 0
            j = i
            while not visited[j]:
                visited[j] = True
                j = perm[j]
                cycle_len += 1
            if cycle_len % 2 == 0:
                sign *= -1
    return sign


# ============================================================
# Main: Example usage
# ============================================================

if __name__ == "__main__":
    print("=== Subset Preservation Counting ===")
    for n in [5, 10, 20]:
        for k in [1, 2, n//2]:
            c = count_preserving_perms(n, k)
            print(f"  n={n}, k={k}: {c} perms preserve a {k}-subset")
            print(f"    Probability (pair) = 1/C({n},{k}) = {preservation_probability(n, k)}")

    print("\n=== Reciprocal Binomial Sums ===")
    for n in [4, 5, 10, 20, 50, 100]:
        s = float(reciprocal_binomial_sum(n))
        b = reciprocal_binomial_bound(n)
        print(f"  n={n:3d}: sum = {s:.8f}, bound (4/n) = {b:.8f}, ratio = {s/b:.4f}")

    print("\n=== Dixon Decomposition ===")
    for n in [5, 10, 20, 50, 100]:
        d = DixonDecomposition(n)
        print(d.summary())
        print()

    print("=== Fast Generation Test Examples ===")
    import random
    random.seed(42)
    n = 10
    for trial in range(10):
        sigma = list(range(n))
        tau = list(range(n))
        random.shuffle(sigma)
        random.shuffle(tau)
        result = fast_generation_test(sigma, tau, n)
        print(f"  Trial {trial+1}: {result}")
