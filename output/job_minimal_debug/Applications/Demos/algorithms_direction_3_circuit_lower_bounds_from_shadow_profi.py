"""
Shadow Profile and Shadow Complexity Algorithms

Implements the core algorithms for computing shadow profiles, shadow complexity,
and Minkowski sums of finite subsets of ℕ^n. Includes certification procedures
for verifying formula complexity bounds.
"""

from typing import FrozenSet, Tuple, List, Dict, Set
from itertools import combinations
import math


# Type alias: a multi-index is a tuple of non-negative integers
MultiIndex = Tuple[int, ...]


def total_deg(v: MultiIndex) -> int:
    """Total degree |v| = Σᵢ vᵢ."""
    return sum(v)


def lower_shadow(S: Set[MultiIndex]) -> Set[MultiIndex]:
    """Compute the lower shadow ∂(S).

    ∂(S) = {v - eᵢ : v ∈ S, vᵢ > 0}

    Args:
        S: A finite set of multi-indices (tuples of non-negative integers).

    Returns:
        The lower shadow as a set of multi-indices.
    """
    result: Set[MultiIndex] = set()
    for v in S:
        for i in range(len(v)):
            if v[i] > 0:
                w = list(v)
                w[i] -= 1
                result.add(tuple(w))
    return result


def shadow_iter(S: Set[MultiIndex], k: int) -> Set[MultiIndex]:
    """Compute the k-th iterated shadow ∂ᵏ(S).

    Args:
        S: A finite set of multi-indices.
        k: Number of shadow iterations.

    Returns:
        The k-th iterated shadow.
    """
    current = set(S)
    for _ in range(k):
        if not current:
            break
        current = lower_shadow(current)
    return current


def shadow_profile(S: Set[MultiIndex]) -> List[int]:
    """Compute the full shadow profile (a₀, a₁, ..., a_D).

    Args:
        S: A finite set of multi-indices.

    Returns:
        List where entry k is |∂ᵏ(S)|.

    Time complexity: O(D · |S| · n) where D = max total degree, n = dimension.
    """
    if not S:
        return [0]

    profile = []
    current = set(S)
    while current:
        profile.append(len(current))
        current = lower_shadow(current)
    return profile


def shadow_complexity(S: Set[MultiIndex]) -> int:
    """Compute the shadow complexity Σ(S) = Σₖ |∂ᵏ(S)|.

    Args:
        S: A finite set of multi-indices.

    Returns:
        The shadow complexity.
    """
    return sum(shadow_profile(S))


def minkowski_sum(A: Set[MultiIndex], B: Set[MultiIndex]) -> Set[MultiIndex]:
    """Compute the Minkowski sum A + B = {a + b : a ∈ A, b ∈ B}.

    Args:
        A, B: Finite sets of multi-indices (same dimension).

    Returns:
        The Minkowski sum.
    """
    result: Set[MultiIndex] = set()
    for a in A:
        for b in B:
            result.add(tuple(ai + bi for ai, bi in zip(a, b)))
    return result


def verify_convolution_bound(A: Set[MultiIndex], B: Set[MultiIndex]) -> Dict:
    """Verify the convolution bound a_k^{A+B} ≤ Σᵢ aᵢ^A · a_{k-i}^B for all k.

    Args:
        A, B: Finite sets of multi-indices.

    Returns:
        Dictionary with 'holds' (bool), 'profile_A', 'profile_B', 'profile_AB',
        'convolution_bound' (the convolution of profiles), 'max_slack'.
    """
    ab = minkowski_sum(A, B)
    pa = shadow_profile(A)
    pb = shadow_profile(B)
    pab = shadow_profile(ab)

    # Compute convolution of pa and pb
    max_k = len(pab)
    conv = []
    for k in range(max_k):
        val = 0
        for i in range(k + 1):
            if i < len(pa) and (k - i) < len(pb):
                val += pa[i] * pb[k - i]
        conv.append(val)

    holds = all(pab[k] <= conv[k] for k in range(max_k))
    max_slack = max(conv[k] - pab[k] for k in range(max_k)) if max_k > 0 else 0

    return {
        'holds': holds,
        'profile_A': pa,
        'profile_B': pb,
        'profile_AB': pab,
        'convolution_bound': conv,
        'max_slack': max_slack
    }


def certify_formula_bound(S: Set[MultiIndex], s: int) -> Dict:
    """Certify whether Σ(S) ≤ 2^s (formula complexity bound).

    Args:
        S: Support set of a polynomial.
        s: Claimed formula size.

    Returns:
        Dictionary with 'certified' (bool), 'shadow_complexity', 'bound'.
    """
    sc = shadow_complexity(S)
    bound = 2 ** s
    return {
        'certified': sc <= bound,
        'shadow_complexity': sc,
        'bound': bound,
        'ratio': sc / bound if bound > 0 else float('inf')
    }


def support_product_1_plus_xi(n: int) -> Set[MultiIndex]:
    """Support of ∏ᵢ₌₁ⁿ (1 + xᵢ) = all subsets of {0,1}^n.

    This is the full Boolean hypercube {0,1}^n.
    """
    if n == 0:
        return {()}
    result: Set[MultiIndex] = set()
    for bits in range(2 ** n):
        v = tuple((bits >> i) & 1 for i in range(n))
        result.add(v)
    return result


def support_permanent(n: int) -> Set[MultiIndex]:
    """Support of the n×n permanent polynomial.

    The permanent is Σ_σ ∏ᵢ x_{i,σ(i)} where σ ranges over permutations.
    The support consists of n! permutation matrices, each represented as a
    vector in {0,1}^{n²}.
    """
    from itertools import permutations
    result: Set[MultiIndex] = set()
    for perm in permutations(range(n)):
        v = [0] * (n * n)
        for i in range(n):
            v[i * n + perm[i]] = 1
        result.add(tuple(v))
    return result


def support_elementary_symmetric(n: int, k: int) -> Set[MultiIndex]:
    """Support of the k-th elementary symmetric polynomial e_k(x₁,...,xₙ).

    e_k = Σ_{|T|=k} ∏_{i∈T} xᵢ. Support is all {0,1}^n vectors with exactly k ones.
    """
    result: Set[MultiIndex] = set()
    for subset in combinations(range(n), k):
        v = [0] * n
        for i in subset:
            v[i] = 1
        result.add(tuple(v))
    return result


if __name__ == "__main__":
    # Example usage
    print("=== Shadow Profile Algorithm Demo ===\n")

    # Example 1: Support of (1+x)(1+y) in ℕ²
    S = {(0, 0), (1, 0), (0, 1), (1, 1)}
    print(f"S = {S}")
    print(f"Shadow profile: {shadow_profile(S)}")
    print(f"Shadow complexity: {shadow_complexity(S)}")
    print()

    # Example 2: Convolution bound verification
    A = {(1, 0), (0, 0)}  # Support of 1 + x
    B = {(0, 1), (0, 0)}  # Support of 1 + y
    result = verify_convolution_bound(A, B)
    print(f"A = {A}, B = {B}")
    print(f"Convolution bound holds: {result['holds']}")
    print(f"Profile A: {result['profile_A']}")
    print(f"Profile B: {result['profile_B']}")
    print(f"Profile A+B: {result['profile_AB']}")
    print(f"Conv bound: {result['convolution_bound']}")
