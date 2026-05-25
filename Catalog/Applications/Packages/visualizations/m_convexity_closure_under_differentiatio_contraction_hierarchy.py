#!/usr/bin/env python3
"""
Visualization: Support Contraction Hierarchy

Shows how the support of a degree-4 homogeneous polynomial in 3 variables
changes under successive partial differentiations. Each subplot shows the
lattice points of the support at one stage, projected onto the standard
2-simplex. Colors indicate the contraction step.

This illustrates the main theorem: M-convexity (exchange property)
is preserved at every step.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations


def unit_vec(n, i):
    return tuple(1 if j == i else 0 for j in range(n))

def vec_sub(a, b):
    return tuple(max(x - y, 0) for x, y in zip(a, b))

def support_contraction(S, n, i):
    ei = unit_vec(n, i)
    return {vec_sub(m, ei) for m in S if m[i] > 0}

def homogeneous_support(n, d):
    result = set()
    def gen(rem, deg, cur):
        if rem == 1:
            result.add(tuple(cur + [deg]))
            return
        for k in range(deg + 1):
            gen(rem - 1, deg - k, cur + [k])
    gen(n, d, [])
    return result

def satisfies_exchange(S, n):
    for a in S:
        for b in S:
            for i in range(n):
                if a[i] > b[i]:
                    ok = False
                    for j in range(n):
                        if b[j] > a[j]:
                            s1 = tuple(a[k]-(1 if k==i else 0)+(1 if k==j else 0) for k in range(n))
                            s2 = tuple(b[k]+(1 if k==i else 0)-(1 if k==j else 0) for k in range(n))
                            if s1 in S and s2 in S:
                                ok = True; break
                    if not ok: return False
    return True

def to_2d(v):
    """Project 3D simplex point to 2D for plotting."""
    x = v[1] + 0.5 * v[2]
    y = v[2] * np.sqrt(3) / 2
    return x, y


# Build the contraction sequence
n = 3
d = 4
stages = []
S = homogeneous_support(n, d)
labels = [f"Original (degree {d})"]
derivatives = [""]
stages.append(S)

deriv_seq = [0, 1, 2, 0]
for idx, var in enumerate(deriv_seq):
    S = support_contraction(S, n, var)
    stages.append(S)
    deriv_label = f"∂/∂x_{var}"
    labels.append(f"After {deriv_label}")
    derivatives.append(deriv_label)

fig, axes = plt.subplots(1, 5, figsize=(20, 4))
colors = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63', '#9C27B0']

for idx, (ax, S, label, color) in enumerate(zip(axes, stages, labels, colors)):
    ax.set_aspect('equal')
    ax.set_title(label, fontsize=11, fontweight='bold')
    
    # Draw simplex outline
    d_cur = d - idx  # current degree
    corners = [(0, 0, d_cur), (d_cur, 0, 0), (0, d_cur, 0)]
    corner_2d = [to_2d(c) for c in corners]
    triangle = plt.Polygon(corner_2d, fill=False, edgecolor='gray',
                          linewidth=1, linestyle='--')
    ax.add_patch(triangle)
    
    # Plot support points
    if S:
        points = [to_2d(v) for v in S]
        xs, ys = zip(*points)
        ax.scatter(xs, ys, c=color, s=80, zorder=5, edgecolors='black',
                  linewidth=0.5, alpha=0.85)
    
    exch = satisfies_exchange(S, n) if S else True
    ax.text(0.5, -0.15, f"|S|={len(S)}, M-convex: {'✓' if exch else '✗'}",
            transform=ax.transAxes, ha='center', fontsize=9,
            color='green' if exch else 'red')
    
    if idx > 0:
        ax.text(0.5, 1.12, derivatives[idx], transform=ax.transAxes,
               ha='center', fontsize=10, color='gray')
    
    ax.set_xlim(-0.5, d_cur + 0.5)
    ax.set_ylim(-0.5, d_cur * np.sqrt(3)/2 + 0.5)
    ax.axis('off')

plt.suptitle('Support Contraction Hierarchy: Differentiation Preserves M-Convexity',
            fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('contraction_hierarchy.png', dpi=150, bbox_inches='tight')
print("Saved: contraction_hierarchy.png")
