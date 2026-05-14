#!/usr/bin/env python3
"""
Algorithms for Mod-12 Pareto Voice Leading
===========================================

Implements:
1. Cyclic distance computation on Z/12Z
2. Optimal voice assignment (minimum-cost matching)
3. Pareto frontier enumeration for voice assignments
4. Normal-form reduction and orbit classification
5. Chord-class transition database

All algorithms operate on pitch-class space Z/12Z with cyclic distance.
"""

import itertools
from typing import List, Tuple, Dict, Set, FrozenSet, Optional
from dataclasses import dataclass
from collections import defaultdict


# ─────────────────────────────────────────────────────────────
# Algorithm 1: Cyclic Distance (O(1))
# ─────────────────────────────────────────────────────────────

def cyc_dist(a: int, b: int, n: int = 12) -> int:
    """
    Cyclic distance on Z/nZ.

    Time: O(1)
    Space: O(1)

    Args:
        a, b: pitch classes (integers mod n)
        n: modulus (default 12 for standard chromatic)

    Returns:
        Minimum arc length between a and b on the cycle Z/nZ
    """
    r = (a - b) % n
    return min(r, n - r)


# ─────────────────────────────────────────────────────────────
# Algorithm 2: Voice-Leading Cost (O(k))
# ─────────────────────────────────────────────────────────────

def voice_lead_cost(source: List[int], target: List[int], n: int = 12) -> int:
    """
    Total voice-leading cost between two configurations.

    Time: O(k) where k = number of voices
    Space: O(1)
    """
    return sum(cyc_dist(s, t, n) for s, t in zip(source, target))


# ─────────────────────────────────────────────────────────────
# Algorithm 3: Optimal Voice Assignment (O(k! · k))
# ─────────────────────────────────────────────────────────────

def all_assignments(k: int) -> List[Tuple[int, ...]]:
    """Generate all k! permutations of {0, ..., k-1}."""
    return list(itertools.permutations(range(k)))


def assignment_cost(source: List[int], target: List[int],
                    perm: Tuple[int, ...], n: int = 12) -> int:
    """Cost of a specific voice assignment."""
    return sum(cyc_dist(source[i], target[perm[i]], n) for i in range(len(source)))


def optimal_assignment(source: List[int], target: List[int],
                       n: int = 12) -> Tuple[Tuple[int, ...], int]:
    """
    Find the minimum-cost voice assignment.

    Time: O(k! · k) — exact for small k (3-4 voices)
    Space: O(k!)

    For k > 6, use Hungarian algorithm instead (O(k³)).

    Returns:
        (optimal_permutation, minimum_cost)
    """
    k = len(source)
    best_perm = None
    best_cost = float('inf')

    for perm in all_assignments(k):
        cost = assignment_cost(source, target, perm, n)
        if cost < best_cost:
            best_cost = cost
            best_perm = perm

    return best_perm, best_cost


# ─────────────────────────────────────────────────────────────
# Algorithm 4: Pareto Frontier of Voice Assignments (O(k!² · k))
# ─────────────────────────────────────────────────────────────

def assignment_dominates(source: List[int], target: List[int],
                         sigma: Tuple[int, ...], tau: Tuple[int, ...],
                         n: int = 12) -> bool:
    """
    Does assignment sigma Pareto-dominate tau?

    sigma dominates tau iff:
    - For all voices i: d(source[i], target[sigma[i]]) ≤ d(source[i], target[tau[i]])
    - For some voice j: d(source[j], target[sigma[j]]) < d(source[j], target[tau[j]])
    """
    k = len(source)
    weakly_better = all(
        cyc_dist(source[i], target[sigma[i]], n) <= cyc_dist(source[i], target[tau[i]], n)
        for i in range(k)
    )
    strictly_better = any(
        cyc_dist(source[i], target[sigma[i]], n) < cyc_dist(source[i], target[tau[i]], n)
        for i in range(k)
    )
    return weakly_better and strictly_better


def pareto_frontier(source: List[int], target: List[int],
                    n: int = 12) -> List[Tuple[Tuple[int, ...], int]]:
    """
    Compute the Pareto frontier of voice assignments.

    An assignment is Pareto-optimal if no other assignment dominates it.

    Time: O(k!² · k)
    Space: O(k!)

    Returns:
        List of (permutation, cost) pairs on the Pareto frontier
    """
    k = len(source)
    perms = all_assignments(k)

    frontier = []
    for tau in perms:
        is_dominated = False
        for sigma in perms:
            if sigma != tau and assignment_dominates(source, target, sigma, tau, n):
                is_dominated = True
                break
        if not is_dominated:
            cost = assignment_cost(source, target, tau, n)
            frontier.append((tau, cost))

    return frontier


# ─────────────────────────────────────────────────────────────
# Algorithm 5: Normal Form and Orbit Classification (O(k · n))
# ─────────────────────────────────────────────────────────────

def normalize(config: List[int], n: int = 12) -> Tuple[int, ...]:
    """
    Normalize a configuration by subtracting the first voice.

    This maps to the orbit representative under transposition.

    Time: O(k)
    Space: O(k)
    """
    offset = config[0]
    return tuple((c - offset) % n for c in config)


def canonical_form(config: List[int], n: int = 12) -> Tuple[int, ...]:
    """
    Canonical form: normalize by all possible transpositions,
    take lexicographically smallest.

    This is the unique representative of the transposition orbit.

    Time: O(k · n)
    Space: O(k)
    """
    k = len(config)
    best = None
    for t in range(n):
        shifted = tuple(sorted((c - t) % n for c in config))
        if best is None or shifted < best:
            best = shifted
    return best


def classify_chord(config: List[int], n: int = 12) -> str:
    """Classify a chord by its interval structure."""
    cf = canonical_form(config, n)
    intervals = tuple(cf[i+1] - cf[i] for i in range(len(cf)-1))
    remaining = n - cf[-1]
    intervals = intervals + (remaining,)

    # Known chord types for n=12, k=3
    # Use sorted interval multiset to handle all rotations
    interval_set = tuple(sorted(intervals))
    chord_names = {
        (3, 4, 5): "major/minor triad",
        (3, 3, 6): "diminished triad",
        (4, 4, 4): "augmented triad",
        (2, 5, 5): "sus2/sus4",
    }
    intervals = interval_set

    return chord_names.get(intervals, f"type-{intervals}")


# ─────────────────────────────────────────────────────────────
# Algorithm 6: Chord-Class Transition Database
# ─────────────────────────────────────────────────────────────

@dataclass
class TransitionRecord:
    """Record of a chord-class transition with Pareto analysis."""
    source_class: str
    target_class: str
    source_canonical: Tuple[int, ...]
    target_canonical: Tuple[int, ...]
    optimal_cost: int
    pareto_frontier_size: int
    all_costs_on_frontier: List[int]


def build_triad_database(n: int = 12) -> List[TransitionRecord]:
    """
    Build a database of all triad-to-triad transitions with Pareto analysis.

    Enumerates canonical representatives of major and minor triads,
    computes optimal voice assignments and Pareto frontiers.

    Time: O(T² · k!² · k) where T = number of distinct triad classes
    Space: O(T²)
    """
    # Generate all major and minor triads (canonical reps)
    triads = []
    for root in range(n):
        major = sorted([(root + i) % n for i in [0, 4, 7]])
        minor = sorted([(root + i) % n for i in [0, 3, 7]])
        triads.append(major)
        triads.append(minor)

    # Deduplicate by canonical form
    seen = set()
    unique_triads = []
    for t in triads:
        cf = canonical_form(t, n)
        if cf not in seen:
            seen.add(cf)
            unique_triads.append(t)

    records = []
    for source in unique_triads:
        for target in unique_triads:
            frontier = pareto_frontier(source, target, n)
            _, opt_cost = optimal_assignment(source, target, n)
            frontier_costs = sorted(set(cost for _, cost in frontier))

            records.append(TransitionRecord(
                source_class=classify_chord(source, n),
                target_class=classify_chord(target, n),
                source_canonical=canonical_form(source, n),
                target_canonical=canonical_form(target, n),
                optimal_cost=opt_cost,
                pareto_frontier_size=len(frontier),
                all_costs_on_frontier=frontier_costs,
            ))

    return records


# ─────────────────────────────────────────────────────────────
# Main: Run all algorithms with examples
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 60)

    # Example chords
    C_major = [0, 4, 7]   # C E G
    C_minor = [0, 3, 7]   # C Eb G
    G_major = [7, 11, 2]  # G B D
    F_minor = [5, 8, 0]   # F Ab C

    NOTE = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']

    def chord_str(c):
        return '[' + ', '.join(NOTE[x%12] for x in c) + ']'

    # Algorithm 1-2: Distances
    print("\n--- Cyclic Distances ---")
    for a, b in [(0,4), (0,7), (4,7), (0,6)]:
        print(f"  d({NOTE[a]}, {NOTE[b]}) = {cyc_dist(a, b)}")

    # Algorithm 3: Optimal assignment
    print("\n--- Optimal Voice Assignments ---")
    pairs = [(C_major, G_major), (C_major, C_minor), (C_major, F_minor)]
    for s, t in pairs:
        perm, cost = optimal_assignment(s, t)
        print(f"  {chord_str(s)} → {chord_str(t)}")
        print(f"    Optimal assignment: {perm}, cost = {cost}")

    # Algorithm 4: Pareto frontier
    print("\n--- Pareto Frontiers ---")
    for s, t in pairs:
        frontier = pareto_frontier(s, t)
        print(f"  {chord_str(s)} → {chord_str(t)}")
        print(f"    Frontier size: {len(frontier)}")
        for perm, cost in sorted(frontier, key=lambda x: x[1]):
            voices = [f"{NOTE[s[i]]}→{NOTE[t[perm[i]]%12]}" for i in range(3)]
            print(f"      σ={perm} cost={cost}: {', '.join(voices)}")

    # Algorithm 5: Classification
    print("\n--- Chord Classification ---")
    chords = [C_major, C_minor, [0,4,8], [0,3,6], [2,7,11]]
    for c in chords:
        print(f"  {chord_str(c)}: {classify_chord(c)}, canonical={canonical_form(c)}")

    # Algorithm 6: Transition database (subset)
    print("\n--- Triad Transition Database (sample) ---")
    records = build_triad_database()
    # Show a few representative transitions
    shown = set()
    for r in records[:20]:
        key = (r.source_class, r.target_class)
        if key not in shown:
            shown.add(key)
            print(f"  {r.source_class} → {r.target_class}: "
                  f"opt_cost={r.optimal_cost}, "
                  f"frontier_size={r.pareto_frontier_size}, "
                  f"frontier_costs={r.all_costs_on_frontier}")

    print(f"\n  Total transitions in database: {len(records)}")
    print(f"  Unique transition types: {len(set((r.source_class, r.target_class) for r in records))}")
