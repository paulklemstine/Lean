"""
Visualization: Phantom Filtration Heatmap

Shows how the open-set structure evolves across filtration stages.
Each row is a potential open set, each column is a filtration stage.
Color indicates whether the set is open (green) or closed (red) at
that stage.

Demonstrates the monotone coarsening: green cells can only turn red
as we move right (adding observers removes consensus-open sets).
"""

import matplotlib.pyplot as plt
import numpy as np

# Topologies on X = {0, 1, 2}
X = {0, 1, 2}

# All subsets of X
subsets = [
    frozenset(),
    frozenset({0}),
    frozenset({1}),
    frozenset({2}),
    frozenset({0, 1}),
    frozenset({0, 2}),
    frozenset({1, 2}),
    frozenset({0, 1, 2}),
]
subset_labels = ["∅", "{0}", "{1}", "{2}", "{0,1}", "{0,2}", "{1,2}", "{0,1,2}"]

# Observer topologies (each must be a valid topology)
# Observer 1: distinguishes {0} from {1,2}
obs1_opens = {frozenset(), frozenset({0}), frozenset({1, 2}), frozenset({0, 1, 2})}

# Observer 2: distinguishes {1} from {0,2}
obs2_opens = {frozenset(), frozenset({1}), frozenset({0, 2}), frozenset({0, 1, 2})}

# Observer 3: distinguishes {0,1} from {2}
obs3_opens = {frozenset(), frozenset({2}), frozenset({0, 1}), frozenset({0, 1, 2})}

# Observer 4: same as observer 1 (redundant - should cause stabilization)
obs4_opens = obs1_opens.copy()

observers = [obs1_opens, obs2_opens, obs3_opens, obs4_opens]
observer_names = ["Observer 1\n{0}|{1,2}", "Observer 2\n{1}|{0,2}",
                  "Observer 3\n{0,1}|{2}", "Observer 4\n(=Obs 1)"]

# Compute filtration stages
# Stage 0: discrete (all subsets open)
# Stage k: intersection of observers 1..k
n_stages = len(observers) + 1
n_subsets = len(subsets)

# Build the heatmap matrix
# 1 = open, 0 = closed
heatmap = np.zeros((n_subsets, n_stages))

# Stage 0: discrete
for i in range(n_subsets):
    heatmap[i, 0] = 1

# Stage k: consensus of first k observers
for k in range(1, n_stages):
    consensus_opens = set(subsets)  # Start with all
    for j in range(k):
        consensus_opens &= observers[j]
    for i, s in enumerate(subsets):
        heatmap[i, k] = 1 if s in consensus_opens else 0

fig, axes = plt.subplots(1, 2, figsize=(14, 6), gridspec_kw={'width_ratios': [3, 1]})

# --- Panel 1: Heatmap ---
ax = axes[0]
cmap = plt.cm.colors.ListedColormap(['#E74C3C', '#2ECC71'])

im = ax.imshow(heatmap, cmap=cmap, aspect='auto', interpolation='nearest')

ax.set_xticks(range(n_stages))
stage_labels = ["Stage 0\n(discrete)"] + [f"Stage {k}\n(+{observer_names[k-1]})" for k in range(1, n_stages)]
ax.set_xticklabels(stage_labels, fontsize=8)
ax.set_yticks(range(n_subsets))
ax.set_yticklabels(subset_labels, fontsize=10)

ax.set_xlabel("Filtration Stage", fontsize=12, fontweight='bold')
ax.set_ylabel("Subset of X = {0, 1, 2}", fontsize=12, fontweight='bold')
ax.set_title("Phantom Filtration Heatmap\nGreen = Open, Red = Closed", fontsize=14, fontweight='bold')

# Add text labels
for i in range(n_subsets):
    for j in range(n_stages):
        text = "✓" if heatmap[i, j] == 1 else "✗"
        color = 'white'
        ax.text(j, i, text, ha='center', va='center', fontsize=12,
                color=color, fontweight='bold')

# Highlight stabilization
for k in range(1, n_stages):
    col_k = heatmap[:, k]
    col_prev = heatmap[:, k-1]
    if np.array_equal(col_k, col_prev):
        ax.axvline(x=k - 0.5, color='gold', linewidth=3, linestyle='--', alpha=0.7)
        ax.text(k, -0.8, "STABILIZED", ha='center', fontsize=8,
                color='goldenrod', fontweight='bold')
        break

# --- Panel 2: Open set count ---
ax2 = axes[1]
counts = [int(heatmap[:, k].sum()) for k in range(n_stages)]
colors = ['#2ECC71' if k == 0 else '#3498DB' for k in range(n_stages)]

bars = ax2.barh(range(n_stages), counts, color=colors, edgecolor='#2C3E50', height=0.6)
ax2.set_yticks(range(n_stages))
ax2.set_yticklabels([f"Stage {k}" for k in range(n_stages)], fontsize=10)
ax2.set_xlabel("Number of Open Sets", fontsize=12, fontweight='bold')
ax2.set_title("Open Set Count\n(monotone decreasing)", fontsize=13, fontweight='bold')
ax2.invert_yaxis()

for i, (count, bar) in enumerate(zip(counts, bars)):
    ax2.text(count + 0.1, i, str(count), va='center', fontsize=11, fontweight='bold')

ax2.set_xlim(0, max(counts) + 1)

plt.tight_layout()
plt.savefig('filtration_heatmap.png', dpi=150, bbox_inches='tight',
            facecolor='white', edgecolor='none')
plt.close()
print("Saved: filtration_heatmap.png")
