#!/usr/bin/env python3
"""
Applications of Cycle-Systolic Bounds

Demonstrates real-world applications of the cycle-systolic lower bound
theorem in communication complexity, network routing, and distributed computing.
"""

import numpy as np


def application_network_routing():
    """
    Application: Network Routing Cost Lower Bounds

    In a distributed network, two nodes communicate by sending messages
    over a shared channel. The routing cost depends on the states of
    both nodes. The cycle systole of the state-cost matrix gives a
    fundamental lower bound on total communication cost.
    """
    print("=" * 70)
    print("APPLICATION 1: Network Routing Cost Lower Bounds")
    print("=" * 70)
    print()

    # Network with 5 source states and 4 destination states
    # Cost matrix: latency in milliseconds
    W = np.array([
        [10, 25, 15, 30],
        [20, 10, 35, 15],
        [30, 15, 10, 25],
        [15, 30, 20, 10],
        [25, 20, 15, 20]
    ])

    g = int(W.min())  # Cycle systole = minimum entry
    print(f"  Network latency matrix (5 sources x 4 destinations):")
    print(f"  {W}")
    print(f"  Cycle systole (min routing cost per cycle): g = {g} ms")
    print()

    # Scenario: 1000 rounds of communication, 8 possible message types
    R, n = 1000, 8
    lower_bound = g * (R // n)
    print(f"  Scenario: {R} communication rounds, {n} message types")
    print(f"  Minimum total latency: >= {g} * {R // n} = {lower_bound} ms")
    print(f"  This is {lower_bound / 1000:.1f} seconds minimum, regardless of protocol")
    print()


def application_database_queries():
    """
    Application: Database Query Complexity

    In a two-party database protocol, Alice holds row keys and Bob holds
    column keys. Each query has a cost. The cycle systole bounds the
    total query cost for any protocol with bounded message complexity.
    """
    print("=" * 70)
    print("APPLICATION 2: Database Query Cost Bounds")
    print("=" * 70)
    print()

    # Query cost matrix: cost units per (row_key, col_key) pair
    W = np.array([
        [1, 3, 2],
        [4, 1, 5],
        [2, 4, 1]
    ])

    g = int(W.min())
    print(f"  Query cost matrix (3 row keys x 3 col keys):")
    print(f"  {W}")
    print(f"  Cycle systole: g = {g}")
    print()

    for n_msgs in [2, 3, 5, 10]:
        R = 100
        bound = g * (R // n_msgs)
        print(f"  With {n_msgs} message types over {R} queries: "
              f"cost >= {bound}")
    print()
    print("  Insight: More message types reduce the forced cycle count,")
    print("  but each cycle still costs at least g.")
    print()


def application_distributed_consensus():
    """
    Application: Distributed Consensus Communication Cost

    In consensus protocols, nodes exchange state information. The cost
    matrix represents the communication overhead of state mismatches.
    The cycle systole gives a lower bound on total consensus cost.
    """
    print("=" * 70)
    print("APPLICATION 3: Distributed Consensus Communication Cost")
    print("=" * 70)
    print()

    # 6 nodes, cost of state reconciliation between pairs
    n_nodes = 6
    W = np.random.RandomState(42).randint(1, 10, size=(n_nodes, n_nodes))
    np.fill_diagonal(W, 0)  # No self-communication cost

    g = int(W[W > 0].min()) if (W > 0).any() else 0
    print(f"  State reconciliation cost matrix ({n_nodes}x{n_nodes}):")
    print(f"  {W}")
    print(f"  Cycle systole (excluding self-loops): g = {g}")
    print()

    # Different protocol configurations
    configs = [
        (50, 3, "Minimal messages"),
        (50, 6, "One message per node"),
        (100, 5, "Extended protocol"),
    ]
    for R, n, label in configs:
        bound = g * (R // n)
        print(f"  {label} (R={R}, n={n}): cost >= {bound}")
    print()


def application_crypto_key_exchange():
    """
    Application: Cryptographic Key Exchange Cost

    In key exchange protocols, the communication cost depends on the
    security parameters of both parties. The cycle systole bounds
    the minimum total computational cost of key negotiation.
    """
    print("=" * 70)
    print("APPLICATION 4: Cryptographic Key Exchange Cost Bounds")
    print("=" * 70)
    print()

    # Cost matrix: computational cost (microseconds) for key operations
    # Rows: Alice's security levels, Columns: Bob's security levels
    W = np.array([
        [100, 200, 400],
        [150, 100, 300],
        [250, 200, 100]
    ])

    g = int(W.min())
    total = int(W.sum())
    print(f"  Key exchange cost matrix (3 security levels each):")
    print(f"  {W}")
    print(f"  Cycle systole: g = {g} μs")
    print()

    R = 256  # Key exchange rounds
    for n in [4, 8, 16, 32]:
        bound = g * (R // n)
        print(f"  {R} rounds, {n} message types: cost >= {bound} μs "
              f"({bound / 1000:.1f} ms)")
    print()
    print("  The cycle systole is a universal lower bound: no clever")
    print("  message encoding can reduce the total cost below this.")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Real-World Applications of Cycle-Systolic Bounds              ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    application_network_routing()
    application_database_queries()
    application_distributed_consensus()
    application_crypto_key_exchange()

    print("=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Cycle-Systolic Lower Bounds for Communication Protocols — Demonstrations

This script demonstrates the key theorems with concrete numerical examples,
showing how alternating cycle costs in bipartite communication graphs
yield provable lower bounds on protocol complexity.
"""

import numpy as np
from itertools import product


def alt_cycle_cost(W, row_indices, col_indices):
    """Compute the cost of an alternating cycle in weight matrix W."""
    return sum(W[r, c] for r, c in zip(row_indices, col_indices))


def min_cycle_cost(W):
    """
    Compute the minimum alternating cycle cost (cycle systole) of W.
    For length-1 cycles, the minimum cost is simply the minimum matrix entry.
    """
    a, b = W.shape
    if a == 0 or b == 0:
        return float('inf')
    return int(W.min())


def protocol_lower_bound(g, R, n):
    """Compute the cycle-systolic lower bound: g * (R // n)."""
    return g * (R // n)


def find_repetition(sigma):
    """Find a collision in sigma (pigeonhole)."""
    seen = {}
    for i, v in enumerate(sigma):
        if v in seen:
            return (seen[v], i, v)
        seen[v] = i
    return None


def demo_block_lower_bound():
    """Demonstrate the core additive block lower bound theorem."""
    print("=" * 70)
    print("DEMO 1: Core Additive Block Lower Bound")
    print("=" * 70)
    print()
    print("Theorem: If R rounds use n message types, and each block of n")
    print("rounds has cost >= g, then total cost >= g * floor(R/n).")
    print()

    examples = [
        (100, 10, 5, "Standard case"),
        (1000, 7, 3, "Large transcript, small alphabet"),
        (50, 3, 10, "High systole"),
        (256, 16, 1, "Minimal systole"),
    ]

    for R, n, g, label in examples:
        num_blocks = R // n
        lower = g * num_blocks
        print(f"  {label}:")
        print(f"    R={R} rounds, n={n} messages, g={g} (cycle systole)")
        print(f"    Blocks: floor({R}/{n}) = {num_blocks}")
        print(f"    Lower bound: {g} * {num_blocks} = {lower}")
        print()


def demo_pigeonhole():
    """Demonstrate the pigeonhole repetition lemma."""
    print("=" * 70)
    print("DEMO 2: Pigeonhole Repetition in Finite-Alphabet Blocks")
    print("=" * 70)
    print()
    print("Theorem: Any function from Fin(n+1) to Fin(n) has a collision.")
    print()

    for n in [3, 5, 8]:
        # Random message assignment
        np.random.seed(42 + n)
        sigma = np.random.randint(0, n, size=n + 1)
        collision = find_repetition(sigma)
        print(f"  n={n}: sigma = {list(sigma)}")
        if collision:
            i, j, v = collision
            print(f"    Collision: sigma[{i}] = sigma[{j}] = {v}")
        print()


def demo_cycle_systole():
    """Demonstrate minimum cycle cost computation on example matrices."""
    print("=" * 70)
    print("DEMO 3: Cycle Systole of Communication Matrices")
    print("=" * 70)
    print()

    # Example 1: Identity-like matrix (high systole)
    W1 = np.array([[3, 1, 0],
                    [0, 3, 1],
                    [1, 0, 3]])
    g1 = min_cycle_cost(W1)
    print("  Matrix W1 (circulant-like):")
    print(f"  {W1}")
    print(f"  Minimum cycle cost (systole): g = {g1}")
    print()

    # Example 2: All-ones matrix (low systole)
    W2 = np.ones((3, 3), dtype=int)
    g2 = min_cycle_cost(W2)
    print("  Matrix W2 (all-ones):")
    print(f"  {W2}")
    print(f"  Minimum cycle cost (systole): g = {g2}")
    print()

    # Example 3: Weighted matrix
    W3 = np.array([[5, 2, 8],
                    [3, 7, 1],
                    [6, 4, 9]])
    g3 = min_cycle_cost(W3)
    print("  Matrix W3 (weighted):")
    print(f"  {W3}")
    print(f"  Minimum cycle cost (systole): g = {g3}")
    print()


def demo_rectangle_bound():
    """Demonstrate the full rectangle bound theorem."""
    print("=" * 70)
    print("DEMO 4: Rectangle Bound (Cycle-Obstruction Form)")
    print("=" * 70)
    print()
    print("Theorem: For a protocol with R rounds, n messages, and")
    print("bipartite graph systole g: total cost >= g * floor(R/n)")
    print()

    W = np.array([[3, 1, 0],
                   [0, 3, 1],
                   [1, 0, 3]])
    g = min_cycle_cost(W)
    a, b = W.shape

    print(f"  Communication matrix ({a}x{b}):")
    print(f"  {W}")
    print(f"  Cycle systole: g = {g}")
    print()

    for R, n in [(100, 5), (200, 10), (500, 3)]:
        bound = protocol_lower_bound(g, R, n)
        print(f"  R={R}, n={n}: lower bound = {g} * {R // n} = {bound}")

    print()


def demo_edge_disjoint():
    """Demonstrate the edge-disjoint cycle bound."""
    print("=" * 70)
    print("DEMO 5: Edge-Disjoint Cycle Extraction")
    print("=" * 70)
    print()
    print("When m edge-disjoint cycles exist, each with cost >= g,")
    print("total matrix weight >= g * m.")
    print()

    W = np.array([[5, 2, 8, 1],
                   [3, 7, 1, 4],
                   [6, 4, 9, 2],
                   [1, 3, 2, 6]])
    total_weight = W.sum()
    g = min_cycle_cost(W)

    print(f"  Matrix W (4x4):")
    for row in W:
        print(f"    {row}")
    print(f"  Total weight: {total_weight}")
    print(f"  Cycle systole: g = {g}")
    print(f"  Max edge-disjoint cycles possible: <= {total_weight} / {g} = {total_weight // g}")
    print()

    # Show some concrete cycles
    cycles = [
        ([0], [0]),  # Single edge cycle: W[0,0] = 5
        ([1], [1]),  # Single edge cycle: W[1,1] = 7
        ([2], [2]),  # Single edge cycle: W[2,2] = 9
    ]
    print("  Example edge-disjoint cycles:")
    for i, (rows, cols) in enumerate(cycles):
        cost = alt_cycle_cost(W, rows, cols)
        edges = list(zip(rows, cols))
        print(f"    Cycle {i}: edges={edges}, cost={cost}")
    print()


def demo_tropical_interpretation():
    """Demonstrate the tropical/min-plus interpretation."""
    print("=" * 70)
    print("DEMO 6: Tropical (Min-Plus) Interpretation")
    print("=" * 70)
    print()
    print("In the tropical semiring (min, +), the cycle systole is the")
    print("minimum-weight cycle — the tropical eigenvalue of the graph.")
    print()

    W = np.array([[4, 2, 7],
                   [3, 5, 1],
                   [6, 8, 3]])

    print("  Weight matrix:")
    print(f"  {W}")
    print()

    # Compute all length-1 cycle costs (diagonal entries in tropical sense)
    print("  Length-1 cycles (single edges):")
    a, b = W.shape
    for i in range(a):
        for j in range(b):
            print(f"    ({i},{j}): cost = {W[i, j]}")

    g = min_cycle_cost(W)
    print(f"\n  Tropical cycle systole: g = {g}")
    print(f"  This is the 'tropical eigenvalue' of the communication graph.")
    print()

    # Show how this controls protocol cost
    for R, n in [(50, 5), (100, 4), (200, 8)]:
        bound = protocol_lower_bound(g, R, n)
        print(f"  Protocol R={R}, n={n}: tropical lower bound = {bound}")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Cycle-Systolic Lower Bounds for Communication Protocols       ║")
    print("║  Concrete Demonstrations of Formally Verified Theorems         ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    demo_block_lower_bound()
    demo_pigeonhole()
    demo_cycle_systole()
    demo_rectangle_bound()
    demo_edge_disjoint()
    demo_tropical_interpretation()

    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Generate visualizations for cycle-systolic communication complexity.
Saves figures as PNG files and prints base64 encodings for JSON embedding.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_block_lower_bound():
    """Visualize the block lower bound as R and n vary."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: bound vs R for fixed n, g
    g = 3
    n_vals = [2, 5, 10, 20]
    R_range = np.arange(1, 201)

    ax = axes[0]
    for n in n_vals:
        bounds = [g * (R // n) for R in R_range]
        ax.plot(R_range, bounds, label=f'n={n}', linewidth=2)
    ax.set_xlabel('Number of Rounds (R)', fontsize=12)
    ax.set_ylabel('Lower Bound g·⌊R/n⌋', fontsize=12)
    ax.set_title('Cycle-Systolic Lower Bound vs. Rounds', fontsize=13)
    ax.legend(title='Alphabet size n', fontsize=10)
    ax.grid(True, alpha=0.3)

    # Right: bound vs n for fixed R, g
    R = 100
    g_vals = [1, 3, 5, 10]
    n_range = np.arange(1, 51)

    ax = axes[1]
    for g in g_vals:
        bounds = [g * (R // n) for n in n_range]
        ax.plot(n_range, bounds, label=f'g={g}', linewidth=2)
    ax.set_xlabel('Message Alphabet Size (n)', fontsize=12)
    ax.set_ylabel('Lower Bound g·⌊R/n⌋', fontsize=12)
    ax.set_title('Lower Bound vs. Alphabet Size (R=100)', fontsize=13)
    ax.legend(title='Cycle systole g', fontsize=10)
    ax.grid(True, alpha=0.3)

    fig.suptitle('The Discrete Systolic Inequality for Protocols', fontsize=14, y=1.02)
    fig.tight_layout()
    return fig


def viz_bipartite_graph():
    """Visualize a bipartite communication graph with alternating cycle."""
    fig, ax = plt.subplots(figsize=(10, 6))

    # Bipartite graph: 4 Alice nodes, 3 Bob nodes
    a, b = 4, 3
    W = np.array([
        [5, 2, 8],
        [3, 7, 1],
        [6, 4, 9],
        [1, 3, 2]
    ])

    # Position nodes
    alice_x = np.zeros(a)
    alice_y = np.linspace(0, 3, a)
    bob_x = np.ones(b) * 4
    bob_y = np.linspace(0.5, 2.5, b)

    # Draw all edges (light gray)
    for i in range(a):
        for j in range(b):
            ax.plot([alice_x[i], bob_x[j]], [alice_y[i], bob_y[j]],
                   'gray', alpha=0.15, linewidth=1)

    # Highlight an alternating cycle: (0,0) -> (1,1) -> (2,0) -> (0,2)
    cycle_edges = [(0, 0), (1, 1), (2, 0)]
    colors_cycle = ['#e74c3c', '#2ecc71', '#3498db']
    for idx, (i, j) in enumerate(cycle_edges):
        ax.plot([alice_x[i], bob_x[j]], [alice_y[i], bob_y[j]],
               color=colors_cycle[idx], linewidth=3, alpha=0.8)
        mid_x = (alice_x[i] + bob_x[j]) / 2
        mid_y = (alice_y[i] + bob_y[j]) / 2
        ax.annotate(f'W={W[i,j]}', (mid_x, mid_y), fontsize=11,
                   ha='center', va='bottom',
                   bbox=dict(boxstyle='round,pad=0.2', facecolor='yellow', alpha=0.8))

    # Draw nodes
    for i in range(a):
        ax.scatter(alice_x[i], alice_y[i], s=300, c='#e74c3c', zorder=5,
                  edgecolors='black', linewidth=2)
        ax.annotate(f'A{i}', (alice_x[i] - 0.3, alice_y[i]), fontsize=12,
                   ha='center', va='center', fontweight='bold')

    for j in range(b):
        ax.scatter(bob_x[j], bob_y[j], s=300, c='#3498db', zorder=5,
                  edgecolors='black', linewidth=2)
        ax.annotate(f'B{j}', (bob_x[j] + 0.3, bob_y[j]), fontsize=12,
                   ha='center', va='center', fontweight='bold')

    cycle_cost = sum(W[i, j] for i, j in cycle_edges)
    ax.set_title(f'Bipartite Communication Graph with Alternating Cycle\n'
                f'Cycle cost = {" + ".join(str(W[i,j]) for i,j in cycle_edges)} = {cycle_cost}',
                fontsize=13)
    ax.set_xlim(-1, 5)
    ax.set_ylim(-0.5, 3.5)
    ax.axis('off')
    fig.tight_layout()
    return fig


def viz_heatmap_systole():
    """Visualize weight matrix as heatmap with systole highlighted."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    matrices = [
        (np.array([[5, 2, 8], [3, 7, 1], [6, 4, 9]]), "Weighted Matrix"),
        (np.array([[1, 1, 1], [1, 1, 1], [1, 1, 1]]), "Uniform Matrix"),
    ]

    for ax, (W, title) in zip(axes, matrices):
        im = ax.imshow(W, cmap='YlOrRd', aspect='auto')
        a, b = W.shape
        for i in range(a):
            for j in range(b):
                color = 'white' if W[i, j] > W.max() * 0.6 else 'black'
                ax.text(j, i, str(W[i, j]), ha='center', va='center',
                       fontsize=16, color=color, fontweight='bold')

        # Highlight minimum (systole)
        min_pos = np.unravel_index(W.argmin(), W.shape)
        rect = plt.Rectangle((min_pos[1] - 0.5, min_pos[0] - 0.5), 1, 1,
                            linewidth=3, edgecolor='#2ecc71', facecolor='none')
        ax.add_patch(rect)

        ax.set_xlabel('Bob States', fontsize=12)
        ax.set_ylabel('Alice States', fontsize=12)
        ax.set_title(f'{title}\nSystole g = {W.min()} (green box)', fontsize=12)
        plt.colorbar(im, ax=ax, shrink=0.8)

    fig.suptitle('Communication Matrix Weight & Cycle Systole', fontsize=14, y=1.02)
    fig.tight_layout()
    return fig


def viz_protocol_decomposition():
    """Visualize protocol block decomposition and repetition detection."""
    fig, axes = plt.subplots(2, 1, figsize=(14, 7))

    R, n = 30, 5
    np.random.seed(42)
    messages = np.random.randint(0, n, R)
    costs = np.random.randint(1, 8, R)

    # Top: message trace with block boundaries
    ax = axes[0]
    colors = plt.cm.Set2(np.linspace(0, 1, n))
    for t in range(R):
        ax.bar(t, 1, color=colors[messages[t]], edgecolor='black', linewidth=0.5)

    # Block boundaries
    num_blocks = R // n
    for k in range(num_blocks + 1):
        ax.axvline(x=k * n - 0.5, color='red', linewidth=2, linestyle='--')

    # Mark repetitions
    for k in range(num_blocks):
        block = messages[k*n:(k+1)*n]
        seen = {}
        for i, m in enumerate(block):
            if m in seen:
                t1, t2 = k*n + seen[m], k*n + i
                ax.annotate('', xy=(t2, 1.05), xytext=(t1, 1.05),
                          arrowprops=dict(arrowstyle='<->', color='red', lw=2))
                break
            seen[m] = i

    ax.set_xlabel('Round', fontsize=12)
    ax.set_ylabel('Message', fontsize=12)
    ax.set_title('Protocol Message Trace with Block Decomposition\n'
                '(Red arrows: forced repetitions by pigeonhole)', fontsize=13)
    ax.set_xlim(-0.5, R - 0.5)
    ax.set_ylim(0, 1.3)

    # Legend
    from matplotlib.patches import Patch
    legend_elements = [Patch(facecolor=colors[i], edgecolor='black', label=f'Msg {i}')
                      for i in range(n)]
    ax.legend(handles=legend_elements, loc='upper right', ncol=n, fontsize=9)

    # Bottom: cost per round with block totals
    ax = axes[1]
    block_colors = plt.cm.Pastel1(np.linspace(0, 1, num_blocks))
    for t in range(R):
        block_idx = t // n
        if block_idx < num_blocks:
            ax.bar(t, costs[t], color=block_colors[block_idx],
                  edgecolor='black', linewidth=0.5)
        else:
            ax.bar(t, costs[t], color='lightgray',
                  edgecolor='black', linewidth=0.5)

    # Block cost annotations
    for k in range(num_blocks):
        block_cost = sum(costs[k*n:(k+1)*n])
        ax.annotate(f'Σ={block_cost}', xy=(k*n + n/2 - 0.5, max(costs) + 0.5),
                   fontsize=10, ha='center', fontweight='bold',
                   bbox=dict(boxstyle='round', facecolor=block_colors[k], alpha=0.8))

    ax.set_xlabel('Round', fontsize=12)
    ax.set_ylabel('Cost', fontsize=12)
    ax.set_title('Per-Round Costs with Block Totals', fontsize=13)
    ax.set_xlim(-0.5, R - 0.5)

    fig.tight_layout()
    return fig


if __name__ == "__main__":
    print("Generating visualizations...")

    figs = {
        'block_lower_bound': viz_block_lower_bound(),
        'bipartite_graph': viz_bipartite_graph(),
        'heatmap_systole': viz_heatmap_systole(),
        'protocol_decomposition': viz_protocol_decomposition(),
    }

    for name, fig in figs.items():
        filename = f'{name}.png'
        fig.savefig(filename, dpi=150, bbox_inches='tight')
        print(f"  Saved {filename}")
        b64 = fig_to_base64(fig)
        print(f"  Base64 length: {len(b64)}")

    print("All visualizations generated.")
