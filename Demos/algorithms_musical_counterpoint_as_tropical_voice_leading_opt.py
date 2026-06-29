#!/usr/bin/env python3
"""
Tropical Counterpoint: Algorithms

Implements the core algorithms from the tropical music theory framework:
1. Tropical shortest-path DP for optimal voice leading
2. Pareto frontier computation for multi-objective optimization
3. Bach score minimization via scalarized objectives
"""

from typing import List, Tuple, Set, Dict, Optional
from dataclasses import dataclass
import heapq

# ─── Musical Constants ───────────────────────────────────────────────

PERFECT_CONSONANCES = frozenset({0, 7, 12})
IMPERFECT_CONSONANCES = frozenset({3, 4, 8, 9})
CONSONANCES = PERFECT_CONSONANCES | IMPERFECT_CONSONANCES

# ─── Cost Functions ──────────────────────────────────────────────────

def forbidden_vertical_penalty(k: int) -> float:
    """Vertical interval penalty: 1 if dissonant, 0 if consonant."""
    return 0.0 if abs(k) in CONSONANCES else 1.0

def melodic_leap_penalty(x: int, y: int) -> float:
    """Melodic leap penalty: max(0, |y-x| - 2)."""
    return max(0.0, abs(y - x) - 2)

def parallel_perfect_penalty(iv_curr: int, iv_next: int) -> float:
    """Parallel perfect consonance penalty."""
    return 1.0 if abs(iv_curr) in PERFECT_CONSONANCES and abs(iv_next) in PERFECT_CONSONANCES else 0.0

# ─── Algorithm 1: Tropical DP for Optimal Voice Leading ─────────────

@dataclass
class DPResult:
    """Result of tropical dynamic programming."""
    optimal_melody: List[int]
    optimal_cost: float
    dp_table: List[Dict[int, float]]
    parent: List[Dict[int, int]]

def tropical_dp_voice_leading(
    cantus: List[int],
    pitch_range: range,
    weights: Tuple[float, float, float] = (1.0, 1.0, 1.0)
) -> DPResult:
    """
    Find the optimal counterpoint melody via tropical (min-plus) DP.

    Uses the Bellman recursion:
      dp[k+1][x] = min_y (transition_cost(y,x) + dp[k][y])

    This is the min-plus semiring generalization of shortest paths
    in a layered DAG, where each layer represents a time step and
    each node represents a pitch.

    Args:
        cantus: The cantus firmus (fixed lower voice).
        pitch_range: Range of allowed pitches for the upper voice.
        weights: (A, B, C) penalty weights for vertical, melodic, parallel.

    Returns:
        DPResult with optimal melody, cost, and full DP table.

    Time complexity: O(n * P^2) where n = len(cantus), P = len(pitch_range).
    Space complexity: O(n * P).
    """
    A, B, C = weights
    n = len(cantus)

    dp = [{} for _ in range(n)]
    parent = [{} for _ in range(n)]

    # Base case: cost at position 0
    for x in pitch_range:
        dp[0][x] = A * forbidden_vertical_penalty(x - cantus[0])

    # Bellman recursion
    for k in range(1, n):
        for x in pitch_range:
            best_cost = float('inf')
            best_prev = None
            for y in pitch_range:
                # Transition cost (tropical edge weight)
                vert = A * forbidden_vertical_penalty(x - cantus[k])
                mel = B * melodic_leap_penalty(y, x)
                par = C * parallel_perfect_penalty(y - cantus[k-1], x - cantus[k])
                cost = vert + mel + par + dp[k-1][y]
                if cost < best_cost:
                    best_cost = cost
                    best_prev = y
            dp[k][x] = best_cost
            parent[k][x] = best_prev

    # Backtrack
    opt_pitch = min(pitch_range, key=lambda x: dp[n-1][x])
    melody = [0] * n
    melody[n-1] = opt_pitch
    for k in range(n-2, -1, -1):
        melody[k] = parent[k+1][melody[k+1]]

    return DPResult(
        optimal_melody=melody,
        optimal_cost=dp[n-1][opt_pitch],
        dp_table=dp,
        parent=parent
    )

# ─── Algorithm 2: Pareto Frontier Computation ───────────────────────

@dataclass
class ParetoPoint:
    """A point on the Pareto frontier."""
    melody: List[int]
    cost: float
    variety: int
    is_legal: bool

def compute_pareto_frontier(
    cantus: List[int],
    candidates: List[List[int]]
) -> List[ParetoPoint]:
    """
    Compute the Pareto frontier of melodies with respect to
    (minimize cost, maximize variety).

    Uses the standard dominance-checking algorithm.

    Args:
        cantus: The cantus firmus.
        candidates: List of candidate melodies.

    Returns:
        List of Pareto-optimal points, sorted by cost.

    Time complexity: O(m^2) where m = len(candidates).
    """
    n = len(cantus)
    points = []
    for m in candidates:
        c = sum(forbidden_vertical_penalty(m[i] - cantus[i]) for i in range(n))
        c += sum(melodic_leap_penalty(m[i], m[i+1]) for i in range(n-1))
        ivs = [m[i] - cantus[i] for i in range(n)]
        c += sum(parallel_perfect_penalty(ivs[i], ivs[i+1]) for i in range(n-1))
        v = len(set(ivs))
        legal = all(abs(ivs[i]) in CONSONANCES for i in range(n))
        legal = legal and all(
            not (abs(ivs[i]) in PERFECT_CONSONANCES and abs(ivs[i+1]) in PERFECT_CONSONANCES)
            for i in range(n-1)
        )
        legal = legal and all(abs(m[i+1]-m[i]) <= 2 for i in range(n-1))
        points.append(ParetoPoint(m, c, v, legal))

    # Filter dominated points
    pareto = []
    for p in points:
        dominated = any(
            (q.cost <= p.cost and q.variety >= p.variety) and
            (q.cost < p.cost or q.variety > p.variety)
            for q in points
        )
        if not dominated:
            pareto.append(p)

    pareto.sort(key=lambda p: (p.cost, -p.variety))
    return pareto

# ─── Algorithm 3: Bach Score Optimizer ───────────────────────────────

def bach_score_dp(
    cantus: List[int],
    pitch_range: range,
    lam: float,
    weights: Tuple[float, float, float] = (1.0, 1.0, 1.0)
) -> Tuple[List[int], float]:
    """
    Find melody minimizing the Bach score: totalCost - λ·variety.

    This combines DP for cost minimization with variety tracking.
    Since variety is a global property (depends on the full set of
    intervals used), we use a two-pass approach:
    1. DP to find near-optimal melodies.
    2. Greedy diversification to maximize variety.

    For exact optimization, we enumerate all DP-optimal paths
    and select the one with maximum variety.

    Args:
        cantus: The cantus firmus.
        pitch_range: Allowed pitch range.
        lam: Variety reward parameter.
        weights: Cost weights (A, B, C).

    Returns:
        (optimal_melody, bach_score).
    """
    A, B, C = weights
    n = len(cantus)

    # Phase 1: Find all near-optimal melodies via DP with bounded suboptimality
    result = tropical_dp_voice_leading(cantus, pitch_range, weights)
    opt_cost = result.optimal_cost

    # Phase 2: Enumerate good melodies within cost budget
    threshold = opt_cost + lam * n  # Allow cost slack up to λ·n
    good_melodies = []

    def enumerate_paths(k: int, path: List[int], cost_so_far: float):
        if k == n:
            if cost_so_far <= threshold:
                good_melodies.append((list(path), cost_so_far))
            return
        for x in pitch_range:
            if k == 0:
                added = A * forbidden_vertical_penalty(x - cantus[0])
            else:
                y = path[-1]
                added = (A * forbidden_vertical_penalty(x - cantus[k]) +
                         B * melodic_leap_penalty(y, x) +
                         C * parallel_perfect_penalty(y - cantus[k-1], x - cantus[k]))

            # Prune if cost already exceeds threshold
            if cost_so_far + added > threshold:
                continue

            # Optimistic bound on remaining cost
            remaining_lower = 0  # Could be refined with DP backward pass
            if cost_so_far + added + remaining_lower <= threshold:
                path.append(x)
                enumerate_paths(k + 1, path, cost_so_far + added)
                path.pop()

    # For large pitch ranges, limit enumeration
    if len(pitch_range) <= 15 and n <= 6:
        enumerate_paths(0, [], 0.0)
    else:
        # Fallback: sample around DP optimum
        melody = result.optimal_melody
        good_melodies.append((melody, opt_cost))
        import random
        random.seed(42)
        for _ in range(10000):
            m = list(melody)
            pos = random.randint(0, n-1)
            m[pos] += random.choice([-2, -1, 0, 1, 2])
            if m[pos] in pitch_range:
                c = 0.0
                for i in range(n):
                    c += A * forbidden_vertical_penalty(m[i] - cantus[i])
                for i in range(n-1):
                    c += B * melodic_leap_penalty(m[i], m[i+1])
                    c += C * parallel_perfect_penalty(m[i]-cantus[i], m[i+1]-cantus[i+1])
                if c <= threshold:
                    good_melodies.append((m, c))

    # Phase 3: Select melody with best Bach score
    if not good_melodies:
        return result.optimal_melody, opt_cost

    def bach_score(m, c):
        v = len(set(m[i] - cantus[i] for i in range(n)))
        return c - lam * v

    best_melody, best_cost = min(good_melodies, key=lambda mc: bach_score(*mc))
    return best_melody, bach_score(best_melody, best_cost)

# ─── Demo ────────────────────────────────────────────────────────────

if __name__ == "__main__":
    cantus = [60, 62, 64, 65, 67]

    print("=== Tropical DP Voice Leading ===")
    result = tropical_dp_voice_leading(cantus, range(55, 80))
    print(f"Cantus:  {cantus}")
    print(f"Optimal: {result.optimal_melody}")
    print(f"Cost:    {result.optimal_cost}")
    print(f"Variety: {len(set(result.optimal_melody[i]-cantus[i] for i in range(5)))}")

    print("\n=== Bach Score Optimization ===")
    for lam in [0.0, 1.0, 2.0, 5.0]:
        melody, score = bach_score_dp(cantus, range(55, 80), lam)
        v = len(set(melody[i]-cantus[i] for i in range(5)))
        print(f"λ={lam:.1f}: melody={melody}, score={score:.1f}, variety={v}")
