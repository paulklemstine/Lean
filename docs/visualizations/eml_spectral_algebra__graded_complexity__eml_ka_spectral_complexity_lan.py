#!/usr/bin/env python3
"""
Visualization: EML-KA Spectral Complexity Landscape
====================================================

Visualizes the EML-KA complexity of various function classes,
showing how the spectral algebra stratifies bivariate functions.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

def eval_mul_emlka(x, y):
    return np.exp(np.log(x) + np.log(y))

def eval_monomial_emlka(x, y, a, b):
    return np.exp(a * np.log(x) + b * np.log(y))

def eval_poly_emlka(x, y, coeffs, exps_a, exps_b):
    total = np.zeros_like(x)
    for c, a, b in zip(coeffs, exps_a, exps_b):
        total += c * np.exp(a * np.log(x) + b * np.log(y))
    return total

# Figure 1: Complexity Landscape
fig, axes = plt.subplots(2, 3, figsize=(15, 10))
fig.suptitle('EML-KA Spectral Algebra: Complexity Landscape on (0,∞)²',
             fontsize=14, fontweight='bold')

x = np.linspace(0.1, 3, 100)
y = np.linspace(0.1, 3, 100)
X, Y = np.meshgrid(x, y)

# C₁: multiplication
Z1 = eval_mul_emlka(X, Y)
axes[0, 0].contourf(X, Y, Z1, levels=20, cmap='viridis')
axes[0, 0].set_title('C₁: x·y (1 term)', fontsize=11)
axes[0, 0].set_xlabel('x'); axes[0, 0].set_ylabel('y')

# C₁: x²y³
Z2 = eval_monomial_emlka(X, Y, 2, 3)
axes[0, 1].contourf(X, Y, Z2, levels=20, cmap='plasma')
axes[0, 1].set_title('C₁: x²y³ (1 term)', fontsize=11)
axes[0, 1].set_xlabel('x'); axes[0, 1].set_ylabel('y')

# C₁: geometric mean
Z3 = np.sqrt(X * Y)
axes[0, 2].contourf(X, Y, Z3, levels=20, cmap='inferno')
axes[0, 2].set_title('C₁: √(xy) (1 term)', fontsize=11)
axes[0, 2].set_xlabel('x'); axes[0, 2].set_ylabel('y')

# C₂: addition
Z4 = X + Y
axes[1, 0].contourf(X, Y, Z4, levels=20, cmap='coolwarm')
axes[1, 0].set_title('C₂: x + y (2 terms)', fontsize=11)
axes[1, 0].set_xlabel('x'); axes[1, 0].set_ylabel('y')

# C₃: polynomial with 3 monomials
Z5 = eval_poly_emlka(X, Y, [3, 2, -1], [2, 1, 1], [1, 2, 1])
axes[1, 1].contourf(X, Y, Z5, levels=20, cmap='RdYlBu_r')
axes[1, 1].set_title('C₃: 3x²y + 2xy² − xy', fontsize=11)
axes[1, 1].set_xlabel('x'); axes[1, 1].set_ylabel('y')

# Complexity spectrum diagram
ax = axes[1, 2]
ax.set_xlim(0, 6); ax.set_ylim(0, 5)
colors = ['#2ecc71', '#3498db', '#e74c3c', '#9b59b6', '#f39c12']
labels = ['C₁', 'C₂', 'C₃', 'C₄', 'C₅']
functions = [
    ['x·y', 'x/y', 'x²y³', '√(xy)'],
    ['x+y', 'x−y'],
    ['3x²y+2xy²−xy'],
    ['polynomial (4 terms)'],
    ['polynomial (5 terms)']
]

for i in range(5):
    rect = mpatches.FancyBboxPatch((0.3, 4.2 - i*0.9), 5.2, 0.7,
                                    boxstyle="round,pad=0.1",
                                    facecolor=colors[i], alpha=0.3,
                                    edgecolor=colors[i], linewidth=2)
    ax.add_patch(rect)
    ax.text(0.5, 4.55 - i*0.9, f'{labels[i]}:', fontsize=10, fontweight='bold',
            color=colors[i])
    ax.text(1.3, 4.55 - i*0.9, ', '.join(functions[i]), fontsize=9)

ax.set_title('EML-KA Complexity Spectrum', fontsize=11)
ax.axis('off')

plt.tight_layout()
plt.savefig('/workspace/request-project/spectral_landscape.png', dpi=150, bbox_inches='tight')
plt.close()

# Figure 2: AM-GM via EML
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
fig.suptitle('AM-GM Inequality via EML Spectral Perspective', fontsize=13, fontweight='bold')

y_vals = np.linspace(0.1, 5, 200)
x_fixed = 2.0

gm = np.exp((np.log(x_fixed) + np.log(y_vals)) / 2)
am = (x_fixed + y_vals) / 2

ax1.plot(y_vals, am, 'b-', linewidth=2, label='AM = (x+y)/2 [C₂]')
ax1.plot(y_vals, gm, 'r-', linewidth=2, label='GM = exp((log x+log y)/2) [C₁]')
ax1.fill_between(y_vals, gm, am, alpha=0.2, color='green', label='AM−GM gap')
ax1.axvline(x=x_fixed, color='gray', linestyle='--', alpha=0.5, label=f'x = y = {x_fixed}')
ax1.set_xlabel('y (with x = 2 fixed)')
ax1.set_ylabel('Mean value')
ax1.set_title('AM ≥ GM: Higher complexity ≥ Lower complexity')
ax1.legend()
ax1.grid(True, alpha=0.3)

# Fenchel-Young gap
x_range = np.linspace(-2, 3, 200)
s_vals = [0.5, 1.0, 2.0, np.e]
for s in s_vals:
    gap = np.exp(x_range) + s * np.log(s) - s - x_range * s
    ax2.plot(x_range, gap, linewidth=2, label=f's = {s:.2f}')
    ax2.axvline(x=np.log(s), color='gray', linestyle=':', alpha=0.3)

ax2.axhline(y=0, color='black', linewidth=0.5)
ax2.set_xlabel('x')
ax2.set_ylabel('Fenchel-Young gap')
ax2.set_title('Fenchel-Young: exp(x) + s·log(s) − s − x·s ≥ 0')
ax2.legend()
ax2.grid(True, alpha=0.3)
ax2.set_ylim(-0.5, 10)

plt.tight_layout()
plt.savefig('/workspace/request-project/am_gm_fenchel.png', dpi=150, bbox_inches='tight')
plt.close()

print("Visualizations saved: spectral_landscape.png, am_gm_fenchel.png")
