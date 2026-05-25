#!/usr/bin/env python3
"""
Algorithms for Tropical-Analytic Duality

This module implements the core algorithms from the research paper:
1. Tropical L-order computation
2. Tropical regulator (assignment problem)
3. Partition function and free energy
4. Hungarian algorithm for optimal assignment
5. Tropical BSD ratio computation

All algorithms include docstrings, type hints, and complexity analysis.
"""

import math
from itertools import permutations
from typing import List, Dict, Tuple, Optional


# ============================================================
# Algorithm 1: Tropical L-Order
# ============================================================

def tropical_l_order(coeffs: Dict[int, float], weights: Dict[int, float]) -> int:
    """Compute the tropical order of vanishing at s=1.

    The tropical L-series evaluated at s=1 is:
        L^trop(1) = min_{n in support} (coeff(n) + weight(n))

    The tropical order is |active_set| - 1, where the active set
    is the set of indices achieving the minimum.

    Complexity: O(|support|) time, O(|support|) space.

    Args:
        coeffs: Maps support indices to coefficient values (p-adic valuations)
        weights: Maps support indices to weight values (typically log(p))

    Returns:
        Tropical order of vanishing (non-negative integer)

    Examples:
        >>> tropical_l_order({2: 0, 3: 1, 5: 0}, {2: 0.7, 3: 1.1, 5: 1.6})
        0
        >>> tropical_l_order({2: 0, 3: 0}, {2: 0.7, 3: 1.1})
        0
    """
    support = sorted(set(coeffs.keys()) & set(weights.keys()))
    if not support:
        return 0

    values = {n: coeffs[n] + weights[n] for n in support}
    min_val = min(values.values())
    active_count = sum(1 for v in values.values() if abs(v - min_val) < 1e-10)

    return active_count - 1


# ============================================================
# Algorithm 2: Tropical Regulator (Brute Force)
# ============================================================

def tropical_regulator_brute(R: List[List[float]]) -> float:
    """Compute the tropical regulator by brute force enumeration.

    TropReg(R) = min_{σ ∈ S_n} Σ_i R[i][σ(i)]

    Complexity: O(n! · n) time, O(n) space.

    Args:
        R: n×n matrix (list of lists)

    Returns:
        Tropical regulator value

    Examples:
        >>> tropical_regulator_brute([[1, 2], [3, 0]])
        1.0
        >>> tropical_regulator_brute([[0, 0], [0, 0]])
        0.0
    """
    n = len(R)
    if n == 0:
        return 0.0

    return min(
        sum(R[i][perm[i]] for i in range(n))
        for perm in permutations(range(n))
    )


# ============================================================
# Algorithm 3: Hungarian Algorithm for Optimal Assignment
# ============================================================

def hungarian_algorithm(cost: List[List[float]]) -> Tuple[float, List[int]]:
    """Solve the assignment problem using the Hungarian algorithm.

    Finds the permutation σ minimizing Σ_i cost[i][σ(i)].

    Complexity: O(n³) time, O(n²) space.

    Args:
        cost: n×n cost matrix

    Returns:
        (optimal_cost, assignment) where assignment[i] = σ(i)

    Examples:
        >>> hungarian_algorithm([[1, 2], [3, 0]])
        (1.0, [0, 1])
    """
    n = len(cost)
    if n == 0:
        return 0.0, []

    # Pad to use 1-indexed arrays
    INF = float('inf')
    u = [0.0] * (n + 1)  # potential for rows
    v = [0.0] * (n + 1)  # potential for columns
    p = [0] * (n + 1)    # assignment: p[j] = i means column j assigned to row i
    way = [0] * (n + 1)  # way[j] = previous column in augmenting path

    for i in range(1, n + 1):
        p[0] = i
        j0 = 0
        minv = [INF] * (n + 1)
        used = [False] * (n + 1)

        while True:
            used[j0] = True
            i0 = p[j0]
            delta = INF
            j1 = -1

            for j in range(1, n + 1):
                if not used[j]:
                    cur = cost[i0 - 1][j - 1] - u[i0] - v[j]
                    if cur < minv[j]:
                        minv[j] = cur
                        way[j] = j0
                    if minv[j] < delta:
                        delta = minv[j]
                        j1 = j

            for j in range(n + 1):
                if used[j]:
                    u[p[j]] += delta
                    v[j] -= delta
                else:
                    minv[j] -= delta

            j0 = j1
            if p[j0] == 0:
                break

        while j0:
            p[j0] = p[way[j0]]
            j0 = way[j0]

    assignment = [0] * n
    for j in range(1, n + 1):
        assignment[p[j] - 1] = j - 1

    opt_cost = sum(cost[i][assignment[i]] for i in range(n))
    return opt_cost, assignment


def tropical_regulator(R: List[List[float]]) -> float:
    """Compute the tropical regulator using the Hungarian algorithm.

    Complexity: O(n³) time, O(n²) space.

    Args:
        R: n×n matrix

    Returns:
        Tropical regulator value
    """
    if not R:
        return 0.0
    cost, _ = hungarian_algorithm(R)
    return cost


# ============================================================
# Algorithm 4: Partition Function
# ============================================================

def partition_function(R: List[List[float]], beta: float) -> float:
    """Compute Z(β) = Σ_σ exp(-β · Σ_i R[i][σ(i)]).

    For numerical stability, uses the log-sum-exp trick:
    log Z = max_σ(-β·S(σ)) + log(Σ_σ exp(-β·S(σ) - max))

    Complexity: O(n! · n) time for brute force.

    Args:
        R: n×n matrix
        beta: Inverse temperature (can be any real number)

    Returns:
        Partition function value (always positive)
    """
    n = len(R)
    if n == 0:
        return 1.0

    # Compute all costs
    costs = [sum(R[i][perm[i]] for i in range(n)) for perm in permutations(range(n))]
    exponents = [-beta * c for c in costs]

    # Log-sum-exp for numerical stability
    max_exp = max(exponents)
    Z = math.exp(max_exp) * sum(math.exp(e - max_exp) for e in exponents)

    return Z


def free_energy(R: List[List[float]], beta: float) -> float:
    """Compute F(β) = (-1/β) · log Z(β).

    The free energy satisfies: F(β) ≤ TropReg(R) for all β > 0.
    As β → ∞, F(β) → TropReg(R).

    Complexity: Same as partition_function.

    Args:
        R: n×n matrix
        beta: Inverse temperature (must be positive)

    Returns:
        Free energy value

    Raises:
        ValueError: If beta ≤ 0
    """
    if beta <= 0:
        raise ValueError(f"beta must be positive, got {beta}")

    Z = partition_function(R, beta)
    return (-1.0 / beta) * math.log(Z)


# ============================================================
# Algorithm 5: Tropical BSD Ratio
# ============================================================

def tropical_bsd_defect(leading_coeff: float, regulator: float,
                        sha_order: float, tamagawa: float,
                        torsion: float, period: float) -> float:
    """Compute the tropical BSD defect.

    In the tropical (additive) setting, the BSD formula becomes:
        leadingCoeff = period + regulator + sha + tamagawa - 2·torsion

    The defect measures how far from this identity we are.

    Complexity: O(1).

    Args:
        leading_coeff: Tropical leading coefficient of L
        regulator: Tropical regulator
        sha_order: log(|Sha|)
        tamagawa: Tropical Tamagawa product (sum of log c_p)
        torsion: log(|E_tors|)
        period: log(Ω)

    Returns:
        BSD defect (zero if and only if BSD holds)
    """
    return leading_coeff - (period + regulator + sha_order + tamagawa - 2 * torsion)


# ============================================================
# Algorithm 6: Elliptic Curve Arithmetic
# ============================================================

def compute_ap_naive(a: int, b: int, p: int) -> int:
    """Compute a_p for y² = x³ + ax + b over F_p by naive point counting.

    Complexity: O(p) time.

    Args:
        a, b: Curve coefficients
        p: Prime (must be ≥ 3)

    Returns:
        a_p = p + 1 - #E(F_p)
    """
    count = 1  # point at infinity
    for x in range(p):
        rhs = (x * x * x + a * x + b) % p
        if rhs == 0:
            count += 1
        elif pow(rhs, (p - 1) // 2, p) == 1:
            count += 2
    return p + 1 - count


def p_adic_valuation(n: int, p: int) -> int:
    """Compute v_p(n) for n ≠ 0. Returns 0 for n = 0.

    Complexity: O(log_p(n)).
    """
    if n == 0:
        return 0
    n = abs(n)
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("=== Tropical Regulator Examples ===")

    # Example 1: Identity matrix
    I = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
    print(f"TropReg(I₃) = {tropical_regulator(I)}")  # Expected: 0 + 0 = 0... wait

    # Actually for identity matrix, TropReg = min over perms of sum of entries
    # Identity perm: 1+1+1 = 3. Other perms pick up 0's.
    # For I = diag(1,1,1), swap (0,1): 0+0+1=1. Hmm let me reconsider.
    # I[0][1]=0, I[1][0]=0, I[2][2]=1. Sum = 0+0+1=1.
    # Cycle (0,1,2): I[0][1]+I[1][2]+I[2][0] = 0+0+0 = 0
    print(f"  (For the 3x3 identity matrix: min perm sum)")

    # Example 2: Constant matrix
    C = [[2, 2], [2, 2]]
    print(f"TropReg(2·J₂) = {tropical_regulator(C)}")  # Expected: 2*2 = 4

    # Example 3: Hungarian algorithm test
    cost_matrix = [[9, 2, 7, 8], [6, 4, 3, 7], [5, 8, 1, 8], [7, 6, 9, 4]]
    opt, assign = hungarian_algorithm(cost_matrix)
    print(f"\nHungarian algorithm on 4x4 matrix:")
    print(f"  Optimal cost: {opt}")
    print(f"  Assignment: {assign}")

    # Example 4: Partition function convergence
    R = [[1, 3], [2, 1]]
    treg = tropical_regulator(R)
    print(f"\nPartition function convergence (TropReg = {treg}):")
    for beta in [0.1, 1.0, 10.0, 100.0]:
        F = free_energy(R, beta)
        print(f"  β={beta:6.1f}: F(β) = {F:.6f}")
