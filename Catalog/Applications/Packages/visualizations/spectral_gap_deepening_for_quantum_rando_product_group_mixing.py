#!/usr/bin/env python3
"""
Visualization: Product Group Mixing Decomposition
T_mix(G₁×G₂) ≥ max(T_mix(G₁), T_mix(G₂)) with min-gap control.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def plot_product_mixing():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: mixing time decomposition
    ax = axes[0]
    n1 = 100
    gap1 = 0.1
    n2_vals = np.arange(10, 500, 5)
    
    t1 = np.log(n1) / gap1
    
    for gap2 in [0.05, 0.1, 0.2, 0.5]:
        t2_vals = np.log(n2_vals) / gap2
        t_product = np.log(n1 * n2_vals) / np.minimum(gap1, gap2)
        t_max = np.maximum(t1, t2_vals)
        
        ax.plot(n2_vals, t_product, '-', linewidth=2, label=f'$T_{{prod}}$, $\\gamma_2={gap2}$')
        ax.plot(n2_vals, t_max, '--', linewidth=1.5, alpha=0.7)
    
    ax.axhline(y=t1, color='gray', linestyle=':', alpha=0.5, label=f'$T_1$ (n₁={n1})')
    ax.set_xlabel('|G₂|', fontsize=13)
    ax.set_ylabel('Mixing time', fontsize=13)
    ax.set_title('Product Mixing: Solid = T_prod, Dashed = max(T₁,T₂)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Right: Cayley graph on Z/nZ - spectral gap vs n
    ax = axes[1]
    ns = np.arange(3, 200)
    theoretical_gap = 1 - np.cos(2 * np.pi / ns)
    lower_bound = 2 / ns**2
    upper_bound = 2 * np.pi**2 / ns**2
    
    ax.loglog(ns, theoretical_gap, 'b-', linewidth=2.5, label='$1 - \\cos(2\\pi/n)$')
    ax.loglog(ns, lower_bound, 'r--', linewidth=2, label='$2/n^2$ (lower bound)')
    ax.loglog(ns, upper_bound, 'g-.', linewidth=2, label='$2\\pi^2/n^2$ (upper bound)')
    ax.set_xlabel('Group size n', fontsize=13)
    ax.set_ylabel('Spectral gap', fontsize=13)
    ax.set_title('Cyclic Group Spectral Gap', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('product_mixing.png', dpi=150, bbox_inches='tight')
    print("Saved product_mixing.png")

if __name__ == "__main__":
    plot_product_mixing()
