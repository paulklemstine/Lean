#!/usr/bin/env python3
"""
algorithms.py — Shadow Decay Profile Algorithms

Implements core algorithms for computing and analyzing shadow decay profiles
of polynomial supports, including:

1. Exact k-th shadow computation
2. Shadow profile computation
3. Circuit shadow envelope evaluation
4. Normalized decay analysis
5. Elementary symmetric support construction

All algorithms include complexity analysis and docstrings.
"""

import itertools
from math import comb
from typing import Set, Tuple, Dict, List, FrozenSet


# Type aliases
MultiIndex = tuple  # Tuple[int, ...]
Support = Set[MultiIndex]


def kth_shadow(S: Support, k: int, n: int) -> Support:
    """
    Compute the k-th downward shadow of a support set.

    Given S ⊆ ℕ^n and k ≥ 0, returns
      Shadow_k(S) = {β ∈ ℕ^n : ∃ α ∈ S, β ≤ α pointwise, Σ(αᵢ - βᵢ) = k}.

    Algorithm:
    For each α ∈ S, enumerate all ways to distribute k units of decrease
    across the n coordinates, respecting the bound αᵢ for each coordinate.
    This is done via recursive partitioning.

    Complexity:
    - Time: O(|S| · P(k, α_max, n)) where P is the number of valid partitions
    - Space: O(|Shadow_k(S)|)
    - For degree-d multilinear supports: O(|S| · C(n, k))

    Args:
        S: Set of multi-indices (tuples of non-negative integers)
        k: Shadow depth (non-negative integer)
        n: Number of variables

    Returns:
        The k-th shadow as a set of multi-indices

    >>> S = {(1, 1, 0), (0, 1, 1)}
    >>> sorted(kth_shadow(S, 1, 3))
    [(0, 0, 1), (0, 1, 0), (1, 0, 0)]
    """
    shadow = set()
    for alpha in S:
        _enumerate_shadow_elements(alpha, k, n, 0, [], shadow)
    return shadow


def _enumerate_shadow_elements(alpha, remaining, n, idx, current_diff, result):
    """Recursively enumerate all valid shadow elements from a single α."""
    if idx == n:
        if remaining == 0:
            beta = tuple(alpha[i] - current_diff[i] for i in range(n))
            result.add(beta)
        return

    max_decrease = min(remaining, alpha[idx])
    for d in range(max_decrease + 1):
        current_diff.append(d)
        _enumerate_shadow_elements(alpha, remaining - d, n, idx + 1, current_diff, result)
        current_diff.pop()


def shadow_profile(S: Support, n: int, max_k: int = None) -> Dict[int, int]:
    """
    Compute the full shadow profile of a support set.

    The shadow profile is the function k ↦ |Shadow_k(S)|.

    Complexity: O(sum_{k=0}^{max_k} |S| · P(k, α_max, n))

    Args:
        S: Support set
        n: Number of variables
        max_k: Maximum k value (defaults to max total degree in S)

    Returns:
        Dictionary mapping k to |Shadow_k(S)|

    >>> S = elem_symm_support(4, 2)
    >>> profile = shadow_profile(S, 4)
    >>> [profile[k] for k in range(3)]
    [6, 4, 1]
    """
    if not S:
        return {}
    if max_k is None:
        max_k = max(sum(m) for m in S)
    return {k: len(kth_shadow(S, k, n)) for k in range(max_k + 1)}


def elem_symm_support(n: int, r: int) -> Support:
    """
    Compute the support of the elementary symmetric polynomial e_r(x_1,...,x_n).

    The support consists of all 0-1 vectors in ℕ^n with exactly r ones,
    corresponding to the r-element subsets of {1,...,n}.

    Complexity: O(C(n, r) · n)

    Args:
        n: Number of variables
        r: Degree of the elementary symmetric polynomial

    Returns:
        Support set with C(n, r) elements

    >>> len(elem_symm_support(5, 2))
    10
    >>> elem_symm_support(3, 1) == {(1,0,0), (0,1,0), (0,0,1)}
    True
    """
    support = set()
    for subset in itertools.combinations(range(n), r):
        vec = tuple(1 if i in subset else 0 for i in range(n))
        support.add(vec)
    return support


def permanent_support(m: int) -> Support:
    """
    Compute the support of the permanent of an m×m matrix of variables.

    Variables are indexed by (i,j) ↦ i*m + j, giving n = m² variables.
    Each permutation σ contributes the monomial ∏ᵢ x_{i,σ(i)},
    corresponding to a 0-1 vector (permutation matrix) in ℕ^{m²}.

    Complexity: O(m! · m)

    Args:
        m: Matrix dimension

    Returns:
        Support set with m! elements (in n = m² variables)
    """
    n = m * m
    support = set()
    for perm in itertools.permutations(range(m)):
        vec = [0] * n
        for i in range(m):
            vec[i * m + perm[i]] = 1
        support.add(tuple(vec))
    return support


def circuit_shadow_envelope(n: int, d: int, s: int, k: int) -> int:
    """
    Compute the circuit shadow envelope bound.

    For a support-compressed circuit with s leaves, degree d, in n variables,
    the k-th shadow profile is bounded by:
        s · C(n + d - k, n)

    This is the fundamental upper bound that explicit hard polynomials
    can potentially violate.

    Complexity: O(min(n, d-k)) for the binomial coefficient

    Args:
        n: Number of variables
        d: Degree
        s: Circuit size (leaf count)
        k: Shadow depth

    Returns:
        Upper bound on shadow profile
    """
    if d < k:
        return 0
    return s * comb(n + d - k, n)


def normalized_shadow_decay(profile: Dict[int, int], n: int, d: int) -> Dict[int, float]:
    """
    Compute the normalized shadow decay function.

    δ_f(k) = |Shadow_k(supp(f))| / C(n + d - k, n)

    The normalized decay measures how much of the degree-(d-k) simplex
    is occupied by the shadow. Small circuits force rapid decay of δ(k).

    Args:
        profile: Shadow profile dictionary
        n: Number of variables
        d: Degree

    Returns:
        Dictionary mapping k to δ(k)
    """
    decay = {}
    for k, val in profile.items():
        denom = comb(n + d - k, n)
        decay[k] = val / denom if denom > 0 else 0.0
    return decay


def simplex_lattice_count(n: int, d: int) -> int:
    """
    Count the number of lattice points in the degree-d simplex in n variables.

    |Δ_{n,d}| = |{m ∈ ℕ^n : Σmᵢ ≤ d}| = C(n + d, n)

    This is the stars-and-bars formula.

    Args:
        n: Number of variables
        d: Degree bound

    Returns:
        Number of lattice points C(n+d, n)
    """
    return comb(n + d, n)


def verify_elem_symm_shadow_formula(n: int, r: int) -> bool:
    """
    Verify that |Shadow_k(supp(e_r))| = C(n, r-k) for all valid k.

    This is Theorem 4 of the shadow decay framework.

    Args:
        n: Number of variables
        r: Degree

    Returns:
        True if the formula holds for all k ∈ {0, ..., r}
    """
    S = elem_symm_support(n, r)
    for k in range(r + 1):
        actual = len(kth_shadow(S, k, n))
        expected = comb(n, r - k)
        if actual != expected:
            return False
    return True


def shadow_decay_ratio(S: Support, n: int, d: int, k1: int, k2: int) -> float:
    """
    Compute the shadow decay ratio |Shadow_{k2}(S)| / |Shadow_{k1}(S)|.

    For elementary symmetric supports, this equals C(n,r-k2) / C(n,r-k1).
    For circuit-bounded supports, this ratio is constrained.

    Args:
        S: Support set
        n: Number of variables
        d: Degree
        k1, k2: Shadow depths (k1 < k2)

    Returns:
        Decay ratio (0 if denominator is 0)
    """
    s1 = len(kth_shadow(S, k1, n))
    s2 = len(kth_shadow(S, k2, n))
    return s2 / s1 if s1 > 0 else 0.0


if __name__ == "__main__":
    # Run doctests
    import doctest
    results = doctest.testmod(verbose=True)

    # Additional verification
    print("\n" + "=" * 60)
    print("ALGORITHM VERIFICATION")
    print("=" * 60)

    for n in range(3, 8):
        for r in range(1, n):
            ok = verify_elem_symm_shadow_formula(n, r)
            status = "✓" if ok else "✗"
            print(f"  elem_symm({n},{r}): shadow formula verified = {status}")

    print("\nSimplex lattice counts:")
    for n in range(1, 6):
        for d in range(1, 5):
            print(f"  |Δ({n},{d})| = C({n+d},{n}) = {simplex_lattice_count(n, d)}")
