"""
Visualization: Heatmap of Integrality Gap across (d, K) parameter space

Shows how the empirical integrality gap varies as a function of both
the uniformity d and the pair codegree bound K, revealing the
two-dimensional landscape of overlap-sensitive covering.
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import linprog


def generate_hypergraph(n, d, m, max_codegree=None):
    edges = []
    codeg = np.zeros((n, n), dtype=int)
    attempts = 0
    while len(edges) < m and attempts < m * 100:
        attempts += 1
        verts = set(np.random.choice(n, d, replace=False).tolist())
        if any(verts == set(e) for e in edges):
            continue
        if max_codegree is not None:
            vl = list(verts)
            ok = all(codeg[vl[i], vl[j]] < max_codegree
                     for i in range(len(vl)) for j in range(i+1, len(vl)))
            if not ok:
                continue
        edges.append(verts)
        vl = list(verts)
        for i in range(len(vl)):
            for j in range(i+1, len(vl)):
                codeg[vl[i], vl[j]] += 1
                codeg[vl[j], vl[i]] += 1
    return edges


def solve_lp(n, edges):
    if not edges:
        return np.zeros(n)
    c = np.ones(n)
    A_ub = np.zeros((len(edges), n))
    b_ub = -np.ones(len(edges))
    for i, e in enumerate(edges):
        for v in e:
            A_ub[i, v] = -1.0
    result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=[(0, None)]*n, method='highs')
    return result.x if result.success else None


np.random.seed(42)

d_values = [3, 4, 5, 6, 7]
K_values = [1, 2, 3, 5, 8, 12]
n = 50
trials = 10

gap_matrix = np.zeros((len(d_values), len(K_values)))

for i, d in enumerate(d_values):
    for j, K in enumerate(K_values):
        m = min(80, n * (n-1) // (d * (d-1)))
        gaps = []
        for _ in range(trials):
            edges = generate_hypergraph(n, d, m, max_codegree=K)
            if len(edges) < 5:
                continue
            x = solve_lp(n, edges)
            if x is None or np.sum(x) < 0.1:
                continue
            S = {v for v in range(n) if x[v] >= 1.0/d}
            for e in edges:
                if not S.intersection(e):
                    S.add(min(e))
            gap = len(S) / np.sum(x)
            gaps.append(gap)
        gap_matrix[i, j] = np.mean(gaps) if gaps else d

fig, ax = plt.subplots(figsize=(10, 7))

im = ax.imshow(gap_matrix, cmap='RdYlGn_r', aspect='auto',
               vmin=1.0, vmax=max(d_values))

# Add text annotations
for i in range(len(d_values)):
    for j in range(len(K_values)):
        val = gap_matrix[i, j]
        color = 'white' if val > (d_values[i] + 1) / 2 else 'black'
        ax.text(j, i, f'{val:.2f}', ha='center', va='center',
                color=color, fontsize=11, fontweight='bold')

ax.set_xticks(range(len(K_values)))
ax.set_xticklabels(K_values, fontsize=12)
ax.set_yticks(range(len(d_values)))
ax.set_yticklabels(d_values, fontsize=12)

ax.set_xlabel('Pair Codegree Bound K', fontsize=14)
ax.set_ylabel('Uniformity d', fontsize=14)
ax.set_title('Empirical Integrality Gap τ/τ* across (d, K)\n'
             'Lower values (green) = better covering efficiency',
             fontsize=14)

cbar = plt.colorbar(im, ax=ax, shrink=0.8)
cbar.set_label('Gap Ratio τ/τ*', fontsize=12)

# Add classical bound annotations
for i, d in enumerate(d_values):
    ax.text(len(K_values) - 0.3, i, f'←d={d}', ha='left', va='center',
            fontsize=9, color='#666', style='italic')

plt.tight_layout()
plt.savefig('gap_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved gap_heatmap.png")
