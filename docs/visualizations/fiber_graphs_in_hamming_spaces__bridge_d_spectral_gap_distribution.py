#!/usr/bin/env python3
"""
Visualization: Spectral Gap Distribution

Plots the distribution of spectral gaps across random weight systems,
testing the Fiber Expansion Conjecture.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product


def score(weights, config):
    return sum(weights[i][config[i]] for i in range(len(config)))


def hamming_dist(x, y):
    return sum(1 for a, b in zip(x, y) if a != b)


def compute_spectral_gap(weights, target_score):
    n = len(weights)
    q = len(weights[0])
    configs = list(product(range(q), repeat=n))
    fiber = [c for c in configs if score(weights, c) == target_score]
    m = len(fiber)
    if m < 2:
        return None

    adj = np.zeros((m, m))
    for i in range(m):
        for j in range(i + 1, m):
            if hamming_dist(fiber[i], fiber[j]) == 1:
                adj[i][j] = 1
                adj[j][i] = 1

    degrees = adj.sum(axis=1)
    if np.any(degrees == 0):
        return 0.0

    d_inv_sqrt = np.diag(1.0 / np.sqrt(degrees))
    laplacian = np.eye(m) - d_inv_sqrt @ adj @ d_inv_sqrt
    eigenvalues = np.sort(np.linalg.eigvalsh(laplacian))
    return float(eigenvalues[1]) if len(eigenvalues) > 1 else None


def random_pos_sep_weights(n, q, low=-15, high=15):
    weights = []
    for _ in range(n):
        vals = np.random.choice(range(low, high + 1), size=q, replace=False)
        weights.append(list(vals))
    return weights


def main():
    np.random.seed(42)
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle('Spectral Gap Distribution (Testing Expansion Conjecture)',
                 fontsize=14, fontweight='bold')

    for ax_idx, n in enumerate([3, 4, 5]):
        q = 3
        gaps = []
        num_trials = 30

        for _ in range(num_trials):
            weights = random_pos_sep_weights(n, q)
            scores_all = {}
            for c in product(range(q), repeat=n):
                s = score(weights, c)
                scores_all[s] = scores_all.get(s, 0) + 1

            for s, count in scores_all.items():
                if count >= 3:
                    gap = compute_spectral_gap(weights, s)
                    if gap is not None and gap > 1e-10:
                        gaps.append(gap)

        ax = axes[ax_idx]
        if gaps:
            ax.hist(gaps, bins=20, color='steelblue', edgecolor='black', alpha=0.7)
            predicted = 0.5 / n
            ax.axvline(predicted, color='red', linestyle='--', linewidth=2,
                      label=f'Predicted lower bound (0.5/{n})')
            ax.set_xlabel('Spectral Gap λ₂')
            ax.set_ylabel('Frequency')
            ax.set_title(f'n={n}, q={q} ({len(gaps)} fibers)')
            ax.legend(fontsize=8)
        else:
            ax.text(0.5, 0.5, 'No non-trivial fibers found',
                   ha='center', va='center', transform=ax.transAxes)
            ax.set_title(f'n={n}, q={q}')

    plt.tight_layout()
    plt.savefig('spectral_gap_distribution.png', dpi=150, bbox_inches='tight')
    print("Saved spectral_gap_distribution.png")


if __name__ == "__main__":
    main()
