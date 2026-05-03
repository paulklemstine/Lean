#!/usr/bin/env python3
"""
GL₃ Tropical Satake Injectivity — Demonstration and Visualization

Demonstrates the key theorem: a finitely-supported coefficient function
on GL₃ dominant coweights satisfying adjacent-facet compatibility
(simple coroot fiber alternation) must be identically zero.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

def plot_dominant_cone():
    """Plot the GL₃ dominant cone with facets and extreme rays."""
    fig = plt.figure(figsize=(14, 6))
    
    ax1 = fig.add_subplot(121, projection='3d')
    N = 6
    dom_pts = [(a, b, c) for a in range(N+1) for b in range(a+1) for c in range(b+1)]
    
    colors = []
    for a, b, c in dom_pts:
        n_bdry = (a == b) + (b == c) + (c == 0)
        if n_bdry >= 2: colors.append('red')
        elif n_bdry == 1: colors.append('royalblue')
        else: colors.append('gray')
    
    xs, ys, zs = zip(*dom_pts)
    ax1.scatter(xs, ys, zs, c=colors, s=40, alpha=0.8, edgecolors='k', linewidth=0.5)
    ax1.plot([0, N], [0, 0], [0, 0], 'r-', linewidth=2, label='E₁: (k,0,0)')
    ax1.plot([0, N], [0, N], [0, 0], 'g-', linewidth=2, label='E₂: (k,k,0)')
    ax1.plot([0, N], [0, N], [0, N], 'b-', linewidth=2, label='E₃: (k,k,k)')
    ax1.set_xlabel('a'); ax1.set_ylabel('b'); ax1.set_zlabel('c')
    ax1.set_title('GL₃ Dominant Cone\n{(a,b,c) : a ≥ b ≥ c ≥ 0}')
    ax1.legend(fontsize=8)
    
    ax2 = fig.add_subplot(122)
    h = 6
    pts_h = [(a, b, c) for a, b, c in dom_pts if a + b + c == h]
    for a, b, c in pts_h:
        n_bdry = (a == b) + (b == c) + (c == 0)
        color = 'red' if n_bdry >= 2 else ('royalblue' if n_bdry == 1 else 'gray')
        ax2.scatter(a - b, b - c, c=color, s=80, edgecolors='k', linewidth=0.5, zorder=5)
        ax2.annotate(f'({a},{b},{c})', (a - b, b - c), fontsize=6, ha='center', va='bottom',
                    textcoords='offset points', xytext=(0, 5))
    ax2.set_xlabel('d = a - b'); ax2.set_ylabel('e = b - c')
    ax2.set_title(f'Height {h} cross-section')
    ax2.grid(True, alpha=0.3)
    legend_elements = [mpatches.Patch(color='red', label='Edge'), mpatches.Patch(color='royalblue', label='Facet'), mpatches.Patch(color='gray', label='Interior')]
    ax2.legend(handles=legend_elements, fontsize=8)
    plt.tight_layout()
    plt.savefig('demos/gl3_dominant_cone.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: demos/gl3_dominant_cone.png")

def demo_alternation_vanishing():
    """Show that alternation + finite support forces all values to zero."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4))
    ns = np.arange(12)
    
    vals = np.array([5 * (-1)**n for n in ns])
    axes[0].bar(ns, vals, color=['green' if v > 0 else 'red' for v in vals], alpha=0.7, edgecolor='k')
    axes[0].set_title('Alternating: f(n) = (-1)ⁿ · 5\n(NOT finitely supported!)')
    axes[0].set_xlabel('n'); axes[0].axhline(y=0, color='k', linewidth=0.5)
    
    vals_t = vals.copy(); vals_t[8:] = 0
    axes[1].bar(ns, vals_t, color=['green' if v > 0 else 'red' if v < 0 else 'lightgray' for v in vals_t], alpha=0.7, edgecolor='k')
    axes[1].set_title('Truncated: breaks alternation\nat n=7 → f(7)+f(8) ≠ 0')
    axes[1].set_xlabel('n'); axes[1].axhline(y=0, color='k', linewidth=0.5)
    
    axes[2].bar(ns, np.zeros(12), color='lightgray', alpha=0.7, edgecolor='k')
    axes[2].set_title('Unique solution: f ≡ 0')
    axes[2].set_xlabel('n'); axes[2].set_ylim(-6, 6); axes[2].axhline(y=0, color='k', linewidth=0.5)
    axes[2].annotate('f(n)+f(n+1)=0 ∀n\n+ finite support\n⟹ f ≡ 0', xy=(5, 3), fontsize=10, ha='center',
                    bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    plt.tight_layout()
    plt.savefig('demos/alternation_vanishing.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: demos/alternation_vanishing.png")

def verify_theorem_numerically():
    """Numerically verify that the conditions force h = 0 on dominant weights."""
    print("\n" + "="*60)
    print("NUMERICAL VERIFICATION")
    print("="*60)
    N = 5
    dom_pts = [(a, b, c) for a in range(N+1) for b in range(a+1) for c in range(b+1)]
    n = len(dom_pts)
    pt_to_idx = {p: i for i, p in enumerate(dom_pts)}
    print(f"Dominant points up to N={N}: {n}")
    
    constraints = []
    for d in range(N+1):
        for c in range(N+1):
            for b in range(N):
                p1, p2 = (b + d, b, c), (b + 1 + d, b + 1, c)
                if p1 in pt_to_idx and p2 in pt_to_idx:
                    row = np.zeros(n); row[pt_to_idx[p1]] = 1; row[pt_to_idx[p2]] = 1
                    constraints.append(row)
    for a in range(N+1):
        for e in range(N+1):
            for c in range(N):
                p1, p2 = (a, c + e, c), (a, c + 1 + e, c + 1)
                if p1 in pt_to_idx and p2 in pt_to_idx:
                    row = np.zeros(n); row[pt_to_idx[p1]] = 1; row[pt_to_idx[p2]] = 1
                    constraints.append(row)
    
    A = np.array(constraints)
    rank = np.linalg.matrix_rank(A)
    kernel_dim = n - rank
    print(f"Constraints: {len(constraints)}, Rank: {rank}, Kernel dim: {kernel_dim}")
    print(f"{'✓ VERIFIED: h ≡ 0 is the unique solution' if kernel_dim == 0 else '⚠ Non-trivial kernel'}")
    print("="*60)

if __name__ == '__main__':
    print("GL₃ Tropical Satake Injectivity — Demo\n")
    plot_dominant_cone()
    demo_alternation_vanishing()
    verify_theorem_numerically()
    print("\n✓ All demos complete!")
