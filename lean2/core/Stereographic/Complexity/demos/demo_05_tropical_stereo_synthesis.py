#!/usr/bin/env python3
"""
Demo 5: Tropical-Stereographic Synthesis
The Grand Experiment: composing stereographic projection with tropical deformation
to explore complexity class transmutation.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import matplotlib.gridspec as gridspec

fig = plt.figure(figsize=(22, 14))
gs = gridspec.GridSpec(2, 3, figure=fig, hspace=0.3, wspace=0.3)

# ──── Panel 1: The Pipeline ────
ax1 = fig.add_subplot(gs[0, :])
ax1.set_title('The Complexity Transmutation Pipeline', fontsize=16, fontweight='bold', color='white')
ax1.set_xlim(0, 20)
ax1.set_ylim(0, 4)

stages = [
    (2, 2, 'NP-hard\nProblem\nin ℝⁿ', '#e74c3c'),
    (6, 2, 'Problem\non Sⁿ\n(compactified)', '#3498db'),
    (10, 2, 'Tropical\nDeformation\n(h → 0)', '#9b59b6'),
    (14, 2, 'Piecewise\nLinear\nAlgebra', '#f39c12'),
    (18, 2, 'Solution\n(if exists)', '#2ecc71'),
]

for x, y, label, color in stages:
    circle = plt.Circle((x, y), 1.2, facecolor='#1a1a2e', edgecolor=color, linewidth=3)
    ax1.add_patch(circle)
    ax1.text(x, y, label, ha='center', va='center', fontsize=10, color=color, fontweight='bold')

# Arrows between stages
arrows = [
    (3.3, 2, 4.7, 2, 'σ⁻¹\n(stereo)', '#3498db'),
    (7.3, 2, 8.7, 2, 'Maslov\n(h→0)', '#9b59b6'),
    (11.3, 2, 12.7, 2, 'Tropical\nsolve', '#f39c12'),
    (15.3, 2, 16.7, 2, 'σ ∘ inv\n(decode)', '#2ecc71'),
]
for x1, y1, x2, y2, label, color in arrows:
    ax1.annotate('', xy=(x2, y2), xytext=(x1, y1),
                arrowprops=dict(arrowstyle='->', color=color, lw=2.5))
    ax1.text((x1+x2)/2, y1+1.0, label, ha='center', fontsize=9, color=color, fontstyle='italic')

ax1.set_facecolor('#0a0a1a')
ax1.axis('off')

# ──── Panel 2: Shortest Path Tropical Example ────
ax2 = fig.add_subplot(gs[1, 0])
ax2.set_title('Example: Shortest Path\n= Tropical Matrix Power', fontsize=12, fontweight='bold', color='white')

# Small graph
nodes = {0: (1, 3), 1: (3, 5), 2: (5, 3), 3: (3, 1)}
edges = [
    (0, 1, 2), (0, 3, 7), (1, 2, 3), (1, 3, 1), (2, 3, 5), (0, 2, 10)
]

for (u, v, w) in edges:
    x1, y1 = nodes[u]
    x2, y2 = nodes[v]
    ax2.plot([x1, x2], [y1, y2], '-', color='#666666', linewidth=2)
    mx, my = (x1+x2)/2 + 0.2, (y1+y2)/2 + 0.2
    ax2.text(mx, my, str(w), fontsize=10, color='#f39c12', fontweight='bold')

for node, (x, y) in nodes.items():
    ax2.plot(x, y, 'o', color='#3498db', markersize=25, zorder=5)
    ax2.text(x, y, str(node), ha='center', va='center', fontsize=12, color='white', fontweight='bold')

# Highlight shortest path 0→1→3
path_edges = [(0, 1), (1, 3)]
for u, v in path_edges:
    x1, y1 = nodes[u]
    x2, y2 = nodes[v]
    ax2.plot([x1, x2], [y1, y2], '-', color='#2ecc71', linewidth=4, zorder=4)

ax2.text(3, -0.3, 'Shortest 0→3: min(7, 2+1) = 3\n= Tropical: 7 ⊕ (2 ⊗ 1) = min(7, 3) = 3', 
         ha='center', fontsize=9, color='#2ecc71',
         bbox=dict(boxstyle='round', facecolor='#1a1a2e', alpha=0.8))

ax2.set_xlim(-0.5, 6.5)
ax2.set_ylim(-1.5, 6)
ax2.set_facecolor('#0a0a1a')
ax2.axis('off')

# ──── Panel 3: Log-Semiring Phase Transition ────
ax3 = fig.add_subplot(gs[1, 1])
ax3.set_title('Complexity Phase Transition?\nAs h varies in the log-semiring', 
              fontsize=12, fontweight='bold', color='white')

h_values = np.logspace(-2, 1, 100)

# Simulated "computational cost" for different problems
# (conceptual — illustrating the hypothesis)
np.random.seed(42)

# Easy problem: stays easy
easy = 10 * np.ones_like(h_values) + 2 * np.sin(np.log(h_values))

# Hard problem: potentially gets easier in tropical limit
hard = 100 * np.exp(-2/h_values) + 10  # Hard at h=1, easier as h→0

# Another hard problem: stays hard
hard2 = 80 + 20 * np.tanh(h_values)

ax3.semilogx(h_values, easy, '-', color='#2ecc71', linewidth=2, label='P problem')
ax3.semilogx(h_values, hard, '-', color='#e74c3c', linewidth=2, label='NP problem (type A)')
ax3.semilogx(h_values, hard2, '-', color='#f39c12', linewidth=2, label='NP problem (type B)')

ax3.axvline(x=1, color='white', linestyle=':', alpha=0.3)
ax3.text(1.2, 95, 'h=1\n(standard)', fontsize=9, color='white', alpha=0.5)

ax3.axvline(x=0.01, color='#e74c3c', linestyle=':', alpha=0.3)
ax3.text(0.012, 95, 'h→0\n(tropical)', fontsize=9, color='#e74c3c', alpha=0.5)

# Phase transition region
ax3.axvspan(0.05, 0.3, alpha=0.1, color='#9b59b6')
ax3.text(0.12, 50, 'Phase\ntransition?', fontsize=10, color='#9b59b6', ha='center', fontweight='bold')

ax3.set_xlabel('h (deformation parameter)', color='white')
ax3.set_ylabel('Computational cost (conceptual)', color='white')
ax3.legend(facecolor='#1a1a2e', labelcolor='white', fontsize=9)
ax3.set_facecolor('#0a0a1a')
ax3.tick_params(colors='white')
for spine in ax3.spines.values():
    spine.set_color('#444444')

# ──── Panel 4: Sphere + Tropical = ? ────
ax4 = fig.add_subplot(gs[1, 2])
ax4.set_title('Tropical Geometry on the Sphere\nPiecewise-linear "equators"', 
              fontsize=12, fontweight='bold', color='white')

# Draw a circle (equatorial view of S²)
theta = np.linspace(0, 2*np.pi, 300)
ax4.plot(np.cos(theta), np.sin(theta), '-', color='white', linewidth=1, alpha=0.3)

# Tropical curves on the sphere = piecewise geodesics
# Draw several tropical "lines" as piecewise great circle arcs
colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6']

for i, color in enumerate(colors):
    # Each tropical line is max of two linear functions, projected to circle
    offset = 0.3 * i - 0.6
    # Create a piecewise linear curve
    t = np.linspace(-2, 2, 100)
    # Two branches meeting at a kink
    x_vals = np.where(t < offset, t, offset + 0 * t)  
    y_vals = np.where(t < offset, offset * np.ones_like(t), t)
    # Normalize to circle
    norms = np.sqrt(x_vals**2 + y_vals**2)
    norms = np.maximum(norms, 0.01)
    x_norm = x_vals / norms * 0.95
    y_norm = y_vals / norms * 0.95
    # Only plot points inside circle
    mask = (x_vals**2 + y_vals**2) <= 1.5**2
    ax4.plot(x_norm[mask], y_norm[mask], '-', color=color, linewidth=2, alpha=0.7)

# Intersection points
intersections = [(0, 0), (0.3, 0.3), (-0.3, -0.3), (0.2, -0.4)]
for ix, iy in intersections:
    ax4.plot(ix, iy, '*', color='#f1c40f', markersize=12, zorder=5)

ax4.text(0, -1.4, 'Tropical curves become piecewise geodesics\non the sphere — potentially tractable!', 
         ha='center', fontsize=9, color='white',
         bbox=dict(boxstyle='round', facecolor='#1a1a2e', alpha=0.8))

ax4.set_xlim(-1.6, 1.6)
ax4.set_ylim(-1.8, 1.4)
ax4.set_aspect('equal')
ax4.set_facecolor('#0a0a1a')
ax4.axis('off')

fig.patch.set_facecolor('#0a0a1a')
plt.savefig('/workspace/request-project/demos/tropical_stereo_synthesis.png', 
            dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
plt.close()
print("✅ Saved: demos/tropical_stereo_synthesis.png")
