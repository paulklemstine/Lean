#!/usr/bin/env python3
"""
Algorithms for Support Rigidity and Circuit Lower Bounds

Implements the core algorithms from the research paper:
1. Shadow computation for degree-d multilinear families
2. Support rigidity verification
3. Depth-3 circuit cost lower bound computation
4. Combinatorial entropy computation

All algorithms include docstrings, type hints, and complexity analysis.
"""

import itertools
import math
from typing import (
    Dict, FrozenSet, List, Optional, Set, Tuple
)


# ============================================================
# Algorithm 1: Shadow Computation
# ============================================================

def compute_shadow(
    support: Set[FrozenSet[int]],
    shadow_degree: int = 2
) -> Set[FrozenSet[int]]:
    """
    Compute the second-derivative shadow of a set of multilinear monomials.

    Given a set of degree-d monomials (represented as frozensets of variable
    indices), compute all degree-(d - shadow_degree) monomials obtainable
    by removing `shadow_degree` variables from some support element.

    Args:
        support: Set of frozensets, each representing a multilinear monomial.
        shadow_degree: Number of variables to remove (default 2 for second
                       derivative shadow).

    Returns:
        Set of frozensets representing the shadow.

    Complexity:
        Time: O(|support| * C(d, shadow_degree)) where d is the monomial degree.
        Space: O(|shadow|).

    Example:
        >>> s = {frozenset({0,1,2,3}), frozenset({0,1,2,4})}
        >>> shadow = compute_shadow(s)
        >>> frozenset({0,1}) in shadow
        True
    """
    shadow: Set[FrozenSet[int]] = set()
    for monomial in support:
        d = len(monomial)
        if d < shadow_degree:
            continue
        # All ways to choose shadow_degree elements to remove
        for removed in itertools.combinations(monomial, shadow_degree):
            remaining = monomial - frozenset(removed)
            shadow.add(remaining)
    return shadow


def compute_shadow_pairs(
    quads: List[Tuple[int, ...]],
) -> Set[Tuple[int, int]]:
    """
    Compute shadow specifically for degree-4 monomials producing pairs.

    Optimized version for the degree-4 → degree-2 shadow computation.

    Args:
        quads: List of 4-tuples (a, b, c, d) with a < b < c < d.

    Returns:
        Set of pairs (i, j) with i < j in the shadow.

    Complexity:
        Time: O(|quads| * 6) = O(|quads|).
        Space: O(n²) where n is the number of variables.
    """
    shadow: Set[Tuple[int, int]] = set()
    for q in quads:
        for pair in itertools.combinations(q, 2):
            shadow.add(pair)
    return shadow


# ============================================================
# Algorithm 2: Support Rigidity Verification
# ============================================================

def verify_support_rigidity(
    n: int,
    degree: int = 4,
    shadow_degree: int = 2,
    target_scale: Optional[int] = None
) -> Dict:
    """
    Verify support rigidity for the complete degree-d multilinear family.

    Constructs all degree-d multilinear monomials over n variables,
    computes the shadow, and verifies that the shadow size meets
    the target scale.

    Args:
        n: Number of variables.
        degree: Degree of monomials (default 4).
        shadow_degree: Shadow degree (default 2).
        target_scale: Expected minimum shadow size. If None, uses
                      n*(n-1)/2 for degree=4, shadow_degree=2.

    Returns:
        Dictionary with:
        - 'n': number of variables
        - 'support_size': |support|
        - 'shadow_size': |shadow|
        - 'target_scale': expected minimum
        - 'is_rigid': whether shadow_size >= target_scale
        - 'ratio': shadow_size / target_scale

    Complexity:
        Time: O(C(n, degree) * C(degree, shadow_degree)).
        Space: O(C(n, degree - shadow_degree)).
    """
    if target_scale is None:
        target_scale = n * (n - 1) // 2

    support = set(
        frozenset(c) for c in itertools.combinations(range(n), degree)
    )
    shadow = compute_shadow(support, shadow_degree)

    return {
        'n': n,
        'support_size': len(support),
        'shadow_size': len(shadow),
        'target_scale': target_scale,
        'is_rigid': len(shadow) >= target_scale,
        'ratio': len(shadow) / target_scale if target_scale > 0 else float('inf')
    }


# ============================================================
# Algorithm 3: Depth-3 Circuit Cost Lower Bound
# ============================================================

def circuit_lower_bound(
    shadow_size: int,
    max_shadow_per_component: int
) -> int:
    """
    Compute the depth-3 nonneg circuit cost lower bound.

    By the covering lower bound theorem, any depth-3 circuit with
    nonneg intermediates computing a polynomial with shadow size M,
    where each multiplication gate's output has shadow ≤ B, requires
    at least ⌊M / B⌋ multiplication gates.

    Args:
        shadow_size: Total shadow size M of the target polynomial.
        max_shadow_per_component: Maximum shadow size B per gate.

    Returns:
        Lower bound on the number of multiplication gates.

    Complexity:
        Time: O(1).
    """
    if max_shadow_per_component <= 0:
        return shadow_size  # degenerate case
    return shadow_size // max_shadow_per_component


def compute_family_lower_bounds(
    n: int,
    gate_fan_ins: List[int] = [1, 2, 3, 6]
) -> Dict:
    """
    Compute circuit lower bounds for the degree-4 family at scale n.

    For each gate fan-in bound, computes the maximum shadow per component
    and the resulting circuit lower bound.

    Args:
        n: Number of variables.
        gate_fan_ins: List of maximum shadow sizes per component.

    Returns:
        Dictionary mapping fan-in to lower bound.

    Complexity:
        Time: O(C(n,4) * 6 + |gate_fan_ins|).
    """
    quads = list(itertools.combinations(range(n), 4))
    shadow = compute_shadow_pairs(quads)
    shadow_size = len(shadow)

    results = {}
    for B in gate_fan_ins:
        lb = circuit_lower_bound(shadow_size, B)
        results[B] = {
            'shadow_size': shadow_size,
            'max_shadow_per_component': B,
            'lower_bound': lb,
            'formula_bound': n * (n - 1) // (2 * B)
        }
    return results


# ============================================================
# Algorithm 4: Combinatorial Entropy
# ============================================================

def comb_entropy(size: int) -> float:
    """
    Compute combinatorial entropy: log of cardinality.

    In statistical physics, this is the Boltzmann entropy at zero temperature,
    counting microstates.

    Args:
        size: Cardinality of the set.

    Returns:
        Natural logarithm of size, or 0 if size ≤ 0.

    Complexity:
        Time: O(1).
    """
    if size <= 0:
        return 0.0
    return math.log(size)


def entropy_profile(
    n_range: range,
    degree: int = 4,
    shadow_degree: int = 2
) -> List[Dict]:
    """
    Compute entropy profile for support and shadow across n values.

    Args:
        n_range: Range of n values.
        degree: Monomial degree.
        shadow_degree: Shadow degree.

    Returns:
        List of dicts with n, support_entropy, shadow_entropy.
    """
    results = []
    for n in n_range:
        if n < degree:
            continue
        support = set(
            frozenset(c) for c in itertools.combinations(range(n), degree)
        )
        shadow = compute_shadow(support, shadow_degree)
        results.append({
            'n': n,
            'support_size': len(support),
            'shadow_size': len(shadow),
            'support_entropy': comb_entropy(len(support)),
            'shadow_entropy': comb_entropy(len(shadow)),
        })
    return results


# ============================================================
# Algorithm 5: Shadow Algorithm with Correctness Certificate
# ============================================================

def shadow_algorithm_certified(
    support: Set[FrozenSet[int]],
    n: int,
    shadow_degree: int = 2
) -> Tuple[int, List[Tuple[FrozenSet[int], FrozenSet[int], Tuple[int, ...]]]]:
    """
    Certified shadow computation: returns shadow size with witness.

    For each element in the shadow, provides a certificate:
    (shadow_element, parent_monomial, removed_variables).

    This mirrors the Lean theorem `shadowAlgorithm_correct`.

    Args:
        support: Set of multilinear monomials.
        n: Number of variables (for verification).
        shadow_degree: Number of variables to remove.

    Returns:
        Tuple of (shadow_size, certificates) where each certificate
        is (shadow_element, parent, removed_variables).

    Complexity:
        Time: O(|support| * C(d, shadow_degree)).
        Space: O(|shadow| * certificate_size).
    """
    shadow: Dict[FrozenSet[int], Tuple] = {}
    for monomial in support:
        for removed in itertools.combinations(monomial, shadow_degree):
            remaining = monomial - frozenset(removed)
            if remaining not in shadow:
                shadow[remaining] = (remaining, monomial, removed)

    certificates = list(shadow.values())
    return len(shadow), certificates


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("=== Support Rigidity Algorithms ===\n")

    # Verify support rigidity for n=4..10
    print("Support Rigidity Verification:")
    for n in range(4, 11):
        result = verify_support_rigidity(n)
        print(f"  n={n}: support={result['support_size']}, "
              f"shadow={result['shadow_size']}, "
              f"target={result['target_scale']}, "
              f"rigid={'✓' if result['is_rigid'] else '✗'}")

    print("\nCircuit Lower Bounds (n=10):")
    bounds = compute_family_lower_bounds(10)
    for B, info in bounds.items():
        print(f"  B={B}: lower_bound={info['lower_bound']}, "
              f"formula={info['formula_bound']}")

    print("\nEntropy Profile:")
    profile = entropy_profile(range(4, 12))
    for entry in profile:
        print(f"  n={entry['n']}: H(support)={entry['support_entropy']:.3f}, "
              f"H(shadow)={entry['shadow_entropy']:.3f}")

    print("\nCertified Shadow (n=5, degree=4):")
    support_5 = set(
        frozenset(c) for c in itertools.combinations(range(5), 4)
    )
    size, certs = shadow_algorithm_certified(support_5, 5)
    print(f"  Shadow size: {size}")
    print(f"  Sample certificate: {certs[0]}")
