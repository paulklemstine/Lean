"""
Algorithms for Sheaf-Theoretic Tropical Persistence
====================================================

Implements the core algorithms from the research paper:
1. Critical stratification computation
2. Stalk/rank data computation
3. Sheaf jump computation
4. Cumulative profile construction
5. Stability bound evaluation

All algorithms operate on finite graph filtrations and have
polynomial time complexity.

Type hints and docstrings included throughout.
"""

from typing import List, Dict, Tuple, Set, Optional
from collections import defaultdict
import math


# ─── Core Data Structures ───────────────────────────────────────────

class Graph:
    """Simple undirected graph on integer vertices."""

    def __init__(self, vertices: Set[int], edges: List[Tuple[int, int]]):
        self.vertices = vertices
        self.edges = edges
        self._adj: Dict[int, Set[int]] = defaultdict(set)
        for u, v in edges:
            self._adj[u].add(v)
            self._adj[v].add(u)

    def degree(self, v: int) -> int:
        """Degree of vertex v. O(1) amortized."""
        return len(self._adj[v])

    def neighbors(self, v: int) -> Set[int]:
        """Neighbors of vertex v."""
        return self._adj[v]

    def subgraph(self, S: Set[int]) -> 'Graph':
        """Induced subgraph on vertex set S. O(|E|)."""
        sub_edges = [(u, v) for u, v in self.edges if u in S and v in S]
        return Graph(S, sub_edges)

    @staticmethod
    def path(n: int) -> 'Graph':
        """Path graph P_{n+1} on {0, ..., n}. O(n)."""
        return Graph(set(range(n + 1)), [(i, i + 1) for i in range(n)])

    @staticmethod
    def cycle(n: int) -> 'Graph':
        """Cycle graph C_n on {0, ..., n-1}. Requires n >= 3. O(n)."""
        assert n >= 3
        return Graph(set(range(n)), [(i, (i + 1) % n) for i in range(n)])


class VertexFiltration:
    """Vertex filtration: assigns an entrance time to each vertex.

    Time complexity:
        Construction: O(|V| log |V|) for sorting critical values.
        Query (active_vertices): O(|V|) per query.
    """

    def __init__(self, entrance_times: Dict[int, float]):
        self.entrance_times = entrance_times
        self._critical_values = sorted(set(entrance_times.values()))

    @property
    def critical_values(self) -> List[float]:
        """Sorted list of critical values (unique entrance times). O(1)."""
        return self._critical_values

    def active_vertices(self, t: float) -> Set[int]:
        """Vertices with entrance time ≤ t. O(|V|)."""
        return {v for v, ft in self.entrance_times.items() if ft <= t}

    def fiber(self, c: float) -> Set[int]:
        """Vertices entering exactly at time c. O(|V|)."""
        return {v for v, ft in self.entrance_times.items() if ft == c}

    def sup_distance(self, other: 'VertexFiltration') -> float:
        """Sup-norm distance to another filtration. O(|V|)."""
        assert set(self.entrance_times.keys()) == set(other.entrance_times.keys())
        return max(abs(self.entrance_times[v] - other.entrance_times[v])
                   for v in self.entrance_times)

    @staticmethod
    def natural(n: int) -> 'VertexFiltration':
        """Natural filtration on {0, ..., n}: vertex i enters at time i. O(n)."""
        return VertexFiltration({i: float(i) for i in range(n + 1)})


# ─── Algorithm 1: Critical Stratification ───────────────────────────

def compute_critical_stratification(filt: VertexFiltration) -> List[Tuple[str, float, float]]:
    """Compute the critical stratification of the threshold line.

    Returns a list of strata, each a tuple (type, start, end):
      - ("critical", c, c) for each critical value c
      - ("open", a, b) for open intervals (a, b) between critical values

    Time: O(|V| log |V|)    Space: O(|V|)

    >>> filt = VertexFiltration.natural(3)
    >>> strata = compute_critical_stratification(filt)
    >>> [(s[0], s[1]) for s in strata if s[0] == 'critical']
    [('critical', 0.0), ('critical', 1.0), ('critical', 2.0), ('critical', 3.0)]
    """
    crits = filt.critical_values
    strata = []
    for i, c in enumerate(crits):
        if i > 0:
            strata.append(("open", crits[i - 1], c))
        strata.append(("critical", c, c))
    return strata


# ─── Algorithm 2: Sheaf Jump Computation ────────────────────────────

def compute_sheaf_jump(G: Graph, filt: VertexFiltration, c: float) -> int:
    """Compute the sheaf jump at critical value c.

    Jump = sum of (degree(v) + 1) for all vertices v entering at time c.

    Time: O(|V|)    Space: O(1)

    >>> G = Graph.path(3)
    >>> filt = VertexFiltration.natural(3)
    >>> compute_sheaf_jump(G, filt, 1.0)
    3
    """
    return sum(G.degree(v) + 1 for v in filt.fiber(c))


def compute_all_sheaf_jumps(G: Graph, filt: VertexFiltration) -> Dict[float, int]:
    """Compute sheaf jumps at all critical values.

    Time: O(|V|²) worst case, O(|V| · max_degree) typical.
    Space: O(|V|)

    >>> G = Graph.path(3)
    >>> filt = VertexFiltration.natural(3)
    >>> jumps = compute_all_sheaf_jumps(G, filt)
    >>> jumps[0.0], jumps[1.0], jumps[2.0], jumps[3.0]
    (2, 3, 3, 2)
    """
    return {c: compute_sheaf_jump(G, filt, c) for c in filt.critical_values}


# ─── Algorithm 3: Cumulative Sheaf Profile ──────────────────────────

def compute_sheaf_event_profile(G: Graph, filt: VertexFiltration, t: float) -> int:
    """Compute the sheaf event profile at threshold t.

    This equals the cumulative sum of sheaf jumps at critical values ≤ t,
    which by our main theorem equals the tropical event profile.

    Time: O(|V|²) worst case.    Space: O(|V|)

    >>> G = Graph.path(3)
    >>> filt = VertexFiltration.natural(3)
    >>> compute_sheaf_event_profile(G, filt, 2.0)
    8
    """
    return sum(compute_sheaf_jump(G, filt, c)
               for c in filt.critical_values if c <= t)


def compute_profile_table(G: Graph, filt: VertexFiltration) -> List[Tuple[float, int]]:
    """Compute the complete profile table at all critical values.

    Returns [(c, cumulative_profile_at_c), ...] sorted by c.

    Time: O(|V|² log |V|)    Space: O(|V|)

    >>> G = Graph.path(3)
    >>> filt = VertexFiltration.natural(3)
    >>> compute_profile_table(G, filt)
    [(0.0, 2), (1.0, 5), (2.0, 8), (3.0, 10)]
    """
    jumps = compute_all_sheaf_jumps(G, filt)
    cumulative = 0
    table = []
    for c in filt.critical_values:
        cumulative += jumps[c]
        table.append((c, cumulative))
    return table


# ─── Algorithm 4: Stability Bound Evaluation ────────────────────────

def compute_stability_bound(G: Graph, filt1: VertexFiltration,
                            filt2: VertexFiltration) -> Dict[str, float]:
    """Evaluate the sheaf-theoretic stability bound.

    Returns:
        - sup_dist: sup-norm distance between filtrations
        - max_degree: maximum degree in G
        - barcode_bound: (max_degree + 1) * sup_dist
        - max_profile_diff: observed maximum |profile1(t) - profile2(t)|

    Time: O(|V|² · |C|) where |C| = number of critical values.
    Space: O(|V|)

    >>> G = Graph.path(3)
    >>> f1 = VertexFiltration.natural(3)
    >>> f2 = VertexFiltration({i: float(i) + 0.1 for i in range(4)})
    >>> result = compute_stability_bound(G, f1, f2)
    >>> result['sup_dist']
    0.1
    """
    sup_dist = filt1.sup_distance(filt2)
    max_deg = max(G.degree(v) for v in G.vertices) if G.vertices else 0
    barcode_bound = (max_deg + 1) * sup_dist

    # Sample profile differences
    all_crits = sorted(set(filt1.critical_values + filt2.critical_values))
    test_points = []
    for c in all_crits:
        test_points.extend([c - 0.01, c, c + 0.01])

    max_diff = 0
    for t in test_points:
        p1 = compute_sheaf_event_profile(G, filt1, t)
        p2 = compute_sheaf_event_profile(G, filt2, t)
        max_diff = max(max_diff, abs(p1 - p2))

    return {
        'sup_dist': sup_dist,
        'max_degree': max_deg,
        'barcode_bound': barcode_bound,
        'max_profile_diff': max_diff,
    }


# ─── Algorithm 5: Singular Support ──────────────────────────────────

def compute_singular_support(G: Graph, filt: VertexFiltration) -> List[float]:
    """Compute the singular support of the tropical rank sheaf.

    These are the critical values where the sheaf jump is nonzero,
    i.e., the "microsupport" of the constructible sheaf.

    Time: O(|V|²)    Space: O(|V|)

    >>> G = Graph.path(3)
    >>> filt = VertexFiltration.natural(3)
    >>> compute_singular_support(G, filt)
    [0.0, 1.0, 2.0, 3.0]
    """
    return [c for c in filt.critical_values
            if compute_sheaf_jump(G, filt, c) != 0]


# ─── Algorithm 6: Higher Sheaf Jump ─────────────────────────────────

def compute_higher_sheaf_jump(filt: VertexFiltration, c: float) -> int:
    """Compute the higher sheaf jump at c.

    This measures simultaneous vertex entrances beyond the first.
    For injective filtrations, this is always 0.

    Time: O(|V|)    Space: O(1)
    """
    fiber_size = len(filt.fiber(c))
    return max(0, fiber_size - 1)


# ─── Algorithm 7: Euler Characteristic ──────────────────────────────

def compute_euler_characteristic(G: Graph, filt: VertexFiltration, t: float) -> int:
    """Compute the Euler characteristic of the active subgraph at threshold t.

    χ(t) = |active vertices| - |active edges|

    Time: O(|V| + |E|)    Space: O(|V|)

    >>> G = Graph.path(3)
    >>> filt = VertexFiltration.natural(3)
    >>> compute_euler_characteristic(G, filt, 2.0)
    1
    """
    active = filt.active_vertices(t)
    active_edges = sum(1 for u, v in G.edges if u in active and v in active)
    return len(active) - active_edges


# ─── Example Usage ──────────────────────────────────────────────────

if __name__ == "__main__":
    # Path graph example
    print("=== Path Graph P_6 ===")
    G = Graph.path(5)
    filt = VertexFiltration.natural(5)

    print(f"Critical values: {filt.critical_values}")
    print(f"Singular support: {compute_singular_support(G, filt)}")
    print(f"Stratification: {compute_critical_stratification(filt)}")
    print(f"\nProfile table:")
    for c, p in compute_profile_table(G, filt):
        print(f"  t={c}: profile={p}")

    print(f"\nJump data:")
    for c, j in compute_all_sheaf_jumps(G, filt).items():
        print(f"  c={c}: jump={j}, higher_jump={compute_higher_sheaf_jump(filt, c)}")

    print(f"\nEuler characteristic at each stage:")
    for c in filt.critical_values:
        chi = compute_euler_characteristic(G, filt, c)
        print(f"  t={c}: χ={chi}")

    # Stability example
    print(f"\n=== Stability Test ===")
    filt2 = VertexFiltration({i: float(i) + 0.2 for i in range(6)})
    result = compute_stability_bound(G, filt, filt2)
    for k, v in result.items():
        print(f"  {k}: {v}")

    # Cycle graph example
    print(f"\n=== Cycle Graph C_6 ===")
    G_cycle = Graph.cycle(6)
    filt_cycle = VertexFiltration({i: float(i) for i in range(6)})
    print(f"Profile table:")
    for c, p in compute_profile_table(G_cycle, filt_cycle):
        print(f"  t={c}: profile={p}")
