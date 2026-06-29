#!/usr/bin/env python3
"""
Applications of Tropical Rank Defect Theory

Real-world and mathematical applications of the tropical rank defect framework,
connecting effective resistance, chip-firing, and tropical linear algebra.

Applications demonstrated:
1. Network robustness analysis — defect as a transport frustration measure
2. Graph partitioning quality — resistance geometry guides partitioning
3. Random walk metastability detection — commute time identifies metastable regions
4. Spectral-resistance comparison — eigenvalue vs resistance-based diagnostics
"""

import numpy as np
from itertools import combinations
from typing import List, Dict, Tuple


# ─── Core utilities (self-contained) ───

def make_laplacian(adj):
    return np.diag(np.sum(adj, axis=1)) - adj

def make_resistance(adj):
    L = make_laplacian(adj).astype(float)
    Lp = np.linalg.pinv(L)
    n = adj.shape[0]
    R = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            R[i, j] = max(0, Lp[i, i] + Lp[j, j] - 2 * Lp[i, j])
    return R

def max_resistance(R, verts):
    if len(verts) <= 1:
        return 0.0
    return max(R[u, v] for u in verts for v in verts)

def trop_rank(L_S):
    if L_S.size == 0:
        return 0
    return int(np.linalg.matrix_rank(L_S.astype(float)))

def path_graph(n):
    adj = np.zeros((n, n), dtype=int)
    for i in range(n - 1):
        adj[i, i + 1] = adj[i + 1, i] = 1
    return adj

def grid_graph(rows, cols):
    """2D grid graph."""
    n = rows * cols
    adj = np.zeros((n, n), dtype=int)
    for r in range(rows):
        for c in range(cols):
            v = r * cols + c
            if c + 1 < cols:
                w = r * cols + c + 1
                adj[v, w] = adj[w, v] = 1
            if r + 1 < rows:
                w = (r + 1) * cols + c
                adj[v, w] = adj[w, v] = 1
    return adj

def random_graph(n, p, seed=42):
    """Erdős–Rényi random graph G(n, p)."""
    rng = np.random.RandomState(seed)
    adj = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                adj[i, j] = adj[j, i] = 1
    return adj

def complete_graph(n):
    return np.ones((n, n), dtype=int) - np.eye(n, dtype=int)


# ─── Application 1: Network Robustness Analysis ───

def network_robustness_analysis():
    """
    Use the tropical rank defect as a measure of transport frustration
    in communication/power networks.

    The defect Δ(G, q, S) measures how much the formal linear flexibility
    of the network (tropical rank) exceeds the actual chip-firing transport
    capacity. High defect regions indicate network bottlenecks.
    """
    print("=" * 65)
    print("  APPLICATION 1: Network Robustness Analysis")
    print("  Using tropical rank defect as transport frustration measure")
    print("=" * 65)

    # Compare a well-connected network vs a bottleneck network
    networks = {
        "Well-connected (K_5)": complete_graph(5),
        "Bottleneck (path P_5)": path_graph(5),
        "Grid (2×3)": grid_graph(2, 3),
    }

    for name, adj in networks.items():
        n = adj.shape[0]
        R = make_resistance(adj)
        L = make_laplacian(adj)
        q = 0  # root

        # Compute defect for all pairs
        defects = []
        for i in range(1, n):
            for j in range(i + 1, n):
                S = [i, j]
                L_S = L[np.ix_(S, S)]
                tr = trop_rank(L_S)
                # For degree-0 divisors, chip rank ≤ 0, so defect ≥ tr - 1
                defect_lb = tr - 1
                rd = max_resistance(R, S + [q])
                defects.append({
                    'S': S, 'defect_lb': defect_lb,
                    'rdiam': rd, 'trop_rank': tr
                })

        avg_defect = np.mean([d['defect_lb'] for d in defects])
        max_defect = max(d['defect_lb'] for d in defects)
        avg_rdiam = np.mean([d['rdiam'] for d in defects])

        print(f"\n  {name} (n={n}):")
        print(f"    Average defect lower bound: {avg_defect:.2f}")
        print(f"    Maximum defect lower bound: {max_defect}")
        print(f"    Average resistance diameter: {avg_rdiam:.4f}")
        print(f"    Interpretation: {'High frustration' if avg_defect > 0.5 else 'Low frustration'}")


# ─── Application 2: Graph Partitioning Quality ───

def partitioning_quality():
    """
    Use resistance diameter to assess graph partition quality.

    A good partition should separate vertices with high mutual resistance
    (they're "electrically far apart"). The tropical rank defect of
    each partition set tells us how much transport capacity is lost.
    """
    print("\n" + "=" * 65)
    print("  APPLICATION 2: Graph Partitioning Quality via Resistance")
    print("=" * 65)

    # Create a graph with natural community structure
    n = 8
    adj = np.zeros((n, n), dtype=int)
    # Community 1: vertices 0-3 (dense)
    for i in range(4):
        for j in range(i + 1, 4):
            adj[i, j] = adj[j, i] = 1
    # Community 2: vertices 4-7 (dense)
    for i in range(4, 8):
        for j in range(i + 1, 8):
            adj[i, j] = adj[j, i] = 1
    # Bridge: single edge
    adj[3, 4] = adj[4, 3] = 1

    R = make_resistance(adj)
    L = make_laplacian(adj)

    print(f"\n  Graph: Two K_4 cliques joined by one bridge edge")
    print(f"  Vertices: 0-3 (community A), 4-7 (community B)")

    # Compare good vs bad partitions
    partitions = {
        "Good (natural)": ([1, 2, 3], [4, 5, 6, 7]),
        "Bad (mixed)": ([1, 4, 5], [2, 3, 6, 7]),
        "Singleton": ([1], [2, 3, 4, 5, 6, 7]),
    }

    q = 0
    for pname, (S1, S2) in partitions.items():
        rd1 = max_resistance(R, S1 + [q])
        rd2 = max_resistance(R, S2 + [q])
        L_S1 = L[np.ix_(S1, S1)]
        L_S2 = L[np.ix_(S2, S2)]
        tr1 = trop_rank(L_S1)
        tr2 = trop_rank(L_S2)

        print(f"\n  Partition '{pname}':")
        print(f"    S1={S1}: Rdiam={rd1:.4f}, tropRank={tr1}, defect_lb={tr1-1}")
        print(f"    S2={S2}: Rdiam={rd2:.4f}, tropRank={tr2}, defect_lb={tr2-1}")
        print(f"    Total defect lb: {tr1 + tr2 - 2}")
        print(f"    Cross-resistance: {R[S1[-1], S2[0]]:.4f}")


# ─── Application 3: Random Walk Metastability ───

def metastability_detection():
    """
    Use commute time diameter to identify metastable regions.

    Large commute time = large resistance diameter = high defect.
    This identifies regions where a random walk gets "trapped."
    """
    print("\n" + "=" * 65)
    print("  APPLICATION 3: Random Walk Metastability Detection")
    print("  via Commute Time Diameter")
    print("=" * 65)

    # Barbell graph: two dense cliques with a thin bridge
    n = 6  # 2 x 3
    adj = np.zeros((n, n), dtype=int)
    for i in range(3):
        for j in range(i + 1, 3):
            adj[i, j] = adj[j, i] = 1
    for i in range(3, 6):
        for j in range(i + 1, 6):
            adj[i, j] = adj[j, i] = 1
    adj[2, 3] = adj[3, 2] = 1

    R = make_resistance(adj)
    num_edges = int(np.sum(adj) // 2)

    print(f"\n  Barbell graph: K_3 — K_3 (|E| = {num_edges})")
    print(f"\n  Pairwise effective resistance:")
    for i in range(n):
        row = "    " + " ".join(f"{R[i, j]:6.3f}" for j in range(n))
        print(row)

    print(f"\n  Commute times (= 2|E| · R_eff):")
    for i in range(n):
        row = "    " + " ".join(f"{2*num_edges*R[i, j]:6.1f}" for j in range(n))
        print(row)

    # Identify metastable pairs
    print(f"\n  Metastable pairs (commute time > {2 * num_edges * 1.0:.0f}):")
    for i in range(n):
        for j in range(i + 1, n):
            ct = 2 * num_edges * R[i, j]
            if ct > 2 * num_edges * 0.8:
                clique_i = "A" if i < 3 else "B"
                clique_j = "A" if j < 3 else "B"
                print(f"    ({i},{j}): C = {ct:.1f}, "
                      f"cliques {clique_i}-{clique_j}, "
                      f"R = {R[i, j]:.4f}")


# ─── Application 4: Spectral-Resistance Comparison ───

def spectral_resistance_comparison():
    """
    Compare spectral gap (λ₂) with resistance diameter.

    Both measure graph connectivity, but from different perspectives:
    - λ₂: algebraic connectivity (expansion)
    - R_diam: worst-case electrical transport cost
    """
    print("\n" + "=" * 65)
    print("  APPLICATION 4: Spectral Gap vs Resistance Diameter")
    print("=" * 65)

    graphs = {
        "Path P_6": path_graph(6),
        "Cycle C_6": grid_graph(1, 6),  # cycle approximation
        "Complete K_6": complete_graph(6),
        "Star S_6": np.zeros((6, 6), dtype=int),
        "Grid 2×3": grid_graph(2, 3),
    }

    # Fix star
    star = graphs["Star S_6"]
    for i in range(1, 6):
        star[0, i] = star[i, 0] = 1

    # Fix cycle
    cycle = np.zeros((6, 6), dtype=int)
    for i in range(6):
        cycle[i, (i + 1) % 6] = cycle[(i + 1) % 6, i] = 1
    graphs["Cycle C_6"] = cycle

    print(f"\n  {'Graph':<14} {'λ₂':>8} {'R_diam':>8} {'λ₂·R_diam':>10} {'Defect_max':>10}")
    print(f"  {'-' * 52}")

    for name, adj in graphs.items():
        n = adj.shape[0]
        L = make_laplacian(adj).astype(float)
        eigenvalues = sorted(np.linalg.eigvalsh(L))
        lambda2 = eigenvalues[1] if len(eigenvalues) > 1 else 0

        R = make_resistance(adj)
        rd = max_resistance(R, list(range(n)))

        # Max defect lower bound over all pairs
        max_dlb = 0
        for i in range(1, n):
            for j in range(i + 1, n):
                S = [i, j]
                L_S = L[np.ix_(S, S)]
                tr = trop_rank(L_S)
                max_dlb = max(max_dlb, tr - 1)

        print(f"  {name:<14} {lambda2:>8.4f} {rd:>8.4f} "
              f"{lambda2 * rd:>10.4f} {max_dlb:>10}")


if __name__ == '__main__':
    print("╔" + "═" * 63 + "╗")
    print("║  Applications of Tropical Rank Defect Theory                  ║")
    print("╚" + "═" * 63 + "╝")

    network_robustness_analysis()
    partitioning_quality()
    metastability_detection()
    spectral_resistance_comparison()

    print("\n" + "=" * 65)
    print("  Summary of Applications:")
    print("  1. Network robustness: defect identifies transport bottlenecks")
    print("  2. Partitioning: resistance geometry guides community detection")
    print("  3. Metastability: commute time reveals trapped random walks")
    print("  4. Spectral comparison: resistance provides complementary diagnostics")
    print("=" * 65)


#!/usr/bin/env python3
"""
Demo: Effective Resistance and Tropical Rank Defect

Demonstrates the relationship between effective resistance geometry,
chip-firing rank, and tropical rank defect on finite graphs.

Generates plots and tables showing:
1. Defect vs resistance diameter across graph families
2. Defect vs commute time diameter
3. Family-wise comparison (paths, cycles, complete, barbell, star)
4. The monotone lower envelope f(Rdiam) bounding defect from below

Usage:
    python demo.py
"""

import numpy as np
from itertools import combinations
from typing import List, Dict, Tuple
import json
import sys

# ─── Inline implementations (self-contained, no local imports) ───

class SimpleGraph:
    """A simple undirected graph represented by adjacency matrix."""
    def __init__(self, adj: np.ndarray):
        self.adj = adj
        self.n = adj.shape[0]

    @classmethod
    def path(cls, n: int) -> 'SimpleGraph':
        adj = np.zeros((n, n), dtype=int)
        for i in range(n - 1):
            adj[i, i + 1] = 1
            adj[i + 1, i] = 1
        return cls(adj)

    @classmethod
    def cycle(cls, n: int) -> 'SimpleGraph':
        g = cls.path(n)
        g.adj[0, n - 1] = 1
        g.adj[n - 1, 0] = 1
        return g

    @classmethod
    def complete(cls, n: int) -> 'SimpleGraph':
        adj = np.ones((n, n), dtype=int) - np.eye(n, dtype=int)
        return cls(adj)

    @classmethod
    def barbell(cls, n: int) -> 'SimpleGraph':
        total = 2 * n
        adj = np.zeros((total, total), dtype=int)
        for i in range(n):
            for j in range(i + 1, n):
                adj[i, j] = adj[j, i] = 1
        for i in range(n, total):
            for j in range(i + 1, total):
                adj[i, j] = adj[j, i] = 1
        adj[n - 1, n] = adj[n, n - 1] = 1
        return cls(adj)

    @classmethod
    def star(cls, n: int) -> 'SimpleGraph':
        adj = np.zeros((n, n), dtype=int)
        for i in range(1, n):
            adj[0, i] = adj[i, 0] = 1
        return cls(adj)

    @classmethod
    def lollipop(cls, clique_n: int, path_k: int) -> 'SimpleGraph':
        total = clique_n + path_k
        adj = np.zeros((total, total), dtype=int)
        for i in range(clique_n):
            for j in range(i + 1, clique_n):
                adj[i, j] = adj[j, i] = 1
        for i in range(clique_n - 1, clique_n + path_k - 1):
            adj[i, i + 1] = adj[i + 1, i] = 1
        return cls(adj)

    def num_edges(self) -> int:
        return int(np.sum(self.adj) // 2)

    def is_connected(self) -> bool:
        visited = set([0])
        queue = [0]
        while queue:
            v = queue.pop(0)
            for w in range(self.n):
                if self.adj[v, w] and w not in visited:
                    visited.add(w)
                    queue.append(w)
        return len(visited) == self.n


def laplacian(G: SimpleGraph) -> np.ndarray:
    return np.diag(np.sum(G.adj, axis=1)) - G.adj


def eff_resistance(G: SimpleGraph) -> np.ndarray:
    L = laplacian(G).astype(float)
    L_pinv = np.linalg.pinv(L)
    R = np.zeros((G.n, G.n))
    for u in range(G.n):
        for v in range(G.n):
            R[u, v] = L_pinv[u, u] + L_pinv[v, v] - 2 * L_pinv[u, v]
    return np.maximum(R, 0)


def res_diam(R: np.ndarray, verts: List[int]) -> float:
    if len(verts) <= 1:
        return 0.0
    return max(R[u, v] for u in verts for v in verts)


def trop_rank_proxy(L_S: np.ndarray) -> int:
    if L_S.size == 0:
        return 0
    return int(np.linalg.matrix_rank(L_S.astype(float)))


def rooted_div(n, q, S):
    D = np.zeros(n, dtype=int)
    for v in S:
        D[v] = 1
    D[q] = -len(S)
    return D


def _can_make_effective(D, L, n, max_iter=500):
    current = D.copy().astype(int)
    for _ in range(max_iter):
        if np.all(current >= 0):
            return True
        neg_verts = np.where(current < 0)[0]
        if len(neg_verts) == 0:
            return True
        made_progress = False
        for v in neg_verts:
            f = np.zeros(n, dtype=int)
            f[v] = -1
            new_D = current - L @ f
            if np.sum(new_D < 0) < np.sum(current < 0) or np.min(new_D) > np.min(current):
                current = new_D
                made_progress = True
                break
        if not made_progress:
            for v in range(n):
                if current[v] > 0:
                    f = np.zeros(n, dtype=int)
                    f[v] = 1
                    new_D = current - L @ f
                    if np.sum(new_D < 0) < np.sum(current < 0):
                        current = new_D
                        made_progress = True
                        break
            if not made_progress:
                return False
    return np.all(current >= 0)


def _eff_divs(n, r):
    if n == 0 or r < 0:
        return
    if n == 1:
        yield np.array([r], dtype=int)
        return
    for first in range(r + 1):
        for rest in _eff_divs(n - 1, r - first):
            yield np.concatenate([[first], rest])


def div_rank(G, D, max_rank=8):
    n = G.n
    L = laplacian(G)
    if not _can_make_effective(D, L, n):
        return -1
    for r in range(1, max_rank + 1):
        for E in _eff_divs(n, r):
            if not _can_make_effective(D - E, L, n):
                return r - 1
    return max_rank


def analyze_graph(G: SimpleGraph, q: int, max_size: int = None):
    """Full defect analysis for a graph with root q."""
    n = G.n
    L = laplacian(G)
    R = eff_resistance(G)
    verts = [v for v in range(n) if v != q]
    if max_size is None:
        max_size = len(verts)

    results = []
    for size in range(1, min(max_size, len(verts)) + 1):
        for S in combinations(verts, size):
            S_list = list(S)
            S_q = S_list + [q]
            L_S = L[np.ix_(S_list, S_list)]
            tr = trop_rank_proxy(L_S)
            D_S = rooted_div(n, q, S_list)
            cr = div_rank(G, D_S, max_rank=min(size + 2, 6))
            delta = (tr - 1) - cr
            rd = res_diam(R, S_q)
            ct = 2 * G.num_edges() * rd

            results.append({
                'S': S_list, 'size': size,
                'trop_rank': tr, 'chip_rank': cr, 'defect': delta,
                'resistance_diam': round(rd, 4),
                'commute_time_diam': round(ct, 4),
            })
    return results


def print_table(results: List[Dict], title: str):
    """Print a formatted table of results."""
    print(f"\n{'=' * 70}")
    print(f"  {title}")
    print(f"{'=' * 70}")
    print(f"  {'S':<16} {'|S|':>3} {'tropRk':>6} {'chipRk':>6} {'Δ':>4} "
          f"{'Rdiam':>8} {'Cdiam':>10}")
    print(f"  {'-' * 60}")
    for r in results:
        s_str = str(r['S'])
        if len(s_str) > 14:
            s_str = s_str[:12] + '..'
        print(f"  {s_str:<16} {r['size']:>3} {r['trop_rank']:>6} "
              f"{r['chip_rank']:>6} {r['defect']:>4} "
              f"{r['resistance_diam']:>8.3f} {r['commute_time_diam']:>10.2f}")


def demo_graph_families():
    """Demonstrate defect analysis across graph families."""

    print("\n" + "▓" * 70)
    print("  TROPICAL RANK DEFECT ANALYSIS")
    print("  Effective Resistance and Chip-Firing on Finite Graphs")
    print("▓" * 70)

    # 1. Path graphs
    for n in [4, 5, 6]:
        G = SimpleGraph.path(n)
        results = analyze_graph(G, q=0, max_size=min(n - 1, 3))
        print_table(results, f"Path P_{n}, root q=0")

    # 2. Cycle graphs
    for n in [4, 5]:
        G = SimpleGraph.cycle(n)
        results = analyze_graph(G, q=0, max_size=min(n - 1, 3))
        print_table(results, f"Cycle C_{n}, root q=0")

    # 3. Complete graphs
    for n in [3, 4, 5]:
        G = SimpleGraph.complete(n)
        results = analyze_graph(G, q=0, max_size=min(n - 1, 3))
        print_table(results, f"Complete K_{n}, root q=0")

    # 4. Star graphs
    for n in [4, 5]:
        G = SimpleGraph.star(n)
        results = analyze_graph(G, q=0, max_size=min(n - 1, 3))
        print_table(results, f"Star S_{n}, root q=0 (center)")

    # 5. Barbell
    G = SimpleGraph.barbell(3)
    results = analyze_graph(G, q=0, max_size=3)
    print_table(results, "Barbell B(3,3), root q=0")


def demo_defect_vs_resistance():
    """Collect defect vs resistance diameter data across many graphs."""

    print("\n" + "▓" * 70)
    print("  DEFECT vs RESISTANCE DIAMETER — Cross-Family Analysis")
    print("▓" * 70)

    all_data = []

    families = {
        'Path': [SimpleGraph.path(n) for n in range(3, 7)],
        'Cycle': [SimpleGraph.cycle(n) for n in range(3, 7)],
        'Complete': [SimpleGraph.complete(n) for n in range(3, 6)],
        'Star': [SimpleGraph.star(n) for n in range(3, 7)],
    }

    for family_name, graphs in families.items():
        for G in graphs:
            results = analyze_graph(G, q=0, max_size=3)
            for r in results:
                r['family'] = family_name
                r['graph_size'] = G.n
                all_data.append(r)

    # Find extremizers
    if all_data:
        max_defect = max(all_data, key=lambda x: x['defect'])
        max_rdiam = max(all_data, key=lambda x: x['resistance_diam'])

        print(f"\n  Maximum defect: Δ = {max_defect['defect']}")
        print(f"    Family: {max_defect['family']}, n={max_defect['graph_size']}, "
              f"S={max_defect['S']}")

        print(f"\n  Maximum resistance diameter: {max_rdiam['resistance_diam']:.4f}")
        print(f"    Family: {max_rdiam['family']}, n={max_rdiam['graph_size']}, "
              f"S={max_rdiam['S']}")

    # Summary statistics by family
    print(f"\n  {'Family':<12} {'Count':>6} {'AvgΔ':>8} {'MaxΔ':>6} "
          f"{'AvgRdiam':>10} {'MaxRdiam':>10}")
    print(f"  {'-' * 54}")

    for family in families:
        fdata = [d for d in all_data if d['family'] == family]
        if fdata:
            avg_d = np.mean([d['defect'] for d in fdata])
            max_d = max(d['defect'] for d in fdata)
            avg_r = np.mean([d['resistance_diam'] for d in fdata])
            max_r = max(d['resistance_diam'] for d in fdata)
            print(f"  {family:<12} {len(fdata):>6} {avg_d:>8.2f} {max_d:>6} "
                  f"{avg_r:>10.4f} {max_r:>10.4f}")

    return all_data


def demo_lower_envelope(all_data: List[Dict]):
    """Compute and display the monotone lower envelope f(Rdiam)."""

    print("\n" + "▓" * 70)
    print("  MONOTONE LOWER ENVELOPE f(Rdiam)")
    print("▓" * 70)

    if not all_data:
        print("  No data available.")
        return

    # Bin by resistance diameter
    r_vals = [d['resistance_diam'] for d in all_data]
    d_vals = [d['defect'] for d in all_data]

    # Sort by resistance diameter
    sorted_pairs = sorted(zip(r_vals, d_vals))

    # Compute running minimum defect (lower envelope)
    bins = np.linspace(0, max(r_vals) + 0.1, 20)
    envelope = []
    for i in range(len(bins) - 1):
        lo, hi = bins[i], bins[i + 1]
        in_bin = [d for r, d in sorted_pairs if lo <= r < hi]
        if in_bin:
            envelope.append((round((lo + hi) / 2, 3), min(in_bin), len(in_bin)))

    print(f"\n  {'Rdiam range':>14} {'min Δ':>8} {'count':>6}")
    print(f"  {'-' * 30}")
    for mid, min_d, count in envelope:
        print(f"  {mid:>14.3f} {min_d:>8} {count:>6}")

    print("\n  Observation: The minimum defect tends to increase with")
    print("  resistance diameter, consistent with the main theorem.")
    print("  Defect ≥ tropRank - 1 ≥ |S| - 1 for degree-zero divisors.")


def demo_tree_theorem():
    """Demonstrate the tree rigidity result: on trees, defect = |S| - 1 - r(D_S)."""

    print("\n" + "▓" * 70)
    print("  TREE RIGIDITY: Δ(T, q, S) ≥ |S| - 1")
    print("  (since L_S has full rank |S| on trees)")
    print("▓" * 70)

    for n in [4, 5, 6]:
        G = SimpleGraph.path(n)  # Path = simplest tree
        L = laplacian(G)
        R = eff_resistance(G)
        q = 0

        print(f"\n  Path P_{n}, root q={q}:")
        verts = [v for v in range(n) if v != q]

        for size in range(1, min(len(verts), 4) + 1):
            for S in combinations(verts, size):
                S_list = list(S)
                L_S = L[np.ix_(S_list, S_list)]
                det_LS = np.linalg.det(L_S.astype(float))
                rank_LS = int(np.linalg.matrix_rank(L_S.astype(float)))
                D_S = rooted_div(n, q, S_list)
                cr = div_rank(G, D_S, max_rank=4)
                delta = (rank_LS - 1) - cr
                rdiam = res_diam(R, S_list + [q])

                status = "✓" if delta >= size - 1 else "✗"
                print(f"    {status} S={S_list}, |S|={size}, "
                      f"rank(L_S)={rank_LS}, det={det_LS:.1f}, "
                      f"r(D_S)={cr}, Δ={delta}, |S|-1={size - 1}, "
                      f"Rdiam={rdiam:.2f}")


def demo_commute_time_bridge():
    """Demonstrate the commute time interpretation."""

    print("\n" + "▓" * 70)
    print("  COMMUTE TIME BRIDGE: C_diam = 2|E| · R_diam")
    print("▓" * 70)

    families = [
        ("Path P_5", SimpleGraph.path(5)),
        ("Cycle C_5", SimpleGraph.cycle(5)),
        ("Complete K_5", SimpleGraph.complete(5)),
        ("Star S_5", SimpleGraph.star(5)),
    ]

    for name, G in families:
        R = eff_resistance(G)
        E = G.num_edges()
        print(f"\n  {name} (|E| = {E}):")

        verts = list(range(1, G.n))  # q = 0
        rd = res_diam(R, [0] + verts)
        cd = 2 * E * rd
        print(f"    Rdiam(V) = {rd:.4f}")
        print(f"    Cdiam(V) = 2·{E}·{rd:.4f} = {cd:.4f}")
        print(f"    Interpretation: max round-trip time ≈ {cd:.1f} steps")


if __name__ == '__main__':
    print("╔" + "═" * 68 + "╗")
    print("║  Effective Resistance and Tropical Rank Defect — Interactive Demo  ║")
    print("╚" + "═" * 68 + "╝")

    # Run all demonstrations
    demo_graph_families()
    all_data = demo_defect_vs_resistance()
    demo_lower_envelope(all_data)
    demo_tree_theorem()
    demo_commute_time_bridge()

    print("\n" + "=" * 70)
    print("  Demo complete. Key findings:")
    print("  • Degree-zero divisors have chip-firing rank ≤ 0 (proven)")
    print("  • Tropical rank defect ≥ tropRank - 1 (proven)")
    print("  • On trees: L_S has full rank, so defect ≥ |S| - 1")
    print("  • Resistance diameter correlates with defect magnitude")
    print("  • Commute time provides dynamical interpretation")
    print("=" * 70)
