#!/usr/bin/env python3
"""
Visualization: Invariant Subspace Problem Landscape

Maps the landscape of the invariant subspace problem, showing which
classes of operators are known to have the ISP and where the frontier
of knowledge lies.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch


def create_isp_landscape():
    fig, axes = plt.subplots(1, 2, figsize=(16, 8))
    
    # --- Panel 1: Class hierarchy and ISP status ---
    ax1 = axes[0]
    ax1.set_xlim(0, 10)
    ax1.set_ylim(0, 10)
    
    # Draw nested operator classes
    classes = [
        (1, 1, 8, 8, 'All bounded operators', '#ffcccc', '?'),
        (1.5, 1.5, 7, 7, 'Polynomially compact', '#ffddaa', '✓ (1966)'),
        (2, 2, 6, 6, 'Compact commutant', '#ffffaa', '✓ (1973)'),
        (2.5, 2.5, 5, 5, 'Compact operators', '#ccffcc', '✓ (1954)'),
        (3.5, 3.5, 3, 3, 'Normal operators', '#aaddff', '✓ (spectral)'),
        (4, 4, 2, 2, 'Self-adjoint', '#ccccff', '✓ (eigenspace)'),
    ]
    
    for x, y, w, h, label, color, status in classes:
        rect = FancyBboxPatch((x, y), w, h, 
                              boxstyle="round,pad=0.1",
                              facecolor=color, edgecolor='black',
                              linewidth=1.5, alpha=0.6)
        ax1.add_patch(rect)
        ax1.text(x + w/2, y + h - 0.3, label, fontsize=9,
                ha='center', va='top', fontweight='bold')
        ax1.text(x + w/2, y + 0.3, f'ISP: {status}', fontsize=8,
                ha='center', va='bottom', style='italic')
    
    ax1.set_title('Operator Classes with ISP Status', fontsize=14, fontweight='bold')
    ax1.axis('off')
    
    # --- Panel 2: Spectral decay and nilpotency ---
    ax2 = axes[1]
    
    # Several operator types and their spectral profiles
    n = 50
    
    # Compact: eigenvalues decay
    compact_evals = 1.0 / np.arange(1, n + 1) ** 1.5
    ax2.semilogy(range(1, n + 1), compact_evals, 'b-o', markersize=3,
                 label='Compact (decay → 0)', linewidth=2)
    
    # Normal (unitary): all on unit circle
    normal_evals = np.ones(n)
    ax2.semilogy(range(1, n + 1), normal_evals, 'g-s', markersize=3,
                 label='Unitary (|λ| = 1)', linewidth=2)
    
    # Nilpotent: all zero
    nilp_evals = np.full(n, 1e-16)
    ax2.semilogy(range(1, n + 1), nilp_evals, 'r-^', markersize=3,
                 label='Nilpotent (all λ = 0)', linewidth=2)
    
    # Generic: random
    np.random.seed(42)
    A = np.random.randn(n, n) / np.sqrt(n)
    generic_evals = np.sort(np.abs(np.linalg.eigvals(A)))[::-1]
    ax2.semilogy(range(1, n + 1), generic_evals + 1e-16, 'k--', 
                 alpha=0.5, label='Generic (random)', linewidth=1.5)
    
    ax2.set_xlabel('Index', fontsize=12)
    ax2.set_ylabel('|Eigenvalue|', fontsize=12)
    ax2.set_title('Spectral Profiles by Operator Class', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(1e-17, 10)
    
    plt.tight_layout()
    plt.savefig('isp_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: isp_landscape.png")


if __name__ == "__main__":
    create_isp_landscape()
