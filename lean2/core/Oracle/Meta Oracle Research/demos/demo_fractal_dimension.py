#!/usr/bin/env python3
"""
Demo 2: Fractal Dimension of a/c Ratios in the Berggren Tree

Hypothesis 2: The distribution of a/c ratios at depth n converges to a fractal
measure with Hausdorff dimension ≈ log(3)/log(3+2√2) ≈ 0.622.

We test this by:
1. Computing a/c ratios at each depth
2. Box-counting the distribution
3. Estimating the fractal dimension
4. Comparing with the theoretical prediction

Author: Meta-Oracle Research Program
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import deque
import os

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), '..', 'figures')
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Berggren matrices
B1 = np.array([[ 1, -2,  2], [ 2, -1,  2], [ 2, -2,  3]])
B2 = np.array([[ 1,  2,  2], [ 2,  1,  2], [ 2,  2,  3]])
B3 = np.array([[-1,  2,  2], [-2,  1,  2], [-2,  2,  3]])
MATRICES = [B1, B2, B3]


def collect_ratios_by_depth(max_depth=14):
    """Collect a/c ratios at each depth of the Berggren tree."""
    root = np.array([3, 4, 5])
    ratios_by_depth = {0: [3.0/5.0]}
    
    queue = deque()
    queue.append((root, 0))
    
    while queue:
        triple, d = queue.popleft()
        if d >= max_depth:
            continue
        for M in MATRICES:
            child = M @ triple
            if all(x > 0 for x in child):
                a, b, c = child
                r = float(a) / float(c)
                nd = d + 1
                if nd not in ratios_by_depth:
                    ratios_by_depth[nd] = []
                ratios_by_depth[nd].append(r)
                queue.append((child, nd))
    
    return ratios_by_depth


def box_counting_dimension(points, n_scales=20):
    """Estimate fractal dimension via box-counting on 1D point set in [0,1]."""
    points = np.array(points)
    points = points[(points >= 0) & (points <= 1)]
    
    epsilons = np.logspace(-4, -0.3, n_scales)
    counts = []
    
    for eps in epsilons:
        bins = int(np.ceil(1.0 / eps))
        hist, _ = np.histogram(points, bins=bins, range=(0, 1))
        n_occupied = np.sum(hist > 0)
        counts.append(n_occupied)
    
    counts = np.array(counts, dtype=float)
    
    # Linear regression in log-log space
    log_eps = np.log(1.0 / epsilons)
    log_counts = np.log(counts + 1e-10)
    
    # Use middle portion for best fit
    n = len(log_eps)
    start, end = n // 5, 4 * n // 5
    coeffs = np.polyfit(log_eps[start:end], log_counts[start:end], 1)
    
    return coeffs[0], epsilons, counts


def plot_ratio_distributions(ratios_by_depth):
    """Plot the evolution of a/c ratio distributions with depth."""
    fig, axes = plt.subplots(3, 3, figsize=(18, 14))
    
    depths_to_show = [1, 2, 3, 4, 5, 6, 8, 10, 12]
    
    for idx, d in enumerate(depths_to_show):
        ax = axes[idx // 3][idx % 3]
        if d in ratios_by_depth and len(ratios_by_depth[d]) > 0:
            ratios = ratios_by_depth[d]
            ax.hist(ratios, bins=min(100, len(ratios)), color='#3498db', 
                   alpha=0.7, edgecolor='white', linewidth=0.5, density=True)
            ax.set_title(f'Depth {d}  (n={len(ratios)})', fontsize=12, fontweight='bold')
            ax.set_xlim(0, 1)
        else:
            ax.text(0.5, 0.5, 'No data', ha='center', va='center', transform=ax.transAxes)
            ax.set_title(f'Depth {d}', fontsize=12)
        
        ax.set_xlabel('a/c ratio', fontsize=10)
        ax.set_ylabel('Density', fontsize=10)
        ax.grid(True, alpha=0.3)
    
    plt.suptitle('Evolution of a/c Ratio Distribution in Berggren Tree', 
                fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'ratio_distributions.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved ratio_distributions.png")


def plot_fractal_analysis(ratios_by_depth):
    """Box-counting fractal dimension analysis."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))
    
    theoretical_dim = np.log(3) / np.log(3 + 2*np.sqrt(2))
    
    dims = []
    depths = []
    
    for d in sorted(ratios_by_depth.keys()):
        if len(ratios_by_depth[d]) >= 10:
            dim, epsilons, counts = box_counting_dimension(ratios_by_depth[d])
            dims.append(dim)
            depths.append(d)
            
            if d in [4, 8, 12]:
                log_inv_eps = np.log(1.0 / epsilons)
                log_counts = np.log(counts + 1e-10)
                ax1.plot(log_inv_eps, log_counts, 'o-', label=f'Depth {d}', 
                        markersize=5, linewidth=1.5)
    
    ax1.set_xlabel('log(1/ε)', fontsize=12)
    ax1.set_ylabel('log(N(ε))', fontsize=12)
    ax1.set_title('Box-Counting: log-log Plot', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    
    # Dimension vs depth
    ax2.plot(depths, dims, 'o-', color='#e74c3c', markersize=8, linewidth=2, 
            label='Estimated dimension')
    ax2.axhline(y=theoretical_dim, color='#2ecc71', linestyle='--', linewidth=2,
               label=f'Predicted: log(3)/log(3+2√2) ≈ {theoretical_dim:.4f}')
    ax2.axhline(y=1.0, color='gray', linestyle=':', linewidth=1, alpha=0.5, label='d=1 (full)')
    
    ax2.set_xlabel('Depth', fontsize=12)
    ax2.set_ylabel('Box-counting Dimension', fontsize=12)
    ax2.set_title('Fractal Dimension Convergence', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, 1.2)
    
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'fractal_dimension.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved fractal_dimension.png")
    
    print(f"\n══════ HYPOTHESIS 2: FRACTAL DIMENSION ══════")
    print(f"  Theoretical prediction: log(3)/log(3+2√2) = {theoretical_dim:.6f}")
    if len(dims) > 0:
        print(f"  Estimated at max depth: {dims[-1]:.6f}")
        print(f"  Relative error: {abs(dims[-1] - theoretical_dim) / theoretical_dim * 100:.2f}%")
    
    return dims, depths


def plot_self_similarity(ratios_by_depth):
    """Demonstrate self-similarity of the fractal measure."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    
    if 12 not in ratios_by_depth:
        d = max(ratios_by_depth.keys())
    else:
        d = 12
    
    ratios = np.array(ratios_by_depth[d])
    
    # Full view
    axes[0][0].hist(ratios, bins=200, color='#3498db', alpha=0.8, density=True)
    axes[0][0].set_title(f'Full View [0, 1] — Depth {d}', fontsize=12, fontweight='bold')
    axes[0][0].set_xlim(0, 1)
    
    # Zoom into [0, 0.3]
    mask1 = (ratios >= 0) & (ratios <= 0.3)
    if np.sum(mask1) > 5:
        axes[0][1].hist(ratios[mask1], bins=100, color='#e74c3c', alpha=0.8, density=True)
    axes[0][1].set_title('Zoom: [0, 0.3]', fontsize=12, fontweight='bold')
    axes[0][1].set_xlim(0, 0.3)
    
    # Zoom into [0.3, 0.7]
    mask2 = (ratios >= 0.3) & (ratios <= 0.7)
    if np.sum(mask2) > 5:
        axes[1][0].hist(ratios[mask2], bins=100, color='#2ecc71', alpha=0.8, density=True)
    axes[1][0].set_title('Zoom: [0.3, 0.7]', fontsize=12, fontweight='bold')
    axes[1][0].set_xlim(0.3, 0.7)
    
    # Zoom into [0.7, 1.0]
    mask3 = (ratios >= 0.7) & (ratios <= 1.0)
    if np.sum(mask3) > 5:
        axes[1][1].hist(ratios[mask3], bins=100, color='#9b59b6', alpha=0.8, density=True)
    axes[1][1].set_title('Zoom: [0.7, 1.0]', fontsize=12, fontweight='bold')
    axes[1][1].set_xlim(0.7, 1.0)
    
    for ax_row in axes:
        for ax in ax_row:
            ax.set_xlabel('a/c ratio', fontsize=10)
            ax.set_ylabel('Density', fontsize=10)
            ax.grid(True, alpha=0.3)
    
    plt.suptitle('Self-Similarity of the Berggren Fractal Measure', 
                fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'self_similarity.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved self_similarity.png")


if __name__ == '__main__':
    print("=" * 60)
    print("  FRACTAL DIMENSION ANALYSIS")
    print("=" * 60)
    
    ratios = collect_ratios_by_depth(max_depth=13)
    
    plot_ratio_distributions(ratios)
    dims, depths = plot_fractal_analysis(ratios)
    plot_self_similarity(ratios)
    
    print("\n✓ All fractal analyses complete!")
