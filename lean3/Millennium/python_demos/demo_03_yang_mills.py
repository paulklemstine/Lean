#!/usr/bin/env python3
"""
Yang-Mills Existence and Mass Gap — Visual Demonstration

Visualizes:
1. Lattice gauge theory (Wilson loops)
2. The mass gap concept
3. Confinement via the quark-antiquark potential

Run: python demo_03_yang_mills.py
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import matplotlib.colors as mcolors


def plot_lattice_gauge_theory():
    """Visualize a 2D lattice gauge configuration."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Panel 1: Lattice with gauge links
    ax = axes[0]
    N = 6
    for i in range(N):
        for j in range(N):
            # Draw vertices
            ax.plot(i, j, 'ko', markersize=8)

            # Draw horizontal links with random SU(2) phases
            if i < N - 1:
                phase = np.random.uniform(-np.pi, np.pi)
                color = plt.cm.hsv((phase + np.pi) / (2 * np.pi))
                ax.annotate('', xy=(i + 0.8, j), xytext=(i + 0.2, j),
                           arrowprops=dict(arrowstyle='->', color=color, lw=2.5))

            # Draw vertical links
            if j < N - 1:
                phase = np.random.uniform(-np.pi, np.pi)
                color = plt.cm.hsv((phase + np.pi) / (2 * np.pi))
                ax.annotate('', xy=(i, j + 0.8), xytext=(i, j + 0.2),
                           arrowprops=dict(arrowstyle='->', color=color, lw=2.5))

    # Highlight a Wilson loop (plaquette)
    rect_x = [1.1, 2.9, 2.9, 1.1, 1.1]
    rect_y = [1.1, 1.1, 2.9, 2.9, 1.1]
    ax.plot(rect_x, rect_y, 'r-', linewidth=4, alpha=0.7)
    ax.text(2, 2, 'W□', fontsize=16, ha='center', va='center',
           color='red', fontweight='bold',
           bbox=dict(facecolor='white', edgecolor='red', alpha=0.8))

    ax.set_xlim(-0.5, N - 0.5)
    ax.set_ylim(-0.5, N - 0.5)
    ax.set_title('Lattice Gauge Theory\nColored arrows = gauge links Uμ(x)',
                fontsize=12, fontweight='bold')
    ax.set_xlabel('Lattice site x₁', fontsize=11)
    ax.set_ylabel('Lattice site x₂', fontsize=11)
    ax.set_aspect('equal')

    # Panel 2: The mass gap — spectral illustration
    ax = axes[1]

    # Energy spectrum
    E_vacuum = 0
    E_gap = 1.5  # mass gap Δ
    E_states = [0, 1.5, 2.1, 2.8, 3.2, 3.5, 4.0, 4.3, 4.8, 5.2]

    # Continuum above gap
    E_cont = np.linspace(E_gap, 6, 100)
    density = np.exp(-(E_cont - E_gap)) * (E_cont - E_gap)**0.5

    ax.barh([0], [0.3], height=0.15, color='blue', alpha=0.8, label='Vacuum |0⟩')

    # Discrete states
    for i, E in enumerate(E_states[1:4]):
        ax.barh([E], [0.3], height=0.1, color='red', alpha=0.7)

    # Continuum
    ax.fill_betweenx(E_cont, 0, density * 0.8, alpha=0.3, color='orange', label='Continuum')

    # Mass gap annotation
    ax.annotate('', xy=(0.5, E_gap - 0.05), xytext=(0.5, 0.05),
               arrowprops=dict(arrowstyle='<->', color='green', lw=3))
    ax.text(0.65, E_gap / 2, f'Δ = {E_gap}\n(mass gap)',
           fontsize=13, fontweight='bold', color='green', va='center')

    ax.set_ylim(-0.5, 6)
    ax.set_xlim(-0.1, 1.5)
    ax.set_ylabel('Energy E', fontsize=12)
    ax.set_title('The Mass Gap\nΔ = inf{E > 0 : E ∈ σ(H)}',
                fontsize=12, fontweight='bold')
    ax.set_xticks([])
    ax.legend(fontsize=10, loc='upper right')
    ax.grid(True, alpha=0.3, axis='y')

    # Panel 3: Quark-antiquark potential (confinement)
    ax = axes[2]
    r = np.linspace(0.1, 3, 200)

    # QED: Coulomb potential (no confinement)
    V_qed = -1 / r
    ax.plot(r, V_qed, 'b--', linewidth=2, label='QED: V(r) ~ -1/r (no confinement)')

    # QCD: Cornell potential (confinement!)
    sigma = 1.0  # string tension
    alpha_s = 0.3
    V_qcd = -alpha_s / r + sigma * r
    ax.plot(r, V_qcd, 'r-', linewidth=3, label='QCD: V(r) ~ -α/r + σr (confinement!)')

    # String tension visualization
    r_break = 2.5
    ax.fill_between(r[r > 1.5], V_qcd[r > 1.5], V_qcd[r > 1.5] - 0.3,
                    alpha=0.2, color='red')
    ax.annotate('String tension σ\n→ linear confinement',
               xy=(2.2, V_qcd[np.argmin(np.abs(r - 2.2))]),
               xytext=(1.5, 3.5), fontsize=11, fontweight='bold',
               arrowprops=dict(arrowstyle='->', color='red', lw=2))

    ax.axhline(y=0, color='gray', linestyle='-', alpha=0.3)
    ax.set_xlabel('Quark separation r', fontsize=12)
    ax.set_ylabel('Potential V(r)', fontsize=12)
    ax.set_title('Confinement: QED vs QCD\nThe Mass Gap is Confinement',
                fontsize=12, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-5, 5)

    plt.tight_layout()
    plt.savefig('demo_03_yang_mills.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved demo_03_yang_mills.png")


def plot_wilson_loop_area_law():
    """
    Demonstrate area law vs perimeter law for Wilson loops,
    which distinguishes confined from deconfined phases.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Panel 1: Wilson loop expectation vs area
    ax = axes[0]
    areas = np.arange(1, 25)

    # Confined phase: ⟨W(C)⟩ ~ exp(-σ·Area)
    sigma = 0.2
    W_confined = np.exp(-sigma * areas)

    # Deconfined phase: ⟨W(C)⟩ ~ exp(-μ·Perimeter)
    mu = 0.1
    perimeters = 4 * np.sqrt(areas)  # approximate
    W_deconfined = np.exp(-mu * perimeters)

    ax.semilogy(areas, W_confined, 'rs-', linewidth=2, markersize=8,
               label='Confined: ⟨W⟩ ~ e^{-σ·Area}')
    ax.semilogy(areas, W_deconfined, 'bo-', linewidth=2, markersize=8,
               label='Deconfined: ⟨W⟩ ~ e^{-μ·Perimeter}')

    ax.set_xlabel('Loop Area', fontsize=12)
    ax.set_ylabel('⟨W(C)⟩ (log scale)', fontsize=12)
    ax.set_title('Wilson Loop: Confinement Criterion\nArea Law ↔ Confinement',
                fontsize=12, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Panel 2: Monte Carlo simulation of 2D lattice gauge theory
    ax = axes[1]

    # Simulate 2D U(1) lattice gauge theory
    L = 20  # lattice size
    beta_values = np.linspace(0.1, 5, 20)
    plaquette_avgs = []

    for beta in beta_values:
        # In 2D U(1), exact result: ⟨plaquette⟩ = I₁(β)/I₀(β)
        from scipy.special import i0, i1
        plaq = i1(beta) / i0(beta)
        plaquette_avgs.append(plaq)

    ax.plot(beta_values, plaquette_avgs, 'g-o', linewidth=2, markersize=6)
    ax.set_xlabel('Coupling β = 1/g²', fontsize=12)
    ax.set_ylabel('⟨Plaquette⟩', fontsize=12)
    ax.set_title('2D U(1) Lattice Gauge Theory\nExact: ⟨□⟩ = I₁(β)/I₀(β)',
                fontsize=12, fontweight='bold')
    ax.grid(True, alpha=0.3)
    ax.axhline(y=1, color='r', linestyle='--', alpha=0.5, label='Weak coupling limit')
    ax.axhline(y=0, color='b', linestyle='--', alpha=0.5, label='Strong coupling limit')
    ax.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('demo_03b_yang_mills_wilson.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved demo_03b_yang_mills_wilson.png")


if __name__ == '__main__':
    print("=" * 60)
    print("Yang-Mills — Visual Demonstrations")
    print("=" * 60)
    print("\n1. Generating lattice gauge theory visualization...")
    plot_lattice_gauge_theory()
    print("\n2. Generating Wilson loop analysis...")
    plot_wilson_loop_area_law()
    print("\nDone! Check the generated PNG files.")
