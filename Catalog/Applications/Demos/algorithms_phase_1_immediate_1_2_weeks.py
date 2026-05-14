#!/usr/bin/env python3
"""
Algorithms for Voice-Leading Geometry

Implements the core algorithms from the research, with full docstrings,
type hints, and complexity analysis.

Algorithms:
1. Brute-force optimal matching (O(n! * n))
2. Sorted matching shortcut (O(n log n))
3. Chord graph construction and shortest path
4. Cost landscape enumeration
"""

from itertools import permutations
from typing import List, Tuple, Dict, Optional, Set
from collections import defaultdict
import heapq


# ═══════════════════════════════════════════════════════════════════════════════
# Algorithm 1: Brute-Force Optimal Voice-Leading Cost
# ═══════════════════════════════════════════════════════════════════════════════

def brute_force_vl_cost(x: List[int], y: List[int]) -> Tuple[int, List[int]]:
    """
    Compute the optimal voice-leading cost by brute-force enumeration
    of all n! permutations.

    Algorithm:
        For each permutation σ of {0, ..., n-1}:
            cost(σ) = Σᵢ |x[i] - y[σ(i)]|
        Return min over all σ.

    Complexity:
        Time:  O(n! · n)
        Space: O(n)

    Args:
        x: Source chord (list of n integer pitches)
        y: Target chord (list of n integer pitches)

    Returns:
        (optimal_cost, optimal_permutation)

    Example:
        >>> brute_force_vl_cost([48, 52, 55, 60], [53, 57, 60, 65])
        (20, [0, 1, 2, 3])
    """
    n = len(x)
    assert len(y) == n, "Chords must have same number of voices"

    best_cost = float('inf')
    best_perm = list(range(n))

    for perm in permutations(range(n)):
        cost = sum(abs(x[i] - y[perm[i]]) for i in range(n))
        if cost < best_cost:
            best_cost = cost
            best_perm = list(perm)

    return best_cost, best_perm


# ═══════════════════════════════════════════════════════════════════════════════
# Algorithm 2: Sorted Matching (Optimal for Monotone Chords)
# ═══════════════════════════════════════════════════════════════════════════════

def sorted_vl_cost(x: List[int], y: List[int]) -> Tuple[int, List[int]]:
    """
    Compute voice-leading cost using the sorted matching strategy.

    By the discrete Monge/rearrangement theorem (vlCost4_sorted_optimal),
    when both sequences are sorted, the identity matching is optimal.
    For general sequences, we sort both, compute the identity matching cost,
    and reconstruct the optimal permutation.

    Algorithm:
        1. Sort x to get x_sorted, recording the permutation π_x
        2. Sort y to get y_sorted, recording the permutation π_y
        3. The optimal cost is Σᵢ |x_sorted[i] - y_sorted[i]|
        4. The optimal permutation is π_y ∘ π_x⁻¹

    Complexity:
        Time:  O(n log n)
        Space: O(n)

    This is a massive improvement over O(n!) brute force.

    Args:
        x: Source chord
        y: Target chord

    Returns:
        (optimal_cost, optimal_permutation)

    Example:
        >>> sorted_vl_cost([60, 48, 55, 52], [65, 53, 60, 57])
        (20, [0, 1, 2, 3])
    """
    n = len(x)
    assert len(y) == n

    # Sort with index tracking
    x_indexed = sorted(enumerate(x), key=lambda p: p[1])
    y_indexed = sorted(enumerate(y), key=lambda p: p[1])

    # Compute cost on sorted sequences
    cost = sum(abs(x_indexed[i][1] - y_indexed[i][1]) for i in range(n))

    # Reconstruct permutation: voice x_indexed[i][0] maps to y_indexed[i][0]
    perm = [0] * n
    for i in range(n):
        perm[x_indexed[i][0]] = y_indexed[i][0]

    return cost, perm


# ═══════════════════════════════════════════════════════════════════════════════
# Algorithm 3: Chord Graph Construction
# ═══════════════════════════════════════════════════════════════════════════════

class ChordGraph:
    """
    A weighted graph on a finite corpus of chords, with edges weighted
    by voice-leading cost.

    The graph supports:
    - Shortest path computation (Dijkstra)
    - Diameter computation
    - Adjacency queries at various cost thresholds
    - Connected component analysis

    Complexity:
        Construction: O(|V|² · n!)  for brute-force, O(|V|² · n log n) for sorted
        Shortest path: O(|V|² log |V|) via Dijkstra
        Diameter: O(|V|³) via all-pairs shortest paths
    """

    def __init__(self, chords: Dict[str, List[int]], use_sorted: bool = True):
        """
        Build the chord graph from a dictionary of named chords.

        Args:
            chords: Map from chord name to pitch list
            use_sorted: Use O(n log n) sorted algorithm (True) or brute force (False)
        """
        self.chords = chords
        self.names = list(chords.keys())
        self.n = len(self.names)
        self.cost_fn = sorted_vl_cost if use_sorted else brute_force_vl_cost

        # Compute all pairwise costs
        self.costs: Dict[Tuple[str, str], int] = {}
        for n1 in self.names:
            for n2 in self.names:
                cost, _ = self.cost_fn(chords[n1], chords[n2])
                self.costs[(n1, n2)] = cost

    def get_cost(self, name1: str, name2: str) -> int:
        """Get the voice-leading cost between two named chords."""
        return self.costs[(name1, name2)]

    def adjacency(self, threshold: int) -> Dict[str, List[str]]:
        """
        Return adjacency lists for chords connected by cost ≤ threshold.
        """
        adj = defaultdict(list)
        for n1 in self.names:
            for n2 in self.names:
                if n1 != n2 and self.costs[(n1, n2)] <= threshold:
                    adj[n1].append(n2)
        return dict(adj)

    def shortest_path(self, start: str, end: str) -> Tuple[int, List[str]]:
        """
        Compute shortest path between two chords using Dijkstra's algorithm.

        Returns:
            (total_cost, path_as_list_of_chord_names)
        """
        dist = {name: float('inf') for name in self.names}
        prev = {name: None for name in self.names}
        dist[start] = 0
        pq = [(0, start)]

        while pq:
            d, u = heapq.heappop(pq)
            if d > dist[u]:
                continue
            for v in self.names:
                if v != u:
                    new_dist = d + self.costs[(u, v)]
                    if new_dist < dist[v]:
                        dist[v] = new_dist
                        prev[v] = u
                        heapq.heappush(pq, (new_dist, v))

        # Reconstruct path
        path = []
        current = end
        while current is not None:
            path.append(current)
            current = prev[current]
        path.reverse()

        return dist[end], path

    def diameter(self) -> Tuple[int, Tuple[str, str]]:
        """
        Compute the diameter of the chord graph (maximum shortest path distance).

        Returns:
            (diameter_value, (chord1, chord2) achieving it)
        """
        max_dist = 0
        max_pair = (self.names[0], self.names[0])

        for n1 in self.names:
            for n2 in self.names:
                d, _ = self.shortest_path(n1, n2)
                if d > max_dist:
                    max_dist = d
                    max_pair = (n1, n2)

        return max_dist, max_pair

    def cost_table(self) -> str:
        """Return a formatted cost table as a string."""
        header = f"{'':>10}" + "".join(f" {n:>8}" for n in self.names)
        rows = [header]
        for n1 in self.names:
            row = f"{n1:>10}" + "".join(
                f" {self.costs[(n1, n2)]:>8}" for n2 in self.names
            )
            rows.append(row)
        return "\n".join(rows)


# ═══════════════════════════════════════════════════════════════════════════════
# Algorithm 4: Cost Landscape Analysis
# ═══════════════════════════════════════════════════════════════════════════════

def cost_histogram(chords: Dict[str, List[int]]) -> Dict[int, int]:
    """
    Compute the histogram of pairwise voice-leading costs.

    Returns:
        Dictionary mapping cost value → number of chord pairs with that cost
    """
    hist = defaultdict(int)
    names = list(chords.keys())
    for i, n1 in enumerate(names):
        for j, n2 in enumerate(names):
            if i < j:
                cost, _ = sorted_vl_cost(chords[n1], chords[n2])
                hist[cost] += 1
    return dict(sorted(hist.items()))


def identify_symmetry_classes(chords: Dict[str, List[int]]) -> Dict[Tuple[int, ...], List[str]]:
    """
    Group chords by their cost profile (distance vector to all other chords).

    Chords in the same class have identical distance vectors (up to reordering),
    indicating they occupy equivalent positions in the cost geometry.

    Returns:
        Dictionary mapping sorted cost tuple → list of chord names
    """
    profiles = {}
    names = list(chords.keys())
    for n1 in names:
        dists = tuple(sorted(
            sorted_vl_cost(chords[n1], chords[n2])[0]
            for n2 in names if n2 != n1
        ))
        if dists not in profiles:
            profiles[dists] = []
        profiles[dists].append(n1)
    return profiles


# ═══════════════════════════════════════════════════════════════════════════════
# Example Usage
# ═══════════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Voice-Leading Geometry: Algorithm Demonstrations")
    print("=" * 60)

    # Define a corpus of common chord types
    corpus = {
        "C maj":   [48, 52, 55, 60],
        "C min":   [48, 51, 55, 60],
        "F maj":   [53, 57, 60, 65],
        "G dom7":  [55, 59, 62, 65],
        "A min":   [45, 48, 52, 57],
        "D min7":  [50, 53, 57, 62],
        "E maj":   [52, 56, 59, 64],
        "Bb maj":  [46, 50, 53, 58],
    }

    # Algorithm 1 vs 2: verify agreement
    print("\n--- Brute Force vs Sorted Matching ---")
    for n1 in list(corpus.keys())[:4]:
        for n2 in list(corpus.keys())[:4]:
            c1, _ = brute_force_vl_cost(corpus[n1], corpus[n2])
            c2, _ = sorted_vl_cost(corpus[n1], corpus[n2])
            status = "✓" if c1 == c2 else "✗ MISMATCH"
            if n1 != n2:
                print(f"  {n1:>8} → {n2:>8}: brute={c1}, sorted={c2} {status}")

    # Algorithm 3: Graph analysis
    print("\n--- Chord Graph Analysis ---")
    G = ChordGraph(corpus)
    print("\nCost Table:")
    print(G.cost_table())

    print("\nShortest path C maj → G dom7:")
    dist, path = G.shortest_path("C maj", "G dom7")
    print(f"  Distance: {dist}")
    print(f"  Path: {' → '.join(path)}")

    # Algorithm 4: Cost landscape
    print("\n--- Cost Histogram ---")
    hist = cost_histogram(corpus)
    for cost, count in hist.items():
        bar = "█" * count
        print(f"  cost {cost:>3}: {bar} ({count})")

    print("\n--- Symmetry Classes ---")
    classes = identify_symmetry_classes(corpus)
    for profile, members in classes.items():
        if len(members) > 1:
            print(f"  Equivalent: {members}")
