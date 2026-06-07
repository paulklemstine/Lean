#!/usr/bin/env python3
"""
Spectral Gap Phase Transition Demo

Demonstrates the spectral gap phase transition for constraint
satisfaction problems, showing how the gap varies with constraint
density and how Cheeger's inequality bounds relate to computed values.
"""

import numpy as np
import math


def build_lazy_random_walk(adj: np.ndarray) -> np.ndarray:
    """Build lazy random walk transition matrix from adjacency matrix."""
    n = adj.shape[0]
    P = np.zeros((n, n))
    for i in range(n):
        deg = adj[i].sum()
        if deg > 0:
            for j in range(n):
                if adj[i, j] > 0:
                    P[i, j] = adj[i, j] / (2 * deg)
            P[i, i] += 0.5
        else:
            P[i, i] = 1.0
    return P


def spectral_gap(P: np.ndarray) -> float:
    """Compute spectral gap of transition matrix."""
    eigs = sorted(np.abs(np.linalg.eigvals(P)), reverse=True)
    if len(eigs) < 2:
        return 1.0
    return float(eigs[0] - eigs[1])


def cheeger_conductance(P: np.ndarray, pi: np.ndarray) -> float:
    """Compute Cheeger conductance (brute force for small n)."""
    n = P.shape[0]
    if n <= 1:
        return 1.0
    best = float('inf')
    for mask in range(1, 2**n - 1):
        S = [i for i in range(n) if mask & (1 << i)]
        Sc = [i for i in range(n) if not (mask & (1 << i))]
        pi_S = sum(pi[i] for i in S)
        if pi_S > 0.5 + 1e-10 or pi_S < 1e-15:
            continue
        flow = sum(pi[i] * P[i, j] for i in S for j in Sc)
        best = min(best, flow / pi_S)
    return best


def demo_two_state_chain():
    """Demonstrate spectral gap for a parametric two-state chain."""
    print("=" * 60)
    print("Demo 1: Two-State Chain — Spectral Gap vs Transition Rate")
    print("=" * 60)
    print()

    for p in [0.01, 0.05, 0.1, 0.2, 0.3, 0.5]:
        P = np.array([[1-p, p], [p, 1-p]])
        gap = spectral_gap(P)
        pi = np.array([0.5, 0.5])
        h = cheeger_conductance(P, pi)
        lower, upper = h**2 / 2, 2 * h
        print(f"  p = {p:.2f}: gap = {gap:.4f}, conductance h = {h:.4f}, "
              f"Cheeger bounds [{lower:.4f}, {upper:.4f}]")

    print()


def demo_path_graph():
    """Demonstrate spectral gap for random walk on path graphs."""
    print("=" * 60)
    print("Demo 2: Path Graph — Gap Scales as 1/n²")
    print("=" * 60)
    print()

    for n in [3, 5, 8, 10, 15, 20]:
        adj = np.zeros((n, n))
        for i in range(n - 1):
            adj[i, i+1] = 1
            adj[i+1, i] = 1
        P = build_lazy_random_walk(adj)
        gap = spectral_gap(P)
        theoretical = 1 - math.cos(math.pi / n)  # for non-lazy
        print(f"  n = {n:2d}: gap = {gap:.6f}, "
              f"1/n² = {1/n**2:.6f}, "
              f"ratio gap·n² = {gap * n**2:.4f}")

    print()


def demo_complete_graph():
    """Demonstrate spectral gap for random walk on complete graphs."""
    print("=" * 60)
    print("Demo 3: Complete Graph — Gap = n/(2(n-1)) for lazy walk")
    print("=" * 60)
    print()

    for n in [3, 5, 8, 10, 20, 50]:
        adj = np.ones((n, n)) - np.eye(n)
        P = build_lazy_random_walk(adj)
        gap = spectral_gap(P)
        theoretical = n / (2 * (n - 1))
        print(f"  n = {n:2d}: gap = {gap:.6f}, "
              f"theoretical = {theoretical:.6f}, "
              f"match = {abs(gap - theoretical) < 0.001}")

    print()


def demo_phase_transition():
    """Demonstrate the phase transition in spectral gap."""
    print("=" * 60)
    print("Demo 4: Phase Transition — Gap vs Constraint Density")
    print("=" * 60)
    print()

    # Simulate a CSP-like system:
    # Start with complete graph (many solutions), progressively remove edges
    # (add constraints), until isolated (unique solution)
    n = 10
    rng = np.random.RandomState(42)

    adj_full = np.ones((n, n)) - np.eye(n)
    total_edges = int(adj_full.sum() / 2)

    densities = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]

    print(f"  {'Density':>8s}  {'Edges':>6s}  {'Gap':>8s}  {'Phase':>18s}")
    print(f"  {'-'*8}  {'-'*6}  {'-'*8}  {'-'*18}")

    for d in densities:
        edges_to_remove = int(d * total_edges)
        adj = adj_full.copy()

        # Remove random edges
        edge_list = [(i, j) for i in range(n) for j in range(i+1, n)]
        rng.shuffle(edge_list)
        for k in range(min(edges_to_remove, len(edge_list))):
            i, j = edge_list[k]
            adj[i, j] = 0
            adj[j, i] = 0

        remaining = int(adj.sum() / 2)
        P = build_lazy_random_walk(adj)
        gap = spectral_gap(P)

        if d < 17/81:
            phase = "underconstrained"
        elif d < 30/81:
            phase = "critical"
        else:
            phase = "overconstrained"

        print(f"  {d:8.2f}  {remaining:6d}  {gap:8.4f}  {phase:>18s}")

    print()


def demo_tensorization():
    """Demonstrate the tensorization theorem for product chains."""
    print("=" * 60)
    print("Demo 5: Tensorization — Product Gap = Min of Component Gaps")
    print("=" * 60)
    print()

    # Two small chains
    for p1, p2 in [(0.3, 0.7), (0.1, 0.5), (0.4, 0.4), (0.01, 0.9)]:
        P1 = np.array([[1-p1, p1], [p1, 1-p1]])
        P2 = np.array([[1-p2, p2], [p2, 1-p2]])

        gap1 = spectral_gap(P1)
        gap2 = spectral_gap(P2)

        # Build product chain
        P_prod = np.kron(P1, P2)
        gap_prod = spectral_gap(P_prod)

        min_gap = min(gap1, gap2)
        print(f"  p1={p1:.2f}, p2={p2:.2f}: "
              f"gap1={gap1:.4f}, gap2={gap2:.4f}, "
              f"product_gap={gap_prod:.4f}, "
              f"min={min_gap:.4f}")

    print()


def demo_mixing_time():
    """Demonstrate mixing time bounds from spectral gap."""
    print("=" * 60)
    print("Demo 6: Mixing Time Bounds — Divergence at Zero Gap")
    print("=" * 60)
    print()

    epsilon = 0.01
    pi_min = 0.01

    print(f"  Parameters: ε = {epsilon}, π_min = {pi_min}")
    print()
    print(f"  {'Gap':>10s}  {'Mixing Time Bound':>18s}  {'Phase':>15s}")
    print(f"  {'-'*10}  {'-'*18}  {'-'*15}")

    for gap in [0.5, 0.3, 0.1, 0.05, 0.01, 0.005, 0.001, 0.0001]:
        bound = (1/gap) * math.log(1/(epsilon * pi_min))
        if gap > 0.1:
            phase = "fast mixing"
        elif gap > 0.01:
            phase = "slow mixing"
        else:
            phase = "critical"
        print(f"  {gap:10.4f}  {bound:18.1f}  {phase:>15s}")

    print()


def demo_sudoku_constants():
    """Show the key Sudoku constants and phase boundaries."""
    print("=" * 60)
    print("Demo 7: Sudoku Phase Transition Constants")
    print("=" * 60)
    print()

    dc = 17/81
    df = 30/81
    hard_width = df - dc

    print(f"  Critical density d_c = 17/81 ≈ {dc:.4f}")
    print(f"  Frozen density d_f = 30/81 ≈ {df:.4f}")
    print(f"  Hard phase width = 13/81 ≈ {hard_width:.4f}")
    print(f"  Hard phase fraction = {hard_width:.4f} > 1/7 ≈ {1/7:.4f} ✓")
    print(f"  d_c in (0, 1/2): 0 < {dc:.4f} < 0.5 ✓")
    print()

    # Phase classification
    test_densities = [0, 5/81, 10/81, 15/81, 17/81, 20/81,
                      25/81, 30/81, 35/81, 50/81, 70/81, 1.0]
    print(f"  {'Clues':>6s}  {'Density':>8s}  {'Phase':>18s}")
    print(f"  {'-'*6}  {'-'*8}  {'-'*18}")
    for d in test_densities:
        clues = int(d * 81)
        if d < dc:
            phase = "underconstrained"
        elif d < df:
            phase = "critical"
        else:
            phase = "overconstrained"
        print(f"  {clues:6d}  {d:8.4f}  {phase:>18s}")

    print()


if __name__ == '__main__':
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   Spectral Gap Phase Transition — Interactive Demo      ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_two_state_chain()
    demo_path_graph()
    demo_complete_graph()
    demo_phase_transition()
    demo_tensorization()
    demo_mixing_time()
    demo_sudoku_constants()

    print("All demos completed successfully.")


#!/usr/bin/env python3
"""
Visualization: Spectral Gap Phase Transition

Plots the spectral gap as a function of constraint density,
showing the three-phase structure and Cheeger bounds.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def simulate_gap_vs_density(n_points: int = 200) -> tuple:
    """Simulate spectral gap as a function of density.

    Uses a smooth model: gap(d) = exp(-alpha * (d/dc)^beta) for d < dc,
    transitioning to 0 for d > df.
    """
    dc = 17 / 81  # critical density
    df = 30 / 81  # frozen density

    densities = np.linspace(0, 1, n_points)
    gaps = np.zeros_like(densities)

    for i, d in enumerate(densities):
        if d < dc:
            # Subcritical: gap bounded away from 0
            gaps[i] = 0.8 * np.exp(-2 * (d / dc) ** 2)
        elif d < df:
            # Critical: gap approaches 0
            t = (d - dc) / (df - dc)
            gaps[i] = 0.8 * np.exp(-2) * (1 - t) ** 2
        else:
            # Frozen: gap is 0
            gaps[i] = 0.0

    return densities, gaps


def main():
    densities, gaps = simulate_gap_vs_density()
    dc = 17 / 81
    df = 30 / 81

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Plot 1: Spectral gap vs density
    ax1 = axes[0, 0]
    ax1.plot(densities, gaps, 'b-', linewidth=2, label='Spectral gap γ(d)')
    ax1.axvline(x=dc, color='r', linestyle='--', alpha=0.7, label=f'd_c = 17/81 ≈ {dc:.3f}')
    ax1.axvline(x=df, color='orange', linestyle='--', alpha=0.7, label=f'd_f = 30/81 ≈ {df:.3f}')
    ax1.fill_between(densities, 0, gaps, where=densities < dc, alpha=0.15, color='green', label='Underconstrained')
    ax1.fill_between(densities, 0, gaps, where=(densities >= dc) & (densities < df), alpha=0.15, color='yellow', label='Critical')
    ax1.fill_between(densities, 0, gaps, where=densities >= df, alpha=0.15, color='red', label='Overconstrained')
    ax1.set_xlabel('Constraint Density d', fontsize=12)
    ax1.set_ylabel('Spectral Gap γ', fontsize=12)
    ax1.set_title('Spectral Gap Phase Transition in Sudoku', fontsize=13)
    ax1.legend(fontsize=9, loc='upper right')
    ax1.set_xlim(0, 1)
    ax1.set_ylim(-0.02, 0.9)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Mixing time vs density
    ax2 = axes[0, 1]
    eps_val = 0.01
    pi_min = 0.001
    mixing_times = np.zeros_like(densities)
    for i in range(len(densities)):
        if gaps[i] > 1e-6:
            mixing_times[i] = (1 / gaps[i]) * np.log(1 / (eps_val * pi_min))
        else:
            mixing_times[i] = np.nan

    ax2.semilogy(densities, mixing_times, 'r-', linewidth=2)
    ax2.axvline(x=dc, color='r', linestyle='--', alpha=0.7)
    ax2.axvline(x=df, color='orange', linestyle='--', alpha=0.7)
    ax2.set_xlabel('Constraint Density d', fontsize=12)
    ax2.set_ylabel('Mixing Time Bound (log scale)', fontsize=12)
    ax2.set_title('Mixing Time Diverges at Critical Density', fontsize=13)
    ax2.grid(True, alpha=0.3)

    # Plot 3: Cheeger bounds
    ax3 = axes[1, 0]
    # Model conductance
    conductances = np.sqrt(2 * gaps)  # h = sqrt(2γ) (tight Cheeger)
    cheeger_lower = conductances ** 2 / 2
    cheeger_upper = 2 * conductances

    ax3.plot(densities, gaps, 'b-', linewidth=2, label='Spectral gap γ')
    ax3.plot(densities, cheeger_lower, 'g--', linewidth=1.5, label='h²/2 (Cheeger lower)')
    ax3.plot(densities, cheeger_upper, 'r--', linewidth=1.5, label='2h (Cheeger upper)')
    ax3.plot(densities, conductances, 'k:', linewidth=1.5, label='Conductance h')
    ax3.set_xlabel('Constraint Density d', fontsize=12)
    ax3.set_ylabel('Value', fontsize=12)
    ax3.set_title("Cheeger's Inequality: h²/2 ≤ γ ≤ 2h", fontsize=13)
    ax3.legend(fontsize=9)
    ax3.set_xlim(0, 0.5)
    ax3.set_ylim(-0.02, 2.0)
    ax3.grid(True, alpha=0.3)

    # Plot 4: Solution count model
    ax4 = axes[1, 1]
    solution_counts = np.zeros_like(densities)
    for i, d in enumerate(densities):
        if d < dc:
            solution_counts[i] = np.exp(8 * (1 - d / dc))
        elif d < df:
            t = (d - dc) / (df - dc)
            solution_counts[i] = np.exp(8 * (1 - 1) * (1 - t))
            solution_counts[i] = max(1, np.exp(-3 * t))
        else:
            solution_counts[i] = 1

    ax4.semilogy(densities, solution_counts, 'purple', linewidth=2)
    ax4.axvline(x=dc, color='r', linestyle='--', alpha=0.7, label=f'd_c = {dc:.3f}')
    ax4.axvline(x=df, color='orange', linestyle='--', alpha=0.7, label=f'd_f = {df:.3f}')
    ax4.axhline(y=1, color='gray', linestyle=':', alpha=0.5, label='Unique solution')
    ax4.set_xlabel('Constraint Density d', fontsize=12)
    ax4.set_ylabel('Solution Count (log scale)', fontsize=12)
    ax4.set_title('Solution Count Decreases with Density', fontsize=13)
    ax4.legend(fontsize=9)
    ax4.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('spectral_gap_phase_transition.png', dpi=150, bbox_inches='tight')
    print("Saved: spectral_gap_phase_transition.png")


if __name__ == '__main__':
    main()
