#!/usr/bin/env python3
"""
Visualization: EML Depth Hierarchy

Shows that depth-2 EML functions (exp(exp(x))) are fundamentally
different from depth-1 functions (exp(wx+b)), demonstrating the
strict depth hierarchy proven in depth2_not_affine_exp.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def main():
    x = np.linspace(-1, 2, 300)

    # Depth-2: exp(exp(x))
    depth2 = np.exp(np.exp(x))

    # Best depth-1 fits matching at different point pairs
    # Fit 1: match at x=0, x=1
    # exp(b) = exp(1) = e → b = 1
    # exp(w+1) = exp(e) → w = e-1
    w1, b1 = np.e - 1, 1.0
    fit1 = np.exp(w1 * x + b1)

    # Fit 2: match at x=-1, x=0
    # exp(-w+b) = exp(exp(-1)) → -w+b = exp(-1)
    # exp(b) = exp(1) = e → b = 1
    # → w = 1 - exp(-1)
    w2, b2 = 1 - np.exp(-1), 1.0
    fit2 = np.exp(w2 * x + b2)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Linear scale
    ax1.plot(x, depth2, 'b-', linewidth=2.5, label='Depth-2: exp(exp(x))')
    ax1.plot(x, fit1, 'r--', linewidth=2, label=f'Depth-1: exp({w1:.3f}x + {b1:.1f})')
    ax1.plot(x, fit2, 'g--', linewidth=2, label=f'Depth-1: exp({w2:.3f}x + {b2:.1f})')
    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('f(x)', fontsize=12)
    ax1.set_title('Linear Scale', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(0, 100)

    # Log scale
    ax2.semilogy(x, depth2, 'b-', linewidth=2.5, label='Depth-2: exp(exp(x))')
    ax2.semilogy(x, fit1, 'r--', linewidth=2, label=f'Depth-1: exp({w1:.3f}x + {b1:.1f})')
    ax2.semilogy(x, fit2, 'g--', linewidth=2, label=f'Depth-1: exp({w2:.3f}x + {b2:.1f})')
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('f(x) (log scale)', fontsize=12)
    ax2.set_title('Logarithmic Scale', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('EML Depth Hierarchy: Depth-2 ≠ Depth-1', fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('depth_hierarchy_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved: depth_hierarchy_visualization.png")

if __name__ == "__main__":
    main()
