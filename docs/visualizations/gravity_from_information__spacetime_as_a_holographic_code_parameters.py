#!/usr/bin/env python3
"""
Visualization: Holographic Code Parameters vs Boundary Area
Shows how n, k, d, and redundancy scale with boundary area.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def holographic_params(n):
    """Compute holographic code parameters for boundary area n (must be div by 4)."""
    k = n // 4
    d = (3 * k + 2) // 2 if (3 * k + 2) % 2 == 0 else None
    return k, d


def main():
    ns = [n for n in range(4, 260, 4)]
    ks, ds, redundancies, erasure_caps = [], [], [], []
    
    for n in ns:
        k = n // 4
        # For saturated code with even 3k+2
        if (3 * k + 2) % 2 == 0:
            d = (3 * k + 2) // 2
        else:
            d = (3 * k + 1) // 2  # floor
        ks.append(k)
        ds.append(d)
        redundancies.append((n - k) / n)
        erasure_caps.append((d - 1) // 2)
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Holographic Code Parameters: Gravity as Error Correction',
                 fontsize=16, fontweight='bold')
    
    # Plot 1: Code parameters
    ax = axes[0, 0]
    ax.plot(ns, ns, 'b-', linewidth=2, label='n (physical qubits)', alpha=0.7)
    ax.plot(ns, ks, 'r-', linewidth=2, label='k (logical qubits = S_BH)')
    ax.plot(ns, ds, 'g-', linewidth=2, label='d (code distance)')
    ax.set_xlabel('Boundary Area (Planck units)')
    ax.set_ylabel('Code Parameter')
    ax.set_title('[[n, k, d]] vs Boundary Area')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Plot 2: Redundancy ratio
    ax = axes[0, 1]
    ax.plot(ns, redundancies, 'purple', linewidth=2)
    ax.axhline(y=0.75, color='red', linestyle='--', alpha=0.7, label='3/4 = 75%')
    ax.set_xlabel('Boundary Area (Planck units)')
    ax.set_ylabel('Redundancy Ratio (n-k)/n')
    ax.set_title('Holographic Redundancy: The 75% Tax')
    ax.set_ylim(0.7, 0.8)
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Plot 3: Erasure correction capacity
    ax = axes[1, 0]
    ax.plot(ns, erasure_caps, 'orange', linewidth=2, label='Erasure capacity')
    ax.plot(ns, [n // 4 for n in ns], 'blue', linewidth=1, linestyle='--',
            label='n/4 (Bekenstein-Hawking entropy)', alpha=0.7)
    ax.set_xlabel('Boundary Area (Planck units)')
    ax.set_ylabel('Max Correctable Erasures')
    ax.set_title('Error Correction Capacity')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Plot 4: Singleton bound visualization
    ax = axes[1, 1]
    n_vals = np.arange(4, 260, 4)
    k_vals = n_vals / 4
    d_max_standard = (n_vals + 2 - k_vals) / 2
    d_max_rt = (3 * n_vals + 8) / 8
    ax.fill_between(n_vals, 0, d_max_rt, alpha=0.3, color='green',
                    label='Allowed region (RT + Singleton)')
    ax.fill_between(n_vals, d_max_rt, d_max_standard, alpha=0.2, color='red',
                    label='Excluded by RT formula')
    ax.plot(n_vals, d_max_standard, 'r--', linewidth=1.5, label='Standard Singleton d_max')
    ax.plot(n_vals, d_max_rt, 'g-', linewidth=2, label='RT-strengthened d_max')
    ax.set_xlabel('Boundary Area (Planck units)')
    ax.set_ylabel('Maximum Code Distance d')
    ax.set_title('RT Formula Strengthens Singleton Bound')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('holographic_code_params.png', dpi=150, bbox_inches='tight')
    print("Saved: holographic_code_params.png")


if __name__ == '__main__':
    main()
