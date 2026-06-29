"""
Königsberg Bridge Problem — Interactive Demonstration
=====================================================

This script demonstrates the mathematics behind Euler's Bridge Theorem,
the result that launched graph theory in 1736.

We visualize:
1. The original Königsberg bridge graph
2. Degree analysis showing why no Eulerian circuit exists
3. A contrasting graph that DOES have an Eulerian circuit
4. The odd-degree parity theorem in action
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations


# ─── Graph utilities ────────────────────────────────────────────────────────────

def degree(adj, v):
    """Degree of vertex v in adjacency list representation."""
    return len(adj[v])


def has_eulerian_circuit(adj):
    """Check necessary condition: all vertices must have even degree."""
    return all(degree(adj, v) % 2 == 0 for v in adj)


def find_eulerian_circuit(adj):
    """Find an Eulerian circuit using Hierholzer's algorithm (if one exists)."""
    if not has_eulerian_circuit(adj):
        return None

    # Work with a mutable copy
    remaining = {v: list(neighbors) for v, neighbors in adj.items()}
    stack = [list(adj.keys())[0]]
    circuit = []

    while stack:
        v = stack[-1]
        if remaining[v]:
            u = remaining[v].pop()
            remaining[u].remove(v)
            stack.append(u)
        else:
            circuit.append(stack.pop())

    return circuit


# ─── Figure 1: The Königsberg Bridge Graph ──────────────────────────────────────

def plot_konigsberg():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Original Königsberg layout (multigraph)
    ax1 = axes[0]
    ax1.set_xlim(-2.5, 2.5)
    ax1.set_ylim(-2, 2)
    ax1.set_aspect('equal')
    ax1.set_title('Königsberg Bridges (Original Multigraph)', fontsize=14, fontweight='bold')

    # Vertex positions: A=North, B=South, C=Island, D=East
    pos = {'A (North)': (0, 1.2), 'B (South)': (0, -1.2),
           'C (Island)': (-1.5, 0), 'D (East)': (1.5, 0)}

    # Draw the 7 bridges as curved edges
    edges_multi = [
        ('C (Island)', 'A (North)', 0.3),   # Bridge 1: C-A
        ('C (Island)', 'A (North)', -0.3),  # Bridge 2: C-A
        ('C (Island)', 'B (South)', 0.3),   # Bridge 3: C-B
        ('C (Island)', 'B (South)', -0.3),  # Bridge 4: C-B
        ('C (Island)', 'D (East)', 0.0),    # Bridge 5: C-D
        ('A (North)', 'D (East)', 0.0),     # Bridge 6: A-D
        ('B (South)', 'D (East)', 0.0),     # Bridge 7: B-D
    ]

    for u, v, curve in edges_multi:
        p1, p2 = np.array(pos[u]), np.array(pos[v])
        mid = (p1 + p2) / 2
        normal = np.array([-(p2-p1)[1], (p2-p1)[0]])
        normal = normal / (np.linalg.norm(normal) + 1e-10)
        ctrl = mid + curve * normal
        t = np.linspace(0, 1, 50)
        curve_pts = np.outer((1-t)**2, p1) + np.outer(2*(1-t)*t, ctrl) + np.outer(t**2, p2)
        ax1.plot(curve_pts[:, 0], curve_pts[:, 1], 'b-', linewidth=2, alpha=0.7)

    # Draw vertices
    degrees_multi = {'A (North)': 3, 'B (South)': 3, 'C (Island)': 5, 'D (East)': 3}
    for label, (x, y) in pos.items():
        d = degrees_multi[label]
        color = '#ff6b6b' if d % 2 == 1 else '#51cf66'
        ax1.plot(x, y, 'o', markersize=25, color=color, markeredgecolor='black',
                 markeredgewidth=2, zorder=5)
        ax1.annotate(f'{label}\ndeg={d}', (x, y), textcoords="offset points",
                     xytext=(0, -40), ha='center', fontsize=9, fontweight='bold')

    ax1.text(0, -1.85, '⚠ All vertices have ODD degree → No Eulerian circuit!',
             ha='center', fontsize=11, color='red', fontweight='bold',
             bbox=dict(boxstyle='round,pad=0.3', facecolor='#fff3f3', edgecolor='red'))
    ax1.axis('off')

    # Simple graph version (as formalized in Lean)
    ax2 = axes[1]
    ax2.set_xlim(-2.5, 2.5)
    ax2.set_ylim(-2, 2)
    ax2.set_aspect('equal')
    ax2.set_title('Simplified Graph (As Formalized in Lean 4)', fontsize=14, fontweight='bold')

    pos2 = {0: (0, 1.2), 1: (0, -1.2), 2: (-1.5, 0), 3: (1.5, 0)}
    labels2 = {0: 'v₀ North', 1: 'v₁ South', 2: 'v₂ Island', 3: 'v₃ East'}
    edges_simple = [(0, 2), (0, 3), (1, 2), (1, 3), (2, 3)]

    adj_simple = {v: [] for v in pos2}
    for u, v in edges_simple:
        adj_simple[u].append(v)
        adj_simple[v].append(u)

    for u, v in edges_simple:
        p1, p2 = pos2[u], pos2[v]
        ax2.plot([p1[0], p2[0]], [p1[1], p2[1]], 'b-', linewidth=2, alpha=0.7)

    for v, (x, y) in pos2.items():
        d = degree(adj_simple, v)
        color = '#ff6b6b' if d % 2 == 1 else '#51cf66'
        ax2.plot(x, y, 'o', markersize=25, color=color, markeredgecolor='black',
                 markeredgewidth=2, zorder=5)
        ax2.annotate(f'{labels2[v]}\ndeg={d}', (x, y), textcoords="offset points",
                     xytext=(0, -40), ha='center', fontsize=9, fontweight='bold')

    ax2.text(0, -1.85, 'v₂ and v₃ have ODD degree 3 → No Eulerian circuit!',
             ha='center', fontsize=11, color='red', fontweight='bold',
             bbox=dict(boxstyle='round,pad=0.3', facecolor='#fff3f3', edgecolor='red'))
    ax2.axis('off')

    # Legend
    odd_patch = mpatches.Patch(color='#ff6b6b', label='Odd degree (blocks Euler circuit)')
    even_patch = mpatches.Patch(color='#51cf66', label='Even degree')
    fig.legend(handles=[odd_patch, even_patch], loc='lower center', ncol=2, fontsize=12)

    plt.tight_layout(rect=[0, 0.05, 1, 1])
    plt.savefig('python/konigsberg_graph.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: python/konigsberg_graph.png")


# ─── Figure 2: Euler Circuit Example ────────────────────────────────────────────

def plot_euler_circuit_example():
    """Show a graph that HAS an Eulerian circuit, with the circuit traced."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # A graph with all even degrees: a "bowtie" / two triangles sharing a vertex
    # Actually, let's use a square with diagonals removed (a cycle C4)
    # C4: 0-1-2-3-0, all degrees 2
    pos = {0: (0, 1), 1: (1, 0), 2: (0, -1), 3: (-1, 0)}
    edges = [(0, 1), (1, 2), (2, 3), (3, 0)]
    adj = {0: [1, 3], 1: [0, 2], 2: [1, 3], 3: [2, 0]}

    ax1 = axes[0]
    ax1.set_xlim(-1.8, 1.8)
    ax1.set_ylim(-1.8, 1.8)
    ax1.set_aspect('equal')
    ax1.set_title('C₄: All Even Degrees', fontsize=14, fontweight='bold')

    for u, v in edges:
        p1, p2 = pos[u], pos[v]
        ax1.plot([p1[0], p2[0]], [p1[1], p2[1]], 'b-', linewidth=2, alpha=0.7)

    for v, (x, y) in pos.items():
        d = degree(adj, v)
        color = '#51cf66'  # all even
        ax1.plot(x, y, 'o', markersize=25, color=color, markeredgecolor='black',
                 markeredgewidth=2, zorder=5)
        ax1.annotate(f'v{v}\ndeg={d}', (x, y), textcoords="offset points",
                     xytext=(0, -35), ha='center', fontsize=10, fontweight='bold')

    ax1.text(0, -1.65, '✓ All degrees even → Euler circuit exists!',
             ha='center', fontsize=11, color='green', fontweight='bold',
             bbox=dict(boxstyle='round,pad=0.3', facecolor='#f0fff0', edgecolor='green'))
    ax1.axis('off')

    # Trace the Eulerian circuit
    ax2 = axes[1]
    ax2.set_xlim(-1.8, 1.8)
    ax2.set_ylim(-1.8, 1.8)
    ax2.set_aspect('equal')
    ax2.set_title('Eulerian Circuit: 0→1→2→3→0', fontsize=14, fontweight='bold')

    circuit = find_eulerian_circuit(adj)
    colors_edge = plt.cm.viridis(np.linspace(0.2, 0.9, len(circuit)-1))

    for i in range(len(circuit)-1):
        u, v = circuit[i], circuit[i+1]
        p1, p2 = np.array(pos[u]), np.array(pos[v])
        dx, dy = p2 - p1
        ax2.annotate('', xy=p2*0.85+p1*0.15, xytext=p1*0.85+p2*0.15,
                     arrowprops=dict(arrowstyle='->', color=colors_edge[i],
                                     lw=3, mutation_scale=20))
        mid = (p1 + p2) / 2
        ax2.text(mid[0], mid[1], f'  {i+1}', fontsize=12, fontweight='bold',
                 color=colors_edge[i], ha='center')

    for v, (x, y) in pos.items():
        ax2.plot(x, y, 'o', markersize=25, color='#51cf66', markeredgecolor='black',
                 markeredgewidth=2, zorder=5)
        ax2.annotate(f'v{v}', (x, y), ha='center', va='center', fontsize=12,
                     fontweight='bold', zorder=6)

    ax2.text(0, -1.65, f'Circuit: {" → ".join(map(str, circuit))}',
             ha='center', fontsize=11, color='#2d6a4f', fontweight='bold',
             bbox=dict(boxstyle='round,pad=0.3', facecolor='#f0fff0', edgecolor='green'))
    ax2.axis('off')

    plt.tight_layout()
    plt.savefig('python/euler_circuit_example.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: python/euler_circuit_example.png")


# ─── Figure 3: Odd-Degree Parity Theorem ────────────────────────────────────────

def plot_parity_theorem():
    """Demonstrate that the number of odd-degree vertices is always even."""
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle('Odd-Degree Parity Theorem: |{v : deg(v) is odd}| is always even',
                 fontsize=16, fontweight='bold')

    examples = [
        # (name, positions, edges)
        ('Path P₃', {0: (-1,0), 1: (0,0), 2: (1,0)}, [(0,1), (1,2)]),
        ('Triangle K₃', {0: (0,1), 1: (-0.87,-0.5), 2: (0.87,-0.5)}, [(0,1),(1,2),(0,2)]),
        ('Square C₄', {0: (-1,1), 1: (1,1), 2: (1,-1), 3: (-1,-1)}, [(0,1),(1,2),(2,3),(3,0)]),
        ('K₄', {0: (0,1), 1: (1,0), 2: (0,-1), 3: (-1,0)},
         [(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)]),
        ('Star S₄', {0: (0,0), 1: (0,1), 2: (1,0), 3: (0,-1), 4: (-1,0)},
         [(0,1),(0,2),(0,3),(0,4)]),
        ('Petersen-like', {0: (0,1.2), 1: (1.14,0.37), 2: (0.71,-0.97),
                          3: (-0.71,-0.97), 4: (-1.14,0.37)},
         [(0,1),(1,2),(2,3),(3,4),(4,0),(0,2),(1,3),(2,4)]),
    ]

    for idx, (name, pos, edges) in enumerate(examples):
        ax = axes[idx // 3][idx % 3]
        adj = {v: [] for v in pos}
        for u, v in edges:
            adj[u].append(v)
            adj[v].append(u)

        for u, v in edges:
            p1, p2 = pos[u], pos[v]
            ax.plot([p1[0], p2[0]], [p1[1], p2[1]], 'b-', linewidth=1.5, alpha=0.6)

        odd_count = 0
        for v, (x, y) in pos.items():
            d = degree(adj, v)
            is_odd = d % 2 == 1
            if is_odd:
                odd_count += 1
            color = '#ff6b6b' if is_odd else '#51cf66'
            ax.plot(x, y, 'o', markersize=18, color=color, markeredgecolor='black',
                    markeredgewidth=1.5, zorder=5)
            ax.annotate(f'{d}', (x, y), ha='center', va='center', fontsize=10,
                        fontweight='bold', zorder=6)

        ax.set_title(f'{name}\n#odd = {odd_count} ({"even ✓" if odd_count % 2 == 0 else "ERROR!"})',
                     fontsize=11, fontweight='bold')
        ax.set_aspect('equal')
        ax.axis('off')

    odd_patch = mpatches.Patch(color='#ff6b6b', label='Odd degree')
    even_patch = mpatches.Patch(color='#51cf66', label='Even degree')
    fig.legend(handles=[odd_patch, even_patch], loc='lower center', ncol=2, fontsize=12)

    plt.tight_layout(rect=[0, 0.05, 1, 0.95])
    plt.savefig('python/parity_theorem.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: python/parity_theorem.png")


# ─── Figure 4: Walk Incidence Parity ────────────────────────────────────────────

def plot_incidence_parity():
    """Visualize the walk incidence parity lemma on a concrete example."""
    fig, ax = plt.subplots(figsize=(10, 7))
    ax.set_title('Walk Incidence Parity Lemma\n'
                 'Closed walk: each vertex touched an even number of times',
                 fontsize=14, fontweight='bold')

    # Graph: triangle with an extra edge
    pos = {0: (0, 2), 1: (-1.5, -0.5), 2: (1.5, -0.5), 3: (3, 1)}
    adj = {0: [1, 2], 1: [0, 2], 2: [0, 1, 3], 3: [2]}

    # Draw edges lightly
    for v in adj:
        for u in adj[v]:
            if u > v:
                p1, p2 = pos[v], pos[u]
                ax.plot([p1[0], p2[0]], [p1[1], p2[1]], '-', color='#ddd',
                        linewidth=4, zorder=1)

    # Closed walk: 0 → 1 → 2 → 0
    walk = [0, 1, 2, 0]
    incidence = {v: 0 for v in pos}

    colors_walk = ['#e63946', '#457b9d', '#2a9d8f']
    for i in range(len(walk)-1):
        u, v = walk[i], walk[i+1]
        incidence[u] += 1
        incidence[v] += 1
        p1, p2 = np.array(pos[u]), np.array(pos[v])
        offset = np.array([-(p2-p1)[1], (p2-p1)[0]]) * 0.03
        ax.annotate('', xy=p2*0.85+p1*0.15+offset, xytext=p1*0.85+p2*0.15+offset,
                     arrowprops=dict(arrowstyle='->', color=colors_walk[i],
                                     lw=3, mutation_scale=20), zorder=3)
        mid = (p1 + p2) / 2 + offset * 3
        ax.text(mid[0], mid[1], f'step {i+1}', fontsize=10, color=colors_walk[i],
                fontweight='bold', ha='center')

    # Draw vertices with incidence counts
    for v, (x, y) in pos.items():
        inc = incidence[v]
        is_even = inc % 2 == 0
        color = '#51cf66' if is_even else '#ff6b6b'
        ax.plot(x, y, 'o', markersize=35, color=color, markeredgecolor='black',
                markeredgewidth=2, zorder=5)
        label = f'v{v}'
        ax.text(x, y, label, ha='center', va='center', fontsize=14,
                fontweight='bold', zorder=6)
        ax.annotate(f'inc = {inc}\n({"even ✓" if is_even else "odd"})',
                    (x, y), textcoords="offset points", xytext=(0, -45),
                    ha='center', fontsize=11,
                    bbox=dict(boxstyle='round,pad=0.2', facecolor=color, alpha=0.3))

    ax.text(0.5, -1.5, f'Closed walk: {" → ".join(map(str, walk))}\n'
            f'All incidence counts are EVEN ✓  (Theorem: circuit_incidenceCount_even)',
            ha='center', fontsize=12, fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.4', facecolor='#f0fff0', edgecolor='green'))

    ax.set_xlim(-2.5, 4.5)
    ax.set_ylim(-2.5, 3)
    ax.set_aspect('equal')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('python/incidence_parity.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: python/incidence_parity.png")


# ─── Numerical demonstration ────────────────────────────────────────────────────

def numerical_demo():
    """Print a numerical summary of the theorems."""
    print("\n" + "="*70)
    print("EULER'S BRIDGE THEOREM — Numerical Demonstration")
    print("="*70)

    print("\n📐 Theorem 1: Eulerian Circuit ⟹ All Even Degrees")
    print("-"*50)

    graphs = {
        'Königsberg (simple)': {0: [2,3], 1: [2,3], 2: [0,1,3], 3: [0,1,2]},
        'Triangle K₃':         {0: [1,2], 1: [0,2], 2: [0,1]},
        'Square C₄':           {0: [1,3], 1: [0,2], 2: [1,3], 3: [2,0]},
        'Complete K₄':         {0: [1,2,3], 1: [0,2,3], 2: [0,1,3], 3: [0,1,2]},
        'Cube Q₃':             {0:[1,3,4], 1:[0,2,5], 2:[1,3,6], 3:[0,2,7],
                                4:[0,5,7], 5:[1,4,6], 6:[2,5,7], 7:[3,4,6]},
    }

    for name, adj in graphs.items():
        degrees = {v: len(adj[v]) for v in adj}
        all_even = all(d % 2 == 0 for d in degrees.values())
        odd_vertices = [v for v, d in degrees.items() if d % 2 == 1]
        circuit = find_eulerian_circuit(adj)

        print(f"\n  {name}:")
        print(f"    Degrees: {degrees}")
        print(f"    All even? {'Yes ✓' if all_even else 'No ✗'}")
        print(f"    Odd-degree vertices: {odd_vertices} (count = {len(odd_vertices)})")
        print(f"    |odd vertices| even? {'Yes ✓' if len(odd_vertices) % 2 == 0 else 'ERROR!'}")
        if circuit:
            print(f"    Euler circuit: {' → '.join(map(str, circuit))}")
        else:
            print(f"    Euler circuit: None exists")

    print("\n\n📐 Theorem 2: Number of Odd-Degree Vertices Is Always Even")
    print("-"*50)
    print("  (Verified for all graphs above — see 'count' values)")

    print("\n\n📐 Theorem 3: Walk Incidence Parity")
    print("-"*50)
    # Example: walk 0→1→2→3→0 in C₄
    walk = [0, 1, 2, 3, 0]
    print(f"  Closed walk in C₄: {' → '.join(map(str, walk))}")
    incidence = {0: 0, 1: 0, 2: 0, 3: 0}
    for i in range(len(walk)-1):
        u, v = walk[i], walk[i+1]
        incidence[u] += 1
        incidence[v] += 1
    for v in sorted(incidence):
        print(f"    Vertex {v}: incidence count = {incidence[v]} ({'even ✓' if incidence[v] % 2 == 0 else 'odd ✗'})")
    print("  All even ✓ (as guaranteed by circuit_incidenceCount_even)")


# ─── Main ────────────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    numerical_demo()
    print("\n\nGenerating visualizations...")
    plot_konigsberg()
    plot_euler_circuit_example()
    plot_parity_theorem()
    plot_incidence_parity()
    print("\nAll demos complete! 🎉")
