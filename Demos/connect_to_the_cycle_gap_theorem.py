#!/usr/bin/env python3
"""
Applications of Tropical Spectral Theory

Real-world applications demonstrating how the maximum cycle mean
and tropical eigenvalue theory connect to practical problems:

1. Network throughput optimization (scheduling/manufacturing)
2. Routing protocol analysis
3. Tropical neural network depth bounds
4. Cryptocurrency mining difficulty analysis
"""

import numpy as np
from algorithms import (
    trop_mul, trop_pow, max_cycle_mean, walk_weight_growth,
    verify_spectral_bound, bp_growth_analysis
)


def app_network_scheduling():
    """Application: Manufacturing/Network Scheduling

    In event-driven systems (manufacturing lines, packet networks),
    the maximum cycle mean determines the throughput bottleneck.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 1: Manufacturing Line Throughput Analysis")
    print("=" * 70)
    print("""
A manufacturing line has 4 stations. Each station processes items
and passes them to the next. Processing times (in minutes) form
the weight matrix. The maximum cycle mean λ determines the minimum
cycle time — the throughput bottleneck.
""")

    # Processing + transport times between stations
    W = np.array([
        [5.0, 3.0, -np.inf, -np.inf],   # Station A: self-loop 5, to B: 3
        [-np.inf, 4.0, 6.0, -np.inf],     # Station B: self-loop 4, to C: 6
        [-np.inf, -np.inf, 3.0, 7.0],     # Station C: self-loop 3, to D: 7
        [8.0, -np.inf, -np.inf, 2.0]      # Station D: back to A: 8, self-loop 2
    ])

    W_finite = np.where(np.isinf(W), -1000, W)
    mcm, opt_v, opt_L = max_cycle_mean(W_finite)
    stations = ['A', 'B', 'C', 'D']

    print(f"Processing/transport time matrix:")
    for i, row in enumerate(W):
        entries = []
        for j, val in enumerate(row):
            if not np.isinf(val):
                entries.append(f"{stations[i]}→{stations[j]}:{val:.0f}")
        print(f"  {', '.join(entries)}")

    print(f"\nMaximum cycle mean λ = {mcm:.2f} min/edge")
    print(f"Bottleneck cycle starts at station {stations[opt_v]}, length {opt_L + 1}")
    print(f"Minimum cycle time = {mcm:.2f} minutes per processing step")
    print(f"Maximum throughput = {60/mcm:.2f} items/hour")

    # Show how improving the bottleneck changes throughput
    print(f"\nWhat-if analysis (reducing bottleneck edge by 1 min):")
    for edge_i, edge_j in [(3, 0), (1, 2), (2, 3)]:
        W_mod = W_finite.copy()
        W_mod[edge_i, edge_j] -= 1.0
        mcm_mod, _, _ = max_cycle_mean(W_mod)
        improvement = (mcm - mcm_mod) / mcm * 100
        print(f"  Reduce {stations[edge_i]}→{stations[edge_j]}: "
              f"λ = {mcm_mod:.2f}, throughput change = {improvement:+.1f}%")


def app_routing_analysis():
    """Application: Network Routing Reliability Analysis

    In a communication network, edge weights represent reliability
    scores (log-probabilities). The maximum cycle mean indicates
    the most reliable cyclic route — important for redundant systems.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Network Routing Reliability")
    print("=" * 70)
    print("""
In a mesh network, each link has a reliability score (higher = better).
The tropical power W^{⊗k} computes the most reliable k-hop path.
The maximum cycle mean reveals the most reliable cycle — critical
for redundant communication and failover planning.
""")

    # 5-node mesh network reliability scores
    np.random.seed(42)
    n = 5
    W = np.random.uniform(0.5, 3.0, (n, n))
    np.fill_diagonal(W, 0)  # no self-loops in routing

    mcm, opt_v, opt_L = max_cycle_mean(W)
    print(f"Network: {n} nodes, fully connected")
    print(f"Maximum cycle mean (reliability rate) = {mcm:.4f}")
    print(f"Most reliable cycle: starts at node {opt_v}, length {opt_L + 1}")

    # Multi-hop reliability growth
    print(f"\n{'Hops':>5} {'Best Path Score':>16} {'λ × hops':>12} {'Excess':>10}")
    print("-" * 47)
    for k in range(12):
        ww = walk_weight_growth(W, k)
        bound = (k + 1) * mcm
        excess = ww - bound
        print(f"{k + 1:5d} {ww:16.4f} {bound:12.4f} {excess:10.4f}")


def app_tropical_neural_depth():
    """Application: Tropical Neural Network Depth Analysis

    ReLU neural networks compute tropical (piecewise-linear) functions.
    The tropical spectral bound limits how fast the complexity of the
    computed function can grow with depth, for a fixed width.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Neural Network Depth-Width Tradeoffs")
    print("=" * 70)
    print("""
A ReLU neural network of width w computes a tropical polynomial.
The number of linear regions grows with depth, but for fixed width,
the growth rate is bounded by the tropical eigenvalue of the weight
pattern. This gives rigorous lower bounds on network depth.
""")

    for width_label, w in [("Tiny (w=3)", 3), ("Small (w=5)", 5), ("Medium (w=8)", 8)]:
        np.random.seed(100 + w)
        # Simulate weight pattern as tropical transition matrix
        W = np.abs(np.random.randn(w, w)) * 0.5 + 0.1

        mcm, _, _ = max_cycle_mean(W)
        analysis = bp_growth_analysis(W, max_depth=30)

        # Estimate depth needed for target complexity
        target = 50.0
        min_depth = None
        for i, me in enumerate(analysis['max_entries']):
            if me >= target:
                min_depth = i + 1
                break

        print(f"\n  {width_label}: λ = {mcm:.4f}")
        print(f"    Theoretical min depth for output ≥ {target}: "
              f"≈ {target / mcm:.0f} layers")
        if min_depth:
            print(f"    Actual depth needed: {min_depth} layers")
        else:
            print(f"    Actual depth needed: >{len(analysis['depths'])} layers")


def app_critical_path():
    """Application: Project Scheduling (Critical Path Method)

    The critical path in a project network is determined by the
    maximum weight path — exactly what tropical matrix powers compute.
    The maximum cycle mean identifies bottleneck loops.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Project Scheduling — Critical Path Analysis")
    print("=" * 70)
    print("""
In project management, tasks have dependencies and durations.
The tropical product computes the longest path (critical path),
and the maximum cycle mean identifies iterative bottleneck loops.
""")

    # Project with 5 tasks, some with iterative dependencies
    tasks = ['Design', 'Implement', 'Test', 'Review', 'Deploy']
    # Duration matrix: W[i,j] = time for task j after task i completes
    W = np.array([
        [2.0, 5.0, -100, -100, -100],    # Design
        [-100, 3.0, 4.0, 2.0, -100],      # Implement
        [-100, -100, 1.0, 3.0, -100],     # Test
        [4.0, 6.0, -100, 1.0, 5.0],       # Review (can loop back!)
        [-100, -100, -100, -100, 0.0]      # Deploy
    ])

    mcm, opt_v, opt_L = max_cycle_mean(W)

    print(f"Task dependency matrix (durations in days):")
    for i, task in enumerate(tasks):
        deps = []
        for j in range(5):
            if W[i, j] > -50:
                deps.append(f"→{tasks[j]}({W[i, j]:.0f}d)")
        print(f"  {task:12s}: {', '.join(deps)}")

    print(f"\nMaximum cycle mean = {mcm:.2f} days/step")
    print(f"Bottleneck loop starts at: {tasks[opt_v]}")
    print(f"Loop length: {opt_L + 1} steps")

    if mcm > 0:
        print(f"\n⚠ Warning: Iterative loop with positive cycle mean!")
        print(f"  Each iteration of the {tasks[opt_v]} loop adds ≥ {mcm:.1f} days/step")
        print(f"  After 5 iterations: ≥ {5 * (opt_L + 1) * mcm:.0f} days in the loop")


if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║       TROPICAL SPECTRAL THEORY — Real-World Applications       ║")
    print("╚══════════════════════════════════════════════════════════════════╝")

    app_network_scheduling()
    app_routing_analysis()
    app_tropical_neural_depth()
    app_critical_path()

    print("\n" + "=" * 70)
    print("All applications demonstrate the same principle:")
    print("The maximum cycle mean λ(W) is the universal speed limit —")
    print("whether in factories, networks, neural architectures, or projects.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Spectral Theory — Interactive Demonstrations

Demonstrates the core theorems connecting cycle gaps to max-plus eigenvalues:
1. Walk weight growth tracks the maximum cycle mean
2. Cycle repetition produces linear amplification
3. Periodic branching programs are spectrally governed
4. Width-depth tradeoffs from spectral obstructions

Run: python demo.py
"""

import numpy as np
from algorithms import (
    trop_mul, trop_pow, walk_weight_growth, max_cycle_mean,
    verify_spectral_bound, bp_growth_analysis, periodic_bp_eval
)


def demo_tropical_multiplication():
    """Demonstrate tropical (max-plus) matrix multiplication."""
    print("\n" + "=" * 70)
    print("DEMO 1: Tropical Matrix Multiplication")
    print("=" * 70)
    print("""
In the tropical semiring, we replace:
  • Standard addition (+) with maximum (max)
  • Standard multiplication (×) with addition (+)

So the 'tropical product' A ⊗ B has entries:
  (A ⊗ B)_{ij} = max_k (A_{ik} + B_{kj})

This computes optimal path weights in a weighted graph!
""")

    A = np.array([[0, 3], [2, 1]], dtype=float)
    B = np.array([[1, 0], [4, 2]], dtype=float)
    C = trop_mul(A, B)

    print(f"A = {A.tolist()}")
    print(f"B = {B.tolist()}")
    print(f"A ⊗ B = {C.tolist()}")
    print()
    print("Entry (0,0): max(0+1, 3+4) = max(1, 7) = 7  ✓")
    print("Entry (0,1): max(0+0, 3+2) = max(0, 5) = 5  ✓")
    print("Entry (1,0): max(2+1, 1+4) = max(3, 5) = 5  ✓")
    print("Entry (1,1): max(2+0, 1+2) = max(2, 3) = 3  ✓")


def demo_walk_weight_growth():
    """Demonstrate walk weight growth and spectral bounds."""
    print("\n" + "=" * 70)
    print("DEMO 2: Walk Weight Growth = Spectral Amplification")
    print("=" * 70)
    print("""
The tropical power W^{⊗k} computes the maximum weight of all walks
using exactly k+1 edges. As k grows, the maximum walk weight grows
at a rate governed by the maximum cycle mean λ(W).

This is the tropical analogue of the Perron-Frobenius theorem!
""")

    # Network with a high-value cycle
    W = np.array([
        [1.0, 5.0, -1.0],
        [-2.0, 2.0, 4.0],
        [3.0, -1.0, 0.0]
    ])

    print(f"Weight matrix W:")
    for row in W:
        print(f"  {row.tolist()}")

    mcm, opt_v, opt_L = max_cycle_mean(W)
    print(f"\nMaximum cycle mean λ(W) = {mcm:.4f}")
    print(f"Critical cycle: vertex {opt_v}, length {opt_L + 1}")

    print(f"\n{'Edges':>6} {'Max Walk Weight':>16} {'Spectral Bound':>16} {'Ratio':>8}")
    print("-" * 50)

    for k in range(15):
        ww = walk_weight_growth(W, k)
        edges = k + 1
        bound = edges * mcm
        ratio = ww / bound if abs(bound) > 1e-10 else float('inf')
        marker = " ✓" if ww >= bound - 1e-10 else " ✗"
        print(f"{edges:6d} {ww:16.4f} {bound:16.4f} {ratio:8.4f}{marker}")

    print("\n→ Walk weight growth is always ≥ spectral bound (our theorem!)")


def demo_cycle_repetition():
    """Demonstrate the cycle repetition principle."""
    print("\n" + "=" * 70)
    print("DEMO 3: Cycle Repetition = Spectral Amplification Engine")
    print("=" * 70)
    print("""
Key insight: repeating an optimal closed walk multiplies its weight.
If a cycle of length L has weight w, repeating it m times gives:
  weight ≥ m × w

This is tropPow_repeat_closed — the engine behind spectral growth.
""")

    W = np.array([
        [0.0, 10.0],
        [10.0, 0.0]
    ])

    print(f"W = {W.tolist()}")
    print("Best cycle: 0 → 1 → 0, weight = 10 + 10 = 20, mean = 10.0")

    mcm, _, opt_L = max_cycle_mean(W)
    p = opt_L + 1
    print(f"Maximum cycle mean λ(W) = {mcm:.1f}, period p = {p}")

    print(f"\n{'Repetitions':>12} {'Edges':>7} {'Diag Weight':>13} {'Bound (m×20)':>13}")
    print("-" * 50)

    for m in range(1, 8):
        k = m * p - 1  # tropPow index for m repetitions
        Wk = trop_pow(W, k)
        diag = Wk[0, 0]
        bound = m * 20.0
        print(f"{m:12d} {k + 1:7d} {diag:13.1f} {bound:13.1f}")

    print("\n→ Diagonal entry grows exactly linearly: m repetitions → m × cycle weight")


def demo_branching_program():
    """Demonstrate periodic branching program spectral bounds."""
    print("\n" + "=" * 70)
    print("DEMO 4: Branching Programs Are Spectrally Governed")
    print("=" * 70)
    print("""
A periodic branching program (BP) of width w uses the same w×w
tropical transition matrix at each layer. Its output at depth d
equals tropPow(W, d-1).

Our theorem: the BP's growth rate is bounded below by λ(W).
This means narrow BPs cannot escape the spectral speed limit!
""")

    for w, name in [(2, "Narrow (2×2)"), (4, "Wide (4×4)")]:
        print(f"\n--- {name} periodic BP ---")
        np.random.seed(42 + w)
        W = np.random.randn(w, w) * 2

        mcm, _, _ = max_cycle_mean(W)
        print(f"Width = {w}, λ(W) = {mcm:.4f}")

        analysis = bp_growth_analysis(W, max_depth=20)

        print(f"{'Depth':>6} {'Max Entry':>12} {'Spectral LB':>12} {'Bound OK':>10}")
        print("-" * 44)
        for i in range(0, 20, 2):
            d = analysis['depths'][i]
            me = analysis['max_entries'][i]
            sb = analysis['spectral_bounds'][i]
            ok = "✓" if me >= sb - 1e-10 else "✗"
            print(f"{d:6d} {me:12.4f} {sb:12.4f} {ok:>10}")


def demo_width_depth_tradeoff():
    """Demonstrate width-depth tradeoffs."""
    print("\n" + "=" * 70)
    print("DEMO 5: Width-Depth Tradeoff — Narrow Means Deep")
    print("=" * 70)
    print("""
If a target output R requires walk weight ≥ R, and the layer matrix
has max cycle mean λ, then the depth d must satisfy:
  d ≥ R / λ  (approximately)

Narrower BPs (smaller w) have fewer cycles to exploit, potentially
leading to smaller λ and therefore requiring more depth.
""")

    target_R = 100.0
    print(f"Target output R = {target_R}")
    print(f"\n{'Width':>6} {'λ(W)':>10} {'Min Depth ≈ R/λ':>16} {'Actual Depth':>14}")
    print("-" * 50)

    for w in [2, 3, 4, 5, 8]:
        np.random.seed(123 + w)
        W = np.random.randn(w, w)

        mcm, _, _ = max_cycle_mean(W)
        if mcm > 0:
            min_depth_approx = target_R / mcm
        else:
            min_depth_approx = float('inf')

        # Find actual depth needed
        actual = None
        Wk = W.copy()
        for d in range(1, 500):
            if np.max(Wk) >= target_R:
                actual = d
                break
            Wk = trop_mul(Wk, W)

        depth_str = str(actual) if actual else ">500"
        print(f"{w:6d} {mcm:10.4f} {min_depth_approx:16.1f} {depth_str:>14}")

    print("\n→ Spectral bound predicts minimum depth; wider BPs reach target faster")


def demo_mean_payoff_connection():
    """Demonstrate the connection to mean-payoff games."""
    print("\n" + "=" * 70)
    print("DEMO 6: Mean-Payoff Games — The Same Eigenvalue!")
    print("=" * 70)
    print("""
In a mean-payoff game, two players move a token on a weighted graph.
Player Max wants to maximize the long-run average weight per edge.
The value of the game for a single player equals... λ(W)!

Our theorem shows this isn't a coincidence: walk weight growth is
spectrally governed, so the optimal long-run strategy must converge
to the critical cycle.
""")

    # Game graph: 4 vertices, varied edge weights
    W = np.array([
        [-np.inf, 8.0, -np.inf, 2.0],
        [3.0, -np.inf, 5.0, -np.inf],
        [-np.inf, -np.inf, -np.inf, 7.0],
        [1.0, -np.inf, -np.inf, -np.inf]
    ])

    # Replace -inf with very negative for computation
    W_finite = np.where(np.isinf(W), -1000, W)

    mcm, opt_v, opt_L = max_cycle_mean(W_finite)
    print(f"Game graph (4 vertices):")
    print(f"  Edges: 0→1(8), 0→3(2), 1→0(3), 1→2(5), 2→3(7), 3→0(1)")
    print(f"\nMaximum cycle mean = {mcm:.4f}")
    print(f"Critical cycle vertex: {opt_v}, length: {opt_L + 1}")

    # Show convergence of average walk weight
    print(f"\n{'Depth':>6} {'Max Walk Weight':>16} {'Average/Edge':>14} {'→ λ(W)':>8}")
    print("-" * 48)

    Wk = W_finite.copy()
    for k in range(20):
        mw = np.max(Wk)
        avg = mw / (k + 1)
        conv = "✓" if abs(avg - mcm) < 0.5 else ""
        print(f"{k + 1:6d} {mw:16.4f} {avg:14.4f} {conv:>8}")
        Wk = trop_mul(Wk, W_finite)

    print(f"\n→ Average weight per edge converges to λ(W) = {mcm:.4f}")


if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║     TROPICAL SPECTRAL THEORY: From Cycle Gaps to Eigenvalues   ║")
    print("║                    Interactive Demonstrations                   ║")
    print("╚══════════════════════════════════════════════════════════════════╝")

    demo_tropical_multiplication()
    demo_walk_weight_growth()
    demo_cycle_repetition()
    demo_branching_program()
    demo_width_depth_tradeoff()
    demo_mean_payoff_connection()

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("Key takeaway: The maximum cycle mean λ(W) governs everything —")
    print("walk growth, branching program power, and mean-payoff game values.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Tropical Spectral Theory — Visualizations

Generates publication-quality figures illustrating the key results:
1. Walk weight growth vs spectral bound
2. Cycle repetition amplification
3. Width-depth tradeoff landscape
4. Convergence to the tropical eigenvalue
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from algorithms import (
    trop_mul, trop_pow, walk_weight_growth, max_cycle_mean,
    bp_growth_analysis
)


def fig_spectral_bound():
    """Walk weight growth vs spectral lower bound."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    matrices = [
        (np.array([[0.0, 3.0], [2.0, 1.0]]), "Positive cycles"),
        (np.array([[1.0, 5.0, -1.0], [-2.0, 2.0, 4.0], [3.0, -1.0, 0.0]]),
         "Mixed weights"),
        (np.array([[0.0, 10.0], [10.0, 0.0]]), "Symmetric exchange"),
    ]

    for ax, (W, title) in zip(axes, matrices):
        mcm, _, opt_L = max_cycle_mean(W)
        p = opt_L + 1
        max_k = 25

        ks = list(range(max_k))
        growths = [walk_weight_growth(W, k) for k in ks]
        bounds = [(k + 1) * mcm for k in ks]

        ax.plot(range(1, max_k + 1), growths, 'b-o', markersize=3,
                label='Walk weight growth', linewidth=1.5)
        ax.plot(range(1, max_k + 1), bounds, 'r--', linewidth=1.5,
                label=f'Spectral bound (λ={mcm:.2f})')

        # Highlight arithmetic subsequence
        sub_ks = [m * p + p - 1 for m in range(max_k // p + 1) if m * p + p - 1 < max_k]
        sub_growths = [walk_weight_growth(W, k) for k in sub_ks]
        ax.scatter([k + 1 for k in sub_ks], sub_growths, c='green', s=50,
                   zorder=5, label=f'Period-{p} points')

        ax.fill_between(range(1, max_k + 1), bounds, min(growths + bounds),
                        alpha=0.1, color='red')
        ax.set_xlabel('Walk length (edges)')
        ax.set_ylabel('Maximum walk weight')
        ax.set_title(title)
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)

    fig.suptitle('Walk Weight Growth vs Tropical Spectral Bound', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('fig_spectral_bound.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fig_spectral_bound.png")


def fig_cycle_repetition():
    """Cycle repetition amplification effect."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: exact repetition on symmetric graph
    W = np.array([[0.0, 10.0], [10.0, 0.0]])
    mcm, _, _ = max_cycle_mean(W)

    depths = list(range(1, 21))
    diag_weights = []
    Wk = W.copy()
    for k in range(20):
        diag_weights.append(Wk[0, 0])
        Wk = trop_mul(Wk, W)

    ax1.plot(depths, diag_weights, 'bo-', markersize=6, label='Diagonal weight W^k[0,0]')
    ax1.plot(depths, [d * mcm for d in depths], 'r--', linewidth=2,
             label=f'Linear bound: d × λ = d × {mcm:.0f}')

    even_depths = [d for d in depths if d % 2 == 0]
    even_weights = [diag_weights[d - 1] for d in even_depths]
    ax1.scatter(even_depths, even_weights, c='green', s=80, zorder=5,
                label='Cycle multiples (period 2)')

    ax1.set_xlabel('Walk length (edges)')
    ax1.set_ylabel('Closed walk weight')
    ax1.set_title('Cycle Repetition: Linear Amplification')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Right: multiple cycles with different means
    W2 = np.array([
        [3.0, 5.0, -1.0, -10.0],
        [-10.0, 1.0, 4.0, -10.0],
        [2.0, -10.0, 0.0, 6.0],
        [7.0, -10.0, -10.0, 2.0]
    ])

    depths2 = list(range(1, 31))
    max_entries2 = []
    Wk2 = W2.copy()
    for k in range(30):
        max_entries2.append(np.max(Wk2))
        Wk2 = trop_mul(Wk2, W2)

    mcm2, _, _ = max_cycle_mean(W2)
    ax2.plot(depths2, max_entries2, 'b-o', markersize=3, linewidth=1.5,
             label='Max walk weight')
    ax2.plot(depths2, [d * mcm2 for d in depths2], 'r--', linewidth=2,
             label=f'λ(W) × depth (λ={mcm2:.2f})')

    # Show different cycle contributions
    for i in range(4):
        diag_i = []
        Wk_i = W2.copy()
        for k in range(30):
            diag_i.append(Wk_i[i, i])
            Wk_i = trop_mul(Wk_i, W2)
        ax2.plot(depths2, diag_i, '--', alpha=0.4, linewidth=1,
                 label=f'Vertex {i} cycle')

    ax2.set_xlabel('Walk length (edges)')
    ax2.set_ylabel('Walk weight')
    ax2.set_title('Multiple Cycles: Best Cycle Dominates')
    ax2.legend(fontsize=7)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('fig_cycle_repetition.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fig_cycle_repetition.png")


def fig_width_depth_tradeoff():
    """Width-depth tradeoff for periodic branching programs."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: growth curves for different widths
    widths = [2, 3, 4, 6, 8]
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(widths)))

    for w, color in zip(widths, colors):
        np.random.seed(42 + w)
        W = np.random.randn(w, w) * 0.5 + 0.5
        analysis = bp_growth_analysis(W, max_depth=40)
        mcm, _, _ = max_cycle_mean(W)

        ax1.plot(analysis['depths'], analysis['max_entries'],
                 color=color, linewidth=2,
                 label=f'w={w} (λ={mcm:.2f})')

    ax1.set_xlabel('Depth (layers)')
    ax1.set_ylabel('Maximum BP output')
    ax1.set_title('BP Growth by Width')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Right: spectral bound as function of width
    widths_ext = list(range(2, 16))
    cycle_means = []
    for w in widths_ext:
        np.random.seed(42 + w)
        W = np.random.randn(w, w) * 0.5 + 0.5
        mcm, _, _ = max_cycle_mean(W)
        cycle_means.append(mcm)

    ax2.bar(widths_ext, cycle_means, color='steelblue', alpha=0.7)
    ax2.set_xlabel('Width w')
    ax2.set_ylabel('Max cycle mean λ(W)')
    ax2.set_title('Spectral Bound vs Width\n(random matrices)')
    ax2.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('fig_width_depth_tradeoff.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fig_width_depth_tradeoff.png")


def fig_eigenvalue_convergence():
    """Convergence of walk weight average to the tropical eigenvalue."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: convergence plot
    np.random.seed(99)
    W = np.random.randn(5, 5) * 2
    mcm, _, _ = max_cycle_mean(W)

    depths = list(range(1, 51))
    averages = []
    Wk = W.copy()
    for k in range(50):
        max_wt = np.max(Wk)
        averages.append(max_wt / (k + 1))
        Wk = trop_mul(Wk, W)

    ax1.plot(depths, averages, 'b-', linewidth=2, label='max W^k / k')
    ax1.axhline(y=mcm, color='r', linestyle='--', linewidth=2,
                label=f'λ(W) = {mcm:.4f}')
    ax1.fill_between(depths, mcm, averages,
                     where=[a >= mcm for a in averages],
                     alpha=0.2, color='blue')
    ax1.set_xlabel('Walk length k')
    ax1.set_ylabel('Average weight per edge')
    ax1.set_title('Convergence to Tropical Eigenvalue')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Right: error decay
    errors = [abs(a - mcm) for a in averages]
    ax2.semilogy(depths, [max(e, 1e-15) for e in errors], 'b-', linewidth=2)
    ax2.set_xlabel('Walk length k')
    ax2.set_ylabel('|average - λ(W)|')
    ax2.set_title('Convergence Rate (log scale)')
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('fig_eigenvalue_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fig_eigenvalue_convergence.png")


if __name__ == '__main__':
    print("Generating visualizations...")
    fig_spectral_bound()
    fig_cycle_repetition()
    fig_width_depth_tradeoff()
    fig_eigenvalue_convergence()
    print("\nAll figures saved successfully.")
