#!/usr/bin/env python3
"""Visualization of stability regions for the logistic scoring model."""

import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Derivative at non-trivial fixed point as function of mu
    mu = np.linspace(0.1, 4.0, 1000)
    deriv = 2 - mu  # f'(x*) = 2 - mu

    ax1.plot(mu, deriv, 'b-', linewidth=2, label="|f'(x*)| = |2 - μ|")
    ax1.axhline(y=1, color='red', linestyle='--', alpha=0.7, label='Stability boundary')
    ax1.axhline(y=-1, color='red', linestyle='--', alpha=0.7)
    ax1.axhline(y=0, color='black', linestyle='-', alpha=0.3)
    ax1.axvline(x=1, color='blue', linestyle=':', alpha=0.5, label='μ=1 (bifurcation)')
    ax1.axvline(x=3, color='green', linestyle=':', alpha=0.5, label='μ=3 (instability)')

    # Shade stability region
    mu_stable = np.linspace(1, 3, 100)
    ax1.fill_between(mu_stable, -1, 1, alpha=0.1, color='green', label='Stable region')

    ax1.set_xlabel('Parameter μ', fontsize=12)
    ax1.set_ylabel("f'(x*) = 2 - μ", fontsize=12)
    ax1.set_title('Derivative at Non-trivial Fixed Point', fontsize=13)
    ax1.legend(fontsize=9, loc='lower left')
    ax1.set_xlim(0, 4)
    ax1.set_ylim(-2.5, 2.5)
    ax1.grid(True, alpha=0.3)

    # Right: Phase diagram
    regions = [
        (0, 1, 'lightblue', 'Score decay\n(x* < 0)'),
        (1, 3, 'lightgreen', 'Stable equilibrium\n(|f\'| < 1)'),
        (3, 3.57, 'lightyellow', 'Period doubling\ncascade'),
        (3.57, 4, 'lightsalmon', 'Chaos\n(dense orbits)'),
    ]

    for start, end, color, label in regions:
        ax2.axvspan(start, end, alpha=0.5, color=color, label=label)
        ax2.text((start + end) / 2, 0.5, label, ha='center', va='center',
                fontsize=9, fontweight='bold')

    ax2.axvline(x=1, color='blue', linewidth=2, label='Transcritical bifurcation')
    ax2.axvline(x=3, color='red', linewidth=2, label='Period-2 onset')
    ax2.axvline(x=3.57, color='darkred', linewidth=2, label='Chaos onset')

    ax2.set_xlabel('Feedback parameter μ', fontsize=12)
    ax2.set_title('Phase Diagram of Logistic Scoring', fontsize=13)
    ax2.set_xlim(0, 4)
    ax2.set_ylim(0, 1)
    ax2.set_yticks([])

    plt.tight_layout()
    plt.savefig('stability_regions.png', dpi=150)
    print("Saved stability_regions.png")


if __name__ == "__main__":
    main()
