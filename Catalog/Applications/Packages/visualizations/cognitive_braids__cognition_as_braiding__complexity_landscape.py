"""
Visualization 2: Cognitive Complexity Landscape

A heatmap showing the relationship between crossing number, writhe, and
cognitive complexity level. Demonstrates the proved theorem that
|writhe| ≤ crossing_number (the feasible region) and the cognitive
hierarchy (trivial → simple → moderate → complex).
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# ─── Left panel: Writhe vs Crossing Number with feasibility region ────

max_crossings = 12
crossings = np.arange(0, max_crossings + 1)

# Feasible region: |writhe| ≤ crossing_number
# Also writhe ≡ crossing_number (mod 2) — proved theorem
for k in crossings:
    feasible_writhes = [w for w in range(-k, k + 1) if (w - k) % 2 == 0]
    for w in feasible_writhes:
        info = abs(w)
        if k == 0:
            color = '#95a5a6'  # trivial
        elif k <= 2:
            color = '#3498db'  # simple
        elif k <= 5:
            color = '#2ecc71'  # moderate
        else:
            color = '#e74c3c'  # complex

        size = max(20, 60 * (info / max(k, 1)))
        ax1.scatter(k, w, s=size + 30, c=color, alpha=0.7, edgecolors='white', linewidth=0.5)

# Mark special braids
special_braids = [
    (0, 0, 'Identity\n(No thought)', '#95a5a6'),
    (2, 2, 'Hopf link\n(Paired)', '#3498db'),
    (3, 3, 'Trefoil\n(Creative)', '#2ecc71'),
    (4, 0, 'Figure-8\n(Confused)', '#2ecc71'),
    (6, 6, 'Full twist\n(Deep focus)', '#e74c3c'),
]

for cx, wr, label, color in special_braids:
    ax1.scatter(cx, wr, s=200, c=color, edgecolors='black', linewidth=2, zorder=5)
    offset_x = 0.4 if cx < 5 else -0.4
    offset_y = 0.8
    ax1.annotate(label, (cx, wr), xytext=(cx + offset_x, wr + offset_y),
                fontsize=8, fontweight='bold', ha='center',
                arrowprops=dict(arrowstyle='->', color='gray', lw=0.8))

# Draw feasibility boundary
ax1.plot(crossings, crossings, 'k--', alpha=0.5, label='|writhe| = crossings')
ax1.plot(crossings, -crossings, 'k--', alpha=0.5)
ax1.fill_between(crossings, -crossings, crossings, alpha=0.05, color='blue')

ax1.set_xlabel('Crossing Number (Complexity)', fontsize=12)
ax1.set_ylabel('Writhe (Algebraic Crossing Number)', fontsize=12)
ax1.set_title('Cognitive Braid Space\n|writhe| ≤ crossings (proved)', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Add cognitive level bands
for (xmin, xmax, label, color) in [(0, 0.5, 'Trivial', '#95a5a6'),
                                     (0.5, 2.5, 'Simple', '#3498db'),
                                     (2.5, 5.5, 'Moderate', '#2ecc71'),
                                     (5.5, 12.5, 'Complex', '#e74c3c')]:
    ax1.axvspan(xmin, xmax, alpha=0.08, color=color)

# ─── Right panel: Information content vs complexity ────────────

# Generate random braids and compute their invariants
np.random.seed(42)
n_samples = 200
data_crossings = []
data_info = []
data_levels = []

for _ in range(n_samples):
    k = np.random.randint(0, 13)
    # Random writhe with correct parity
    if k == 0:
        w = 0
    else:
        possible = [x for x in range(-k, k + 1) if (x - k) % 2 == 0]
        w = np.random.choice(possible)
    data_crossings.append(k)
    data_info.append(abs(w))
    if k == 0: data_levels.append(0)
    elif k <= 2: data_levels.append(1)
    elif k <= 5: data_levels.append(2)
    else: data_levels.append(3)

level_colors = ['#95a5a6', '#3498db', '#2ecc71', '#e74c3c']
level_names = ['Trivial', 'Simple', 'Moderate', 'Complex']

for level in range(4):
    mask = [l == level for l in data_levels]
    cx = [data_crossings[i] for i in range(n_samples) if mask[i]]
    info = [data_info[i] for i in range(n_samples) if mask[i]]
    ax2.scatter(cx, info, c=level_colors[level], label=level_names[level],
               alpha=0.6, s=30, edgecolors='white', linewidth=0.3)

# Theoretical bound line
x_line = np.linspace(0, 12, 100)
ax2.plot(x_line, x_line, 'k-', linewidth=2, label='info = complexity (upper bound)')
ax2.fill_between(x_line, 0, x_line, alpha=0.05, color='green')

ax2.set_xlabel('Crossing Number (Complexity)', fontsize=12)
ax2.set_ylabel('Information Content |writhe|', fontsize=12)
ax2.set_title('Information ≤ Complexity\n(Shannon-type bound, proved)', fontsize=14, fontweight='bold')
ax2.legend(fontsize=9, loc='upper left')
ax2.grid(True, alpha=0.3)
ax2.set_xlim(-0.5, 12.5)
ax2.set_ylim(-0.5, 12.5)

plt.tight_layout()
plt.savefig('viz_complexity_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_complexity_landscape.png")
