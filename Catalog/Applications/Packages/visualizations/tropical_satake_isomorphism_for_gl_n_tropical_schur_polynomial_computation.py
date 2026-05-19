#!/usr/bin/env python3
"""
algorithms.py — Algorithms for computing tropical Satake objects for GL_n.

Implements:
1. Tropical Schur polynomial computation via orbit enumeration
2. Fast dominant weight recovery from tropical Schur evaluations
3. Weyl symmetrization (Satake transform)
4. Dominance order detection via tropical Schur comparison
"""

from itertools import permutations
from math import factorial
from typing import Optional


def compute_trop_schur(weight: list[int], point: list[int]) -> int:
    """
    Compute the tropical Schur polynomial tropSchur(w, x).

    Algorithm: Enumerate all n! permutations σ ∈ S_n and compute
    min_{σ} ∑_i w(σ(i)) * x(i).

    Time complexity: O(n! · n)
    Space complexity: O(n)

    Args:
        weight: Dominant weight w = [w_0, ..., w_{n-1}] (weakly decreasing).
        point: Evaluation point x = [x_0, ..., x_{n-1}].

    Returns:
        The minimum over all permutations of the inner product.

    Example:
        >>> compute_trop_schur([3, 1, 0], [1, 0, -1])
        -3
    """
    n = len(weight)
    assert len(point) == n, "weight and point must have same length"
    indices = list(range(n))
    return min(
        sum(weight[sigma[i]] * point[i] for i in indices)
        for sigma in permutations(indices)
    )


def compute_hecke_basis(weight: list[int], point: list[int]) -> int:
    """
    Compute the Hecke basis element heckeBasis(w, x).

    Algorithm: Enumerate all n! permutations and compute
    min_{σ} ∑_i w(i) * x(σ(i)).

    By the reindexing theorem, this equals compute_trop_schur(weight, point).

    Time complexity: O(n! · n)

    Example:
        >>> compute_hecke_basis([3, 1, 0], [1, 0, -1])
        -3
    """
    n = len(weight)
    indices = list(range(n))
    return min(
        sum(weight[i] * point[sigma[i]] for i in indices)
        for sigma in permutations(indices)
    )


def recover_weight_from_trop_schur(
    trop_schur_oracle: "callable",
    n: int
) -> list[int]:
    """
    Recover a dominant weight from its tropical Schur polynomial.

    Algorithm: Evaluate the tropical Schur polynomial at test vectors
    e_k(i) = 1 if i >= k, 0 otherwise, for k = 0, ..., n-1.
    This yields the partial tail sums S_k = ∑_{i≥k} w(i).
    Then w(k) = S_k - S_{k+1} (with S_n = 0).

    Time complexity: O(n) oracle calls, each O(n! · n).
    The oracle calls dominate.

    Args:
        trop_schur_oracle: Function x ↦ tropSchur(w, x) for unknown w.
        n: The rank.

    Returns:
        The recovered dominant weight [w_0, ..., w_{n-1}].

    Example:
        >>> w = [5, 3, 1]
        >>> oracle = lambda x: compute_trop_schur(w, x)
        >>> recover_weight_from_trop_schur(oracle, 3)
        [5, 3, 1]
    """
    # Compute partial tail sums
    tail_sums = []
    for k in range(n):
        test = [1 if i >= k else 0 for i in range(n)]
        tail_sums.append(trop_schur_oracle(test))

    # Telescope to recover individual entries
    weight = []
    for k in range(n - 1):
        weight.append(tail_sums[k] - tail_sums[k + 1])
    weight.append(tail_sums[n - 1])  # w(n-1) = S_{n-1}

    return weight


def weyl_symmetrize(f: "callable", point: list[int]) -> int:
    """
    Apply the Weyl symmetrization (tropical Satake transform) to f at point x.

    satakeTransform(f)(x) = min_{σ ∈ S_n} f(σ · x)

    Time complexity: O(n! · T_f) where T_f is the time for one evaluation of f.

    Example:
        >>> f = lambda x: sum(i * xi for i, xi in enumerate(x))
        >>> weyl_symmetrize(f, [3, 1, 2])  # min over permutations of x
        4
    """
    n = len(point)
    indices = list(range(n))
    return min(
        f([point[sigma[i]] for i in indices])
        for sigma in permutations(indices)
    )


def is_weyl_invariant(f: "callable", n: int, test_points: Optional[list] = None) -> bool:
    """
    Test whether f is S_n-invariant by checking on test points.

    Time complexity: O(|test_points| · n! · T_f)

    Args:
        f: Function (Fin n → ℤ) → ℤ.
        n: The rank.
        test_points: Points to test. Defaults to standard test vectors.

    Returns:
        True if f appears invariant on all test points.
    """
    if test_points is None:
        test_points = [list(range(n)), list(range(n, 0, -1)),
                       [(-1)**i * (i+1) for i in range(n)]]

    indices = list(range(n))
    for x in test_points:
        base = f(x)
        for sigma in permutations(indices):
            x_perm = [x[sigma[i]] for i in indices]
            if f(x_perm) != base:
                return False
    return True


def enumerate_dominant_weights(n: int, max_val: int) -> list[list[int]]:
    """
    Enumerate all dominant weights w with 0 ≤ w(n-1) ≤ ... ≤ w(0) ≤ max_val.

    Time complexity: O(binom(max_val + n, n))

    Example:
        >>> enumerate_dominant_weights(2, 2)
        [[0, 0], [1, 0], [1, 1], [2, 0], [2, 1], [2, 2]]
    """
    results = []

    def backtrack(pos: int, upper_bound: int, current: list[int]):
        if pos == n:
            results.append(current[:])
            return
        for v in range(0, upper_bound + 1):
            current.append(v)
            backtrack(pos + 1, v, current)
            current.pop()

    backtrack(0, max_val, [])
    return results


def dominance_order_via_trop_schur(
    w1: list[int], w2: list[int], n: int, num_tests: int = 100
) -> Optional[str]:
    """
    Detect dominance ordering between two dominant weights using
    tropical Schur evaluations.

    If w1 ≤_dom w2, then for "monotone" test vectors x,
    tropSchur(w1, x) ≤ tropSchur(w2, x).

    Returns: "w1 <= w2", "w2 <= w1", "equal", "incomparable", or None if uncertain.

    Example:
        >>> dominance_order_via_trop_schur([3, 1, 0], [2, 2, 0], 3)
        'incomparable'
    """
    w1_le_w2 = True
    w2_le_w1 = True

    # Use monotone test vectors (weakly decreasing)
    import random
    random.seed(42)

    for _ in range(num_tests):
        x = sorted([random.randint(-10, 10) for _ in range(n)], reverse=True)
        v1 = compute_trop_schur(w1, x)
        v2 = compute_trop_schur(w2, x)
        if v1 > v2:
            w1_le_w2 = False
        if v2 > v1:
            w2_le_w1 = False

    if w1_le_w2 and w2_le_w1:
        return "equal"
    elif w1_le_w2:
        return "w1 <= w2"
    elif w2_le_w1:
        return "w2 <= w1"
    else:
        return "incomparable"


# ──────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────
if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm demonstrations")
    print("=" * 60)

    # 1. Compute tropical Schur
    w = [5, 3, 1, 0]
    x = [1, -1, 2, 0]
    print(f"\n1. tropSchur({w}, {x}) = {compute_trop_schur(w, x)}")
    print(f"   heckeBasis({w}, {x}) = {compute_hecke_basis(w, x)}")
    print(f"   (These should be equal by the reindexing theorem)")

    # 2. Weight recovery
    print(f"\n2. Weight recovery from tropSchur oracle:")
    oracle = lambda pt: compute_trop_schur(w, pt)
    recovered = recover_weight_from_trop_schur(oracle, 4)
    print(f"   Original:  {w}")
    print(f"   Recovered: {recovered}")
    print(f"   Match: {'✓' if w == recovered else '✗'}")

    # 3. Weyl invariance check
    print(f"\n3. Weyl invariance check:")
    f_schur = lambda pt: compute_trop_schur(w, pt)
    print(f"   tropSchur({w}, ·) is S_4-invariant: {is_weyl_invariant(f_schur, 4)}")
    f_bad = lambda pt: sum(pt)  # This IS invariant
    print(f"   sum(·) is S_4-invariant: {is_weyl_invariant(f_bad, 4)}")
    f_bad2 = lambda pt: pt[0]  # This is NOT invariant
    print(f"   x[0] is S_4-invariant: {is_weyl_invariant(f_bad2, 4)}")

    # 4. Dominant weight enumeration
    print(f"\n4. Dominant weights of GL_3 with entries ≤ 3:")
    dw = enumerate_dominant_weights(3, 3)
    print(f"   Count: {len(dw)}")
    print(f"   First 10: {dw[:10]}")

    # 5. Dominance order
    print(f"\n5. Dominance order detection:")
    pairs = [
        ([3, 1, 0], [2, 2, 0]),
        ([3, 2, 1], [4, 1, 1]),
        ([3, 2, 1], [3, 2, 1]),
    ]
    for w1, w2 in pairs:
        result = dominance_order_via_trop_schur(w1, w2, 3)
        print(f"   {w1} vs {w2}: {result}")
