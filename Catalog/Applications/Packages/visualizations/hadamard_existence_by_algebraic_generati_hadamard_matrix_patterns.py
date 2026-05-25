#!/usr/bin/env python3
"""
Visualization 1: Hadamard Matrix Structure

Visualizes the ±1 pattern of Sylvester-Hadamard matrices at different orders,
showing how the recursive doubling construction creates fractal-like patterns.
The self-similar structure is the visual fingerprint of the Walsh system.
"""
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

def hadamard(k):
    H = np.array([[1]])
    for _ in range(k):
        H = np.block([[H, H], [H, -H]])
    return H

fig, axes = plt.subplots(1, 4, figsize=(16, 4))
cmap = mcolors.ListedColormap(['#2c3e50', '#ecf0f1'])  # dark=-1, light=+1

for idx, k in enumerate([1, 2, 3, 4]):
    ax = axes[idx]
    H = hadamard(k)
    n = H.shape[0]
    # Map -1 → 0, +1 → 1 for colormap
    display = ((H + 1) // 2).astype(int)
    ax.imshow(display, cmap=cmap, interpolation='nearest', aspect='equal')
    ax.set_title(f'Order {n} (k={k})', fontsize=14, fontweight='bold')
    ax.set_xticks([])
    ax.set_yticks([])
    # Add grid
    for i in range(n + 1):
        ax.axhline(i - 0.5, color='gray', linewidth=0.3)
        ax.axvline(i - 0.5, color='gray', linewidth=0.3)

fig.suptitle('Sylvester-Hadamard Matrices: Self-Similar ±1 Patterns',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('hadamard_patterns.png', dpi=150, bbox_inches='tight')
print("Saved hadamard_patterns.png")
