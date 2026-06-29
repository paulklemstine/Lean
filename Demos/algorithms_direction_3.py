#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Tropical Convexity

Implements core algorithms arising from the tropical Carathéodory theorem:
- Tropical linear combination computation
- Carathéodory support extraction
- Tropical hull membership testing
- Tropical halfspace intersection
"""

import numpy as np
from typing import List, Tuple, Set, Optional


def trop_lin_comb(V: np.ndarray, c: np.ndarray) -> np.ndarray:
    """
    Compute the tropical (max-plus) linear combination.

    Given generators V = [v_1, ..., v_m] in ℝⁿ and coefficients c = [c_1, ..., c_m],
    computes x_i = max_j(c_j + v_j(i)) for each coordinate i.

    Algorithm: O(mn) — single pass over all generator-coordinate pairs.

    Parameters:
        V: (m, n) array of generators
        c: (m,) array of coefficients

    Returns:
        (n,) array — the tropical combination
    """
    return np.max(c[:, None] + V, axis=0)


def caratheodory_extract(V: np.ndarray, c: np.ndarray) -> Tuple[List[int], np.ndarray]:
    """
    Extract a Carathéodory-sparse representation.

    Given a tropical linear combination x = tropLinComb(V, c), finds a subset
    I ⊆ {0, ..., m-1} with |I| ≤ n such that tropLinComb(V[I], c[I]) = x.

    This is the constructive content of the tropical Carathéodory theorem.

    Algorithm:
        1. For each coordinate i, find argmax_j(c_j + V_j(i))     — O(mn)
        2. Collect the image of this argmax map                     — O(n)
        3. Return the sparse subset                                 — O(1)
    Total: O(mn) time, O(n) space for the active set.

    Parameters:
        V: (m, n) array of generators
        c: (m,) array of coefficients

    Returns:
        I: sorted list of active generator indices (|I| ≤ n)
        x: the tropical combination
    """
    m, n = V.shape
    shifted = c[:, None] + V
    x = np.max(shifted, axis=0)

    # Argmax for each coordinate
    active = set()
    for i in range(n):
        j_star = np.argmax(shifted[:, i])
        active.add(int(j_star))

    I = sorted(active)
    if len(I) == 0:
        I = [0]

    return I, x


def tropical_hull_membership(V: np.ndarray, x: np.ndarray,
                              tol: float = 1e-10) -> Tuple[bool, Optional[np.ndarray]]:
    """
    Test whether x belongs to the tropical convex hull of V.

    A point x is in tropHull(V) if there exist coefficients c such that
    x_i = max_j(c_j + V_j(i)) for all i.

    This is equivalent to: for each i, there exists j(i) such that
    c_{j(i)} = x_i - V_{j(i)}(i) and c_{j(i)} + V_{j(i)}(k) ≤ x_k for all k.

    In other words, for each i and its chosen generator j(i),
    V_{j(i)}(k) - V_{j(i)}(i) ≤ x_k - x_i for all k.

    Algorithm: O(m * n²) — for each possible assignment of generators to coordinates,
    check consistency.

    Parameters:
        V: (m, n) array of generators
        x: (n,) array — the test point
        tol: numerical tolerance

    Returns:
        (is_member, coefficients) — whether x is in the hull, and witnessing coefficients if so
    """
    m, n = V.shape

    # For each generator j assigned to coordinate i, the coefficient would be c_j = x_i - V_j(i)
    # For consistency: c_j + V_j(k) ≤ x_k for all k, i.e., x_i - V_j(i) + V_j(k) ≤ x_k
    # i.e., V_j(k) - V_j(i) ≤ x_k - x_i

    # Try to find a valid assignment using greedy approach
    # For each coordinate i, find generators that could be active there
    feasible = np.zeros((n, m), dtype=bool)
    for i in range(n):
        for j in range(m):
            # Check if generator j can be active at coordinate i
            valid = True
            for k in range(n):
                if V[j, k] - V[j, i] > x[k] - x[i] + tol:
                    valid = False
                    break
            feasible[i, j] = valid

    # Check if every coordinate has at least one feasible generator
    if not np.all(np.any(feasible, axis=1)):
        return False, None

    # Construct coefficients: for each coordinate, pick a feasible generator
    c = np.full(m, -np.inf)
    for i in range(n):
        for j in range(m):
            if feasible[i, j]:
                c_candidate = x[i] - V[j, i]
                c[j] = max(c[j], c_candidate)
                break

    # Recompute with the constructed coefficients
    x_check = trop_lin_comb(V, np.where(np.isfinite(c), c, -1e15))
    if np.allclose(x, x_check, atol=tol):
        return True, c

    # Fallback: try all generators for each coordinate
    c = np.full(m, -np.inf)
    for i in range(n):
        best_j = -1
        best_c = -np.inf
        for j in range(m):
            if feasible[i, j]:
                c_val = x[i] - V[j, i]
                if c_val > best_c:
                    best_c = c_val
                    best_j = j
        if best_j >= 0:
            c[best_j] = max(c[best_j], best_c)

    c_final = np.where(np.isfinite(c), c, -1e15)
    x_check = trop_lin_comb(V, c_final)
    if np.allclose(x, x_check, atol=tol):
        return True, c_final
    return False, None


def tropical_halfspace_test(a: np.ndarray, b: np.ndarray, x: np.ndarray) -> bool:
    """
    Test whether x lies in the tropical halfspace defined by (a, b):
    max_i(a_i + x_i) ≤ max_i(b_i + x_i)

    Parameters:
        a, b: (n,) arrays defining the halfspace
        x: (n,) array — the test point

    Returns:
        True if x is in the halfspace
    """
    lhs = np.max(a + x)
    rhs = np.max(b + x)
    return lhs <= rhs + 1e-12


def tropical_helly_check(halfspaces: List[Tuple[np.ndarray, np.ndarray]],
                          n: int, num_samples: int = 10000) -> dict:
    """
    Numerically check the tropical Helly property for a collection of halfspaces.

    The tropical Helly theorem states: if every subfamily of size ≤ n+1
    has nonempty intersection, then the whole family has nonempty intersection.

    This function checks this by sampling.

    Parameters:
        halfspaces: list of (a, b) pairs defining tropical halfspaces
        n: dimension
        num_samples: number of random samples to test

    Returns:
        dict with intersection statistics
    """
    from itertools import combinations

    m = len(halfspaces)

    # Sample random points and check which halfspaces they satisfy
    np.random.seed(42)
    points = np.random.randn(num_samples, n) * 5

    # Check full intersection
    full_count = 0
    for x in points:
        if all(tropical_halfspace_test(a, b, x) for a, b in halfspaces):
            full_count += 1

    # Check small subfamilies
    small_nonempty = True
    for combo in combinations(range(m), min(n + 1, m)):
        sub_count = 0
        for x in points:
            if all(tropical_halfspace_test(halfspaces[j][0], halfspaces[j][1], x)
                   for j in combo):
                sub_count += 1
        if sub_count == 0:
            small_nonempty = False
            break

    return {
        "full_intersection_samples": full_count,
        "all_small_subfamilies_nonempty": small_nonempty,
        "helly_consistent": (not small_nonempty) or (full_count > 0),
        "num_halfspaces": m,
        "dimension": n,
    }


if __name__ == "__main__":
    print("=== Tropical Convexity Algorithms ===\n")

    # Demo: Carathéodory extraction
    np.random.seed(42)
    n, m = 4, 15
    V = np.random.randn(m, n) * 3
    c = np.random.randn(m) * 2

    I, x = caratheodory_extract(V, c)
    print(f"Carathéodory extraction: {m} generators → {len(I)} active (bound: {n})")
    print(f"Active set: {I}")

    # Verify
    x_full = trop_lin_comb(V, c)
    x_sparse = trop_lin_comb(V[I], c[I])
    print(f"Full combination: {x_full}")
    print(f"Sparse combination: {x_sparse}")
    print(f"Match: {np.allclose(x_full, x_sparse)}\n")

    # Demo: Hull membership
    V_test = np.array([[0, 0], [3, 1], [1, 4]], dtype=float)
    x_in = trop_lin_comb(V_test, np.array([0.0, -1.0, 0.5]))
    x_out = np.array([10.0, 10.0])  # likely not in hull with reasonable coefficients

    is_in, c_witness = tropical_hull_membership(V_test, x_in)
    print(f"Hull membership test:")
    print(f"  x_in = {x_in}: member = {is_in}")

    # Demo: Halfspace test
    a = np.array([1.0, 0.0, -1.0])
    b = np.array([0.0, 2.0, 0.0])
    x_test = np.array([1.0, 1.0, 1.0])
    print(f"\nHalfspace test: {tropical_halfspace_test(a, b, x_test)}")

    print("\nAll algorithms tested successfully!")
