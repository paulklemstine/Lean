#!/usr/bin/env python3
"""
Visualization 1: Phase Transition at the Semicircle Edge

Visualizes the sharp failure upper bound as a function of ε/σ for various
dimensions n, showing the phase transition at ε = 2σ. Below the edge, the
bound is 1 (no suppression). Above the edge, exponential decay kicks in.
"""

import numpy as np
import matplotlib.pyplot as plt


def sharp_failure_upper_bound(C, sigma, eps, n):
    gap = max(eps - 2 * sigma, 0)
    if C * sigma**2 == 0:
        return 1.0
    return np.exp(-gap**2 * n / (C * sigma**2))


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

sigma = 1.0
C = 1.0
eps_ratios = np.linspace(0.5, 4.0, 500)

# Left: Linear scale
ax = axes[0]
for n in [5, 20, 50, 100, 500]:
    bounds = [sharp_failure_upper_bound(C, sigma, r * sigma, n) for r in eps_ratios]
    ax.plot(eps_ratios, bounds, label=f'n = {n}', linewidth=2)

ax.axvline(x=2.0, color='red', linestyle='--', alpha=0.7, label='Edge: ε = 2σ')
ax.set_xlabel('ε / σ', fontsize=14)
ax.set_ylabel('SharpFailureUpperBound', fontsize=14)
ax.set_title('Phase Transition at the Semicircle Edge', fontsize=15)
ax.legend(fontsize=11)
ax.set_ylim(-0.05, 1.1)
ax.grid(True, alpha=0.3)

# Right: Log scale
ax = axes[1]
for n in [5, 20, 50, 100, 500]:
    bounds = [sharp_failure_upper_bound(C, sigma, r * sigma, n) for r in eps_ratios]
    ax.semilogy(eps_ratios, bounds, label=f'n = {n}', linewidth=2)

ax.axvline(x=2.0, color='red', linestyle='--', alpha=0.7, label='Edge: ε = 2σ')
ax.set_xlabel('ε / σ', fontsize=14)
ax.set_ylabel('SharpFailureUpperBound (log scale)', fontsize=14)
ax.set_title('Exponential Decay Above Edge', fontsize=15)
ax.legend(fontsize=11)
ax.set_ylim(1e-50, 10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved phase_transition.png")
