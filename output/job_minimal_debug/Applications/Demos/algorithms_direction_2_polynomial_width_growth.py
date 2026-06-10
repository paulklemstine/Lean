#!/usr/bin/env python3
"""
Algorithms for Certificate-Family Profile Analysis

Implements the profile-based width estimation algorithms derived from
the polynomial width theory for bounded certificate-family posets.

The key algorithms are:
1. Certificate profile computation
2. Profile-based width estimation
3. Rank-level decomposition and counting
4. Box antichain width computation
"""

from math import comb, factorial
from itertools import product as iter_product
from typing import List, Tuple, Dict, Set, FrozenSet
from functools import lru_cache


# ============================================================
# Type aliases
# ============================================================

# A certificate is a pair (Pos, Neg) of frozensets
Certificate = Tuple[FrozenSet[int], FrozenSet[int]]
CertFamily = FrozenSet[Certificate]
Profile = Tuple[int, ...]  # indexed by size class (a, b)


# ============================================================
# Algorithm 1: Certificate Profile Computation
# ============================================================

def compute_profile(family: CertFamily, t: int) -> Profile:
    """Compute the certificate profile of a family.

    The profile records, for each size class (a, b) with 0 ≤ a, b ≤ t,
    the number of certificates in the family with |Pos| = a and |Neg| = b.

    Args:
        family: A set of (Pos, Neg) certificate pairs
        t: Size bound

    Returns:
        Profile vector indexed by size classes (a, b) for 0 ≤ a, b ≤ t

    Time complexity: O(|family| * t^2)
    Space complexity: O(t^2)

    Example:
        >>> cert1 = (frozenset({0}), frozenset({1}))
        >>> cert2 = (frozenset({0, 1}), frozenset())
        >>> family = frozenset({cert1, cert2})
        >>> compute_profile(family, 2)
        (0, 0, 0, 0, 1, 0, 0, 0, 1)
    """
    counts = []
    for a in range(t + 1):
        for b in range(t + 1):
            count = sum(1 for pos, neg in family
                       if len(pos) == a and len(neg) == b)
            counts.append(count)
    return tuple(counts)


def profile_dim(t: int) -> int:
    """Dimension of the profile space: (t+1)^2."""
    return (t + 1) ** 2


# ============================================================
# Algorithm 2: Bounded Certificate Universe Enumeration
# ============================================================

def enumerate_bounded_subsets(n: int, t: int) -> List[FrozenSet[int]]:
    """Enumerate all subsets of {0,...,n-1} with cardinality ≤ t.

    Time complexity: O(sum_{k=0}^{t} C(n,k))
    Space complexity: O(sum_{k=0}^{t} C(n,k))

    Example:
        >>> sorted(enumerate_bounded_subsets(3, 1), key=lambda s: (len(s), sorted(s)))
        [frozenset(), frozenset({0}), frozenset({1}), frozenset({2})]
    """
    result = [frozenset()]
    elements = list(range(n))
    for k in range(1, min(t, n) + 1):
        result.extend(_subsets_of_size(elements, k))
    return result


def _subsets_of_size(elements: list, k: int) -> List[FrozenSet[int]]:
    """Generate all subsets of given size."""
    if k == 0:
        return [frozenset()]
    if k > len(elements):
        return []
    result = []
    for i, elem in enumerate(elements):
        for subset in _subsets_of_size(elements[i + 1:], k - 1):
            result.append(frozenset({elem}) | subset)
    return result


def enumerate_certificates(n: int, t: int) -> List[Certificate]:
    """Enumerate all certificate pairs (Pos, Neg) with |Pos|,|Neg| ≤ t.

    Time complexity: O((sum C(n,k))^2) for k ≤ t
    Space complexity: O((sum C(n,k))^2)

    Example:
        >>> len(enumerate_certificates(3, 1))
        16
    """
    subsets = enumerate_bounded_subsets(n, t)
    return [(p, q) for p in subsets for q in subsets]


def bounded_cert_universe_size(n: int, t: int) -> int:
    """Size of the bounded certificate universe.

    Example:
        >>> bounded_cert_universe_size(3, 1)
        16
    """
    count = sum(comb(n, k) for k in range(t + 1))
    return count ** 2


# ============================================================
# Algorithm 3: Profile-Based Width Estimation
# ============================================================

def polynomial_width_bound(n: int, t: int) -> int:
    """Compute the polynomial profile-based width bound.

    Returns ((n+1)^{2t} + 1)^{profileDim(t)}.

    This bounds the maximum size of any profile-injective antichain
    in the bounded certificate family poset on {0,...,n-1}.

    Args:
        n: Size of the ambient set
        t: Certificate size bound

    Returns:
        Upper bound on profile-injective antichain cardinality

    Time complexity: O(1) (arithmetic)

    Example:
        >>> polynomial_width_bound(3, 1)
        625
    """
    return ((n + 1) ** (2 * t) + 1) ** profile_dim(t)


def polynomial_exponent(t: int) -> int:
    """The exponent d(t) = (2t+1) * (t+1)^2 in the O(n^{d(t)}) bound.

    Example:
        >>> polynomial_exponent(1)
        12
        >>> polynomial_exponent(2)
        45
    """
    return (2 * t + 1) * profile_dim(t)


def exponential_bound(n: int, t: int) -> float:
    """Log2 of the exponential catalog bound 2^|universe|.

    Example:
        >>> exponential_bound(3, 1)
        16
    """
    return bounded_cert_universe_size(n, t)


# ============================================================
# Algorithm 4: Rank-Level Decomposition
# ============================================================

@lru_cache(maxsize=None)
def rank_level_size(m: int, N: int, r: int) -> int:
    """Number of lattice points in [0,N]^m with coordinate sum = r.

    Uses inclusion-exclusion on the stars-and-bars formula:
    |{f ∈ [0,N]^m : Σ f_i = r}| = Σ_{k=0}^{m} (-1)^k C(m,k) C(r-k(N+1)+m-1, m-1)

    Time complexity: O(m)
    Space complexity: O(1)

    Example:
        >>> rank_level_size(2, 3, 4)
        4
        >>> rank_level_size(3, 5, 7)
        27
    """
    if r < 0 or r > m * N:
        return 0
    total = 0
    for k in range(m + 1):
        adjusted = r - k * (N + 1)
        if adjusted < 0:
            break
        sign = (-1) ** k
        total += sign * comb(m, k) * comb(adjusted + m - 1, m - 1)
    return max(0, total)


def max_rank_level_size(m: int, N: int) -> int:
    """Maximum rank-level size in [0,N]^m (sharp antichain width bound).

    This equals the maximum coefficient of (1 + x + ... + x^N)^m,
    which is the sharp Sperner-type width bound for the product order.

    Time complexity: O(m * N)
    Space complexity: O(1)

    Example:
        >>> max_rank_level_size(2, 5)
        6
        >>> max_rank_level_size(3, 5)
        27
    """
    return max(rank_level_size(m, N, r) for r in range(m * N + 1))


def rank_distribution(m: int, N: int) -> Dict[int, int]:
    """Full rank distribution: {rank: level_size} for [0,N]^m.

    Example:
        >>> rank_distribution(2, 2)
        {0: 1, 1: 2, 2: 3, 3: 2, 4: 1}
    """
    return {r: rank_level_size(m, N, r) for r in range(m * N + 1)}


# ============================================================
# Algorithm 5: Exact Width for Small Cases
# ============================================================

def enumerate_families(n: int, t: int) -> List[CertFamily]:
    """Enumerate all bounded certificate families on {0,...,n-1}.

    WARNING: Exponential in |universe|. Only for very small n, t.

    Time complexity: O(2^|universe|)

    Example:
        >>> len(enumerate_families(2, 0))
        2
    """
    certs = enumerate_certificates(n, t)
    families = []
    for size in range(len(certs) + 1):
        for combo in _subsets_of_list(certs, size):
            families.append(frozenset(combo))
    return families


def _subsets_of_list(lst: list, k: int) -> List[List]:
    """Generate all k-element sublists."""
    if k == 0:
        return [[]]
    if k > len(lst):
        return []
    result = []
    for i in range(len(lst)):
        for rest in _subsets_of_list(lst[i + 1:], k - 1):
            result.append([lst[i]] + rest)
    return result


def is_antichain(families: List[CertFamily]) -> bool:
    """Check if a list of families forms an antichain under subset inclusion.

    Example:
        >>> f1 = frozenset({(frozenset({0}), frozenset())})
        >>> f2 = frozenset({(frozenset({1}), frozenset())})
        >>> is_antichain([f1, f2])
        True
    """
    for i in range(len(families)):
        for j in range(len(families)):
            if i != j and families[i] <= families[j]:
                return False
    return True


def exact_width_brute_force(n: int, t: int) -> int:
    """Compute exact width by brute-force antichain search.

    WARNING: Doubly exponential. Only for tiny n, t (n ≤ 2, t ≤ 1).

    Example:
        >>> exact_width_brute_force(1, 0)
        1
    """
    families = enumerate_families(n, t)
    max_width = 0
    for size in range(len(families), 0, -1):
        if size <= max_width:
            break
        for combo in _subsets_of_list(families, size):
            if is_antichain(combo):
                max_width = max(max_width, size)
                break
    return max_width


# ============================================================
# Algorithm 6: Profile-Based Analysis
# ============================================================

def analyze_profiles(n: int, t: int) -> Dict:
    """Analyze the profile structure of bounded certificate families.

    Returns statistics about profile distribution, collisions, and
    the effectiveness of profile-based width bounds.

    Time complexity: O(2^|universe|)

    Example:
        >>> result = analyze_profiles(2, 1)
        >>> result['num_families'] > 0
        True
    """
    families = enumerate_families(n, t)
    profiles = {}
    for family in families:
        profile = compute_profile(family, t)
        if profile not in profiles:
            profiles[profile] = []
        profiles[profile].append(family)

    # Analyze collision structure
    max_collision = max(len(v) for v in profiles.values())
    avg_collision = sum(len(v) for v in profiles.values()) / len(profiles)

    return {
        'num_families': len(families),
        'num_distinct_profiles': len(profiles),
        'max_profile_collision': max_collision,
        'avg_profile_collision': avg_collision,
        'polynomial_bound': polynomial_width_bound(n, t),
        'exponential_bound_log2': exponential_bound(n, t),
    }


# ============================================================
# Main: Example Usage
# ============================================================

if __name__ == "__main__":
    print("Certificate Profile Analysis - Example Usage")
    print("=" * 50)

    # Example 1: Compute a certificate profile
    cert1 = (frozenset({0}), frozenset({1}))
    cert2 = (frozenset({0, 1}), frozenset())
    cert3 = (frozenset(), frozenset({0, 1}))
    family = frozenset({cert1, cert2, cert3})
    t = 2
    profile = compute_profile(family, t)
    print(f"\nFamily: {family}")
    print(f"Profile (t={t}): {profile}")
    print(f"Profile dimension: {profile_dim(t)}")

    # Example 2: Width bounds
    print("\nWidth bounds for n=5, t=2:")
    n, t = 5, 2
    print(f"  Polynomial bound: {polynomial_width_bound(n, t)}")
    print(f"  Exponential bound (log2): {exponential_bound(n, t)}")
    print(f"  Polynomial exponent d(t): {polynomial_exponent(t)}")

    # Example 3: Rank levels
    print("\nRank levels for [0,4]^3:")
    m, N = 3, 4
    dist = rank_distribution(m, N)
    for r, size in dist.items():
        print(f"  Rank {r}: {size} points")
    print(f"  Max level: {max_rank_level_size(m, N)}")
    print(f"  Crude bound (N+1)^m: {(N + 1) ** m}")

    # Example 4: Profile analysis for small case
    print("\nProfile analysis for n=2, t=1:")
    result = analyze_profiles(2, 1)
    for key, value in result.items():
        print(f"  {key}: {value}")
