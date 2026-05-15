#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Voice-Leading Transport Optimization

Implements:
1. W1 two-point cost (combinatorial optimal transport for 2-atom measures)
2. k-voice sorted matching transport
3. Dynamic programming for optimal counterpoint
4. Lipschitz stability bounds
5. Benamou-Brenier discrete action computation
"""

import numpy as np
from typing import List, Tuple, Optional, Dict
from itertools import permutations
from dataclasses import dataclass


# ============================================================
# Core Transport Costs
# ============================================================

def ordered_vl(p: Tuple[int, int], q: Tuple[int, int]) -> int:
    """
    Ordered voice-leading cost between two sonorities.

    Each voice moves to the corresponding voice:
    voice 1 → voice 1, voice 2 → voice 2.

    Time complexity: O(1)
    Space complexity: O(1)

    >>> ordered_vl((60, 64), (62, 65))
    3
    """
    return abs(p[0] - q[0]) + abs(p[1] - q[1])


def crossing_vl(p: Tuple[int, int], q: Tuple[int, int]) -> int:
    """
    Crossing voice-leading cost between two sonorities.

    Voices swap partners: voice 1 → voice 2, voice 2 → voice 1.

    Time complexity: O(1)
    Space complexity: O(1)

    >>> crossing_vl((60, 64), (62, 65))
    7
    """
    return abs(p[0] - q[1]) + abs(p[1] - q[0])


def w1_two_point(p: Tuple[int, int], q: Tuple[int, int]) -> int:
    """
    1-Wasserstein distance between two 2-atom measures on ℤ.

    For ordered pairs (a₁ ≤ b₁) and (a₂ ≤ b₂), this equals
    the ordered voice-leading cost (Theorem: ordered_matching_optimal).

    Time complexity: O(1)
    Space complexity: O(1)

    >>> w1_two_point((60, 64), (62, 65))
    3
    """
    return min(ordered_vl(p, q), crossing_vl(p, q))


def w1_k_voice(x: np.ndarray, y: np.ndarray) -> int:
    """
    1-Wasserstein distance between two k-atom measures on ℤ.

    By the sorted matching optimality theorem, this equals
    the sum of |x_i - y_i| when both are sorted.

    Time complexity: O(k log k) for sorting
    Space complexity: O(k)

    Args:
        x: array of k pitches (first chord)
        y: array of k pitches (second chord)

    Returns:
        Optimal transport cost

    >>> w1_k_voice(np.array([48, 60, 64]), np.array([47, 59, 62]))
    4
    """
    xs = np.sort(x)
    ys = np.sort(y)
    return int(np.sum(np.abs(xs - ys)))


# ============================================================
# Path-Level Transport Action
# ============================================================

@dataclass
class CounterpointPath:
    """A counterpoint path: two voice sequences over time."""
    cantus: List[int]
    counterpoint: List[int]

    @property
    def n_steps(self) -> int:
        return len(self.cantus)

    @property
    def n_transitions(self) -> int:
        return len(self.cantus) - 1

    def sonority(self, i: int) -> Tuple[int, int]:
        return (self.cantus[i], self.counterpoint[i])

    def is_ordered(self) -> bool:
        return all(c <= p for c, p in zip(self.cantus, self.counterpoint))


def path_cost(path: CounterpointPath) -> int:
    """
    Total melodic path cost (discrete Benamou-Brenier action).

    Computes Σᵢ orderedVL(sᵢ, sᵢ₊₁) over all consecutive sonorities.

    Time complexity: O(n) where n = number of transitions
    Space complexity: O(1)
    """
    total = 0
    for i in range(path.n_transitions):
        total += ordered_vl(path.sonority(i), path.sonority(i + 1))
    return total


def path_cost_as_w1_sum(path: CounterpointPath) -> int:
    """
    Total path cost computed as sum of W1 costs.

    By pathCost_eq_sum_W1, equals path_cost when voices are ordered.

    Time complexity: O(n)
    Space complexity: O(1)
    """
    total = 0
    for i in range(path.n_transitions):
        total += w1_two_point(path.sonority(i), path.sonority(i + 1))
    return total


# ============================================================
# Optimal Counterpoint via Dynamic Programming
# ============================================================

def optimal_counterpoint_dp(
    cantus: List[int],
    admissible_intervals: List[int],
    harmonic_penalty: Optional[Dict[int, float]] = None,
    max_leap: int = 12
) -> Tuple[List[int], float]:
    """
    Find the counterpoint minimizing total transport cost via DP.

    Algorithm:
        1. At each time step, enumerate admissible CP pitches
           (cantus + interval for each consonant interval).
        2. Build a DP table: cost[t][p] = minimum cost to reach pitch p
           at time t.
        3. Backtrack to recover the optimal path.

    Time complexity: O(n · k²) where n = melody length, k = |intervals|
    Space complexity: O(n · k)

    Args:
        cantus: cantus firmus melody (list of MIDI pitches)
        admissible_intervals: allowed intervals above cantus (in semitones)
        harmonic_penalty: optional penalty for each interval (default: 0)
        max_leap: maximum allowed melodic leap in counterpoint

    Returns:
        (optimal_cp, total_cost): optimal counterpoint and its cost
    """
    if harmonic_penalty is None:
        harmonic_penalty = {iv: 0 for iv in admissible_intervals}

    n = len(cantus)

    # Possible pitches at each time step
    possible = []
    for c in cantus:
        possible.append([c + iv for iv in admissible_intervals])

    # DP table
    INF = float('inf')
    cost = [dict() for _ in range(n)]
    parent = [dict() for _ in range(n)]

    # Initialize first step
    for p in possible[0]:
        iv = p - cantus[0]
        cost[0][p] = harmonic_penalty.get(iv, 0)
        parent[0][p] = None

    # Forward pass
    for t in range(1, n):
        for p in possible[t]:
            best_cost = INF
            best_prev = None
            iv = p - cantus[t]
            h_cost = harmonic_penalty.get(iv, 0)

            for prev_p in possible[t - 1]:
                # Check leap constraint
                if abs(p - prev_p) > max_leap:
                    continue

                transition_cost = ordered_vl(
                    (cantus[t - 1], prev_p),
                    (cantus[t], p)
                )
                total = cost[t - 1][prev_p] + transition_cost + h_cost

                if total < best_cost:
                    best_cost = total
                    best_prev = prev_p

            if best_cost < INF:
                cost[t][p] = best_cost
                parent[t][p] = best_prev

    # Backtrack
    if not cost[n - 1]:
        raise ValueError("No feasible counterpoint found")

    best_final = min(cost[n - 1], key=cost[n - 1].get)
    cp = [0] * n
    cp[n - 1] = best_final
    for t in range(n - 2, -1, -1):
        cp[t] = parent[t + 1][cp[t + 1]]

    return cp, cost[n - 1][best_final]


# ============================================================
# Lipschitz Stability Analysis
# ============================================================

def lipschitz_bound(cf1: List[int], cf2: List[int]) -> int:
    """
    Compute the Lipschitz bound for path cost difference.

    By transportAction_lipschitz_in_cantus:
    |pathCost(cf₁, cp) - pathCost(cf₂, cp)| ≤ 2n · ‖cf₁ - cf₂‖∞

    Time complexity: O(n)
    Space complexity: O(1)
    """
    n = len(cf1) - 1  # number of transitions
    delta = max(abs(a - b) for a, b in zip(cf1, cf2))
    return 2 * n * delta


def stability_analysis(
    cf1: List[int],
    cf2: List[int],
    cp: List[int]
) -> Dict[str, float]:
    """
    Full stability analysis comparing two cantus firmi with same counterpoint.

    Returns dictionary with:
    - sup_norm: ‖cf₁ - cf₂‖∞
    - path_cost_1: pathCost(cf₁, cp)
    - path_cost_2: pathCost(cf₂, cp)
    - actual_diff: |pathCost(cf₁, cp) - pathCost(cf₂, cp)|
    - lipschitz_bound: 2n · ‖cf₁ - cf₂‖∞
    - tightness_ratio: actual_diff / lipschitz_bound
    """
    p1 = CounterpointPath(cf1, cp)
    p2 = CounterpointPath(cf2, cp)
    pc1 = path_cost(p1)
    pc2 = path_cost(p2)
    n = len(cf1) - 1
    delta = max(abs(a - b) for a, b in zip(cf1, cf2))
    bound = 2 * n * delta

    return {
        'sup_norm': delta,
        'path_cost_1': pc1,
        'path_cost_2': pc2,
        'actual_diff': abs(pc1 - pc2),
        'lipschitz_bound': bound,
        'tightness_ratio': abs(pc1 - pc2) / bound if bound > 0 else 0.0
    }


# ============================================================
# Brute-Force Verification (for testing)
# ============================================================

def verify_sorted_matching(x: np.ndarray, y: np.ndarray) -> bool:
    """
    Verify the sorted matching optimality theorem by exhaustive search.

    Checks all k! permutations. Only feasible for small k.

    Time complexity: O(k · k!)
    Space complexity: O(k!)
    """
    k = len(x)
    xs = np.sort(x)
    ys = np.sort(y)
    identity_cost = np.sum(np.abs(xs - ys))

    for perm in permutations(range(k)):
        perm_cost = sum(abs(xs[i] - ys[perm[i]]) for i in range(k))
        if perm_cost < identity_cost:
            return False
    return True


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("=== Algorithms Demo ===\n")

    # Example 1: Two-point transport
    p, q = (60, 64), (62, 65)
    print(f"W1 cost between {p} and {q}: {w1_two_point(p, q)}")
    print(f"  ordered={ordered_vl(p, q)}, crossing={crossing_vl(p, q)}")

    # Example 2: k-voice transport
    chord1 = np.array([48, 55, 60, 64])
    chord2 = np.array([47, 55, 59, 62])
    print(f"\nW1 cost between chords {chord1} and {chord2}: "
          f"{w1_k_voice(chord1, chord2)}")
    print(f"  Sorted matching verified: {verify_sorted_matching(chord1, chord2)}")

    # Example 3: Optimal counterpoint
    cantus = [60, 62, 64, 65, 67, 65, 64, 62, 60]
    intervals = [3, 4, 5, 7, 8, 9, 12]
    cp, cost = optimal_counterpoint_dp(cantus, intervals)
    print(f"\nOptimal counterpoint for cantus {cantus}:")
    print(f"  CP: {cp}")
    print(f"  Intervals: {[c - f for f, c in zip(cantus, cp)]}")
    print(f"  Total transport cost: {cost}")

    # Example 4: Stability analysis
    cf1 = [60, 62, 64, 65, 67]
    cf2 = [61, 63, 64, 66, 67]
    cp_fixed = [64, 65, 67, 69, 71]
    results = stability_analysis(cf1, cf2, cp_fixed)
    print(f"\nStability analysis:")
    for k, v in results.items():
        print(f"  {k}: {v}")
