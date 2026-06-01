#!/usr/bin/env python3
"""Visualization: Energy quantization and bubble decomposition."""

import matplotlib.pyplot as plt
import numpy as np


def yamabe_bubble(n, lam, r):
    """Yamabe bubble U_λ(r) = (λ/(λ²+r²))^((n-2)/2)."""
    return (lam / (lam**2 + r**2)) ** ((n - 2) / 2.0)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Panel 1: Multi-bubble configurations
    ax = axes[0]
    r = np.linspace(-15, 15, 1000)
    n = 3

    # 1 bubble
    u1 = yamabe_bubble(n, 1.0, r)
    ax.plot(r, u1, label='1 bubble', linewidth=2)

    # 2 bubbles (separated)
    u2 = yamabe_bubble(n, 1.0, r - 4) + yamabe_bubble(n, 1.0, r + 4)
    ax.plot(r, u2, label='2 bubbles', linewidth=2)

    # 3 bubbles
    u3 = (yamabe_bubble(n, 1.0, r - 6) + yamabe_bubble(n, 1.0, r) +
          yamabe_bubble(n, 1.0, r + 6))
    ax.plot(r, u3, label='3 bubbles', linewidth=2)

    ax.set_xlabel('r', fontsize=12)
    ax.set_ylabel('u(r)', fontsize=12)
    ax.set_title('Multi-bubble configurations', fontsize=13)
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 2: Energy thresholds
    ax = axes[1]
    Y_sphere = 1.0  # Normalized
    k_values = np.arange(0, 6)
    thresholds = k_values * Y_sphere

    ax.bar(k_values, thresholds, color='steelblue', alpha=0.7, edgecolor='navy')
    ax.axhline(y=2*Y_sphere, color='red', linestyle='--',
               label='2·Y(Sⁿ) threshold', linewidth=2)
    ax.axhline(y=3*Y_sphere, color='orange', linestyle='--',
               label='3·Y(Sⁿ) threshold', linewidth=2)

    # Annotate single-bubble criterion region
    ax.axhspan(0, 2*Y_sphere, alpha=0.1, color='green')
    ax.text(0.5, 1.5*Y_sphere, '≤1 bubble', ha='center', fontsize=10,
            color='green', fontweight='bold')

    ax.set_xlabel('Number of bubbles k', fontsize=12)
    ax.set_ylabel('Minimum energy k·Y(Sⁿ)', fontsize=12)
    ax.set_title('Energy quantization', fontsize=13)
    ax.legend()
    ax.grid(True, alpha=0.3, axis='y')

    # Panel 3: Concentration sequence
    ax = axes[2]
    r = np.linspace(-5, 5, 500)
    n = 3

    for eps, alpha in [(2.0, 0.2), (1.0, 0.4), (0.5, 0.6), (0.2, 0.8), (0.1, 1.0)]:
        u = yamabe_bubble(n, eps, r) / yamabe_bubble(n, eps, 0)
        ax.plot(r, u, alpha=alpha, linewidth=2, label=f'ε={eps}')

    ax.set_xlabel('r', fontsize=12)
    ax.set_ylabel('U_ε(r) / U_ε(0)', fontsize=12)
    ax.set_title('Concentration: ε → 0', fontsize=13)
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.suptitle('Energy Quantization in Bubble Decomposition', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('viz_energy_quantization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_energy_quantization.png")


if __name__ == "__main__":
    main()
