"""
Visualization 1: Tropical Morse Filtration — Betti Number Evolution

Visualizes how Betti numbers β₀, β₁, β₂ evolve through a simplex filtration,
with tropical birth/death events marked as vertical lines.

Shows the core theorem in action: tropical event accounting (births minus deaths)
exactly reconstructs the classical Betti number trajectory.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random
import itertools
import math
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
    if not matrix or not matrix[0]:
        return 0
    m = [row[:] for row in matrix]
    rows, cols = len(m), len(m[0])
    rank = 0
    for col in range(cols):
        pivot = None
        for row in range(rank, rows):
            if m[row][col] % 2 == 1:
                pivot = row
                break
        if pivot is None:
            continue
        m[rank], m[pivot] = m[pivot], m[rank]
        for row in range(rows):
            if row != rank and m[row][col] % 2 == 1:
                m[row] = [(m[row][c] + m[rank][c]) % 2 for c in range(cols)]
        rank += 1
    return rank

def boundary_matrix_z2(K, d):
    d_simps = sorted(K.d_simplices(d), key=lambda s: tuple(sorted(s)))
    d1_simps = sorted(K.d_simplices(d - 1), key=lambda s: tuple(sorted(s)))
    if not d_simps or not d1_simps:
        return [], d_simps, d1_simps
    d1_index = {s: i for i, s in enumerate(d1_simps)}
    matrix = [[0] * len(d_simps) for _ in range(len(d1_simps))]
    for j, sigma in enumerate(d_simps):
        for v in sigma:
            face = sigma - {v}
            if face in d1_index:
                matrix[d1_index[face]][j] = 1
    return matrix, d_simps, d1_simps

def compute_betti(K, max_dim=2):
    betti = {}
    ranks = {}
    for d in range(max_dim + 2):
        mat, _, _ = boundary_matrix_z2(K, d)
        ranks[d] = z2_rank(mat)
    for d in range(max_dim + 1):
        n_d = len(K.d_simplices(d))
        betti[d] = n_d - ranks.get(d, 0) - ranks.get(d + 1, 0)
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


# ─── Build filtration ───

random.seed(42)
n = 15
positions = [(random.uniform(0, 10), random.uniform(0, 10)) for _ in range(n)]

dists = {}
for i, j in itertools.combinations(range(n), 2):
    dists[(i,j)] = math.sqrt((positions[i][0]-positions[j][0])**2 +
                              (positions[i][1]-positions[j][1])**2)

# Sort edges by distance
sorted_edges = sorted(dists.items(), key=lambda x: x[1])

K = SimplicialComplex({frozenset({v}) for v in range(n)})
steps_x = [0]
betti_history = {0: [n], 1: [0], 2: [0]}
events = []
weights = [0]

step = 0
for (i, j), d in sorted_edges:
    e = frozenset({i, j})
    if e in K.simplices:
        continue
    datum = classify_insertion(K, e)
    K = SimplicialComplex(K.simplices | {e})

    # Check for triangles
    for k in range(n):
        t = frozenset({i, j, k})
        if len(t) == 3 and all(frozenset({a, b}) in K.simplices
                                for a, b in itertools.combinations(t, 2)):
            if t not in K.simplices:
                tdatum = classify_insertion(K, t)
                K = SimplicialComplex(K.simplices | {t})
                step += 1
                betti = compute_betti(K, 2)
                steps_x.append(step)
                weights.append(d)
                for dd in range(3):
                    betti_history[dd].append(betti.get(dd, 0))
                events.append((step, d, tdatum, 2))

    step += 1
    betti = compute_betti(K, 2)
    steps_x.append(step)
    weights.append(d)
    for dd in range(3):
        betti_history[dd].append(betti.get(dd, 0))
    events.append((step, d, datum, 1))


# ─── Plot ───

fig, axes = plt.subplots(2, 1, figsize=(14, 8), gridspec_kw={'height_ratios': [3, 1]})

# Top panel: Betti numbers
ax1 = axes[0]
colors = ['#2196F3', '#FF5722', '#4CAF50']
labels = ['β₀ (components)', 'β₁ (loops)', 'β₂ (voids)']

for d in range(3):
    ax1.step(steps_x, betti_history[d], where='post', color=colors[d],
             linewidth=2, label=labels[d])

# Mark birth/death events
for step_i, w, datum, dim in events:
    if datum.event == TropicalEvent.BIRTH:
        ax1.axvline(x=step_i, color=colors[datum.degree], alpha=0.15, linewidth=1)
    else:
        ax1.axvline(x=step_i, color=colors[datum.degree-1] if datum.degree > 0 else colors[0],
                    alpha=0.15, linewidth=1, linestyle='--')

ax1.set_xlabel('Filtration Step', fontsize=12)
ax1.set_ylabel('Betti Number', fontsize=12)
ax1.set_title('Tropical Morse Filtration: Betti Number Evolution', fontsize=14, fontweight='bold')
ax1.legend(loc='upper right', fontsize=11)
ax1.grid(True, alpha=0.3)
ax1.set_xlim(0, max(steps_x))

# Bottom panel: Event timeline
ax2 = axes[1]
birth_steps = [s for s, w, d, dim in events if d.event == TropicalEvent.BIRTH]
death_steps = [s for s, w, d, dim in events if d.event == TropicalEvent.DEATH]
birth_degs = [d.degree for s, w, d, dim in events if d.event == TropicalEvent.BIRTH]
death_degs = [d.degree for s, w, d, dim in events if d.event == TropicalEvent.DEATH]

ax2.scatter(birth_steps, [1]*len(birth_steps), c=[colors[d] for d in birth_degs],
            marker='^', s=60, label='Birth', zorder=5, edgecolors='black', linewidth=0.5)
ax2.scatter(death_steps, [0]*len(death_steps), c=[colors[min(d-1,0)] for d in death_degs],
            marker='v', s=60, label='Death', zorder=5, edgecolors='black', linewidth=0.5)

ax2.set_xlabel('Filtration Step', fontsize=12)
ax2.set_ylabel('Event Type', fontsize=12)
ax2.set_yticks([0, 1])
ax2.set_yticklabels(['Death', 'Birth'])
ax2.set_title('Tropical Event Timeline', fontsize=12)
ax2.legend(loc='upper right', fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(0, max(steps_x))

plt.tight_layout()
plt.savefig('viz_filtration.png', dpi=150, bbox_inches='tight')
print("Saved viz_filtration.png")
