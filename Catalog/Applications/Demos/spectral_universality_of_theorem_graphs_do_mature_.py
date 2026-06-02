"""
Spectral Universality of Theorem Graphs — Demo

Demonstrates the key concepts:
1. Building theorem-dependency DAGs
2. Computing spectral properties
3. Coarse-graining and observing spectral convergence
4. Comparing spectra across different graph types
"""

import numpy as np
from algorithms import (
    DigraphOn, tarjan_scc, SCCPartition, coarse_grain,
    spectral_moment, normalized_laplacian_spectrum,
    wasserstein_distance, iterated_renormalization,
    degree_entropy, generate_random_dag, generate_layered_dag
)


def demo_basic_properties():
    """Demonstrate basic graph properties and the handshaking lemma."""
    print("=" * 60)
    print("DEMO 1: Basic Properties and Handshaking Lemma")
    print("=" * 60)

    # Create a small theorem-dependency graph
    # Vertices represent: 0=Axiom1, 1=Axiom2, 2=Lemma1, 3=Lemma2, 4=Theorem
    edges = [(2, 0), (2, 1), (3, 1), (4, 2), (4, 3)]
    g = DigraphOn.from_edge_list(5, edges)

    print("\nGraph: 5 vertices (2 axioms, 2 lemmas, 1 theorem)")
    print(f"Edges: {edges}")
    print(f"Edge count: {g.edge_count()}")

    out_degs = g.out_degrees()
    in_degs = g.in_degrees()
    print(f"Out-degrees: {out_degs}")
    print(f"In-degrees:  {in_degs}")
    print(f"Sum of out-degrees: {sum(out_degs)}")
    print(f"Sum of in-degrees:  {sum(in_degs)}")
    print(f"Handshaking verified: {sum(out_degs) == sum(in_degs) == g.edge_count()}")


def demo_spectral_moments():
    """Demonstrate spectral moment computation."""
    print("\n" + "=" * 60)
    print("DEMO 2: Spectral Moments")
    print("=" * 60)

    g = generate_random_dag(50, 0.15, seed=42)
    print(f"\nRandom DAG: {g.n} vertices, {g.edge_count()} edges")

    for k in range(6):
        mu_k = spectral_moment(g, k)
        print(f"  μ_{k} = {mu_k:.6f}")

    print(f"\nNote: μ₀ = 1 always (trace identity)")
    print(f"Note: μ₁ = 0 for DAGs (no self-loops)")
    print(f"Note: μ₂ = 0 for DAGs (no 2-cycles)")


def demo_laplacian_trace():
    """Demonstrate the normalized Laplacian trace identity."""
    print("\n" + "=" * 60)
    print("DEMO 3: Normalized Laplacian Trace Identity")
    print("=" * 60)

    for n in [10, 25, 50, 100]:
        g = generate_random_dag(n, 0.2, seed=n)
        spec = normalized_laplacian_spectrum(g)
        trace = np.sum(spec)
        print(f"  n = {n:3d}: tr(L_norm) = {trace:.6f} (expected: {n})")


def demo_coarse_graining():
    """Demonstrate coarse-graining and its effect on spectral properties."""
    print("\n" + "=" * 60)
    print("DEMO 4: Coarse-Graining (Renormalization)")
    print("=" * 60)

    g = generate_random_dag(100, 0.1, seed=42)
    print(f"\nInitial graph: {g.n} vertices, {g.edge_count()} edges")
    print(f"Degree entropy: {degree_entropy(g):.4f}")

    history = iterated_renormalization(g)
    print(f"\nRenormalization history ({len(history)} steps):")
    for i, (gi, _) in enumerate(history):
        spec = normalized_laplacian_spectrum(gi)
        print(f"  Step {i}: {gi.n:4d} vertices, {gi.edge_count():5d} edges, "
              f"entropy = {degree_entropy(gi):.4f}, "
              f"λ₂ = {spec[1] if len(spec) > 1 else 0:.4f}")


def demo_spectral_comparison():
    """Compare spectra across different graph types."""
    print("\n" + "=" * 60)
    print("DEMO 5: Spectral Comparison Across Graph Types")
    print("=" * 60)

    n = 100
    # Type 1: Dense random DAG (algebra-like: many interconnections)
    g_dense = generate_random_dag(n, 0.3, seed=1)
    # Type 2: Sparse random DAG (topology-like: fewer dependencies)
    g_sparse = generate_random_dag(n, 0.05, seed=2)
    # Type 3: Layered DAG (analysis-like: hierarchical structure)
    g_layered = generate_layered_dag([10, 20, 30, 25, 15], 0.2, seed=3)

    specs = {
        "Dense DAG": normalized_laplacian_spectrum(g_dense),
        "Sparse DAG": normalized_laplacian_spectrum(g_sparse),
        "Layered DAG": normalized_laplacian_spectrum(g_layered),
    }

    print(f"\nGraph properties:")
    for name, g in [("Dense DAG", g_dense), ("Sparse DAG", g_sparse), ("Layered DAG", g_layered)]:
        print(f"  {name}: {g.n} vertices, {g.edge_count()} edges, "
              f"entropy = {degree_entropy(g):.4f}")

    print(f"\nPairwise Wasserstein distances (before coarse-graining):")
    names = list(specs.keys())
    for i in range(len(names)):
        for j in range(i + 1, len(names)):
            d = wasserstein_distance(specs[names[i]], specs[names[j]])
            print(f"  W₁({names[i]}, {names[j]}) = {d:.6f}")

    # After coarse-graining
    print(f"\nPairwise Wasserstein distances (after 1 coarse-graining step):")
    graphs_cg = {}
    for name, g in [("Dense DAG", g_dense), ("Sparse DAG", g_sparse), ("Layered DAG", g_layered)]:
        history = iterated_renormalization(g, max_steps=1)
        g_cg = history[-1][0]
        graphs_cg[name] = g_cg
        specs[name + " (CG)"] = normalized_laplacian_spectrum(g_cg)

    for i in range(len(names)):
        for j in range(i + 1, len(names)):
            d = wasserstein_distance(
                specs[names[i] + " (CG)"],
                specs[names[j] + " (CG)"]
            )
            print(f"  W₁({names[i]}, {names[j]}) = {d:.6f}")


def demo_dag_edge_bound():
    """Verify the DAG edge bound n(n-1)/2."""
    print("\n" + "=" * 60)
    print("DEMO 6: DAG Edge Bound Verification")
    print("=" * 60)

    for n in [10, 20, 50, 100]:
        bound = n * (n - 1) // 2
        # Generate a dense DAG
        g = generate_random_dag(n, 1.0, seed=42)  # maximum density
        print(f"  n = {n:3d}: edges = {g.edge_count()}, "
              f"bound = {bound}, satisfied: {g.edge_count() <= bound}")


def demo_source_theorem():
    """Verify that every non-empty DAG has a source (in-degree 0 vertex)."""
    print("\n" + "=" * 60)
    print("DEMO 7: DAG Source Theorem Verification")
    print("=" * 60)

    for trial in range(5):
        n = 50 + trial * 20
        g = generate_random_dag(n, 0.2, seed=trial)
        in_degs = g.in_degrees()
        sources = np.where(in_degs == 0)[0]
        print(f"  Trial {trial + 1}: n = {n}, edges = {g.edge_count()}, "
              f"sources = {len(sources)}, "
              f"source exists: {len(sources) > 0}")


def demo_termination():
    """Demonstrate renormalization termination."""
    print("\n" + "=" * 60)
    print("DEMO 8: Renormalization Termination")
    print("=" * 60)

    for seed in range(3):
        g = generate_random_dag(200, 0.1, seed=seed)
        history = iterated_renormalization(g, max_steps=50)
        vertex_counts = [gi.n for gi, _ in history]
        print(f"  Seed {seed}: initial = {vertex_counts[0]}, "
              f"steps = {len(history) - 1}, "
              f"final = {vertex_counts[-1]}, "
              f"sequence: {' → '.join(str(v) for v in vertex_counts[:8])}"
              f"{'...' if len(vertex_counts) > 8 else ''}")


if __name__ == "__main__":
    demo_basic_properties()
    demo_spectral_moments()
    demo_laplacian_trace()
    demo_coarse_graining()
    demo_spectral_comparison()
    demo_dag_edge_bound()
    demo_source_theorem()
    demo_termination()

    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


"""
Visualization: DAG Structure and Edge Bound

Demonstrates key DAG properties:
1. Edge density vs. the n(n-1)/2 bound
2. Source vertex count
3. Degree distributions across different DAG types
"""

import numpy as np
import matplotlib.pyplot as plt


def generate_random_dag(n: int, p: float, seed: int) -> np.ndarray:
    rng = np.random.default_rng(seed)
    perm = rng.permutation(n)
    adj = np.zeros((n, n), dtype=bool)
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                adj[perm[i]][perm[j]] = True
    return adj


fig, axes = plt.subplots(2, 2, figsize=(13, 10))

# Plot 1: Edge count vs bound
ns = list(range(5, 101, 5))
edge_counts_sparse = []
edge_counts_dense = []
bounds = []

for n in ns:
    g_sparse = generate_random_dag(n, 0.1, seed=n)
    g_dense = generate_random_dag(n, 0.5, seed=n + 1000)
    edge_counts_sparse.append(int(np.sum(g_sparse)))
    edge_counts_dense.append(int(np.sum(g_dense)))
    bounds.append(n * (n - 1) // 2)

axes[0, 0].plot(ns, bounds, 'k--', linewidth=2, label='Bound n(n-1)/2')
axes[0, 0].plot(ns, edge_counts_dense, 'rs-', markersize=4, label='Dense DAG (p=0.5)')
axes[0, 0].plot(ns, edge_counts_sparse, 'bo-', markersize=4, label='Sparse DAG (p=0.1)')
axes[0, 0].set_xlabel("Number of vertices n")
axes[0, 0].set_ylabel("Edge count")
axes[0, 0].set_title("DAG Edge Count vs. Theoretical Bound")
axes[0, 0].legend()

# Plot 2: Number of sources vs n
ns2 = list(range(10, 201, 10))
for p, color, label in [(0.05, 'b', 'p=0.05'), (0.15, 'g', 'p=0.15'), (0.4, 'r', 'p=0.40')]:
    source_counts = []
    for n in ns2:
        g = generate_random_dag(n, p, seed=n * 3)
        in_degs = np.sum(g, axis=0)
        source_counts.append(np.sum(in_degs == 0))
    axes[0, 1].plot(ns2, source_counts, 'o-', color=color, markersize=3, label=label)

axes[0, 1].set_xlabel("Number of vertices n")
axes[0, 1].set_ylabel("Number of sources")
axes[0, 1].set_title("Source Vertices (in-degree 0) vs. Graph Size")
axes[0, 1].legend()

# Plot 3: Out-degree distribution
n = 200
for p, color, label in [(0.05, 'blue', 'Sparse'), (0.15, 'green', 'Medium'), (0.4, 'red', 'Dense')]:
    g = generate_random_dag(n, p, seed=42)
    out_degs = np.sum(g, axis=1)
    max_deg = int(np.max(out_degs))
    hist, bins = np.histogram(out_degs, bins=range(max_deg + 2), density=True)
    axes[1, 0].bar(bins[:-1] + 0.15 * (list(zip(['blue', 'green', 'red'], range(3)))
                   .index((color, ['blue', 'green', 'red'].index(color)))),
                   hist, width=0.25, alpha=0.7, color=color, label=f'{label} (p={p})')

axes[1, 0].set_xlabel("Out-degree")
axes[1, 0].set_ylabel("Probability")
axes[1, 0].set_title("Out-Degree Distribution")
axes[1, 0].legend()

# Plot 4: Edge density (edge_count / max_edges) vs p
ps = np.linspace(0.01, 0.99, 30)
densities_50 = []
densities_100 = []
densities_200 = []

for p in ps:
    for n, store in [(50, densities_50), (100, densities_100), (200, densities_200)]:
        g = generate_random_dag(n, p, seed=int(p * 1000))
        max_edges = n * (n - 1) // 2
        store.append(int(np.sum(g)) / max_edges if max_edges > 0 else 0)

axes[1, 1].plot(ps, densities_50, 'o-', markersize=3, label='n=50')
axes[1, 1].plot(ps, densities_100, 's-', markersize=3, label='n=100')
axes[1, 1].plot(ps, densities_200, '^-', markersize=3, label='n=200')
axes[1, 1].plot(ps, ps / 2, 'k--', linewidth=1, label='p/2 (expected)')
axes[1, 1].set_xlabel("Edge probability p")
axes[1, 1].set_ylabel("Edge density (edges / max_edges)")
axes[1, 1].set_title("Edge Density vs. Probability")
axes[1, 1].legend()

fig.suptitle("Structural Properties of Theorem-Dependency DAGs", fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig("dag_structure.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved: dag_structure.png")


"""
Visualization: Renormalization Flow

Shows how graph properties evolve under iterative coarse-graining,
demonstrating convergence to a fixed point.
"""

import numpy as np
import matplotlib.pyplot as plt


def generate_random_dag(n: int, p: float, seed: int) -> np.ndarray:
    rng = np.random.default_rng(seed)
    perm = rng.permutation(n)
    adj = np.zeros((n, n), dtype=bool)
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                adj[perm[i]][perm[j]] = True
    return adj


def tarjan_scc(adj: np.ndarray) -> list:
    n = len(adj)
    idx = [0]
    stack, on_stack = [], [False] * n
    index, lowlink = [-1] * n, [-1] * n
    result = []

    def sc(v):
        index[v] = lowlink[v] = idx[0]
        idx[0] += 1
        stack.append(v)
        on_stack[v] = True
        for w in range(n):
            if not adj[v][w]:
                continue
            if index[w] == -1:
                sc(w)
                lowlink[v] = min(lowlink[v], lowlink[w])
            elif on_stack[w]:
                lowlink[v] = min(lowlink[v], index[w])
        if lowlink[v] == index[v]:
            comp = []
            while True:
                w = stack.pop()
                on_stack[w] = False
                comp.append(w)
                if w == v:
                    break
            result.append(comp)

    for v in range(n):
        if index[v] == -1:
            sc(v)
    return result


def coarse_grain(adj: np.ndarray) -> np.ndarray:
    n = len(adj)
    sccs = tarjan_scc(adj)
    m = len(sccs)
    block_of = np.zeros(n, dtype=int)
    for b, scc in enumerate(sccs):
        for v in scc:
            block_of[v] = b
    new_adj = np.zeros((m, m), dtype=bool)
    for i in range(n):
        for j in range(n):
            if adj[i][j]:
                b1, b2 = block_of[i], block_of[j]
                if b1 != b2:
                    new_adj[b1][b2] = True
    return new_adj


def degree_entropy(adj: np.ndarray) -> float:
    n = len(adj)
    if n == 0:
        return 0.0
    degs = np.sum(adj, axis=1)
    _, counts = np.unique(degs, return_counts=True)
    probs = counts / n
    probs = probs[probs > 0]
    return float(-np.sum(probs * np.log2(probs)))


def laplacian_spectrum(adj: np.ndarray) -> np.ndarray:
    A_sym = (adj | adj.T).astype(float)
    degrees = np.sum(A_sym, axis=1)
    D_inv_sqrt = np.zeros(len(adj))
    for i in range(len(adj)):
        if degrees[i] > 0:
            D_inv_sqrt[i] = 1.0 / np.sqrt(degrees[i])
    L = np.eye(len(adj)) - np.diag(D_inv_sqrt) @ A_sym @ np.diag(D_inv_sqrt)
    return np.sort(np.linalg.eigvalsh(L))


# Generate initial graphs
seeds = [42, 123, 456]
labels = ["Graph A (p=0.15)", "Graph B (p=0.20)", "Graph C (p=0.10)"]
probs = [0.15, 0.20, 0.10]
n_init = 150

fig, axes = plt.subplots(2, 2, figsize=(13, 10))

for seed, label, p in zip(seeds, labels, probs):
    adj = generate_random_dag(n_init, p, seed)
    vertex_counts = [len(adj)]
    edge_counts = [int(np.sum(adj))]
    entropies = [degree_entropy(adj)]
    spectral_gaps = []

    spec = laplacian_spectrum(adj)
    spectral_gaps.append(spec[1] if len(spec) > 1 else 0)

    for _ in range(20):
        if len(adj) <= 1:
            break
        new_adj = coarse_grain(adj)
        if len(new_adj) == len(adj):
            break
        adj = new_adj
        vertex_counts.append(len(adj))
        edge_counts.append(int(np.sum(adj)))
        entropies.append(degree_entropy(adj))
        spec = laplacian_spectrum(adj)
        spectral_gaps.append(spec[1] if len(spec) > 1 else 0)

    steps = range(len(vertex_counts))
    axes[0, 0].plot(list(steps), vertex_counts, 'o-', markersize=4, label=label)
    axes[0, 1].plot(list(steps), edge_counts, 'o-', markersize=4, label=label)
    axes[1, 0].plot(list(steps), entropies, 'o-', markersize=4, label=label)
    axes[1, 1].plot(list(steps), spectral_gaps, 'o-', markersize=4, label=label)

axes[0, 0].set_xlabel("Coarse-graining step")
axes[0, 0].set_ylabel("Vertex count")
axes[0, 0].set_title("Vertex Count Under Renormalization")
axes[0, 0].legend(fontsize=8)
axes[0, 0].set_yscale('log')

axes[0, 1].set_xlabel("Coarse-graining step")
axes[0, 1].set_ylabel("Edge count")
axes[0, 1].set_title("Edge Count Under Renormalization")
axes[0, 1].legend(fontsize=8)
axes[0, 1].set_yscale('log')

axes[1, 0].set_xlabel("Coarse-graining step")
axes[1, 0].set_ylabel("Degree Entropy (bits)")
axes[1, 0].set_title("Degree Entropy Under Renormalization")
axes[1, 0].legend(fontsize=8)

axes[1, 1].set_xlabel("Coarse-graining step")
axes[1, 1].set_ylabel("Spectral Gap λ₂")
axes[1, 1].set_title("Spectral Gap Under Renormalization")
axes[1, 1].legend(fontsize=8)

fig.suptitle("Renormalization Flow: Graph Properties Under Iterative Coarse-Graining",
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig("renormalization_flow.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved: renormalization_flow.png")


"""
Visualization: Spectral Distribution Comparison Across Graph Types

Generates a figure comparing the spectral distributions of the normalized
Laplacian for different types of DAGs, illustrating the spectral universality
hypothesis.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec


def generate_random_dag(n: int, p: float, seed: int) -> np.ndarray:
    rng = np.random.default_rng(seed)
    perm = rng.permutation(n)
    adj = np.zeros((n, n), dtype=bool)
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                adj[perm[i]][perm[j]] = True
    return adj


def generate_layered_dag(layers: list, p: float, seed: int) -> np.ndarray:
    rng = np.random.default_rng(seed)
    n = sum(layers)
    adj = np.zeros((n, n), dtype=bool)
    offsets = [0]
    for s in layers:
        offsets.append(offsets[-1] + s)
    for li in range(len(layers) - 1):
        for i in range(offsets[li], offsets[li + 1]):
            for j in range(offsets[li + 1], offsets[li + 2]):
                if rng.random() < p:
                    adj[i][j] = True
    return adj


def laplacian_spectrum(adj: np.ndarray) -> np.ndarray:
    A_sym = (adj | adj.T).astype(float)
    degrees = np.sum(A_sym, axis=1)
    D_inv_sqrt = np.zeros(len(adj))
    for i in range(len(adj)):
        if degrees[i] > 0:
            D_inv_sqrt[i] = 1.0 / np.sqrt(degrees[i])
    L = np.eye(len(adj)) - np.diag(D_inv_sqrt) @ A_sym @ np.diag(D_inv_sqrt)
    return np.sort(np.linalg.eigvalsh(L))


n = 200

# Generate three different types of DAGs
adj_dense = generate_random_dag(n, 0.25, seed=42)
adj_sparse = generate_random_dag(n, 0.05, seed=123)
adj_layered = generate_layered_dag([30, 40, 50, 45, 35], 0.15, seed=7)

specs = {
    "Dense Random DAG (p=0.25)": laplacian_spectrum(adj_dense),
    "Sparse Random DAG (p=0.05)": laplacian_spectrum(adj_sparse),
    "Layered DAG (5 layers)": laplacian_spectrum(adj_layered),
}

fig = plt.figure(figsize=(14, 8))
gs = GridSpec(2, 2, figure=fig, hspace=0.35, wspace=0.3)

# Plot 1: Spectral distributions (histograms)
ax1 = fig.add_subplot(gs[0, 0])
for name, spec in specs.items():
    ax1.hist(spec, bins=40, alpha=0.5, density=True, label=name.split("(")[0].strip())
ax1.set_xlabel("Eigenvalue λ", fontsize=11)
ax1.set_ylabel("Density", fontsize=11)
ax1.set_title("Spectral Distributions of Normalized Laplacian", fontsize=12)
ax1.legend(fontsize=8)

# Plot 2: Empirical CDFs
ax2 = fig.add_subplot(gs[0, 1])
for name, spec in specs.items():
    y = np.arange(1, len(spec) + 1) / len(spec)
    ax2.plot(spec, y, linewidth=1.5, label=name.split("(")[0].strip())
ax2.set_xlabel("Eigenvalue λ", fontsize=11)
ax2.set_ylabel("Cumulative Probability", fontsize=11)
ax2.set_title("Empirical Spectral CDFs", fontsize=12)
ax2.legend(fontsize=8)

# Plot 3: Spectral moments comparison
ax3 = fig.add_subplot(gs[1, 0])
moment_orders = range(7)
for name, spec in specs.items():
    moments = [np.mean(spec**k) for k in moment_orders]
    ax3.plot(list(moment_orders), moments, 'o-', linewidth=1.5, markersize=5,
             label=name.split("(")[0].strip())
ax3.set_xlabel("Moment Order k", fontsize=11)
ax3.set_ylabel("μ_k = E[λ^k]", fontsize=11)
ax3.set_title("Spectral Moments", fontsize=12)
ax3.legend(fontsize=8)
ax3.set_yscale('log')

# Plot 4: Wasserstein distance matrix
ax4 = fig.add_subplot(gs[1, 1])
names = list(specs.keys())
short_names = [n.split("(")[0].strip() for n in names]
dist_matrix = np.zeros((3, 3))
for i in range(3):
    for j in range(3):
        s1, s2 = specs[names[i]], specs[names[j]]
        max_val = max(np.max(np.abs(s1)), np.max(np.abs(s2)), 1e-10)
        n_pts = 200
        grid = np.linspace(0, 1, n_pts)
        c1 = np.interp(grid, np.linspace(0, 1, len(s1)), np.sort(s1) / max_val)
        c2 = np.interp(grid, np.linspace(0, 1, len(s2)), np.sort(s2) / max_val)
        dist_matrix[i][j] = np.mean(np.abs(c1 - c2))

im = ax4.imshow(dist_matrix, cmap='YlOrRd', interpolation='nearest')
ax4.set_xticks(range(3))
ax4.set_yticks(range(3))
ax4.set_xticklabels(short_names, rotation=30, ha='right', fontsize=8)
ax4.set_yticklabels(short_names, fontsize=8)
for i in range(3):
    for j in range(3):
        ax4.text(j, i, f"{dist_matrix[i][j]:.3f}", ha='center', va='center', fontsize=9)
ax4.set_title("Wasserstein Distance Matrix", fontsize=12)
plt.colorbar(im, ax=ax4, fraction=0.046, pad=0.04)

fig.suptitle("Spectral Universality of Theorem-Dependency Graphs", fontsize=14, fontweight='bold')
plt.savefig("spectral_comparison.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved: spectral_comparison.png")
