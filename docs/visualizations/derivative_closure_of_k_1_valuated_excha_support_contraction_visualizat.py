#!/usr/bin/env python3
"""
Visualization: Contraction Shadow and Derivative Support

This script visualizes how partial differentiation transforms the support
of a polynomial — showing the "contraction shadow" operation that projects
support vectors by decrementing one coordinate.

For a degree-3 uniform matroid U(3,4), we show the original support and
the derivative support for each variable, illustrating the matroid
contraction interpretation.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations


def uniform_matroid_support(n, d):
    result = []
    for combo in combinations(range(n), d):
        vec = [0] * n
        for i in combo:
            vec[i] = 1
        result.append(tuple(vec))
    return result


def derivative_support(support, var_idx):
    dsupport = set()
    for alpha in support:
        if alpha[var_idx] >= 1:
            m = list(alpha)
            m[var_idx] -= 1
            dsupport.add(tuple(m))
    return list(dsupport)


def plot_support_3d(ax, support, title, color, marker='o', alpha=0.8, size=100):
    """Plot 3D support vectors (using first 3 coordinates)."""
    if not support:
        return
    xs = [s[0] for s in support]
    ys = [s[1] for s in support]
    zs = [s[2] for s in support]
    ax.scatter(xs, ys, zs, c=color, s=size, marker=marker, alpha=alpha,
              edgecolors='black', linewidth=0.5)
    ax.set_title(title, fontsize=11, fontweight='bold')
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    ax.set_zlabel('x₃')


def main():
    n = 4
    d = 3
    
    support = uniform_matroid_support(n, d)
    
    fig = plt.figure(figsize=(16, 10))
    fig.suptitle('Contraction Shadow: Support of U(3,4) and Its Derivatives\n'
                 'Derivative = Matroid Contraction at the Exponent Level',
                 fontsize=14, fontweight='bold')
    
    # Original support
    ax1 = fig.add_subplot(2, 3, 1, projection='3d')
    plot_support_3d(ax1, support, f'Original U(3,4)\n{len(support)} monomials',
                    'royalblue', size=150)
    
    # Derivative supports
    colors = ['crimson', 'forestgreen', 'darkorange', 'purple']
    for i in range(n):
        ax = fig.add_subplot(2, 3, i + 2, projection='3d')
        dsup = derivative_support(support, i)
        plot_support_3d(ax, dsup,
                       f'∂/∂x_{i+1} U(3,4)\n{len(dsup)} monomials',
                       colors[i], marker='s', size=120)
    
    # Summary panel
    ax_text = fig.add_subplot(2, 3, 6)
    ax_text.axis('off')
    
    summary = (
        "Derivative Closure Theorem\n"
        "━━━━━━━━━━━━━━━━━━━━━━━━\n\n"
        "If w satisfies K=1 valuated\n"
        "exchange, then ∂ᵢw also\n"
        "satisfies K=1 exchange.\n\n"
        "Support Contraction:\n"
        f"  Original: {len(support)} vectors (deg 3)\n"
    )
    for i in range(n):
        dsup = derivative_support(support, i)
        summary += f"  ∂/∂x_{i+1}: {len(dsup)} vectors (deg 2)\n"
    
    summary += "\nThe derivative support is the\ncontraction shadow of the\noriginal support."
    
    ax_text.text(0.1, 0.5, summary, transform=ax_text.transAxes,
                fontsize=10, verticalalignment='center',
                fontfamily='monospace',
                bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    
    plt.tight_layout()
    plt.savefig('support_contraction.png', dpi=150, bbox_inches='tight')
    print("Saved support_contraction.png")


if __name__ == "__main__":
    main()
