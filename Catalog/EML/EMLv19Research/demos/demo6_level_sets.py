"""
Demo 6: EML Level Sets and Sublevel Characterization

V19 proves:
- Level set {y : eml(x,y) = c} is the singleton y = exp(exp(x) - c)
- Sublevel set {y > 0 : eml(x,y) ≤ c} = [exp(exp(x)-c), ∞)
- eml(x,y) ≤ c iff exp(exp(x)-c) ≤ y

This reveals the "exponential-of-exponential" structure in EML's geometry.
"""

import numpy as np
import matplotlib.pyplot as plt

def eml(x, y):
    return np.exp(x) - np.log(y)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: Level curves of eml in (x, y) plane
ax = axes[0]
x = np.linspace(-2, 2, 200)
y = np.linspace(0.1, 10, 200)
X, Y = np.meshgrid(x, y)
Z = eml(X, Y)
levels = [-2, -1, 0, 1, 2, 3, 5, 8]
c = ax.contour(X, Y, Z, levels=levels, cmap='viridis')
ax.clabel(c, inline=True, fontsize=9)
# Overlay the level curve formula y = exp(exp(x) - c)
for c_val in [0, 1, 2]:
    x_curve = np.linspace(-2, 2, 200)
    y_curve = np.exp(np.exp(x_curve) - c_val)
    mask = y_curve < 10
    ax.plot(x_curve[mask], y_curve[mask], 'r--', alpha=0.7)
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.set_title('Level Curves: eml(x,y) = c')
ax.grid(True, alpha=0.3)

# Plot 2: Sublevel sets for fixed x
ax = axes[1]
x_fixed = 0  # eml(0, y) = 1 - log(y)
y = np.linspace(0.01, 10, 500)
eml_vals = eml(x_fixed, y)
ax.plot(y, eml_vals, 'b-', linewidth=2, label='eml(0, y) = 1 - log(y)')
for c_val, color in [(0, 'red'), (1, 'green'), (2, 'purple')]:
    y_boundary = np.exp(np.exp(x_fixed) - c_val)
    ax.axhline(y=c_val, color=color, linestyle='--', alpha=0.5)
    ax.axvline(x=y_boundary, color=color, linestyle=':', alpha=0.5)
    ax.fill_between(y, c_val, eml_vals, where=eml_vals<=c_val,
                    alpha=0.1, color=color, label=f'eml ≤ {c_val}: y ≥ {y_boundary:.2f}')
ax.set_xlabel('y')
ax.set_ylabel('eml(0, y)')
ax.set_title('Sublevel Sets: y ≥ exp(1-c)')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Plot 3: Level set boundary y = exp(exp(x) - c) for various c
ax = axes[2]
x = np.linspace(-2, 2, 200)
for c_val in [-1, 0, 1, 2, 3]:
    y_boundary = np.exp(np.exp(x) - c_val)
    mask = y_boundary < 100
    ax.semilogy(x[mask], y_boundary[mask], label=f'c = {c_val}')
ax.set_xlabel('x')
ax.set_ylabel('y (log scale)')
ax.set_title('Level Set Boundaries: y = exp(eˣ - c)')
ax.legend()
ax.grid(True, alpha=0.3)

plt.suptitle('V19: EML Level Sets & Sublevel Characterization', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('demo6_level_sets.png', dpi=150, bbox_inches='tight')
plt.close()
print("Demo 6 saved: demo6_level_sets.png")
