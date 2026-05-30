"""
Visualization: Phantom Entropy vs. Observer Count

Shows how phantom entropy grows as observers are added to a system.
Compares: (a) independent observers (each contributes new information),
(b) redundant observers (duplicates contribute nothing).

The key insight: entropy grows linearly with independent observers
but plateaus with redundant ones, providing a diversity measure.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations

# Work with topologies on X = {0, 1}
# 4 topologies: discrete, Sierp-0, Sierp-1, indiscrete
X = frozenset({0, 1})

discrete = frozenset([frozenset(), frozenset({0}), frozenset({1}), frozenset({0, 1})])
sierp0 = frozenset([frozenset(), frozenset({0}), frozenset({0, 1})])
sierp1 = frozenset([frozenset(), frozenset({1}), frozenset({0, 1})])
indiscrete = frozenset([frozenset(), frozenset({0, 1})])


def consensus_of(*tops):
    """Consensus = intersection of open-set families."""
    if not tops:
        return discrete
    result = set(tops[0])
    for t in tops[1:]:
        result &= set(t)
    return frozenset(result)


def spectrum_size(observers):
    """Compute |spectrum| for a list of observers."""
    spec = {discrete}  # Empty subset
    for r in range(1, len(observers) + 1):
        for combo in combinations(observers, r):
            spec.add(consensus_of(*combo))
    return len(spec)


# Scenario 1: Independent observers (alternating Sierp-0, Sierp-1)
independent_observers = [sierp0, sierp1, sierp0, sierp1, sierp0, sierp1]
independent_entropies = []
for k in range(len(independent_observers) + 1):
    obs = independent_observers[:k]
    spec = spectrum_size(obs)
    independent_entropies.append(spec - 1)

# Scenario 2: Redundant observers (all Sierp-0)
redundant_observers = [sierp0, sierp0, sierp0, sierp0, sierp0, sierp0]
redundant_entropies = []
for k in range(len(redundant_observers) + 1):
    obs = redundant_observers[:k]
    spec = spectrum_size(obs)
    redundant_entropies.append(spec - 1)

# Scenario 3: Mixed (some independent, some redundant)
mixed_observers = [sierp0, sierp1, sierp0, indiscrete, sierp1, sierp0]
mixed_entropies = []
for k in range(len(mixed_observers) + 1):
    obs = mixed_observers[:k]
    spec = spectrum_size(obs)
    mixed_entropies.append(spec - 1)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# --- Panel 1: Entropy Growth ---
ax = axes[0]
x = np.arange(len(independent_entropies))

ax.plot(x, independent_entropies, 'o-', color='#2ECC71', linewidth=2.5,
        markersize=8, label='Independent (Sierp-0, Sierp-1, ...)', zorder=5)
ax.plot(x, redundant_entropies, 's-', color='#E74C3C', linewidth=2.5,
        markersize=8, label='Redundant (all Sierp-0)', zorder=5)
ax.plot(x, mixed_entropies, '^-', color='#3498DB', linewidth=2.5,
        markersize=8, label='Mixed', zorder=5)

ax.fill_between(x, independent_entropies, alpha=0.1, color='#2ECC71')
ax.fill_between(x, redundant_entropies, alpha=0.1, color='#E74C3C')

ax.set_xlabel("Number of Observers", fontsize=13, fontweight='bold')
ax.set_ylabel("Phantom Entropy", fontsize=13, fontweight='bold')
ax.set_title("Phantom Entropy vs. Observer Count\n(X = {0, 1})", fontsize=14, fontweight='bold')
ax.legend(fontsize=10, loc='upper left')
ax.grid(True, alpha=0.3)
ax.set_xticks(x)
ax.set_ylim(-0.5, max(independent_entropies) + 1)

# Annotate key points
ax.annotate("Redundancy →\nno entropy gain",
            xy=(2, redundant_entropies[2]),
            xytext=(3.5, 0.5),
            fontsize=9,
            arrowprops=dict(arrowstyle='->', color='#E74C3C'),
            color='#E74C3C')

ax.annotate("Each new independent\nobserver adds entropy",
            xy=(3, independent_entropies[3]),
            xytext=(4, independent_entropies[3] - 0.8),
            fontsize=9,
            arrowprops=dict(arrowstyle='->', color='#2ECC71'),
            color='#2ECC71')

# --- Panel 2: Spectrum Structure ---
ax2 = axes[1]

# Show spectrum structure for 2 independent observers
obs_list = [sierp0, sierp1]
spec_elements = set()
spec_elements.add(("∅→discrete", discrete))

all_combos = []
for r in range(1, len(obs_list) + 1):
    for combo in combinations(range(len(obs_list)), r):
        obs = tuple(obs_list[i] for i in combo)
        c = consensus_of(*obs)
        label = "{" + ",".join(f"obs{i+1}" for i in combo) + "}"
        all_combos.append((label, c, combo))

# Create bar chart of spectrum
labels = ["S=∅\n(discrete)"]
sizes = [4]  # discrete has 4 open sets
colors_bar = ['#E74C3C']

for label, c, combo in all_combos:
    labels.append(f"S={label}")
    sizes.append(len(c))
    if len(combo) == 1:
        colors_bar.append('#3498DB' if combo[0] == 0 else '#F39C12')
    else:
        colors_bar.append('#9B59B6')

bars = ax2.bar(range(len(labels)), sizes, color=colors_bar,
               edgecolor='#2C3E50', linewidth=1.5)

ax2.set_xticks(range(len(labels)))
ax2.set_xticklabels(labels, fontsize=9, rotation=15, ha='right')
ax2.set_ylabel("|Open Sets|", fontsize=13, fontweight='bold')
ax2.set_title("Phantom Spectrum Structure\n(2 Independent Observers)", fontsize=14, fontweight='bold')
ax2.grid(True, alpha=0.3, axis='y')

# Add value labels on bars
for bar, size in zip(bars, sizes):
    ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.1,
             str(size), ha='center', va='bottom', fontsize=11, fontweight='bold')

# Add topology names
topology_names = {4: "discrete", 3: "Sierp", 2: "indiscrete"}
for bar, size in zip(bars, sizes):
    if size in topology_names:
        ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height()/2,
                 topology_names[size], ha='center', va='center',
                 fontsize=8, color='white', fontweight='bold')

ax2.set_ylim(0, 5.5)

plt.tight_layout()
plt.savefig('phantom_entropy.png', dpi=150, bbox_inches='tight',
            facecolor='white', edgecolor='none')
plt.close()
print("Saved: phantom_entropy.png")
