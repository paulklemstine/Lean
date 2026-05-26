"""
Visualization: Spectral Gap Geometry
======================================
Visualizes the geometry of gapped Lorentzian signatures:
- How eigenvalues define the safety zone
- The perturbation ball and signature boundary
- Gap degradation under successive perturbations
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Circle, FancyArrowPatch
from matplotlib.collections import PatchCollection


fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# ---- Panel 1: Eigenvalue spectrum with gap ----
ax = axes[0]
eigenvalues = np.array([-2.5, -1.8, -1.2, -0.5, 1.5])
gap = 0.5  # Minimum |negative eigenvalue|

colors = ['#d32f2f' if e < 0 else '#388e3c' for e in eigenvalues]
ax.barh(range(len(eigenvalues)), eigenvalues, color=colors, height=0.6, alpha=0.8)

# Mark the gap
ax.axvline(x=0, color='black', linewidth=1.5, linestyle='-')
ax.axvline(x=-gap, color='orange', linewidth=2, linestyle='--', label=f'Gap boundary (ε = {gap})')
ax.axvline(x=gap, color='orange', linewidth=2, linestyle='--')

# Shade the danger zone
ax.axvspan(-gap, gap, alpha=0.1, color='red', label='Danger zone')

ax.set_xlabel('Eigenvalue', fontsize=12)
ax.set_ylabel('Index', fontsize=12)
ax.set_title('Eigenvalue Spectrum with Spectral Gap', fontsize=13)
ax.legend(fontsize=9, loc='lower right')
ax.set_yticks(range(len(eigenvalues)))
ax.set_yticklabels([f'λ_{i+1}' for i in range(len(eigenvalues))])
ax.grid(True, alpha=0.2)

# ---- Panel 2: Perturbation ball in signature space ----
ax = axes[1]

# Draw the Lorentzian cone boundary (simplified 2D projection)
theta = np.linspace(0, 2*np.pi, 100)

# Safe zone (circle of radius ε)
gap_radius = 1.5
circle_safe = plt.Circle((0, 0), gap_radius, fill=True, facecolor='#e8f5e9',
                          edgecolor='#388e3c', linewidth=2, label=f'Safe zone (radius ε)')
ax.add_patch(circle_safe)

# Critical zone
circle_crit = plt.Circle((0, 0), gap_radius * 1.5, fill=True, facecolor='#fff3e0',
                          edgecolor='#f57c00', linewidth=1.5, linestyle='--',
                          label='Warning zone')
ax.add_patch(circle_crit)

# Mark the matrix A at center
ax.plot(0, 0, 'ko', markersize=10, zorder=5)
ax.annotate('A', (0.1, 0.15), fontsize=14, fontweight='bold')

# Show some perturbation arrows
np.random.seed(42)
for _ in range(8):
    angle = np.random.uniform(0, 2*np.pi)
    r = np.random.uniform(0.3, gap_radius * 0.8)
    dx, dy = r * np.cos(angle), r * np.sin(angle)
    ax.annotate('', xy=(dx, dy), xytext=(0, 0),
                arrowprops=dict(arrowstyle='->', color='#1565c0', lw=1.5, alpha=0.6))
    ax.plot(dx, dy, 'o', color='#1565c0', markersize=4, alpha=0.7)

# One dangerous perturbation
angle = 0.8
r = gap_radius * 1.3
dx, dy = r * np.cos(angle), r * np.sin(angle)
ax.annotate('', xy=(dx, dy), xytext=(0, 0),
            arrowprops=dict(arrowstyle='->', color='#d32f2f', lw=2.5))
ax.plot(dx, dy, 'X', color='#d32f2f', markersize=12, zorder=5)
ax.annotate('Failure!', (dx+0.1, dy+0.15), fontsize=10, color='#d32f2f')

ax.set_xlim(-3, 3)
ax.set_ylim(-3, 3)
ax.set_aspect('equal')
ax.set_xlabel('Perturbation component 1', fontsize=12)
ax.set_ylabel('Perturbation component 2', fontsize=12)
ax.set_title('Perturbation Safety Zone', fontsize=13)
ax.legend(fontsize=9, loc='upper left')
ax.grid(True, alpha=0.2)

# ---- Panel 3: Gap degradation under successive perturbations ----
ax = axes[2]

initial_gap = 2.0
perturbation_bounds = [0.3, 0.5, 0.2, 0.4, 0.3]
cumulative_bounds = np.cumsum([0] + perturbation_bounds)
remaining_gaps = [initial_gap - cb for cb in cumulative_bounds]

steps = range(len(remaining_gaps))
colors_grad = plt.cm.RdYlGn(np.linspace(0.8, 0.2, len(remaining_gaps)))

bars = ax.bar(steps, remaining_gaps, color=colors_grad, edgecolor='gray',
              width=0.7, alpha=0.85)

# Add perturbation annotations
for i, pb in enumerate(perturbation_bounds):
    ax.annotate(f'δ_{i+1}={pb}', xy=(i+0.5, remaining_gaps[i+1] + 0.05),
                xytext=(i+0.8, remaining_gaps[i] - 0.15),
                fontsize=8, ha='center',
                arrowprops=dict(arrowstyle='->', color='gray', lw=1))

ax.axhline(y=0, color='red', linewidth=2, linestyle='--', label='Failure threshold')
ax.set_xlabel('Perturbation step', fontsize=12)
ax.set_ylabel('Remaining gap (ε - Σδ)', fontsize=12)
ax.set_title('Gap Degradation Under Sequential Perturbation', fontsize=13)
ax.set_xticks(steps)
ax.set_xticklabels([f'Step {i}' for i in steps], fontsize=9)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.2, axis='y')

plt.tight_layout()
plt.savefig('viz_gap_geometry.png', dpi=150, bbox_inches='tight')
print("Saved viz_gap_geometry.png")
