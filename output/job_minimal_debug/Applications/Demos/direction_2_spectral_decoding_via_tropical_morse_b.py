#!/usr/bin/env python3
"""
Applications of Tropical-Topological Decoding Theory

Demonstrates real-world applications of the barcode-weighted decoder:
1. Surface code quantum error correction
2. Network vulnerability analysis
3. Optimal routing with topological hazard avoidance
"""

import numpy as np
from collections import defaultdict
from typing import Dict, List, Set, Tuple
import heapq


# ─── Application 1: Surface Code QEC ────────────────────────────────────────

class SurfaceCodeDecoder:
    """
    Surface code decoder using tropical barcode vulnerability penalties.

    The surface code encodes logical qubits on a 2D lattice. Physical errors
    create syndrome defects that must be paired and corrected. The tropical
    decoder penalizes corrections that pass through edges with high barcode
    persistence, reducing the probability of logical errors.
    """

    def __init__(self, L: int, lam: float = 1.0):
        self.L = L
        self.lam = lam
        self.nodes = list(range(L * L))
        self.edges: List[Tuple[int, int]] = []
        self.base_weights: Dict[Tuple[int, int], float] = {}

        # Build grid
        for r in range(L):
            for c in range(L):
                idx = r * L + c
                if c + 1 < L:
                    e = (idx, idx + 1)
                    self.edges.append(e)
                    self.base_weights[e] = 1.0
                if r + 1 < L:
                    e = (idx, idx + L)
                    self.edges.append(e)
                    self.base_weights[e] = 1.0

        # Logical operators
        self.logical_x = {(c, c + 1) for c in range(L - 1)}
        self.logical_z = {(r * L, (r + 1) * L) for r in range(L - 1)}

        # Compute barcode
        self.vulnerability = self._compute_vulnerability()

    def _compute_vulnerability(self) -> Dict[Tuple[int, int], float]:
        """Compute edge vulnerabilities from tropical Morse barcode."""
        sorted_edges = sorted(self.edges, key=lambda e: self.base_weights[e])
        parent = {n: n for n in self.nodes}

        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x

        def union(x, y):
            rx, ry = find(x), find(y)
            if rx == ry:
                return False
            parent[ry] = rx
            return True

        vuln = {e: 0.0 for e in self.edges}
        for e in sorted_edges:
            u, v = e
            w = self.base_weights[e]
            if find(u) == find(v):
                # Cycle event - this edge has high persistence
                vuln[e] += w
                # Propagate to neighbors
                for e2 in self.edges:
                    if e2 != e and (u in e2 or v in e2):
                        vuln[e2] += w * 0.3
            else:
                union(u, v)
        return vuln

    def decode(self, syndrome: Set[int]) -> Set[Tuple[int, int]]:
        """Decode using barcode-weighted shortest paths."""
        if not syndrome:
            return set()

        adj: Dict[int, List[Tuple[int, float, Tuple[int, int]]]] = defaultdict(list)
        for e in self.edges:
            u, v = e
            cost = self.base_weights[e] + self.lam * self.vulnerability[e]
            adj[u].append((v, cost, e))
            adj[v].append((u, cost, e))

        remaining = set(syndrome)
        correction: Set[Tuple[int, int]] = set()

        while len(remaining) >= 2:
            best = None
            for s in remaining:
                dist = {s: 0.0}
                prev = {}
                pq = [(0.0, s)]
                while pq:
                    d, u = heapq.heappop(pq)
                    if d > dist.get(u, float('inf')):
                        continue
                    if u in remaining and u != s:
                        path = []
                        cur = u
                        while cur != s:
                            p, e = prev[cur]
                            path.append(e)
                            cur = p
                        if best is None or d < best[0]:
                            best = (d, s, u, path)
                        break
                    for v, cost, e in adj.get(u, []):
                        nd = d + cost
                        if nd < dist.get(v, float('inf')):
                            dist[v] = nd
                            prev[v] = (u, e)
                            heapq.heappush(pq, (nd, v))

            if best is None:
                break
            _, s1, s2, path = best
            correction.update(path)
            remaining.discard(s1)
            remaining.discard(s2)

        return correction

    def simulate(self, p: float, num_trials: int = 1000) -> float:
        """Simulate and return logical error rate."""
        logical_errors = 0
        for _ in range(num_trials):
            error = {e for e in self.edges if np.random.random() < p}
            syndrome = defaultdict(int)
            for e in error:
                syndrome[e[0]] ^= 1
                syndrome[e[1]] ^= 1
            syn_nodes = {n for n, s in syndrome.items() if s == 1}

            correction = self.decode(syn_nodes)
            residual = correction.symmetric_difference(error)
            for logical in [self.logical_x, self.logical_z]:
                if len(residual.intersection(logical)) % 2 == 1:
                    logical_errors += 1
                    break

        return logical_errors / num_trials


# ─── Application 2: Network Vulnerability Analysis ──────────────────────────

def network_vulnerability_analysis(
    nodes: List[int],
    edges: List[Tuple[int, int]],
    weights: Dict[Tuple[int, int], float],
    critical_paths: List[List[int]]
) -> Dict[str, object]:
    """
    Analyze network vulnerability using tropical barcode persistence.

    Identifies edges that participate in many persistent cycles,
    indicating structural redundancy or critical chokepoints.

    Returns vulnerability rankings and corridor identification.
    """
    # Compute barcode
    sorted_edges = sorted(edges, key=lambda e: weights[e])
    parent = {n: n for n in nodes}

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        rx, ry = find(x), find(y)
        if rx == ry:
            return False
        parent[ry] = rx
        return True

    vuln = {e: 0.0 for e in edges}
    cycle_edges = []

    for e in sorted_edges:
        u, v = e
        w = weights[e]
        if find(u) == find(v):
            vuln[e] += w
            cycle_edges.append(e)
        else:
            union(u, v)

    # Rank edges by vulnerability
    ranked = sorted(edges, key=lambda e: vuln[e], reverse=True)

    # Identify corridors at different thresholds
    max_vuln = max(vuln.values()) if vuln else 0
    corridors = {}
    for frac in [0.25, 0.5, 0.75]:
        tau = frac * max_vuln
        corridors[f"tau={frac:.0%}"] = [e for e in edges if vuln[e] >= tau]

    # Analyze critical path exposure
    path_exposure = {}
    for i, path in enumerate(critical_paths):
        path_edges = [(path[j], path[j+1]) for j in range(len(path)-1)]
        exposure = sum(vuln.get(e, vuln.get((e[1], e[0]), 0.0)) for e in path_edges)
        path_exposure[f"path_{i}"] = exposure

    return {
        "vulnerability": vuln,
        "ranked_edges": ranked[:10],
        "cycle_edges": cycle_edges,
        "corridors": corridors,
        "path_exposure": path_exposure,
        "total_persistence": sum(vuln.values()),
    }


# ─── Application 3: Topological Routing ──────────────────────────────────────

def topological_routing(
    nodes: List[int],
    edges: List[Tuple[int, int]],
    weights: Dict[Tuple[int, int], float],
    source: int,
    target: int,
    lam: float = 1.0
) -> Tuple[List[int], float, float]:
    """
    Find optimal route avoiding topological hazard zones.

    Uses barcode vulnerability as a hazard penalty. Routes that pass
    through persistent cycle regions are penalized, steering traffic
    toward topologically simpler paths.

    Returns: (path, total_cost, hazard_exposure)
    """
    # Compute vulnerability
    sorted_edges = sorted(edges, key=lambda e: weights[e])
    parent = {n: n for n in nodes}

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        rx, ry = find(x), find(y)
        if rx == ry:
            return False
        parent[ry] = rx
        return True

    vuln = {e: 0.0 for e in edges}
    for e in sorted_edges:
        u, v = e
        if find(u) == find(v):
            vuln[e] += weights[e]
        else:
            union(u, v)

    # Dijkstra with barcode-weighted costs
    adj = defaultdict(list)
    for e in edges:
        u, v = e
        cost = weights[e] + lam * vuln[e]
        adj[u].append((v, cost, e))
        adj[v].append((u, cost, e))

    dist = {source: 0.0}
    prev = {}
    pq = [(0.0, source)]

    while pq:
        d, u = heapq.heappop(pq)
        if d > dist.get(u, float('inf')):
            continue
        if u == target:
            break
        for v, cost, e in adj[u]:
            nd = d + cost
            if nd < dist.get(v, float('inf')):
                dist[v] = nd
                prev[v] = (u, e)
                heapq.heappush(pq, (nd, v))

    # Trace path
    if target not in prev and target != source:
        return [], float('inf'), 0.0

    path = [target]
    hazard = 0.0
    cur = target
    while cur != source:
        p, e = prev[cur]
        path.append(p)
        hazard += vuln.get(e, 0.0)
        cur = p
    path.reverse()

    return path, dist.get(target, float('inf')), hazard


# ─── Demo ────────────────────────────────────────────────────────────────────

def main():
    np.random.seed(42)

    print("=" * 60)
    print("Application 1: Surface Code QEC")
    print("=" * 60)

    for L in [3, 5]:
        decoder = SurfaceCodeDecoder(L, lam=0.5)
        print(f"\n{L}×{L} Surface Code:")
        for p in [0.01, 0.05]:
            rate = decoder.simulate(p, num_trials=200)
            print(f"  p={p:.2f}: logical error rate = {rate:.4f}")

    print("\n" + "=" * 60)
    print("Application 2: Network Vulnerability")
    print("=" * 60)

    # Small network example
    nodes = list(range(8))
    edges = [(0,1),(1,2),(2,3),(3,0),(0,4),(4,5),(5,6),(6,7),(7,4),(1,5),(2,6)]
    weights = {e: 1.0 + 0.5 * i for i, e in enumerate(edges)}

    analysis = network_vulnerability_analysis(
        nodes, edges, weights,
        critical_paths=[[0,1,2,3], [4,5,6,7]]
    )
    print(f"\nTotal persistence: {analysis['total_persistence']:.2f}")
    print(f"Cycle edges: {analysis['cycle_edges']}")
    print(f"Top vulnerable edges: {analysis['ranked_edges'][:5]}")
    for name, corridor in analysis['corridors'].items():
        print(f"  Corridor at {name}: {len(corridor)} edges")

    print("\n" + "=" * 60)
    print("Application 3: Topological Routing")
    print("=" * 60)

    path, cost, hazard = topological_routing(
        nodes, edges, weights, source=0, target=7, lam=1.0
    )
    print(f"\nOptimal route: {path}")
    print(f"Total cost: {cost:.2f}")
    print(f"Hazard exposure: {hazard:.2f}")

    path2, cost2, hazard2 = topological_routing(
        nodes, edges, weights, source=0, target=7, lam=0.0
    )
    print(f"\nShortest path (no penalty): {path2}")
    print(f"Total cost: {cost2:.2f}")
    print(f"Hazard exposure: {hazard2:.2f}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Tropical Barcode Decoder — Demonstration Script

Compares a tropical-barcode-weighted decoder against MWPM and union-find baselines
on surface codes of sizes 3×3, 5×5, 7×7 under depolarizing noise at p = 0.01, 0.05, 0.10.

The tropical decoder penalizes corrections that traverse edges with high barcode
vulnerability, using the scoring function:

    W(C) = base_weight(C) + λ · Σ_{e ∈ C} vulnerability(e)

where vulnerability(e) is the total persistence of barcode intervals assigned to e.
"""

import numpy as np
from collections import defaultdict
import heapq

# ─── Surface Code Graph ──────────────────────────────────────────────────────

def build_surface_code_graph(L):
    """
    Build an L×L surface code graph.

    Returns:
        nodes: list of node indices
        edges: list of (i, j) edges
        edge_weights: dict mapping (i,j) -> weight (initially 1.0)
        logical_x: set of edges forming a logical X operator (horizontal chain)
        logical_z: set of edges forming a logical Z operator (vertical chain)
    """
    num_qubits = 2 * L * L - 2 * L  # data qubits for toric-like surface code
    # Simplified: use a grid graph as the syndrome graph
    nodes = list(range(L * L))
    edges = []
    for r in range(L):
        for c in range(L):
            idx = r * L + c
            if c + 1 < L:
                edges.append((idx, idx + 1))
            if r + 1 < L:
                edges.append((idx, idx + L))

    edge_weights = {e: 1.0 for e in edges}

    # Logical operators: horizontal and vertical chains
    logical_x = set()
    for c in range(L - 1):
        logical_x.add((c, c + 1))

    logical_z = set()
    for r in range(L - 1):
        logical_z.add((r * L, (r + 1) * L))

    return nodes, edges, edge_weights, logical_x, logical_z


# ─── Tropical Morse Barcode Computation ──────────────────────────────────────

def compute_tropical_barcode(nodes, edges, edge_weights):
    """
    Compute a tropical Morse barcode via Kruskal-style filtration.

    Sorts edges by weight. Each edge either merges two components (merge event)
    or creates a cycle (cycle-death event). Returns barcode intervals.

    Returns:
        barcodes: list of (birth, death, edge, event_type)
        edge_intervals: dict mapping edge -> list of (birth, death)
    """
    sorted_edges = sorted(edges, key=lambda e: edge_weights[e])
    parent = {n: n for n in nodes}
    rank = {n: 0 for n in nodes}

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        rx, ry = find(x), find(y)
        if rx == ry:
            return False
        if rank[rx] < rank[ry]:
            rx, ry = ry, rx
        parent[ry] = rx
        if rank[rx] == rank[ry]:
            rank[rx] += 1
        return True

    barcodes = []
    component_birth = {n: 0.0 for n in nodes}
    edge_intervals = defaultdict(list)

    for edge in sorted_edges:
        w = edge_weights[edge]
        u, v = edge
        ru, rv = find(u), find(v)

        if ru != rv:
            # Merge event: a component dies
            birth = max(component_birth.get(ru, 0), component_birth.get(rv, 0))
            barcodes.append((birth, w, edge, 'merge'))
            union(u, v)
            new_root = find(u)
            component_birth[new_root] = 0.0
        else:
            # Cycle-death event: a cycle is born and immediately closed
            barcodes.append((0.0, w, edge, 'cycle'))
            edge_intervals[edge].append((0.0, w))

    # Distribute persistence to edges based on participation in cycles
    # Each cycle event gives persistence to the closing edge
    # Also propagate to nearby edges via neighborhood
    for birth, death, edge, etype in barcodes:
        if etype == 'cycle':
            edge_intervals[edge].append((birth, death))
            # Spread to adjacent edges
            u, v = edge
            for e in edges:
                if e != edge and (u in e or v in e):
                    edge_intervals[e].append((birth, death * 0.5))

    return barcodes, edge_intervals


def compute_edge_vulnerability(edge_intervals):
    """
    Compute vulnerability for each edge: sum of interval persistences.
    V(e) = Σ (death - birth) for all intervals assigned to e.
    """
    vulnerability = {}
    for edge, intervals in edge_intervals.items():
        vulnerability[edge] = sum(d - b for b, d in intervals)
    return vulnerability


# ─── Decoders ────────────────────────────────────────────────────────────────

def generate_error(edges, p):
    """Generate a random error pattern under depolarizing noise."""
    error = set()
    for e in edges:
        if np.random.random() < p:
            error.add(e)
    return error


def compute_syndrome(edges, error, L):
    """Compute syndrome: parity of errors incident to each node."""
    syndrome = defaultdict(int)
    for e in error:
        u, v = e
        syndrome[u] ^= 1
        syndrome[v] ^= 1
    return {n: s for n, s in syndrome.items() if s == 1}


def dijkstra_decode(nodes, edges, edge_costs, syndrome_nodes, L):
    """
    Simple shortest-path decoder: find minimum-cost correction
    connecting syndrome nodes (greedy pairing + shortest paths).
    """
    if len(syndrome_nodes) == 0:
        return set()
    if len(syndrome_nodes) % 2 == 1:
        # Add boundary node
        syndrome_nodes = list(syndrome_nodes) + [-1]

    # Build adjacency
    adj = defaultdict(list)
    for e in edges:
        u, v = e
        w = edge_costs.get(e, edge_costs.get((v, u), 1.0))
        adj[u].append((v, w, e))
        adj[v].append((u, w, e))

    # Greedy matching of syndrome nodes
    syndrome_list = list(syndrome_nodes)
    correction = set()
    matched = set()

    for i in range(len(syndrome_list)):
        if i in matched:
            continue
        src = syndrome_list[i]
        if src == -1:
            continue

        # Dijkstra from src to nearest unmatched syndrome node
        dist = {src: 0}
        prev = {}
        pq = [(0, src)]
        target = None

        while pq:
            d, u = heapq.heappop(pq)
            if d > dist.get(u, float('inf')):
                continue
            if u != src and u in syndrome_nodes and syndrome_list.index(u) not in matched:
                target = u
                break
            for v, w, e in adj.get(u, []):
                nd = d + w
                if nd < dist.get(v, float('inf')):
                    dist[v] = nd
                    prev[v] = (u, e)
                    heapq.heappush(pq, (nd, v))

        if target is not None:
            j = syndrome_list.index(target)
            matched.add(i)
            matched.add(j)
            # Trace path
            cur = target
            while cur != src:
                p, e = prev[cur]
                correction.add(e)
                cur = p

    return correction


def tropical_decode(nodes, edges, edge_weights, vulnerability, syndrome_nodes, L, lam=1.0):
    """Tropical barcode decoder: uses barcode-weighted edge costs."""
    edge_costs = {}
    for e in edges:
        base = edge_weights.get(e, 1.0)
        vuln = vulnerability.get(e, 0.0)
        edge_costs[e] = base + lam * vuln
    return dijkstra_decode(nodes, edges, edge_costs, syndrome_nodes, L)


def mwpm_decode(nodes, edges, edge_weights, syndrome_nodes, L):
    """MWPM-style decoder (greedy approximation)."""
    return dijkstra_decode(nodes, edges, edge_weights, syndrome_nodes, L)


def union_find_decode(nodes, edges, edge_weights, syndrome_nodes, L):
    """Union-find decoder (simplified: greedy edge addition)."""
    if len(syndrome_nodes) == 0:
        return set()

    sorted_edges = sorted(edges, key=lambda e: edge_weights.get(e, 1.0))
    parent = {n: n for n in nodes}

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        rx, ry = find(x), find(y)
        if rx == ry:
            return False
        parent[ry] = rx
        return True

    correction = set()
    remaining = set(syndrome_nodes)

    for e in sorted_edges:
        if len(remaining) <= 1:
            break
        u, v = e
        ru, rv = find(u), find(v)
        if ru != rv:
            # Check if merging would connect two syndrome nodes
            if u in remaining or v in remaining:
                correction.add(e)
                union(u, v)
                # Check if we paired two syndrome nodes
                paired = set()
                for s in remaining:
                    if find(s) == find(u):
                        paired.add(s)
                if len(paired) >= 2:
                    remaining -= paired

    return correction


def check_logical_error(correction, error, logical_ops):
    """
    Check if correction + error forms a logical operator.
    A logical error occurs if the symmetric difference of correction and error
    has odd overlap with a logical operator.
    """
    residual = correction.symmetric_difference(error)
    for logical in logical_ops:
        overlap = len(residual.intersection(logical))
        if overlap % 2 == 1:
            return True
    return False


# ─── Main Experiment ─────────────────────────────────────────────────────────

def run_experiment(L, p, num_trials=1000, lam=1.0):
    """Run decoding experiment for a given code size and noise rate."""
    nodes, edges, edge_weights, logical_x, logical_z = build_surface_code_graph(L)
    logical_ops = [logical_x, logical_z]

    # Compute tropical barcode
    barcodes, edge_intervals = compute_tropical_barcode(nodes, edges, edge_weights)
    vulnerability = compute_edge_vulnerability(edge_intervals)

    results = {'tropical': 0, 'mwpm': 0, 'union_find': 0}

    for _ in range(num_trials):
        error = generate_error(edges, p)
        syndrome = compute_syndrome(edges, error, L)
        syndrome_nodes = set(syndrome.keys())

        # Tropical decoder
        corr_trop = tropical_decode(nodes, edges, edge_weights, vulnerability,
                                     syndrome_nodes, L, lam)
        if check_logical_error(corr_trop, error, logical_ops):
            results['tropical'] += 1

        # MWPM decoder
        corr_mwpm = mwpm_decode(nodes, edges, edge_weights, syndrome_nodes, L)
        if check_logical_error(corr_mwpm, error, logical_ops):
            results['mwpm'] += 1

        # Union-find decoder
        corr_uf = union_find_decode(nodes, edges, edge_weights, syndrome_nodes, L)
        if check_logical_error(corr_uf, error, logical_ops):
            results['union_find'] += 1

    return {k: v / num_trials for k, v in results.items()}


def main():
    print("=" * 72)
    print("Tropical Barcode Decoder — Experimental Comparison")
    print("=" * 72)
    print()
    print("Comparing three decoders on surface code syndrome graphs:")
    print("  1. Tropical Barcode Decoder (barcode-weighted shortest path)")
    print("  2. MWPM Decoder (minimum weight perfect matching approximation)")
    print("  3. Union-Find Decoder (greedy cluster growth)")
    print()

    sizes = [3, 5, 7]
    noise_rates = [0.01, 0.05, 0.10]
    num_trials = 500
    lam = 0.5  # Penalty parameter

    print(f"{'Size':>6} {'p':>6} {'Tropical':>10} {'MWPM':>10} {'Union-Find':>12}")
    print("-" * 50)

    for L in sizes:
        for p in noise_rates:
            results = run_experiment(L, p, num_trials=num_trials, lam=lam)
            print(f"{L}x{L:>3} {p:>6.2f} {results['tropical']:>10.4f} "
                  f"{results['mwpm']:>10.4f} {results['union_find']:>12.4f}")
        print()

    print("=" * 72)
    print("Interpretation:")
    print("  Lower logical error rate is better.")
    print("  The tropical decoder uses barcode-derived vulnerability penalties")
    print("  to steer corrections away from logical error corridors.")
    print()
    print("  The conjecture predicts that for sufficiently large codes and")
    print("  moderate noise, the tropical decoder should match or outperform")
    print("  both baselines at appropriate penalty calibration λ.")
    print("=" * 72)

    # Additional: Show barcode data for 3x3
    print("\n--- Barcode Data for 3×3 Surface Code ---")
    nodes, edges, edge_weights, _, _ = build_surface_code_graph(3)
    barcodes, edge_intervals = compute_tropical_barcode(nodes, edges, edge_weights)
    vulnerability = compute_edge_vulnerability(edge_intervals)

    print(f"\nNumber of barcode intervals: {len(barcodes)}")
    print(f"  Merge events: {sum(1 for b in barcodes if b[3] == 'merge')}")
    print(f"  Cycle events: {sum(1 for b in barcodes if b[3] == 'cycle')}")

    print("\nEdge vulnerabilities:")
    for e in sorted(edges):
        v = vulnerability.get(e, 0.0)
        if v > 0:
            print(f"  Edge {e}: vulnerability = {v:.3f}")


if __name__ == "__main__":
    np.random.seed(42)
    main()


#!/usr/bin/env python3
"""
Visualization: Tropical Morse Barcode Persistence Diagram

Shows the persistence barcode from a tropical Morse filtration on a surface code
graph. Each horizontal bar represents a topological feature (connected component
or cycle) that is born at one weight threshold and dies at another. Longer bars
indicate more persistent features — these drive higher edge vulnerability and
define logical corridors.

This visualization makes the key mathematical object tangible: the barcode is the
topological memory of the weight filtration, and its geometry guides decoding.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def compute_barcode(L, seed=42):
    """Compute tropical Morse barcode for L×L grid with random weights."""
    np.random.seed(seed)
    nodes = list(range(L * L))
    edges = []
    weights = {}

    for r in range(L):
        for c in range(L):
            idx = r * L + c
            if c + 1 < L:
                e = (idx, idx + 1)
                edges.append(e)
                weights[e] = np.random.exponential(1.0)
            if r + 1 < L:
                e = (idx, idx + L)
                edges.append(e)
                weights[e] = np.random.exponential(1.0)

    sorted_edges = sorted(edges, key=lambda e: weights[e])
    parent = {n: n for n in nodes}
    rank_uf = {n: 0 for n in nodes}
    component_birth = {n: 0.0 for n in nodes}

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        rx, ry = find(x), find(y)
        if rx == ry:
            return False, rx
        if rank_uf[rx] < rank_uf[ry]:
            rx, ry = ry, rx
        parent[ry] = rx
        if rank_uf[rx] == rank_uf[ry]:
            rank_uf[rx] += 1
        return True, rx

    h0_bars = []  # Connected component bars (birth, death)
    h1_bars = []  # Cycle bars (birth, death)
    events = []

    for e in sorted_edges:
        u, v = e
        w = weights[e]
        ru, rv = find(u), find(v)

        if ru != rv:
            # Merge: younger component dies
            birth_u = component_birth.get(ru, 0.0)
            birth_v = component_birth.get(rv, 0.0)
            dying_birth = max(birth_u, birth_v)
            h0_bars.append((dying_birth, w))
            merged, new_root = union(u, v)
            component_birth[new_root] = min(birth_u, birth_v)
            events.append(('merge', w, e))
        else:
            # Cycle birth
            h1_bars.append((0.0, w))
            events.append(('cycle', w, e))

    return h0_bars, h1_bars, events, edges, weights


fig, axes = plt.subplots(2, 3, figsize=(15, 9))

for col, L in enumerate([3, 5, 7]):
    h0_bars, h1_bars, events, edges, weights = compute_barcode(L)

    # Top row: Barcode diagram
    ax = axes[0, col]
    y = 0
    # H0 bars
    for birth, death in sorted(h0_bars, key=lambda x: x[0]):
        ax.barh(y, death - birth, left=birth, height=0.7,
                color='steelblue', alpha=0.7, edgecolor='navy', linewidth=0.5)
        y += 1

    h0_count = y
    # H1 bars
    for birth, death in sorted(h1_bars, key=lambda x: -x[1]):
        ax.barh(y, death - birth, left=birth, height=0.7,
                color='crimson', alpha=0.7, edgecolor='darkred', linewidth=0.5)
        y += 1

    ax.axhline(h0_count - 0.5, color='gray', linestyle='--', linewidth=0.5)
    ax.set_xlabel('Weight Threshold', fontsize=10)
    ax.set_ylabel('Feature Index', fontsize=10)
    ax.set_title(f'{L}×{L} Grid — Persistence Barcode', fontsize=11, fontweight='bold')

    # Add labels
    if col == 0:
        mid_h0 = h0_count / 2
        mid_h1 = h0_count + len(h1_bars) / 2
        ax.text(-0.15, mid_h0, 'H₀', transform=ax.get_yaxis_transform(),
                fontsize=10, fontweight='bold', color='steelblue', va='center')
        ax.text(-0.15, mid_h1, 'H₁', transform=ax.get_yaxis_transform(),
                fontsize=10, fontweight='bold', color='crimson', va='center')

    # Bottom row: Persistence diagram (birth vs death)
    ax = axes[1, col]

    if h0_bars:
        births_h0, deaths_h0 = zip(*h0_bars)
        ax.scatter(births_h0, deaths_h0, c='steelblue', s=30, alpha=0.7,
                   label='H₀ (components)', zorder=3)

    if h1_bars:
        births_h1, deaths_h1 = zip(*h1_bars)
        ax.scatter(births_h1, deaths_h1, c='crimson', s=30, alpha=0.7,
                   marker='^', label='H₁ (cycles)', zorder=3)

    # Diagonal
    max_val = max(max(d for _, d in h0_bars + h1_bars), 0.1)
    ax.plot([0, max_val * 1.1], [0, max_val * 1.1], 'k--', linewidth=0.5, alpha=0.3)
    ax.set_xlabel('Birth', fontsize=10)
    ax.set_ylabel('Death', fontsize=10)
    ax.set_title(f'{L}×{L} Grid — Persistence Diagram', fontsize=11, fontweight='bold')
    ax.legend(fontsize=8, loc='lower right')
    ax.set_aspect('equal')

fig.suptitle('Tropical Morse Filtration: Persistence Barcodes and Diagrams',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_barcode_persistence.png', dpi=150, bbox_inches='tight')
print("Saved viz_barcode_persistence.png")


#!/usr/bin/env python3
"""
Visualization: Barcode Vulnerability Heatmap on Surface Code Grid

Visualizes the edge vulnerability profile derived from tropical Morse barcodes
on a surface code syndrome graph. Edges with higher vulnerability (more persistent
cycle participation) are shown in warmer colors, highlighting the logical corridors
that the tropical decoder penalizes.

This directly illustrates the core concept: persistent topological features in the
weight filtration reveal structural vulnerabilities that guide decoding decisions.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
from collections import defaultdict


def compute_vulnerability(L):
    """Compute edge vulnerability for an L×L grid via Kruskal filtration."""
    nodes = list(range(L * L))
    edges = []
    weights = {}

    np.random.seed(42)
    for r in range(L):
        for c in range(L):
            idx = r * L + c
            if c + 1 < L:
                e = (idx, idx + 1)
                edges.append(e)
                weights[e] = 1.0 + 0.3 * np.random.randn()
            if r + 1 < L:
                e = (idx, idx + L)
                edges.append(e)
                weights[e] = 1.0 + 0.3 * np.random.randn()

    # Kruskal filtration
    sorted_edges = sorted(edges, key=lambda e: weights[e])
    parent = {n: n for n in nodes}

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        rx, ry = find(x), find(y)
        if rx == ry:
            return False
        parent[ry] = rx
        return True

    vuln = {e: 0.0 for e in edges}
    for e in sorted_edges:
        u, v = e
        w = weights[e]
        if find(u) == find(v):
            vuln[e] += w
            for e2 in edges:
                if e2 != e and (u in e2 or v in e2):
                    vuln[e2] += w * 0.3
        else:
            union(u, v)

    return nodes, edges, weights, vuln


def plot_vulnerability_heatmap(L, ax, title):
    """Plot vulnerability heatmap for L×L grid."""
    nodes, edges, weights, vuln = compute_vulnerability(L)

    max_v = max(vuln.values()) if vuln.values() else 1.0
    cmap = plt.cm.YlOrRd

    # Draw edges
    for e in edges:
        u, v = e
        r1, c1 = divmod(u, L)
        r2, c2 = divmod(v, L)
        v_norm = vuln[e] / max_v if max_v > 0 else 0
        color = cmap(v_norm)
        lw = 1 + 4 * v_norm
        ax.plot([c1, c2], [L-1-r1, L-1-r2], color=color, linewidth=lw, solid_capstyle='round')

    # Draw nodes
    for n in nodes:
        r, c = divmod(n, L)
        ax.plot(c, L-1-r, 'ko', markersize=6, zorder=5)

    ax.set_xlim(-0.5, L - 0.5)
    ax.set_ylim(-0.5, L - 0.5)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.axis('off')


fig, axes = plt.subplots(1, 3, figsize=(15, 5))

for i, L in enumerate([3, 5, 7]):
    plot_vulnerability_heatmap(L, axes[i], f'{L}×{L} Surface Code\nEdge Vulnerability')

# Colorbar
sm = plt.cm.ScalarMappable(cmap=plt.cm.YlOrRd, norm=mcolors.Normalize(0, 1))
sm.set_array([])
cbar = fig.colorbar(sm, ax=axes, shrink=0.6, pad=0.02)
cbar.set_label('Normalized Vulnerability', fontsize=11)

fig.suptitle('Tropical Morse Barcode: Edge Vulnerability Profile',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_barcode_vulnerability.png', dpi=150, bbox_inches='tight')
print("Saved viz_barcode_vulnerability.png")


#!/usr/bin/env python3
"""
Visualization: Free-Energy Landscape for Barcode-Weighted Decoding

Illustrates the zero-temperature selection principle: the free-energy functional
F(C) = E(C) + λ·Φ(C) creates a landscape where corrections with low base weight
AND low vulnerability are preferred. As λ increases, high-vulnerability corrections
become increasingly penalized, steering the decoder away from logical corridors.

This visualizes the cross-domain connection between statistical mechanics and
quantum error correction: decoding as free-energy minimization.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def free_energy(energy, entropy, lam):
    """F = E + λ·Φ"""
    return energy + lam * entropy


# Generate correction candidates
np.random.seed(123)
n_corrections = 50
energies = np.random.exponential(2.0, n_corrections)
entropies = np.random.exponential(1.5, n_corrections)

# Mark some as "logical corridor" corrections (high entropy)
logical_mask = entropies > np.percentile(entropies, 75)

fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# Panel 1: Energy vs Entropy scatter
ax = axes[0, 0]
ax.scatter(energies[~logical_mask], entropies[~logical_mask],
           c='steelblue', alpha=0.7, s=40, label='Benign corrections')
ax.scatter(energies[logical_mask], entropies[logical_mask],
           c='crimson', alpha=0.7, s=40, marker='^', label='Logical corridor')
ax.set_xlabel('Base Weight E(C)', fontsize=11)
ax.set_ylabel('Vulnerability Φ(C)', fontsize=11)
ax.set_title('Correction Candidates', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)

# Panel 2: Free energy at different λ
ax = axes[0, 1]
lambdas = [0, 0.5, 1.0, 2.0]
colors = ['gray', 'steelblue', 'orange', 'crimson']
for lam, color in zip(lambdas, colors):
    F = free_energy(energies, entropies, lam)
    sorted_idx = np.argsort(F)
    ax.plot(range(n_corrections), F[sorted_idx], '-o', color=color,
            markersize=3, label=f'λ = {lam}', alpha=0.8)
ax.set_xlabel('Correction Index (sorted)', fontsize=11)
ax.set_ylabel('Free Energy F(C)', fontsize=11)
ax.set_title('Free Energy at Different λ', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)

# Panel 3: Winner changes with λ
ax = axes[1, 0]
lam_range = np.linspace(0, 3, 100)
winner_energy = []
winner_entropy = []
winner_is_logical = []

for lam in lam_range:
    F = free_energy(energies, entropies, lam)
    best = np.argmin(F)
    winner_energy.append(energies[best])
    winner_entropy.append(entropies[best])
    winner_is_logical.append(logical_mask[best])

ax.plot(lam_range, winner_energy, 'b-', linewidth=2, label='Winner E(C)')
ax.plot(lam_range, winner_entropy, 'r--', linewidth=2, label='Winner Φ(C)')
ax.fill_between(lam_range, 0, max(max(winner_energy), max(winner_entropy)),
                where=winner_is_logical, alpha=0.15, color='red',
                label='Winner in corridor')
ax.set_xlabel('Penalty Parameter λ', fontsize=11)
ax.set_ylabel('Winner Properties', fontsize=11)
ax.set_title('Optimal Correction vs λ', fontsize=12, fontweight='bold')
ax.legend(fontsize=9)

# Panel 4: Separation theorem illustration
ax = axes[1, 1]
E1, E2 = 3.0, 4.0
Phi1, Phi2 = 2.0, 0.5
lam_range2 = np.linspace(0, 5, 200)
F1 = E1 + lam_range2 * Phi1
F2 = E2 + lam_range2 * Phi2

ax.plot(lam_range2, F1, 'b-', linewidth=2.5, label=f'C₁: E={E1}, Φ={Phi1} (corridor)')
ax.plot(lam_range2, F2, 'g-', linewidth=2.5, label=f'C₂: E={E2}, Φ={Phi2} (benign)')

# Find crossing point
lam_cross = (E2 - E1) / (Phi1 - Phi2) if Phi1 != Phi2 else 0
F_cross = E1 + lam_cross * Phi1
ax.plot(lam_cross, F_cross, 'ro', markersize=10, zorder=5)
ax.annotate(f'Separation at λ={lam_cross:.1f}',
            xy=(lam_cross, F_cross), xytext=(lam_cross + 0.5, F_cross + 1),
            fontsize=9, arrowprops=dict(arrowstyle='->', color='red'),
            color='red', fontweight='bold')

ax.fill_between(lam_range2, F1, F2, where=F2 < F1, alpha=0.15, color='green',
                label='Benign wins')
ax.fill_between(lam_range2, F1, F2, where=F1 < F2, alpha=0.15, color='blue',
                label='Corridor wins')

ax.set_xlabel('Penalty Parameter λ', fontsize=11)
ax.set_ylabel('Free Energy F(C)', fontsize=11)
ax.set_title('Spectral Gap Separation Theorem', fontsize=12, fontweight='bold')
ax.legend(fontsize=9, loc='upper left')

fig.suptitle('Free-Energy Landscape for Tropical Barcode Decoding',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_free_energy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_free_energy_landscape.png")
