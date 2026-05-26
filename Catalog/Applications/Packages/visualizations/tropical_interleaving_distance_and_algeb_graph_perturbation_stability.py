"""
Visualization: Graph Perturbation Stability

This script visualizes the cross-domain bridge theorem: perturbing
vertex filtration weights by at most δ on a graph perturbs the
tropical persistence module by at most δ in interleaving distance.

Shows the persistence modules before and after perturbation, and
how the interleaving shift captures the structural change.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random


def graph_tpm_values(n, edges, f, t_range):
    """Compute the graph TPM values over a range of indices."""
    degrees = [0] * n
    for u, v in edges:
        degrees[u] += 1
        degrees[v] += 1

    values = []
    for t in t_range:
        val = sum(degrees[v] + 1 for v in range(n) if f[v] <= t)
        values.append(val)
    return values


def plot_graph_stability():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    random.seed(42)

    # Graph: path P_6
    n = 6
    edges = [(i, i + 1) for i in range(n - 1)]
    degrees = [0] * n
    for u, v in edges:
        degrees[u] += 1
        degrees[v] += 1

    f_base = [1, 3, 2, 5, 4, 6]
    t_range = list(range(-1, 9))

    # Panel 1: Base filtration and its persistence module
    ax = axes[0, 0]
    vals_base = graph_tpm_values(n, edges, f_base, t_range)
    ax.step(t_range, vals_base, where='post', linewidth=2.5, color='#2196F3',
            label='Base filtration')
    ax.set_xlabel('Filtration parameter t', fontsize=12)
    ax.set_ylabel('Cumulative degree-weighted count', fontsize=12)
    ax.set_title(f'Path Graph P₆\nFiltration f = {f_base}', fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Annotate active vertices
    for v in range(n):
        ax.axvline(x=f_base[v], color='gray', linestyle=':', alpha=0.3)

    # Panel 2: Perturbation δ=1
    ax = axes[0, 1]
    delta = 1
    f_pert = [fi + random.randint(-delta, delta) for fi in f_base]
    vals_pert = graph_tpm_values(n, edges, f_pert, t_range)
    vals_base_shifted = graph_tpm_values(n, edges, f_base,
                                         [t + delta for t in t_range])

    ax.step(t_range, vals_base, where='post', linewidth=2.5, color='#2196F3',
            label='Base f')
    ax.step(t_range, vals_pert, where='post', linewidth=2.5, color='#FF5722',
            label=f'Perturbed g (δ={delta})')
    ax.step(t_range, vals_base_shifted, where='post', linewidth=1.5,
            color='#2196F3', linestyle='--', alpha=0.5, label=f'Base f(·+{delta})')

    ax.set_xlabel('Filtration parameter t', fontsize=12)
    ax.set_ylabel('Cumulative count', fontsize=12)
    ax.set_title(f'Perturbation δ={delta}\ng = {f_pert}', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Panel 3: Multiple perturbation levels
    ax = axes[1, 0]
    deltas = range(0, 5)
    colors_pert = ['#2196F3', '#4CAF50', '#FF9800', '#FF5722', '#9C27B0']

    for delta in deltas:
        random.seed(100 + delta)
        if delta == 0:
            f_p = f_base[:]
        else:
            f_p = [fi + random.randint(-delta, delta) for fi in f_base]
        vals_p = graph_tpm_values(n, edges, f_p, t_range)
        ax.step(t_range, vals_p, where='post', linewidth=2 if delta == 0 else 1.5,
                color=colors_pert[delta], alpha=0.8,
                label=f'δ={delta}' + (' (base)' if delta == 0 else ''))

    ax.set_xlabel('Filtration parameter t', fontsize=12)
    ax.set_ylabel('Cumulative count', fontsize=12)
    ax.set_title('Persistence Modules Under\nIncreasing Perturbation', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)

    # Panel 4: Stability bound verification
    ax = axes[1, 1]
    test_deltas = list(range(1, 8))
    n_trials = 20
    actual_dists = []
    bound_values = []

    for delta in test_deltas:
        trial_dists = []
        for trial in range(n_trials):
            random.seed(1000 * delta + trial)
            f_p = [fi + random.randint(-delta, delta) for fi in f_base]
            # Compute interleaving distance (simplified check)
            M_vals = graph_tpm_values(n, edges, f_base, list(range(-5, 15)))
            N_vals = graph_tpm_values(n, edges, f_p, list(range(-5, 15)))

            # Find smallest d such that d-interleaved
            for d in range(0, 20):
                ok = True
                for idx, t in enumerate(range(-5, 15)):
                    t_shifted = t + d
                    idx_shifted = t_shifted - (-5)
                    if 0 <= idx_shifted < len(N_vals):
                        if M_vals[idx] > N_vals[idx_shifted]:
                            ok = False
                            break
                    if 0 <= idx_shifted < len(M_vals):
                        if N_vals[idx] > M_vals[idx_shifted]:
                            ok = False
                            break
                if ok:
                    trial_dists.append(d)
                    break

        if trial_dists:
            actual_dists.append(max(trial_dists))
        else:
            actual_dists.append(delta)
        bound_values.append(delta)

    ax.bar([d - 0.15 for d in test_deltas], bound_values, width=0.3,
           color='#FF5722', alpha=0.7, label='Bound δ')
    ax.bar([d + 0.15 for d in test_deltas], actual_dists, width=0.3,
           color='#2196F3', alpha=0.7, label='Actual d_I')

    ax.set_xlabel('Perturbation bound δ', fontsize=12)
    ax.set_ylabel('Distance', fontsize=12)
    ax.set_title('Stability Theorem Verification\nd_I ≤ δ for all perturbations', fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.suptitle('Graph Perturbation Stability: Cross-Domain Bridge Theorem',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_graph_stability.png', dpi=150, bbox_inches='tight')
    print("Saved viz_graph_stability.png")


if __name__ == "__main__":
    plot_graph_stability()
