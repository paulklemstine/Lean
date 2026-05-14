#!/usr/bin/env python3
"""
Tropical Voice-Leading Optimization — Algorithms

Implements the core algorithms from the tropical music theory framework:
1. Tropical shortest-path voice-leading search (Bellman-style DP)
2. Pareto frontier computation for multi-objective optimization
3. Weighted penalty optimizer with scale separation
4. Harmonic variety analyzer

All algorithms have documented time/space complexity.
"""

import numpy as np
from typing import List, Tuple, Dict, Set, Optional
from itertools import product
from dataclasses import dataclass

# ─────────────────────────────────────────────────────────────────
# Data Structures
# ─────────────────────────────────────────────────────────────────

@dataclass
class VoiceLeadingResult:
    """Result of a voice-leading optimization."""
    melody: List[int]
    cost: float
    intervals: List[int]
    steps: List[int]
    is_legal: bool
    harmonic_variety: int

@dataclass
class ParetoPoint:
    """A point on the Pareto frontier."""
    melody: List[int]
    cost: float
    variety: int
    is_legal: bool

# ─────────────────────────────────────────────────────────────────
# Interval Classification
# ─────────────────────────────────────────────────────────────────

PERFECT_CONSONANCES: Set[int] = {0, 7, 12}
IMPERFECT_CONSONANCES: Set[int] = {3, 4, 8, 9}
ALL_CONSONANCES: Set[int] = PERFECT_CONSONANCES | IMPERFECT_CONSONANCES

def is_perfect(k: int) -> bool:
    """Check if interval k (in semitones) is a perfect consonance."""
    return abs(k) in PERFECT_CONSONANCES

def is_consonant(k: int) -> bool:
    """Check if interval k is consonant (perfect or imperfect)."""
    return abs(k) in ALL_CONSONANCES

# ─────────────────────────────────────────────────────────────────
# Cost Functions
# ─────────────────────────────────────────────────────────────────

def forbidden_penalty(k: int) -> float:
    """Penalty for dissonant vertical interval. O(1)."""
    return 0.0 if is_consonant(k) else 1.0

def leap_penalty(x: int, y: int) -> float:
    """Penalty for melodic leap > 2 semitones. O(1)."""
    return max(0.0, abs(y - x) - 2.0)

def parallel_penalty(u: List[int], v: List[int], i: int) -> float:
    """Penalty for parallel perfect motion at position i. O(1)."""
    if is_perfect(v[i] - u[i]) and is_perfect(v[i+1] - u[i+1]):
        return 1.0
    return 0.0

def total_cost(u: List[int], v: List[int]) -> float:
    """
    Total contrapuntal cost.

    Time: O(n) where n = len(u)
    Space: O(1)
    """
    n = len(u)
    cost = sum(forbidden_penalty(v[i] - u[i]) for i in range(n))
    cost += sum(leap_penalty(v[i], v[i+1]) for i in range(n-1))
    cost += sum(parallel_penalty(u, v, i) for i in range(n-1))
    return cost

# ─────────────────────────────────────────────────────────────────
# Algorithm 1: Tropical Shortest-Path Voice-Leading Search
# ─────────────────────────────────────────────────────────────────

def tropical_voice_leading_dp(
    cantus: List[int],
    pitch_range: Tuple[int, int] = (-2, 16),
    include_parallel_penalty: bool = False
) -> VoiceLeadingResult:
    """
    Find the optimal counterpoint voice over a cantus firmus using
    tropical (min-plus) dynamic programming.

    This implements the certified Bellman recursion from Theorem 3:
        dp[k+1][x] = min_y { transition(y, x) + dp[k][y] }

    where transition cost = vertical penalty + melodic leap penalty.

    Time:  O(n * P^2) where n = melody length, P = pitch alphabet size
    Space: O(n * P) for the DP table and backtracking

    Args:
        cantus: The cantus firmus (fixed lower voice)
        pitch_range: (min_pitch, max_pitch) for the upper voice
        include_parallel_penalty: Whether to include parallel-fifths penalty
            (makes the problem non-decomposable into pure DP, but still works
            as a heuristic; formally certified only without this flag)

    Returns:
        VoiceLeadingResult with optimal melody and metadata
    """
    n = len(cantus)
    lo, hi = pitch_range
    pitches = list(range(lo, hi + 1))
    P = len(pitches)

    # DP tables: dp[k][x_index] = (cost, predecessor_index)
    INF = float('inf')
    dp_cost = [[INF] * P for _ in range(n)]
    dp_prev = [[-1] * P for _ in range(n)]

    # Base case: k = 0
    for xi, x in enumerate(pitches):
        dp_cost[0][xi] = forbidden_penalty(x - cantus[0])

    # Bellman recursion: k = 1, ..., n-1
    for k in range(1, n):
        for xi, x in enumerate(pitches):
            vert_cost = forbidden_penalty(x - cantus[k])
            for yi, y in enumerate(pitches):
                trans = vert_cost + leap_penalty(y, x)
                if include_parallel_penalty:
                    if is_perfect(y - cantus[k-1]) and is_perfect(x - cantus[k]):
                        trans += 1.0
                candidate = trans + dp_cost[k-1][yi]
                if candidate < dp_cost[k][xi]:
                    dp_cost[k][xi] = candidate
                    dp_prev[k][xi] = yi

    # Backtrack to find optimal melody
    best_xi = min(range(P), key=lambda xi: dp_cost[n-1][xi])
    melody = [0] * n
    xi = best_xi
    for k in range(n-1, -1, -1):
        melody[k] = pitches[xi]
        xi = dp_prev[k][xi]

    opt_cost = dp_cost[n-1][best_xi]
    intervals = [melody[i] - cantus[i] for i in range(n)]
    steps = [abs(melody[i+1] - melody[i]) for i in range(n-1)]
    legal = all(is_consonant(k) for k in intervals) and \
            all(s <= 2 for s in steps) and \
            not any(is_perfect(intervals[i]) and is_perfect(intervals[i+1])
                    for i in range(n-1))

    return VoiceLeadingResult(
        melody=melody, cost=opt_cost, intervals=intervals,
        steps=steps, is_legal=legal,
        harmonic_variety=len(set(intervals))
    )

# ─────────────────────────────────────────────────────────────────
# Algorithm 2: Pareto Frontier Computation
# ─────────────────────────────────────────────────────────────────

def compute_pareto_frontier(
    cantus: List[int],
    candidates: List[List[int]]
) -> List[ParetoPoint]:
    """
    Compute the Pareto frontier for the bi-objective problem:
        minimize: contrapuntal cost
        maximize: harmonic variety

    A point is Pareto-optimal if no other point has both lower cost
    and higher variety.

    Time:  O(m^2) where m = |candidates| (naive; could be O(m log m) with sorting)
    Space: O(m)

    Args:
        cantus: The cantus firmus
        candidates: List of candidate melodies

    Returns:
        List of ParetoPoint on the frontier, sorted by cost
    """
    n = len(cantus)

    # Evaluate all candidates
    evaluated = []
    for v in candidates:
        c = total_cost(cantus, v)
        h = len(set(v[i] - cantus[i] for i in range(n)))
        legal = all(is_consonant(v[i] - cantus[i]) for i in range(n)) and \
                all(abs(v[i+1] - v[i]) <= 2 for i in range(n-1)) and \
                not any(is_perfect(v[i] - cantus[i]) and is_perfect(v[i+1] - cantus[i+1])
                        for i in range(n-1))
        evaluated.append(ParetoPoint(melody=v, cost=c, variety=h, is_legal=legal))

    # Filter Pareto-optimal points
    pareto = []
    for p in evaluated:
        dominated = any(
            q.cost <= p.cost and q.variety >= p.variety and
            (q.cost < p.cost or q.variety > p.variety)
            for q in evaluated
        )
        if not dominated:
            pareto.append(p)

    pareto.sort(key=lambda p: (p.cost, -p.variety))
    return pareto

# ─────────────────────────────────────────────────────────────────
# Algorithm 3: Scale-Separated Penalty Optimizer
# ─────────────────────────────────────────────────────────────────

def find_minimizer_with_guarantees(
    cantus: List[int],
    candidates: List[List[int]],
    A: float = 100.0, B: float = 1.0, C: float = 100.0,
    M: int = 4
) -> Tuple[VoiceLeadingResult, bool, str]:
    """
    Find the weighted-cost minimizer and check if penalty separation
    guarantees legality (Theorem 2).

    The theorem states: if A > (n-1)*B*M and C > (n-1)*B*M, then
    any minimizer must satisfy vertical consonance and no-parallel-perfects
    (VPLegal), provided a legal candidate exists.

    Time:  O(m * n) where m = |candidates|, n = melody length
    Space: O(m)

    Args:
        cantus: Cantus firmus
        candidates: Candidate melodies (all with steps ≤ M)
        A, B, C: Penalty weights
        M: Step bound for candidates

    Returns:
        (result, guarantee_holds, explanation)
    """
    n = len(cantus)
    threshold = (n - 1) * B * M

    # Find minimizer
    best_cost = float('inf')
    best_melody = candidates[0]
    for v in candidates:
        c = weighted_cost_fn(A, B, C, cantus, v)
        if c < best_cost:
            best_cost = c
            best_melody = v

    intervals = [best_melody[i] - cantus[i] for i in range(n)]
    steps = [abs(best_melody[i+1] - best_melody[i]) for i in range(n-1)]
    legal = all(is_consonant(k) for k in intervals) and \
            all(s <= 2 for s in steps) and \
            not any(is_perfect(intervals[i]) and is_perfect(intervals[i+1])
                    for i in range(n-1))

    # Check if legal candidate exists
    has_legal = any(
        all(is_consonant(v[i] - cantus[i]) for i in range(n)) and
        not any(is_perfect(v[i] - cantus[i]) and is_perfect(v[i+1] - cantus[i+1])
                for i in range(n-1))
        for v in candidates
    )

    guarantee = A > threshold and C > threshold and has_legal
    explanation = (
        f"Threshold = (n-1)*B*M = {threshold:.1f}. "
        f"A={A:.1f}{'>' if A > threshold else '≤'}{threshold:.1f}, "
        f"C={C:.1f}{'>' if C > threshold else '≤'}{threshold:.1f}. "
        f"Legal candidate exists: {has_legal}. "
        f"Guarantee holds: {guarantee}."
    )

    result = VoiceLeadingResult(
        melody=best_melody, cost=best_cost, intervals=intervals,
        steps=steps, is_legal=legal,
        harmonic_variety=len(set(intervals))
    )

    return result, guarantee, explanation

def weighted_cost_fn(A: float, B: float, C: float,
                     u: List[int], v: List[int]) -> float:
    """Weighted total cost function."""
    n = len(u)
    vert = sum(forbidden_penalty(v[i] - u[i]) for i in range(n))
    melodic = sum(leap_penalty(v[i], v[i+1]) for i in range(n-1))
    par = sum(parallel_penalty(u, v, i) for i in range(n-1))
    return A * vert + B * melodic + C * par

# ─────────────────────────────────────────────────────────────────
# Algorithm 4: Harmonic Variety Analyzer
# ─────────────────────────────────────────────────────────────────

def analyze_harmonic_landscape(
    cantus: List[int],
    pitch_range: Tuple[int, int] = (0, 12),
    max_step: int = 4
) -> Dict:
    """
    Analyze the distribution of (cost, variety) pairs across all
    candidate melodies, identifying the strict-style and Bach-style
    regions of the optimization landscape.

    Time:  O(P^n * n) where P = pitch range, n = melody length
    Space: O(P^n)

    Args:
        cantus: Cantus firmus
        pitch_range: Range of allowed pitches
        max_step: Maximum allowed step size

    Returns:
        Dictionary with landscape statistics
    """
    n = len(cantus)
    lo, hi = pitch_range

    # Generate candidates with bounded steps
    candidates = []
    def generate(pos, prev):
        if pos == n:
            candidates.append(list(prev))
            return
        for p in range(max(lo, prev[-1] - max_step) if prev else lo,
                       min(hi, prev[-1] + max_step) + 1 if prev else hi + 1):
            prev.append(p)
            generate(pos + 1, prev)
            prev.pop()

    generate(0, [])

    # Classify
    results = {
        'total_candidates': len(candidates),
        'legal_count': 0,
        'cost_variety_pairs': [],
        'min_cost': float('inf'),
        'max_variety': 0,
        'legal_min_cost': float('inf'),
        'pareto_size': 0
    }

    for v in candidates:
        c = total_cost(cantus, v)
        h = len(set(v[i] - cantus[i] for i in range(n)))
        legal = all(is_consonant(v[i] - cantus[i]) for i in range(n)) and \
                all(abs(v[i+1] - v[i]) <= 2 for i in range(n-1)) and \
                not any(is_perfect(v[i] - cantus[i]) and is_perfect(v[i+1] - cantus[i+1])
                        for i in range(n-1))
        results['cost_variety_pairs'].append((c, h, legal))
        results['min_cost'] = min(results['min_cost'], c)
        results['max_variety'] = max(results['max_variety'], h)
        if legal:
            results['legal_count'] += 1
            results['legal_min_cost'] = min(results['legal_min_cost'], c)

    return results


# ─────────────────────────────────────────────────────────────────
# Main: Run all algorithms
# ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("TROPICAL VOICE-LEADING ALGORITHMS")
    print("=" * 60)

    # Algorithm 1: DP voice-leading search
    print("\n--- Algorithm 1: Tropical DP Voice-Leading ---")
    cantus = [0, 2, 4, 5, 7, 5, 4, 2, 0]
    result = tropical_voice_leading_dp(cantus, pitch_range=(0, 16))
    print(f"Cantus:    {cantus}")
    print(f"Optimal:   {result.melody}")
    print(f"Intervals: {result.intervals}")
    print(f"Steps:     {result.steps}")
    print(f"Cost:      {result.cost:.2f}")
    print(f"Legal:     {result.is_legal}")
    print(f"Variety:   {result.harmonic_variety}")

    # Algorithm 2: Pareto frontier
    print("\n--- Algorithm 2: Pareto Frontier ---")
    cantus3 = [0, 2, 4]
    cands = []
    for v0 in range(-2, 14):
        for v1 in range(v0 - 4, v0 + 5):
            for v2 in range(v1 - 4, v1 + 5):
                cands.append([v0, v1, v2])
    frontier = compute_pareto_frontier(cantus3, cands)
    print(f"Total candidates: {len(cands)}")
    print(f"Pareto-optimal: {len(frontier)}")
    for p in frontier[:5]:
        print(f"  Cost={p.cost:.1f}, Variety={p.variety}, Legal={p.is_legal}, Melody={p.melody}")

    # Algorithm 3: Guaranteed optimizer
    print("\n--- Algorithm 3: Scale-Separated Optimizer ---")
    result, guarantee, explanation = find_minimizer_with_guarantees(
        cantus3, cands, A=100, B=1, C=100, M=4
    )
    print(f"Minimizer: {result.melody}, Cost={result.cost:.1f}")
    print(f"Legal: {result.is_legal}")
    print(f"Guarantee: {explanation}")

    print("\n✓ All algorithms executed successfully")
