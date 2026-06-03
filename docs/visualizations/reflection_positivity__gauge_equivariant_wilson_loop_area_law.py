#!/usr/bin/env python3
"""
Visualization: Wilson Loop Area Law and Confinement

Demonstrates the connection between mass gap and confinement
through the Wilson loop area law.
"""

import math


def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available.")
        sigma = 0.3
        for r in range(1, 11):
            for T in [5, 10, 20]:
                bound = math.exp(-sigma * r * T)
                print(f"  r={r:2d}, T={T:2d}: |W| ≤ {bound:.6e}")
        return

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle('Wilson Loop Area Law and Confinement', fontsize=14, fontweight='bold')

    # Panel 1: Wilson loop vs area for different σ
    ax1 = axes[0]
    areas = np.arange(0, 25)
    for sigma in [0.1, 0.3, 0.5, 1.0]:
        bounds = [math.exp(-sigma * a) for a in areas]
        ax1.semilogy(areas, bounds, '-o', markersize=3, label=f'σ = {sigma}')

    ax1.set_xlabel('Area A')
    ax1.set_ylabel('|⟨W(A)⟩|')
    ax1.set_title('Wilson Loop Area Law')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Panel 2: Confining potential V(r) = σ·r
    ax2 = axes[1]
    r_vals = np.linspace(0.1, 5, 100)
    for sigma in [0.1, 0.3, 0.5, 1.0]:
        V = sigma * r_vals
        ax2.plot(r_vals, V, linewidth=2, label=f'σ = {sigma}')

    ax2.set_xlabel('Quark separation r')
    ax2.set_ylabel('Potential V(r)')
    ax2.set_title('Linear Confining Potential')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    # Panel 3: Mass gap → string tension connection
    ax3 = axes[2]
    gaps = np.linspace(0.05, 2.0, 50)
    string_tensions = gaps  # σ ≥ Δ in our framework
    ax3.plot(gaps, string_tensions, 'b-', linewidth=2)
    ax3.fill_between(gaps, string_tensions, 2.5, alpha=0.1, color='blue')
    ax3.set_xlabel('Mass gap Δ')
    ax3.set_ylabel('String tension σ')
    ax3.set_title('Mass Gap → String Tension')
    ax3.annotate('σ ≥ Δ\n(Confinement region)', xy=(1.0, 1.5),
                 fontsize=11, ha='center', color='blue')
    ax3.grid(True, alpha=0.3)
    ax3.set_xlim(0, 2)
    ax3.set_ylim(0, 2.5)

    plt.tight_layout()
    plt.savefig('wilson_loop_area_law.png', dpi=150, bbox_inches='tight')
    print("Saved: wilson_loop_area_law.png")


if __name__ == "__main__":
    main()
