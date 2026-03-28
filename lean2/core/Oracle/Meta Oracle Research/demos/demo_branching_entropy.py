#!/usr/bin/env python3
"""
Demo 3: Effective Branching Factor & Shannon Entropy

Hypothesis 3: Since B₁ applied to (3,4,5) produces a triple with a negative
component (specifically, B₁·(3,4,5) = (3-8+10, 6-4+10, 6-8+15) = (5, 12, 13)
— wait, let's check), the effective branching factor may differ from 3.

Actually: B₁·(3,4,5) = (1·3 + (-2)·4 + 2·5, 2·3 + (-1)·4 + 2·5, 2·3 + (-2)·4 + 3·5)
                      = (3-8+10, 6-4+10, 6-8+15) = (5, 12, 13) ✓ positive!

The hypothesis refers to (a,b,c) = (0,1,1): B₁·(0,1,1) = (0, -1+2, 0-2+3) = (0, 1, 1)
which is a fixed point but not a valid primitive triple.

We test: at each depth, how many children are valid (all components positive)?

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
MATRIX_NAMES = ['B₁', 'B₂', 'B₃']


def analyze_branching(max_depth=14):
    """Count valid vs invalid children at each depth."""
    root = np.array([3, 4, 5])
    
    # Track: per depth, how many nodes, how many have 2 vs 3 valid children
    depth_stats = {}
    
    queue = deque()
    queue.append((root, 0))
    
    total_nodes = {0: 1}
    branch_counts = {}  # depth -> list of actual branch counts per node
    
    while queue:
        triple, d = queue.popleft()
        if d >= max_depth:
            continue
        
        valid_children = 0
        for M in MATRICES:
            child = M @ triple
            if all(x > 0 for x in child):
                valid_children += 1
                nd = d + 1
                total_nodes[nd] = total_nodes.get(nd, 0) + 1
                queue.append((child, nd))
        
        if d not in branch_counts:
            branch_counts[d] = []
        branch_counts[d].append(valid_children)
    
    return total_nodes, branch_counts


def compute_entropy(total_nodes, max_depth):
    """Compute Shannon entropy of the tree growth."""
    depths = sorted(total_nodes.keys())
    cumulative = np.cumsum([total_nodes.get(d, 0) for d in depths])
    
    # Entropy: H(n) = log₂(total_nodes_at_depth_n)
    entropies = [np.log2(total_nodes[d]) if total_nodes[d] > 0 else 0 for d in depths]
    
    return depths, entropies, cumulative


def plot_branching_analysis(total_nodes, branch_counts, max_depth):
    """Visualize branching factor and entropy."""
    fig, axes = plt.subplots(2, 2, figsize=(16, 12))
    
    depths = sorted(total_nodes.keys())
    counts = [total_nodes[d] for d in depths]
    
    # 1. Nodes per depth
    ax = axes[0][0]
    ax.semilogy(depths, counts, 'o-', color='#e74c3c', linewidth=2, markersize=8, label='Actual')
    ax.semilogy(depths, [3**d for d in depths], 's--', color='gray', alpha=0.5, label='3ⁿ (full ternary)')
    ax.semilogy(depths, [2**d for d in depths], '^--', color='#3498db', alpha=0.5, label='2ⁿ (binary)')
    ax.set_xlabel('Depth', fontsize=12)
    ax.set_ylabel('Node Count', fontsize=12)
    ax.set_title('Nodes per Depth Level', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # 2. Effective branching factor
    ax = axes[0][1]
    eff_branch = []
    for i in range(1, len(depths)):
        if counts[i-1] > 0:
            eff_branch.append(counts[i] / counts[i-1])
        else:
            eff_branch.append(0)
    
    ax.plot(depths[1:], eff_branch, 'o-', color='#2ecc71', linewidth=2, markersize=8)
    ax.axhline(y=3, color='gray', linestyle='--', alpha=0.5, label='b=3')
    ax.axhline(y=2, color='#3498db', linestyle='--', alpha=0.5, label='b=2')
    ax.set_xlabel('Depth', fontsize=12)
    ax.set_ylabel('Effective Branching Factor', fontsize=12)
    ax.set_title('Branching Factor vs Depth', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(1.5, 3.5)
    
    # 3. Shannon entropy
    ax = axes[1][0]
    _, entropies, _ = compute_entropy(total_nodes, max_depth)
    ax.plot(depths, entropies, 'o-', color='#9b59b6', linewidth=2, markersize=8, label='H(n) = log₂(count)')
    
    # Fit linear model
    if len(depths) > 2:
        coeffs = np.polyfit(depths[1:], entropies[1:], 1)
        fit_line = np.polyval(coeffs, depths)
        ax.plot(depths, fit_line, 'k--', alpha=0.5, 
               label=f'Linear fit: slope = {coeffs[0]:.4f} (≈ log₂({2**coeffs[0]:.3f}))')
    
    ax.plot(depths, [d * np.log2(3) for d in depths], '--', color='gray', alpha=0.4, label='n·log₂(3)')
    ax.plot(depths, [d * np.log2(2) for d in depths], '--', color='#3498db', alpha=0.4, label='n·log₂(2)')
    
    ax.set_xlabel('Depth n', fontsize=12)
    ax.set_ylabel('Shannon Entropy H(n)', fontsize=12)
    ax.set_title('Entropy Growth', fontsize=14, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    
    # 4. Distribution of branch counts
    ax = axes[1][1]
    all_branches = []
    for d in sorted(branch_counts.keys()):
        all_branches.extend(branch_counts[d])
    
    unique, freq = np.unique(all_branches, return_counts=True)
    ax.bar(unique, freq / freq.sum(), color='#f39c12', edgecolor='white', width=0.6)
    ax.set_xlabel('Children per Node', fontsize=12)
    ax.set_ylabel('Fraction', fontsize=12)
    ax.set_title('Distribution of Children Count', fontsize=14, fontweight='bold')
    ax.set_xticks([0, 1, 2, 3])
    ax.grid(True, alpha=0.3, axis='y')
    
    for u, f in zip(unique, freq / freq.sum()):
        ax.text(u, f + 0.01, f'{f:.3f}', ha='center', fontsize=11, fontweight='bold')
    
    plt.suptitle('Effective Branching Factor & Shannon Entropy Analysis',
                fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'branching_entropy.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved branching_entropy.png")
    
    print(f"\n══════ HYPOTHESIS 3: EFFECTIVE BRANCHING ══════")
    print(f"  Mean effective branching factor: {np.mean(eff_branch[1:]):.6f}")
    print(f"  Shannon entropy slope: {coeffs[0]:.6f}")
    print(f"  Equivalent branching: 2^slope = {2**coeffs[0]:.6f}")
    
    # Check: is it exactly 3 for all descendants of (3,4,5)?
    two_child_count = sum(1 for b in all_branches if b < 3)
    three_child_count = sum(1 for b in all_branches if b == 3)
    print(f"\n  Nodes with <3 children: {two_child_count}")
    print(f"  Nodes with  3 children: {three_child_count}")
    print(f"  Fraction with full branching: {three_child_count / (two_child_count + three_child_count):.6f}")


if __name__ == '__main__':
    print("=" * 60)
    print("  BRANCHING FACTOR & ENTROPY ANALYSIS")
    print("=" * 60)
    
    max_depth = 13
    total_nodes, branch_counts = analyze_branching(max_depth)
    plot_branching_analysis(total_nodes, branch_counts, max_depth)
    
    print("\n✓ Branching analysis complete!")
