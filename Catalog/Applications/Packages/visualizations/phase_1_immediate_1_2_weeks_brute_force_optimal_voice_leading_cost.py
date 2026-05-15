#!/usr/bin/env python3
"""
algorithms.py — Voice-Leading Cost Algorithms

Implements:
1. Brute-force optimal voice-leading cost via permutation enumeration
2. Sorted matching algorithm (O(n log n) via sort)
3. Chord corpus enumeration and cost landscape computation
4. Graph-theoretic analysis of chord transition spaces
"""

import itertools
from typing import List, Tuple, Dict, Set, Optional
from collections import defaultdict


# ──────────────────────────────────────────────────────────────────────
# Algorithm 1: Brute-Force Optimal Voice-Leading Cost
# ──────────────────────────────────────────────────────────────────────

def brute_force_vl_cost(x: List[int], y: List[int]) -> Tuple[int, Tuple[int, ...]]:
    """
    Compute optimal voice-leading cost by enumerating all n! permutations.

    Time complexity: O(n! · n)
    Space complexity: O(n)

    Args:
        x: Source chord (list of n integer pitches)
        y: Target chord (list of n integer pitches)

    Returns:
        (optimal_cost, optimal_permutation)
    """
    n = len(x)
    assert len(y) == n, "Chords must have same number of voices"

    best_cost = float('inf')
    best_perm = None

    for sigma in itertools.permutations(range(n)):
        cost = sum(abs(x[i] - y[sigma[i]]) for i in range(n))
        if cost < best_cost:
            best_cost = cost
            best_perm = sigma

    return int(best_cost), best_perm


# ──────────────────────────────────────────────────────────────────────
# Algorithm 2: Sorted Matching (Monge-Optimal for 1D)
# ──────────────────────────────────────────────────────────────────────

def sorted_matching_cost(x: List[int], y: List[int]) -> int:
    """
    Compute voice-leading cost via sorted matching.

    By the Monge/rearrangement theorem (vlCost4_sorted_optimal),
    the optimal matching for 1D pitches is obtained by sorting both
    chords and matching corresponding entries.

    Time complexity: O(n log n)
    Space complexity: O(n)

    Args:
        x: Source chord
        y: Target chord

    Returns:
        Optimal voice-leading cost
    """
    xs = sorted(x)
    ys = sorted(y)
    return sum(abs(xs[i] - ys[i]) for i in range(len(xs)))


# ──────────────────────────────────────────────────────────────────────
# Algorithm 3: Chord Corpus and Cost Landscape
# ──────────────────────────────────────────────────────────────────────

# Chord templates as pitch-class sets (semitones above root)
CHORD_TYPES = {
    "major":       [0, 4, 7],
    "minor":       [0, 3, 7],
    "dim":         [0, 3, 6],
    "aug":         [0, 4, 8],
    "dom7":        [0, 4, 7, 10],
    "maj7":        [0, 4, 7, 11],
    "min7":        [0, 3, 7, 10],
    "dim7":        [0, 3, 6, 9],
    "hdim7":       [0, 3, 6, 10],  # half-diminished
}


def generate_chord_corpus(
    base_pitch: int = 48,
    chord_types: Optional[Dict[str, List[int]]] = None,
    roots: Optional[List[int]] = None,
) -> Dict[str, List[int]]:
    """
    Generate a corpus of concrete 4-voice chords.

    For triads, doubles the root an octave higher.
    For seventh chords, uses all four notes.

    Args:
        base_pitch: Starting MIDI pitch for root position
        chord_types: Dict of chord type name -> interval list
        roots: List of root pitch classes (0-11)

    Returns:
        Dict of chord name -> list of 4 MIDI pitches (sorted)
    """
    if chord_types is None:
        chord_types = CHORD_TYPES
    if roots is None:
        roots = list(range(12))

    corpus = {}
    for root in roots:
        for ctype, intervals in chord_types.items():
            pitches = [base_pitch + root + iv for iv in intervals]
            if len(pitches) == 3:
                # Double the root an octave up for 4 voices
                pitches.append(base_pitch + root + 12)
            pitches = sorted(pitches)
            name = f"{root}_{ctype}"
            corpus[name] = pitches

    return corpus


def compute_cost_landscape(corpus: Dict[str, List[int]]) -> Dict[Tuple[str, str], int]:
    """
    Compute all pairwise voice-leading costs in a chord corpus.

    Time complexity: O(|corpus|² · n!)

    Returns:
        Dict mapping (chord_name_1, chord_name_2) -> cost
    """
    costs = {}
    names = list(corpus.keys())
    for i, n1 in enumerate(names):
        for j, n2 in enumerate(names):
            costs[(n1, n2)] = sorted_matching_cost(corpus[n1], corpus[n2])
    return costs


# ──────────────────────────────────────────────────────────────────────
# Algorithm 4: Chord Transition Graph Analysis
# ──────────────────────────────────────────────────────────────────────

class ChordGraph:
    """
    Weighted graph on chord space where edge weights are voice-leading costs.

    Supports:
    - BFS for shortest path (unweighted)
    - Dijkstra for shortest path (weighted)
    - Connectivity analysis
    - Diameter computation
    """

    def __init__(self, corpus: Dict[str, List[int]], max_cost: Optional[int] = None):
        self.corpus = corpus
        self.names = list(corpus.keys())
        self.n = len(self.names)
        self.costs = compute_cost_landscape(corpus)

        # Build adjacency with optional cost threshold
        self.adj: Dict[str, List[Tuple[str, int]]] = defaultdict(list)
        for (n1, n2), cost in self.costs.items():
            if n1 != n2 and (max_cost is None or cost <= max_cost):
                self.adj[n1].append((n2, cost))

    def is_connected(self) -> bool:
        """Check if the graph is connected via BFS."""
        if not self.names:
            return True
        visited = set()
        queue = [self.names[0]]
        visited.add(self.names[0])
        while queue:
            current = queue.pop(0)
            for neighbor, _ in self.adj[current]:
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append(neighbor)
        return len(visited) == self.n

    def dijkstra(self, source: str) -> Dict[str, int]:
        """Shortest path distances from source using Dijkstra's algorithm."""
        import heapq
        dist = {name: float('inf') for name in self.names}
        dist[source] = 0
        pq = [(0, source)]

        while pq:
            d, u = heapq.heappop(pq)
            if d > dist[u]:
                continue
            for v, w in self.adj[u]:
                if dist[u] + w < dist[v]:
                    dist[v] = dist[u] + w
                    heapq.heappush(pq, (dist[v], v))

        return dist

    def diameter(self) -> int:
        """Compute the diameter of the graph (max shortest path distance)."""
        max_dist = 0
        for name in self.names:
            dists = self.dijkstra(name)
            for d in dists.values():
                if d != float('inf') and d > max_dist:
                    max_dist = d
        return max_dist

    def cost_distribution(self) -> Dict[int, int]:
        """Distribution of edge costs."""
        dist = defaultdict(int)
        for (n1, n2), cost in self.costs.items():
            if n1 != n2:
                dist[cost] += 1
        return dict(sorted(dist.items()))

    def zero_cost_classes(self) -> List[Set[str]]:
        """Find equivalence classes of chords with zero mutual cost."""
        classes = []
        visited = set()
        for name in self.names:
            if name in visited:
                continue
            cls = {name}
            queue = [name]
            while queue:
                current = queue.pop(0)
                for other in self.names:
                    if other not in cls and self.costs.get((current, other), float('inf')) == 0:
                        cls.add(other)
                        queue.append(other)
            visited.update(cls)
            classes.append(cls)
        return classes


def verify_brute_vs_sorted(n_tests: int = 100, n_voices: int = 4) -> bool:
    """
    Verify that sorted matching gives the same result as brute force.

    This is an empirical verification of vlCost4_sorted_optimal.
    """
    import random
    random.seed(42)

    for _ in range(n_tests):
        x = sorted(random.choices(range(30, 80), k=n_voices))
        y = sorted(random.choices(range(30, 80), k=n_voices))

        brute_cost, _ = brute_force_vl_cost(x, y)
        sorted_cost = sorted_matching_cost(x, y)

        if brute_cost != sorted_cost:
            print(f"MISMATCH: x={x}, y={y}, brute={brute_cost}, sorted={sorted_cost}")
            return False

    return True


# ──────────────────────────────────────────────────────────────────────
# Main: Run all algorithms and display results
# ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 70)
    print("Voice-Leading Cost Algorithms")
    print("=" * 70)
    print()

    # Test brute force vs sorted
    print("Verifying brute-force vs sorted matching (100 random tests)...")
    result = verify_brute_vs_sorted()
    print(f"  All tests passed: {result}")
    print()

    # Build corpus and analyze
    print("Building chord corpus (C major key, common chord types)...")
    # Use just C major key chords for readable output
    corpus = generate_chord_corpus(
        base_pitch=48,
        roots=[0, 2, 4, 5, 7, 9, 11],  # C D E F G A B
        chord_types={"major": [0, 4, 7], "minor": [0, 3, 7], "dom7": [0, 4, 7, 10]}
    )
    print(f"  Corpus size: {len(corpus)} chords")
    print()

    # Cost landscape
    costs = compute_cost_landscape(corpus)
    nonzero = [c for c in costs.values() if c > 0]
    print(f"  Min nonzero cost: {min(nonzero)}")
    print(f"  Max cost: {max(nonzero)}")
    print(f"  Mean cost: {sum(nonzero)/len(nonzero):.1f}")
    print()

    # Graph analysis
    print("Graph analysis (full graph, no cost threshold)...")
    graph = ChordGraph(corpus)
    print(f"  Connected: {graph.is_connected()}")
    print(f"  Diameter: {graph.diameter()}")
    print()

    # Cost distribution
    dist = graph.cost_distribution()
    print("  Cost distribution:")
    for cost, count in list(dist.items())[:15]:
        print(f"    cost={cost}: {count} pairs")
    print()

    # Zero-cost classes
    classes = graph.zero_cost_classes()
    print(f"  Zero-cost equivalence classes: {len(classes)}")
    for i, cls in enumerate(classes[:5]):
        if len(cls) > 1:
            print(f"    Class {i}: {cls}")

    print()
    print("=" * 70)
    print("All algorithms completed successfully.")
    print("=" * 70)
