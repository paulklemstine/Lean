"""
Algorithms for Tropical Grassmannian Theory

Implements:
1. Dressian membership test (3-term Plücker relation checker)
2. Four-point condition checker for rank-2 tree metrics
3. Matroid representability test over finite fields
"""

from itertools import combinations
from typing import Callable, Dict, FrozenSet, List, Tuple, Optional
import numpy as np


def check_dressian_membership(
    r: int, n: int, w: Callable[[FrozenSet[int]], float]
) -> Tuple[bool, Optional[Tuple]]:
    """Check if a Plücker vector w is in the Dressian Dr(r,n).

    Args:
        r: rank
        n: ground set size
        w: weight function on r-element subsets of {0,...,n-1}

    Returns:
        (True, None) if w ∈ Dr(r,n)
        (False, (S, a, b, c, d)) witnessing a violated relation
    """
    ground = list(range(n))

    for S_tuple in combinations(ground, r - 2):
        S = frozenset(S_tuple)
        remaining = [x for x in ground if x not in S]

        for (a, b, c, d) in combinations(remaining, 4):
            v1 = w(S | {a, b}) + w(S | {c, d})
            v2 = w(S | {a, c}) + w(S | {b, d})
            v3 = w(S | {a, d}) + w(S | {b, c})

            vals = sorted([v1, v2, v3])
            if vals[0] < vals[1]:  # minimum not attained twice
                return False, (S, a, b, c, d)

    return True, None


def check_four_point_condition(
    n: int, d: Callable[[int, int], float]
) -> Tuple[bool, Optional[Tuple]]:
    """Check if a distance function satisfies the four-point condition.

    The four-point condition: for all distinct i,j,k,l,
    d(i,j)+d(k,l) ≤ max(d(i,k)+d(j,l), d(i,l)+d(j,k)).

    Equivalent to: the maximum of the three sums is attained at least twice.

    Args:
        n: number of points
        d: distance function

    Returns:
        (True, None) if condition holds
        (False, (i,j,k,l)) witnessing violation
    """
    for quad in combinations(range(n), 4):
        i, j, k, l = quad
        s1 = d(i, j) + d(k, l)
        s2 = d(i, k) + d(j, l)
        s3 = d(i, l) + d(j, k)

        vals = sorted([s1, s2, s3])
        if vals[2] > vals[1]:  # maximum not attained twice
            return False, (i, j, k, l)

    return True, None


def is_representable_over_Fp(
    matroid_bases: List[FrozenSet[int]],
    n: int, r: int, p: int,
    max_attempts: int = 1000
) -> Tuple[bool, Optional[np.ndarray]]:
    """Test if a matroid is representable over F_p by random sampling.

    This is a Monte Carlo test: it tries random r×n matrices over F_p
    and checks if their matroid matches.

    Args:
        matroid_bases: list of r-element subsets that are bases
        n: ground set size
        r: rank
        p: prime field characteristic
        max_attempts: number of random trials

    Returns:
        (True, A) if a representation is found
        (False, None) if no representation found after max_attempts
    """
    bases_set = set(matroid_bases)

    for _ in range(max_attempts):
        A = np.random.randint(0, p, size=(r, n))

        # Check matroid
        is_match = True
        for cols in combinations(range(n), r):
            submat = A[:, list(cols)]
            det = int(round(np.linalg.det(submat))) % p
            is_basis = frozenset(cols) in bases_set

            if (det != 0) != is_basis:
                is_match = False
                break

        if is_match:
            return True, A

    return False, None


def matroid_from_weight(r: int, n: int, w: Callable) -> List[FrozenSet[int]]:
    """Extract the matroid of weight-minimal subsets."""
    all_subsets = [frozenset(s) for s in combinations(range(n), r)]
    min_weight = min(w(s) for s in all_subsets)
    return [s for s in all_subsets if w(s) == min_weight]


# ============================================================
# Demonstrations
# ============================================================

if __name__ == "__main__":
    # Fano matroid
    FANO_LINES = [
        frozenset({0, 1, 3}), frozenset({0, 2, 4}), frozenset({1, 2, 5}),
        frozenset({0, 5, 6}), frozenset({1, 4, 6}), frozenset({2, 3, 6}),
        frozenset({3, 4, 5}),
    ]

    def fano_weight(I):
        return 1 if I in FANO_LINES else 0

    # 1. Check Dressian membership
    print("Testing Dressian membership for Fano weight:")
    ok, witness = check_dressian_membership(3, 7, fano_weight)
    print(f"  Result: {'PASS' if ok else 'FAIL'}")

    # 2. Extract matroid and test representability
    bases = matroid_from_weight(3, 7, fano_weight)
    print(f"\nFano matroid: {len(bases)} bases")

    print("\nTesting representability over F_2:")
    ok2, A2 = is_representable_over_Fp(bases, 7, 3, 2)
    print(f"  F_2: {'REPRESENTABLE' if ok2 else 'Not found'}")
    if ok2:
        print(f"  Matrix:\n{A2}")

    print("\nTesting representability over F_3:")
    ok3, _ = is_representable_over_Fp(bases, 7, 3, 3, max_attempts=5000)
    print(f"  F_3: {'REPRESENTABLE' if ok3 else 'Not found (expected: not representable)'}")

    print("\nTesting representability over F_5:")
    ok5, _ = is_representable_over_Fp(bases, 7, 3, 5, max_attempts=5000)
    print(f"  F_5: {'REPRESENTABLE' if ok5 else 'Not found (expected: not representable)'}")

    # 3. Four-point condition example
    print("\n\nFour-point condition test:")
    # Tree metric
    tree_d = lambda i, j: abs(i - j) if i != j else 0
    ok_tree, _ = check_four_point_condition(5, tree_d)
    print(f"  Path metric on 5 points: {'PASS' if ok_tree else 'FAIL'}")
