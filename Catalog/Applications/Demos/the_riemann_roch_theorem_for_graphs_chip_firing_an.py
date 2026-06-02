#!/usr/bin/env python3
"""
Chip-Firing and Graph Riemann-Roch: Demonstration

Demonstrates the key results from our formalization:
1. Chip-firing conservation law
2. Canonical divisor degree = 2g - 2
3. Complete graph genus formula
4. Riemann-Roch degree identity
"""

import numpy as np
from typing import List, Tuple, Dict


def complete_graph_adjacency(n: int) -> np.ndarray:
    """Adjacency matrix of K_n."""
    return np.ones((n, n), dtype=int) - np.eye(n, dtype=int)


def graph_laplacian(adj: np.ndarray) -> np.ndarray:
    """Laplacian matrix L = D - A where D is degree matrix."""
    degrees = adj.sum(axis=1)
    return np.diag(degrees) - adj


def canonical_divisor(adj: np.ndarray) -> np.ndarray:
    """Canonical divisor K_G: K_G(v) = deg(v) - 2 for each vertex."""
    degrees = adj.sum(axis=1)
    return degrees - 2


def graph_genus(adj: np.ndarray) -> int:
    """Genus g = |E| - |V| + 1."""
    n = adj.shape[0]
    num_edges = adj.sum() // 2  # Each edge counted twice
    return num_edges - n + 1


def chip_fire(divisor: np.ndarray, adj: np.ndarray, vertex: int) -> np.ndarray:
    """Fire vertex v: sends one chip along each edge."""
    result = divisor.copy()
    degree = adj[vertex].sum()
    result[vertex] -= degree
    for w in range(len(divisor)):
        if adj[vertex][w]:
            result[w] += 1
    return result


def divisor_degree(divisor: np.ndarray) -> int:
    """Total number of chips."""
    return int(divisor.sum())


def demo_conservation():
    """Demonstrate chip-firing conservation law."""
    print("=" * 60)
    print("THEOREM: Chip-firing preserves degree")
    print("=" * 60)
    
    for n in [3, 4, 5, 6]:
        adj = complete_graph_adjacency(n)
        # Random initial divisor
        D = np.array([i - n//2 for i in range(n)])
        deg_before = divisor_degree(D)
        
        print(f"\nK_{n}: Initial divisor = {D}, degree = {deg_before}")
        
        # Fire each vertex in sequence
        current = D.copy()
        for v in range(n):
            current = chip_fire(current, adj, v)
            deg_after = divisor_degree(current)
            assert deg_after == deg_before, "Conservation violated!"
        
        print(f"  After firing all vertices: {current}, degree = {divisor_degree(current)}")
        print(f"  Conservation verified ✓")


def demo_canonical_degree():
    """Demonstrate deg(K_G) = 2g - 2."""
    print("\n" + "=" * 60)
    print("THEOREM: deg(K_G) = 2g - 2")
    print("=" * 60)
    
    for n in range(2, 9):
        adj = complete_graph_adjacency(n)
        K = canonical_divisor(adj)
        g = graph_genus(adj)
        deg_K = divisor_degree(K)
        expected = 2 * g - 2
        
        print(f"K_{n}: K_G = {K}, deg(K_G) = {deg_K}, "
              f"genus = {g}, 2g-2 = {expected}, "
              f"{'✓' if deg_K == expected else '✗'}")
        assert deg_K == expected


def demo_complete_graph_genus():
    """Demonstrate g(K_n) = (n-1)(n-2)/2."""
    print("\n" + "=" * 60)
    print("THEOREM: g(K_n) = (n-1)(n-2)/2")
    print("=" * 60)
    
    for n in range(2, 12):
        adj = complete_graph_adjacency(n)
        g = graph_genus(adj)
        formula = (n - 1) * (n - 2) // 2
        
        edges = n * (n - 1) // 2
        print(f"K_{n:2d}: |E| = {edges:3d}, |V| = {n:2d}, "
              f"genus = {g:3d}, (n-1)(n-2)/2 = {formula:3d}, "
              f"{'✓' if g == formula else '✗'}")
        assert g == formula


def demo_riemann_roch_identity():
    """Demonstrate the Riemann-Roch degree identity for K_G."""
    print("\n" + "=" * 60)
    print("THEOREM: deg(K_G) + 1 - g = g - 1")
    print("=" * 60)
    
    for n in range(2, 9):
        adj = complete_graph_adjacency(n)
        K = canonical_divisor(adj)
        g = graph_genus(adj)
        deg_K = divisor_degree(K)
        
        lhs = deg_K + 1 - g
        rhs = g - 1
        
        print(f"K_{n}: deg(K) + 1 - g = {deg_K} + 1 - {g} = {lhs}, "
              f"g - 1 = {rhs}, {'✓' if lhs == rhs else '✗'}")
        assert lhs == rhs


def demo_chip_firing_complete():
    """Demonstrate chip-firing structure on complete graphs."""
    print("\n" + "=" * 60)
    print("THEOREM: On K_n, firing sends exactly 1 chip to each neighbor")
    print("=" * 60)
    
    for n in [3, 4, 5]:
        adj = complete_graph_adjacency(n)
        D = np.arange(n, dtype=int) * 2  # Some divisor
        
        print(f"\nK_{n}: D = {D}")
        for v in range(min(n, 3)):  # Show a few firings
            D_new = chip_fire(D, adj, v)
            changes = D_new - D
            print(f"  Fire v={v}: change = {changes}")
            assert changes[v] == -(n - 1), "Wrong loss!"
            for w in range(n):
                if w != v:
                    assert changes[w] == 1, "Wrong gain!"
            D = D_new


def demo_jacobian_structure():
    """Compute the Jacobian group structure for small complete graphs."""
    print("\n" + "=" * 60)
    print("JACOBIAN GROUP of K_n")
    print("=" * 60)
    
    for n in range(3, 8):
        adj = complete_graph_adjacency(n)
        L = graph_laplacian(adj)
        
        # Reduced Laplacian (remove last row and column)
        L_red = L[:-1, :-1]
        
        # Number of spanning trees = det(reduced Laplacian)
        det = int(round(np.linalg.det(L_red)))
        cayley = n ** (n - 2)
        
        print(f"K_{n}: det(L̃) = {det:6d}, n^(n-2) = {cayley:6d}, "
              f"{'✓' if det == cayley else '✗'} "
              f"(Cayley's formula)")


if __name__ == "__main__":
    print("GRAPH RIEMANN-ROCH: NUMERICAL DEMONSTRATIONS")
    print("=" * 60)
    
    demo_conservation()
    demo_canonical_degree()
    demo_complete_graph_genus()
    demo_riemann_roch_identity()
    demo_chip_firing_complete()
    demo_jacobian_structure()
    
    print("\n" + "=" * 60)
    print("ALL DEMONSTRATIONS PASSED ✓")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Chip-Firing on Complete Graphs

Creates a visualization of chip-firing dynamics on K_5,
showing how the canonical divisor evolves under firing.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from typing import List, Tuple


def complete_graph_adjacency(n: int) -> np.ndarray:
    return np.ones((n, n), dtype=int) - np.eye(n, dtype=int)


def chip_fire(D: np.ndarray, adj: np.ndarray, v: int) -> np.ndarray:
    result = D.copy()
    degree = int(adj[v].sum())
    result[v] -= degree
    for w in range(len(D)):
        if adj[v][w]:
            result[w] += 1
    return result


def vertex_positions(n: int) -> List[Tuple[float, float]]:
    """Arrange n vertices in a regular polygon."""
    angles = [2 * np.pi * i / n - np.pi / 2 for i in range(n)]
    return [(np.cos(a), np.sin(a)) for a in angles]


def draw_chip_state(ax, n: int, D: np.ndarray, positions: List[Tuple[float, float]],
                    title: str, adj: np.ndarray):
    """Draw a graph state with chip counts."""
    ax.set_xlim(-1.8, 1.8)
    ax.set_ylim(-1.8, 1.8)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=11, fontweight='bold')
    ax.axis('off')
    
    # Draw edges
    for i in range(n):
        for j in range(i + 1, n):
            if adj[i][j]:
                ax.plot([positions[i][0], positions[j][0]],
                       [positions[i][1], positions[j][1]],
                       'gray', linewidth=0.8, alpha=0.5)
    
    # Draw vertices
    max_chips = max(abs(D[i]) for i in range(n))
    for i in range(n):
        x, y = positions[i]
        # Color based on chip count
        if D[i] > 0:
            color = plt.cm.Blues(0.3 + 0.7 * D[i] / max(max_chips, 1))
        elif D[i] < 0:
            color = plt.cm.Reds(0.3 + 0.7 * abs(D[i]) / max(max_chips, 1))
        else:
            color = 'lightyellow'
        
        circle = plt.Circle((x, y), 0.25, facecolor=color,
                            edgecolor='black', linewidth=1.5)
        ax.add_patch(circle)
        ax.text(x, y, str(D[i]), ha='center', va='center',
               fontsize=14, fontweight='bold')
        ax.text(x, y - 0.4, f'v{i}', ha='center', va='center',
               fontsize=8, color='gray')


def main():
    n = 5
    adj = complete_graph_adjacency(n)
    positions = vertex_positions(n)
    
    # Start with canonical divisor of K_5: each vertex gets n-3 = 2 chips
    D = np.array([2, 2, 2, 2, 2])
    
    # Sequence of firings
    firing_sequence = [0, 1, 2]
    
    fig, axes = plt.subplots(1, len(firing_sequence) + 1, figsize=(4 * (len(firing_sequence) + 1), 4))
    
    draw_chip_state(axes[0], n, D, positions,
                   f'K₅ Canonical Divisor\ndeg = {D.sum()}, g = {(n-1)*(n-2)//2}',
                   adj)
    
    for idx, v in enumerate(firing_sequence):
        D = chip_fire(D, adj, v)
        draw_chip_state(axes[idx + 1], n, D, positions,
                       f'After firing v{v}\ndeg = {D.sum()}',
                       adj)
    
    plt.suptitle('Chip-Firing on K₅: Conservation of Degree', fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('chipfiring_K5.png', dpi=150, bbox_inches='tight')
    plt.close()
    
    # Second plot: genus formula
    ns = list(range(2, 15))
    genera = [(k - 1) * (k - 2) // 2 for k in ns]
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    
    ax1.bar(ns, genera, color='steelblue', edgecolor='navy', alpha=0.8)
    ax1.set_xlabel('n (vertices)', fontsize=12)
    ax1.set_ylabel('Genus g(Kₙ)', fontsize=12)
    ax1.set_title('Genus of Complete Graphs\ng(Kₙ) = (n-1)(n-2)/2', fontsize=13, fontweight='bold')
    ax1.grid(axis='y', alpha=0.3)
    
    # Third: canonical degree
    can_degs = [k * (k - 3) for k in ns]
    two_g_minus_2 = [2 * g - 2 for g in genera]
    
    ax2.plot(ns, can_degs, 'bo-', label='deg(K_G) = n(n-3)', markersize=8)
    ax2.plot(ns, two_g_minus_2, 'rx--', label='2g - 2', markersize=8)
    ax2.set_xlabel('n (vertices)', fontsize=12)
    ax2.set_ylabel('Degree', fontsize=12)
    ax2.set_title('Canonical Divisor Degree = 2g - 2', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=11)
    ax2.grid(alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('genus_canonical.png', dpi=150, bbox_inches='tight')
    plt.close()
    
    print("Visualizations saved: chipfiring_K5.png, genus_canonical.png")


if __name__ == "__main__":
    main()
