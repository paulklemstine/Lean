#!/usr/bin/env python3
"""
Visualization: Support and Shadow in 2D

Visualizes the support of a bivariate polynomial and its shadows along
various derivative directions. Shows how the shadow operation shifts and
filters the support set.

This makes the key idea tangible: differentiation is a shadow operation
on exponent lattice points.
"""

import matplotlib.pyplot as plt
import numpy as np

# Inline functions
def le_mi(a, b): return all(x <= y for x, y in zip(a, b))
def sub_mi(a, b): return tuple(x - y for x, y in zip(a, b))
def add_mi(a, b): return tuple(x + y for x, y in zip(a, b))

def shadow_along(S, gamma):
    return frozenset(sub_mi(a, gamma) for a in S if le_mi(gamma, a))

# Create a bivariate polynomial support
S = frozenset([
    (4, 0), (3, 1), (2, 2), (1, 3), (0, 4),  # degree 4
    (3, 0), (2, 1), (0, 3),                    # degree 3
    (2, 0), (1, 1),                              # degree 2
    (1, 0),                                       # degree 1
])

# Define derivative directions to show
directions = [
    ((1, 0), "∂/∂x₁", "tab:blue"),
    ((0, 1), "∂/∂x₂", "tab:red"),
    ((1, 1), "∂²/∂x₁∂x₂", "tab:green"),
    ((2, 0), "∂²/∂x₁²", "tab:purple"),
    ((2, 1), "∂³/∂x₁²∂x₂", "tab:orange"),
    ((3, 0), "∂³/∂x₁³", "tab:brown"),
]

fig, axes = plt.subplots(2, 3, figsize=(16, 10))
axes = axes.flatten()

for idx, (gamma, label, color) in enumerate(directions):
    ax = axes[idx]

    # Draw lattice grid
    for i in range(6):
        for j in range(6):
            ax.plot(i, j, '.', color='lightgray', markersize=3)

    # Draw original support
    xs = [p[0] for p in S]
    ys = [p[1] for p in S]
    ax.scatter(xs, ys, s=80, c='black', marker='s', label='Support S',
               zorder=5, alpha=0.3)

    # Draw shadow
    shadow = shadow_along(S, gamma)
    if shadow:
        sx = [p[0] for p in shadow]
        sy = [p[1] for p in shadow]
        ax.scatter(sx, sy, s=120, c=color, marker='o', label=f'Shadow',
                   zorder=6, edgecolors='black', linewidth=0.5)

    # Draw arrows from shadow to ancestor
    for beta in shadow:
        alpha = add_mi(beta, gamma)
        if alpha in S:
            ax.annotate('', xy=alpha, xytext=beta,
                       arrowprops=dict(arrowstyle='->', color=color, alpha=0.4, lw=1))

    ax.set_xlim(-0.5, 5.5)
    ax.set_ylim(-0.5, 5.5)
    ax.set_aspect('equal')
    ax.set_xlabel('x₁ exponent')
    ax.set_ylabel('x₂ exponent')
    ax.set_title(f'{label}, γ={gamma}\n|Shadow| = {len(shadow)}', fontsize=11)
    ax.legend(loc='upper right', fontsize=8)
    ax.grid(True, alpha=0.2)

plt.suptitle('Support Shadows: How Differentiation Maps Exponent Sets\n'
             '(■ = original support, ● = shadow = derivative support)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_support_shadow.png', dpi=150, bbox_inches='tight')
print("Saved viz_support_shadow.png")
