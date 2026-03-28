#!/usr/bin/env python3
"""
Demo 1: Berggren Pythagorean Triple Tree — Visualization & Spectral Analysis

Generates the ternary Berggren tree of primitive Pythagorean triples,
visualizes the tree structure, and computes spectral properties of the
generating matrices.

Author: Meta-Oracle Research Program
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from collections import deque
import os

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), '..', 'figures')
os.makedirs(OUTPUT_DIR, exist_ok=True)

# ─── Berggren 3×3 Matrices ───────────────────────────────────────────────────
B1 = np.array([[ 1, -2,  2],
               [ 2, -1,  2],
               [ 2, -2,  3]])

B2 = np.array([[ 1,  2,  2],
               [ 2,  1,  2],
               [ 2,  2,  3]])

B3 = np.array([[-1,  2,  2],
               [-2,  1,  2],
               [-2,  2,  3]])

MATRICES = [B1, B2, B3]
LABELS = ['B₁ (left)', 'B₂ (mid)', 'B₃ (right)']
COLORS = ['#e74c3c', '#2ecc71', '#3498db']

# ─── 2×2 Berggren Matrices (Euclid parameter space) ──────────────────────────
M1_2x2 = np.array([[2, -1], [1, 0]])
M2_2x2 = np.array([[2,  1], [1, 0]])
M3_2x2 = np.array([[1,  2], [0, 1]])


def generate_tree(root, depth):
    """Generate all triples up to given depth via BFS."""
    triples = []
    queue = deque()
    queue.append((root, 0, 'root', None))
    
    while queue:
        triple, d, label, parent = queue.popleft()
        triples.append({'triple': tuple(triple), 'depth': d, 'label': label, 'parent': parent})
        if d < depth:
            for i, M in enumerate(MATRICES):
                child = M @ triple
                # Only keep positive triples
                if all(x > 0 for x in child):
                    queue.append((child, d + 1, LABELS[i], tuple(triple)))
    
    return triples


def plot_tree_structure(triples, max_depth=4):
    """Visualize the tree as a radial layout."""
    fig, ax = plt.subplots(1, 1, figsize=(16, 10))
    
    # Position nodes by depth and index
    depth_counts = {}
    depth_indices = {}
    for t in triples:
        d = t['depth']
        depth_counts[d] = depth_counts.get(d, 0) + 1
    
    current_idx = {}
    for d in range(max(depth_counts.keys()) + 1):
        current_idx[d] = 0
    
    positions = {}
    for t in triples:
        d = t['depth']
        n = depth_counts[d]
        idx = current_idx[d]
        current_idx[d] += 1
        
        x = (idx - (n - 1) / 2) * (12 / max(n, 1))
        y = -d * 2
        positions[t['triple']] = (x, y)
    
    # Draw edges
    for t in triples:
        if t['parent'] is not None and t['parent'] in positions:
            p1 = positions[t['parent']]
            p2 = positions[t['triple']]
            color_idx = LABELS.index(t['label']) if t['label'] in LABELS else 0
            ax.plot([p1[0], p2[0]], [p1[1], p2[1]], '-', 
                   color=COLORS[color_idx], alpha=0.6, linewidth=1.5)
    
    # Draw nodes
    for t in triples:
        pos = positions[t['triple']]
        a, b, c = t['triple']
        ax.plot(pos[0], pos[1], 'o', color='white', markersize=28,
               markeredgecolor='#2c3e50', markeredgewidth=1.5, zorder=5)
        fontsize = 7 if t['depth'] <= 3 else 5
        ax.text(pos[0], pos[1], f"({a},{b},{c})", ha='center', va='center',
               fontsize=fontsize, fontweight='bold', zorder=6)
    
    patches = [mpatches.Patch(color=c, label=l) for c, l in zip(COLORS, LABELS)]
    ax.legend(handles=patches, loc='upper right', fontsize=11)
    ax.set_title('Berggren Tree of Primitive Pythagorean Triples', fontsize=16, fontweight='bold')
    ax.set_xlim(-14, 14)
    ax.axis('off')
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'berggren_tree.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print(f"✓ Saved berggren_tree.png")


def spectral_analysis():
    """Analyze eigenvalues of Berggren matrices."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    
    results = {}
    for i, (M, label) in enumerate(zip(MATRICES, ['B₁', 'B₂', 'B₃'])):
        eigenvalues = np.linalg.eigvals(M)
        results[label] = eigenvalues
        
        ax = axes[i]
        # Plot eigenvalues in complex plane
        ax.scatter(eigenvalues.real, eigenvalues.imag, s=200, c=COLORS[i], 
                  zorder=5, edgecolors='black', linewidth=1.5)
        
        # Unit circle
        theta = np.linspace(0, 2*np.pi, 100)
        ax.plot(np.cos(theta), np.sin(theta), 'k--', alpha=0.3, linewidth=1)
        
        for ev in eigenvalues:
            ax.annotate(f'{ev.real:.3f}+{ev.imag:.3f}i' if abs(ev.imag) > 1e-10 
                       else f'{ev.real:.3f}',
                       (ev.real, ev.imag), textcoords="offset points",
                       xytext=(10, 10), fontsize=9)
        
        ax.set_xlabel('Re(λ)', fontsize=12)
        ax.set_ylabel('Im(λ)', fontsize=12)
        ax.set_title(f'{label} Eigenvalues', fontsize=14, fontweight='bold')
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.3)
        ax.axhline(y=0, color='k', linewidth=0.5)
        ax.axvline(x=0, color='k', linewidth=0.5)
    
    plt.suptitle('Spectral Decomposition of Berggren Matrices', fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'spectral_analysis.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print(f"✓ Saved spectral_analysis.png")
    
    # ─── Spectral Gap Analysis ────────────────────────────────────────────
    print("\n══════ SPECTRAL ANALYSIS ══════")
    for label, evs in results.items():
        mags = sorted(np.abs(evs), reverse=True)
        print(f"\n{label}: eigenvalues = {evs}")
        print(f"  |λ₁| = {mags[0]:.6f}, |λ₂| = {mags[1]:.6f}, |λ₃| = {mags[2]:.6f}")
        print(f"  Spectral gap = |λ₁| - |λ₂| = {mags[0] - mags[1]:.6f}")
        print(f"  Spectral radius = {mags[0]:.6f}")
    
    # Combined spectral radius
    sr = 3 + 2*np.sqrt(2)
    gap = sr - 1
    print(f"\n══════ HYPOTHESIS 1: SPECTRAL GAP ══════")
    print(f"  3 + 2√2 = {sr:.6f}")
    print(f"  3 + 2√2 - 1 = {gap:.6f}")
    print(f"  Predicted convergence rate: ~{gap:.3f}")
    
    return results


def hypotenuse_growth():
    """Analyze how the hypotenuse grows with depth."""
    root = np.array([3, 4, 5])
    max_depth = 12
    triples = generate_tree(root, max_depth)
    
    depth_hyps = {}
    for t in triples:
        d = t['depth']
        c = t['triple'][2]
        if d not in depth_hyps:
            depth_hyps[d] = []
        depth_hyps[d].append(c)
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))
    
    depths = sorted(depth_hyps.keys())
    means = [np.mean(depth_hyps[d]) for d in depths]
    mins = [np.min(depth_hyps[d]) for d in depths]
    maxs = [np.max(depth_hyps[d]) for d in depths]
    counts = [len(depth_hyps[d]) for d in depths]
    
    ax1.semilogy(depths, means, 'o-', color='#e74c3c', label='Mean hypotenuse', linewidth=2)
    ax1.semilogy(depths, mins, 's--', color='#3498db', label='Min hypotenuse', linewidth=1.5)
    ax1.semilogy(depths, maxs, '^--', color='#2ecc71', label='Max hypotenuse', linewidth=1.5)
    
    # Fit exponential growth
    log_means = np.log(means)
    coeffs = np.polyfit(depths, log_means, 1)
    growth_rate = np.exp(coeffs[0])
    fit_line = np.exp(coeffs[1]) * growth_rate ** np.array(depths)
    ax1.semilogy(depths, fit_line, 'k--', alpha=0.5, label=f'Fit: growth rate ≈ {growth_rate:.3f}')
    
    ax1.set_xlabel('Depth', fontsize=12)
    ax1.set_ylabel('Hypotenuse c', fontsize=12)
    ax1.set_title('Hypotenuse Growth in Berggren Tree', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Node count (should be 3^n for full tree, but B1 drops at root)
    ax2.semilogy(depths, counts, 'o-', color='#9b59b6', linewidth=2, label='Actual count')
    theoretical = [1] + [3**d for d in depths[1:]]  # Approximate
    ax2.semilogy(depths, [3**d for d in depths], 's--', color='gray', 
                alpha=0.5, label='3ⁿ (full ternary)')
    ax2.set_xlabel('Depth', fontsize=12)
    ax2.set_ylabel('Count', fontsize=12)
    ax2.set_title('Nodes per Depth Level', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'hypotenuse_growth.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print(f"✓ Saved hypotenuse_growth.png")
    print(f"  Exponential growth rate ≈ {growth_rate:.6f}")
    print(f"  3 + 2√2 ≈ {3 + 2*np.sqrt(2):.6f}")
    print(f"  Ratio: {growth_rate / (3 + 2*np.sqrt(2)):.6f}")


if __name__ == '__main__':
    print("=" * 60)
    print("  BERGGREN TREE & SPECTRAL ANALYSIS")
    print("=" * 60)
    
    root = np.array([3, 4, 5])
    
    # 1. Generate and visualize tree
    triples = generate_tree(root, 4)
    plot_tree_structure(triples, max_depth=4)
    
    # 2. Spectral analysis
    spectral_analysis()
    
    # 3. Hypotenuse growth
    hypotenuse_growth()
    
    print("\n✓ All tree visualizations complete!")
