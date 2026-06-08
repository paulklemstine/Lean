#!/usr/bin/env python3
"""
EML-KA Decomposition Visualization

Visualizes the LogAffine Separation Algebra and EML-KA decomposition
properties using matplotlib.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

def log_affine_eval(alpha, beta, x):
    """Evaluate LogAffine map α·log(x) + β"""
    return alpha * np.log(x) + beta

def eml_ka_multiply(x, y):
    return np.exp(np.log(x) + np.log(y))

def eml_ka_add(x, y):
    return np.exp(np.log(x)) + np.exp(np.log(y))

def fenchel_young_gap(x, s):
    return np.exp(x) + s * np.log(s) - s - x * s

# Create figure with 4 panels
fig = plt.figure(figsize=(16, 12))
gs = GridSpec(2, 2, figure=fig, hspace=0.3, wspace=0.3)

# ============================================================
# Panel 1: LogAffine Separation — different (α,β) pairs
# ============================================================
ax1 = fig.add_subplot(gs[0, 0])
x = np.linspace(0.1, 5, 200)

params = [(1, 0, 'log(x)'), (2, 0, '2·log(x)'), (0.5, 1, '½·log(x)+1'),
          (-1, 2, '-log(x)+2'), (1, -1, 'log(x)-1')]
colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd']

for (a, b, label), color in zip(params, colors):
    ax1.plot(x, log_affine_eval(a, b, x), label=label, color=color, linewidth=2)

ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.3)
ax1.axvline(x=1, color='gray', linestyle='--', alpha=0.3)
ax1.set_xlabel('x', fontsize=12)
ax1.set_ylabel('f(x)', fontsize=12)
ax1.set_title('LogAffine Separation Algebra\n{x ↦ α·log(x) + β}', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_ylim(-4, 5)
ax1.grid(True, alpha=0.2)

# ============================================================
# Panel 2: EML-KA Error Surface for Addition
# ============================================================
ax2 = fig.add_subplot(gs[0, 1])
x_grid = np.linspace(0.1, 5, 100)
y_grid = np.linspace(0.1, 5, 100)
X, Y = np.meshgrid(x_grid, y_grid)
Z_exact = X + Y
Z_emlka = eml_ka_add(X, Y)
Z_error = np.abs(Z_exact - Z_emlka)

im = ax2.pcolormesh(X, Y, np.log10(Z_error + 1e-16), cmap='viridis', shading='auto')
cb = plt.colorbar(im, ax=ax2, label='log₁₀(|error|)')
ax2.set_xlabel('x', fontsize=12)
ax2.set_ylabel('y', fontsize=12)
ax2.set_title('EML-KA Addition: Numerical Precision\n2-term decomposition error', fontsize=13, fontweight='bold')

# ============================================================
# Panel 3: Fenchel-Young Gap Surface
# ============================================================
ax3 = fig.add_subplot(gs[1, 0])
x_range = np.linspace(-3, 3, 200)
s_values = [0.5, 1.0, np.e, 3.0]
colors3 = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728']

for s, color in zip(s_values, colors3):
    gap = fenchel_young_gap(x_range, s)
    ax3.plot(x_range, gap, label=f's={s:.2f} (min at x={np.log(s):.2f})',
             color=color, linewidth=2)
    ax3.plot(np.log(s), 0, 'o', color=color, markersize=8, zorder=5)

ax3.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax3.set_xlabel('x', fontsize=12)
ax3.set_ylabel('Gap(x, s)', fontsize=12)
ax3.set_title('Fenchel-Young Gap\nexp(x) + s·log(s) − s − x·s ≥ 0', fontsize=13, fontweight='bold')
ax3.legend(fontsize=9)
ax3.set_ylim(-0.5, 15)
ax3.grid(True, alpha=0.2)

# ============================================================
# Panel 4: EML-KA Complexity Comparison
# ============================================================
ax4 = fig.add_subplot(gs[1, 1])

operations = ['x·y', 'x/y', 'x^a·y^b', '√(xy)', 'x+y', 'x^r+y^r',
              'Σcᵢx^{aᵢ}y^{bᵢ}', 'c (const)']
terms = [1, 1, 1, 1, 2, 2, 3, 1]  # example M=3 for poly
depths = [2, 2, 2, 2, 2, 2, 2, 0]

y_pos = np.arange(len(operations))
bar_width = 0.35

bars1 = ax4.barh(y_pos - bar_width/2, terms, bar_width, label='Terms (Q)',
                  color='#2196F3', alpha=0.8)
bars2 = ax4.barh(y_pos + bar_width/2, depths, bar_width, label='Depth',
                  color='#FF9800', alpha=0.8)

ax4.set_yticks(y_pos)
ax4.set_yticklabels(operations, fontsize=10)
ax4.set_xlabel('Count', fontsize=12)
ax4.set_title('EML-KA Complexity Table\nTerms × Depth = Total Operations', fontsize=13, fontweight='bold')
ax4.legend(fontsize=10)
ax4.grid(True, axis='x', alpha=0.2)

# Add value labels
for bar in bars1:
    width = bar.get_width()
    ax4.text(width + 0.1, bar.get_y() + bar.get_height()/2, f'{int(width)}',
             ha='left', va='center', fontsize=9)
for bar in bars2:
    width = bar.get_width()
    ax4.text(width + 0.1, bar.get_y() + bar.get_height()/2, f'{int(width)}',
             ha='left', va='center', fontsize=9)

fig.suptitle('EML Spectral Kolmogorov-Arnold Theory', fontsize=16, fontweight='bold', y=0.98)
plt.savefig('emlka_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: emlka_visualization.png")
