#!/usr/bin/env python3
"""
Integrated Information as a Topological Invariant: Demonstrations

Computes Phi (integrated information) = beta_1 (first Betti number)
for various graph topologies, demonstrating the key results from the
formal verification.
"""

import itertools
from typing import List, Tuple, Set


def betti_one(num_vertices: int, num_edges: int) -> int:
    """First Betti number for a connected graph.
    
    beta_1 = |E| - |V| + 1 = number of independent cycles.
    """
    assert num_edges >= num_vertices - 1, "Graph must be connected"
    return num_edges - num_vertices + 1


def phi(num_vertices: int, num_edges: int) -> int:
    """Integrated information Phi = beta_1."""
    return betti_one(num_vertices, num_edges)


def complete_graph_edges(n: int) -> int:
    """Number of edges in K_n."""
    return n * (n - 1) // 2


def complete_graph_phi(n: int) -> int:
    """Phi for the complete graph K_n."""
    if n <= 1:
        return 0
    return (n - 1) * (n - 2) // 2


def cycle_graph_phi(n: int) -> int:
    """Phi for the cycle graph C_n (n >= 3)."""
    assert n >= 3, "Cycle graph needs >= 3 vertices"
    return 1  # Always 1


def euler_relation(num_vertices: int, num_edges: int) -> bool:
    """Verify |V| - |E| = 1 - Phi for connected graphs."""
    p = phi(num_vertices, num_edges)
    return num_vertices - num_edges == 1 - p


# ============================================================
# Demonstrations
# ============================================================

def demo_tree():
    """Theorem 1: Trees have Phi = 0."""
    print("=" * 60)
    print("THEOREM 1: Trees have Phi = 0")
    print("=" * 60)
    for n in range(1, 11):
        edges = n - 1  # Tree on n vertices has n-1 edges
        p = phi(n, edges) if n >= 1 else 0
        print(f"  Path graph P_{n}: |V|={n}, |E|={edges}, Phi={p}")
    print()


def demo_cycles():
    """Theorem 2: Cycle graphs have Phi = 1."""
    print("=" * 60)
    print("THEOREM 2: Cycle graphs have Phi = 1")
    print("=" * 60)
    for n in range(3, 13):
        edges = n  # Cycle on n vertices has n edges
        p = phi(n, edges)
        print(f"  Cycle graph C_{n}: |V|={n}, |E|={edges}, Phi={p}")
    print()


def demo_complete():
    """Theorem 3: Complete graphs have Phi = (n-1)(n-2)/2."""
    print("=" * 60)
    print("THEOREM 3: Complete graphs K_n have Phi = (n-1)(n-2)/2")
    print("=" * 60)
    for n in range(1, 13):
        edges = complete_graph_edges(n)
        p = complete_graph_phi(n)
        formula = f"({n}-1)({n}-2)/2 = {p}"
        print(f"  K_{n:2d}: |V|={n:2d}, |E|={edges:3d}, Phi={p:3d}  [{formula}]")
    print()


def demo_euler():
    """Theorem 5: Euler relation |V| - |E| = 1 - Phi."""
    print("=" * 60)
    print("THEOREM 5: Euler relation |V| - |E| = 1 - Phi")
    print("=" * 60)
    test_cases = [
        ("Path P_5", 5, 4),
        ("Cycle C_6", 6, 6),
        ("K_5", 5, 10),
        ("K_10", 10, 45),
        ("Petersen", 10, 15),  # Petersen graph
    ]
    for name, v, e in test_cases:
        p = phi(v, e)
        lhs = v - e
        rhs = 1 - p
        check = "✓" if lhs == rhs else "✗"
        print(f"  {name:12s}: |V|-|E| = {v}-{e} = {lhs:3d}, "
              f"1-Phi = 1-{p} = {rhs:3d}  [{check}]")
    print()


def demo_uniform_sheaf():
    """Theorem 6: Uniform sheaf dim H^1 = d * beta_1."""
    print("=" * 60)
    print("THEOREM 6: Uniform sheaf dim H^1 = d * beta_1")
    print("=" * 60)
    for d in [1, 2, 3, 5]:
        for name, v, e in [("C_5", 5, 5), ("K_4", 4, 6), ("K_5", 5, 10)]:
            b1 = phi(v, e)
            dimH1 = d * b1
            print(f"  d={d}, {name}: beta_1={b1}, dim H^1 = {d}*{b1} = {dimH1}")
    print()


def demo_quadratic_scaling():
    """Demonstrate quadratic scaling of Phi for complete graphs."""
    print("=" * 60)
    print("SCALING: Phi grows quadratically for complete graphs")
    print("=" * 60)
    for n in [10, 50, 100, 500, 1000]:
        p = complete_graph_phi(n)
        ratio = p / n**2 if n > 0 else 0
        print(f"  K_{n:4d}: Phi = {p:>10,d}  "
              f"(Phi/n^2 = {ratio:.4f}, approaches 0.5)")
    print()


def demo_consciousness_spectrum():
    """Show the spectrum of Phi for different architectures."""
    print("=" * 60)
    print("CONSCIOUSNESS SPECTRUM: Phi for various architectures")
    print("=" * 60)
    
    architectures = [
        ("Chain (feedforward)", 10, 9, "No cycles, no integration"),
        ("Ring (recurrent)", 10, 10, "One cycle, minimal integration"),
        ("Binary tree", 15, 14, "Hierarchical, no integration"),
        ("Ladder graph", 10, 13, "Two cycles, moderate integration"),
        ("Grid 3x3", 9, 12, "Several cycles"),
        ("Cube graph", 8, 12, "Complex 3D structure"),
        ("Petersen graph", 10, 15, "High symmetry, many cycles"),
        ("Complete K_5", 5, 10, "Maximal for 5 nodes"),
        ("Complete K_10", 10, 45, "Maximal for 10 nodes"),
    ]
    
    for name, v, e, desc in architectures:
        p = phi(v, e)
        bar = "█" * p + "░" * max(0, 36 - p)
        print(f"  {name:22s} Phi={p:3d} |{bar[:36]}| {desc}")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("INTEGRATED INFORMATION AS A TOPOLOGICAL INVARIANT")
    print("Phi = beta_1 = dim H^1 = |E| - |V| + 1")
    print("=" * 60 + "\n")
    
    demo_tree()
    demo_cycles()
    demo_complete()
    demo_euler()
    demo_uniform_sheaf()
    demo_quadratic_scaling()
    demo_consciousness_spectrum()
    
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""Visualization: Phi scaling for different graph families."""
import matplotlib.pyplot as plt
import numpy as np

def main():
    ns = np.arange(1, 21)
    
    # Phi for different graph families
    phi_tree = np.zeros_like(ns)
    phi_cycle = np.array([0 if n < 3 else 1 for n in ns])
    phi_complete = np.array([(n-1)*(n-2)//2 for n in ns])
    phi_grid = np.array([max(0, 2*(n-1) + 1 - 2*n + 1) if n >= 2 else 0 for n in ns])
    # For an n x n grid: |V| = n^2, |E| = 2n(n-1), phi = 2n(n-1) - n^2 + 1 = (n-1)^2
    phi_grid_sq = np.array([(n-1)**2 for n in ns])
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: Linear scale
    ax1.plot(ns, phi_tree, 'o-', label='Path/Tree ($\\Phi = 0$)', linewidth=2, markersize=6)
    ax1.plot(ns, phi_cycle, 's-', label='Cycle ($\\Phi = 1$)', linewidth=2, markersize=6)
    ax1.plot(ns[1:], phi_grid_sq[1:], 'D-', label='$n \\times n$ Grid ($\\Phi = (n-1)^2$)', linewidth=2, markersize=6)
    ax1.plot(ns, phi_complete, '^-', label='Complete $K_n$ ($\\Phi = \\frac{(n-1)(n-2)}{2}$)', linewidth=2, markersize=6)
    ax1.set_xlabel('Network size $n$', fontsize=13)
    ax1.set_ylabel('$\\Phi$ (Integrated Information)', fontsize=13)
    ax1.set_title('Integrated Information by Graph Topology', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    
    # Right: Normalized by n^2
    ax2.plot(ns[2:], phi_tree[2:] / ns[2:]**2, 'o-', label='Tree', linewidth=2, markersize=6)
    ax2.plot(ns[2:], phi_cycle[2:] / ns[2:]**2, 's-', label='Cycle', linewidth=2, markersize=6)
    ax2.plot(ns[2:], phi_grid_sq[2:] / ns[2:]**2, 'D-', label='Grid', linewidth=2, markersize=6)
    ax2.plot(ns[2:], phi_complete[2:] / ns[2:]**2, '^-', label='Complete', linewidth=2, markersize=6)
    ax2.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5, label='$\\Phi/n^2 \\to 1/2$')
    ax2.set_xlabel('Network size $n$', fontsize=13)
    ax2.set_ylabel('$\\Phi / n^2$ (Normalized)', fontsize=13)
    ax2.set_title('Normalized Integration Density', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('phi_scaling.png', dpi=150, bbox_inches='tight')
    print("Saved phi_scaling.png")

if __name__ == "__main__":
    main()
