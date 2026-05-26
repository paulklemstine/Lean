"""
Visualization 3: Phase Diagram — Gap, Defect, and Susceptibility

Visualizes the "thermodynamic" observables of random hypergraph transversals:
- Fractional cover density (energy density)
- Rounding defect (order parameter)
- Gap variance (susceptibility)

Shows the statistical-physics interpretation: the system undergoes a crossover
from a "dilute phase" (few constraints, easy covering) to a "dense phase"
(many constraints, harder covering), with response functions peaking in between.
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


rng = np.random.default_rng(42)

# Multi-d comparison
fig, axes = plt.subplots(2, 3, figsize=(16, 10))

for d_idx, d in enumerate([3, 4, 5]):
    n = 60
    c_values = np.linspace(0.2, 4.0, 20)
    num_samples = 30

    densities = []
    defects = []
    susceptibilities = []

    for c in c_values:
        m = max(1, int(c * n))
        gaps = []
        frac_densities = []
        round_defects = []

        for _ in range(num_samples):
            edges = random_uniform_hypergraph(n, m, d, rng)
            frac_opt, x = solve_fractional_lp(n, edges)
            if frac_opt < 1e-10:
                continue
            S_g = greedy_transversal(n, edges)
            gap = len(S_g) / frac_opt
            gaps.append(gap)
            frac_densities.append(frac_opt / n)
            round_defects.append((len(S_g) - frac_opt) / n)

        densities.append(np.mean(frac_densities) if frac_densities else 0)
        defects.append(np.mean(round_defects) if round_defects else 0)
        susceptibilities.append(np.var(gaps) if gaps else 0)

    # Energy density
    ax = axes[0, d_idx]
    ax.plot(c_values, densities, 'b-o', markersize=4, linewidth=2)
    ax.set_xlabel('c = m/n')
    ax.set_ylabel('τ*/n (fractional density)')
    ax.set_title(f'd = {d}: Cover Density ("Energy")')
    ax.grid(True, alpha=0.3)

    # Order parameter + susceptibility
    ax2 = axes[1, d_idx]
    l1, = ax2.plot(c_values, defects, 'g-o', markersize=4, linewidth=2,
                    label='Defect (τ-τ*)/n')
    ax2_twin = ax2.twinx()
    l2, = ax2_twin.plot(c_values, susceptibilities, 'r-s', markersize=4,
                         linewidth=2, label='Susceptibility')
    ax2.set_xlabel('c = m/n')
    ax2.set_ylabel('Normalized defect', color='green')
    ax2_twin.set_ylabel('Var(gap)', color='red')
    ax2.set_title(f'd = {d}: Defect & Susceptibility')
    ax2.legend(handles=[l1, l2], loc='upper left', fontsize=8)
    ax2.grid(True, alpha=0.3)

plt.suptitle('Phase Diagram: Thermodynamic Observables of Random Transversals',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_phase_diagram.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_phase_diagram.png")
