"""
Visualization: Tropical Defect as Height Detector

Shows the cross-domain connection between arithmetic slope data and tropical
geometry through the tropical defect function. The key theorem:
the tropical defect vanishes identically at all non-negative thresholds
if and only if the profile is supersingular.

This visualization demonstrates how slope concentration produces tropical
collapse — the min-plus analogue of the height dichotomy.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ---- Inline implementations ----

def tropical_defect(slopes, center, t):
    if not slopes:
        return 0.0
    return max(max(0.0, abs(s - center) - t) for s in slopes)

def height_signature(slopes, center, eps):
    return sum(1 for s in slopes if abs(s - center) <= eps)

# ---- Profiles ----

center = 1.0

profiles = {
    'Supersingular': [1.0] * 22,
    'Height 1 (ordinary)': [0.0] + [1.0]*20 + [2.0],
    'Height 2': [1.0 + k/2 for k in range(1,3)] + [1.0 - k/2 for k in range(1,3)] + [1.0]*18,
    'Height 5': [1.0 + k/5 for k in range(1,6)] + [1.0 - k/5 for k in range(1,6)] + [1.0]*12,
}

colors = ['#e74c3c', '#2ecc71', '#3498db', '#9b59b6']

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Tropical defect curves
ax = axes[0, 0]
t_vals = np.linspace(0, 2.0, 500)
for (name, slopes), color in zip(profiles.items(), colors):
    defects = [tropical_defect(slopes, center, t) for t in t_vals]
    ax.plot(t_vals, defects, label=name, color=color, linewidth=2.5)

    # Mark breakpoints
    devs = sorted(set(abs(s - center) for s in slopes))
    for d in devs:
        if d > 0:
            td = tropical_defect(slopes, center, d)
            ax.plot(d, td, 'o', color=color, markersize=6, zorder=5)

ax.set_xlabel('Threshold t', fontsize=12)
ax.set_ylabel('Tropical defect τ(t)', fontsize=12)
ax.set_title('(a) Tropical Defect Functions', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.2)
ax.axhline(y=0, color='gray', linestyle='-', alpha=0.3)

# Panel 2: Derivative of tropical defect (slope detection)
ax = axes[0, 1]
dt = t_vals[1] - t_vals[0]
for (name, slopes), color in zip(profiles.items(), colors):
    defects = np.array([tropical_defect(slopes, center, t) for t in t_vals])
    ddefects = -np.gradient(defects, dt)  # Negative derivative (defect decreases)
    ax.plot(t_vals, ddefects, label=name, color=color, linewidth=1.5, alpha=0.8)

ax.set_xlabel('Threshold t', fontsize=12)
ax.set_ylabel('-dτ/dt', fontsize=12)
ax.set_title('(b) Tropical Defect Derivative\n(Jump Detection)', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.2)

# Panel 3: Combined persistence + tropical view
ax = axes[1, 0]
slopes_h3 = [1.0 + k/3 for k in range(1,4)] + [1.0 - k/3 for k in range(1,4)] + [1.0]*16
t_fine = np.linspace(0, 2.0, 1000)

ranks = [height_signature(slopes_h3, center, t) / 22 for t in t_fine]
defects = [tropical_defect(slopes_h3, center, t) for t in t_fine]

ax.plot(t_fine, ranks, color='#3498db', linewidth=2.5, label='Normalized rank r(t)/n')
ax_twin = ax.twinx()
ax_twin.plot(t_fine, defects, color='#e74c3c', linewidth=2.5, linestyle='--',
            label='Tropical defect τ(t)')
ax_twin.set_ylabel('Tropical defect', fontsize=11, color='#e74c3c')

# Mark critical deviations
devs = sorted(set(abs(s - center) for s in slopes_h3))
for d in devs:
    if d > 0:
        ax.axvline(x=d, color='gray', linestyle=':', alpha=0.4)
        ax.annotate(f'd={d:.2f}', (d, 0.05), fontsize=7, rotation=90)

ax.set_xlabel('Parameter t', fontsize=12)
ax.set_ylabel('Normalized rank', fontsize=11, color='#3498db')
ax.set_title('(c) Height 3: Rank vs Tropical Defect', fontsize=13, fontweight='bold')
ax.legend(loc='center left', fontsize=9)
ax_twin.legend(loc='center right', fontsize=9)
ax.grid(True, alpha=0.2)

# Panel 4: Phase transition diagram
ax = axes[1, 1]
heights = range(1, 11)
max_devs = []
vanishing_thresholds = []

for h in heights:
    slopes = [1.0 + k/h for k in range(1, h+1)] + \
             [1.0 - k/h for k in range(1, h+1)] + [1.0]*(22-2*h)
    md = max(abs(s - center) for s in slopes)
    max_devs.append(md)
    vanishing_thresholds.append(md)

ax.bar(list(heights), vanishing_thresholds, color='#3498db', alpha=0.7,
       edgecolor='navy', linewidth=1.5)
ax.plot(list(heights), [1.0]*len(heights), 'r--', linewidth=2,
       label='Symmetry center', alpha=0.5)
ax.set_xlabel('Formal Brauer group height h', fontsize=12)
ax.set_ylabel('Tropical vanishing threshold', fontsize=12)
ax.set_title('(d) Height vs Tropical Vanishing\n(Phase Transition)', fontsize=13, fontweight='bold')
ax.set_xticks(list(heights))
ax.legend(fontsize=10)
ax.grid(True, alpha=0.2, axis='y')

# Add annotation about supersingular limit
ax.annotate('h → ∞: threshold → 0\n(tropical collapse)',
           xy=(8, 0.3), fontsize=9, fontstyle='italic',
           bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.suptitle('Tropical Geometry Meets Arithmetic Persistence',
            fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_tropical.png', dpi=150, bbox_inches='tight')
print("Saved: viz_tropical.png")
plt.close()
