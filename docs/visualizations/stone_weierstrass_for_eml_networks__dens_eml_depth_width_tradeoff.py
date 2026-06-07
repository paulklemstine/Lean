#!/usr/bin/env python3
"""
Visualization: EML Depth-Width Tradeoff

Shows the relationship between EML chain depth and
the functions that can be exactly represented.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

x = np.linspace(0.1, 3, 500)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle("EML Depth Hierarchy: Exact Representations", fontsize=15, fontweight='bold')

# Depth 0: identity
ax = axes[0]
ax.set_title("Depth 0: Affine", fontsize=12)
for a, b in [(1, 0), (2, -1), (0.5, 1)]:
    ax.plot(x, a * x + b, label=f'{a}x + {b}')
ax.legend()
ax.grid(True, alpha=0.3)
ax.set_xlabel('x')

# Depth 1: exp(ax + b)
ax = axes[1]
ax.set_title("Depth 1: exp(ax + b)", fontsize=12)
for a, b in [(1, 0), (0.5, -1), (-1, 2)]:
    ax.plot(x, np.exp(a * x + b), label=f'exp({a}x + {b})')
ax.legend()
ax.grid(True, alpha=0.3)
ax.set_xlabel('x')

# Depth 2: x^n = exp(n log x)
ax = axes[2]
ax.set_title("Depth 2: $x^n$ = exp(n·log x)", fontsize=12)
for n in [2, 3, 5]:
    direct = x ** n
    eml = np.exp(n * np.log(x))
    ax.plot(x, direct, '-', linewidth=2, label=f'$x^{n}$ (direct)')
    ax.plot(x, eml, '--', linewidth=1, label=f'exp({n}·log x)')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)
ax.set_xlabel('x')
ax.set_ylim(0, 30)

plt.tight_layout()
plt.savefig('viz_depth_tradeoff.png', dpi=150, bbox_inches='tight')
print("Saved viz_depth_tradeoff.png")
