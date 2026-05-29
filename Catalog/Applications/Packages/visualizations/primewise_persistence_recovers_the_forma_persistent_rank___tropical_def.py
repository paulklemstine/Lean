"""
Visualization: Persistent Rank and Tropical Defect Curves

Visualizes the core invariants of arithmetic persistence theory:
- Persistent rank functions r(t) showing monotone filtration behavior
- Tropical defect functions τ(t) showing supersingular collapse
- Height signature comparison across reduction types

The key insight: supersingular profiles produce flat maximal persistent rank
and identically zero tropical defect, while finite-height profiles show
characteristic jumps whose locations encode the formal Brauer group height.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

# ---- Inline implementations ----

def height_signature(slopes, center, eps):
    return sum(1 for s in slopes if abs(s - center) <= eps)

def tropical_defect(slopes, center, t):
    if not slopes:
        return 0.0
    return max(max(0.0, abs(s - center) - t) for s in slopes)

# ---- Profile data ----

def supersingular_slopes(n=22):
    return [1.0] * n

def ordinary_slopes():
    return [0.0] + [1.0] * 20 + [2.0]

def height_h_slopes(h):
    slopes = []
    for k in range(1, h + 1):
        slopes.append(1.0 + k / h)
        slopes.append(1.0 - k / h)
    slopes.extend([1.0] * (22 - len(slopes)))
    return slopes

# ---- Build figure ----

center = 1.0
t_vals = np.linspace(0, 2.5, 1000)

profiles = {
    'Supersingular (h=∞)': supersingular_slopes(),
    'Ordinary (h=1)': ordinary_slopes(),
    'Height h=2': height_h_slopes(2),
    'Height h=5': height_h_slopes(5),
    'Height h=10': height_h_slopes(10),
}

colors = ['#e74c3c', '#2ecc71', '#3498db', '#9b59b6', '#f39c12']

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Persistent rank curves
ax = axes[0, 0]
for (name, slopes), color in zip(profiles.items(), colors):
    ranks = [height_signature(slopes, center, t) for t in t_vals]
    ax.plot(t_vals, ranks, label=name, color=color, linewidth=2)
ax.set_xlabel('Filtration parameter t', fontsize=11)
ax.set_ylabel('Persistent rank r(t)', fontsize=11)
ax.set_title('(a) Persistent Rank Functions', fontsize=13, fontweight='bold')
ax.legend(fontsize=8, loc='lower right')
ax.grid(True, alpha=0.2)
ax.set_ylim(-0.5, 23)
ax.axhline(y=22, color='gray', linestyle=':', alpha=0.5, label='maximal rank')

# Panel 2: Tropical defect curves
ax = axes[0, 1]
for (name, slopes), color in zip(profiles.items(), colors):
    defects = [tropical_defect(slopes, center, t) for t in t_vals]
    ax.plot(t_vals, defects, label=name, color=color, linewidth=2)
ax.set_xlabel('Threshold t', fontsize=11)
ax.set_ylabel('Tropical defect τ(t)', fontsize=11)
ax.set_title('(b) Tropical Defect Functions', fontsize=13, fontweight='bold')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.2)

# Panel 3: Slope distributions
ax = axes[1, 0]
for i, (name, slopes) in enumerate(profiles.items()):
    y_offset = i * 0.4
    devs = sorted([abs(s - center) for s in slopes])
    ax.scatter(devs, [y_offset] * len(devs), color=colors[i], s=40, alpha=0.7,
              zorder=5, edgecolors='black', linewidth=0.5)
    ax.annotate(name, (-0.05, y_offset), fontsize=8, ha='right', va='center')
ax.set_xlabel('|slope − center|', fontsize=11)
ax.set_title('(c) Slope Deviation Distributions', fontsize=13, fontweight='bold')
ax.set_yticks([])
ax.grid(True, alpha=0.2, axis='x')
ax.set_xlim(-0.1, 1.5)

# Panel 4: Classification phase diagram
ax = axes[1, 1]
heights = list(range(1, 11)) + [0]  # 0 = supersingular
eps_range = np.linspace(0.01, 1.5, 200)

phase_data = np.zeros((len(heights), len(eps_range)))
for i, h in enumerate(heights):
    if h == 0:
        slopes = supersingular_slopes()
    else:
        slopes = height_h_slopes(h)
    for j, eps in enumerate(eps_range):
        sig = height_signature(slopes, center, eps)
        phase_data[i, j] = sig / 22.0

im = ax.imshow(phase_data, aspect='auto', origin='lower',
              extent=[eps_range[0], eps_range[-1], -0.5, len(heights)-0.5],
              cmap='viridis', vmin=0, vmax=1)
ax.set_yticks(range(len(heights)))
ax.set_yticklabels([f'h={h}' if h > 0 else 'SS' for h in heights], fontsize=8)
ax.set_xlabel('Scale ε', fontsize=11)
ax.set_title('(d) Height Signature Heatmap', fontsize=13, fontweight='bold')
plt.colorbar(im, ax=ax, label='Normalized signature', shrink=0.8)

plt.suptitle('Arithmetic Persistence Invariants for K3 Height Detection',
            fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_persistence_curves.png', dpi=150, bbox_inches='tight')
print("Saved: viz_persistence_curves.png")
plt.close()
