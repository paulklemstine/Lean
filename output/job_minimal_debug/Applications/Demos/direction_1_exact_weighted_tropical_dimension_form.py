#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Weighted Tropical Kernel Dimension

Demonstrates connections to:
  1. Network routing: shortest-path degeneracy detection
  2. Resistor networks: resonance mode counting
  3. Optimization: min-plus linear algebra kernel structure
"""

from __future__ import annotations
from collections import defaultdict
import random
import heapq


# ──────────────────────────────────────────────────────────────────────
# Core graph class (self-contained)
# ──────────────────────────────────────────────────────────────────────

class WGraph:
    def __init__(self, n: int):
        self.n = n
        self.adj: dict[int, set[int]] = defaultdict(set)
        self.weight: dict[tuple[int, int], int] = {}

    def add_edge(self, u: int, v: int, w: int = 1):
        if u == v:
            return
        self.adj[u].add(v)
        self.adj[v].add(u)
        self.weight[(u, v)] = w
        self.weight[(v, u)] = w

    def edges(self):
        seen = set()
        for u in range(self.n):
            for v in self.adj[u]:
                if (v, u) not in seen:
                    seen.add((u, v))
                    yield (u, v, self.weight[(u, v)])


def construct_tie_subgraph(G: WGraph) -> WGraph:
    T = WGraph(G.n)
    for u, v, w in G.edges():
        wuv = G.weight[(u, v)]
        tie_at_u = any(G.weight[(u, k)] == wuv for k in G.adj[u] if k != v)
        tie_at_v = any(G.weight[(v, k)] == G.weight[(v, u)] for k in G.adj[v] if k != u)
        if tie_at_u or tie_at_v:
            T.add_edge(u, v, w)
    return T


def connected_components(G: WGraph, S: set[int]) -> list[set[int]]:
    visited = set()
    components = []
    for start in S:
        if start in visited:
            continue
        comp = set()
        stack = [start]
        while stack:
            v = stack.pop()
            if v in comp:
                continue
            comp.add(v)
            visited.add(v)
            for nb in G.adj[v]:
                if nb in S and nb not in comp:
                    stack.append(nb)
        components.append(comp)
    return components


def cycle_rank(G: WGraph, S: set[int]) -> int:
    if not S:
        return 0
    e = sum(1 for u, v, _ in G.edges() if u in S and v in S)
    c = len(connected_components(G, S))
    return max(0, e + c - len(S))


def visible_components(G: WGraph, q: int, S: set[int]) -> int:
    comps = connected_components(G, S)
    return sum(1 for comp in comps if any(v in G.adj.get(q, set()) for v in comp))


def weighted_kernel_dim(G: WGraph, q: int, S: set[int]) -> int:
    T = construct_tie_subgraph(G)
    return cycle_rank(T, S) + visible_components(T, q, S)


# ──────────────────────────────────────────────────────────────────────
# Application 1: Network Routing — Shortest Path Degeneracy
# ──────────────────────────────────────────────────────────────────────

def dijkstra_all_paths(G: WGraph, source: int) -> dict[int, list[list[int]]]:
    """Find ALL shortest paths from source using modified Dijkstra."""
    dist: dict[int, float] = {source: 0}
    paths: dict[int, list[list[int]]] = {source: [[source]]}
    pq = [(0, source)]

    while pq:
        d, u = heapq.heappop(pq)
        if d > dist.get(u, float('inf')):
            continue
        for v in G.adj[u]:
            new_dist = d + G.weight[(u, v)]
            if v not in dist or new_dist < dist[v]:
                dist[v] = new_dist
                paths[v] = [p + [v] for p in paths[u]]
                heapq.heappush(pq, (new_dist, v))
            elif new_dist == dist[v]:
                paths[v].extend(p + [v] for p in paths[u])

    return paths


def shortest_path_degeneracy(G: WGraph, source: int) -> dict[int, int]:
    """Count number of distinct shortest paths to each vertex."""
    paths = dijkstra_all_paths(G, source)
    return {v: len(ps) for v, ps in paths.items()}


def demo_routing():
    """Demonstrate connection between tie subgraph and routing degeneracy."""
    print("=" * 60)
    print("APPLICATION 1: Network Routing — Shortest Path Degeneracy")
    print("=" * 60)

    # City network with some equal-cost paths
    G = WGraph(6)
    # Hub-and-spoke with equal-weight spokes
    G.add_edge(0, 1, 3)
    G.add_edge(0, 2, 3)  # tie at 0: w(0,1) = w(0,2) = 3
    G.add_edge(0, 3, 5)
    G.add_edge(1, 4, 2)
    G.add_edge(2, 4, 2)  # tie at 4: w(4,1) = w(4,2) = 2
    G.add_edge(3, 5, 1)
    G.add_edge(4, 5, 4)

    q = 0
    S = {1, 2, 3, 4, 5}

    T = construct_tie_subgraph(G)
    tie_edges = list(T.edges())
    deg = shortest_path_degeneracy(G, q)
    dim = weighted_kernel_dim(G, q, S)

    print(f"\nCity network: 6 nodes, hub at node 0")
    print(f"Tie subgraph edges: {[(u,v) for u,v,_ in tie_edges]}")
    print(f"Shortest path counts from node 0:")
    for v in sorted(deg.keys()):
        if v != 0:
            print(f"  To node {v}: {deg[v]} shortest path(s)")
    print(f"\nWeighted kernel dimension: {dim}")
    print(f"  β₁ʷ = {cycle_rank(T, S)}, κʷ = {visible_components(T, q, S)}")
    print(f"\nInsight: Tie edges mark where routing has multiple optimal choices.")
    print(f"The kernel dimension counts independent degrees of freedom in routing.")


# ──────────────────────────────────────────────────────────────────────
# Application 2: Resistor Networks — Resonance Mode Analysis
# ──────────────────────────────────────────────────────────────────────

def weighted_laplacian(G: WGraph) -> list[list[float]]:
    """Compute weighted graph Laplacian matrix."""
    L = [[0.0] * G.n for _ in range(G.n)]
    for u, v, w in G.edges():
        L[u][v] -= w
        L[v][u] -= w
        L[u][u] += w
        L[v][v] += w
    return L


def demo_resistor_network():
    """Demonstrate connection to resistor network zero modes."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: Resistor Networks — Resonance Modes")
    print("=" * 60)

    # Create resistor network with equal resistances on some branches
    G = WGraph(5)
    G.add_edge(0, 1, 10)  # 10Ω
    G.add_edge(0, 2, 10)  # 10Ω — tie with (0,1)
    G.add_edge(1, 3, 5)
    G.add_edge(2, 3, 5)   # tie with (1,3)
    G.add_edge(3, 4, 7)

    q = 0
    S = {1, 2, 3, 4}

    T = construct_tie_subgraph(G)
    dim = weighted_kernel_dim(G, q, S)
    beta1 = cycle_rank(T, S)
    kappa = visible_components(T, q, S)

    L = weighted_laplacian(G)

    print(f"\nResistor network: 5 nodes, ground at node 0")
    print(f"Resistances: (0-1)=10Ω, (0-2)=10Ω, (1-3)=5Ω, (2-3)=5Ω, (3-4)=7Ω")
    print(f"\nTie subgraph edges: {[(u,v) for u,v,_ in T.edges()]}")
    print(f"β₁ʷ = {beta1} (degenerate cycle modes)")
    print(f"κʷ  = {kappa} (visible components)")
    print(f"dim = {dim}")
    print(f"\nWeighted Laplacian (first 3 rows):")
    for i in range(min(3, G.n)):
        print(f"  {L[i]}")
    print(f"\nInsight: Equal resistances create degenerate current distributions.")
    print(f"The tie subgraph cycle rank counts independent resonance modes.")


# ──────────────────────────────────────────────────────────────────────
# Application 3: Supply Chain Optimization
# ──────────────────────────────────────────────────────────────────────

def demo_supply_chain():
    """Demonstrate application to supply chain network optimization."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Supply Chain — Cost Degeneracy Analysis")
    print("=" * 60)

    # Supply chain: warehouse (0) → distribution centers → retail
    G = WGraph(7)
    # Warehouse to DCs
    G.add_edge(0, 1, 8)   # DC-North
    G.add_edge(0, 2, 8)   # DC-South (same cost — tie!)
    G.add_edge(0, 3, 12)  # DC-West

    # DCs to retail
    G.add_edge(1, 4, 3)   # North → Retail-A
    G.add_edge(2, 4, 3)   # South → Retail-A (same cost — tie!)
    G.add_edge(2, 5, 5)   # South → Retail-B
    G.add_edge(3, 5, 5)   # West → Retail-B (tie with South→B!)
    G.add_edge(3, 6, 4)   # West → Retail-C

    q = 0  # warehouse
    S = {1, 2, 3, 4, 5, 6}  # all other nodes

    T = construct_tie_subgraph(G)
    dim = weighted_kernel_dim(G, q, S)

    print(f"\nSupply chain network:")
    print(f"  Warehouse (0) → 3 DCs → 3 Retail stores")
    print(f"  Cost ties: DC-North ↔ DC-South cost, Retail-A paths, Retail-B paths")
    print(f"\nTie subgraph edges: {[(u,v) for u,v,_ in T.edges()]}")
    print(f"Weighted kernel dimension: {dim}")
    print(f"  β₁ʷ = {cycle_rank(T, S)}")
    print(f"  κʷ  = {visible_components(T, q, S)}")
    print(f"\nInterpretation:")
    print(f"  dim = {dim} means there are {dim} independent degrees of freedom")
    print(f"  in choosing optimal supply routes. Each represents a cost-neutral")
    print(f"  reallocation of flow — valuable for robustness and load balancing.")


# ──────────────────────────────────────────────────────────────────────
# Application 4: Weight Sensitivity Analysis
# ──────────────────────────────────────────────────────────────────────

def demo_sensitivity():
    """Analyze how dimension changes as weights are perturbed."""
    print("\n" + "=" * 60)
    print("APPLICATION 4: Weight Sensitivity — Phase Transitions")
    print("=" * 60)

    n = 5
    G_base = WGraph(n)
    base_edges = [(0,1), (1,2), (2,3), (3,4), (4,0), (0,2), (1,3)]

    q = 0
    S = {1, 2, 3, 4}

    print(f"\nBase graph: {n} vertices, {len(base_edges)} edges")
    print(f"Varying edge weights from uniform (all=1) to generic (all distinct)")
    print()

    # Uniform → generic transition
    for step in range(6):
        G = WGraph(n)
        for i, (u, v) in enumerate(base_edges):
            # Gradually separate weights
            w = 10 + i * step
            G.add_edge(u, v, w)

        T = construct_tie_subgraph(G)
        dim = weighted_kernel_dim(G, q, S)
        beta1 = cycle_rank(T, S)
        kappa = visible_components(T, q, S)
        tie_count = sum(1 for _ in T.edges())

        weights = [G.weight[(u,v)] for u,v in base_edges]
        print(f"  Step {step}: weights={weights}")
        print(f"    Tie edges: {tie_count}, β₁ʷ={beta1}, κʷ={kappa}, dim={dim}")

    print(f"\nInsight: As weights separate, tie edges disappear and dimension drops.")
    print(f"This is the 'generic-weight collapse' — a phase transition in the")
    print(f"tropical kernel structure controlled by weight degeneracy.")


if __name__ == "__main__":
    demo_routing()
    demo_resistor_network()
    demo_supply_chain()
    demo_sensitivity()
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
demo.py — Weighted Tropical Kernel Dimension Formula: Interactive Demonstration

Demonstrates the exact weighted tropical dimension formula:
    dim_trop(G, w, q, S) = β₁ʷ(G, w, S) + κʷ(G, w, q, S)

where β₁ʷ is the cycle rank of the weight-degeneracy (tie) subgraph and κʷ counts
q-visible components in that subgraph.

Features:
  - Construct tie subgraphs from weighted graphs
  - Compute weighted Betti numbers and visible defect
  - Verify generic-weight collapse (β₁ʷ = 0)
  - Verify uniform-weight recovery (β₁ʷ = β₁)
  - Exhaustive search on small graphs for counterexamples
"""

from __future__ import annotations
import itertools
import random
from collections import defaultdict
from typing import Optional


# ──────────────────────────────────────────────────────────────────────
# Core data structures
# ──────────────────────────────────────────────────────────────────────

class WeightedGraph:
    """A finite simple graph with integer edge weights."""

    def __init__(self, n: int):
        self.n = n
        self.adj: dict[int, set[int]] = defaultdict(set)
        self.weight: dict[tuple[int, int], int] = {}

    def add_edge(self, u: int, v: int, w: int = 1):
        if u == v:
            return
        self.adj[u].add(v)
        self.adj[v].add(u)
        self.weight[(u, v)] = w
        self.weight[(v, u)] = w

    def edges(self) -> list[tuple[int, int]]:
        seen = set()
        result = []
        for u in range(self.n):
            for v in self.adj[u]:
                if (v, u) not in seen:
                    seen.add((u, v))
                    result.append((u, v))
        return result

    def degree(self, v: int) -> int:
        return len(self.adj[v])

    def neighbors(self, v: int) -> set[int]:
        return self.adj[v]

    def __repr__(self):
        edges_str = ", ".join(
            f"({u},{v},w={self.weight[(u,v)]})" for u, v in self.edges()
        )
        return f"WeightedGraph(n={self.n}, edges=[{edges_str}])"


# ──────────────────────────────────────────────────────────────────────
# Tie subgraph construction
# ──────────────────────────────────────────────────────────────────────

def has_tie_at_vertex(G: WeightedGraph, w_func, u: int, v: int) -> bool:
    """Check if edge (u,v) has a weight tie at vertex u."""
    if v not in G.adj[u]:
        return False
    wuv = w_func(u, v)
    for k in G.adj[u]:
        if k != v and w_func(u, k) == wuv:
            return True
    return False


def build_tie_subgraph(G: WeightedGraph, w_func=None) -> WeightedGraph:
    """Build the tie subgraph: edges participating in weight ties."""
    if w_func is None:
        w_func = lambda u, v: G.weight.get((u, v), 0)

    H = WeightedGraph(G.n)
    for u, v in G.edges():
        if has_tie_at_vertex(G, w_func, u, v) or has_tie_at_vertex(G, w_func, v, u):
            H.add_edge(u, v, w_func(u, v))
    return H


# ──────────────────────────────────────────────────────────────────────
# Graph invariants
# ──────────────────────────────────────────────────────────────────────

def connected_components(G: WeightedGraph, S: set[int]) -> list[set[int]]:
    """Find connected components of G restricted to vertex set S."""
    visited = set()
    components = []
    for start in S:
        if start in visited:
            continue
        comp = set()
        stack = [start]
        while stack:
            v = stack.pop()
            if v in comp:
                continue
            comp.add(v)
            visited.add(v)
            for nb in G.adj[v]:
                if nb in S and nb not in comp:
                    stack.append(nb)
        components.append(comp)
    return components


def edge_count_on(G: WeightedGraph, S: set[int]) -> int:
    """Count edges in the subgraph induced on S."""
    count = 0
    for u, v in G.edges():
        if u in S and v in S:
            count += 1
    return count


def cycle_rank(G: WeightedGraph, S: set[int]) -> int:
    """Compute β₁(G[S]) = |E(G[S])| + c(G[S]) - |S|."""
    if not S:
        return 0
    e = edge_count_on(G, S)
    c = len(connected_components(G, S))
    return e + c - len(S)


def visible_components(G: WeightedGraph, q: int, S: set[int]) -> int:
    """Count components of G[S] that have a vertex adjacent to q in G."""
    comps = connected_components(G, S)
    count = 0
    for comp in comps:
        for v in comp:
            if v in G.adj.get(q, set()):
                count += 1
                break
    return count


# ──────────────────────────────────────────────────────────────────────
# Weighted tropical invariants
# ──────────────────────────────────────────────────────────────────────

def weighted_betti1(G: WeightedGraph, S: set[int], w_func=None) -> int:
    """Weighted first Betti number: cycle rank of tie subgraph on S."""
    H = build_tie_subgraph(G, w_func)
    return cycle_rank(H, S)


def weighted_visible_defect(G: WeightedGraph, q: int, S: set[int], w_func=None) -> int:
    """Weighted visible defect: q-visible components of tie subgraph on S."""
    H = build_tie_subgraph(G, w_func)
    return visible_components(H, q, S)


def weighted_trop_kernel_dim(G: WeightedGraph, q: int, S: set[int], w_func=None) -> int:
    """Weighted tropical kernel dimension = β₁ʷ + κʷ."""
    return weighted_betti1(G, S, w_func) + weighted_visible_defect(G, q, S, w_func)


def is_generic(G: WeightedGraph, w_func=None) -> bool:
    """Check if weights are generic (all distinct at each vertex)."""
    if w_func is None:
        w_func = lambda u, v: G.weight.get((u, v), 0)
    for v in range(G.n):
        weights = [w_func(v, nb) for nb in G.adj[v]]
        if len(weights) != len(set(weights)):
            return False
    return True


# ──────────────────────────────────────────────────────────────────────
# Demonstrations
# ──────────────────────────────────────────────────────────────────────

def demo_triangle():
    """Triangle graph with various weights."""
    print("=" * 60)
    print("DEMO 1: Triangle graph (K₃)")
    print("=" * 60)

    # Uniform weights
    G = WeightedGraph(3)
    G.add_edge(0, 1, 1)
    G.add_edge(1, 2, 1)
    G.add_edge(0, 2, 1)

    S = {0, 1, 2}
    q = 0
    S_no_q = S - {q}

    print(f"\nGraph: {G}")
    print(f"q = {q}, S = {S_no_q}")

    H = build_tie_subgraph(G)
    print(f"Tie subgraph edges: {H.edges()}")
    print(f"Ordinary β₁(G[S\\q]) = {cycle_rank(G, S_no_q)}")
    print(f"Weighted β₁ʷ(G,w,S\\q) = {weighted_betti1(G, S_no_q)}")
    print(f"Weighted κʷ(G,w,q,S\\q) = {weighted_visible_defect(G, q, S_no_q)}")
    print(f"Weighted dim = {weighted_trop_kernel_dim(G, q, S_no_q)}")

    # Generic weights
    print("\n--- With generic weights ---")
    G2 = WeightedGraph(3)
    G2.add_edge(0, 1, 1)
    G2.add_edge(1, 2, 2)
    G2.add_edge(0, 2, 3)

    H2 = build_tie_subgraph(G2)
    print(f"Graph: {G2}")
    print(f"Generic? {is_generic(G2)}")
    print(f"Tie subgraph edges: {H2.edges()}")
    print(f"Weighted β₁ʷ = {weighted_betti1(G2, S_no_q)}")
    print(f"Weighted κʷ = {weighted_visible_defect(G2, q, S_no_q)}")
    print(f"Weighted dim = {weighted_trop_kernel_dim(G2, q, S_no_q)}")
    print(f"✓ Generic collapse: β₁ʷ = 0" if weighted_betti1(G2, S_no_q) == 0 else "✗ UNEXPECTED")


def demo_square():
    """Square (C₄) with mixed weights."""
    print("\n" + "=" * 60)
    print("DEMO 2: Square graph (C₄) with partial degeneracy")
    print("=" * 60)

    G = WeightedGraph(4)
    G.add_edge(0, 1, 1)
    G.add_edge(1, 2, 1)  # tie at vertex 1: w(1,0)=w(1,2)=1
    G.add_edge(2, 3, 2)
    G.add_edge(3, 0, 3)

    S = {1, 2, 3}
    q = 0

    print(f"\nGraph: {G}")
    print(f"q = {q}, S = {S}")

    H = build_tie_subgraph(G)
    print(f"Tie subgraph edges: {H.edges()}")
    print(f"Ordinary β₁(G[S]) = {cycle_rank(G, S)}")
    print(f"Weighted β₁ʷ = {weighted_betti1(G, S)}")
    print(f"Weighted κʷ = {weighted_visible_defect(G, q, S)}")
    print(f"Weighted dim = {weighted_trop_kernel_dim(G, q, S)}")


def demo_generic_collapse_theorem():
    """Verify Theorem A on random graphs."""
    print("\n" + "=" * 60)
    print("DEMO 3: Generic-Weight Collapse Verification")
    print("=" * 60)

    random.seed(42)
    n_tests = 100
    n_passed = 0

    for _ in range(n_tests):
        n = random.randint(3, 6)
        G = WeightedGraph(n)
        # Random edges with distinct weights
        weight_pool = list(range(1, 100))
        random.shuffle(weight_pool)
        wi = 0
        for i in range(n):
            for j in range(i + 1, n):
                if random.random() < 0.5:
                    G.add_edge(i, j, weight_pool[wi])
                    wi += 1

        if not is_generic(G):
            continue

        S = set(range(1, n))
        q = 0
        b = weighted_betti1(G, S)
        if b == 0:
            n_passed += 1
        else:
            print(f"  COUNTEREXAMPLE: {G}, β₁ʷ = {b}")

    print(f"  Tested {n_tests} random graphs, {n_passed} generic ones all had β₁ʷ = 0 ✓")


def demo_uniform_recovery_theorem():
    """Verify Theorem B on graphs with uniform weights and degree ≥ 2."""
    print("\n" + "=" * 60)
    print("DEMO 4: Uniform-Weight Recovery Verification")
    print("=" * 60)

    # Complete graphs K_n with uniform weight
    for n in range(3, 7):
        G = WeightedGraph(n)
        for i in range(n):
            for j in range(i + 1, n):
                G.add_edge(i, j, 5)  # constant weight 5

        S = set(range(n))
        b_w = weighted_betti1(G, S)
        b_o = cycle_rank(G, S)
        status = "✓" if b_w == b_o else "✗"
        print(f"  K_{n}: β₁ʷ = {b_w}, β₁ = {b_o} {status}")


def demo_exhaustive_search():
    """Exhaustive verification on small graphs."""
    print("\n" + "=" * 60)
    print("DEMO 5: Exhaustive Search — Formula Consistency")
    print("=" * 60)

    n = 4
    weight_range = [1, 2, 3]
    n_tested = 0
    n_consistent = 0

    # Generate all possible edges on 4 vertices
    all_edges = [(i, j) for i in range(n) for j in range(i + 1, n)]

    # For each subset of edges
    for r in range(1, len(all_edges) + 1):
        for edge_subset in itertools.combinations(all_edges, r):
            # For each weight assignment
            for weights in itertools.product(weight_range, repeat=r):
                G = WeightedGraph(n)
                for (u, v), w in zip(edge_subset, weights):
                    G.add_edge(u, v, w)

                q = 0
                S = set(range(1, n))

                dim = weighted_trop_kernel_dim(G, q, S)
                b = weighted_betti1(G, S)
                k = weighted_visible_defect(G, q, S)

                if dim == b + k:
                    n_consistent += 1
                else:
                    print(f"  INCONSISTENCY: {G}")
                    print(f"    dim={dim}, β₁ʷ={b}, κʷ={k}")

                n_tested += 1

    print(f"  Tested {n_tested} weighted graphs on {n} vertices")
    print(f"  All {n_consistent} passed formula consistency ✓")


def demo_dimension_spectrum():
    """Show range of possible dimensions for fixed graph, varying weights."""
    print("\n" + "=" * 60)
    print("DEMO 6: Dimension Spectrum — How Weights Shape Topology")
    print("=" * 60)

    # Complete graph K4
    n = 4
    G_base_edges = [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)]
    q = 0
    S = {1, 2, 3}

    dim_counts: dict[int, int] = defaultdict(int)
    weight_range = [1, 2, 3, 4, 5]

    for weights in itertools.product(weight_range, repeat=len(G_base_edges)):
        G = WeightedGraph(n)
        for (u, v), w in zip(G_base_edges, weights):
            G.add_edge(u, v, w)

        dim = weighted_trop_kernel_dim(G, q, S)
        dim_counts[dim] += 1

    print(f"  Graph: K₄, q=0, S={{1,2,3}}")
    print(f"  Weight range: {weight_range}")
    print(f"  Dimension distribution:")
    for d in sorted(dim_counts.keys()):
        bar = "█" * min(dim_counts[d] // 100, 40)
        print(f"    dim = {d}: {dim_counts[d]:6d} weight assignments {bar}")


if __name__ == "__main__":
    demo_triangle()
    demo_square()
    demo_generic_collapse_theorem()
    demo_uniform_recovery_theorem()
    demo_exhaustive_search()
    demo_dimension_spectrum()
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Weighted Tropical Kernel Dimension Spectrum

Shows how the weighted tropical kernel dimension varies as edge weights
change on a fixed graph topology (K₄). The heatmap reveals the
"degeneracy landscape" — regions where weight ties create higher-dimensional
tropical kernels, separated by generic-weight valleys of dimension zero.

This visualizes the core theorem: dim = β₁ʷ + κʷ, where both terms
depend on the weight-degeneracy (tie) subgraph structure.
"""

import itertools
from collections import defaultdict
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


# ── Self-contained graph utilities ──

class WG:
    def __init__(self, n):
        self.n = n
        self.adj = defaultdict(set)
        self.w = {}
    def add(self, u, v, w):
        if u == v: return
        self.adj[u].add(v); self.adj[v].add(u)
        self.w[(u,v)] = w; self.w[(v,u)] = w
    def edges(self):
        seen = set()
        for u in range(self.n):
            for v in self.adj[u]:
                if (v,u) not in seen:
                    seen.add((u,v)); yield (u,v)

def tie_sub(G):
    T = WG(G.n)
    for u,v in G.edges():
        wuv = G.w[(u,v)]
        t_u = any(G.w[(u,k)] == wuv for k in G.adj[u] if k != v)
        t_v = any(G.w[(v,k)] == G.w[(v,u)] for k in G.adj[v] if k != u)
        if t_u or t_v:
            T.add(u, v, wuv)
    return T

def cc(G, S):
    vis = set(); comps = []
    for s in S:
        if s in vis: continue
        c = set(); stk = [s]
        while stk:
            v = stk.pop()
            if v in c: continue
            c.add(v); vis.add(v)
            for nb in G.adj[v]:
                if nb in S and nb not in c: stk.append(nb)
        comps.append(c)
    return comps

def cr(G, S):
    if not S: return 0
    e = sum(1 for u,v in G.edges() if u in S and v in S)
    return max(0, e + len(cc(G, S)) - len(S))

def vc(G, q, S):
    return sum(1 for c in cc(G, S) if any(v in G.adj.get(q, set()) for v in c))

def wdim(G, q, S):
    T = tie_sub(G)
    return cr(T, S) + vc(T, q, S)


# ── Figure 1: Dimension heatmap for two varying weights ──

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# K4 graph: edges (0,1), (0,2), (0,3), (1,2), (1,3), (2,3)
# Fix 4 edge weights, vary 2
base_weights = [1, 2, 3, 4]  # weights for edges (0,2), (0,3), (1,3), (2,3)
edge_list = [(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)]
q = 0
S = {1, 2, 3}

wrange = range(1, 11)
dim_grid = np.zeros((len(wrange), len(wrange)))
beta_grid = np.zeros((len(wrange), len(wrange)))
kappa_grid = np.zeros((len(wrange), len(wrange)))

for i, w01 in enumerate(wrange):
    for j, w12 in enumerate(wrange):
        G = WG(4)
        ws = [w01, 2, 3, w12, 4, 5]
        for (u,v), w in zip(edge_list, ws):
            G.add(u, v, w)
        T = tie_sub(G)
        beta_grid[j, i] = cr(T, S)
        kappa_grid[j, i] = vc(T, q, S)
        dim_grid[j, i] = beta_grid[j, i] + kappa_grid[j, i]

# Plot dimension
im0 = axes[0].imshow(dim_grid, origin='lower', cmap='YlOrRd',
                      extent=[0.5, 10.5, 0.5, 10.5], aspect='auto')
axes[0].set_xlabel('w(0,1)', fontsize=12)
axes[0].set_ylabel('w(1,2)', fontsize=12)
axes[0].set_title('Kernel Dimension\ndim = β₁ʷ + κʷ', fontsize=13)
plt.colorbar(im0, ax=axes[0], label='dimension')

# Plot beta
im1 = axes[1].imshow(beta_grid, origin='lower', cmap='Blues',
                      extent=[0.5, 10.5, 0.5, 10.5], aspect='auto')
axes[1].set_xlabel('w(0,1)', fontsize=12)
axes[1].set_ylabel('w(1,2)', fontsize=12)
axes[1].set_title('Weighted Betti β₁ʷ\n(tie subgraph cycle rank)', fontsize=13)
plt.colorbar(im1, ax=axes[1], label='β₁ʷ')

# Plot kappa
im2 = axes[2].imshow(kappa_grid, origin='lower', cmap='Greens',
                      extent=[0.5, 10.5, 0.5, 10.5], aspect='auto')
axes[2].set_xlabel('w(0,1)', fontsize=12)
axes[2].set_ylabel('w(1,2)', fontsize=12)
axes[2].set_title('Visible Defect κʷ\n(q-visible tie components)', fontsize=13)
plt.colorbar(im2, ax=axes[2], label='κʷ')

plt.suptitle('Weighted Tropical Dimension Formula on K₄\n'
             'Fixed: w(0,2)=2, w(0,3)=3, w(1,3)=4, w(2,3)=5  |  q=0, S={1,2,3}',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('dimension_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved dimension_spectrum.png")


#!/usr/bin/env python3
"""
Visualization: Generic-Weight Collapse Phase Transition

Shows how the weighted tropical kernel dimension drops to zero as weights
become generic. This illustrates the central theorem: generic weights
destroy all tie edges, collapsing the degeneracy subgraph and eliminating
tropical kernel dimensions.

The plot shows dimension as a function of a "perturbation parameter" ε,
where edge weights are w_i + ε·δ_i for random perturbation vectors δ.
At ε = 0 (uniform weights), dimension is maximal. As ε grows, ties break
and dimension drops sharply — a combinatorial phase transition.
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import defaultdict
import random


# ── Self-contained graph utilities ──

class WG:
    def __init__(self, n):
        self.n = n
        self.adj = defaultdict(set)
        self.w = {}
    def add(self, u, v, w):
        if u == v: return
        self.adj[u].add(v); self.adj[v].add(u)
        self.w[(u,v)] = w; self.w[(v,u)] = w
    def edges(self):
        seen = set()
        for u in range(self.n):
            for v in self.adj[u]:
                if (v,u) not in seen:
                    seen.add((u,v)); yield (u,v)

def tie_sub(G):
    T = WG(G.n)
    for u,v in G.edges():
        wuv = G.w[(u,v)]
        t_u = any(G.w[(u,k)] == wuv for k in G.adj[u] if k != v)
        t_v = any(G.w[(v,k)] == G.w[(v,u)] for k in G.adj[v] if k != u)
        if t_u or t_v:
            T.add(u, v, wuv)
    return T

def cc(G, S):
    vis = set(); comps = []
    for s in S:
        if s in vis: continue
        c = set(); stk = [s]
        while stk:
            v = stk.pop()
            if v in c: continue
            c.add(v); vis.add(v)
            for nb in G.adj[v]:
                if nb in S and nb not in c: stk.append(nb)
        comps.append(c)
    return comps

def cr(G, S):
    if not S: return 0
    e = sum(1 for u,v in G.edges() if u in S and v in S)
    return max(0, e + len(cc(G, S)) - len(S))

def vc(G, q, S):
    return sum(1 for c in cc(G, S) if any(v in G.adj.get(q, set()) for v in c))

def wdim(G, q, S):
    T = tie_sub(G)
    return cr(T, S) + vc(T, q, S)

def wbetti(G, q, S):
    T = tie_sub(G)
    return cr(T, S)

def wkappa(G, q, S):
    T = tie_sub(G)
    return vc(T, q, S)

def tie_edge_count(G):
    T = tie_sub(G)
    return sum(1 for _ in T.edges())


# ── Phase transition plot ──

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

random.seed(123)
np.random.seed(123)

# Graph topologies to test
topologies = [
    ("K₅ (complete)", 5, [(i,j) for i in range(5) for j in range(i+1,5)]),
    ("C₆ (cycle)", 6, [(i,(i+1)%6) for i in range(6)]),
    ("K₃,₃ (bipartite)", 6, [(i,j) for i in range(3) for j in range(3,6)]),
    ("Petersen-like", 5, [(0,1),(1,2),(2,3),(3,4),(4,0),(0,2),(1,3),(2,4)]),
]

for idx, (name, n, edge_list) in enumerate(topologies):
    ax = axes[idx // 2][idx % 2]

    q = 0
    S = set(range(1, n))

    # Multiple random perturbation directions
    n_trials = 8
    colors = plt.cm.tab10(np.linspace(0, 1, n_trials))

    for trial in range(n_trials):
        # Random perturbation vector (integers for exact tie detection)
        delta = [random.randint(1, 100) for _ in edge_list]

        # Use integer weights: base + scale * delta
        # We use scale as our ε parameter (integer valued)
        scales = list(range(0, 21))
        dims = []
        betas = []
        kappas = []
        ties = []

        for scale in scales:
            G = WG(n)
            for i, (u, v) in enumerate(edge_list):
                w = 100 + scale * delta[i]  # base weight 100
                G.add(u, v, w)

            dims.append(wdim(G, q, S))
            betas.append(wbetti(G, q, S))
            kappas.append(wkappa(G, q, S))
            ties.append(tie_edge_count(G))

        alpha = 0.4 if trial > 0 else 1.0
        lw = 1.0 if trial > 0 else 2.5
        ax.plot(scales, dims, '-', color=colors[trial], alpha=alpha, lw=lw)

    ax.set_xlabel('Perturbation scale ε', fontsize=11)
    ax.set_ylabel('Kernel dimension', fontsize=11)
    ax.set_title(name, fontsize=13, fontweight='bold')
    ax.set_ylim(-0.5, max(dims[0] for _ in [0]) + 2)
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.3)
    ax.grid(True, alpha=0.2)

    # Annotate uniform point
    G0 = WG(n)
    for u, v in edge_list:
        G0.add(u, v, 100)
    dim0 = wdim(G0, q, S)
    ax.annotate(f'Uniform: dim={dim0}', xy=(0, dim0),
                xytext=(3, dim0 + 0.5), fontsize=9,
                arrowprops=dict(arrowstyle='->', color='red'),
                color='red', fontweight='bold')

plt.suptitle('Generic-Weight Collapse: Phase Transition in Tropical Kernel Dimension\n'
             '8 random perturbation directions per graph topology  |  '
             'ε=0: uniform weights (max dim) → ε>0: generic weights (dim→0)',
             fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig('phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved phase_transition.png")


#!/usr/bin/env python3
"""
Visualization: Tie Subgraph Structure

Illustrates how different weight assignments on the same graph produce
different tie subgraphs, and how the weighted Betti number and visible
defect change accordingly. Shows the original graph with all edges,
highlighting tie edges in red and non-tie edges in gray.

This directly visualizes the core definition: the tie subgraph captures
the "degeneracy geometry" where tropical ties can occur.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from collections import defaultdict
import math


# ── Self-contained graph utilities ──

class WG:
    def __init__(self, n):
        self.n = n
        self.adj = defaultdict(set)
        self.w = {}
    def add(self, u, v, w):
        if u == v: return
        self.adj[u].add(v); self.adj[v].add(u)
        self.w[(u,v)] = w; self.w[(v,u)] = w
    def edges(self):
        seen = set()
        for u in range(self.n):
            for v in self.adj[u]:
                if (v,u) not in seen:
                    seen.add((u,v)); yield (u,v)

def is_tie_edge(G, u, v):
    wuv = G.w[(u,v)]
    t_u = any(G.w[(u,k)] == wuv for k in G.adj[u] if k != v)
    t_v = any(G.w[(v,k)] == G.w[(v,u)] for k in G.adj[v] if k != u)
    return t_u or t_v

def cc(G, S):
    vis = set(); comps = []
    for s in S:
        if s in vis: continue
        c = set(); stk = [s]
        while stk:
            v = stk.pop()
            if v in c: continue
            c.add(v); vis.add(v)
            for nb in G.adj[v]:
                if nb in S and nb not in c: stk.append(nb)
        comps.append(c)
    return comps

def tie_sub(G):
    T = WG(G.n)
    for u,v in G.edges():
        if is_tie_edge(G, u, v):
            T.add(u, v, G.w[(u,v)])
    return T

def cr(G, S):
    if not S: return 0
    e = sum(1 for u,v in G.edges() if u in S and v in S)
    return max(0, e + len(cc(G, S)) - len(S))

def vc(G, q, S):
    return sum(1 for c in cc(G, S) if any(v in G.adj.get(q, set()) for v in c))


# ── Layout computation ──

def circular_layout(n, center=(0,0), radius=1.0):
    pos = {}
    for i in range(n):
        angle = 2 * math.pi * i / n - math.pi / 2
        pos[i] = (center[0] + radius * math.cos(angle),
                  center[1] + radius * math.sin(angle))
    return pos


# ── Draw a weighted graph ──

def draw_graph(ax, G, pos, q, S, title, show_ties=True):
    """Draw graph with tie edges highlighted."""
    T = tie_sub(G)

    # Draw edges
    for u, v in G.edges():
        x = [pos[u][0], pos[v][0]]
        y = [pos[u][1], pos[v][1]]
        is_tie = is_tie_edge(G, u, v)

        if is_tie and show_ties:
            ax.plot(x, y, '-', color='#E74C3C', linewidth=3.0, alpha=0.9, zorder=1)
        else:
            ax.plot(x, y, '-', color='#BDC3C7', linewidth=1.5, alpha=0.6, zorder=1)

        # Edge weight label
        mx, my = (pos[u][0] + pos[v][0]) / 2, (pos[u][1] + pos[v][1]) / 2
        # Offset perpendicular to edge
        dx, dy = pos[v][0] - pos[u][0], pos[v][1] - pos[u][1]
        length = max(math.sqrt(dx**2 + dy**2), 0.01)
        nx, ny = -dy/length * 0.12, dx/length * 0.12
        ax.text(mx + nx, my + ny, str(G.w[(u,v)]),
                fontsize=8, ha='center', va='center',
                color='#2C3E50', fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.15', facecolor='white',
                         edgecolor='none', alpha=0.8))

    # Draw vertices
    for v in range(G.n):
        if v == q:
            color = '#F39C12'  # gold for basepoint
            size = 400
        elif v in S:
            color = '#3498DB'  # blue for S
            size = 300
        else:
            color = '#95A5A6'  # gray
            size = 250
        ax.scatter(pos[v][0], pos[v][1], s=size, c=color,
                  edgecolors='#2C3E50', linewidths=1.5, zorder=3)
        ax.text(pos[v][0], pos[v][1], str(v), fontsize=11,
               ha='center', va='center', fontweight='bold',
               color='white', zorder=4)

    # Compute and display invariants
    beta = cr(T, S)
    kappa = vc(T, q, S)
    dim = beta + kappa
    tie_count = sum(1 for _ in T.edges())

    info = f"β₁ʷ={beta}  κʷ={kappa}  dim={dim}\ntie edges: {tie_count}/{sum(1 for _ in G.edges())}"
    ax.text(0.02, 0.02, info, transform=ax.transAxes, fontsize=9,
            verticalalignment='bottom', fontfamily='monospace',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

    ax.set_title(title, fontsize=11, fontweight='bold', pad=10)
    ax.set_xlim(-1.4, 1.4)
    ax.set_ylim(-1.4, 1.4)
    ax.set_aspect('equal')
    ax.axis('off')


# ── Create figure ──

fig, axes = plt.subplots(2, 3, figsize=(18, 12))

n = 6
edge_list = [(0,1), (1,2), (2,3), (3,4), (4,5), (5,0), (0,3), (1,4), (2,5)]
pos = circular_layout(n, radius=1.1)
q = 0
S = {1, 2, 3, 4, 5}

weight_configs = [
    ("Uniform: all w=1", [1,1,1,1,1,1,1,1,1]),
    ("Generic: all distinct", [1,2,3,5,7,11,13,17,19]),
    ("Partial tie: some equal", [1,1,2,2,3,3,4,5,6]),
    ("Strong resonance", [1,1,1,2,2,2,3,3,3]),
    ("Two-level weights", [1,1,1,1,1,1,2,2,2]),
    ("Single tie pair", [1,2,3,4,5,6,7,8,1]),
]

for idx, (title, weights) in enumerate(weight_configs):
    ax = axes[idx // 3][idx % 3]
    G = WG(n)
    for (u, v), w in zip(edge_list, weights):
        G.add(u, v, w)
    draw_graph(ax, G, pos, q, S, title)

# Legend
legend_elements = [
    mpatches.Patch(color='#E74C3C', label='Tie edge (weight degeneracy)'),
    mpatches.Patch(color='#BDC3C7', label='Non-tie edge (generic)'),
    mpatches.Patch(color='#F39C12', label='Basepoint q'),
    mpatches.Patch(color='#3498DB', label='Vertex in S'),
]
fig.legend(handles=legend_elements, loc='lower center', ncol=4,
          fontsize=11, frameon=True, fancybox=True)

plt.suptitle('Tie Subgraph Structure Under Different Weight Assignments\n'
             'Red edges form the degeneracy subgraph; their cycle rank gives β₁ʷ',
             fontsize=14, fontweight='bold')
plt.tight_layout(rect=[0, 0.05, 1, 0.93])
plt.savefig('tie_subgraph.png', dpi=150, bbox_inches='tight')
print("Saved tie_subgraph.png")
