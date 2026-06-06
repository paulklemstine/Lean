#!/usr/bin/env python3
"""
Visualization: EML-KA Representation Landscape

Shows the key relationships between EML-KA decompositions:
1. Monomial decomposition accuracy across exponents
2. AM-GM gap as a function of x/y ratio
3. LogSumExp approximation quality
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm

def plot_monomial_accuracy():
    """Plot EML-KA monomial representation accuracy across exponent space."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))
    
    # Panel 1: x^a * y^b via EML-KA for various (a,b)
    ax = axes[0]
    x_vals = np.linspace(0.1, 5, 200)
    exponents = [(1, 1), (2, 0.5), (0.5, 3), (1.5, 1.5)]
    y_fixed = 2.0
    for a, b in exponents:
        direct = x_vals**a * y_fixed**b
        eml = np.exp(a * np.log(x_vals) + b * np.log(y_fixed))
        ax.plot(x_vals, direct, '-', linewidth=2, label=f'$x^{{{a}}}y^{{{b}}}$')
        ax.plot(x_vals, eml, 'k--', linewidth=0.5, alpha=0.5)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('$f(x, 2)$', fontsize=12)
    ax.set_title('Monomials via EML-KA (y=2)', fontsize=13)
    ax.legend(fontsize=9)
    ax.set_yscale('log')
    
    # Panel 2: Power sum x^n + y^n
    ax = axes[1]
    x_vals = np.linspace(0.1, 3, 200)
    for n in [1, 2, 3, 5]:
        ps = x_vals**n + y_fixed**n
        ax.plot(x_vals, ps, linewidth=2, label=f'$x^{n}+y^{n}$ (2 terms)')
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel(f'$x^n + 2^n$', fontsize=12)
    ax.set_title('Power Sums: 2-Term EML-KA', fontsize=13)
    ax.legend(fontsize=9)
    
    # Panel 3: Polynomial via EML-KA
    ax = axes[2]
    x_vals = np.linspace(0.5, 3, 200)
    # p(x,y) = 3x^2*y + 2xy^3 + x at y=2
    direct = 3*x_vals**2*2 + 2*x_vals*2**3 + x_vals
    eml = (3 * np.exp(2*np.log(x_vals) + np.log(2)) + 
           2 * np.exp(np.log(x_vals) + 3*np.log(2)) + 
           np.exp(np.log(x_vals)))
    ax.plot(x_vals, direct, 'b-', linewidth=2, label='Direct')
    ax.plot(x_vals, eml, 'r--', linewidth=2, label='EML-KA (3 terms)')
    ax.fill_between(x_vals, direct, eml, alpha=0.1, color='green')
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('p(x, 2)', fontsize=12)
    ax.set_title('Polynomial Completeness', fontsize=13)
    ax.legend(fontsize=9)
    
    plt.tight_layout()
    plt.savefig('eml_ka_monomial_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eml_ka_monomial_landscape.png")


def plot_amgm_and_lse():
    """Plot AM-GM gap and LogSumExp bounds."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    # Panel 1: AM-GM gap
    ax = axes[0]
    ratios = np.linspace(0.01, 10, 500)
    y_fixed = 1.0
    x_vals = ratios * y_fixed
    
    gm = np.exp((np.log(x_vals) + np.log(y_fixed)) / 2)
    am = (x_vals + y_fixed) / 2
    gap = am - gm
    
    ax.fill_between(ratios, 0, gap, alpha=0.3, color='blue', label='AM - GM gap')
    ax.plot(ratios, am, 'r-', linewidth=2, label='AM = (x+1)/2')
    ax.plot(ratios, gm, 'g-', linewidth=2, label='GM = √x')
    ax.axvline(x=1, color='k', linestyle=':', alpha=0.5, label='x=y (equality)')
    ax.set_xlabel('x/y ratio', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('AM-GM via EML-KA (y=1)', fontsize=13)
    ax.legend(fontsize=9)
    ax.set_xlim(0, 5)
    ax.set_ylim(0, 3.5)
    
    # Panel 2: LogSumExp bounds
    ax = axes[1]
    b_fixed = 0
    a_vals = np.linspace(-5, 5, 500)
    lse = np.log(np.exp(a_vals) + np.exp(b_fixed))
    mx = np.maximum(a_vals, b_fixed)
    mx_log2 = mx + np.log(2)
    
    ax.fill_between(a_vals, mx, lse, alpha=0.3, color='orange', label='LSE − max')
    ax.fill_between(a_vals, lse, mx_log2, alpha=0.2, color='purple', label='max+log2 − LSE')
    ax.plot(a_vals, lse, 'b-', linewidth=2, label='LogSumExp(a, 0)')
    ax.plot(a_vals, mx, 'r--', linewidth=1.5, label='max(a, 0)')
    ax.plot(a_vals, mx_log2, 'g--', linewidth=1.5, label='max(a, 0) + log2')
    ax.set_xlabel('a', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('LogSumExp: Smooth Max Bounds', fontsize=13)
    ax.legend(fontsize=9, loc='upper left')
    
    plt.tight_layout()
    plt.savefig('eml_ka_amgm_lse.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eml_ka_amgm_lse.png")


def plot_log_coordinate_transform():
    """Show the logarithmic isomorphism: monomials become linear in log-space."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    # Panel 1: Original coordinates - curved level sets
    ax = axes[0]
    x = np.linspace(0.1, 5, 300)
    y = np.linspace(0.1, 5, 300)
    X, Y = np.meshgrid(x, y)
    
    # Monomial x^2 * y
    Z = X**2 * Y
    levels = [0.5, 1, 2, 5, 10, 20, 50]
    cs = ax.contour(X, Y, Z, levels=levels, cmap='viridis')
    ax.clabel(cs, fontsize=8)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.set_title('$x^2 y$ in original coordinates\n(curved level sets)', fontsize=12)
    
    # Panel 2: Log coordinates - linear level sets!
    ax = axes[1]
    t1 = np.linspace(-2, 2, 300)
    t2 = np.linspace(-2, 2, 300)
    T1, T2 = np.meshgrid(t1, t2)
    
    # In log-coords: log(x^2*y) = 2*log(x) + log(y) = 2*t1 + t2 (LINEAR!)
    Z_log = 2*T1 + T2
    levels_log = np.log(levels)
    cs = ax.contour(T1, T2, Z_log, levels=levels_log, cmap='viridis')
    ax.clabel(cs, fontsize=8, fmt='%.1f')
    ax.set_xlabel('$t_1 = \\log(x)$', fontsize=12)
    ax.set_ylabel('$t_2 = \\log(y)$', fontsize=12)
    ax.set_title('$2t_1 + t_2$ in log-coordinates\n(straight level sets!)', fontsize=12)
    
    plt.suptitle('The Logarithmic Isomorphism: Monomials → Linear Functions', 
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('eml_ka_log_isomorphism.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eml_ka_log_isomorphism.png")


if __name__ == "__main__":
    plot_monomial_accuracy()
    plot_amgm_and_lse()
    plot_log_coordinate_transform()
    print("\nAll visualizations generated!")
