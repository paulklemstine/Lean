#!/usr/bin/env python3
"""
Visualization: Entropy Uncertainty Surface

Plots the entropy sum S_spec + S_cls as a function over the simplex of
spectral distributions for S₃. The log(r) floor is visible as a horizontal
plane. Points below this plane would violate the entropy uncertainty principle.
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D


def compute_entropies_S3():
    """Compute spectral and class entropies for S₃ parameterized over the simplex."""
    # S₃ character table
    char_table = np.array([[1,1,1],[1,-1,1],[2,0,-1]], dtype=complex)
    class_sizes = np.array([1, 3, 2])
    order = 6
    r = 3

    # Parameterize class functions by spectral coefficients a = (a1, a2, a3)
    # f = a1*χ1 + a2*χ2 + a3*χ3
    # Use barycentric-like coordinates: a = (t1, t2, 1-t1-t2) on simplex
    n_points = 80
    t1_vals = np.linspace(0.01, 0.98, n_points)
    t2_vals = np.linspace(0.01, 0.98, n_points)

    T1, T2 = np.meshgrid(t1_vals, t2_vals)
    S_total = np.full_like(T1, np.nan)

    for i in range(n_points):
        for j in range(n_points):
            a1, a2 = T1[i, j], T2[i, j]
            a3 = 1.0 - a1 - a2
            if a3 <= 0.01:
                continue

            # Spectral coefficients
            a = np.array([a1, a2, a3])

            # Reconstruct f on conjugacy classes
            f_vals = np.zeros(r, dtype=complex)
            for k in range(r):
                f_vals[k] = np.sum(a * char_table[:, k])

            # Spectral entropy
            p = a ** 2
            p_total = np.sum(p)
            if p_total < 1e-15:
                continue
            p_norm = p / p_total
            p_pos = p_norm[p_norm > 1e-15]
            s_spec = -np.sum(p_pos * np.log(p_pos))

            # Class entropy
            q = class_sizes * np.abs(f_vals) ** 2 / order
            q_total = np.sum(q)
            if q_total < 1e-15:
                continue
            q_norm = q / q_total
            q_pos = q_norm[q_norm > 1e-15]
            s_cls = -np.sum(q_pos * np.log(q_pos))

            S_total[i, j] = s_spec + s_cls

    return T1, T2, S_total


def plot_entropy_surface():
    T1, T2, S_total = compute_entropies_S3()
    r = 3
    log_r = np.log(r)

    fig = plt.figure(figsize=(14, 6))

    # 3D surface plot
    ax1 = fig.add_subplot(121, projection='3d')

    # Mask NaN values
    mask = ~np.isnan(S_total)

    surf = ax1.plot_surface(T1, T2, S_total, cmap='viridis',
                            alpha=0.8, edgecolor='none')

    # Add the log(r) floor plane
    xx = np.linspace(0, 1, 10)
    yy = np.linspace(0, 1, 10)
    XX, YY = np.meshgrid(xx, yy)
    ZZ = np.full_like(XX, log_r)
    ax1.plot_surface(XX, YY, ZZ, alpha=0.3, color='red')

    ax1.set_xlabel('a₁ (trivial)', fontsize=10)
    ax1.set_ylabel('a₂ (sign)', fontsize=10)
    ax1.set_zlabel('S_spec + S_cls', fontsize=10)
    ax1.set_title('Entropy Sum over Spectral Simplex (S₃)\nRed plane = log(3) floor',
                  fontsize=12, fontweight='bold')
    ax1.view_init(elev=25, azim=135)

    # 2D contour plot
    ax2 = fig.add_subplot(122)
    levels = np.linspace(log_r - 0.1, np.nanmax(S_total), 20)
    contour = ax2.contourf(T1, T2, S_total, levels=levels, cmap='viridis')
    plt.colorbar(contour, ax=ax2, label='S_spec + S_cls')

    # Draw the simplex boundary
    ax2.plot([0, 1], [0, 0], 'k-', linewidth=2)
    ax2.plot([0, 0], [0, 1], 'k-', linewidth=2)
    ax2.plot([0, 1], [1, 0], 'k-', linewidth=2)

    # Mark the vertices (pure characters)
    vertices = [(0.98, 0.01), (0.01, 0.98), (0.01, 0.01)]
    labels = ['χ₁', 'χ₂', 'χ₃']
    for (x, y), label in zip(vertices, labels):
        ax2.plot(x, y, 'r*', markersize=15, zorder=5)
        ax2.annotate(label, (x, y), textcoords="offset points",
                    xytext=(10, 10), fontsize=12, fontweight='bold', color='red')

    # Add log(r) contour
    ax2.contour(T1, T2, S_total, levels=[log_r], colors='red',
               linewidths=2, linestyles='--')

    ax2.set_xlabel('a₁ (trivial character weight)', fontsize=10)
    ax2.set_ylabel('a₂ (sign character weight)', fontsize=10)
    ax2.set_title('Contour Plot of Entropy Sum\nDashed red = log(3) = {:.3f}'.format(log_r),
                  fontsize=12, fontweight='bold')
    ax2.set_xlim(0, 1)
    ax2.set_ylim(0, 1)

    plt.tight_layout()
    plt.savefig("entropy_surface.png", dpi=150, bbox_inches='tight')
    print("Saved: entropy_surface.png")


if __name__ == "__main__":
    plot_entropy_surface()
