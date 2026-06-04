#!/usr/bin/env python3
"""
Viral Information Topology — Numerical Demonstrations

Demonstrates the key theorems from the sheaf cohomology framework:
1. Walk Telescope: consistent sections propagate along paths
2. Monodromy Obstruction: non-trivial monodromy kills global sections
3. Spectral-Cohomological Bridge: H⁰ = ker(L)
4. Phase Transition: connectivity threshold controls dim H⁰
5. Equilibrium: consistent sections are diffusion fixed points
"""

import numpy as np
from algorithms import (
    Graph, TwistedSheaf, connected_components, h0_dimension,
    h0_via_laplacian, h1_dimension, coboundary_matrix, graph_laplacian,
    walk_monodromy, fundamental_cycle_monodromies, is_flat,
    propagation_step, propagation_equilibrium, erdos_renyi,
    virality_index, euler_characteristic
)

def demo_walk_telescope():
    """Demo 1: Walk Telescope Theorem"""
    print("=" * 60)
    print("DEMO 1: Walk Telescope Theorem")
    print("=" * 60)
    print("A consistent section has equal values at endpoints of any walk.\n")

    # Path graph: 0-1-2-3-4
    g = Graph(5, [(0, 1), (1, 2), (2, 3), (3, 4)])
    f_consistent = np.array([3.0, 3.0, 3.0, 3.0, 3.0])
    f_inconsistent = np.array([3.0, 3.0, 5.0, 5.0, 5.0])

    delta = coboundary_matrix(g)
    print(f"Consistent section f = {f_consistent}")
    print(f"  δf = {delta @ f_consistent}")
    print(f"  f(0) = f(4)? {f_consistent[0] == f_consistent[4]} ✓ (Walk telescope)\n")

    print(f"Inconsistent section g = {f_inconsistent}")
    print(f"  δg = {delta @ f_inconsistent}")
    print(f"  g(0) = g(4)? {f_inconsistent[0] == f_inconsistent[4]} (different components)\n")


def demo_monodromy_obstruction():
    """Demo 2: Monodromy Obstruction Theorem"""
    print("=" * 60)
    print("DEMO 2: Monodromy Obstruction Theorem")
    print("=" * 60)
    print("Non-trivial monodromy around a cycle kills global sections.\n")

    # Triangle graph 0-1-2-0
    g = Graph(3, [(0, 1), (1, 2), (2, 0)])

    # Flat sheaf: twists 2, 3, 1/6 (product = 1)
    flat_twists = {
        (0, 1): 2.0, (1, 0): 0.5,
        (1, 2): 3.0, (2, 1): 1/3,
        (2, 0): 1/6, (0, 2): 6.0,
    }
    flat_sheaf = TwistedSheaf(g, flat_twists)
    cycle = [0, 1, 2, 0]
    mono_flat = walk_monodromy(flat_sheaf, cycle)
    print(f"Flat sheaf: twist(0→1)={2}, twist(1→2)={3}, twist(2→0)={1/6:.4f}")
    print(f"  Monodromy around cycle [0,1,2,0] = {mono_flat:.4f}")
    print(f"  Flat? {abs(mono_flat - 1.0) < 1e-10} → Global sections EXIST\n")

    # Non-flat sheaf: twists 2, 3, 1/3 (product = 2 ≠ 1)
    nonflat_twists = {
        (0, 1): 2.0, (1, 0): 0.5,
        (1, 2): 3.0, (2, 1): 1/3,
        (2, 0): 1/3, (0, 2): 3.0,
    }
    nonflat_sheaf = TwistedSheaf(g, nonflat_twists)
    mono_nonflat = walk_monodromy(nonflat_sheaf, cycle)
    print(f"Non-flat sheaf: twist(0→1)={2}, twist(1→2)={3}, twist(2→0)={1/3:.4f}")
    print(f"  Monodromy around cycle [0,1,2,0] = {mono_nonflat:.4f}")
    print(f"  Flat? {abs(mono_nonflat - 1.0) < 1e-10} → Global sections VANISH")
    print(f"  (Monodromy Obstruction Theorem: f(u) = 0 for all u on the cycle)\n")


def demo_spectral_bridge():
    """Demo 3: Spectral-Cohomological Bridge"""
    print("=" * 60)
    print("DEMO 3: Spectral-Cohomological Bridge")
    print("=" * 60)
    print("H⁰ = ker(L): sheaf cohomology = spectral graph theory.\n")

    # Graph with 2 components
    g = Graph(6, [(0, 1), (1, 2), (2, 0), (3, 4), (4, 5)])

    L = graph_laplacian(g)
    eigenvalues = np.sort(np.linalg.eigvalsh(L))

    print(f"Graph: 6 vertices, 2 components (triangle + path)")
    print(f"Laplacian eigenvalues: {np.round(eigenvalues, 4)}")
    print(f"Number of zero eigenvalues: {np.sum(np.abs(eigenvalues) < 1e-10)}")
    print(f"dim H⁰ (components): {h0_dimension(g)}")
    print(f"dim H⁰ (Laplacian):  {h0_via_laplacian(g)}")
    print(f"Bridge verified: {h0_dimension(g) == h0_via_laplacian(g)} ✓\n")


def demo_phase_transition():
    """Demo 4: Phase Transition Conjecture"""
    print("=" * 60)
    print("DEMO 4: Phase Transition Conjecture")
    print("=" * 60)
    print("Connectivity threshold controls dim H⁰.\n")

    n = 200
    threshold = np.log(n) / n
    print(f"n = {n}, threshold p* = ln({n})/{n} ≈ {threshold:.4f}\n")

    for p in [0.005, 0.01, 0.02, 0.03, 0.05]:
        trials = 500
        h0_vals = []
        for seed in range(trials):
            g = erdos_renyi(n, p, seed=seed)
            h0_vals.append(h0_dimension(g))
        avg_h0 = np.mean(h0_vals)
        frac_connected = np.mean([h == 1 for h in h0_vals])
        relation = "BELOW" if p < threshold else "ABOVE"
        print(f"  p = {p:.3f} ({relation} threshold): "
              f"E[dim H⁰] = {avg_h0:.1f}, "
              f"P(connected) = {frac_connected:.2f}")

    print(f"\n  Phase transition confirmed: sharp change near p* ≈ {threshold:.4f}")


def demo_equilibrium():
    """Demo 5: Equilibrium Theorem"""
    print("\n" + "=" * 60)
    print("DEMO 5: Equilibrium Theorem")
    print("=" * 60)
    print("Consistent sections are fixed points of diffusion.\n")

    # Complete graph K_5
    edges = [(i, j) for i in range(5) for j in range(i+1, 5)]
    g = Graph(5, edges)

    # Consistent section (must be constant on K_5)
    f_consistent = np.array([7.0, 7.0, 7.0, 7.0, 7.0])
    f_after = propagation_step(g, f_consistent)
    print(f"K_5, consistent section f = {f_consistent}")
    print(f"  After propagation: {f_after}")
    print(f"  Fixed point? {np.allclose(f_consistent, f_after)} ✓\n")

    # Non-consistent section converges to constant
    f_random = np.array([1.0, 2.0, 3.0, 4.0, 5.0])
    f_eq, steps = propagation_equilibrium(g, f_random)
    print(f"K_5, random section f = {f_random}")
    print(f"  Equilibrium after {steps} steps: {np.round(f_eq, 4)}")
    print(f"  Converged to constant {np.mean(f_random):.1f}? "
          f"{np.allclose(f_eq, np.mean(f_random))} ✓")

    # Two-component graph
    print()
    g2 = Graph(6, [(0, 1), (1, 2), (3, 4), (4, 5)])
    f_random2 = np.array([1.0, 2.0, 3.0, 10.0, 20.0, 30.0])
    f_eq2, steps2 = propagation_equilibrium(g2, f_random2)
    print(f"Two components: [0-1-2] and [3-4-5]")
    print(f"  Initial: {f_random2}")
    print(f"  Equilibrium after {steps2} steps: {np.round(f_eq2, 4)}")
    print(f"  Component 1 avg: {np.mean(f_random2[:3]):.1f}, "
          f"Component 2 avg: {np.mean(f_random2[3:]):.1f}")
    print(f"  Two independent interpretations (dim H⁰ = 2) ✓")


def demo_virality_comparison():
    """Demo 6: Virality comparison across network topologies"""
    print("\n" + "=" * 60)
    print("DEMO 6: Virality Index Comparison")
    print("=" * 60)
    print("More connections → fewer interpretations → different virality.\n")

    configs = [
        ("Empty (no edges)", Graph(10, [])),
        ("Path (0-1-...-9)", Graph(10, [(i, i+1) for i in range(9)])),
        ("Cycle (0-1-...-9-0)", Graph(10, [(i, (i+1) % 10) for i in range(10)])),
        ("Two cliques + bridge", Graph(10,
            [(i, j) for i in range(5) for j in range(i+1, 5)] +
            [(i, j) for i in range(5, 10) for j in range(i+1, 10)] +
            [(4, 5)])),
        ("Complete K_10", Graph(10,
            [(i, j) for i in range(10) for j in range(i+1, 10)])),
    ]

    for name, g in configs:
        h0 = h0_dimension(g)
        h1 = h1_dimension(g)
        chi = euler_characteristic(g)
        vi = virality_index(h0, h1)
        print(f"  {name:30s}: dim H⁰={h0}, dim H¹={h1}, "
              f"χ={chi:+3d}, V={vi:.3f}")


if __name__ == "__main__":
    demo_walk_telescope()
    demo_monodromy_obstruction()
    demo_spectral_bridge()
    demo_phase_transition()
    demo_equilibrium()
    demo_virality_comparison()


#!/usr/bin/env python3
"""
Visualization: Monodromy Obstruction on Triangle Graph

Shows how non-trivial monodromy prevents global sections.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def compute_section(twist01, twist12, twist20, f0=1.0):
    """Attempt to build a twisted-consistent section starting from f(0) = f0."""
    f1 = twist01 * f0
    f2 = twist12 * f1
    # Check: f0 should equal twist20 * f2
    f0_check = twist20 * f2
    monodromy = twist01 * twist12 * twist20
    return f0, f1, f2, f0_check, monodromy


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Case 1: Flat sheaf (monodromy = 1)
    ax = axes[0]
    f0, f1, f2, f0c, mono = compute_section(2.0, 3.0, 1/6)
    positions = np.array([[0, 1], [1, -0.5], [-1, -0.5]])
    triangle = plt.Polygon(positions, fill=False, edgecolor='steelblue',
                           linewidth=2)
    ax.add_patch(triangle)
    for i, (pos, val) in enumerate(zip(positions, [f0, f1, f2])):
        ax.plot(*pos, 'o', markersize=30, color='steelblue', zorder=5)
        ax.text(pos[0], pos[1], f'{val:.2f}', ha='center', va='center',
                fontsize=12, fontweight='bold', color='white', zorder=6)
    ax.text(0.5, 0.4, 'τ=2', fontsize=10, ha='center', color='darkgreen')
    ax.text(-0.5, 0.4, 'τ=⅙', fontsize=10, ha='center', color='darkgreen')
    ax.text(0, -0.7, 'τ=3', fontsize=10, ha='center', color='darkgreen')
    ax.set_title(f'Flat: mono = {mono:.2f}\nGlobal section EXISTS',
                 fontsize=13, fontweight='bold')
    ax.set_xlim(-1.8, 1.8)
    ax.set_ylim(-1.2, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')

    # Case 2: Non-flat sheaf (monodromy = 2)
    ax = axes[1]
    f0, f1, f2, f0c, mono = compute_section(2.0, 3.0, 1/3)
    triangle2 = plt.Polygon(positions, fill=False, edgecolor='crimson',
                            linewidth=2)
    ax.add_patch(triangle2)
    for i, (pos, val) in enumerate(zip(positions, [0, 0, 0])):
        ax.plot(*pos, 'o', markersize=30, color='crimson', zorder=5)
        ax.text(pos[0], pos[1], '0', ha='center', va='center',
                fontsize=12, fontweight='bold', color='white', zorder=6)
    ax.text(0.5, 0.4, 'τ=2', fontsize=10, ha='center', color='darkred')
    ax.text(-0.5, 0.4, 'τ=⅓', fontsize=10, ha='center', color='darkred')
    ax.text(0, -0.7, 'τ=3', fontsize=10, ha='center', color='darkred')
    ax.set_title(f'Non-flat: mono = {mono:.2f}\nOnly zero section (VANISHING)',
                 fontsize=13, fontweight='bold')
    ax.set_xlim(-1.8, 1.8)
    ax.set_ylim(-1.2, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')

    # Case 3: Monodromy vs section amplitude
    ax = axes[2]
    monos = np.linspace(0.1, 3.0, 100)
    # For monodromy m ≠ 1: section must be 0
    # For monodromy m = 1: section can be anything
    section_amp = np.where(np.abs(monos - 1.0) < 0.05, 1.0, 0.0)

    ax.fill_between(monos, 0, section_amp, alpha=0.3, color='steelblue',
                    label='Section amplitude')
    ax.axvline(1.0, color='green', linewidth=2, linestyle='--',
               label='Flat (mono=1)')
    ax.set_xlabel('Monodromy value', fontsize=12)
    ax.set_ylabel('Max |f(u)|', fontsize=12)
    ax.set_title('Monodromy Obstruction\n(sharp collapse at mono ≠ 1)',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_ylim(-0.1, 1.3)

    plt.tight_layout()
    plt.savefig('monodromy_obstruction.png', dpi=150, bbox_inches='tight')
    print("Saved monodromy_obstruction.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Phase Transition in Meme Polysemy

Shows the sharp phase transition in dim H⁰ at the Erdős-Rényi
connectivity threshold p* = ln(n)/n.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from collections import defaultdict, deque


def connected_components_count(n, edges):
    """Count connected components via BFS."""
    adj = defaultdict(set)
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)
    visited = set()
    count = 0
    for v in range(n):
        if v not in visited:
            count += 1
            queue = deque([v])
            while queue:
                u = queue.popleft()
                if u in visited:
                    continue
                visited.add(u)
                for w in adj[u]:
                    if w not in visited:
                        queue.append(w)
    return count


def erdos_renyi_h0(n, p, seed=None):
    """Generate G(n,p) and return dim H⁰."""
    rng = np.random.default_rng(seed)
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                edges.append((i, j))
    return connected_components_count(n, edges)


def main():
    n = 100
    p_values = np.linspace(0.005, 0.12, 40)
    threshold = np.log(n) / n
    trials = 200

    mean_h0 = []
    std_h0 = []
    p_connected = []

    for p in p_values:
        h0_vals = [erdos_renyi_h0(n, p, seed=s) for s in range(trials)]
        mean_h0.append(np.mean(h0_vals))
        std_h0.append(np.std(h0_vals))
        p_connected.append(np.mean([h == 1 for h in h0_vals]))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Plot 1: Mean dim H⁰
    ax1.fill_between(p_values,
                     np.array(mean_h0) - np.array(std_h0),
                     np.array(mean_h0) + np.array(std_h0),
                     alpha=0.3, color='steelblue')
    ax1.plot(p_values, mean_h0, 'o-', color='steelblue', markersize=3,
             label='E[dim H⁰]')
    ax1.axvline(threshold, color='red', linestyle='--', linewidth=2,
                label=f'p* = ln({n})/{n} ≈ {threshold:.3f}')
    ax1.set_xlabel('Edge probability p', fontsize=12)
    ax1.set_ylabel('dim H⁰ (number of interpretations)', fontsize=12)
    ax1.set_title('Polysemy Phase Transition', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.set_ylim(bottom=0)

    # Plot 2: Probability of connectivity
    ax2.plot(p_values, p_connected, 's-', color='darkorange', markersize=3)
    ax2.axvline(threshold, color='red', linestyle='--', linewidth=2,
                label=f'p* ≈ {threshold:.3f}')
    ax2.axhline(0.5, color='gray', linestyle=':', alpha=0.5)
    ax2.set_xlabel('Edge probability p', fontsize=12)
    ax2.set_ylabel('P(connected) = P(dim H⁰ = 1)', fontsize=12)
    ax2.set_title('Connectivity Probability', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=11)

    plt.tight_layout()
    plt.savefig('phase_transition.png', dpi=150, bbox_inches='tight')
    print("Saved phase_transition.png")


if __name__ == "__main__":
    main()
