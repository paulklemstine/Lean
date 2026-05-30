"""
Visualization: Fenchel-Young Inequality and EML Duality

Illustrates the Fenchel-Young inequality x·s ≤ exp(x) + s·log(s) - s
which provides a variational characterization of the EML operation.
The gap is zero exactly when x = log(s), connecting exp and log dually.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# --- Panel 1: Fenchel-Young for different values of s ---
x = np.linspace(-3, 4, 200)
s_values = [0.5, 1.0, 2.0, 5.0]
colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336']

for s, color in zip(s_values, colors):
    lhs = x * s
    rhs = np.exp(x) + s * np.log(s) - s
    axes[0].plot(x, rhs - lhs, color=color, linewidth=2, label=f's = {s}')
    axes[0].axvline(np.log(s), color=color, linestyle='--', alpha=0.5)

axes[0].axhline(0, color='black', linewidth=0.5)
axes[0].set_xlabel('x', fontsize=12)
axes[0].set_ylabel('Gap = RHS − LHS', fontsize=12)
axes[0].set_title('Fenchel-Young Gap\n(minimum at x = log s)', fontsize=12)
axes[0].legend(fontsize=10)
axes[0].set_ylim(-0.5, 10)
axes[0].grid(True, alpha=0.3)

# --- Panel 2: exp(x) and its conjugate ---
x = np.linspace(-2, 3, 200)
axes[1].plot(x, np.exp(x), 'b-', linewidth=2.5, label='exp(x)')

# Tangent lines showing duality
for s, color in zip([0.5, 1.0, 2.0], ['#4CAF50', '#FF9800', '#F44336']):
    x0 = np.log(s)
    tangent = s * (x - x0) + s
    axes[1].plot(x, tangent, color=color, linewidth=1.5, linestyle='--',
                 alpha=0.7, label=f'Tangent at x=log({s})')
    axes[1].plot(x0, s, 'o', color=color, markersize=8)

axes[1].set_xlabel('x', fontsize=12)
axes[1].set_ylabel('y', fontsize=12)
axes[1].set_title('exp(x) and Supporting Hyperplanes\n(Convex Conjugate Structure)', fontsize=12)
axes[1].legend(fontsize=9)
axes[1].set_ylim(-1, 12)
axes[1].grid(True, alpha=0.3)

# --- Panel 3: The EML surface eml(x,y) = exp(x) - log(y) ---
y_pos = np.linspace(0.1, 5.0, 100)
x_vals = [-1.0, 0.0, 1.0, 2.0]
for xv, color in zip(x_vals, colors):
    eml_vals = np.exp(xv) - np.log(y_pos)
    axes[2].plot(y_pos, eml_vals, color=color, linewidth=2,
                 label=f'eml({xv}, y)')

axes[2].axhline(0, color='black', linewidth=0.5)
axes[2].set_xlabel('y', fontsize=12)
axes[2].set_ylabel('eml(x, y)', fontsize=12)
axes[2].set_title('EML Slices: eml(x, y) = exp(x) − log(y)\n(exp dominates for large x)', fontsize=12)
axes[2].legend(fontsize=10)
axes[2].grid(True, alpha=0.3)

plt.suptitle('EML Duality: Fenchel-Young Inequality and Convex Conjugates',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_fenchel_young.png', dpi=150, bbox_inches='tight')
print("Saved viz_fenchel_young.png")
