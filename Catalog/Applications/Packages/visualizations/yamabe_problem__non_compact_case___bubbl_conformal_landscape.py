#!/usr/bin/env python3
"""Visualization: Conformal geometry landscape and exponent analysis."""

import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Panel 1: Critical exponents vs dimension
    ax = axes[0]
    dims = np.arange(3, 30)
    p_star = 2.0 * dims / (dims - 2)
    q = (dims + 2.0) / (dims - 2)
    c_n = (dims - 2.0) / (4.0 * (dims - 1))

    ax.plot(dims, p_star, 'b-o', markersize=4, label='p*(n) = 2n/(n-2)', linewidth=2)
    ax.plot(dims, q, 'r-s', markersize=4, label='q(n) = (n+2)/(n-2)', linewidth=2)
    ax.axhline(y=2, color='blue', linestyle='--', alpha=0.5, label='p* → 2')
    ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='q → 1')
    ax.set_xlabel('Dimension n', fontsize=12)
    ax.set_ylabel('Exponent value', fontsize=12)
    ax.set_title('Critical exponents vs dimension', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel 2: Conformal dimension constant
    ax = axes[1]
    ax.plot(dims, c_n, 'g-o', markersize=4, linewidth=2, label='c_n = (n-2)/(4(n-1))')
    ax.axhline(y=0.25, color='gray', linestyle='--', alpha=0.5, label='Limit 1/4')
    ax.axhline(y=0.125, color='orange', linestyle=':', alpha=0.7, label='c₃ = 1/8')

    # Highlight dimension 3
    ax.plot(3, 1/8, 'ro', markersize=10, zorder=5)
    ax.annotate('c₃ = 1/8', xy=(3, 1/8), xytext=(6, 0.1),
                arrowprops=dict(arrowstyle='->', color='red'),
                fontsize=11, color='red')

    ax.set_xlabel('Dimension n', fontsize=12)
    ax.set_ylabel('c_n', fontsize=12)
    ax.set_title('Conformal dimension constant', fontsize=13)
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 0.3)

    # Panel 3: Stereographic factor and Green's function
    ax = axes[2]
    r = np.linspace(0.01, 10, 500)

    phi = 2.0 / (1 + r**2)
    G3 = r**(-1)
    G4 = r**(-2)
    G5 = r**(-3)

    ax.semilogy(r, phi, 'b-', linewidth=2, label='φ(r) = 2/(1+r²)')
    ax.semilogy(r, G3, 'r--', linewidth=1.5, label='G₃(r) = r⁻¹')
    ax.semilogy(r, G4, 'g--', linewidth=1.5, label='G₄(r) = r⁻²')
    ax.semilogy(r, G5, 'm--', linewidth=1.5, label='G₅(r) = r⁻³')

    ax.set_xlabel('r', fontsize=12)
    ax.set_ylabel('Value (log scale)', fontsize=12)
    ax.set_title('Conformal factor & Green functions', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(1e-4, 10)

    plt.suptitle('The Conformal Geometry Landscape', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('viz_conformal_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_conformal_landscape.png")


if __name__ == "__main__":
    main()
