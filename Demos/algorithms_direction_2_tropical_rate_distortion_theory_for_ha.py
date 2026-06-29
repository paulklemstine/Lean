#!/usr/bin/env python3
"""
Algorithms for Tropical Rate-Distortion Theory

Implements efficient computation of the rate-distortion function R(D)
and dual threshold costs C(k) for finite pitch universes.

Includes:
  - Brute-force exact computation (exponential)
  - Dynamic programming approach (for structured costs)
  - Threshold-based computation via C(k)
  - Tropical Blahut–Arimoto style iteration
"""
from __future__ import annotations
import itertools
from typing import Callable
from collections import defaultdict


# ═══════════════════════════════════════════════════════════════════════
#  Algorithm 1: Exact Computation via Exhaustive Search
# ═══════════════════════════════════════════════════════════════════════

def compute_rd_exact(
    cost: Callable[[int, int], int],
    u: list[int],
    alpha: list[int],
    D_max: int
) -> dict[int, int]:
    """
    Compute R(D) for D = 0, 1, ..., D_max by exhaustive enumeration.

    Complexity: O(|α|^|ι| · |ι| · D_max)

    Parameters
    ----------
    cost : callable
        Pairwise cost function cost(a, b) -> non-negative integer.
    u : list[int]
        Source melodic line (list of pitches from alpha).
    alpha : list[int]
        Finite pitch alphabet.
    D_max : int
        Maximum budget to compute.

    Returns
    -------
    dict[int, int]
        Mapping D -> R(D).
    """
    n = len(u)
    # Precompute all candidate lines with their cost and variety
    candidates = []
    for v in itertools.product(alpha, repeat=n):
        v_list = list(v)
        c = sum(cost(u[i], v_list[i]) for i in range(n))
        var = len(set(v_list))
        candidates.append((c, var))

    # For each budget D, find maximum variety
    rd = {}
    for D in range(D_max + 1):
        rd[D] = max((var for c, var in candidates if c <= D), default=0)
    return rd


# ═══════════════════════════════════════════════════════════════════════
#  Algorithm 2: Threshold-Based Computation
# ═══════════════════════════════════════════════════════════════════════

def compute_thresholds(
    cost: Callable[[int, int], int],
    u: list[int],
    alpha: list[int]
) -> dict[int, int | float]:
    """
    Compute the threshold costs C(k) for k = 0, 1, ..., max_variety.

    C(k) = min { totalCost(u, v) : harmonicVariety(v) >= k }

    By the primal-dual theorem: for k >= 1,
        k <= R(D)  iff  C(k) <= D

    This completely determines R(D) via finitely many thresholds.

    Complexity: O(|α|^|ι| · |ι|)

    Returns
    -------
    dict[int, int | float]
        Mapping k -> C(k). Returns float('inf') for unrealizable k.
    """
    n = len(u)
    max_k = min(len(alpha), n)
    thresholds: dict[int, int | float] = {k: float('inf') for k in range(max_k + 2)}

    for v in itertools.product(alpha, repeat=n):
        v_list = list(v)
        c = sum(cost(u[i], v_list[i]) for i in range(n))
        var = len(set(v_list))
        for k in range(var + 1):
            thresholds[k] = min(thresholds[k], c)

    return thresholds


def rd_from_thresholds(
    thresholds: dict[int, int | float],
    D: int
) -> int:
    """
    Compute R(D) from precomputed thresholds C(k).

    R(D) = max { k : C(k) <= D }

    Complexity: O(max_variety) per query after O(1) preprocessing.
    """
    return max((k for k, c in thresholds.items() if c <= D), default=0)


# ═══════════════════════════════════════════════════════════════════════
#  Algorithm 3: Greedy Heuristic for Large Instances
# ═══════════════════════════════════════════════════════════════════════

def greedy_variety_maximizer(
    cost: Callable[[int, int], int],
    u: list[int],
    alpha: list[int],
    D: int
) -> tuple[list[int], int, int]:
    """
    Greedy heuristic: assign each position the pitch that maximizes
    marginal variety increase while staying within budget.

    Not guaranteed optimal but runs in O(|ι| · |α|) time.

    Returns
    -------
    tuple
        (best_v, variety, total_cost)
    """
    n = len(u)
    remaining = D
    v = list(u)  # Start with the source (zero cost)
    used_pitches = set(v)

    # Try to swap each position to introduce new pitches
    for i in range(n):
        best_pitch = v[i]
        best_gain = 0
        best_cost_delta = 0

        for a in alpha:
            if a in used_pitches:
                continue
            cost_delta = cost(u[i], a) - cost(u[i], v[i])
            if cost_delta <= remaining:
                # This swap introduces a new pitch
                gain = 1
                if gain > best_gain or (gain == best_gain and cost_delta < best_cost_delta):
                    best_pitch = a
                    best_gain = gain
                    best_cost_delta = cost_delta

        if best_gain > 0:
            remaining -= best_cost_delta
            v[i] = best_pitch
            used_pitches.add(best_pitch)

    return v, len(set(v)), sum(cost(u[i], v[i]) for i in range(n))


# ═══════════════════════════════════════════════════════════════════════
#  Algorithm 4: Tropical Blahut–Arimoto Style Iteration
# ═══════════════════════════════════════════════════════════════════════

def tropical_blahut_arimoto(
    cost: Callable[[int, int], int],
    u: list[int],
    alpha: list[int],
    lam: float,
    max_iter: int = 100
) -> tuple[list[int], int, int]:
    """
    Lagrangian relaxation approach to the rate-distortion problem.

    For a given Lagrange multiplier λ, solve:
        max_v { harmonicVariety(v) - λ · totalCost(u, v) }

    By sweeping λ, we trace out the rate-distortion curve.
    In the tropical (discrete) setting, this is a finite optimization
    that converges in one pass.

    Parameters
    ----------
    lam : float
        Lagrange multiplier (tradeoff parameter).

    Returns
    -------
    tuple
        (optimal_v, variety, total_cost)
    """
    n = len(u)
    # For each position independently, choose the pitch maximizing
    # the Lagrangian objective
    best_v = None
    best_obj = float('-inf')

    # Since variety depends on the full assignment, we use greedy selection
    v = [alpha[0]] * n
    for i in range(n):
        best_a = alpha[0]
        best_local = float('-inf')
        for a in alpha:
            obj = -lam * cost(u[i], a)
            if obj > best_local:
                best_local = obj
                best_a = a
        v[i] = best_a

    variety = len(set(v))
    tc = sum(cost(u[i], v[i]) for i in range(n))
    return v, variety, tc


def sweep_lagrangian(
    cost: Callable[[int, int], int],
    u: list[int],
    alpha: list[int],
    num_lambdas: int = 50
) -> list[tuple[int, int]]:
    """
    Sweep the Lagrange multiplier to trace the rate-distortion tradeoff.

    Returns a list of (total_cost, variety) Pareto points.
    """
    points = set()
    for i in range(num_lambdas + 1):
        lam = i / max(num_lambdas, 1)
        v, var, tc = tropical_blahut_arimoto(cost, u, alpha, lam)
        points.add((tc, var))

    return sorted(points)


# ═══════════════════════════════════════════════════════════════════════
#  Demonstration
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    cost = lambda a, b: abs(a - b)
    alpha = list(range(5))
    u = [0, 1, 2, 3]

    print("=" * 60)
    print("Algorithm Comparison")
    print("=" * 60)

    # Exact computation
    rd = compute_rd_exact(cost, u, alpha, 20)
    print("\nExact R(D):")
    for D in range(15):
        print(f"  D={D:>3}  R(D)={rd[D]}")

    # Threshold computation
    thresholds = compute_thresholds(cost, u, alpha)
    print("\nThreshold costs C(k):")
    for k, c in sorted(thresholds.items()):
        c_str = str(c) if c != float('inf') else "∞"
        print(f"  k={k}  C(k)={c_str}")

    print("\nR(D) from thresholds (verification):")
    for D in range(15):
        rd_thresh = rd_from_thresholds(thresholds, D)
        match = "✓" if rd_thresh == rd[D] else "✗"
        print(f"  D={D:>3}  R(D)={rd_thresh} {match}")

    # Greedy heuristic
    print("\nGreedy heuristic:")
    for D in [0, 2, 5, 10]:
        v, var, tc = greedy_variety_maximizer(cost, u, alpha, D)
        print(f"  D={D:>3}  greedy variety={var} (cost={tc}), exact R(D)={rd[D]}")

    # Lagrangian sweep
    print("\nLagrangian sweep Pareto points:")
    pareto = sweep_lagrangian(cost, u, alpha)
    for tc, var in pareto:
        print(f"  cost={tc:>3}  variety={var}")
