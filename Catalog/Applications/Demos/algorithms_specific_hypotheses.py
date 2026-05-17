#!/usr/bin/env python3
"""
Tropical Hypergraph Counterpoint: Algorithms

Implements:
1. Tropical penalty evaluation (O(1) per pair, O(k²) per transition)
2. Bellman-Ford shortest path on the SATB hypergraph
3. Viterbi-style optimal harmonization via dynamic programming
4. Pairwise factorized search (exploiting Theorem 3)

All algorithms include docstrings, type hints, and complexity analysis.
"""

import numpy as np
from typing import List, Tuple, Optional, Dict, Set
from itertools import product
from collections import defaultdict

# ============================================================
# Type Aliases
# ============================================================

Chord = Tuple[int, ...]  # (S, A, T, B) as MIDI pitch numbers
Progression = List[Chord]

VOICE_PAIRS = [(i, j) for i in range(4) for j in range(i+1, 4)]


# ============================================================
# Algorithm 1: Tropical Penalty Evaluation
# ============================================================

def interval(a: int, b: int) -> int:
    """Signed interval: b - a."""
    return b - a


def no_parallel_fifths(i: int, j: int, v: Chord, w: Chord) -> bool:
    return interval(v[i], v[j]) != 7 or interval(w[i], w[j]) != 7


def no_crossing(i: int, j: int, w: Chord) -> bool:
    return i >= j or w[j] <= w[i]


def spacing_ok(i: int, j: int, w: Chord) -> bool:
    return not (i + 1 == j and i < 3) or w[i] - w[j] <= 12


def pair_penalty(i: int, j: int, v: Chord, w: Chord) -> float:
    """
    Tropical pairwise penalty for voice pair (i, j).

    Returns max(fifths_penalty, max(crossing_penalty, spacing_penalty)).
    Each component is 0 if the constraint is satisfied, 1 otherwise.

    Time complexity: O(1)
    Space complexity: O(1)
    """
    p_fifth = 0.0 if no_parallel_fifths(i, j, v, w) else 1.0
    p_cross = 0.0 if no_crossing(i, j, w) else 1.0
    p_space = 0.0 if spacing_ok(i, j, w) else 1.0
    return max(p_fifth, max(p_cross, p_space))


def total_penalty(v: Chord, w: Chord) -> float:
    """
    Total SATB transition penalty: sum over 6 voice pairs.

    Time complexity: O(k²) where k = number of voices (k=4, so O(1))
    Space complexity: O(1)
    """
    return sum(pair_penalty(i, j, v, w) for i, j in VOICE_PAIRS)


def progression_cost(prog: Progression) -> float:
    """
    Total cost of an SATB progression.

    Time complexity: O(n · k²) where n = number of transitions
    Space complexity: O(1)
    """
    return sum(total_penalty(prog[k], prog[k+1]) for k in range(len(prog) - 1))


def is_legal_step(v: Chord, w: Chord) -> bool:
    """Check legality via zero-locus (Theorem 1)."""
    return total_penalty(v, w) == 0.0


def is_legal_progression(prog: Progression) -> bool:
    """Check legality via zero-cost (Theorem 2)."""
    return progression_cost(prog) == 0.0


# ============================================================
# Algorithm 2: Bellman-Ford Shortest Path on SATB Hypergraph
# ============================================================

def bellman_ford_satb(
    pitch_set: List[int],
    source: Chord,
    target: Chord,
    n_steps: int
) -> Tuple[float, Optional[Progression]]:
    """
    Find the minimum-cost progression from source to target in n_steps.

    Uses Bellman-Ford dynamic programming on the SATB chord graph.
    By Theorem 2, if a legal path exists, it has cost 0 and is optimal.

    Args:
        pitch_set: Available pitches for each voice
        source: Starting chord
        target: Ending chord
        n_steps: Number of transitions (progression length = n_steps + 1)

    Returns:
        (min_cost, optimal_progression) or (inf, None) if no path exists

    Time complexity: O(n · |P|^8) where |P| = len(pitch_set)
    Space complexity: O(|P|^4)

    Pseudocode:
        1. Initialize: dist[0][source] = 0, dist[0][v] = ∞ for v ≠ source
        2. For step k = 1, ..., n_steps:
             For each chord w in P^4:
               dist[k][w] = min over v of (dist[k-1][v] + totalPenalty6(v, w))
               pred[k][w] = argmin v
        3. Return dist[n_steps][target] and reconstruct path via pred
    """
    # Generate all chords
    all_chords = list(product(pitch_set, repeat=4))

    # DP tables
    INF = float('inf')
    dist_prev: Dict[Chord, float] = defaultdict(lambda: INF)
    dist_prev[source] = 0.0
    pred: List[Dict[Chord, Optional[Chord]]] = [{}]

    for step in range(n_steps):
        dist_curr: Dict[Chord, float] = defaultdict(lambda: INF)
        pred_step: Dict[Chord, Optional[Chord]] = {}

        for w in all_chords:
            best_cost = INF
            best_pred = None
            for v in all_chords:
                if dist_prev[v] < INF:
                    cost = dist_prev[v] + total_penalty(v, w)
                    if cost < best_cost:
                        best_cost = cost
                        best_pred = v
            dist_curr[w] = best_cost
            pred_step[w] = best_pred

        dist_prev = dist_curr
        pred.append(pred_step)

    # Reconstruct path
    if dist_prev[target] == INF:
        return INF, None

    path = [target]
    current = target
    for step in range(n_steps, 0, -1):
        current = pred[step][current]
        path.append(current)
    path.reverse()

    return dist_prev[target], path


# ============================================================
# Algorithm 3: Viterbi-Style Optimal Harmonization
# ============================================================

def viterbi_harmonize(
    pitch_set: List[int],
    soprano_melody: List[int],
    n_steps: int
) -> Tuple[float, Optional[Progression]]:
    """
    Find the minimum-cost SATB harmonization of a given soprano melody.

    Constrains the soprano voice and optimizes over alto, tenor, bass.
    Uses Viterbi-style DP exploiting the factorized cost structure.

    Args:
        pitch_set: Available pitches for inner voices
        soprano_melody: Fixed soprano pitches (length = n_steps + 1)
        n_steps: Number of transitions

    Returns:
        (min_cost, optimal_progression)

    Time complexity: O(n · |P|^6)  — reduced from O(n · |P|^8) by fixing soprano
    Space complexity: O(|P|^3)
    """
    INF = float('inf')
    inner_chords = list(product(pitch_set, repeat=3))

    def make_chord(soprano: int, inner: Tuple[int, int, int]) -> Chord:
        return (soprano,) + inner

    # Initialize
    dist_prev: Dict[Tuple, float] = {}
    for inner in inner_chords:
        chord = make_chord(soprano_melody[0], inner)
        dist_prev[inner] = 0.0  # No cost at first step

    pred: List[Dict[Tuple, Optional[Tuple]]] = [{}]

    for step in range(n_steps):
        dist_curr: Dict[Tuple, float] = {}
        pred_step: Dict[Tuple, Optional[Tuple]] = {}

        for w_inner in inner_chords:
            w = make_chord(soprano_melody[step + 1], w_inner)
            best_cost = INF
            best_pred = None

            for v_inner in inner_chords:
                if v_inner in dist_prev and dist_prev[v_inner] < INF:
                    v = make_chord(soprano_melody[step], v_inner)
                    cost = dist_prev[v_inner] + total_penalty(v, w)
                    if cost < best_cost:
                        best_cost = cost
                        best_pred = v_inner

            dist_curr[w_inner] = best_cost
            pred_step[w_inner] = best_pred

        dist_prev = dist_curr
        pred.append(pred_step)

    # Find best ending
    best_end = None
    best_cost = INF
    for inner, cost in dist_prev.items():
        if cost < best_cost:
            best_cost = cost
            best_end = inner

    if best_end is None:
        return INF, None

    # Reconstruct
    path_inner = [best_end]
    current = best_end
    for step in range(n_steps, 0, -1):
        current = pred[step][current]
        path_inner.append(current)
    path_inner.reverse()

    progression = [make_chord(soprano_melody[k], path_inner[k])
                   for k in range(n_steps + 1)]

    return best_cost, progression


# ============================================================
# Algorithm 4: Pairwise Factorized Legal Path Search
# ============================================================

def factorized_legal_search(
    pitch_set: List[int],
    source: Chord,
    target: Chord,
    n_steps: int
) -> Optional[Progression]:
    """
    Search for a legal SATB progression exploiting pairwise factorization.

    By Theorem 3, a progression is legal iff EVERY voice pair is pairwise
    legal at EVERY step. This allows early pruning: if any pair is violated,
    the entire progression is illegal.

    This implements a depth-first search with pairwise constraint propagation.

    Args:
        pitch_set: Available pitches
        source: Starting chord
        target: Ending chord
        n_steps: Number of transitions

    Returns:
        A legal progression if one exists, None otherwise

    Time complexity: O(|P|^4 · n) in best case with heavy pruning
    Space complexity: O(n · |P|^4)
    """
    all_chords = list(product(pitch_set, repeat=4))

    def search(step: int, current: Chord, path: List[Chord]) -> Optional[Progression]:
        if step == n_steps:
            if current == target:
                return path
            return None

        for next_chord in all_chords:
            # Exploit pairwise factorization: check pairs incrementally
            legal = True
            for i, j in VOICE_PAIRS:
                if pair_penalty(i, j, current, next_chord) > 0:
                    legal = False
                    break  # Early exit — no need to check remaining pairs

            if legal:
                result = search(step + 1, next_chord, path + [next_chord])
                if result is not None:
                    return result

        return None

    return search(0, source, [source])


# ============================================================
# Algorithm 5: Tropical Cost Matrix Computation
# ============================================================

def compute_cost_matrix(pitch_set: List[int]) -> np.ndarray:
    """
    Compute the full tropical cost matrix for all chord-to-chord transitions.

    This is the adjacency matrix of the SATB hypergraph, where entry (i,j)
    is totalPenalty6(chord_i, chord_j).

    Time complexity: O(|P|^8 · k²)
    Space complexity: O(|P|^8)

    Returns:
        cost_matrix: np.ndarray of shape (|P|^4, |P|^4)
    """
    chords = list(product(pitch_set, repeat=4))
    n = len(chords)
    matrix = np.zeros((n, n))

    for i, v in enumerate(chords):
        for j, w in enumerate(chords):
            matrix[i, j] = total_penalty(v, w)

    return matrix


# ============================================================
# Demonstration
# ============================================================

if __name__ == "__main__":
    print("Tropical SATB Algorithms — Demonstration")
    print("=" * 60)

    # Small pitch set for tractability
    pitches = [48, 52, 55, 60, 64, 67]  # C3, E3, G3, C4, E4, G4

    # Demo: Bellman-Ford
    source = (64, 60, 55, 48)  # C major
    target = (67, 60, 55, 48)  # Another voicing

    print("\n--- Bellman-Ford Shortest Path (2 steps) ---")
    cost, path = bellman_ford_satb(pitches, source, target, 2)
    print(f"  Source: {source}")
    print(f"  Target: {target}")
    print(f"  Min cost: {cost}")
    if path:
        for k, c in enumerate(path):
            print(f"  Step {k}: {c}")
        print(f"  Legal? {is_legal_progression(path)}")

    # Demo: Viterbi harmonization
    soprano = [64, 65, 67, 65, 64]
    print(f"\n--- Viterbi Harmonization ---")
    print(f"  Soprano melody: {soprano}")
    cost, harm = viterbi_harmonize(pitches, soprano, len(soprano) - 1)
    print(f"  Min cost: {cost}")
    if harm:
        for k, c in enumerate(harm):
            print(f"  Step {k}: {c}")

    # Demo: Cost matrix statistics
    small_pitches = [48, 55, 60, 64]
    print(f"\n--- Cost Matrix Statistics (pitches={small_pitches}) ---")
    matrix = compute_cost_matrix(small_pitches)
    n_chords = len(list(product(small_pitches, repeat=4)))
    n_zero = np.sum(matrix == 0)
    print(f"  Number of chords: {n_chords}")
    print(f"  Matrix size: {matrix.shape}")
    print(f"  Zero entries (legal transitions): {n_zero} ({100*n_zero/matrix.size:.1f}%)")
    print(f"  Max penalty: {matrix.max()}")
    print(f"  Mean penalty: {matrix.mean():.2f}")
