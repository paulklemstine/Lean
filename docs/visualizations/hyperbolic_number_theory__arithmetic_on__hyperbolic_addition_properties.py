"""
Visualization: Hyperbolic Addition and Its Properties
======================================================

Visualizes the key properties of hyperbolic addition
(a ⊕ b = (a+b)/(1+ab)), which is the relativistic velocity
addition formula.

Shows:
1. The hyperbolic addition surface
2. Comparison with ordinary addition
3. Iterated hypAdd convergence to 1
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D


def hyp_add(a, b):
    """Hyperbolic addition."""
    return (a + b) / (1 + a * b)


def hyp_add_iter(a, n):
    """Iterated hyperbolic addition."""
    result = 0.0
    for _ in range(n):
        result = hyp_add(result, a)
    return result


fig = plt.figure(figsize=(18, 5.5))

# --- Panel 1: Surface plot of hypAdd ---
ax1 = fig.add_subplot(131, projection='3d')

a_vals = np.linspace(-0.95, 0.95, 80)
b_vals = np.linspace(-0.95, 0.95, 80)
A, B = np.meshgrid(a_vals, b_vals)
Z = (A + B) / (1 + A * B)

# Mask where result is outside (-1, 1) — shouldn't happen but just in case
mask = np.abs(Z) < 1
Z_masked = np.where(mask, Z, np.nan)

surf = ax1.plot_surface(A, B, Z_masked, cmap='coolwarm', alpha=0.85,
                        edgecolor='none', antialiased=True)
ax1.set_xlabel('a', fontsize=11)
ax1.set_ylabel('b', fontsize=11)
ax1.set_zlabel('a ⊕ b', fontsize=11)
ax1.set_title('Hyperbolic Addition\na ⊕ b = (a+b)/(1+ab)', fontsize=12, fontweight='bold')
ax1.view_init(elev=25, azim=-60)

# Add the plane z = 1 for reference
ax1.plot_surface(A, B, np.ones_like(A), alpha=0.1, color='red')
ax1.plot_surface(A, B, -np.ones_like(A), alpha=0.1, color='red')

# --- Panel 2: Comparison with ordinary addition ---
ax2 = fig.add_subplot(132)

a_vals = np.linspace(0, 0.99, 100)
b_fixed = [0.3, 0.5, 0.7, 0.9]

for b in b_fixed:
    hyp = (a_vals + b) / (1 + a_vals * b)
    ax2.plot(a_vals, hyp, linewidth=2, label=f'a ⊕ {b}')
    # Ordinary addition (capped at 1 for display)
    ordinary = np.minimum(a_vals + b, 1.5)
    ax2.plot(a_vals, ordinary, '--', alpha=0.4, linewidth=1)

ax2.axhline(y=1, color='red', linestyle=':', alpha=0.5, label='Speed limit (1)')
ax2.set_xlabel('a', fontsize=12)
ax2.set_ylabel('a ⊕ b', fontsize=12)
ax2.set_title('Hyperbolic vs Ordinary Addition\n(dashed = ordinary)', fontsize=12, fontweight='bold')
ax2.legend(fontsize=9, loc='lower right')
ax2.set_xlim(0, 1)
ax2.set_ylim(0, 1.1)
ax2.grid(True, alpha=0.3)
ax2.fill_between([0, 1], 1, 1.1, alpha=0.1, color='red')
ax2.text(0.5, 1.03, 'Forbidden zone', ha='center', fontsize=9, color='red', alpha=0.7)

# --- Panel 3: Iterated hypAdd convergence ---
ax3 = fig.add_subplot(133)

a_values = [0.1, 0.3, 0.5, 0.7, 0.9]
n_max = 30

for a in a_values:
    seq = [hyp_add_iter(a, n) for n in range(n_max + 1)]
    ax3.plot(range(n_max + 1), seq, 'o-', markersize=3, linewidth=1.5,
             label=f'a = {a}')

ax3.axhline(y=1, color='red', linestyle=':', alpha=0.5, linewidth=2)
ax3.set_xlabel('Number of iterations n', fontsize=12)
ax3.set_ylabel('hypAdd_iter(a, n)', fontsize=12)
ax3.set_title('Iterated Hyperbolic Addition\nConverges to 1 (proven < 1 always)',
              fontsize=12, fontweight='bold')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)
ax3.set_ylim(-0.05, 1.05)

# Annotate the proven bound
ax3.annotate('Proven: always < 1\n(hypAdd_iter_lt_one)',
             xy=(20, 0.98), fontsize=9, color='red',
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.9))

plt.tight_layout()
plt.savefig('hyperbolic_addition.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: hyperbolic_addition.png")
