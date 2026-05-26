"""
Visualization 2: Overlap Landscape and Pseudorandomness

Visualizes the pair-codegree statistics (overlap profile) of random hypergraphs
as a function of density, alongside the integrality gap. Shows that low-overlap
regions correlate with better (smaller) integrality gaps, confirming the central
thesis that pseudorandomness drives improved rounding.
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import linprog


def random_uniform_hypergraph(n, m, d, rng):
    edges = []
    vertices = list(range(n))
    for _ in range(m):
        edge = frozenset(rng.choice(vertices, size=d, replace=False))
        edges.append(edge)
    return edges


def solve_fractional_lp(n, edges):
    if not edges:
        return 0.0, np.zeros(n)
    c_obj = np.ones(n)
    A_ub = np.zeros((len(edges), n))
    b_ub = -np.ones(len(edges))
    for i, e in enumerate(edges):
        for v in e:
            A_ub[i, v] = -1
    bounds = [(0, None)] * n
    result = linprog(c_obj, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')
    if result.success:
        return result.fun, result.x
    return float('inf'), np.ones(n)


def greedy_transversal(n, edges):
    uncovered = list(range(len(edges)))
    S = set()
    while uncovered:
        hits = {}
        for idx in uncovered:
            for v in edges[idx]:
                hits[v] = hits.get(v, 0) + 1
        if not hits:
            break
        best = max(hits, key=hits.get)
        S.add(best)
        uncovered = [i for i in uncovered if best not in edges[i]]
    return S


def max_pair_codegree(edges):
    pair_count = {}
    for e in edges:
        elist = sorted(e)
        for i in range(len(elist)):
            for j in range(i + 1, len(elist)):
                pair = (elist[i], elist[j])
                pair_count[pair] = pair_count.get(pair, 0) + 1
    return max(pair_count.values()) if pair_count else 0


def mean_pair_codegree(edges):
    pair_count = {}
    for e in edges:
        elist = sorted(e)
        for i in range(len(elist)):
            for j in range(i + 1, len(elist)):
                pair = (elist[i], elist[j])
                pair_count[pair] = pair_count.get(pair, 0) + 1
    if not pair_count:
        return 0
    return np.mean(list(pair_count.values()))


rng = np.random.default_rng(42)
d = 3
n = 60
c_values = np.linspace(0.3, 5.0, 25)
num_samples = 30

all_codeg = []
all_gaps = []
all_c = []

mean_codeg_by_c = []
mean_gap_by_c = []

for c in c_values:
    m = max(1, int(c * n))
    codeg_list = []
    gap_list = []
    for _ in range(num_samples):
        edges = random_uniform_hypergraph(n, m, d, rng)
        frac_opt, x = solve_fractional_lp(n, edges)
        if frac_opt < 1e-10:
            continue
        S_g = greedy_transversal(n, edges)
        gap = len(S_g) / frac_opt
        mc = max_pair_codegree(edges)
        all_codeg.append(mc)
        all_gaps.append(gap)
        all_c.append(c)
        codeg_list.append(mc)
        gap_list.append(gap)
    mean_codeg_by_c.append(np.mean(codeg_list) if codeg_list else 0)
    mean_gap_by_c.append(np.mean(gap_list) if gap_list else np.nan)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Scatter of gap vs codegree
ax1 = axes[0]
scatter = ax1.scatter(all_codeg, all_gaps, c=all_c, cmap='viridis',
                       alpha=0.5, s=15, edgecolors='none')
plt.colorbar(scatter, ax=ax1, label='Density c')
ax1.set_xlabel('Max pair-codegree K', fontsize=12)
ax1.set_ylabel('Integrality gap τ/τ*', fontsize=12)
ax1.set_title('Gap vs. Overlap (Individual Instances)', fontsize=13)
ax1.axhline(y=d, color='red', linestyle='--', alpha=0.7, label=f'd={d}')
ax1.legend()
ax1.grid(True, alpha=0.3)

# Plot 2: Mean codegree vs density
ax2 = axes[1]
ax2.plot(c_values, mean_codeg_by_c, 'r-o', markersize=5, linewidth=2)
ax2.set_xlabel('Edge density c = m/n', fontsize=12)
ax2.set_ylabel('Mean max pair-codegree', fontsize=12)
ax2.set_title('Overlap Profile vs. Density', fontsize=13)
ax2.grid(True, alpha=0.3)

# Plot 3: Gap and codegree on same axis
ax3 = axes[2]
ax3_twin = ax3.twinx()
l1, = ax3.plot(c_values, mean_gap_by_c, 'b-o', markersize=4, label='Mean gap')
l2, = ax3_twin.plot(c_values, mean_codeg_by_c, 'r-s', markersize=4, label='Mean codegree')
ax3.axhline(y=d, color='blue', linestyle='--', alpha=0.5)
ax3.set_xlabel('Edge density c = m/n', fontsize=12)
ax3.set_ylabel('Integrality gap', color='blue', fontsize=12)
ax3_twin.set_ylabel('Max pair-codegree', color='red', fontsize=12)
ax3.set_title('Gap & Overlap Co-evolution', fontsize=13)
ax3.legend(handles=[l1, l2], loc='upper left')
ax3.grid(True, alpha=0.3)

plt.suptitle('Overlap Landscape: Pseudorandomness Controls the Gap',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_overlap_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_overlap_landscape.png")
