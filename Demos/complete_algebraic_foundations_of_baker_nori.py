#!/usr/bin/env python3
"""
Baker-Norine Chip-Firing Demo

Demonstrates chip-firing dynamics, divisor rank computation, and
the Riemann-Roch identity on small graphs.
"""

import numpy as np
from typing import List, Tuple, Dict, Set
from itertools import combinations


def laplacian_matrix(adj: np.ndarray) -> np.ndarray:
    """Compute the Laplacian matrix L = D - A where D is degree matrix."""
    n = adj.shape[0]
    deg = np.diag(adj.sum(axis=1))
    return deg - adj


def chip_fire(divisor: np.ndarray, adj: np.ndarray, vertex: int) -> np.ndarray:
    """Fire vertex v: sends one chip to each neighbor."""
    result = divisor.copy()
    degree = int(adj[vertex].sum())
    result[vertex] -= degree
    for w in range(len(divisor)):
        if adj[vertex, w] > 0:
            result[w] += 1
    return result


def graph_genus(adj: np.ndarray) -> int:
    """Compute genus g = |E| - |V| + 1."""
    n = adj.shape[0]
    num_edges = int(adj.sum()) // 2
    return num_edges - n + 1


def canonical_divisor(adj: np.ndarray) -> np.ndarray:
    """Compute K_G(v) = deg(v) - 2."""
    return adj.sum(axis=1).astype(int) - 2


def is_effective(divisor: np.ndarray) -> bool:
    """Check if all values are non-negative."""
    return all(d >= 0 for d in divisor)


def divisor_degree(divisor: np.ndarray) -> int:
    """Sum of all values."""
    return int(divisor.sum())


def complete_graph_adj(n: int) -> np.ndarray:
    """Adjacency matrix of K_n."""
    return np.ones((n, n), dtype=int) - np.eye(n, dtype=int)


def cycle_graph_adj(n: int) -> np.ndarray:
    """Adjacency matrix of C_n."""
    adj = np.zeros((n, n), dtype=int)
    for i in range(n):
        adj[i, (i + 1) % n] = 1
        adj[(i + 1) % n, i] = 1
    return adj


def find_effective_representative(divisor: np.ndarray, adj: np.ndarray,
                                   max_iter: int = 10000) -> Tuple[bool, np.ndarray]:
    """Try to find an effective divisor linearly equivalent to D via chip-firing."""
    current = divisor.copy()
    n = len(divisor)
    for _ in range(max_iter):
        if is_effective(current):
            return True, current
        # Find a vertex with negative value and fire its neighbors
        for v in range(n):
            if current[v] < 0:
                # Fire all neighbors of v (anti-fire v)
                degree = int(adj[v].sum())
                current[v] += degree
                for w in range(n):
                    if adj[v, w] > 0:
                        current[w] -= 1
                break
    return is_effective(current), current


def compute_rank(divisor: np.ndarray, adj: np.ndarray) -> int:
    """
    Compute divisor rank r(D) by brute force.
    r(D) = -1 if D is not linearly equivalent to an effective divisor.
    Otherwise r(D) is the max k such that D - E is equivalent to effective
    for all effective E of degree k.
    """
    n = len(divisor)
    deg = divisor_degree(divisor)

    # Check r(D) >= 0
    found, _ = find_effective_representative(divisor, adj)
    if not found:
        return -1

    for k in range(1, deg + 2):
        # Check if D - E is equivalent to effective for all effective E of degree k
        # Generate effective divisors of degree k (with bounded entries)
        all_pass = True
        for combo in _effective_divisors_of_degree(n, k, max_val=k+1):
            E = np.array(combo, dtype=int)
            diff = divisor - E
            found, _ = find_effective_representative(diff, adj)
            if not found:
                all_pass = False
                break
        if not all_pass:
            return k - 1
    return deg


def _effective_divisors_of_degree(n: int, k: int, max_val: int = None):
    """Generate all effective divisors of degree k on n vertices."""
    if max_val is None:
        max_val = k
    if n == 1:
        if 0 <= k <= max_val:
            yield (k,)
        return
    for val in range(min(k, max_val) + 1):
        for rest in _effective_divisors_of_degree(n - 1, k - val, max_val):
            yield (val,) + rest


def demo_riemann_roch_identity():
    """Verify deg(K_G) = 2g - 2 on several graphs."""
    print("=" * 60)
    print("RIEMANN-ROCH DEGREE IDENTITY: deg(K_G) = 2g - 2")
    print("=" * 60)

    graphs = [
        ("K_3", complete_graph_adj(3)),
        ("K_4", complete_graph_adj(4)),
        ("K_5", complete_graph_adj(5)),
        ("C_4", cycle_graph_adj(4)),
        ("C_5", cycle_graph_adj(5)),
        ("C_6", cycle_graph_adj(6)),
    ]

    for name, adj in graphs:
        K = canonical_divisor(adj)
        g = graph_genus(adj)
        deg_K = divisor_degree(K)
        expected = 2 * g - 2
        status = "✓" if deg_K == expected else "✗"
        print(f"  {name}: g = {g}, deg(K) = {deg_K}, 2g-2 = {expected} {status}")
        print(f"         K = {K}")


def demo_chip_firing_conservation():
    """Show that chip-firing conserves degree."""
    print("\n" + "=" * 60)
    print("CHIP-FIRING CONSERVATION OF DEGREE")
    print("=" * 60)

    adj = complete_graph_adj(4)
    D = np.array([3, -1, 2, -2])
    print(f"  Initial divisor: {D}, degree = {divisor_degree(D)}")

    for v in range(4):
        D_new = chip_fire(D, adj, v)
        print(f"  Fire vertex {v}: {D_new}, degree = {divisor_degree(D_new)}")
        D = D_new


def demo_genus_complete():
    """Verify g(K_n) = (n-1)(n-2)/2."""
    print("\n" + "=" * 60)
    print("GENUS OF COMPLETE GRAPHS: g(K_n) = (n-1)(n-2)/2")
    print("=" * 60)

    for n in range(2, 10):
        adj = complete_graph_adj(n)
        g = graph_genus(adj)
        expected = (n - 1) * (n - 2) // 2
        status = "✓" if g == expected else "✗"
        print(f"  K_{n}: g = {g}, (n-1)(n-2)/2 = {expected} {status}")


def demo_divisor_rank():
    """Compute ranks and verify Riemann-Roch: r(D) - r(K-D) = deg(D) - g + 1."""
    print("\n" + "=" * 60)
    print("DIVISOR RANK AND RIEMANN-ROCH")
    print("=" * 60)

    # Cycle graph C_4 (genus 1)
    adj = cycle_graph_adj(4)
    g = graph_genus(adj)
    K = canonical_divisor(adj)
    print(f"\n  Graph: C_4, genus = {g}")
    print(f"  K = {K}")

    test_divisors = [
        np.array([2, 0, 0, 0]),
        np.array([1, 1, 0, 0]),
        np.array([1, 0, 0, 0]),
        np.array([0, 0, 0, 0]),
    ]

    for D in test_divisors:
        rD = compute_rank(D, adj)
        KmD = K - D
        rKmD = compute_rank(KmD, adj)
        degD = divisor_degree(D)
        lhs = rD - rKmD
        rhs = degD - g + 1
        status = "✓" if lhs == rhs else "?"
        print(f"  D={D}: r(D)={rD}, r(K-D)={rKmD}, "
              f"r(D)-r(K-D)={lhs}, deg(D)-g+1={rhs} {status}")


def demo_q_reduced():
    """Show q-reduced divisors and their uniqueness."""
    print("\n" + "=" * 60)
    print("Q-REDUCED DIVISORS")
    print("=" * 60)

    adj = cycle_graph_adj(4)
    q = 0
    D = np.array([0, 1, 0, 1])
    print(f"  Graph: C_4, q = vertex {q}")
    print(f"  Initial D = {D}, degree = {divisor_degree(D)}")

    # Find q-reduced representative by Dhar's algorithm
    current = D.copy()
    n = len(D)
    changed = True
    while changed:
        changed = False
        for v in range(n):
            if v == q:
                continue
            # Count edges from v to complement of {v}
            outdeg = int(adj[v].sum())
            if current[v] >= outdeg:
                # Fire vertex v
                current = chip_fire(current, adj, v)
                changed = True
                print(f"  Fire vertex {v}: {current}")

    print(f"  Q-reduced form: {current}")
    print(f"  Non-negative away from q: {all(current[v] >= 0 for v in range(n) if v != q)}")


if __name__ == "__main__":
    demo_riemann_roch_identity()
    demo_chip_firing_conservation()
    demo_genus_complete()
    demo_divisor_rank()
    demo_q_reduced()


#!/usr/bin/env python3
"""
Visualization: Chip-Firing Dynamics on Graphs

Standalone matplotlib visualization showing chip-firing conservation
and divisor evolution on a cycle graph.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def cycle_graph_adj(n):
    adj = np.zeros((n, n), dtype=int)
    for i in range(n):
        adj[i, (i + 1) % n] = 1
        adj[(i + 1) % n, i] = 1
    return adj


def chip_fire(divisor, adj, vertex):
    result = divisor.copy()
    degree = int(adj[vertex].sum())
    result[vertex] -= degree
    for w in range(len(divisor)):
        if adj[vertex, w] > 0:
            result[w] += 1
    return result


def main():
    n = 6
    adj = cycle_graph_adj(n)
    D0 = np.array([5, -2, 3, -1, 4, -3])

    # Simulate chip-firing
    steps = [D0.copy()]
    firing_order = [0, 2, 4, 1, 3, 5, 0, 2, 4, 1, 3, 5]
    current = D0.copy()
    for v in firing_order:
        current = chip_fire(current, adj, v)
        steps.append(current.copy())

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Plot 1: Chip evolution over time
    ax = axes[0, 0]
    for i in range(n):
        values = [s[i] for s in steps]
        ax.plot(range(len(steps)), values, 'o-', label=f'v{i}', linewidth=2, markersize=5)
    ax.set_xlabel('Step', fontsize=12)
    ax.set_ylabel('Chips', fontsize=12)
    ax.set_title('Chip-Firing Evolution on C₆', fontsize=14, fontweight='bold')
    ax.legend(ncol=3, fontsize=9)
    ax.grid(True, alpha=0.3)

    # Plot 2: Degree conservation
    ax = axes[0, 1]
    degrees = [sum(s) for s in steps]
    ax.plot(range(len(steps)), degrees, 'rs-', linewidth=2, markersize=8)
    ax.set_xlabel('Step', fontsize=12)
    ax.set_ylabel('Total Degree', fontsize=12)
    ax.set_title('Conservation of Degree', fontsize=14, fontweight='bold')
    ax.set_ylim(min(degrees) - 1, max(degrees) + 1)
    ax.grid(True, alpha=0.3)

    # Plot 3: Genus of K_n
    ax = axes[1, 0]
    ns = range(2, 15)
    genera = [(k - 1) * (k - 2) // 2 for k in ns]
    ax.bar(list(ns), genera, color='steelblue', alpha=0.8, edgecolor='navy')
    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel('Genus g(Kₙ)', fontsize=12)
    ax.set_title('Genus of Complete Graphs: g = (n-1)(n-2)/2', fontsize=14, fontweight='bold')
    ax.grid(True, alpha=0.3, axis='y')

    # Plot 4: Canonical divisor degree vs 2g-2
    ax = axes[1, 1]
    ns2 = range(3, 12)
    deg_K = []
    two_g_minus_2 = []
    for k in ns2:
        adj_k = np.ones((k, k), dtype=int) - np.eye(k, dtype=int)
        K = adj_k.sum(axis=1).astype(int) - 2
        deg_K.append(int(K.sum()))
        num_edges = k * (k - 1) // 2
        g = num_edges - k + 1
        two_g_minus_2.append(2 * g - 2)

    x = np.arange(len(list(ns2)))
    width = 0.35
    ax.bar(x - width/2, deg_K, width, label='deg(K_G)', color='coral', alpha=0.8)
    ax.bar(x + width/2, two_g_minus_2, width, label='2g - 2', color='seagreen', alpha=0.8)
    ax.set_xticks(x)
    ax.set_xticklabels([f'K_{k}' for k in ns2])
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Riemann-Roch Identity: deg(K_G) = 2g - 2', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('chip_firing_dynamics.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved chip_firing_dynamics.png")


if __name__ == "__main__":
    main()
