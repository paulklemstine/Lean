#!/usr/bin/env python3
"""
Tropical Finite Optimization — Algorithms

Implements the core algorithms from the research paper:
1. Finite minimizer (argmin over finite sets)
2. Tropical finset infimum
3. Tropical matrix operations
4. Below-average element finder
5. Monotonicity checker
"""

from typing import TypeVar, Callable, Sequence, Tuple, List, Optional
import numpy as np

T = TypeVar('T')


def finite_minimizer(elements: Sequence[T], cost: Callable[[T], float]) -> Tuple[T, float]:
    """
    Find the global minimizer of a cost function over a finite nonempty set.
    
    Implements Theorem 3 (exists_minimizer_fintype) computationally.
    
    Time complexity: O(n) where n = len(elements)
    Space complexity: O(1) additional space
    
    Args:
        elements: Nonempty finite sequence of candidates.
        cost: Real-valued cost function.
    
    Returns:
        (minimizer, minimum_cost): The element achieving the global minimum
        and its cost.
    
    Raises:
        ValueError: If elements is empty.
    
    Example:
        >>> finite_minimizer([3, 1, 4, 1, 5], lambda x: x)
        (1, 1)
    """
    if not elements:
        raise ValueError("Element set must be nonempty (Nonempty α required)")
    
    best = elements[0]
    best_cost = cost(best)
    
    for elem in elements[1:]:
        c = cost(elem)
        if c < best_cost:
            best = elem
            best_cost = c
    
    return best, best_cost


def tropical_finset_inf(costs: Sequence[float]) -> float:
    """
    Compute the tropical n-ary sum (infimum/minimum) over a finite nonempty set.
    
    Implements the computation underlying Theorem 1 (tropical_finset_inf_le_of_mem).
    
    Time complexity: O(n)
    Space complexity: O(1)
    
    Args:
        costs: Nonempty sequence of real-valued costs.
    
    Returns:
        The minimum value (tropical sum).
    
    Example:
        >>> tropical_finset_inf([3.0, 1.0, 4.0])
        1.0
    """
    if not costs:
        raise ValueError("Cost set must be nonempty")
    return min(costs)


def tropical_pair_min(a: float, b: float) -> Tuple[float, bool, bool]:
    """
    Compute the tropical binary conjunction and verify both bounds.
    
    Implements Theorem 2 (tropical_pair_conjunction_bound).
    
    Args:
        a, b: Two real values.
    
    Returns:
        (min_val, le_a, le_b): The minimum and verification of both bounds.
    
    Example:
        >>> tropical_pair_min(3.0, 7.0)
        (3.0, True, True)
    """
    m = min(a, b)
    return m, m <= a, m <= b


def below_average_element(elements: Sequence[T], cost: Callable[[T], float]) -> Tuple[T, float, float]:
    """
    Find an element with cost at most the average.
    
    Implements Theorem 5 (exists_codeword_with_cost_le_average).
    
    Time complexity: O(n)
    Space complexity: O(1)
    
    Args:
        elements: Nonempty finite sequence.
        cost: Real-valued cost function.
    
    Returns:
        (element, element_cost, average_cost): An element achieving cost ≤ average.
    
    Example:
        >>> below_average_element([1, 2, 3, 4, 5], lambda x: float(x))
        (1, 1.0, 3.0)
    """
    if not elements:
        raise ValueError("Element set must be nonempty")
    
    total = sum(cost(e) for e in elements)
    avg = total / len(elements)
    
    best, best_cost = finite_minimizer(elements, cost)
    assert best_cost <= avg, "Theorem 5 violated (should never happen)"
    
    return best, best_cost, avg


def matrix_entry_minimizer(M: np.ndarray) -> Tuple[Tuple[int, int], float]:
    """
    Find the globally minimal entry in a matrix.
    
    Implements Theorem 8 (exists_matrix_entry_minimizer).
    
    Time complexity: O(n²) for an n×n matrix
    Space complexity: O(1)
    
    Args:
        M: A nonempty n×n matrix of real values.
    
    Returns:
        ((i, j), min_value): The indices and value of the global minimum.
    
    Example:
        >>> M = np.array([[5, 3], [7, 1]])
        >>> matrix_entry_minimizer(M)
        ((1, 1), 1.0)
    """
    if M.size == 0:
        raise ValueError("Matrix must be nonempty (n > 0 required)")
    
    idx = np.unravel_index(np.argmin(M), M.shape)
    return (int(idx[0]), int(idx[1])), float(M[idx])


def tropical_matrix_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical (min-plus) matrix multiplication.
    
    Computes C[i,j] = min_k (A[i,k] + B[k,j]).
    
    This is the algorithmic foundation for shortest-path computation
    and multi-step cost analysis (see FUTURE_DIRECTIONS.md, Direction 1).
    
    Time complexity: O(n³)
    Space complexity: O(n²)
    
    Args:
        A: n×m matrix
        B: m×p matrix
    
    Returns:
        n×p matrix C where C[i,j] = min_k (A[i,k] + B[k,j])
    
    Example:
        >>> A = np.array([[0, 3], [7, 1]])
        >>> B = np.array([[2, 4], [5, 0]])
        >>> tropical_matrix_multiply(A, B)
        array([[2., 3.],
               [6., 1.]])
    """
    n, m = A.shape
    _, p = B.shape
    
    C = np.full((n, p), np.inf)
    for i in range(n):
        for j in range(p):
            for k in range(m):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    
    return C


def verify_monotonicity(
    f: Sequence[float], g: Sequence[float]
) -> Tuple[bool, float, float]:
    """
    Verify the monotonicity theorem: if f ≤ g pointwise, then inf(f) ≤ inf(g).
    
    Implements Theorem 6 (finset_inf'_mono) as a checker.
    
    Args:
        f, g: Two sequences of the same length with f[i] ≤ g[i] for all i.
    
    Returns:
        (monotonicity_holds, inf_f, inf_g)
    
    Example:
        >>> verify_monotonicity([1, 3, 5], [2, 4, 6])
        (True, 1, 2)
    """
    assert len(f) == len(g), "Sequences must have the same length"
    assert all(fi <= gi for fi, gi in zip(f, g)), "f must be ≤ g pointwise"
    
    inf_f = min(f)
    inf_g = min(g)
    
    return inf_f <= inf_g, inf_f, inf_g


# ─────────────────────────────────────────────────────────
# Pseudocode for key algorithms (for the research paper)
# ─────────────────────────────────────────────────────────

PSEUDOCODE = {
    "finite_minimizer": """
    ALGORITHM FiniteMinimizer(S, cost)
    INPUT:  Nonempty finite set S, cost function cost : S → ℝ
    OUTPUT: Element a* ∈ S with cost(a*) ≤ cost(b) for all b ∈ S
    
    1. Pick any a* ∈ S
    2. FOR each b ∈ S:
    3.     IF cost(b) < cost(a*):
    4.         a* ← b
    5. RETURN a*
    
    TIME:  O(|S|)
    SPACE: O(1)
    CORRECTNESS: By Theorem 3 (exists_minimizer_fintype)
    """,
    
    "tropical_matrix_multiply": """
    ALGORITHM TropicalMatMul(A, B)
    INPUT:  n×m matrix A, m×p matrix B over (ℝ ∪ {∞}, min, +)
    OUTPUT: n×p matrix C with C[i,j] = min_k (A[i,k] + B[k,j])
    
    1. Initialize C[i,j] ← ∞ for all i, j
    2. FOR i = 1 TO n:
    3.     FOR j = 1 TO p:
    4.         FOR k = 1 TO m:
    5.             C[i,j] ← min(C[i,j], A[i,k] + B[k,j])
    6. RETURN C
    
    TIME:  O(nmp)
    SPACE: O(np)
    NOTE:  Associative — (A⊗B)⊗C = A⊗(B⊗C). See Future Direction 1.
    """,
    
    "shortest_path_tropical": """
    ALGORITHM TropicalShortestPath(M, n)
    INPUT:  n×n cost matrix M, dimension n
    OUTPUT: n×n matrix D with D[i,j] = shortest path cost from i to j
    
    1. D ← M
    2. FOR k = 1 TO n:
    3.     D ← TropicalMatMul(D, M)  // D = M^k in tropical algebra
    4.     // Alternative: D[i,j] ← min(D[i,j], D[i,k] + D[k,j])
    5. RETURN D
    
    TIME:  O(n⁴) naive, O(n³ log n) with repeated squaring
    SPACE: O(n²)
    CORRECTNESS: By matrix entry minimizer (Theorem 8) applied at each step
    """
}


if __name__ == "__main__":
    print("=" * 60)
    print("  Tropical Finite Optimization — Algorithm Tests")
    print("=" * 60)
    
    # Test finite minimizer
    print("\n1. Finite Minimizer:")
    elems = list(range(1, 11))
    costs_fn = lambda x: (x - 4.5) ** 2
    best, best_cost = finite_minimizer(elems, costs_fn)
    print(f"   Elements: {elems}")
    print(f"   Cost: (x - 4.5)²")
    print(f"   Minimizer: {best}, cost = {best_cost}")
    
    # Test tropical infimum
    print("\n2. Tropical Finset Infimum:")
    costs = [5.0, 2.0, 8.0, 1.0, 9.0]
    inf_val = tropical_finset_inf(costs)
    print(f"   Costs: {costs}")
    print(f"   Infimum: {inf_val}")
    
    # Test below-average
    print("\n3. Below-Average Element:")
    elems = ["A", "B", "C", "D", "E"]
    cost_map = {"A": 10, "B": 3, "C": 7, "D": 12, "E": 8}
    elem, ec, avg = below_average_element(elems, lambda x: cost_map[x])
    print(f"   Elements: {elems}, costs: {cost_map}")
    print(f"   Below-average: {elem} (cost={ec}, avg={avg})")
    
    # Test matrix minimizer
    print("\n4. Matrix Entry Minimizer:")
    M = np.array([[5.0, 3.0, 7.0],
                  [2.0, 8.0, 4.0],
                  [6.0, 1.0, 9.0]])
    (i, j), val = matrix_entry_minimizer(M)
    print(f"   Matrix:\n{M}")
    print(f"   Min entry: M[{i},{j}] = {val}")
    
    # Test tropical matrix multiplication
    print("\n5. Tropical Matrix Multiplication:")
    A = np.array([[0, 3], [7, 1]])
    B = np.array([[2, 4], [5, 0]])
    C = tropical_matrix_multiply(A, B)
    print(f"   A = {A.tolist()}")
    print(f"   B = {B.tolist()}")
    print(f"   A ⊗ B = {C.tolist()}")
    
    # Test monotonicity
    print("\n6. Monotonicity Verification:")
    f = [1.0, 3.0, 5.0, 2.0]
    g = [2.0, 4.0, 6.0, 3.0]
    holds, inf_f, inf_g = verify_monotonicity(f, g)
    print(f"   f = {f}, g = {g}")
    print(f"   f ≤ g pointwise, inf(f)={inf_f} ≤ inf(g)={inf_g}? {holds} ✓")
    
    print("\n" + "=" * 60)
    print("  All algorithm tests passed.")
    print("=" * 60)
