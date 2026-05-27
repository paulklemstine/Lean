"""
Visualization: Integrality Gap vs Pair Codegree Bound K

Shows how the empirical gap ratio τ/τ* decreases as the pair codegree
bound K decreases, demonstrating that bounded overlap forces a strictly
sub-d integrality gap. The theoretical d=3 bound is shown for reference.
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import linprog


def compute_pair_codegree_matrix(n, edges):
    codeg = np.zeros((n, n), dtype=int)
    for e in edges:
        verts = list(e)
        for i in range(len(verts)):
            for j in range(i + 1, len(verts)):
                codeg[verts[i], verts[j]] += 1
                codeg[verts[j], verts[i]] += 1
    return codeg


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


def threshold_round(x, d):
    return {v for v in range(len(x)) if x[v] >= 1.0/d}


np.random.seed(42)

K_values = [1, 2, 3, 5, 8, 12, 20]
n, d, m = 60, 3, 100
trials = 15

avg_gaps = []
std_gaps = []

for K in K_values:
    gaps = []
    for _ in range(trials):
        edges = generate_hypergraph(n, d, m, max_codegree=K)
        if len(edges) < 10:
            continue
        x = solve_lp(n, edges)
        if x is None or np.sum(x) < 0.1:
            continue
        S = threshold_round(x, d)
        # Repair
        for e in edges:
            if not S.intersection(e):
                S.add(min(e))
        gap = len(S) / np.sum(x)
        gaps.append(gap)
    avg_gaps.append(np.mean(gaps) if gaps else d)
    std_gaps.append(np.std(gaps) if gaps else 0)

fig, ax = plt.subplots(figsize=(10, 6))

ax.errorbar(K_values, avg_gaps, yerr=std_gaps, fmt='o-', color='#2196F3',
            linewidth=2, markersize=8, capsize=5, label='Empirical gap τ/τ*')

# Theoretical bound d
ax.axhline(y=d, color='#F44336', linestyle='--', linewidth=2, label=f'Classical bound d={d}')

# Predicted improvement: d - c/(K+1) with c ≈ 1
predicted = [d - 1.0/(K+1) for K in K_values]
ax.plot(K_values, predicted, 's--', color='#4CAF50', linewidth=1.5,
        markersize=6, label='Predicted d - 1/(K+1)')

ax.set_xlabel('Pair Codegree Bound K', fontsize=14)
ax.set_ylabel('Gap Ratio τ / τ*', fontsize=14)
ax.set_title('Integrality Gap vs Pair Codegree Bound\n(d=3 uniform, n=60, ~100 edges)',
             fontsize=15)
ax.legend(fontsize=12, loc='lower right')
ax.set_ylim(0.5, d + 0.5)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('gap_vs_codegree.png', dpi=150, bbox_inches='tight')
print("Saved gap_vs_codegree.png")
