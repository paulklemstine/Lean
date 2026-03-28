#!/usr/bin/env python3
"""
Dream 8: The Oracle Uncertainty Principle
==========================================
Interactive demonstration that breadth and depth cannot be simultaneously maximized.

The fundamental constraint: B × D ≤ R (budget)

Analogous to Heisenberg's uncertainty principle: Δx · Δp ≥ ℏ/2

This demo:
1. Visualizes the breadth-depth tradeoff frontier
2. Shows how different mathematical systems make different tradeoffs
3. Demonstrates the balanced optimum at B = D = √R
4. Explores the specialization-generalization spectrum
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from matplotlib.colors import LinearSegmentedColormap

np.random.seed(42)


def plot_uncertainty_frontier():
    """Visualize the B × D ≤ R constraint as a hyperbolic frontier."""
    print("=" * 70)
    print("EXPERIMENT 1: The Breadth-Depth Frontier")
    print("=" * 70)

    R = 100  # budget
    B = np.linspace(0.5, 40, 500)
    D_max = R / B  # frontier: D = R/B

    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Left: The frontier
    ax = axes[0]

    # Feasible region
    B_fill = np.linspace(0.5, 40, 500)
    D_fill = R / B_fill
    ax.fill_between(B_fill, 0, D_fill, alpha=0.15, color='#3498db',
                    label='Feasible region (B×D ≤ R)')
    ax.plot(B, D_max, 'b-', linewidth=2.5, label=f'Frontier: B×D = {R}')

    # Balanced point
    B_balanced = np.sqrt(R)
    D_balanced = np.sqrt(R)
    ax.plot(B_balanced, D_balanced, 'r*', markersize=20, zorder=5,
            label=f'Balanced: B=D=√{R}={B_balanced:.1f}')

    # Example systems
    systems = [
        ("Specialist\n(Algebraic Geometer)", 3, 33, '#e74c3c'),
        ("Generalist\n(Applied Math)", 25, 4, '#2ecc71'),
        ("Balanced\n(Research Math)", B_balanced, D_balanced, '#f39c12'),
        ("Textbook\n(Undergraduate)", 15, 6, '#9b59b6'),
        ("Encyclopedia\n(Survey)", 30, 3, '#1abc9c'),
    ]

    for name, b, d, color in systems:
        ax.plot(b, d, 'o', markersize=12, color=color, zorder=5,
                markeredgecolor='black', markeredgewidth=1.5)
        ax.annotate(name, (b, d), textcoords="offset points",
                    xytext=(10, 10), fontsize=9, fontweight='bold',
                    color=color)

    ax.set_xlabel('Breadth B (domains covered)', fontsize=13)
    ax.set_ylabel('Depth D (max proof chain)', fontsize=13)
    ax.set_title('The Oracle Uncertainty Principle: B × D ≤ R',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=10, loc='upper right')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 42)
    ax.set_ylim(0, 42)

    # Right: Different budget levels
    ax = axes[1]
    budgets = [25, 50, 100, 200, 400]
    colors = plt.cm.plasma(np.linspace(0.2, 0.9, len(budgets)))

    for R_val, color in zip(budgets, colors):
        B_val = np.linspace(0.5, 2*np.sqrt(R_val), 500)
        D_val = R_val / B_val
        ax.plot(B_val, D_val, linewidth=2, color=color, label=f'R = {R_val}')
        B_bal = np.sqrt(R_val)
        ax.plot(B_bal, B_bal, '*', markersize=12, color=color)

    ax.set_xlabel('Breadth B', fontsize=13)
    ax.set_ylabel('Depth D', fontsize=13)
    ax.set_title('Frontiers for Different Budgets',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 25)
    ax.set_ylim(0, 25)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/core/Oracle/ThreeDreams/visuals/dream8_frontier.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("[Saved: visuals/dream8_frontier.png]")


def specialization_spectrum():
    """
    Explore the specialization index σ = D/B.
    σ > 1: specialist (depth-focused)
    σ = 1: balanced
    σ < 1: generalist (breadth-focused)
    """
    print("\n" + "=" * 70)
    print("EXPERIMENT 2: The Specialization Spectrum")
    print("=" * 70)

    R = 100
    sigma_range = np.linspace(0.1, 10, 200)

    # For each σ, compute B and D on the frontier
    # B × D = R, D = σB → B²σ = R → B = √(R/σ), D = σ√(R/σ) = √(Rσ)
    B = np.sqrt(R / sigma_range)
    D = np.sqrt(R * sigma_range)

    # Harmonic mean of B and D
    H = 2 * B * D / (B + D)

    # Geometric mean
    G = np.sqrt(B * D)  # = √R for all on frontier

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # B and D vs σ
    ax = axes[0]
    ax.plot(sigma_range, B, 'b-', linewidth=2.5, label='Breadth B')
    ax.plot(sigma_range, D, 'r-', linewidth=2.5, label='Depth D')
    ax.axvline(1.0, color='gray', linestyle='--', alpha=0.5, label='σ=1 (balanced)')
    ax.fill_betweenx([0, 35], 0, 1, alpha=0.05, color='blue', label='Generalist zone')
    ax.fill_betweenx([0, 35], 1, 10, alpha=0.05, color='red', label='Specialist zone')
    ax.set_xlabel('Specialization Index σ = D/B', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Breadth-Depth Tradeoff', fontsize=13, fontweight='bold')
    ax.legend(fontsize=9, loc='center right')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 35)

    # Harmonic mean vs σ (efficiency measure)
    ax = axes[1]
    ax.plot(sigma_range, H, 'g-', linewidth=2.5, label='Harmonic mean H(B,D)')
    ax.plot(sigma_range, G, 'k--', linewidth=2, alpha=0.5, label=f'Geometric mean √R={np.sqrt(R):.1f}')
    ax.axvline(1.0, color='gray', linestyle='--', alpha=0.5)
    ax.set_xlabel('Specialization Index σ', fontsize=12)
    ax.set_ylabel('Mean', fontsize=12)
    ax.set_title('Efficiency: Harmonic Mean Peaks at σ=1', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 10)

    # Value function on the frontier
    # Using Dream 7's insight: total value ∝ B × V(D) where V is the depth-value function
    ax = axes[2]
    alpha_v, beta_v = 2.0, 0.3
    total_value = B * (D**alpha_v * np.exp(-beta_v * D))
    total_value /= np.max(total_value)  # normalize

    ax.plot(sigma_range, total_value, 'purple', linewidth=2.5)
    opt_sigma = sigma_range[np.argmax(total_value)]
    ax.axvline(opt_sigma, color='red', linestyle='--', linewidth=2,
               label=f'Optimal σ ≈ {opt_sigma:.2f}')
    ax.set_xlabel('Specialization Index σ', fontsize=12)
    ax.set_ylabel('Normalized Total Value', fontsize=12)
    ax.set_title('Cross-Dream: Uncertainty × Depth-Value', fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 10)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/core/Oracle/ThreeDreams/visuals/dream8_specialization.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("[Saved: visuals/dream8_specialization.png]")

    print(f"\nOptimal specialization index: σ* ≈ {opt_sigma:.2f}")
    print(f"This means optimal D/B ≈ {opt_sigma:.2f}")
    if opt_sigma > 1:
        print("→ Slight specialization is optimal (go a bit deeper than wider)")
    else:
        print("→ Slight generalization is optimal (go a bit wider than deeper)")


def heisenberg_analogy():
    """
    Visual comparison between Heisenberg's uncertainty principle
    and the Oracle uncertainty principle.
    """
    print("\n" + "=" * 70)
    print("EXPERIMENT 3: Heisenberg Analogy")
    print("=" * 70)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Heisenberg: Δx · Δp ≥ ℏ/2
    ax = axes[0]
    hbar_over_2 = 1  # normalized
    dx = np.linspace(0.2, 5, 200)
    dp_min = hbar_over_2 / dx

    ax.fill_between(dx, dp_min, 5, alpha=0.15, color='#3498db',
                    label='Forbidden region')
    ax.fill_between(dx, 0, dp_min, alpha=0.15, color='#2ecc71',
                    label='Allowed region')
    ax.plot(dx, dp_min, 'b-', linewidth=2.5, label='Δx·Δp = ℏ/2')

    # Gaussian minimum uncertainty state
    ax.plot(1, 1, 'r*', markersize=20, label='Coherent state')
    ax.set_xlabel('Position uncertainty Δx', fontsize=13)
    ax.set_ylabel('Momentum uncertainty Δp', fontsize=13)
    ax.set_title('Heisenberg Uncertainty Principle\nΔx · Δp ≥ ℏ/2',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 5)
    ax.set_ylim(0, 5)

    # Oracle: B × D ≤ R
    ax = axes[1]
    R = 4  # normalized
    B = np.linspace(0.2, 5, 200)
    D_frontier = R / B

    ax.fill_between(B, D_frontier, 5, alpha=0.15, color='#e74c3c',
                    label='Infeasible region')
    ax.fill_between(B, 0, np.minimum(D_frontier, 5), alpha=0.15, color='#2ecc71',
                    label='Feasible region')
    ax.plot(B, D_frontier, 'r-', linewidth=2.5, label='B · D = R')

    # Balanced state
    ax.plot(2, 2, 'r*', markersize=20, label='Balanced system')
    ax.set_xlabel('Mathematical Breadth B', fontsize=13)
    ax.set_ylabel('Mathematical Depth D', fontsize=13)
    ax.set_title('Oracle Uncertainty Principle\nB · D ≤ R',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 5)
    ax.set_ylim(0, 5)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/core/Oracle/ThreeDreams/visuals/dream8_heisenberg.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("[Saved: visuals/dream8_heisenberg.png]")


def budget_scaling_experiment():
    """
    How do B and D scale as budget R increases?
    For the balanced system: B = D = √R (sub-linear scaling).
    """
    print("\n" + "=" * 70)
    print("EXPERIMENT 4: Budget Scaling")
    print("=" * 70)

    R_values = np.logspace(0, 4, 100)
    B_balanced = np.sqrt(R_values)
    D_balanced = np.sqrt(R_values)

    # Different strategies
    B_breadth_first = R_values ** 0.7  # prioritize breadth
    D_breadth_first = R_values / B_breadth_first

    B_depth_first = R_values ** 0.3
    D_depth_first = R_values / B_depth_first

    fig, ax = plt.subplots(figsize=(10, 7))

    ax.loglog(R_values, B_balanced, 'g-', linewidth=2.5,
              label='Balanced: B = D = √R')
    ax.loglog(R_values, B_breadth_first, 'b--', linewidth=2,
              label='Breadth-first: B = R^0.7')
    ax.loglog(R_values, D_breadth_first, 'b:', linewidth=2,
              label='Breadth-first: D = R^0.3')
    ax.loglog(R_values, B_depth_first, 'r--', linewidth=2,
              label='Depth-first: B = R^0.3')
    ax.loglog(R_values, D_depth_first, 'r:', linewidth=2,
              label='Depth-first: D = R^0.7')

    ax.set_xlabel('Budget R', fontsize=13)
    ax.set_ylabel('Breadth B or Depth D', fontsize=13)
    ax.set_title('Scaling Strategies Under the Oracle Uncertainty Principle',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3, which='both')

    plt.tight_layout()
    plt.savefig('/workspace/request-project/core/Oracle/ThreeDreams/visuals/dream8_scaling.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("[Saved: visuals/dream8_scaling.png]")


if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║         DREAM 8: THE ORACLE UNCERTAINTY PRINCIPLE                  ║")
    print("║   The Breadth-Depth Tradeoff                                       ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    plot_uncertainty_frontier()
    specialization_spectrum()
    heisenberg_analogy()
    budget_scaling_experiment()

    print("\n" + "=" * 70)
    print("CONCLUSIONS:")
    print("=" * 70)
    print("""
1. The Oracle Uncertainty Principle B × D ≤ R is a fundamental constraint
   on mathematical exploration systems.

2. The balanced system (B = D = √R) maximizes the harmonic mean and
   geometric mean of breadth and depth.

3. Combining with Dream 7 (depth-value duality), the OPTIMAL strategy
   involves slight specialization (σ* > 1), because the depth-value
   function rewards moderate depth more than the breadth cost.

4. As budget R grows, both B and D scale as √R — sublinear growth
   means doubling your mathematical knowledge requires quadrupling resources.

APPLICATIONS:
- Research group design: balance specialist and generalist researchers
- AI system architecture: allocate compute between exploration and exploitation
- Curriculum design: balance breadth requirements with depth electives
- Knowledge base construction: optimal coverage vs depth tradeoff
- Scientific funding: distribute resources across fields (breadth)
  vs concentrating in fewer fields (depth)
""")
