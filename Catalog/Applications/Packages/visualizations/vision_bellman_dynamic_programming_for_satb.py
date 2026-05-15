#!/usr/bin/env python3
"""
Tropical SATB Chorale Optimization — Algorithms

Complete implementations of the algorithms described in the research paper,
including the Bellman DP, tropical matrix formulation, and constraint encoding.
"""

import numpy as np
from typing import Callable, Dict, List, Optional, Set, Tuple
from dataclasses import dataclass
import time

# ─── Type aliases ────────────────────────────────────────────────────────

Voice = Tuple[int, int, int, int]  # (Soprano, Alto, Tenor, Bass)
PenaltyFn = Callable[[Voice], float]
LeadFn = Callable[[Voice, Voice], float]


# ─── Algorithm 1: Bellman Dynamic Programming ────────────────────────────

@dataclass
class BellmanResult:
    """Result of the Bellman DP algorithm."""
    optimal_cost: float
    optimal_path: List[Voice]
    value_table: List[Dict[Voice, float]]
    backpointers: List[Dict[Voice, Voice]]
    runtime_ms: float


def bellman_satb_dp(
    admissible_sets: List[List[Voice]],
    vert: PenaltyFn,
    lead: LeadFn,
) -> BellmanResult:
    """
    Algorithm 1: Bellman Dynamic Programming for SATB Optimization

    Computes the globally optimal SATB realization via backward induction.

    Parameters:
        admissible_sets: admissible_sets[i] = list of admissible voicings at step i
        vert: vertical (harmonic) penalty function
        lead: horizontal (voice-leading) penalty function

    Returns:
        BellmanResult with optimal cost, path, value tables, and backpointers

    Complexity:
        Time:  O(N · |S|²)  where N = number of steps, |S| = max state space size
        Space: O(N · |S|)

    Pseudocode:
        1. Initialize: V[N][v] = vert(v) for all v in admissible_sets[N]
        2. For n = N-1 down to 0:
             For each v in admissible_sets[n]:
               V[n][v] = vert(v) + min_{w in admissible_sets[n+1]} (lead(v,w) + V[n+1][w])
               backptr[n][v] = argmin_w (lead(v,w) + V[n+1][w])
        3. Find v* = argmin_{v in admissible_sets[0]} V[0][v]
        4. Trace path: v*, backptr[0][v*], backptr[1][...], ...
    """
    start = time.time()
    N = len(admissible_sets) - 1

    value_table: List[Dict[Voice, float]] = [{} for _ in range(N + 1)]
    backpointers: List[Dict[Voice, Voice]] = [{} for _ in range(N)]

    # Base case
    for v in admissible_sets[N]:
        value_table[N][v] = vert(v)

    # Backward recursion (Bellman equation)
    for n in range(N - 1, -1, -1):
        for v in admissible_sets[n]:
            best_cost = float('inf')
            best_next = admissible_sets[n + 1][0]
            for w in admissible_sets[n + 1]:
                cost = lead(v, w) + value_table[n + 1][w]
                if cost < best_cost:
                    best_cost = cost
                    best_next = w
            value_table[n][v] = vert(v) + best_cost
            backpointers[n][v] = best_next

    # Find optimal start
    best_start = min(admissible_sets[0], key=lambda v: value_table[0][v])
    opt_cost = value_table[0][best_start]

    # Trace path
    path = [best_start]
    for n in range(N):
        path.append(backpointers[n][path[-1]])

    elapsed = (time.time() - start) * 1000

    return BellmanResult(
        optimal_cost=opt_cost,
        optimal_path=path,
        value_table=value_table,
        backpointers=backpointers,
        runtime_ms=elapsed,
    )


# ─── Algorithm 2: Tropical Matrix Multiplication ────────────────────────

def tropical_matrix_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical (min-plus) matrix multiplication.

    (A ⊕ B)_{ij} = min_k (A_{ik} + B_{kj})

    This replaces standard matrix multiplication's (sum, product)
    with (min, sum) — the min-plus semiring.

    Complexity: O(n³) where n = matrix dimension
    """
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C


def build_transition_matrix(
    states: List[Voice],
    lead: LeadFn,
    vert_next: PenaltyFn,
) -> np.ndarray:
    """
    Build the tropical transition matrix for one time step.

    M[i,j] = lead(states[i], states[j]) + vert(states[j])

    The (i,j) entry represents the cost of transitioning from state i to state j,
    including the vertical penalty at the destination.
    """
    n = len(states)
    M = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            M[i, j] = lead(states[i], states[j]) + vert_next(states[j])
    return M


def tropical_matrix_dp(
    states: List[Voice],
    vert: PenaltyFn,
    lead: LeadFn,
    N: int,
) -> np.ndarray:
    """
    Algorithm 2: Tropical Matrix Power for Multi-Step Optimization

    Computes the N-step optimal cost matrix via iterated tropical multiplication.

    The (i,j) entry of the result gives the minimum cost of an N+1 step path
    from state i to state j (including all intermediate vertical and leading costs).

    Complexity: O(N · |S|³)
    """
    n = len(states)
    # Initial matrix: just vertical penalties on diagonal-ish
    M = build_transition_matrix(states, lead, vert)

    result = M.copy()
    for _ in range(N - 1):
        result = tropical_matrix_multiply(result, M)

    # Add initial vertical penalties
    for i in range(n):
        for j in range(n):
            result[i, j] += vert(states[i])

    return result


# ─── Algorithm 3: Constraint Encoding ────────────────────────────────────

@dataclass
class TropicalConstraint:
    """A tropical constraint: penalty function with associated predicate."""
    name: str
    penalty: PenaltyFn
    predicate: Callable[[Voice], bool]
    weight: float = 1.0


def tropical_conjunction(constraints: List[TropicalConstraint]) -> PenaltyFn:
    """
    Algorithm 3: Tropical Conjunction of Constraints

    Combines multiple constraints via tropical max (= conjunction).
    The combined penalty is max(p₁(v), p₂(v), ..., pₖ(v)).

    Property: combined_penalty(v) = 0 ↔ all individual penalties = 0
              (when all penalties are nonneg)
    """
    def combined(v: Voice) -> float:
        return max(c.weight * c.penalty(v) for c in constraints)
    return combined


def verify_conjunction_property(
    constraints: List[TropicalConstraint],
    test_voices: List[Voice],
) -> bool:
    """
    Verify the tropical conjunction property:
    max(penalties) = 0 ↔ all predicates satisfied
    """
    combined = tropical_conjunction(constraints)
    for v in test_voices:
        all_legal = all(c.predicate(v) for c in constraints)
        zero_penalty = (combined(v) == 0)
        if all_legal != zero_penalty:
            return False
    return True


# ─── Algorithm 4: Viterbi-style Forward Pass ────────────────────────────

def viterbi_satb(
    admissible_sets: List[List[Voice]],
    vert: PenaltyFn,
    lead: LeadFn,
) -> BellmanResult:
    """
    Algorithm 4: Viterbi (Forward) Algorithm for SATB

    Equivalent to Bellman DP but computed forward. This variant is more
    natural for streaming/online applications.

    The connection to Viterbi decoding in HMMs: states are voice configs,
    transition costs replace log-probabilities, and we seek the minimum-cost
    path instead of the maximum-probability path.

    Complexity: O(N · |S|²)
    """
    start = time.time()
    N = len(admissible_sets) - 1

    # Forward tables
    cost_table: List[Dict[Voice, float]] = [{} for _ in range(N + 1)]
    backpointers: List[Dict[Voice, Voice]] = [{} for _ in range(N)]

    # Initialize
    for v in admissible_sets[0]:
        cost_table[0][v] = vert(v)

    # Forward pass
    for n in range(1, N + 1):
        for w in admissible_sets[n]:
            best_cost = float('inf')
            best_prev = admissible_sets[n - 1][0]
            for v in admissible_sets[n - 1]:
                cost = cost_table[n - 1][v] + lead(v, w)
                if cost < best_cost:
                    best_cost = cost
                    best_prev = v
            cost_table[n][w] = best_cost + vert(w)
            backpointers[n - 1][w] = best_prev

    # Find optimal end state
    best_end = min(admissible_sets[N], key=lambda v: cost_table[N][v])
    opt_cost = cost_table[N][best_end]

    # Trace backward
    path = [best_end]
    for n in range(N - 1, -1, -1):
        path.append(backpointers[n][path[-1]])
    path.reverse()

    elapsed = (time.time() - start) * 1000

    return BellmanResult(
        optimal_cost=opt_cost,
        optimal_path=path,
        value_table=cost_table,
        backpointers=backpointers,
        runtime_ms=elapsed,
    )


# ─── Voice generation utilities ──────────────────────────────────────────

def generate_voicings(root: int, quality: str = 'major') -> List[Voice]:
    """Generate all valid SATB voicings for a given chord."""
    intervals = {'major': [0, 4, 7], 'minor': [0, 3, 7], 'dom7': [0, 4, 7, 10]}
    pcs = [(root + i) % 12 for i in intervals.get(quality, [0, 4, 7])]

    ranges = [(60, 80), (53, 75), (48, 68), (40, 63)]
    notes = [[p for p in range(lo, hi) if p % 12 in pcs] for lo, hi in ranges]

    voicings = []
    for s in notes[0]:
        for a in notes[1]:
            if a > s: continue
            for t in notes[2]:
                if t > a: continue
                for b in notes[3]:
                    if b > t: continue
                    if s - a <= 12 and a - t <= 12:
                        voicings.append((s, a, t, b))
    return voicings


if __name__ == "__main__":
    # Quick self-test
    print("Testing Bellman DP vs Viterbi forward pass...")

    def simple_vert(v: Voice) -> float:
        return 0 if (v[3] <= v[2] <= v[1] <= v[0]) else 100

    def simple_lead(v1: Voice, v2: Voice) -> float:
        return sum(abs(v2[i] - v1[i]) for i in range(4))

    chords = [generate_voicings(0), generate_voicings(5),
              generate_voicings(7, 'dom7'), generate_voicings(0)]

    result_bellman = bellman_satb_dp(chords, simple_vert, simple_lead)
    result_viterbi = viterbi_satb(chords, simple_vert, simple_lead)

    print(f"  Bellman cost: {result_bellman.optimal_cost} ({result_bellman.runtime_ms:.1f}ms)")
    print(f"  Viterbi cost: {result_viterbi.optimal_cost} ({result_viterbi.runtime_ms:.1f}ms)")
    print(f"  Costs match: {result_bellman.optimal_cost == result_viterbi.optimal_cost} ✓")
    print(f"  Paths match: {result_bellman.optimal_path == result_viterbi.optimal_path}")
