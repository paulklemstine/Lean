#!/usr/bin/env python3
"""
algorithms.py — Certified Voice-Leading Algorithms

Implements the sorting-based voice-leading metric and related algorithms,
with full type hints and docstrings. These algorithms are backed by
formally verified correctness proofs.
"""

from typing import List, Tuple, Optional
import heapq
import itertools


def voice_leading_cost(source: List[int], target: List[int]) -> int:
    """
    Compute the optimal voice-leading cost between two chords.

    Given two collections of pitches (as integers, e.g. MIDI numbers),
    finds the minimum total absolute pitch displacement across all
    possible voice assignments.

    This is equivalent to the discrete Wasserstein-1 distance between
    the two empirical measures.

    Formally verified to be correct:
        vlCostN_compute_correct : vlCostN_compute x y = vlCostN x y

    Time complexity: O(n log n) — dominated by sorting.
    Space complexity: O(n)

    Args:
        source: List of integer pitches (source chord)
        target: List of integer pitches (target chord)

    Returns:
        The minimum voice-leading cost (non-negative integer)

    Raises:
        ValueError: If source and target have different lengths
    """
    if len(source) != len(target):
        raise ValueError(f"Chords must have same size: {len(source)} ≠ {len(target)}")

    sorted_source = sorted(source)
    sorted_target = sorted(target)
    return sum(abs(a - b) for a, b in zip(sorted_source, sorted_target))


def optimal_voice_assignment(source: List[int], target: List[int]) -> List[int]:
    """
    Compute the optimal voice assignment (permutation) between two chords.

    Returns a permutation σ such that voice i in the source chord is
    assigned to voice σ[i] in the target chord, minimizing total displacement.

    The algorithm works by sorting both chords and matching sorted positions:
    the k-th lowest source pitch is assigned to the k-th lowest target pitch.

    Time complexity: O(n log n)

    Args:
        source: List of integer pitches
        target: List of integer pitches

    Returns:
        A permutation as a list of indices into the target chord
    """
    if len(source) != len(target):
        raise ValueError(f"Chords must have same size: {len(source)} ≠ {len(target)}")

    n = len(source)

    # Get sorting permutations
    source_order = sorted(range(n), key=lambda i: (source[i], i))
    target_order = sorted(range(n), key=lambda i: (target[i], i))

    # Build the optimal assignment: match sorted positions
    assignment = [0] * n
    for rank in range(n):
        assignment[source_order[rank]] = target_order[rank]

    return assignment


def voice_leading_path(
    source: List[int],
    target: List[int],
    steps: int = 10
) -> List[List[float]]:
    """
    Compute a linear interpolation path between two chords under
    optimal voice leading.

    Each intermediate chord is a weighted average of the source and target
    pitches under the optimal voice assignment.

    Args:
        source: Starting chord
        target: Ending chord
        steps: Number of interpolation steps (including endpoints)

    Returns:
        List of chords (as lists of floats) along the path
    """
    assignment = optimal_voice_assignment(source, target)
    path = []
    for step in range(steps):
        t = step / (steps - 1) if steps > 1 else 0
        chord = [source[i] * (1 - t) + target[assignment[i]] * t
                 for i in range(len(source))]
        path.append(chord)
    return path


def chord_distance_matrix(chords: List[List[int]]) -> List[List[int]]:
    """
    Compute the pairwise voice-leading distance matrix for a set of chords.

    Args:
        chords: List of chords (each a list of integer pitches)

    Returns:
        Symmetric distance matrix as a list of lists
    """
    n = len(chords)
    matrix = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in range(i + 1, n):
            d = voice_leading_cost(chords[i], chords[j])
            matrix[i][j] = d
            matrix[j][i] = d
    return matrix


def shortest_chord_progression(
    chords: List[List[int]],
    start: int,
    end: int
) -> Tuple[int, List[int]]:
    """
    Find the shortest progression (by total voice-leading cost) between
    two chords through a set of intermediate chords.

    Uses Dijkstra's algorithm on the voice-leading distance graph.

    Args:
        chords: Available chords
        start: Index of starting chord
        end: Index of ending chord

    Returns:
        (total_cost, path) where path is a list of chord indices
    """
    n = len(chords)
    dist = [float('inf')] * n
    prev = [-1] * n
    dist[start] = 0

    heap = [(0, start)]

    while heap:
        d, u = heapq.heappop(heap)
        if d > dist[u]:
            continue
        if u == end:
            break
        for v in range(n):
            if v == u:
                continue
            w = voice_leading_cost(chords[u], chords[v])
            if dist[u] + w < dist[v]:
                dist[v] = dist[u] + w
                prev[v] = u
                heapq.heappush(heap, (dist[v], v))

    # Reconstruct path
    path = []
    node = end
    while node != -1:
        path.append(node)
        node = prev[node]
    path.reverse()

    return dist[end], path


def canonical_representative(chord: List[int]) -> Tuple[int, ...]:
    """
    Compute the canonical (sorted) representative of a chord's
    permutation orbit.

    Two chords have the same canonical representative if and only if
    one is a permutation of the other. Formally verified:

        sortChord_eq_iff_same_orbit :
            sortChord x = sortChord y ↔ ∃ σ, ∀ i, x i = y (σ i)

    Args:
        chord: A chord as a list of integer pitches

    Returns:
        The sorted tuple (canonical form)
    """
    return tuple(sorted(chord))


# ═══════════════════════════════════════════════════════════
# Example usage
# ═══════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Voice-Leading Algorithms — Example Usage")
    print("=" * 50)

    # Common chords (MIDI numbers)
    C_major = [60, 64, 67]   # C4 E4 G4
    F_major = [65, 69, 60]   # F4 A4 C4 (different voicing)
    G_major = [55, 59, 62]   # G3 B3 D4
    Am = [57, 60, 64]        # A3 C4 E4

    print("\n1. Voice-leading costs:")
    print(f"   C → F: {voice_leading_cost(C_major, F_major)}")
    print(f"   C → G: {voice_leading_cost(C_major, G_major)}")
    print(f"   C → Am: {voice_leading_cost(C_major, Am)}")

    print("\n2. Optimal voice assignment (C → F):")
    assignment = optimal_voice_assignment(C_major, F_major)
    for i, j in enumerate(assignment):
        print(f"   Voice {i} ({C_major[i]}) → Voice {j} ({F_major[j]}), "
              f"displacement = {abs(C_major[i] - F_major[j])}")

    print("\n3. Canonical representatives:")
    voicings = [[67, 60, 64], [60, 67, 64], [64, 60, 67]]
    for v in voicings:
        print(f"   {v} → {canonical_representative(v)}")

    print("\n4. Shortest progression C → Am through available chords:")
    chords = [C_major, F_major, G_major, Am]
    names = ["C", "F", "G", "Am"]
    cost, path = shortest_chord_progression(chords, 0, 3)
    path_str = " → ".join(names[i] for i in path)
    print(f"   Path: {path_str}")
    print(f"   Total cost: {cost}")

    print("\n5. Distance matrix:")
    matrix = chord_distance_matrix(chords)
    print("       " + "  ".join(f"{n:>4s}" for n in names))
    for i, row in enumerate(matrix):
        print(f"   {names[i]:>3s}  " + "  ".join(f"{d:4d}" for d in row))
