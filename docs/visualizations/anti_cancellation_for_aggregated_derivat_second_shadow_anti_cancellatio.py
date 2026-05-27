#!/usr/bin/env python3
"""
Visualization: Second Shadow Anti-Cancellation Heatmap
=======================================================

Visualizes the anti-cancellation principle for a 3-variable polynomial.
Shows the support of f, the second shadow, and the coefficient magnitudes
in D_A f, confirming that all shadow exponents survive with positive
coefficients.

Uses barycentric coordinates to plot degree-d monomials in 3 variables
as points in a triangle.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.collections import PatchCollection
import random


def generate_homogeneous_monomials(n, d):
    """Generate all exponent vectors of degree d in n variables."""
    if n == 0:
        return [()]
    if n == 1:
        return [(d,)]
    result = []
    for first in range(d + 1):
        for rest in generate_homogeneous_monomials(n - 1, d - first):
            result.append((first,) + rest)
    return result


def compute_second_shadow(support, n):
    """Compute second shadow of a support set."""
    shadow = set()
    for alpha in support:
        for i in range(n):
            for j in range(n):
                beta = list(alpha)
                if i == j:
                    if beta[i] >= 2:
                        beta[i] -= 2
                        shadow.add(tuple(beta))
                else:
                    if beta[i] >= 1 and beta[j] >= 1:
                        beta[i] -= 1
                        beta[j] -= 1
                        shadow.add(tuple(beta))
    return shadow


def compute_weighted_hessian_coeff(coeffs, A, beta, n):
    """Compute [beta](D_A f)."""
    total = 0.0
    for i in range(n):
        for j in range(n):
            alpha = list(beta)
            if i == j:
                mult = (beta[i] + 1) * (beta[i] + 2)
                alpha[i] += 2
            else:
                mult = (beta[i] + 1) * (beta[j] + 1)
                alpha[i] += 1
                alpha[j] += 1
            total += A[i, j] * mult * coeffs.get(tuple(alpha), 0.0)
    return total


def to_barycentric(alpha, d):
    """Convert degree-d exponent (a,b,c) to 2D coordinates in equilateral triangle."""
    a, b, c = alpha[0] / d, alpha[1] / d, alpha[2] / d
    x = 0.5 * (2 * b + c)
    y = (np.sqrt(3) / 2) * c
    return x, y


# Setup
random.seed(123)
np.random.seed(123)
n = 3
d = 5  # degree of f

# Generate M-convex support (take a nice subset of all monomials)
all_mons_d = generate_homogeneous_monomials(n, d)
# Use a connected subset: start from center and grow
support = set()
center = (d // 3, d // 3, d - 2 * (d // 3))
support.add(center)
for m in all_mons_d:
    if sum(abs(m[k] - center[k]) for k in range(n)) <= 3:
        support.add(m)
support = set(list(support)[:12])  # Keep manageable size

coeffs = {s: random.uniform(0.5, 5.0) for s in support}

# Compute shadow and coefficients
all_mons_d2 = generate_homogeneous_monomials(n, d - 2)
shadow = compute_second_shadow(support, n)
A = np.array([[2.0, 1.0, 0.5], [1.0, 3.0, 1.0], [0.5, 1.0, 2.0]])

hessian_coeffs = {}
for beta in all_mons_d2:
    c = compute_weighted_hessian_coeff(coeffs, A, beta, n)
    if abs(c) > 1e-12:
        hessian_coeffs[beta] = c

# Create figure with two panels
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# --- Panel 1: Support of f and second shadow ---
ax1.set_title(f'Support of f (degree {d}) and Second Shadow (degree {d-2})', fontsize=12, fontweight='bold')
ax1.set_aspect('equal')
ax1.set_xlim(-0.15, 1.15)
ax1.set_ylim(-0.15, 1.05)

# Draw triangle for degree d
triangle_d = plt.Polygon(
    [to_barycentric((d, 0, 0), d),
     to_barycentric((0, d, 0), d),
     to_barycentric((0, 0, d), d)],
    fill=False, edgecolor='gray', linestyle='--', alpha=0.5
)
ax1.add_patch(triangle_d)

# Draw triangle for degree d-2
triangle_d2 = plt.Polygon(
    [to_barycentric((d-2, 0, 0), d),
     to_barycentric((0, d-2, 0), d),
     to_barycentric((0, 0, d-2), d)],
    fill=False, edgecolor='blue', linestyle=':', alpha=0.5
)
ax1.add_patch(triangle_d2)

# Plot all degree-d monomials (faint)
for m in all_mons_d:
    x, y = to_barycentric(m, d)
    ax1.plot(x, y, 'o', color='lightgray', markersize=4, zorder=1)

# Plot support of f
for m in support:
    x, y = to_barycentric(m, d)
    ax1.plot(x, y, 's', color='red', markersize=10, zorder=3,
             markeredgecolor='darkred', markeredgewidth=1)

# Plot all degree-(d-2) monomials (faint)
for m in all_mons_d2:
    x, y = to_barycentric(m, d)
    ax1.plot(x, y, 'o', color='lightyellow', markersize=3, zorder=1)

# Plot second shadow
for m in shadow:
    x, y = to_barycentric(m, d)
    ax1.plot(x, y, 'D', color='blue', markersize=8, zorder=2,
             markeredgecolor='darkblue', markeredgewidth=1)

# Draw arrows from support to shadow
for alpha in list(support)[:6]:  # limit arrows for clarity
    for i in range(n):
        for j in range(i, n):
            beta = list(alpha)
            if i == j:
                if beta[i] >= 2:
                    beta[i] -= 2
                    x1, y1 = to_barycentric(alpha, d)
                    x2, y2 = to_barycentric(tuple(beta), d)
                    ax1.annotate('', xy=(x2, y2), xytext=(x1, y1),
                                arrowprops=dict(arrowstyle='->', color='green', alpha=0.15, lw=0.5))
            else:
                if beta[i] >= 1 and beta[j] >= 1:
                    beta[i] -= 1
                    beta[j] -= 1
                    x1, y1 = to_barycentric(alpha, d)
                    x2, y2 = to_barycentric(tuple(beta), d)
                    ax1.annotate('', xy=(x2, y2), xytext=(x1, y1),
                                arrowprops=dict(arrowstyle='->', color='purple', alpha=0.15, lw=0.5))

legend1 = [
    mpatches.Patch(color='red', label=f'Support of f ({len(support)} pts)'),
    mpatches.Patch(color='blue', label=f'Second shadow ({len(shadow)} pts)'),
]
ax1.legend(handles=legend1, loc='upper right', fontsize=9)
ax1.axis('off')

# --- Panel 2: Hessian coefficient magnitudes ---
ax2.set_title(f'Coefficients of D_A f (all shadow exponents survive)', fontsize=12, fontweight='bold')
ax2.set_aspect('equal')
ax2.set_xlim(-0.15, 1.15)
ax2.set_ylim(-0.15, 1.05)

# Background triangle
triangle_bg = plt.Polygon(
    [to_barycentric((d-2, 0, 0), d),
     to_barycentric((0, d-2, 0), d),
     to_barycentric((0, 0, d-2), d)],
    fill=False, edgecolor='gray', linestyle='--', alpha=0.5
)
ax2.add_patch(triangle_bg)

# Plot all degree-(d-2) monomials
for m in all_mons_d2:
    x, y = to_barycentric(m, d)
    if m in shadow:
        c = hessian_coeffs.get(m, 0)
        # Color by log magnitude
        if c > 0:
            intensity = min(1.0, np.log1p(c) / np.log1p(max(hessian_coeffs.values())))
            color = plt.cm.YlOrRd(0.3 + 0.7 * intensity)
            ax2.plot(x, y, 'o', color=color, markersize=12, zorder=3,
                     markeredgecolor='darkred', markeredgewidth=1)
            ax2.text(x, y - 0.04, f'{c:.1f}', ha='center', va='top', fontsize=6, zorder=4)
        else:
            ax2.plot(x, y, 'x', color='red', markersize=12, zorder=3, markeredgewidth=2)
    else:
        ax2.plot(x, y, 'o', color='lightgray', markersize=5, zorder=1)

legend2 = [
    mpatches.Patch(color='orange', label='Shadow exponent (positive coeff)'),
    mpatches.Patch(color='lightgray', label='Non-shadow exponent'),
]
ax2.legend(handles=legend2, loc='upper right', fontsize=9)
ax2.axis('off')

plt.suptitle('Anti-Cancellation: Second Shadow Support Propagation', fontsize=14, fontweight='bold', y=0.98)
plt.tight_layout()
plt.savefig('anti_cancellation_shadows.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: anti_cancellation_shadows.png")
