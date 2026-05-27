#!/usr/bin/env python3
"""
Visualization: Maslov Dequantization — Tropical Gap Under Rescaling

This script visualizes the linear growth of exchange slack under Maslov-type
weight rescaling, demonstrating the relationship between tropical geometry
and Lorentzian stability in the asymptotic (t → ∞) regime.
"""

import numpy as np
import matplotlib.pyplot as plt

np.random.seed(77)
n = 4

# Base weight
w = np.random.randn(n, n)
w = (w + w.T) / 2

# Rescaling direction
omega = np.random.randn(n, n)
omega = (omega + omega.T) / 2


def diag_exchange_slack(w, i, j):
    return 2 * w[i, j] - w[i, i] - w[j, j]


def tropical_gap_value(w):
    n = w.shape[0]
    return min(diag_exchange_slack(w, i, j)
               for i in range(n) for j in range(n) if i != j)


def all_exchange_slacks(w):
    n = w.shape[0]
    slacks = {}
    for i in range(n):
        for j in range(n):
            if i != j:
                slacks[(i, j)] = diag_exchange_slack(w, i, j)
    return slacks


# Compute exchange slacks as function of t
t_values = np.linspace(-3, 10, 500)

# Track individual slacks and the global gap
slack_traces = {(i, j): [] for i in range(n) for j in range(n) if i != j}
gap_values = []

for t in t_values:
    w_t = w + t * omega
    slacks = all_exchange_slacks(w_t)
    for key, val in slacks.items():
        slack_traces[key].append(val)
    gap_values.append(tropical_gap_value(w_t))

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Plot 1: Individual exchange slacks (all linear in t)
ax1 = axes[0]
colors = plt.cm.tab20(np.linspace(0, 1, len(slack_traces)))
for idx, ((i, j), trace) in enumerate(slack_traces.items()):
    ax1.plot(t_values, trace, color=colors[idx], alpha=0.7,
             label=f'δ({i},{j})' if idx < 6 else None)
ax1.set_xlabel('Rescaling parameter t', fontsize=12)
ax1.set_ylabel('Exchange slack', fontsize=12)
ax1.set_title('Individual Exchange Slacks (All Linear)', fontsize=13)
ax1.legend(fontsize=8, ncol=2)
ax1.grid(True, alpha=0.3)
ax1.axhline(y=0, color='k', linewidth=0.5, linestyle='-')

# Plot 2: Global gap (piecewise linear = minimum of linear functions)
ax2 = axes[1]
ax2.plot(t_values, gap_values, 'b-', linewidth=2.5, label='Tropical gap')
# Also plot the linear functions it's the minimum of
for idx, ((i, j), trace) in enumerate(slack_traces.items()):
    ax2.plot(t_values, trace, '--', color=colors[idx], alpha=0.3, linewidth=0.8)
ax2.plot(t_values, gap_values, 'b-', linewidth=2.5)  # redraw on top
ax2.set_xlabel('Rescaling parameter t', fontsize=12)
ax2.set_ylabel('Tropical spectral gap', fontsize=12)
ax2.set_title('Global Gap = min of Linear Functions', fontsize=13)
ax2.axhline(y=0, color='r', linewidth=1, linestyle='--', alpha=0.5)
ax2.grid(True, alpha=0.3)

# Plot 3: Gap slope analysis
ax3 = axes[2]
# Compute slopes of individual slacks
omega_slacks = {}
for i in range(n):
    for j in range(n):
        if i != j:
            omega_slacks[(i, j)] = 2 * omega[i, j] - omega[i, i] - omega[j, j]

slopes = sorted(omega_slacks.values())
bars = ax3.barh(range(len(slopes)), slopes,
                color=['green' if s >= 0 else 'red' for s in slopes],
                alpha=0.7)
ax3.set_xlabel('Slope = δ(ω, i, j)', fontsize=12)
ax3.set_ylabel('Pair index (sorted)', fontsize=12)
ax3.set_title('Slopes of Exchange Slack Lines', fontsize=13)
ax3.axvline(x=0, color='k', linewidth=0.5)
ax3.axvline(x=min(slopes), color='blue', linewidth=2, linestyle='--',
            label=f'Min slope = {min(slopes):.3f}')
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3, axis='x')

plt.suptitle('Maslov Dequantization: Tropical Gap Under Weight Rescaling',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('maslov_rescaling.png', dpi=150, bbox_inches='tight')
print("Saved: maslov_rescaling.png")
