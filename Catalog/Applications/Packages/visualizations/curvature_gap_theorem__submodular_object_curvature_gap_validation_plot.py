#!/usr/bin/env python3
"""
Visualization: Curvature-Gap Theorem
======================================

Produces a 2x2 panel figure illustrating:
1. Curvature vs approximation ratio across random instances
2. Theoretical bound d/(1-κ) vs empirical ratio
3. Distribution of curvature values by modular fraction α
4. Tightness of the bound as a function of curvature

Uses matplotlib to produce a publication-quality figure.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import random
import math


def run_experiments():
    """Generate experiment data."""
    random.seed(42)
    results = []

    for _ in range(300):
        n = random.choice([8, 10, 12])
        d_max = random.randint(3, 5)
        alpha = random.uniform(0.05, 0.95)
        num_items = random.randint(8, 15)

        # Random submodular function: α·modular + (1-α)·coverage
        vertex_w = [random.uniform(0.5, 3.0) for _ in range(n)]
        items = [(random.uniform(0.5, 3.0),
                  random.sample(range(n), random.randint(2, min(4, n))))
                 for _ in range(num_items)]

        def f(A, vw=vertex_w, it=items, a=alpha):
            mod = a * sum(vw[v] for v in A)
            cov = (1 - a) * sum(c for c, S in it if A & set(S))
            return mod + cov

        # Generate hypergraph
        m = random.randint(10, 25)
        edges = [random.sample(range(n), random.randint(2, d_max))
                 for _ in range(m)]
        d = max(len(e) for e in edges)

        # Curvature
        V = set(range(n))
        fV = f(V)
        min_ratio = float('inf')
        for v in range(n):
            fv = f({v})
            if fv > 1e-12:
                ratio = (fV - f(V - {v})) / fv
                min_ratio = min(min_ratio, ratio)
        kappa = max(0.0, 1.0 - min_ratio) if min_ratio < float('inf') else 0.0

        if kappa > 0.999:
            continue

        # Fractional solution
        x = [1.0 / d + 0.05] * n
        for _ in range(10):
            for edge in edges:
                s = sum(x[v] for v in edge)
                if s < 1.0:
                    boost = (1.0 - s) / len(edge) + 0.01
                    for v in edge:
                        x[v] = min(1.0, x[v] + boost)

        # Threshold rounding
        S = {v for v in range(n) if x[v] >= 1.0 / d}
        fS = f(S)

        # Exact MLE
        Fx = 0.0
        for mask in range(1 << n):
            A = {v for v in range(n) if mask & (1 << v)}
            prob = 1.0
            for v in range(n):
                prob *= x[v] if v in A else (1.0 - x[v])
            Fx += prob * f(A)

        if Fx > 1e-6:
            ratio = fS / Fx
            bound = d / (1.0 - kappa)
            tightness = ratio / bound
            results.append({
                'kappa': kappa, 'ratio': ratio, 'bound': bound,
                'tightness': tightness, 'd': d, 'alpha': alpha,
            })

    return results


def make_figure(results):
    """Create the 2x2 visualization."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle('Curvature-Gap Theorem: Empirical Validation',
                 fontsize=16, fontweight='bold', y=0.98)

    # Panel 1: Ratio vs Curvature
    ax = axes[0, 0]
    kappas = [r['kappa'] for r in results]
    ratios = [r['ratio'] for r in results]
    bounds = [r['bound'] for r in results]

    ax.scatter(kappas, ratios, alpha=0.4, s=20, c='steelblue', label='Empirical ratio')

    # Plot theoretical bound curve for d=3,4,5
    k_range = [i * 0.01 for i in range(100)]
    for d_val, color in [(3, '#e74c3c'), (4, '#f39c12'), (5, '#2ecc71')]:
        bound_curve = [d_val / (1.0 - k) for k in k_range]
        ax.plot(k_range, bound_curve, '--', color=color, linewidth=1.5,
                label=f'd/(1-κ), d={d_val}', alpha=0.8)

    ax.set_xlabel('Curvature κ', fontsize=12)
    ax.set_ylabel('f(S) / F(x)', fontsize=12)
    ax.set_title('(a) Ratio vs Curvature', fontsize=13)
    ax.legend(fontsize=9, loc='upper left')
    ax.set_xlim(-0.02, 1.0)
    ax.set_ylim(0, max(bounds) * 0.3)

    # Panel 2: Bound vs Empirical
    ax = axes[0, 1]
    ax.scatter(bounds, ratios, alpha=0.4, s=20, c='steelblue')
    max_b = min(max(bounds), 50)
    ax.plot([0, max_b], [0, max_b], 'r--', linewidth=1.5, label='ratio = bound')
    ax.set_xlabel('Theoretical bound d/(1-κ)', fontsize=12)
    ax.set_ylabel('Empirical ratio f(S)/F(x)', fontsize=12)
    ax.set_title('(b) Bound Tightness', fontsize=13)
    ax.set_xlim(0, max_b)
    ax.set_ylim(0, max(ratios) * 1.1)
    ax.legend(fontsize=10)

    # Panel 3: Curvature distribution by alpha
    ax = axes[1, 0]
    alpha_bins = [(0, 0.2), (0.2, 0.4), (0.4, 0.6), (0.6, 0.8), (0.8, 1.0)]
    positions = list(range(len(alpha_bins)))
    data_by_bin = []
    labels = []
    for lo, hi in alpha_bins:
        subset = [r['kappa'] for r in results if lo <= r['alpha'] < hi]
        data_by_bin.append(subset if subset else [0])
        labels.append(f'{lo:.1f}-{hi:.1f}')

    bp = ax.boxplot(data_by_bin, positions=positions, widths=0.6,
                    patch_artist=True)
    for patch in bp['boxes']:
        patch.set_facecolor('lightsteelblue')
    ax.set_xticks(positions)
    ax.set_xticklabels(labels)
    ax.set_xlabel('Modular fraction α', fontsize=12)
    ax.set_ylabel('Curvature κ', fontsize=12)
    ax.set_title('(c) Curvature vs Modular Fraction', fontsize=13)

    # Panel 4: Tightness histogram
    ax = axes[1, 1]
    tightness = [r['tightness'] for r in results]
    ax.hist(tightness, bins=30, color='steelblue', edgecolor='white', alpha=0.8)
    ax.axvline(x=1.0, color='red', linestyle='--', linewidth=1.5,
               label='Perfect tightness')
    ax.set_xlabel('Tightness (ratio / bound)', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('(d) Bound Utilization', fontsize=13)
    ax.legend(fontsize=10)

    plt.tight_layout(rect=[0, 0, 1, 0.96])
    plt.savefig('curvature_gap_visualization.png', dpi=150, bbox_inches='tight')
    print("Figure saved to curvature_gap_visualization.png")


if __name__ == "__main__":
    print("Generating experiments...")
    results = run_experiments()
    print(f"  {len(results)} valid experiments")
    print("Creating visualization...")
    make_figure(results)
