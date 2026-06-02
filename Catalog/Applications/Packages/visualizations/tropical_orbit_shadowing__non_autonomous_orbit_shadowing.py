#!/usr/bin/env python3
"""
Visualization 1: Orbit Shadowing - Pseudo-orbit vs True Orbit

Shows a contractive pseudo-orbit being shadowed by the true orbit,
with the δ/(1-L) bound envelope.
"""

import numpy as np
import matplotlib.pyplot as plt


def simulate_shadowing(L: float, delta: float, x0: float, n_steps: int, seed: int = 42):
    rng = np.random.RandomState(seed)
    pseudo = [x0]
    true_orb = [x0]
    for k in range(n_steps):
        noise = rng.uniform(-delta, delta)
        pseudo.append(L * pseudo[-1] + noise)
        true_orb.append(L * true_orb[-1])
    return np.array(pseudo), np.array(true_orb)


def main():
    L = 0.7
    delta = 0.3
    x0 = 5.0
    n_steps = 100

    pseudo, true_orb = simulate_shadowing(L, delta, x0, n_steps)
    radius = delta / (1 - L)
    steps = np.arange(n_steps + 1)

    fig, axes = plt.subplots(2, 1, figsize=(12, 8), gridspec_kw={'height_ratios': [2, 1]})

    # Top plot: orbits with shadowing envelope
    ax1 = axes[0]
    ax1.plot(steps, pseudo, 'b-', alpha=0.7, linewidth=1.5, label=f'Pseudo-orbit (δ={delta})')
    ax1.plot(steps, true_orb, 'r-', linewidth=2, label='True orbit (shadow)')
    ax1.fill_between(steps, true_orb - radius, true_orb + radius,
                      alpha=0.15, color='red', label=f'δ/(1-L) = {radius:.2f} envelope')
    ax1.set_xlabel('Step n', fontsize=12)
    ax1.set_ylabel('State x(n)', fontsize=12)
    ax1.set_title(f'Contractive Shadowing: f(x) = {L}x, δ = {delta}, radius = {radius:.2f}',
                  fontsize=14, fontweight='bold')
    ax1.legend(fontsize=11, loc='upper right')
    ax1.grid(True, alpha=0.3)

    # Bottom plot: tracking error
    ax2 = axes[1]
    errors = np.abs(pseudo - true_orb)
    ax2.plot(steps, errors, 'g-', linewidth=1.5, label='|pseudo(n) - true(n)|')
    ax2.axhline(y=radius, color='red', linestyle='--', linewidth=2,
                label=f'Bound δ/(1-L) = {radius:.2f}')
    ax2.set_xlabel('Step n', fontsize=12)
    ax2.set_ylabel('Tracking error', fontsize=12)
    ax2.set_title('Tracking Error vs Theoretical Bound', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('shadowing_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: shadowing_visualization.png")


if __name__ == "__main__":
    main()
