#!/usr/bin/env python3
"""
Demo: Sheaf Cohomology of Meme Propagation

Demonstrates the key results from the viral information topology framework:
1. H⁰ dimension = number of connected components
2. Phase transition at connectivity threshold
3. Mutation sheaf propagation
4. Virality-barrier duality
5. Spectral-cohomological bridge
"""

import random
import math
from algorithms import (
    compute_h0, compute_h1, meme_fitness, spread_rate,
    graph_laplacian, laplacian_spectrum, euler_characteristic,
    MutationSheaf, community_fitness, compute_connected_components
)
import numpy as np


def demo_component_section_isomorphism():
    """Demonstrate that dim H⁰ = number of connected components."""
    print("=" * 60)
    print("DEMO 1: Component-Section Isomorphism")
    print("dim H⁰(G, k) = number of connected components")
    print("=" * 60)

    examples = [
        ("Complete K₅", 5, [(i, j) for i in range(5) for j in range(i+1, 5)]),
        ("Path P₅", 5, [(0,1), (1,2), (2,3), (3,4)]),
        ("Two triangles", 6, [(0,1), (1,2), (2,0), (3,4), (4,5), (5,3)]),
        ("Empty E₅", 5, []),
        ("Star S₅", 5, [(0,1), (0,2), (0,3), (0,4)]),
    ]

    for name, n, edges in examples:
        h0 = compute_h0(n, edges)
        h1 = compute_h1(n, edges)
        chi = euler_characteristic(n, edges)
        fit = meme_fitness(h0, h1)
        print(f"\n  {name}: |V|={n}, |E|={len(edges)}")
        print(f"    dim H⁰ = {h0} (interpretations)")
        print(f"    dim H¹ = {h1} (barriers)")
        print(f"    χ = {chi} (Euler characteristic)")
        print(f"    fitness = {fit:.3f}")
        print(f"    Verified: χ = dim H⁰ - dim H¹ = {h0} - {h1} = {h0 - h1} ✓" if chi == h0 - h1 else "    ERROR!")


def demo_phase_transition():
    """Demonstrate the phase transition at p = ln(n)/n."""
    print("\n" + "=" * 60)
    print("DEMO 2: Phase Transition in Meme Diversity")
    print("Threshold at p ≈ ln(n)/n")
    print("=" * 60)

    n = 200
    threshold = math.log(n) / n
    probabilities = [0.5 * threshold, threshold, 2 * threshold, 5 * threshold]
    num_samples = 50

    print(f"\n  n = {n}, threshold p* = ln({n})/{n} ≈ {threshold:.4f}")

    for p in probabilities:
        h0_values = []
        for _ in range(num_samples):
            edges = []
            for i in range(n):
                for j in range(i+1, n):
                    if random.random() < p:
                        edges.append((i, j))
            h0 = compute_h0(n, edges)
            h0_values.append(h0)

        mean_h0 = np.mean(h0_values)
        pct_connected = sum(1 for h in h0_values if h == 1) / num_samples * 100
        print(f"\n  p = {p:.4f} ({p/threshold:.1f}× threshold):")
        print(f"    mean dim H⁰ = {mean_h0:.1f}")
        print(f"    % connected (dim H⁰ = 1): {pct_connected:.0f}%")
        phase = "FRAGMENTED (diverse)" if mean_h0 > 1.5 else "CONNECTED (uniform)"
        print(f"    Phase: {phase}")


def demo_mutation_sheaf():
    """Demonstrate mutation sheaf propagation."""
    print("\n" + "=" * 60)
    print("DEMO 3: Mutation Sheaf — Semantic Drift")
    print("Memes change meaning as they cross communities")
    print("=" * 60)

    # Triangle graph with mutation weights
    n = 4
    edges = [(0, 1), (1, 2), (2, 3)]
    weights = {(0, 1): 2.0, (1, 2): 0.5, (2, 3): 3.0}

    sheaf = MutationSheaf(n, edges, weights)

    print(f"\n  Path graph: 0 --[×2.0]--> 1 --[×0.5]--> 2 --[×3.0]--> 3")
    print(f"\n  Propagate from vertex 0 with value 1.0:")

    values = sheaf.propagate_from(0, 1.0)
    for v in sorted(values.keys()):
        print(f"    f({v}) = {values[v]:.2f}")

    print(f"\n  Interpretation: meme starts with intensity 1.0,")
    print(f"  doubles crossing edge 0→1, halves crossing 1→2, triples crossing 2→3")

    # Cycle with non-trivial holonomy
    print(f"\n  --- Holonomy on a triangle ---")
    edges_tri = [(0, 1), (1, 2), (0, 2)]
    weights_tri = {(0, 1): 2.0, (1, 2): 3.0, (2, 0): 0.25}
    sheaf_tri = MutationSheaf(3, edges_tri, weights_tri)
    holonomy = sheaf_tri.check_holonomy([0, 1, 2])
    print(f"  Triangle with weights: 0→1: ×2, 1→2: ×3, 2→0: ×0.25")
    print(f"  Holonomy = {holonomy:.2f}")
    if abs(holonomy - 1.0) < 1e-10:
        print(f"  Holonomy = 1: consistent interpretation exists (H¹ contribution = 0)")
    else:
        print(f"  Holonomy ≠ 1: INCONSISTENCY detected (H¹ contribution > 0)")
        print(f"  The meme cannot be consistently interpreted around this cycle")


def demo_virality_duality():
    """Demonstrate the virality-barrier duality theorem."""
    print("\n" + "=" * 60)
    print("DEMO 4: Virality-Barrier Duality")
    print("Super-viral memes can't improve by proportional expansion")
    print("=" * 60)

    print("\n  Theorem: If fitness > 1 (h0 > 1 + h1), then")
    print("  adding k to both h0 and h1 DECREASES fitness.\n")

    cases = [
        (5, 0, "Super-viral: 5 interpretations, 0 barriers"),
        (3, 1, "Viral: 3 interpretations, 1 barrier"),
        (1, 2, "Sub-viral: 1 interpretation, 2 barriers"),
    ]

    for h0, h1, desc in cases:
        fit0 = meme_fitness(h0, h1)
        print(f"  {desc}")
        print(f"    fitness({h0}, {h1}) = {fit0:.3f}", end="")
        print(f" {'(> 1: super-viral)' if fit0 > 1 else '(≤ 1: sub-viral)'}")

        for k in [1, 2, 5]:
            fit_k = meme_fitness(h0 + k, h1 + k)
            direction = "↓" if fit_k < fit0 else "↑" if fit_k > fit0 else "="
            print(f"    + k={k}: fitness({h0+k}, {h1+k}) = {fit_k:.3f} {direction}")
        print()


def demo_spectral_bridge():
    """Demonstrate the spectral-cohomological bridge."""
    print("=" * 60)
    print("DEMO 5: Spectral-Cohomological Bridge")
    print("ker(Laplacian) = H⁰")
    print("=" * 60)

    n = 6
    edges = [(0, 1), (1, 2), (2, 0), (3, 4), (4, 5), (5, 3)]

    print(f"\n  Graph: Two triangles (vertices 0-2 and 3-5)")

    spectrum = laplacian_spectrum(n, edges)
    h0 = compute_h0(n, edges)

    print(f"\n  Laplacian eigenvalues: {[f'{e:.3f}' for e in spectrum]}")
    num_zero = sum(1 for e in spectrum if abs(e) < 1e-10)
    print(f"  Number of zero eigenvalues: {num_zero}")
    print(f"  dim H⁰ (connected components): {h0}")
    print(f"  Match: {'✓' if num_zero == h0 else '✗'}")

    if num_zero < len(spectrum):
        fiedler = min(e for e in spectrum if e > 1e-10)
        print(f"\n  Fiedler value (algebraic connectivity): {fiedler:.4f}")
        print(f"  Interpretation: measures 'interpretive inertia' — how hard it is")
        print(f"  to split the network into two interpretation groups")


def demo_community_analysis():
    """Demonstrate community-based meme fitness analysis."""
    print("\n" + "=" * 60)
    print("DEMO 6: Community Structure and Meme Fitness")
    print("=" * 60)

    # Graph with 3 communities, varying inter-community connectivity
    n = 12
    communities = [0]*4 + [1]*4 + [2]*4

    # Intra-community edges (each community is a complete graph)
    intra = []
    for c in range(3):
        base = c * 4
        for i in range(4):
            for j in range(i+1, 4):
                intra.append((base + i, base + j))

    scenarios = [
        ("No bridges", []),
        ("1 bridge", [(3, 4)]),
        ("2 bridges", [(3, 4), (7, 8)]),
        ("3 bridges (fully linked)", [(3, 4), (7, 8), (3, 8)]),
    ]

    for name, inter in scenarios:
        edges = intra + inter
        result = community_fitness(n, edges, communities)
        print(f"\n  {name}:")
        print(f"    dim H⁰ = {result['h0_dim']}, dim H¹ = {result['h1_dim']}")
        print(f"    fitness = {result['fitness']:.3f}")
        print(f"    inter-community edges: {result['inter_community_edges']}")
        print(f"    Euler χ = {result['euler_char']}")


if __name__ == "__main__":
    random.seed(42)
    np.random.seed(42)

    demo_component_section_isomorphism()
    demo_phase_transition()
    demo_mutation_sheaf()
    demo_virality_duality()
    demo_spectral_bridge()
    demo_community_analysis()

    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Meme Fitness Landscape

Plots the fitness function fitness(h0, h1) = h0 / (1 + h1) as a heatmap,
showing the virality-barrier duality.
"""

import numpy as np

try:
    import matplotlib.pyplot as plt
    from matplotlib import cm
    HAS_MPL = True
except ImportError:
    HAS_MPL = False


def meme_fitness(h0, h1):
    return h0 / (1 + h1)


def main():
    h0_range = np.arange(0, 21)
    h1_range = np.arange(0, 21)
    H0, H1 = np.meshgrid(h0_range, h1_range)
    F = meme_fitness(H0, H1)

    if not HAS_MPL:
        print("matplotlib not available. Printing sample data.")
        for h0 in [0, 5, 10, 15, 20]:
            for h1 in [0, 5, 10, 15, 20]:
                print(f"fitness({h0}, {h1}) = {meme_fitness(h0, h1):.2f}")
        return

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Heatmap
    ax1 = axes[0]
    im = ax1.imshow(F, origin='lower', cmap='YlOrRd', aspect='auto',
                    extent=[0, 20, 0, 20])
    ax1.set_xlabel('dim H⁰ (interpretation diversity)', fontsize=12)
    ax1.set_ylabel('dim H¹ (transmission barriers)', fontsize=12)
    ax1.set_title('Meme Fitness Landscape', fontsize=14)
    plt.colorbar(im, ax=ax1, label='Fitness = H⁰ / (1 + H¹)')

    # Contour line for fitness = 1 (super-viral threshold)
    ax1.contour(H0, H1, F, levels=[1.0], colors='white', linewidths=2, linestyles='--')
    ax1.text(15, 18, 'fitness < 1\n(sub-viral)', color='white', fontsize=10,
             ha='center', va='center')
    ax1.text(18, 2, 'fitness > 1\n(super-viral)', color='black', fontsize=10,
             ha='center', va='center')

    # Duality plot
    ax2 = axes[1]
    for h0_init, h1_init in [(10, 0), (5, 2), (2, 5)]:
        ks = range(0, 11)
        fitnesses = [meme_fitness(h0_init + k, h1_init + k) for k in ks]
        label = f'h₀={h0_init}, h₁={h1_init} (fit={meme_fitness(h0_init, h1_init):.1f})'
        ax2.plot(ks, fitnesses, 'o-', linewidth=2, markersize=4, label=label)

    ax2.axhline(y=1.0, color='gray', linestyle=':', linewidth=1, label='Super-viral threshold')
    ax2.set_xlabel('k (proportional expansion)', fontsize=12)
    ax2.set_ylabel('fitness(h₀+k, h₁+k)', fontsize=12)
    ax2.set_title('Virality-Barrier Duality', fontsize=14)
    ax2.legend(fontsize=9)

    plt.tight_layout()
    plt.savefig('fitness_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved fitness_landscape.png")
    plt.close()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Phase Transition in Meme Diversity

Plots dim H⁰ vs edge probability p for Erdős-Rényi random graphs,
showing the sharp phase transition at p = ln(n)/n.
"""

import random
import math
import numpy as np

try:
    import matplotlib.pyplot as plt
    HAS_MPL = True
except ImportError:
    HAS_MPL = False


def compute_h0_fast(n, edges):
    """Union-find based connected component counting."""
    parent = list(range(n))

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        rx, ry = find(x), find(y)
        if rx != ry:
            parent[ry] = rx

    for u, v in edges:
        union(u, v)

    return len(set(find(i) for i in range(n)))


def generate_erdos_renyi(n, p):
    """Generate G(n,p) random graph."""
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < p:
                edges.append((i, j))
    return edges


def main():
    random.seed(42)
    np.random.seed(42)

    n = 200
    threshold = math.log(n) / n
    p_values = np.linspace(0.001, 5 * threshold, 60)
    num_samples = 30

    mean_h0 = []
    std_h0 = []
    pct_connected = []

    for p in p_values:
        h0_samples = []
        for _ in range(num_samples):
            edges = generate_erdos_renyi(n, p)
            h0 = compute_h0_fast(n, edges)
            h0_samples.append(h0)
        mean_h0.append(np.mean(h0_samples))
        std_h0.append(np.std(h0_samples))
        pct_connected.append(sum(1 for h in h0_samples if h == 1) / num_samples)

    if not HAS_MPL:
        print("matplotlib not available. Printing data instead.")
        for i, p in enumerate(p_values):
            print(f"p={p:.4f}  mean_h0={mean_h0[i]:.1f}  pct_connected={pct_connected[i]:.1%}")
        return

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Plot 1: mean H⁰ vs p
    ax1.plot(p_values / threshold, mean_h0, 'b-', linewidth=2)
    ax1.fill_between(p_values / threshold,
                     np.array(mean_h0) - np.array(std_h0),
                     np.array(mean_h0) + np.array(std_h0),
                     alpha=0.2, color='blue')
    ax1.axvline(x=1.0, color='red', linestyle='--', linewidth=1.5, label='Threshold p*')
    ax1.set_xlabel('p / p* (normalized edge probability)', fontsize=12)
    ax1.set_ylabel('dim H⁰ (interpretation diversity)', fontsize=12)
    ax1.set_title(f'Phase Transition in Meme Diversity (n={n})', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.set_ylim(bottom=0)

    # Plot 2: % connected vs p
    ax2.plot(p_values / threshold, pct_connected, 'g-', linewidth=2)
    ax2.axvline(x=1.0, color='red', linestyle='--', linewidth=1.5, label='Threshold p*')
    ax2.axhline(y=0.5, color='gray', linestyle=':', linewidth=1)
    ax2.set_xlabel('p / p* (normalized edge probability)', fontsize=12)
    ax2.set_ylabel('P(graph connected) = P(dim H⁰ = 1)', fontsize=12)
    ax2.set_title('Connectivity Phase Transition', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.set_ylim(-0.05, 1.05)

    plt.tight_layout()
    plt.savefig('phase_transition.png', dpi=150, bbox_inches='tight')
    print("Saved phase_transition.png")
    plt.close()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Spectral-Cohomological Bridge

Shows the correspondence between Laplacian eigenvalues and sheaf cohomology.
"""

import numpy as np

try:
    import matplotlib.pyplot as plt
    HAS_MPL = True
except ImportError:
    HAS_MPL = False


def graph_laplacian(n, edges):
    L = np.zeros((n, n))
    for u, v in edges:
        L[u, v] -= 1
        L[v, u] -= 1
        L[u, u] += 1
        L[v, v] += 1
    return L


def compute_h0(n, edges):
    parent = list(range(n))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        rx, ry = find(x), find(y)
        if rx != ry:
            parent[ry] = rx
    for u, v in edges:
        union(u, v)
    return len(set(find(i) for i in range(n)))


def main():
    graphs = {
        'K₅ (complete)': (5, [(i,j) for i in range(5) for j in range(i+1,5)]),
        'C₆ (cycle)': (6, [(i,(i+1)%6) for i in range(6)]),
        'P₅ (path)': (5, [(i,i+1) for i in range(4)]),
        '2×K₃ (2 triangles)': (6, [(0,1),(1,2),(2,0),(3,4),(4,5),(5,3)]),
        'K₃ + K₂ + K₁': (6, [(0,1),(1,2),(2,0),(3,4)]),
        'Star S₅': (5, [(0,i) for i in range(1,5)]),
    }

    if not HAS_MPL:
        print("matplotlib not available. Printing spectral data.")
        for name, (n, edges) in graphs.items():
            L = graph_laplacian(n, edges)
            evals = np.sort(np.linalg.eigvalsh(L))
            h0 = compute_h0(n, edges)
            print(f"{name}: h0={h0}, eigenvalues={[f'{e:.3f}' for e in evals]}")
        return

    fig, axes = plt.subplots(2, 3, figsize=(15, 8))
    axes = axes.flatten()

    for idx, (name, (n, edges)) in enumerate(graphs.items()):
        ax = axes[idx]
        L = graph_laplacian(n, edges)
        evals = np.sort(np.linalg.eigvalsh(L))
        h0 = compute_h0(n, edges)
        h1 = len(edges) - n + h0

        colors = ['red' if abs(e) < 1e-10 else 'steelblue' for e in evals]
        ax.bar(range(len(evals)), evals, color=colors, edgecolor='black', linewidth=0.5)
        ax.set_title(f'{name}\nH⁰={h0}, H¹={h1}', fontsize=11)
        ax.set_xlabel('Eigenvalue index', fontsize=9)
        ax.set_ylabel('λ', fontsize=10)
        ax.axhline(y=0, color='gray', linewidth=0.5)

        # Annotate zero eigenvalues
        num_zero = sum(1 for e in evals if abs(e) < 1e-10)
        ax.text(0.02, 0.95, f'{num_zero} zero eigenvalue{"s" if num_zero > 1 else ""}',
                transform=ax.transAxes, fontsize=8, verticalalignment='top',
                color='red', fontweight='bold')

    plt.suptitle('Spectral-Cohomological Bridge: ker(L) = H⁰', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('spectral_bridge.png', dpi=150, bbox_inches='tight')
    print("Saved spectral_bridge.png")
    plt.close()


if __name__ == "__main__":
    main()
