"""
Visualization 2: Pisot Numbers and the Aperiodicity Landscape

Visualizes the algebraic number theory underlying aperiodic tilings:
- Quadratic Pisot numbers with norm 1 (roots of x² - bx + 1 = 0)
- The Pisot "cone": region where α > 1 and |α'| < 1
- The hat's position in this landscape

The key insight: the hat's inflation factor 2 + √3 is a Pisot number,
and this Pisot property is responsible for the tiling having pure point
diffraction (sharp Bragg peaks like a crystal, but aperiodic).
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib

matplotlib.rcParams.update({
    'font.size': 12,
    'axes.labelsize': 14,
    'axes.titlesize': 15,
})

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Pisot numbers on the number line
ax1 = axes[0]
pisot_data = []
for b in range(3, 16):
    disc = b * b - 4
    if disc > 0:
        alpha = (b + np.sqrt(disc)) / 2
        alpha_conj = (b - np.sqrt(disc)) / 2
        if alpha > 1 and abs(alpha_conj) < 1:
            pisot_data.append((b, alpha, alpha_conj))

alphas = [p[1] for p in pisot_data]
conjs = [p[2] for p in pisot_data]
traces = [p[0] for p in pisot_data]

ax1.scatter(alphas, conjs, c=traces, cmap='viridis', s=150, zorder=5,
            edgecolors='black', linewidth=1)

# Highlight the hat
hat_idx = traces.index(4)
ax1.scatter([alphas[hat_idx]], [conjs[hat_idx]], c='red', s=300, zorder=6,
            marker='*', edgecolors='black', linewidth=1.5,
            label=f'Hat: (2+√3, 2−√3)')

# Pisot region boundaries
ax1.axhline(y=1, color='gray', linestyle='--', alpha=0.5)
ax1.axhline(y=-1, color='gray', linestyle='--', alpha=0.5)
ax1.axhline(y=0, color='gray', linestyle='-', alpha=0.3)
ax1.axvline(x=1, color='gray', linestyle='--', alpha=0.5)

# Fill Pisot region
ax1.fill_between([1, 15], -1, 1, alpha=0.1, color='green', label='Pisot region: |α\'| < 1')

for i, (b, a, ac) in enumerate(pisot_data):
    ax1.annotate(f'b={b}', (a, ac), textcoords="offset points",
                 xytext=(10, 5), fontsize=8, alpha=0.7)

ax1.set_xlabel('Pisot number α (larger root)')
ax1.set_ylabel('Conjugate α\' (smaller root)')
ax1.set_title('Quadratic Pisot Numbers\nwith Norm 1 (x² − bx + 1 = 0)')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(1.5, 15)

# Plot 2: The inflation polynomial for the hat
ax2 = axes[1]
x = np.linspace(-1, 6, 1000)
y = x**2 - 4*x + 1

ax2.plot(x, y, 'b-', linewidth=2.5, label='p(x) = x² − 4x + 1')
ax2.axhline(y=0, color='gray', linestyle='-', alpha=0.5)

# Mark roots
sigma = 2 + np.sqrt(3)
sigma_conj = 2 - np.sqrt(3)
ax2.scatter([sigma], [0], color='red', s=150, zorder=5, marker='*',
            label=f'σ = 2+√3 ≈ {sigma:.3f}')
ax2.scatter([sigma_conj], [0], color='orange', s=100, zorder=5, marker='o',
            label=f'σ\' = 2−√3 ≈ {sigma_conj:.3f}')

# Mark vertex
ax2.scatter([2], [-3], color='purple', s=80, zorder=5, marker='D',
            label='Vertex: (2, −3)')

# Shade regions
ax2.fill_between(x[x < sigma_conj], 0, y[x < sigma_conj],
                 where=y[x < sigma_conj] > 0, alpha=0.1, color='blue')
ax2.fill_between(x[x > sigma], 0, y[x > sigma],
                 where=y[x > sigma] > 0, alpha=0.1, color='blue')

# Annotations
ax2.annotate('Inflation factor\n(area scaling)', xy=(sigma, 0),
             xytext=(sigma + 0.3, 4), fontsize=10,
             arrowprops=dict(arrowstyle='->', color='red'),
             color='red', fontweight='bold')
ax2.annotate('Conjugate\n(0 < σ\' < 1: Pisot!)', xy=(sigma_conj, 0),
             xytext=(sigma_conj - 1.5, 6), fontsize=10,
             arrowprops=dict(arrowstyle='->', color='orange'),
             color='orange', fontweight='bold')

ax2.set_xlabel('x')
ax2.set_ylabel('p(x)')
ax2.set_title('Hat Inflation Polynomial\nx² − 4x + 1 = 0')
ax2.legend(fontsize=9, loc='upper left')
ax2.grid(True, alpha=0.3)
ax2.set_ylim(-5, 12)

plt.suptitle('Algebraic Number Theory of the Hat Tile',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_pisot.png', dpi=150, bbox_inches='tight')
print("Saved viz_pisot.png")
