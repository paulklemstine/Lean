#!/usr/bin/env python3
"""
Visualization 1: Pressure and Rate Function Curves

Visualizes the asymptotic pressure Λ(t) and its Legendre transform,
the rate function I(α), for several finite groups. Shows the duality
between the thermodynamic pressure (free energy) and the large deviation
rate function that governs exponential decay of rare events.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from math import log, exp, gcd


def nongen_prob_cyclic(n):
    """Compute nongeneration probability for Z/nZ."""
    count = sum(1 for g in range(n) for h in range(n) if gcd(g, gcd(h, n)) != 1)
    return count / (n * n)

def pressure(q, t):
    """Λ(t) = log[(1-q) + q·exp(t)]"""
    return log((1 - q) + q * exp(t))

def rate_exact(q, alpha):
    """I(α) = α·log(α/q) + (1-α)·log((1-α)/(1-q))"""
    if alpha <= 1e-12:
        return -log(1 - q)
    if alpha >= 1 - 1e-12:
        return -log(q)
    return alpha * log(alpha / q) + (1 - alpha) * log((1 - alpha) / (1 - q))


fig, axes = plt.subplots(1, 2, figsize=(14, 5.5))

groups = [
    ("Z/2Z", nongen_prob_cyclic(2), '#2196F3'),
    ("Z/6Z", nongen_prob_cyclic(6), '#FF5722'),
    ("Z/5Z (prime)", nongen_prob_cyclic(5), '#4CAF50'),
]

# --- Left panel: Pressure curves ---
ax = axes[0]
ts = np.linspace(-3, 8, 500)

for name, q, color in groups:
    Ls = [pressure(q, t) for t in ts]
    ax.plot(ts, Ls, color=color, linewidth=2.2, label=f'{name} (q={q:.3f})')

ax.set_xlabel('Inverse temperature t', fontsize=13)
ax.set_ylabel('Λ(t) = log E[exp(t·δ)]', fontsize=13)
ax.set_title('Asymptotic Pressure (Cumulant Generating Function)', fontsize=14, fontweight='bold')
ax.legend(fontsize=11, loc='upper left')
ax.grid(True, alpha=0.3)
ax.axhline(y=0, color='gray', linewidth=0.5)
ax.axvline(x=0, color='gray', linewidth=0.5)

# --- Right panel: Rate functions ---
ax = axes[1]
alphas = np.linspace(0.001, 0.999, 500)

for name, q, color in groups:
    Is = [rate_exact(q, a) for a in alphas]
    ax.plot(alphas, Is, color=color, linewidth=2.2, label=f'{name} (q={q:.3f})')
    # Mark the minimum at α = q
    ax.plot(q, 0, 'o', color=color, markersize=8, zorder=5)

ax.set_xlabel('Deviation level α', fontsize=13)
ax.set_ylabel('I(α) = sup_t {tα - Λ(t)}', fontsize=13)
ax.set_title('Rate Function (Legendre Transform)', fontsize=14, fontweight='bold')
ax.legend(fontsize=11, loc='upper center')
ax.grid(True, alpha=0.3)
ax.set_ylim(-0.05, 3.5)
ax.axhline(y=0, color='gray', linewidth=0.5)

# Add annotation
ax.annotate('I(q) = 0\n(typical behavior)', 
            xy=(groups[1][1], 0), xytext=(0.55, 0.8),
            fontsize=10, ha='center',
            arrowprops=dict(arrowstyle='->', color='gray'),
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_pressure_rate.png', dpi=150, bbox_inches='tight')
print("Saved viz_pressure_rate.png")
