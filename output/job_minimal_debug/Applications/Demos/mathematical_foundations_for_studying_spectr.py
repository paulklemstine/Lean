"""
Demo: Spectral Analysis of Theorem Dependency Graphs

Demonstrates the key algorithms and theorems on concrete examples,
including walk counting, degree variance analysis, coarse-graining,
and spectral moment computation.
"""

from algorithms import (
    DGraph, Partition, quotient_graph, compute_scc_partition,
    compute_spectral_moments, spectral_distance, coarse_grain_chain
)


def demo_handshaking():
    """Verify the handshaking lemma: sum of in-degrees = sum of out-degrees."""
    print("=" * 60)
    print("DEMO 1: Handshaking Lemma for Directed Graphs")
    print("=" * 60)

    # A small theorem dependency graph
    # 0 -> 1, 0 -> 2, 1 -> 3, 2 -> 3, 3 -> 4
    g = DGraph(5, [(0, 1), (0, 2), (1, 3), (2, 3), (3, 4)])

    sum_out = sum(g.out_deg(i) for i in range(g.n))
    sum_in = sum(g.in_deg(i) for i in range(g.n))

    print(f"  Graph: 5 vertices, {g.edge_count()} edges")
    print(f"  Out-degrees: {[g.out_deg(i) for i in range(g.n)]}")
    print(f"  In-degrees:  {[g.in_deg(i) for i in range(g.n)]}")
    print(f"  Sum of out-degrees = {sum_out}")
    print(f"  Sum of in-degrees  = {sum_in}")
    print(f"  Edge count         = {g.edge_count()}")
    print(f"  Handshaking verified: {sum_out == sum_in == g.edge_count()}")
    print()


def demo_walk_counting():
    """Demonstrate walk counting and the composition theorem."""
    print("=" * 60)
    print("DEMO 2: Walk Counting and Composition Theorem")
    print("=" * 60)

    # Triangle with extra edge
    g = DGraph(4, [(0, 1), (1, 2), (2, 0), (0, 3)])

    print(f"  Graph: 4 vertices (cycle 0->1->2->0, plus 0->3)")
    print()

    # Walk counts for various lengths
    for k in range(5):
        print(f"  Closed walks of length {k}: {g.closed_walk_count(k)}")

    # Verify composition: walkCount(2+1, 0, 0) = sum_w walkCount(2, 0, w) * walkCount(1, w, 0)
    lhs = g.walk_count(3, 0, 0)
    rhs = sum(g.walk_count(2, 0, w) * g.walk_count(1, w, 0) for w in range(g.n))
    print(f"\n  Walk composition (k=2, l=1, i=j=0):")
    print(f"    walkCount(3, 0, 0) = {lhs}")
    print(f"    Σ_w walkCount(2, 0, w) * walkCount(1, w, 0) = {rhs}")
    print(f"    Composition verified: {lhs == rhs}")
    print()


def demo_dag_properties():
    """Demonstrate DAG walk vanishing and length bounds."""
    print("=" * 60)
    print("DEMO 3: DAG Properties — Walk Vanishing")
    print("=" * 60)

    # A DAG (no cycles)
    dag = DGraph(5, [(0, 1), (0, 2), (1, 3), (2, 3), (3, 4)])

    print(f"  DAG: 5 vertices, {dag.edge_count()} edges")
    print(f"  Is DAG: {dag.is_dag()}")
    print()

    for k in range(7):
        cwc = dag.closed_walk_count(k)
        print(f"  Closed walks of length {k}: {cwc}" +
              (" ✓ (= 0 for k > 0, DAG has no cycles)" if k > 0 and cwc == 0 else
               " ✓ (= n for k = 0)" if k == 0 else " ✗ UNEXPECTED"))

    print()
    # Walk length bound: walks of length >= n vanish
    print("  Walk length bound (walks of length >= n = 5 vanish):")
    for k in [4, 5, 6]:
        total = sum(dag.walk_count(k, i, j) for i in range(5) for j in range(5))
        print(f"    Total walks of length {k}: {total}")
    print()


def demo_degree_variance():
    """Demonstrate degree variance as spectral invariant."""
    print("=" * 60)
    print("DEMO 4: Degree Variance — Detecting Hub Structure")
    print("=" * 60)

    # Regular-ish graph (all out-degrees equal)
    reg = DGraph(4, [(0, 1), (1, 2), (2, 3), (3, 0)])
    print(f"  Regular cycle (4 vertices):")
    print(f"    Out-degrees: {[reg.out_deg(i) for i in range(reg.n)]}")
    print(f"    Variance: {reg.degree_variance():.4f} (= 0 for regular graphs)")
    print()

    # Hub-and-spoke (vertex 0 connects to all others)
    hub = DGraph(5, [(0, 1), (0, 2), (0, 3), (0, 4)])
    print(f"  Hub-and-spoke (5 vertices, vertex 0 → all):")
    print(f"    Out-degrees: {[hub.out_deg(i) for i in range(hub.n)]}")
    print(f"    Variance: {hub.degree_variance():.4f} (high = hub structure)")
    print()

    # Cauchy-Schwarz check: n * sum(d^2) >= (sum(d))^2
    for g, name in [(reg, "Regular"), (hub, "Hub")]:
        degs = [g.out_deg(i) for i in range(g.n)]
        lhs = g.n * sum(d ** 2 for d in degs)
        rhs = sum(degs) ** 2
        print(f"  Cauchy-Schwarz ({name}): {lhs} >= {rhs} → {lhs >= rhs}")
    print()


def demo_coarse_graining():
    """Demonstrate coarse-graining (SCC contraction)."""
    print("=" * 60)
    print("DEMO 5: Coarse-Graining via SCC Contraction")
    print("=" * 60)

    # Graph with SCCs
    # SCC1: {0, 1} (cycle), SCC2: {2, 3} (cycle), edge 0->2
    g = DGraph(4, [(0, 1), (1, 0), (2, 3), (3, 2), (0, 2)])

    scc = compute_scc_partition(g)
    print(f"  Original graph: {g.n} vertices, {g.edge_count()} edges")
    print(f"  SCC assignments: {scc.block_of}")
    print(f"  Number of SCCs: {scc.m}")

    qg = quotient_graph(g, scc)
    print(f"  Quotient graph: {qg.n} vertices, {qg.edge_count()} edges")
    print(f"  Edge bound: {qg.edge_count()} ≤ {qg.n * (qg.n - 1)} = m(m-1)")
    print()


def demo_spectral_moments():
    """Compare spectral moments of different graph families."""
    print("=" * 60)
    print("DEMO 6: Spectral Moment Fingerprints")
    print("=" * 60)

    # Build several graph families
    graphs = {
        "Path (6 vertices)": DGraph(6, [(i, i + 1) for i in range(5)]),
        "Cycle (6 vertices)": DGraph(6, [(i, (i + 1) % 6) for i in range(6)]),
        "Complete DAG (5 vertices)": DGraph(5, [(i, j) for i in range(5) for j in range(i + 1, 5)]),
        "Binary tree (7 vertices)": DGraph(7, [(0, 1), (0, 2), (1, 3), (1, 4), (2, 5), (2, 6)]),
    }

    max_k = 6
    moments = {}
    for name, g in graphs.items():
        m = compute_spectral_moments(g, max_k)
        moments[name] = m
        print(f"  {name}:")
        print(f"    Moments: {[f'{x:.3f}' for x in m]}")

    # Spectral distances
    print(f"\n  Spectral distances (K={max_k}):")
    names = list(graphs.keys())
    for i in range(len(names)):
        for j in range(i + 1, len(names)):
            d = spectral_distance(moments[names[i]], moments[names[j]], max_k)
            print(f"    d({names[i][:15]:>15}, {names[j][:15]:>15}) = {d:.4f}")
    print()


def demo_renormalization_chain():
    """Demonstrate iterated coarse-graining and stabilization."""
    print("=" * 60)
    print("DEMO 7: Renormalization Chain — Stabilization")
    print("=" * 60)

    # A larger graph with nested SCCs
    edges = [(0, 1), (1, 0), (2, 3), (3, 2), (0, 2), (4, 5), (5, 4), (2, 4),
             (6, 7), (7, 6), (4, 6), (8, 9), (9, 8), (6, 8)]
    g = DGraph(10, edges)

    counts = coarse_grain_chain(g, compute_scc_partition)
    print(f"  Initial graph: {g.n} vertices")
    print(f"  Vertex count sequence: {counts}")
    print(f"  Stabilized after {len(counts) - 1} iterations")
    print(f"  Fixed point size: {counts[-1]} vertices")
    print()


if __name__ == "__main__":
    demo_handshaking()
    demo_walk_counting()
    demo_dag_properties()
    demo_degree_variance()
    demo_coarse_graining()
    demo_spectral_moments()
    demo_renormalization_chain()


"""
Visualization: Spectral Fingerprints of Graph Families

Generates a heatmap comparing spectral moments across different graph
families, showing how the moment profile distinguishes graph topologies.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def walk_count_matrix(adj: np.ndarray, k: int) -> np.ndarray:
    """Compute A^k via matrix exponentiation."""
    n = adj.shape[0]
    result = np.eye(n)
    base = adj.copy()
    for _ in range(k):
        result = result @ base
    return result


def spectral_moments(adj: np.ndarray, max_k: int) -> list[float]:
    """Compute normalized spectral moments mu_k = tr(A^k) / n."""
    n = adj.shape[0]
    if n == 0:
        return [0.0] * (max_k + 1)
    moments = []
    power = np.eye(n)
    for k in range(max_k + 1):
        moments.append(np.trace(power) / n)
        power = power @ adj
    return moments


def degree_variance(adj: np.ndarray) -> float:
    """Compute out-degree variance."""
    degs = adj.sum(axis=1)
    return float(np.var(degs))


def make_path(n: int) -> np.ndarray:
    adj = np.zeros((n, n))
    for i in range(n - 1):
        adj[i][i + 1] = 1
    return adj


def make_cycle(n: int) -> np.ndarray:
    adj = np.zeros((n, n))
    for i in range(n):
        adj[i][(i + 1) % n] = 1
    return adj


def make_complete_dag(n: int) -> np.ndarray:
    adj = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            adj[i][j] = 1
    return adj


def make_binary_tree(depth: int) -> np.ndarray:
    n = 2 ** (depth + 1) - 1
    adj = np.zeros((n, n))
    for i in range(n):
        left = 2 * i + 1
        right = 2 * i + 2
        if left < n:
            adj[i][left] = 1
        if right < n:
            adj[i][right] = 1
    return adj


def make_star(n: int) -> np.ndarray:
    adj = np.zeros((n, n))
    for i in range(1, n):
        adj[0][i] = 1
    return adj


def make_bidirectional_cycle(n: int) -> np.ndarray:
    adj = np.zeros((n, n))
    for i in range(n):
        adj[i][(i + 1) % n] = 1
        adj[(i + 1) % n][i] = 1
    return adj


if __name__ == "__main__":
    max_k = 10
    graphs = {
        "Path-8": make_path(8),
        "Cycle-8": make_cycle(8),
        "BiCycle-8": make_bidirectional_cycle(8),
        "CompDAG-6": make_complete_dag(6),
        "BinTree-3": make_binary_tree(3),
        "Star-8": make_star(8),
    }

    # Compute moments
    all_moments = {}
    for name, adj in graphs.items():
        all_moments[name] = spectral_moments(adj, max_k)

    # Figure 1: Moment heatmap
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    names = list(graphs.keys())
    moment_matrix = np.array([all_moments[n] for n in names])

    ax = axes[0]
    im = ax.imshow(moment_matrix, aspect='auto', cmap='RdBu_r', vmin=-1, vmax=1)
    ax.set_yticks(range(len(names)))
    ax.set_yticklabels(names)
    ax.set_xlabel('Moment order k')
    ax.set_ylabel('Graph family')
    ax.set_title('Spectral Moment Fingerprints')
    plt.colorbar(im, ax=ax, label='μ_k = tr(A^k)/n')

    # Figure 2: Degree variance comparison
    ax2 = axes[1]
    variances = [degree_variance(graphs[n]) for n in names]
    colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(names)))
    bars = ax2.barh(range(len(names)), variances, color=colors)
    ax2.set_yticks(range(len(names)))
    ax2.set_yticklabels(names)
    ax2.set_xlabel('Degree Variance')
    ax2.set_title('Degree Distribution Variance\n(Higher = More Hub-like Structure)')

    plt.tight_layout()
    plt.savefig('spectral_fingerprints.png', dpi=150, bbox_inches='tight')
    print("Saved spectral_fingerprints.png")

    # Figure 3: Spectral distance matrix
    fig2, ax3 = plt.subplots(figsize=(7, 6))
    n_graphs = len(names)
    dist_matrix = np.zeros((n_graphs, n_graphs))
    for i in range(n_graphs):
        for j in range(n_graphs):
            dist_matrix[i][j] = max(
                abs(all_moments[names[i]][k] - all_moments[names[j]][k])
                for k in range(max_k + 1)
            )

    im3 = ax3.imshow(dist_matrix, cmap='YlOrRd')
    ax3.set_xticks(range(n_graphs))
    ax3.set_xticklabels(names, rotation=45, ha='right')
    ax3.set_yticks(range(n_graphs))
    ax3.set_yticklabels(names)
    ax3.set_title(f'Spectral Distance Matrix (K={max_k})')
    plt.colorbar(im3, ax=ax3, label='d_K(G₁, G₂)')

    plt.tight_layout()
    plt.savefig('spectral_distances.png', dpi=150, bbox_inches='tight')
    print("Saved spectral_distances.png")
