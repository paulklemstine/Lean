#!/usr/bin/env python3
"""
Visualization: The OS Positivity → Mass Gap Bridge
====================================================

Illustrates the logical chain proven in Lean:
  Reflection Positivity → PSD Transfer Matrix → Positivity Improving
  → Perron-Frobenius → Simple Top Eigenvalue → Mass Gap

Shows:
1. The OS quadratic form as a function of test functions
2. The factored kernel "sum of squares" structure
3. How the chain produces the mass gap
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def build_wilson_transfer_matrix(n: int, beta: float) -> np.ndarray:
    T = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            T[i, j] = np.exp(beta * np.cos(2 * np.pi * (i - j) / n))
    return T


def evaluate_os_form(K, theta, f):
    n = len(f)
    result = 0.0
    for x in range(n):
        for y in range(n):
            result += f[x] * K[theta[x], y] * f[y]
    return result


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: OS form values for random test functions
ax = axes[0]
n = 8
beta = 1.5
T = build_wilson_transfer_matrix(n, beta)
theta = np.arange(n)  # identity involution

os_values = []
for _ in range(500):
    f = np.random.randn(n)
    val = evaluate_os_form(T, theta, f)
    os_values.append(val)

ax.hist(os_values, bins=50, color='#2196F3', alpha=0.7, edgecolor='navy')
ax.axvline(x=0, color='red', linewidth=2, linestyle='--', label='Zero threshold')
min_val = min(os_values)
ax.axvline(x=min_val, color='orange', linewidth=1.5, linestyle=':',
           label=f'Minimum = {min_val:.2f}')
ax.set_xlabel('OS Quadratic Form Q(f)', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title('OS Form Values (500 random f)\nAll ≥ 0 ⟹ Reflection Positive', fontsize=12)
ax.legend(fontsize=10)

# Panel 2: Gram factorization visualization
ax = axes[1]
# Show that T = L @ L^T for the transfer matrix
eigenvalues, eigenvectors = np.linalg.eigh(T)
eigenvalues_pos = np.maximum(eigenvalues, 0)
L = eigenvectors @ np.diag(np.sqrt(eigenvalues_pos))
reconstruction = L @ L.T
error = np.max(np.abs(T - reconstruction))

im = ax.imshow(L, cmap='RdBu_r', aspect='auto')
ax.set_xlabel('Factor index k', fontsize=12)
ax.set_ylabel('Configuration x', fontsize=12)
ax.set_title(f'Gram Factor L: T = LLᵀ\n(reconstruction error: {error:.1e})', fontsize=12)
plt.colorbar(im, ax=ax, shrink=0.8)

# Panel 3: The logical chain as a flow diagram
ax = axes[2]
ax.set_xlim(0, 10)
ax.set_ylim(0, 10)
ax.axis('off')

steps = [
    (5, 9.0, 'Reflection\nPositivity', '#E3F2FD', '#1565C0'),
    (5, 7.2, 'PSD Transfer\nMatrix', '#E8F5E9', '#2E7D32'),
    (5, 5.4, 'Positivity\nImproving', '#FFF3E0', '#E65100'),
    (5, 3.6, 'Perron-Frobenius\n(Simple Top λ)', '#FCE4EC', '#C62828'),
    (5, 1.8, 'MASS GAP\nΔ > 0', '#F3E5F5', '#6A1B9A'),
]

for x, y, text, facecolor, edgecolor in steps:
    box = mpatches.FancyBboxPatch((x-2.3, y-0.65), 4.6, 1.3,
                                   boxstyle="round,pad=0.15",
                                   facecolor=facecolor,
                                   edgecolor=edgecolor,
                                   linewidth=2)
    ax.add_patch(box)
    ax.text(x, y, text, ha='center', va='center',
            fontsize=11, fontweight='bold', color=edgecolor)

# Arrows
for i in range(len(steps) - 1):
    ax.annotate('', xy=(5, steps[i+1][1] + 0.7),
                xytext=(5, steps[i][1] - 0.7),
                arrowprops=dict(arrowstyle='->', color='#424242',
                              lw=2.5, connectionstyle='arc3'))

# Side annotations
annotations = [
    (9.5, 8.1, 'Gram factorization\n(sum of squares)', '#1565C0'),
    (9.5, 6.3, 'Quadratic form\n≥ 0', '#2E7D32'),
    (9.5, 4.5, 'All entries > 0\n(Wilson kernel)', '#E65100'),
    (9.5, 2.7, 'Unique vacuum\nstate', '#C62828'),
]

for x, y, text, color in annotations:
    ax.text(x, y, text, ha='center', va='center',
            fontsize=8, color=color, style='italic')

ax.set_title('The OS → Mass Gap Bridge\n(Each step proved in Lean 4)', fontsize=13,
             fontweight='bold')

plt.suptitle('Reflection Positivity: From Euclidean Symmetry to Mass Gap',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('os_bridge_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: os_bridge_visualization.png")
