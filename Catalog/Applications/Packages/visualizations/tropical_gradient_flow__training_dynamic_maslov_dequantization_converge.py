"""
Visualization: Maslov Dequantization Convergence
=================================================

Shows how the soft maximum converges to the hard maximum as t → ∞.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib


def maslov_soft_max(t, a, b):
    m = np.maximum(a, b)
    return m + (1.0 / t) * np.log(np.exp(t * (a - m)) + np.exp(t * (b - m)))


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Panel 1: MSM(t, a, 0) for different t values
    ax = axes[0]
    a_range = np.linspace(-3, 3, 500)
    b = 0.0
    for t in [0.5, 1, 2, 5, 20]:
        msm = maslov_soft_max(t, a_range, b)
        ax.plot(a_range, msm, label=f't = {t}', alpha=0.8)
    ax.plot(a_range, np.maximum(a_range, b), 'k--', linewidth=2, label='max(a, 0)')
    ax.set_xlabel('a', fontsize=12)
    ax.set_ylabel('MSM(t, a, 0)', fontsize=12)
    ax.set_title('Maslov Soft Max → Hard Max', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Panel 2: Error vs t
    ax = axes[1]
    t_range = np.linspace(0.5, 50, 200)
    pairs = [(1, 2), (0, 0), (-1, 3), (5, 5)]
    for a, b in pairs:
        errors = [abs(maslov_soft_max(t, a, b) - max(a, b)) for t in t_range]
        ax.plot(t_range, errors, label=f'a={a}, b={b}', alpha=0.8)
    ax.plot(t_range, np.log(2) / t_range, 'k--', linewidth=2, label='log(2)/t bound')
    ax.set_xlabel('t (temperature)', fontsize=12)
    ax.set_ylabel('|MSM - max|', fontsize=12)
    ax.set_title('Dequantization Error ≤ log(2)/t', fontsize=13)
    ax.legend(fontsize=9)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)
    
    # Panel 3: 2D heatmap of error
    ax = axes[2]
    a_grid = np.linspace(-2, 2, 100)
    t_grid = np.linspace(1, 20, 100)
    A, T = np.meshgrid(a_grid, t_grid)
    b_val = 0.0
    errors = np.abs(maslov_soft_max(T, A, b_val) - np.maximum(A, b_val))
    im = ax.pcolormesh(A, T, errors, cmap='viridis', shading='auto')
    plt.colorbar(im, ax=ax, label='Error')
    ax.set_xlabel('a', fontsize=12)
    ax.set_ylabel('t', fontsize=12)
    ax.set_title('Error Heatmap (b=0)', fontsize=13)
    
    plt.suptitle('Maslov Dequantization: Tropical Limit of Soft Maximum', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('maslov_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: maslov_convergence.png")


if __name__ == "__main__":
    main()
