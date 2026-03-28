#!/usr/bin/env python3
"""
Demo 6 — Tangent Vectors ↔ Derivations
=======================================
Shows how a tangent vector at a point corresponds to a derivation
satisfying the Leibniz rule δ(fg) = f·δ(g) + g·δ(f).

Visualises tangent vectors on a curve and the Leibniz rule diagram.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))
fig.patch.set_facecolor("#0d1117")

# --- Left: Geometric side — tangent vector on a curve ---
ax1.set_facecolor("#0d1117")
t = np.linspace(-2, 2, 300)
curve_x = t
curve_y = t ** 2

ax1.plot(curve_x, curve_y, color='#58A6FF', lw=3, label='Curve: y = x²')

# Point and tangent
px, py = 1.0, 1.0
ax1.plot(px, py, 'o', color='#F0883E', markersize=14, zorder=5)

# Tangent line: dy/dx = 2x = 2 at x=1
tang_t = np.linspace(-0.5, 2.5, 100)
tang_y = 2 * (tang_t - 1) + 1
ax1.plot(tang_t, tang_y, '--', color='#F0883E', lw=2, label='Tangent at (1,1)')

# Arrow for tangent vector
ax1.annotate('', xy=(1.6, 2.2), xytext=(1.0, 1.0),
             arrowprops=dict(arrowstyle='->', color='#3FB950', lw=3))
ax1.text(1.7, 2.3, "v", fontsize=18, color='#3FB950', fontweight='bold')

ax1.set_title("GEOMETRY: Tangent vector v at point p",
              fontsize=14, color='white', pad=12)
ax1.set_xlim(-1.5, 2.5)
ax1.set_ylim(-0.5, 4)
ax1.legend(fontsize=10, facecolor='#161B22', edgecolor='#30363D',
           labelcolor='#C9D1D9')
ax1.spines[:].set_color('#30363D')
ax1.tick_params(colors='#484F58')

# --- Right: Algebraic side — Leibniz rule diagram ---
ax2.set_facecolor("#0d1117")
ax2.set_xlim(0, 10)
ax2.set_ylim(0, 6)

# Leibniz rule box
box_text = (
    "δ : A → M\n\n"
    "δ(a · b) = a · δ(b) + b · δ(a)\n\n"
    "Example: δ = d/dx\n"
    "d/dx(x² · x³) = x² · 3x² + x³ · 2x\n"
    "              = 3x⁴ + 2x⁴ = 5x⁴  ✓"
)
props = dict(boxstyle='round,pad=0.8', facecolor='#161B22',
             edgecolor='#A371F7', lw=2)
ax2.text(5, 3, box_text, fontsize=13, ha='center', va='center',
         color='#C9D1D9', bbox=props, family='monospace')

ax2.set_title("ALGEBRA: Derivation δ with Leibniz rule",
              fontsize=14, color='white', pad=12)
ax2.axis('off')

fig.suptitle("Row 6: Tangent Vectors ↔ Derivations",
             fontsize=16, color='white', fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("demo_06_derivations.png", dpi=150, bbox_inches='tight',
            facecolor=fig.get_facecolor())
plt.show()
print("✓ Saved demo_06_derivations.png")
