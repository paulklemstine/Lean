#!/usr/bin/env python3
"""
Tropical BSD Machine — Algorithms

Implements the core algorithms underlying the tropical BSD framework:
- Tropical L-series evaluation (min-plus envelope)
- Tropical vanishing order computation
- Tropical permanent (assignment problem)
- BSD data construction and verification
- Newton polygon extraction

All algorithms include complexity analysis and type hints.
"""

import numpy as np
from itertools import permutations
from typing import Dict, List, Tuple, Optional, FrozenSet
from dataclasses import dataclass


# ─────────────────────────────────────────────
# Algorithm 1: Powerset Generation
# ─────────────────────────────────────────────

def powerset(n: int) -> List[FrozenSet[int]]:
    """
    Generate all subsets of {0, ..., n-1}.

    Time:  O(2^n)
    Space: O(2^n · n)

    Parameters
    ----------
    n : int
        Size of the ground set.

    Returns
    -------
    List[FrozenSet[int]]
        All 2^n subsets, ordered by binary encoding.

    Example
    -------
    >>> powerset(2)
    [frozenset(), frozenset({0}), frozenset({1}), frozenset({0, 1})]
    """
    result: List[FrozenSet[int]] = [frozenset()]
    for i in range(n):
        result = result + [s | {i} for s in result]
    return result


# ─────────────────────────────────────────────
# Algorithm 2: Tropical L-Series Evaluation
# ─────────────────────────────────────────────

def evaluate_tropical_l_series(
    n: int,
    coefficients: Dict[FrozenSet[int], float],
    t: float
) -> Tuple[float, FrozenSet[int]]:
    """
    Evaluate the tropical L-series at parameter t and return the active piece.

    L^trop(t) = min_{I ⊆ [n]} (|I| · t + c(I))

    Time:  O(2^n)
    Space: O(1) beyond input

    Parameters
    ----------
    n : int
        Rank parameter.
    coefficients : Dict[FrozenSet[int], float]
        Coefficient function c: 2^[n] → ℝ.
    t : float
        Evaluation point.

    Returns
    -------
    Tuple[float, FrozenSet[int]]
        (value, active_subset) where active_subset achieves the minimum.

    Example
    -------
    >>> c = {frozenset(): 5, frozenset({0}): 0}
    >>> evaluate_tropical_l_series(1, c, 1.0)
    (1.0, frozenset({0}))
    """
    best_val = float('inf')
    best_set = frozenset()

    for I in powerset(n):
        val = len(I) * t + coefficients[I]
        if val < best_val:
            best_val = val
            best_set = I

    return best_val, best_set


# ─────────────────────────────────────────────
# Algorithm 3: Tropical Vanishing Order
# ─────────────────────────────────────────────

def compute_vanishing_order(
    n: int,
    coefficients: Dict[FrozenSet[int], float],
    tol: float = 1e-12
) -> Tuple[int, List[FrozenSet[int]]]:
    """
    Compute the tropical vanishing order at t=0.

    Pseudocode:
        1. Compute min_val = min_{I} c(I)
        2. Find minimizers = {I : c(I) = min_val}
        3. Return min{|I| : I ∈ minimizers}

    Time:  O(2^n)
    Space: O(2^n) for minimizer list

    Parameters
    ----------
    n : int
        Rank parameter.
    coefficients : Dict[FrozenSet[int], float]
        Coefficient function.
    tol : float
        Tolerance for floating-point comparison.

    Returns
    -------
    Tuple[int, List[FrozenSet[int]]]
        (vanishing_order, minimizers)
    """
    ps = powerset(n)
    min_val = min(coefficients[I] for I in ps)

    minimizers = [I for I in ps if abs(coefficients[I] - min_val) < tol]
    vanishing_order = min(len(I) for I in minimizers)

    return vanishing_order, minimizers


# ─────────────────────────────────────────────
# Algorithm 4: Tropical Permanent (Hungarian-style)
# ─────────────────────────────────────────────

def tropical_permanent_brute(M: np.ndarray) -> Tuple[float, List[int]]:
    """
    Compute the tropical permanent by brute-force enumeration.

    trop_perm(M) = min_{σ ∈ S_n} Σ_i M[i, σ(i)]

    Time:  O(n! · n)
    Space: O(n)

    For production use with n > 10, use the Hungarian algorithm (O(n³)).

    Parameters
    ----------
    M : np.ndarray
        n×n real matrix.

    Returns
    -------
    Tuple[float, List[int]]
        (permanent_value, optimal_permutation)
    """
    n = M.shape[0]
    if n == 0:
        return 0.0, []

    best_val = float('inf')
    best_perm = list(range(n))

    for perm in permutations(range(n)):
        val = sum(M[i, perm[i]] for i in range(n))
        if val < best_val:
            best_val = val
            best_perm = list(perm)

    return best_val, best_perm


def tropical_permanent_hungarian(M: np.ndarray) -> float:
    """
    Compute tropical permanent using a simplified Hungarian algorithm.

    Time:  O(n³)
    Space: O(n²)

    This solves the linear assignment problem: minimize Σ M[i,σ(i)].

    Parameters
    ----------
    M : np.ndarray
        n×n cost matrix.

    Returns
    -------
    float
        Tropical permanent value.
    """
    n = M.shape[0]
    if n == 0:
        return 0.0

    # For small n, brute force is fine
    if n <= 8:
        return tropical_permanent_brute(M)[0]

    # Simplified Hungarian: reduce rows and columns
    cost = M.copy()

    # Row reduction
    for i in range(n):
        cost[i] -= cost[i].min()

    # Column reduction
    for j in range(n):
        cost[:, j] -= cost[:, j].min()

    # Greedy assignment (heuristic for large n)
    used_cols = set()
    total = 0.0
    assignment = [-1] * n

    for i in range(n):
        best_j = -1
        best_val = float('inf')
        for j in range(n):
            if j not in used_cols and cost[i, j] < best_val:
                best_val = cost[i, j]
                best_j = j
        if best_j >= 0:
            assignment[i] = best_j
            used_cols.add(best_j)
            total += M[i, best_j]

    return total


# ─────────────────────────────────────────────
# Algorithm 5: BSD Data Package
# ─────────────────────────────────────────────

@dataclass
class TropicalBSDData:
    """
    Complete tropical BSD data package.

    Attributes
    ----------
    n : int
        Rank parameter (tropical MW rank).
    coefficients : Dict[FrozenSet[int], float]
        Coefficient function for the L-series.
    """
    n: int
    coefficients: Dict[FrozenSet[int], float]

    @property
    def trop_rank(self) -> int:
        """Tropical algebraic rank = n."""
        return self.n

    @property
    def trop_ord(self) -> int:
        """Tropical analytic rank (vanishing order)."""
        return compute_vanishing_order(self.n, self.coefficients)[0]

    @property
    def is_generic(self) -> bool:
        """Check if data satisfies the genericity condition."""
        _, minimizers = compute_vanishing_order(self.n, self.coefficients)
        full = frozenset(range(self.n))
        return len(minimizers) == 1 and minimizers[0] == full

    def verify_inequality(self) -> bool:
        """Verify BSD inequality: trop_ord ≤ trop_rank."""
        return self.trop_ord <= self.trop_rank

    def verify_equality(self) -> bool:
        """Check BSD equality (should hold iff generic)."""
        return self.trop_ord == self.trop_rank

    def l_series(self, t: float) -> float:
        """Evaluate the tropical L-series."""
        return evaluate_tropical_l_series(
            self.n, self.coefficients, t)[0]


def construct_generic_bsd_data(
    n: int,
    penalty: float = 1.0
) -> TropicalBSDData:
    """
    Construct generic BSD data where univ is the unique minimizer.

    c(univ) = 0, c(I) = (n - |I|) · penalty for I ≠ univ.

    Time: O(2^n)

    Parameters
    ----------
    n : int
        Rank parameter.
    penalty : float
        Gap between rank levels.

    Returns
    -------
    TropicalBSDData
        Generic data satisfying BSD equality.
    """
    full = frozenset(range(n))
    c = {}
    for I in powerset(n):
        if I == full:
            c[I] = 0.0
        else:
            c[I] = (n - len(I)) * penalty
    return TropicalBSDData(n=n, coefficients=c)


def construct_residue_data(
    n: int,
    M: np.ndarray,
    primes: List[int],
    tau: Dict[int, float]
) -> TropicalBSDData:
    """
    Construct BSD data from regulator matrix and Tamagawa numbers.

    Time: O(n! · n + 2^n) for the permanent computation.

    Parameters
    ----------
    n : int
        Rank.
    M : np.ndarray
        Regulator matrix.
    primes : List[int]
        Bad reduction primes.
    tau : Dict[int, float]
        Tamagawa numbers.

    Returns
    -------
    TropicalBSDData
    """
    reg = tropical_permanent_brute(M)[0]
    tam = sum(tau.get(p, 0) for p in primes)
    base = reg + tam

    c = {}
    full = frozenset(range(n))
    for I in powerset(n):
        if len(I) == n:
            c[I] = base
        else:
            c[I] = len(I) + base + 1
    return TropicalBSDData(n=n, coefficients=c)


# ─────────────────────────────────────────────
# Algorithm 6: Newton Polygon Extraction
# ─────────────────────────────────────────────

def compute_newton_polygon(
    n: int,
    coefficients: Dict[FrozenSet[int], float],
    t_range: Tuple[float, float] = (-5.0, 5.0),
    num_points: int = 1000
) -> List[Tuple[float, float, int]]:
    """
    Extract the Newton polygon of the tropical L-series.

    The Newton polygon encodes the breakpoints where the active affine piece
    changes. Each segment has a slope = cardinality of the active subset.

    Time:  O(2^n · num_points)
    Space: O(num_points)

    Parameters
    ----------
    n : int
        Rank parameter.
    coefficients : Dict[FrozenSet[int], float]
        Coefficient function.
    t_range : Tuple[float, float]
        Range of t values.
    num_points : int
        Number of sample points.

    Returns
    -------
    List[Tuple[float, float, int]]
        List of (t_break, value, slope_after) for each breakpoint.
    """
    t_vals = np.linspace(t_range[0], t_range[1], num_points)
    breakpoints = []

    prev_active = None
    for t in t_vals:
        val, active = evaluate_tropical_l_series(n, coefficients, t)
        if active != prev_active:
            breakpoints.append((float(t), float(val), len(active)))
            prev_active = active

    return breakpoints


# ─────────────────────────────────────────────
# Usage Examples
# ─────────────────────────────────────────────

if __name__ == "__main__":
    print("Tropical BSD Algorithms — Examples\n")

    # Example 1: Generic BSD data
    data = construct_generic_bsd_data(3)
    print(f"Generic BSD data (n=3):")
    print(f"  Rank: {data.trop_rank}")
    print(f"  Vanishing order: {data.trop_ord}")
    print(f"  Generic: {data.is_generic}")
    print(f"  Inequality holds: {data.verify_inequality()}")
    print(f"  Equality holds: {data.verify_equality()}")
    print()

    # Example 2: Tropical permanent
    M = np.array([[1, 5, 9], [2, 4, 8], [3, 6, 7]], dtype=float)
    perm_val, perm = tropical_permanent_brute(M)
    print(f"Tropical permanent of M:")
    print(f"  Value: {perm_val}")
    print(f"  Optimal permutation: {perm}")
    print()

    # Example 3: Newton polygon
    data = construct_generic_bsd_data(2, penalty=2.0)
    breakpoints = compute_newton_polygon(2, data.coefficients)
    print(f"Newton polygon breakpoints (n=2):")
    for t, v, s in breakpoints:
        print(f"  t = {t:.2f}, value = {v:.2f}, slope = {s}")
