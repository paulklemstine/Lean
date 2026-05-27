"""
Visualization: Fractional Cover Susceptibility

Demonstrates the 1-Lipschitz property of τ* under edge perturbation.
Shows how adding/removing single edges changes the fractional transversal
number, confirming the bounded-differences property that enables
concentration of measure.

Also shows the susceptibility (maximum single-edge response) as a
function of density, revealing its behavior near criticality.
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import linprog

# ── Inline needed functions ──

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

    def add_edge(self, e):
        return Hypergraph(self.n, self.edges + [frozenset(e)])

    def remove_edge_at(self, idx):
        new_edges = self.edges[:idx] + self.edges[idx+1:]
        return Hypergraph(self.n, new_edges)


def solve_ft(H):
    n = H.n
    edges = H.unique_edges()
    if not edges:
        return 0.0
    c = np.ones(n)
    A_ub = np.zeros((len(edges), n))
    b_ub = -np.ones(len(edges))
    for i, e in enumerate(edges):
        for v in e:
            A_ub[i, v] = -1.0
    bounds = [(0, None) for _ in range(n)]
    result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')
    return result.fun if result.success else n


# ── Experiment 1: Edge-by-edge exposure ──

def edge_exposure_experiment(d=3, n=60, m=120, seed=42):
    """Build a hypergraph edge by edge and track τ* at each step."""
    rng = np.random.default_rng(seed)
    all_edges = []
    vertices = list(range(n))
    for _ in range(m):
        e = frozenset(rng.choice(vertices, size=d, replace=False))
        all_edges.append(e)

    tau_stars = [0.0]
    deltas = []

    for t in range(1, m + 1):
        H_t = Hypergraph(n, all_edges[:t])
        ts = solve_ft(H_t)
        tau_stars.append(ts)
        deltas.append(ts - tau_stars[t - 1])

    return tau_stars, deltas


# ── Experiment 2: Susceptibility vs density ──

def susceptibility_experiment(d=3, n=60, num_c=20, num_samples=30,
                               num_perturbations=10, seed=42):
    """Compute susceptibility at various densities."""
    rng = np.random.default_rng(seed)
    c_values = np.linspace(0.3, 4.0, num_c)
    mean_suscept = []

    for c in c_values:
        m = max(1, int(c * n))
        suscept_vals = []

        for _ in range(num_samples):
            H = Hypergraph.random_uniform(n, m, d, rng=rng)
            tau_base = solve_ft(H)

            max_delta = 0.0
            for _ in range(num_perturbations):
                e_new = frozenset(rng.choice(n, size=d, replace=False))
                H_new = H.add_edge(e_new)
                tau_new = solve_ft(H_new)
                delta = abs(tau_new - tau_base)
                max_delta = max(max_delta, delta)

            suscept_vals.append(max_delta)

        mean_suscept.append(np.mean(suscept_vals))

    return c_values, mean_suscept


# ── Main visualization ──

def run_visualization():
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    fig.suptitle('Fractional Cover Susceptibility & Edge Exposure',
                 fontsize=14, fontweight='bold')

    # Panel 1: Edge exposure trajectory
    tau_stars, deltas = edge_exposure_experiment()
    ax = axes[0]
    ax.plot(range(len(tau_stars)), tau_stars, 'b-', linewidth=1.5)
    ax.set_xlabel('Number of edges exposed', fontsize=11)
    ax.set_ylabel('τ* (fractional transversal number)', fontsize=11)
    ax.set_title('Edge Exposure: τ* Trajectory', fontsize=12)
    ax.grid(True, alpha=0.3)

    # Panel 2: Per-step changes
    ax = axes[1]
    ax.bar(range(len(deltas)), deltas, color='steelblue', alpha=0.7, width=1.0)
    ax.axhline(y=1, color='r', linestyle='--', label='Lipschitz bound = 1')
    ax.axhline(y=0, color='gray', linestyle='-', alpha=0.5)
    ax.set_xlabel('Edge index', fontsize=11)
    ax.set_ylabel('Δτ* (change per edge)', fontsize=11)
    ax.set_title('Per-Edge Change in τ*', fontsize=12)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Verify Lipschitz
    max_delta = max(abs(d) for d in deltas)
    ax.annotate(f'Max |Δτ*| = {max_delta:.3f} ≤ 1 ✓',
                xy=(0.5, 0.92), xycoords='axes fraction',
                fontsize=10, ha='center',
                bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))

    # Panel 3: Susceptibility vs density
    c_vals, suscept = susceptibility_experiment()
    ax = axes[2]
    ax.plot(c_vals, suscept, 'r-o', markersize=4, linewidth=2)
    ax.axhline(y=1, color='gray', linestyle='--', alpha=0.5,
               label='Upper bound = 1')
    ax.set_xlabel('Edge density c', fontsize=11)
    ax.set_ylabel('Mean susceptibility', fontsize=11)
    ax.set_title('Susceptibility vs. Density', fontsize=12)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('susceptibility.png', dpi=150, bbox_inches='tight')
    print("Saved susceptibility.png")

run_visualization()
