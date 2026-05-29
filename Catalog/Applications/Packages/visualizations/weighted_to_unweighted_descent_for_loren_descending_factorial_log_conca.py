#!/usr/bin/env python3
"""
Visualization: Descending Factorial Log-Concavity

Shows that the descending factorial x^{\\underline{k}} is log-concave in k
for fixed x. Plots the sequence and the log-concavity ratio
(x^{\\underline{k}})^2 / (x^{\\underline{k-1}} * x^{\\underline{k+1}}).
"""
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np


def descending_factorial(x, k):
    """Compute x(x-1)...(x-k+1)."""
    result = 1
    for i in range(k):
        result *= (x - i)
    return result


fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle('Descending Factorial Log-Concavity: (x↓k)² ≥ (x↓(k-1))·(x↓(k+1))',
             fontsize=13, fontweight='bold')

# Plot 1: Descending factorial values
ax1 = axes[0]
for x in [5, 8, 12, 16, 20]:
    ks = list(range(x + 1))
    vals = [descending_factorial(x, k) for k in ks]
    ax1.semilogy(ks, [max(v, 0.5) for v in vals], 'o-', label=f'x={x}', markersize=4)
ax1.set_xlabel('k')
ax1.set_ylabel('x↓k (log scale)')
ax1.set_title('Descending factorial values')
ax1.legend()
ax1.grid(True, alpha=0.3)

# Plot 2: Log-concavity ratio
ax2 = axes[1]
for x in [5, 8, 12, 16, 20]:
    ks = []
    ratios = []
    for k in range(1, x):
        dk = descending_factorial(x, k)
        dkm = descending_factorial(x, k - 1)
        dkp = descending_factorial(x, k + 1)
        if dkm > 0 and dkp > 0:
            ks.append(k)
            ratios.append(dk**2 / (dkm * dkp))
    ax2.plot(ks, ratios, 'o-', label=f'x={x}', markersize=4)

ax2.axhline(y=1, color='red', linestyle='--', linewidth=2, label='Threshold = 1')
ax2.set_xlabel('k')
ax2.set_ylabel('(x↓k)² / ((x↓(k-1))·(x↓(k+1)))')
ax2.set_title('Log-concavity ratio (always ≥ 1)')
ax2.legend()
ax2.grid(True, alpha=0.3)

# Plot 3: The ratio equals (x-k+1)/(x-k) exactly
ax3 = axes[2]
for x in [5, 10, 20, 50]:
    ks = list(range(1, x))
    exact_ratios = [(x - k + 1) / (x - k) for k in ks]
    ax3.plot(ks, exact_ratios, '-', label=f'x={x}', linewidth=2)

ax3.axhline(y=1, color='red', linestyle='--', linewidth=2)
ax3.set_xlabel('k')
ax3.set_ylabel('(x-k+1)/(x-k)')
ax3.set_title('Exact ratio = (x-k+1)/(x-k)')
ax3.legend()
ax3.grid(True, alpha=0.3)
ax3.set_ylim(0.9, 3)

plt.tight_layout()
plt.savefig('viz_descfactorial.png', dpi=150, bbox_inches='tight')
print("Saved viz_descfactorial.png")
