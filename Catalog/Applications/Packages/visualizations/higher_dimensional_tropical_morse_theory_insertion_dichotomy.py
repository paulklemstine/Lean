"""
Visualization 2: Simplex Insertion Dichotomy — Birth vs Death Heatmap

Creates a heatmap showing which simplex insertions are births and which
are deaths across multiple random complexes, organized by simplex dimension.

This visualizes the core theorem: every simplex insertion changes exactly
one Betti number by exactly ±1, and the change is in degree d (birth) or
degree d-1 (death) where d is the dimension of the inserted simplex.
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

@dataclass
class TropicalMorseDatum:
    degree: int
    event: TropicalEvent

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

def classify_insertion(K, sigma):
    d = len(sigma) - 1
    mat_before, _, _ = boundary_matrix_z2(K, d)
    rank_before = z2_rank(mat_before)
    K_prime = SimplicialComplex(K.simplices | {sigma})
    mat_after, _, _ = boundary_matrix_z2(K_prime, d)
    rank_after = z2_rank(mat_after)
    if rank_after > rank_before:
        return TropicalMorseDatum(degree=d, event=TropicalEvent.DEATH)
    else:
        return TropicalMorseDatum(degree=d, event=TropicalEvent.BIRTH)


# ─── Generate data ───

n_trials = 15
birth_counts = {0: [], 1: [], 2: []}  # by dimension
death_counts = {0: [], 1: [], 2: []}
birth_fracs = {0: [], 1: [], 2: []}

for trial in range(n_trials):
    random.seed(100 + trial)
    n = random.randint(8, 20)

    edges = []
    for i, j in itertools.combinations(range(n), 2):
        if random.random() < 0.25:
            edges.append(frozenset({i, j}))

    triangles = []
    edge_set = set(edges)
    for i, j, k in itertools.combinations(range(n), 3):
        if (frozenset({i,j}) in edge_set and
            frozenset({j,k}) in edge_set and
            frozenset({i,k}) in edge_set and
            random.random() < 0.4):
            triangles.append(frozenset({i, j, k}))

    K = SimplicialComplex({frozenset({v}) for v in range(n)})
    dim_births = {0: 0, 1: 0, 2: 0}
    dim_deaths = {0: 0, 1: 0, 2: 0}

    # Vertices already in, count as births
    dim_births[0] = n

    for e in edges:
        if e not in K.simplices:
            datum = classify_insertion(K, e)
            K = SimplicialComplex(K.simplices | {e})
            if datum.event == TropicalEvent.BIRTH:
                dim_births[1] += 1
            else:
                dim_deaths[1] += 1

    for t in triangles:
        if t not in K.simplices:
            datum = classify_insertion(K, t)
            K = SimplicialComplex(K.simplices | {t})
            if datum.event == TropicalEvent.BIRTH:
                dim_births[2] += 1
            else:
                dim_deaths[2] += 1

    for d in range(3):
        birth_counts[d].append(dim_births[d])
        death_counts[d].append(dim_deaths[d])
        total = dim_births[d] + dim_deaths[d]
        birth_fracs[d].append(dim_births[d] / total if total > 0 else 0)


# ─── Plot ───

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Birth/Death counts by dimension
ax1 = axes[0]
dims = [0, 1, 2]
avg_births = [np.mean(birth_counts[d]) for d in dims]
avg_deaths = [np.mean(death_counts[d]) for d in dims]
x = np.arange(3)
width = 0.35
bars1 = ax1.bar(x - width/2, avg_births, width, label='Births', color='#4CAF50', alpha=0.8)
bars2 = ax1.bar(x + width/2, avg_deaths, width, label='Deaths', color='#F44336', alpha=0.8)
ax1.set_xlabel('Simplex Dimension', fontsize=12)
ax1.set_ylabel('Average Count', fontsize=12)
ax1.set_title('Events by Dimension', fontsize=13, fontweight='bold')
ax1.set_xticks(x)
ax1.set_xticklabels(['d=0\n(vertices)', 'd=1\n(edges)', 'd=2\n(triangles)'])
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3, axis='y')

# Panel 2: Birth fraction heatmap
ax2 = axes[1]
data = np.array([[np.mean(birth_fracs[d]) for d in range(3)]] * 1)
im = ax2.imshow([[np.mean(birth_fracs[d]) for d in range(3)]],
                cmap='RdYlGn', vmin=0, vmax=1, aspect='auto')
ax2.set_xticks(range(3))
ax2.set_xticklabels(['d=0', 'd=1', 'd=2'])
ax2.set_yticks([])
ax2.set_title('Birth Fraction', fontsize=13, fontweight='bold')

for d in range(3):
    val = np.mean(birth_fracs[d])
    ax2.text(d, 0, f'{val:.2f}', ha='center', va='center', fontsize=14, fontweight='bold')

plt.colorbar(im, ax=ax2, label='Fraction of births')

# Panel 3: Scatter plot of births vs deaths
ax3 = axes[2]
colors = ['#2196F3', '#FF5722', '#4CAF50']
for d in range(3):
    if birth_counts[d] and death_counts[d]:
        ax3.scatter(birth_counts[d], death_counts[d], c=colors[d], s=60,
                    label=f'dim {d}', alpha=0.7, edgecolors='black', linewidth=0.5)

max_val = max(max(max(birth_counts[d]) for d in range(3)),
              max(max(death_counts[d]) for d in range(3) if death_counts[d]))
ax3.plot([0, max_val], [0, max_val], 'k--', alpha=0.3, label='births = deaths')
ax3.set_xlabel('Births', fontsize=12)
ax3.set_ylabel('Deaths', fontsize=12)
ax3.set_title('Birth vs Death Count', fontsize=13, fontweight='bold')
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)
ax3.set_aspect('equal')

plt.suptitle('Simplex Insertion Dichotomy: Every Insertion is Birth or Death',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_dichotomy.png', dpi=150, bbox_inches='tight')
print("Saved viz_dichotomy.png")
