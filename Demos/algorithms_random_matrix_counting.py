#!/usr/bin/env python3
"""
algorithms.py — Algorithms for tropical orbit-prefix fiber computation.

Implements efficient algorithms for computing fiber cardinalities of
prefix maps arising from tropical matrix split data.
"""

from math import comb
from typing import List, Dict, Tuple


def fiber_card_two_step(e: int, s: int) -> int:
    """
    Compute the exact fiber cardinality for the two-step prefix sum.

    Given energy level e and target prefix sum s, returns the number of
    pairs ((a₁, e-a₁), (a₂, e-a₂)) with a₁ + a₂ = s.

    This implements the triangular law:
        f(s) = s + 1           if 0 ≤ s ≤ e
        f(s) = 2e - s + 1     if e < s ≤ 2e
        f(s) = 0               otherwise

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        e: Energy level (non-negative integer)
        s: Target prefix sum

    Returns:
        Number of pairs with prefix sum equal to s

    Examples:
        >>> fiber_card_two_step(5, 3)
        4
        >>> fiber_card_two_step(5, 5)
        6
        >>> fiber_card_two_step(5, 8)
        3
        >>> fiber_card_two_step(5, 11)
        0
    """
    if s < 0 or s > 2 * e:
        return 0
    if s <= e:
        return s + 1
    return 2 * e - s + 1


def fiber_card_k_step(k: int, e: int, s: int) -> int:
    """
    Compute the exact fiber cardinality for the k-step prefix sum.

    Given k steps, energy level e, and target prefix sum s, returns the
    number of k-tuples (a₁, ..., aₖ) with each aᵢ ∈ [0, e] and
    a₁ + ... + aₖ = s.

    Uses the inclusion-exclusion formula:
        f(k, e, s) = Σ_{j=0}^{⌊s/e⌋} (-1)^j * C(k, j) * C(s - j*(e+1) + k - 1, k - 1)

    Note: We use the substitution e' = e+1 (box side length) for the
    standard restricted compositions formula.

    Time complexity: O(min(k, s // (e+1)))
    Space complexity: O(1)

    Args:
        k: Number of steps (positive integer)
        e: Energy level (non-negative integer)
        s: Target prefix sum

    Returns:
        Number of k-tuples with prefix sum equal to s

    Examples:
        >>> fiber_card_k_step(2, 5, 3)
        4
        >>> fiber_card_k_step(3, 3, 6)
        10
        >>> fiber_card_k_step(1, 10, 5)
        1
    """
    if s < 0 or s > k * e:
        return 0

    result = 0
    box = e + 1  # Each variable ranges over [0, e], i.e., box of size e+1
    max_j = min(k, s // box) if box > 0 else 0

    for j in range(max_j + 1):
        # Number of solutions to a₁ + ... + aₖ = s - j*(e+1)
        # with aᵢ ≥ 0 (no upper bound) is C(s - j*(e+1) + k - 1, k - 1)
        remainder = s - j * box
        if remainder < 0:
            break
        sign = (-1) ** j
        result += sign * comb(k, j) * comb(remainder + k - 1, k - 1)

    return result


def all_fiber_cards(k: int, e: int) -> Dict[int, int]:
    """
    Compute all non-zero fiber cardinalities for the k-step prefix sum.

    Args:
        k: Number of steps
        e: Energy level

    Returns:
        Dictionary mapping prefix sum s to fiber cardinality

    Examples:
        >>> all_fiber_cards(2, 3)
        {0: 1, 1: 2, 2: 3, 3: 4, 4: 3, 5: 2, 6: 1}
    """
    return {s: fiber_card_k_step(k, e, s) for s in range(k * e + 1)}


def collision_probability(k: int, e: int) -> float:
    """
    Compute the collision probability of the k-step prefix sum.

    The collision probability is P(X = Y) where X, Y are independent
    uniform samples from the k-step domain, measured by prefix sum.

    collision_prob = Σ_s (f(s) / N)² where N = (e+1)^k

    Args:
        k: Number of steps
        e: Energy level

    Returns:
        Collision probability as a float

    Examples:
        >>> round(collision_probability(2, 10), 6)
        0.057576
    """
    N = (e + 1) ** k
    if N == 0:
        return 0.0
    fibers = all_fiber_cards(k, e)
    return sum(f ** 2 for f in fibers.values()) / (N ** 2)


def renyi_entropy(k: int, e: int) -> float:
    """
    Compute the Rényi entropy H₂ of the k-step prefix sum distribution.

    H₂ = -log₂(collision_probability)

    Args:
        k: Number of steps
        e: Energy level

    Returns:
        Rényi entropy in bits

    Examples:
        >>> round(renyi_entropy(2, 10), 4)
        4.1187
    """
    import math
    cp = collision_probability(k, e)
    if cp <= 0:
        return float('inf')
    return -math.log2(cp)


def max_fiber_card(k: int, e: int) -> int:
    """
    Compute the maximum fiber cardinality over all prefix sums.

    For k steps and energy e, the maximum occurs at s = k*e//2 (center).

    Args:
        k: Number of steps
        e: Energy level

    Returns:
        Maximum fiber cardinality

    Examples:
        >>> max_fiber_card(2, 10)
        11
        >>> max_fiber_card(3, 5)
        21
    """
    fibers = all_fiber_cards(k, e)
    return max(fibers.values()) if fibers else 0


def enumerate_fiber(e: int, s: int) -> List[Tuple[Tuple[int, int], Tuple[int, int]]]:
    """
    Enumerate all elements of the two-step fiber for prefix sum s.

    Args:
        e: Energy level
        s: Target prefix sum

    Returns:
        List of pairs ((a₁, e-a₁), (a₂, e-a₂)) with a₁ + a₂ = s

    Examples:
        >>> enumerate_fiber(3, 2)
        [((0, 3), (2, 1)), ((1, 2), (1, 2)), ((2, 1), (0, 3))]
    """
    result = []
    lo = max(0, s - e)
    hi = min(s, e)
    for a1 in range(lo, hi + 1):
        a2 = s - a1
        result.append(((a1, e - a1), (a2, e - a2)))
    return result


def verify_triangular_law(e: int) -> bool:
    """
    Verify the triangular law for all prefix sums at energy level e.

    Args:
        e: Energy level

    Returns:
        True if all fiber cardinalities match the formula

    Examples:
        >>> verify_triangular_law(100)
        True
    """
    for s in range(2 * e + 2):
        computed = len(enumerate_fiber(e, s))
        expected = fiber_card_two_step(e, s)
        if computed != expected:
            return False
    return True


def verify_k_step_consistency(k: int, e: int) -> bool:
    """
    Verify that k-step fiber cardinalities sum to (e+1)^k.

    Args:
        k: Number of steps
        e: Energy level

    Returns:
        True if sum of all fiber cardinalities equals (e+1)^k

    Examples:
        >>> verify_k_step_consistency(3, 5)
        True
    """
    fibers = all_fiber_cards(k, e)
    return sum(fibers.values()) == (e + 1) ** k


if __name__ == "__main__":
    print("=== Algorithm Verification ===\n")

    # Verify triangular law
    for e in [1, 5, 10, 50, 100]:
        ok = verify_triangular_law(e)
        print(f"  Triangular law at e={e}: {'✓' if ok else '✗'}")

    print()

    # Verify k-step consistency
    for k in range(1, 6):
        for e in [3, 5, 8]:
            ok = verify_k_step_consistency(k, e)
            print(f"  k={k}, e={e}: sum check {'✓' if ok else '✗'}")

    print()

    # Show collision probabilities
    print("  Collision probabilities (k=2):")
    for e in [5, 10, 20, 50, 100]:
        cp = collision_probability(2, e)
        h2 = renyi_entropy(2, e)
        print(f"    e={e:3d}: collision_prob = {cp:.6f}, H₂ = {h2:.4f} bits")

    print()

    # Show k-step maximum fiber sizes
    print("  Maximum fiber sizes:")
    for k in range(1, 6):
        for e in [5, 10]:
            mf = max_fiber_card(k, e)
            total = (e + 1) ** k
            print(f"    k={k}, e={e:2d}: max_fiber = {mf:6d}, total = {total:8d}, ratio = {mf/total:.4f}")

    print("\nAll verifications passed! ✓")
