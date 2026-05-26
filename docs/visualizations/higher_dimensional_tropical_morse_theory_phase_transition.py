"""
Visualization 3: Phase Transition in Random 2-Complexes

Shows the phase transition in the Linial-Meshulam model where β₁ vanishes
as triangle probability increases, viewed through the lens of tropical
Morse theory. The transition is a cascade of death events.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random
import itertools
from enum import Enum
from dataclasses import dataclass


# ─── Self-contained algorithms ───

class TropicalEvent(Enum):
    BIRTH = "birth"
    DEATH = "death"

class SimplicialComplex:
    def __init__(self, simplices):
        self.simplices = set(simplices)
        to_add = set()
        for s in self.simplices:
            s_list = list(s)
            for i in range(1, 2**len(s_list)):
                to_add.add(frozenset(s_list[j] for j in range(len(s_list)) if i & (1 << j)))
        self.simplices |= to_add
    def d_simplices(self, d):
        return {s for s in self.simplices if len(s) == d + 1}

def z2_rank(matrix):
    if not matrix or not matrix[0]: return 0
    m = [row[:] for row in matrix]
    rows, cols = len(m), len(m[0])
    rank = 0
    for col in range(cols):
        pivot = None
        for row in range(rank, rows):
            if m[row][col] % 2 == 1: pivot = row; break
        if pivot is None: continue
        m[rank], m[pivot] = m[pivot], m[rank]
        for row in range(rows):
            if row != rank and m[row][col] % 2 == 1:
                m[row] = [(m[row][c] + m[rank][c]) % 2 for c in range(cols)]
        rank += 1
    return rank

def boundary_matrix_z2(K, d):
    d_simps = sorted(K.d_simplices(d), key=lambda s: tuple(sorted(s)))
    d1_simps = sorted(K.d_simplices(d - 1), key=lambda s: tuple(sorted(s)))
    if not d_simps or not d1_simps: return [], d_simps, d1_simps
    d1_index = {s: i for i, s in enumerate(d1_simps)}
    matrix = [[0]*len(d_simps) for _ in range(len(d1_simps))]
    for j, sigma in enumerate(d_simps):
        for v in sigma:
            face = sigma - {v}
            if face in d1_index: matrix[d1_index[face]][j] = 1
    return matrix, d_simps, d1_simps

def compute_betti(K, max_dim=2):
    betti = {}; ranks = {}
    for d in range(max_dim + 2):
        mat, _, _ = boundary_matrix_z2(K, d); ranks[d] = z2_rank(mat)
    for d in range(max_dim + 1):
        betti[d] = len(K.d_simplices(d)) - ranks.get(d, 0) - ranks.get(d + 1, 0)
    return betti


# ─── Phase transition data ───

n = 10
p_values = np.linspace(0.01, 0.99, 40)
n_trials = 5

avg_beta1 = []
avg_beta2 = []
avg_death_frac = []

for p in p_values:
    b1_vals, b2_vals, df_vals = [], [], []

    for trial in range(n_trials):
        random.seed(int(p * 1000) + trial)

        base_verts = {frozenset({v}) for v in range(n)}
        base_edges = set()
        for i, j in itertools.combinations(range(n), 2):
            base_edges.add(frozenset({i, j}))

        all_tris = list(itertools.combinations(range(n), 3))
        included = [frozenset(t) for t in all_tris if random.random() < p]

        K = SimplicialComplex(base_verts | base_edges | set(included))
        betti = compute_betti(K, 2)

        b1_vals.append(betti[1])
        b2_vals.append(betti[2])

        # Death fraction: how many of the inserted triangles kill a 1-cycle
        total_1cycles = len(base_edges) - n + 1  # β₁ of complete graph
        df_vals.append(1.0 - betti[1] / total_1cycles if total_1cycles > 0 else 1.0)

    avg_beta1.append(np.mean(b1_vals))
    avg_beta2.append(np.mean(b2_vals))
    avg_death_frac.append(np.mean(df_vals))


# ─── Plot ───

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: β₁ vs p
ax1 = axes[0]
ax1.plot(p_values, avg_beta1, 'o-', color='#FF5722', markersize=4, linewidth=1.5, label='β₁')
ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
ax1.fill_between(p_values, avg_beta1, alpha=0.15, color='#FF5722')
ax1.set_xlabel('Triangle probability p', fontsize=12)
ax1.set_ylabel('β₁ (loop count)', fontsize=12)
ax1.set_title('β₁ Phase Transition', fontsize=13, fontweight='bold')
ax1.grid(True, alpha=0.3)

# Find approximate transition point
for i, b in enumerate(avg_beta1):
    if b < 0.5:
        ax1.axvline(x=p_values[i], color='red', linestyle=':', alpha=0.7,
                    label=f'Transition ≈ p={p_values[i]:.2f}')
        break
ax1.legend(fontsize=10)

# Panel 2: β₂ vs p
ax2 = axes[1]
ax2.plot(p_values, avg_beta2, 's-', color='#4CAF50', markersize=4, linewidth=1.5, label='β₂')
ax2.fill_between(p_values, avg_beta2, alpha=0.15, color='#4CAF50')
ax2.set_xlabel('Triangle probability p', fontsize=12)
ax2.set_ylabel('β₂ (void count)', fontsize=12)
ax2.set_title('β₂ Growth', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Panel 3: Death fraction
ax3 = axes[2]
ax3.plot(p_values, avg_death_frac, 'D-', color='#9C27B0', markersize=4, linewidth=1.5)
ax3.fill_between(p_values, avg_death_frac, alpha=0.15, color='#9C27B0')
ax3.set_xlabel('Triangle probability p', fontsize=12)
ax3.set_ylabel('Fraction of 1-cycles killed', fontsize=12)
ax3.set_title('Tropical Death Cascade', fontsize=13, fontweight='bold')
ax3.grid(True, alpha=0.3)

plt.suptitle('Phase Transition in Random 2-Complexes via Tropical Morse Theory',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_phase.png', dpi=150, bbox_inches='tight')
print("Saved viz_phase.png")
