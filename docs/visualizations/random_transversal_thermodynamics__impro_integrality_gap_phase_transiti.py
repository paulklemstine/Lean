"""
Visualization: Integrality Gap Phase Transition

Visualizes the core prediction of random transversal thermodynamics:
the integrality gap ratio τ/τ* as a function of edge density c
for random d-uniform hypergraphs. Shows that the gap peaks at an
intermediate critical density and is strictly sub-d away from it.

The top panel shows mean gap vs. density with the worst-case bound d.
The bottom panel shows gap variance, which peaks near criticality.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from scipy.optimize import linprog

# ── Inline all needed functions ──

class Hypergraph:
    def __init__(self, n, edges):
        self.n = n
        self.edges = [frozenset(e) for e in edges]

    @staticmethod
    def random_uniform(n, m, d, rng=None):
        if rng is None:
            rng = np.random.default_rng()
        edges = []
        vertices = list(range(n))
        for _ in range(m):
            e = frozenset(rng.choice(vertices, size=d, replace=False))
            edges.append(e)
        return Hypergraph(n, edges)

    def unique_edges(self):
        return list(set(self.edges))


def solve_fractional_transversal(H):
    n = H.n
    edges = H.unique_edges()
    if not edges:
        return np.zeros(n), 0.0
    c = np.ones(n)
    A_ub = np.zeros((len(edges), n))
    b_ub = -np.ones(len(edges))
    for i, e in enumerate(edges):
        for v in e:
            A_ub[i, v] = -1.0
    bounds = [(0, None) for _ in range(n)]
    result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')
    if result.success:
        return result.x, result.fun
    else:
        d_max = max(len(e) for e in edges)
        x = np.full(n, 1.0 / d_max)
        return x, n / d_max


def compute_overlap_profile(H):
    codeg = {}
    for e in H.unique_edges():
        for u, v in combinations(sorted(e), 2):
            codeg[(u, v)] = codeg.get((u, v), 0) + 1
    if not codeg:
        return {'max_pair_codegree': 0, 'mean_pair_codegree': 0.0,
                'num_high_overlap_pairs': 0}
    vals = list(codeg.values())
    return {
        'max_pair_codegree': max(vals),
        'mean_pair_codegree': np.mean(vals),
        'num_high_overlap_pairs': sum(1 for v in vals if v > 1)
    }


def threshold_round(x, theta):
    return set(int(v) for v in np.where(x >= theta)[0])


def greedy_repair(H, S):
    S = set(S)
    for e in H.unique_edges():
        if not S & e:
            S.add(min(e))
    return S


def low_overlap_round(H, x, overlap_stats):
    edges = H.unique_edges()
    d = max(len(e) for e in edges) if edges else 1
    max_codeg = overlap_stats.get('max_pair_codegree', d)
    theta = 1.0 / d + (0.5 / (d * d) if max_codeg <= 1 and d >= 2 else 0)
    S_initial = threshold_round(x, theta)
    S_final = greedy_repair(H, S_initial)
    return S_final


# ── Main visualization ──

def run_visualization():
    d = 3
    n = 100
    num_samples = 100
    c_values = np.linspace(0.1, 5.0, 30)
    rng = np.random.default_rng(42)

    mean_gaps = []
    var_gaps = []
    mean_overlaps = []
    mean_defects = []

    for c in c_values:
        m = max(1, int(np.floor(c * n)))
        gaps = []
        overlaps = []
        defects = []

        for _ in range(num_samples):
            H = Hypergraph.random_uniform(n, m, d, rng=rng)
            x_opt, tau_star = solve_fractional_transversal(H)
            overlap = compute_overlap_profile(H)
            S = low_overlap_round(H, x_opt, overlap)
            tau_int = len(S)

            gap = tau_int / tau_star if tau_star > 1e-10 else 1.0
            gaps.append(gap)
            overlaps.append(overlap['max_pair_codegree'])
            defects.append((tau_int - tau_star) / n)

        mean_gaps.append(np.mean(gaps))
        var_gaps.append(np.var(gaps))
        mean_overlaps.append(np.mean(overlaps))
        mean_defects.append(np.mean(defects))

    # Plot
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle(f'Random Transversal Thermodynamics: d={d}, n={n}',
                 fontsize=14, fontweight='bold')

    # Panel 1: Mean gap vs c
    ax = axes[0, 0]
    ax.plot(c_values, mean_gaps, 'b-o', markersize=4, linewidth=2,
            label='Mean τ/τ*')
    ax.axhline(y=d, color='r', linestyle='--', linewidth=1.5,
               label=f'Worst-case bound d={d}')
    ax.axhline(y=1, color='green', linestyle=':', linewidth=1,
               label='Optimal gap = 1')
    peak_idx = np.argmax(mean_gaps)
    ax.axvline(x=c_values[peak_idx], color='orange', linestyle='-.',
               alpha=0.7, label=f'Peak at c≈{c_values[peak_idx]:.1f}')
    ax.set_xlabel('Edge density c (m = ⌊cn⌋)', fontsize=11)
    ax.set_ylabel('Mean integrality gap τ/τ*', fontsize=11)
    ax.set_title('Integrality Gap vs. Density', fontsize=12)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel 2: Gap variance vs c
    ax = axes[0, 1]
    ax.plot(c_values, var_gaps, 'r-s', markersize=4, linewidth=2)
    ax.axvline(x=c_values[peak_idx], color='orange', linestyle='-.',
               alpha=0.7, label=f'Gap peak at c≈{c_values[peak_idx]:.1f}')
    ax.set_xlabel('Edge density c', fontsize=11)
    ax.set_ylabel('Var(τ/τ*)', fontsize=11)
    ax.set_title('Gap Variance (Susceptibility Proxy)', fontsize=12)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel 3: Overlap profile vs c
    ax = axes[1, 0]
    ax.plot(c_values, mean_overlaps, 'g-^', markersize=4, linewidth=2)
    ax.set_xlabel('Edge density c', fontsize=11)
    ax.set_ylabel('Mean max pair codegree', fontsize=11)
    ax.set_title('Overlap Profile vs. Density', fontsize=12)
    ax.grid(True, alpha=0.3)

    # Panel 4: Normalized rounding defect
    ax = axes[1, 1]
    ax.plot(c_values, mean_defects, 'm-D', markersize=4, linewidth=2)
    ax.set_xlabel('Edge density c', fontsize=11)
    ax.set_ylabel('Mean (τ - τ*) / n', fontsize=11)
    ax.set_title('Normalized Rounding Defect', fontsize=12)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('gap_phase_transition.png', dpi=150, bbox_inches='tight')
    print("Saved gap_phase_transition.png")

run_visualization()
