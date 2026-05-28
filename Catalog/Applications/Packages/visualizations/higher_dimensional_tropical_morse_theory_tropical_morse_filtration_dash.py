#!/usr/bin/env python3
"""
viz_filtration.py — Visualization of tropical Morse filtration and homology jump profiles.

Visualizes:
1. The homology jump profile (births and deaths) across the filtration
2. Betti number evolution through the filtration
3. Tropical barrier positions

This script is fully self-contained and does not import from local modules.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


# ─── Inline data structures ───

class FiltrationStep:
    def __init__(self, weight, dim, creates_cycle):
        self.weight = weight
        self.dim = dim
        self.creates_cycle = creates_cycle

    def betti_delta(self, n):
        if self.creates_cycle:
            return 1 if self.dim == n else 0
        else:
            if self.dim > 0 and self.dim - 1 == n:
                return -1
            return 0


def build_toric_filtration(L):
    """Build filtration for L×L toric code."""
    steps = []
    V, E, F = L*L, 2*L*L, L*L

    for i in range(V):
        steps.append(FiltrationStep(1.0, 0, True))
    for i in range(V - 1):
        steps.append(FiltrationStep(2.0 + i * 0.1, 1, False))
    remaining = E - (V - 1)
    for i in range(2):
        steps.append(FiltrationStep(float(L) + i, 1, True))
    for i in range(remaining - 2):
        steps.append(FiltrationStep(float(L) + 2 + i * 0.1, 1, True))
    face_deaths = remaining - 2
    for i in range(face_deaths):
        steps.append(FiltrationStep(2.0 * L + i * 0.1, 2, False))
    steps.append(FiltrationStep(2.0 * L + face_deaths * 0.1, 2, True))
    remaining_faces = F - face_deaths - 1
    for i in range(remaining_faces):
        steps.append(FiltrationStep(2.0 * L + (face_deaths + 1 + i) * 0.1, 2, False))

    return steps


# ─── Build data ───

L = 5
steps = build_toric_filtration(L)

# Compute Betti trajectories
betti = {0: [0], 1: [0], 2: [0]}
weights = [0]

for s in steps:
    for d in range(3):
        betti[d].append(betti[d][-1] + s.betti_delta(d))
    weights.append(s.weight)

# Collect jump events
birth_events = [(s.weight, s.dim) for s in steps if s.creates_cycle]
death_events = [(s.weight, s.dim) for s in steps if not s.creates_cycle]

# ─── Create figure ───

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle(f'Tropical Morse Filtration — {L}×{L} Toric Code', fontsize=16, fontweight='bold')

# Panel 1: Betti number evolution
ax1 = axes[0, 0]
colors = ['#2196F3', '#F44336', '#4CAF50']
labels = ['β₀ (components)', 'β₁ (cycles)', 'β₂ (cavities)']
for d in range(3):
    ax1.plot(weights, betti[d], color=colors[d], linewidth=2, label=labels[d])
ax1.set_xlabel('Filtration Weight', fontsize=12)
ax1.set_ylabel('Betti Number', fontsize=12)
ax1.set_title('Betti Number Evolution', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(alpha=0.3)

# Panel 2: Jump profile (births and deaths)
ax2 = axes[0, 1]
dim_colors = {0: '#2196F3', 1: '#F44336', 2: '#4CAF50'}

for w, d in birth_events:
    ax2.bar(w, 1, width=0.15, color=dim_colors[d], alpha=0.7, edgecolor='none')
for w, d in death_events:
    ax2.bar(w, -1, width=0.15, color=dim_colors[d], alpha=0.5, edgecolor='none',
            hatch='///')

ax2.axhline(y=0, color='black', linewidth=0.5)
ax2.set_xlabel('Filtration Weight', fontsize=12)
ax2.set_ylabel('Δβ (birth=+1, death=−1)', fontsize=12)
ax2.set_title('Homology Jump Profile', fontsize=13)

# Custom legend
patches = [
    mpatches.Patch(color='#2196F3', label='dim 0'),
    mpatches.Patch(color='#F44336', label='dim 1'),
    mpatches.Patch(color='#4CAF50', label='dim 2'),
]
ax2.legend(handles=patches, fontsize=10)
ax2.grid(alpha=0.3)

# Panel 3: Tropical barrier visualization
ax3 = axes[1, 0]
barrier_lambda = float(L)
birth_weights_1 = sorted([w for w, d in birth_events if d == 1])

ax3.hist(birth_weights_1, bins=15, color='#F44336', alpha=0.7, edgecolor='white',
         label='Degree-1 births')
ax3.axvline(x=barrier_lambda, color='#FF9800', linewidth=3, linestyle='--',
            label=f'Barrier λ={barrier_lambda}')

births_above = sum(1 for w in birth_weights_1 if w >= barrier_lambda)
ax3.annotate(f'{births_above} births ≥ λ\n→ d_Z ≥ {births_above}',
            xy=(barrier_lambda + 0.5, ax3.get_ylim()[1] * 0.7 if ax3.get_ylim()[1] > 0 else 1),
            fontsize=11, color='#FF9800', fontweight='bold')

ax3.set_xlabel('Weight', fontsize=12)
ax3.set_ylabel('Count', fontsize=12)
ax3.set_title('Tropical Barrier Analysis', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(alpha=0.3)

# Panel 4: Euler characteristic consistency check
ax4 = axes[1, 1]
euler_running = [0]
for s in steps:
    euler_running.append(euler_running[-1] + (-1)**s.dim)

alt_betti_sum = [betti[0][i] - betti[1][i] + betti[2][i] for i in range(len(weights))]

ax4.plot(weights, euler_running, 'b-', linewidth=2, label='χ = Σ(-1)^d', alpha=0.7)
ax4.plot(weights, alt_betti_sum, 'r--', linewidth=2, label='β₀ - β₁ + β₂', alpha=0.7)
ax4.set_xlabel('Filtration Weight', fontsize=12)
ax4.set_ylabel('Value', fontsize=12)
ax4.set_title('Euler-Poincaré Consistency', fontsize=13)
ax4.legend(fontsize=10)
ax4.grid(alpha=0.3)

plt.tight_layout()
plt.savefig('viz_filtration.png', dpi=150, bbox_inches='tight')
print("Saved viz_filtration.png")
