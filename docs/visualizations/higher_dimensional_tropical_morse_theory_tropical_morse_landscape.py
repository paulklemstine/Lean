#!/usr/bin/env python3
"""
Visualization 3: Tropical Morse Landscape

Visualizes the tropical filtration as a landscape where height = weight,
showing how homological events (cycle births and deaths) are distributed
across the tropical spectrum. Includes the tropical barrier concept.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def build_toric_events(L):
    """Build classified filtration events for L×L toric code."""
    events = []
    w = 0
    # Vertices
    for _ in range(L*L):
        events.append({'dim': 0, 'weight': w, 'type': 'birth_0'}); w += 1
    # Merges
    for _ in range(L*L - 1):
        events.append({'dim': 1, 'weight': w, 'type': 'death_0'}); w += 1
    # Cycle creations
    for _ in range(L*L + 1):
        events.append({'dim': 1, 'weight': w, 'type': 'birth_1'}); w += 1
    # Boundary kills
    for _ in range(L*L - 1):
        events.append({'dim': 2, 'weight': w, 'type': 'death_1'}); w += 1
    # Final cycle creation
    events.append({'dim': 2, 'weight': w, 'type': 'birth_2'})
    return events


fig, axes = plt.subplots(2, 1, figsize=(14, 10))

L = 5

# ── Panel 1: Event timeline ──
ax = axes[0]
events = build_toric_events(L)

type_colors = {
    'birth_0': '#27ae60', 'death_0': '#e74c3c',
    'birth_1': '#3498db', 'death_1': '#e67e22',
    'birth_2': '#9b59b6'
}
type_labels = {
    'birth_0': 'β₀ birth (vertex)', 'death_0': 'β₀ death (merge)',
    'birth_1': 'β₁ birth (cycle)', 'death_1': 'β₁ death (fill)',
    'birth_2': 'β₂ birth (cavity)'
}

plotted_types = set()
for e in events:
    t = e['type']
    label = type_labels[t] if t not in plotted_types else None
    marker = '^' if 'birth' in t else 'v'
    size = 60 if t in ('birth_1', 'death_1') else 30
    ax.scatter(e['weight'], e['dim'], c=type_colors[t], marker=marker,
               s=size, label=label, alpha=0.8, edgecolors='black', linewidth=0.5)
    plotted_types.add(t)

# Tropical barrier
barrier_weight = L*L + (L*L - 1) + L*L // 2
ax.axvline(x=barrier_weight, color='red', linestyle='--', alpha=0.6, linewidth=2,
           label=f'Tropical barrier (λ={barrier_weight})')
ax.fill_betweenx([-0.5, 2.5], barrier_weight, max(e['weight'] for e in events) + 5,
                  alpha=0.08, color='red')

ax.set_xlabel('Tropical Weight', fontsize=12)
ax.set_ylabel('Simplex Dimension', fontsize=12)
ax.set_yticks([0, 1, 2])
ax.set_yticklabels(['0 (vertices)', '1 (edges)', '2 (faces)'])
ax.set_title(f'Tropical Morse Event Timeline — Toric Code {L}×{L}\n'
             f'Critical simplex attachments classified by homological effect',
             fontsize=13, fontweight='bold')
ax.legend(fontsize=9, loc='upper left', ncol=2)
ax.grid(True, alpha=0.2)

# ── Panel 2: Cumulative Betti evolution with barrier ──
ax = axes[1]

betti = {0: [], 1: [], 2: []}
current = {0: 0, 1: 0, 2: 0}
weights_all = []

for e in events:
    t = e['type']
    if 'birth' in t:
        d = int(t[-1])
        current[d] += 1
    else:
        d = int(t[-1])
        current[d] -= 1
    weights_all.append(e['weight'])
    for d in range(3):
        betti[d].append(current[d])

colors_betti = {0: '#e74c3c', 1: '#3498db', 2: '#2ecc71'}
for d in range(3):
    ax.step(weights_all, betti[d], where='post', color=colors_betti[d],
            linewidth=2.5, alpha=0.85, label=f'β_{d}')

ax.axvline(x=barrier_weight, color='red', linestyle='--', alpha=0.6, linewidth=2,
           label='Tropical barrier')
ax.fill_betweenx([-1, max(max(b) for b in betti.values()) + 2],
                  barrier_weight, max(weights_all) + 5, alpha=0.08, color='red')

# Annotate key transitions
ax.annotate('Components merge\n(β₀ decreases)', xy=(L*L + L*L//2, betti[0][L*L + L*L//2]),
            fontsize=8, ha='center', va='bottom',
            arrowprops=dict(arrowstyle='->', color='gray'))

cycle_start = 2*L*L - 1
if cycle_start < len(weights_all):
    ax.annotate('Cycles born\n(β₁ increases)', xy=(weights_all[cycle_start], 1),
                fontsize=8, ha='center', va='bottom',
                arrowprops=dict(arrowstyle='->', color='gray'))

ax.set_xlabel('Tropical Weight', fontsize=12)
ax.set_ylabel('Betti Number', fontsize=12)
ax.set_title('Betti Number Evolution with Tropical Barrier\n'
             'Cycles crossing the barrier → distance lower bound',
             fontsize=13, fontweight='bold')
ax.legend(fontsize=10, loc='upper left')
ax.grid(True, alpha=0.2)
ax.set_ylim(-0.5, max(max(b) for b in betti.values()) + 1)

plt.tight_layout()
plt.savefig('viz_tropical_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_tropical_landscape.png")
