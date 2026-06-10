#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for Tropical Morse Theory on graphs.

Implements:
  1. Kruskal-based tropical Morse spectrum computation (O(E log E))
  2. Persistent homology barcode extraction
  3. 1-WL color refinement (O(V·E) per iteration, O(V²·E) total)
  4. Bottleneck distance between spectra
  5. Tropical Morse complexity computation
  6. Feature vector construction for GNNs
"""

from collections import Counter, defaultdict
from typing import List, Tuple, Dict, Set, Optional
import heapq


# ──────────────────────────────────────────────────────────────
# Union-Find (Disjoint Set Union)
# ──────────────────────────────────────────────────────────────

class UnionFind:
    """Union-Find with path compression and union by rank.

    Time complexity:
        - find: O(α(n)) amortized
        - union: O(α(n)) amortized
        where α is the inverse Ackermann function (≤ 4 for practical inputs).
    """

    def __init__(self, n: int):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.num_components = n
        self.component_size = [1] * n

    def find(self, x: int) -> int:
        """Find with path compression."""
        root = x
        while self.parent[root] != root:
            root = self.parent[root]
        while self.parent[x] != root:
            self.parent[x], x = root, self.parent[x]
        return root

    def union(self, x: int, y: int) -> bool:
        """Union by rank. Returns True if merge occurred."""
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        self.component_size[rx] += self.component_size[ry]
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        self.num_components -= 1
        return True

    def connected(self, x: int, y: int) -> bool:
        return self.find(x) == self.find(y)


# ──────────────────────────────────────────────────────────────
# Tropical Morse Spectrum
# ──────────────────────────────────────────────────────────────

class MorseEvent:
    """A critical event in the tropical Morse filtration.

    Attributes:
        value: The critical weight value at which the event occurs.
        event_type: One of 'birth', 'merge', 'cycle_death'.
        components_after: Number of connected components after this event.
        cycle_rank_after: Cycle rank (β₁) after this event.
    """
    BIRTH = "birth"
    MERGE = "merge"
    CYCLE_DEATH = "cycle_death"

    def __init__(self, value: float, event_type: str,
                 components_after: int = 0, cycle_rank_after: int = 0):
        self.value = value
        self.event_type = event_type
        self.components_after = components_after
        self.cycle_rank_after = cycle_rank_after

    def __repr__(self):
        return (f"MorseEvent(t={self.value}, type={self.event_type}, "
                f"β₀={self.components_after}, β₁={self.cycle_rank_after})")

    def __eq__(self, other):
        return (isinstance(other, MorseEvent) and
                self.value == other.value and
                self.event_type == other.event_type)

    def __hash__(self):
        return hash((self.value, self.event_type))


def compute_tropical_morse_spectrum(
    n: int,
    edges: List[Tuple[int, int, float]],
    include_births: bool = False
) -> List[MorseEvent]:
    """
    Compute the tropical Morse spectrum via Kruskal-like filtration.

    Algorithm:
        1. Sort edges by weight: O(E log E)
        2. Process edges in order using Union-Find: O(E α(V))
        3. For each edge (u,v,w):
           - If find(u) ≠ find(v): MERGE event (β₀ decreases by 1)
           - If find(u) = find(v): CYCLE_DEATH event (β₁ increases by 1)

    Total time: O(E log E)
    Space: O(V + E)

    Parameters:
        n: Number of vertices.
        edges: List of (u, v, weight) triples.
        include_births: If True, include initial birth events at -∞.

    Returns:
        Sorted list of MorseEvent objects.
    """
    events = []
    uf = UnionFind(n)
    cycle_rank = 0

    # Optional birth events
    if include_births:
        events.extend(
            MorseEvent(float('-inf'), MorseEvent.BIRTH,
                      components_after=n, cycle_rank_after=0)
            for _ in range(n)
        )

    # Sort by weight
    sorted_edges = sorted(edges, key=lambda e: e[2])

    for u, v, w in sorted_edges:
        if uf.union(u, v):
            events.append(MorseEvent(
                w, MorseEvent.MERGE,
                components_after=uf.num_components,
                cycle_rank_after=cycle_rank
            ))
        else:
            cycle_rank += 1
            events.append(MorseEvent(
                w, MorseEvent.CYCLE_DEATH,
                components_after=uf.num_components,
                cycle_rank_after=cycle_rank
            ))

    return events


# ──────────────────────────────────────────────────────────────
# Persistent Homology Barcode
# ──────────────────────────────────────────────────────────────

class Bar:
    """A bar in the persistence barcode."""
    def __init__(self, birth: float, death: float, dimension: int):
        self.birth = birth
        self.death = death
        self.dimension = dimension
        self.persistence = death - birth

    def __repr__(self):
        return f"Bar(dim={self.dimension}, [{self.birth}, {self.death}), pers={self.persistence:.3f})"


def extract_barcode(
    n: int,
    edges: List[Tuple[int, int, float]]
) -> List[Bar]:
    """
    Extract the persistent homology barcode from the weight filtration.

    H₀ bars: Born at -∞ for each vertex, die at merge events.
    H₁ bars: Born at cycle_death events, die at +∞.

    Returns:
        List of Bar objects (H₀ and H₁ bars).
    """
    bars = []
    uf = UnionFind(n)

    # Track birth times for components
    birth_time = {i: float('-inf') for i in range(n)}

    sorted_edges = sorted(edges, key=lambda e: e[2])

    for u, v, w in sorted_edges:
        ru, rv = uf.find(u), uf.find(v)
        if ru != rv:
            # Merge: the younger component dies
            # By convention, the component with later birth time dies
            if birth_time.get(ru, float('-inf')) > birth_time.get(rv, float('-inf')):
                dying = ru
            else:
                dying = rv
            bars.append(Bar(birth_time[dying], w, dimension=0))
            uf.union(u, v)
            # Update birth time for merged component
            new_root = uf.find(u)
            birth_time[new_root] = min(birth_time.get(ru, float('-inf')),
                                       birth_time.get(rv, float('-inf')))
        else:
            # Cycle: H₁ bar born
            bars.append(Bar(w, float('inf'), dimension=1))

    # The surviving H₀ component (if graph is connected) has infinite death
    if uf.num_components == 1:
        root = uf.find(0)
        bars.append(Bar(birth_time[root], float('inf'), dimension=0))

    return bars


# ──────────────────────────────────────────────────────────────
# 1-WL Color Refinement
# ──────────────────────────────────────────────────────────────

def wl1_refine(
    n: int,
    adj: Dict[int, Set[int]],
    max_iter: int = None
) -> Tuple[List[int], int]:
    """
    1-WL color refinement.

    Algorithm:
        1. Initialize colors from vertex degrees.
        2. Repeat until stable:
           - For each vertex, compute (own_color, sorted_neighbor_colors).
           - Hash these tuples to new integer colors.

    Time: O(V² · E) worst case, O(V · E) per iteration.

    Returns:
        (stable_colors, num_iterations)
    """
    if max_iter is None:
        max_iter = n

    colors = [len(adj.get(v, set())) for v in range(n)]

    for iteration in range(max_iter):
        signatures = []
        for v in range(n):
            nbr_colors = tuple(sorted(colors[u] for u in adj.get(v, set())))
            signatures.append((colors[v], nbr_colors))

        color_map = {}
        new_colors = []
        for sig in signatures:
            if sig not in color_map:
                color_map[sig] = len(color_map)
            new_colors.append(color_map[sig])

        if new_colors == colors:
            return colors, iteration + 1
        colors = new_colors

    return colors, max_iter


def wl1_equivalent(n1, adj1, n2, adj2) -> bool:
    """Check if two graphs are 1-WL equivalent."""
    if n1 != n2:
        return False
    c1, _ = wl1_refine(n1, adj1)
    c2, _ = wl1_refine(n2, adj2)
    return Counter(c1) == Counter(c2)


# ──────────────────────────────────────────────────────────────
# Bottleneck Distance
# ──────────────────────────────────────────────────────────────

def bottleneck_distance(
    events1: List[MorseEvent],
    events2: List[MorseEvent]
) -> float:
    """
    Compute the bottleneck distance between two Morse event sequences.

    For matched events (same type, ordered), the bottleneck distance is
    the maximum absolute difference between critical values.

    This is a simplified version that assumes events can be matched
    by index when sorted by value.

    Returns:
        The bottleneck distance (max shift in critical values).
    """
    if len(events1) != len(events2):
        return float('inf')

    return max(
        abs(e1.value - e2.value)
        for e1, e2 in zip(events1, events2)
    ) if events1 else 0.0


# ──────────────────────────────────────────────────────────────
# Tropical Morse Complexity
# ──────────────────────────────────────────────────────────────

def tropical_morse_complexity(events: List[MorseEvent]) -> int:
    """
    The tropical Morse complexity: number of distinct critical values.

    This measures the "topological complexity" of the weight landscape.
    """
    return len(set(e.value for e in events if e.value != float('-inf')))


# ──────────────────────────────────────────────────────────────
# GNN Feature Construction
# ──────────────────────────────────────────────────────────────

def tms_feature_vector(
    n: int,
    edges: List[Tuple[int, int, float]],
    num_bins: int = 10,
    max_weight: float = None
) -> List[float]:
    """
    Construct a fixed-size feature vector from the tropical Morse spectrum.

    Creates a histogram of critical values binned into `num_bins` intervals,
    split by event type (merge vs cycle_death).

    Feature vector layout:
        [merge_bin_1, ..., merge_bin_k, cycle_bin_1, ..., cycle_bin_k,
         total_merges, total_cycles, β₁_final, complexity]

    Total dimension: 2 * num_bins + 4

    Parameters:
        n: Number of vertices.
        edges: Weighted edge list.
        num_bins: Number of histogram bins.
        max_weight: Maximum weight for binning (auto-detected if None).

    Returns:
        Feature vector as list of floats.
    """
    events = compute_tropical_morse_spectrum(n, edges)

    if not events:
        return [0.0] * (2 * num_bins + 4)

    if max_weight is None:
        max_weight = max(e.value for e in events) + 1e-6

    min_weight = min(e.value for e in events)
    bin_width = (max_weight - min_weight) / num_bins if max_weight > min_weight else 1.0

    merge_hist = [0.0] * num_bins
    cycle_hist = [0.0] * num_bins

    for e in events:
        bin_idx = min(int((e.value - min_weight) / bin_width), num_bins - 1)
        if e.event_type == MorseEvent.MERGE:
            merge_hist[bin_idx] += 1.0
        elif e.event_type == MorseEvent.CYCLE_DEATH:
            cycle_hist[bin_idx] += 1.0

    total_merges = sum(1 for e in events if e.event_type == MorseEvent.MERGE)
    total_cycles = sum(1 for e in events if e.event_type == MorseEvent.CYCLE_DEATH)
    beta1 = total_cycles
    complexity = tropical_morse_complexity(events)

    return merge_hist + cycle_hist + [total_merges, total_cycles, beta1, complexity]


# ──────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Example: C₆ vs 2×C₃
    print("=== Tropical Morse Spectrum Algorithm Demo ===\n")

    # C₆
    c6_edges = [(i, (i+1)%6, float(i+1)) for i in range(6)]
    tms_c6 = compute_tropical_morse_spectrum(6, c6_edges)
    print("C₆ spectrum:")
    for e in tms_c6:
        print(f"  {e}")

    barcode_c6 = extract_barcode(6, c6_edges)
    print("\nC₆ barcode:")
    for b in barcode_c6:
        print(f"  {b}")

    # 2×C₃
    tri_edges = [
        (0,1,1.0), (1,2,3.0), (0,2,5.0),
        (3,4,2.0), (4,5,4.0), (3,5,6.0)
    ]
    tms_2t = compute_tropical_morse_spectrum(6, tri_edges)
    print("\n2×C₃ spectrum:")
    for e in tms_2t:
        print(f"  {e}")

    # Feature vectors
    fv_c6 = tms_feature_vector(6, c6_edges, num_bins=6)
    fv_2t = tms_feature_vector(6, tri_edges, num_bins=6)
    print(f"\nC₆ feature vector:   {fv_c6}")
    print(f"2×C₃ feature vector: {fv_2t}")
    print(f"Vectors differ: {fv_c6 != fv_2t}")

    # Bottleneck distance
    bd = bottleneck_distance(tms_c6, tms_2t)
    print(f"\nBottleneck distance: {bd}")
