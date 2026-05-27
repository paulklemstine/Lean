#!/usr/bin/env python3
"""
Visualization: Spectral Chain δ → h → λ₂ → t_mix

Visualizes the core mathematical result: how certificate depth controls
the entire chain from conductance to spectral gap to mixing time.
Three panels show:
1. Depth decrement δ_k vs k for various dimensions
2. Spectral lower bound δ²/(2D²) vs k (log scale)
3. Mixing time bound vs k (log scale)

CRITICAL: This script is fully self-contained. No local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib


def catalog_depth_decrement(d, k, c=1.0):
    """c / d^(d-k)"""
    if d == 0:
        return c
    return c / d**(d - k)


def spectral_lower_bound(delta, D):
    """delta^2 / (2*D^2)"""
    if D <= 0:
        return 0
    return delta**2 / (2 * D**2)


def mixing_time_bound(slb, n):
    """(1/slb) * ln(n)"""
    if slb <= 0:
        return float('inf')
    return (1/slb) * np.log(n)


fig, axes = plt.subplots(1, 3, figsize=(16, 5))
dims = [3, 4, 5, 6]
colors = ['#2196F3', '#FF5722', '#4CAF50', '#9C27B0']
n_states = 100  # For mixing time

# Panel 1: Depth decrement
ax = axes[0]
for d, col in zip(dims, colors):
    ks = list(range(d + 1))
    deltas = [catalog_depth_decrement(d, k) for k in ks]
    ax.plot(ks, deltas, 'o-', color=col, label=f'd={d}', linewidth=2, markersize=6)
ax.set_xlabel('Certificate depth k', fontsize=12)
ax.set_ylabel('Depth decrement δ_k', fontsize=12)
ax.set_title('Depth Decrement vs Certificate Depth', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Panel 2: Spectral lower bound
ax = axes[1]
for d, col in zip(dims, colors):
    ks = list(range(d + 1))
    slbs = [spectral_lower_bound(catalog_depth_decrement(d, k), d) for k in ks]
    ax.plot(ks, slbs, 's-', color=col, label=f'd={d}', linewidth=2, markersize=6)
ax.set_xlabel('Certificate depth k', fontsize=12)
ax.set_ylabel('Spectral lower bound δ²/(2D²)', fontsize=12)
ax.set_title('Spectral Gap Bound vs Depth', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Panel 3: Mixing time
ax = axes[2]
for d, col in zip(dims, colors):
    ks = list(range(d + 1))
    mixes = [mixing_time_bound(
        spectral_lower_bound(catalog_depth_decrement(d, k), d), n_states
    ) for k in ks]
    ax.plot(ks, mixes, '^-', color=col, label=f'd={d}', linewidth=2, markersize=6)
ax.set_xlabel('Certificate depth k', fontsize=12)
ax.set_ylabel('Mixing time bound (1/λ₂)·ln(n)', fontsize=12)
ax.set_title('Mixing Time vs Depth (n=100)', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

plt.suptitle('The Depth-Spectral Chain: Certificate Depth Controls Mixing',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('spectral_chain.png', dpi=150, bbox_inches='tight')
print("Saved spectral_chain.png")
