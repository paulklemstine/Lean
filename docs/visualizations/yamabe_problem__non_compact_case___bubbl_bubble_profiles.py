#!/usr/bin/env python3
"""Visualization: Yamabe Bubble Profiles across dimensions and scales."""

import matplotlib.pyplot as plt
import numpy as np


def yamabe_bubble(n, lam, r):
    """Yamabe bubble U_λ(r) = (λ/(λ²+r²))^((n-2)/2)."""
    return (lam / (lam**2 + r**2)) ** ((n - 2) / 2.0)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    r = np.linspace(0, 10, 500)

    # Panel 1: Different dimensions
    ax = axes[0]
    for n in [3, 4, 5, 6, 10]:
        u = yamabe_bubble(n, 1.0, r)
        ax.plot(r, u, label=f'n={n}', linewidth=2)
    ax.set_xlabel('r', fontsize=12)
    ax.set_ylabel('U₁(r)', fontsize=12)
    ax.set_title('Bubble profiles by dimension', fontsize=13)
    ax.legend()
    ax.set_ylim(0, 1.1)
    ax.grid(True, alpha=0.3)

    # Panel 2: Different scales
    ax = axes[1]
    for lam in [0.25, 0.5, 1.0, 2.0, 4.0]:
        u = yamabe_bubble(3, lam, r)
        ax.plot(r, u, label=f'λ={lam}', linewidth=2)
    ax.set_xlabel('r', fontsize=12)
    ax.set_ylabel('U_λ(r)', fontsize=12)
    ax.set_title('Bubble profiles by scale (n=3)', fontsize=13)
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 3: Log-log decay
    ax = axes[2]
    r_log = np.logspace(-1, 2, 500)
    for n in [3, 4, 5]:
        u = yamabe_bubble(n, 1.0, r_log)
        ax.loglog(r_log, u, label=f'n={n}, decay ~ r^{{-{n-2}}}', linewidth=2)
        # Asymptotic line
        ax.loglog(r_log, r_log**(-(n-2)), '--', alpha=0.4, linewidth=1)
    ax.set_xlabel('r', fontsize=12)
    ax.set_ylabel('U₁(r)', fontsize=12)
    ax.set_title('Decay rates (log-log)', fontsize=13)
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.suptitle('Yamabe Bubble: The Fundamental Solution', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('viz_bubble_profiles.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_bubble_profiles.png")


if __name__ == "__main__":
    main()
