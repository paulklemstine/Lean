#!/usr/bin/env python3
"""
Visualization: Bifurcation diagram of the logistic map family f_r(x) = rx(1-x).
Shows the transition from periodic to chaotic behavior as r increases.
"""

import numpy as np
import matplotlib.pyplot as plt


def compute_bifurcation(r_min: float = 2.5, r_max: float = 4.0,
                        r_steps: int = 2000, n_iterate: int = 300,
                        n_show: int = 100) -> tuple:
    """Compute bifurcation diagram data."""
    rs = np.linspace(r_min, r_max, r_steps)
    all_r = []
    all_x = []
    
    for r in rs:
        x = 0.5
        # Transient
        for _ in range(n_iterate):
            x = r * x * (1.0 - x)
        # Record
        for _ in range(n_show):
            x = r * x * (1.0 - x)
            all_r.append(r)
            all_x.append(x)
    
    return np.array(all_r), np.array(all_x)


def main():
    print("Computing bifurcation diagram...")
    r_vals, x_vals = compute_bifurcation()
    
    fig, ax = plt.subplots(figsize=(12, 7))
    ax.scatter(r_vals, x_vals, s=0.01, c='black', alpha=0.3)
    ax.set_xlabel('Parameter r', fontsize=14)
    ax.set_ylabel('Attractor values x', fontsize=14)
    ax.set_title('Bifurcation Diagram: f(x) = rx(1−x)\n'
                 'Polynomial degree-2 dynamics from order to chaos', fontsize=16)
    ax.axvline(x=4.0, color='red', linestyle='--', alpha=0.5, label='r=4 (full chaos)')
    ax.legend(fontsize=12)
    ax.set_xlim(2.5, 4.0)
    ax.set_ylim(0, 1)
    
    plt.tight_layout()
    plt.savefig('bifurcation_diagram.png', dpi=150)
    print("Saved: bifurcation_diagram.png")
    plt.close()


if __name__ == "__main__":
    main()
