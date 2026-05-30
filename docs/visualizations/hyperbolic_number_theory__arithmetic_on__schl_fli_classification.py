"""
Visualization 3: Schläfli Classification of Tessellations
==========================================================
Shows the landscape of {p,q} tessellations, classifying them as
spherical (Platonic solids), Euclidean (floor tilings), or hyperbolic.
Illustrates the proved theorem: (p-2)(q-2) > 4 ↔ 1/p + 1/q < 1/2.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import RegularPolygon
import matplotlib.patches as mpatches


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7.5))
    
    # ── Left panel: Classification grid ──
    ax = axes[0]
    
    p_range = range(3, 12)
    q_range = range(3, 12)
    
    for p in p_range:
        for q in q_range:
            product = (p - 2) * (q - 2)
            val = 1.0/p + 1.0/q
            
            if product < 4:
                color = '#3498db'  # Blue = spherical
                marker = 'o'
            elif product == 4:
                color = '#2ecc71'  # Green = Euclidean
                marker = 's'
            else:
                color = '#e74c3c'  # Red = hyperbolic
                marker = '^'
            
            size = min(200, 50 + product * 8)
            ax.scatter(p, q, c=color, marker=marker, s=size,
                      edgecolors='black', linewidth=0.5, zorder=3)
    
    # Draw the boundary curve 1/p + 1/q = 1/2
    p_cont = np.linspace(2.01, 12, 200)
    q_boundary = 1.0 / (0.5 - 1.0/p_cont)
    valid = (q_boundary > 2) & (q_boundary < 12)
    ax.plot(p_cont[valid], q_boundary[valid], 'k-', linewidth=2,
            label='(p-2)(q-2) = 4')
    
    # Labels for known tessellations
    labels = {
        (3, 3): 'Tetra', (4, 3): 'Cube', (3, 4): 'Octa',
        (5, 3): 'Dodeca', (3, 5): 'Icosa',
        (3, 6): '△', (4, 4): '□', (6, 3): '⬡',
        (7, 3): '{7,3}', (5, 4): '{5,4}', (4, 5): '{4,5}',
    }
    for (p, q), label in labels.items():
        ax.annotate(label, (p, q), textcoords="offset points",
                   xytext=(8, 5), fontsize=8, fontweight='bold')
    
    # Legend
    legend_elements = [
        mpatches.Patch(facecolor='#3498db', edgecolor='black', label='Spherical: (p-2)(q-2) < 4'),
        mpatches.Patch(facecolor='#2ecc71', edgecolor='black', label='Euclidean: (p-2)(q-2) = 4'),
        mpatches.Patch(facecolor='#e74c3c', edgecolor='black', label='Hyperbolic: (p-2)(q-2) > 4'),
    ]
    ax.legend(handles=legend_elements, loc='upper right', fontsize=10)
    
    ax.set_xlabel('p (sides per polygon)', fontsize=12)
    ax.set_ylabel('q (polygons per vertex)', fontsize=12)
    ax.set_title('Schläfli Classification of {p,q} Tessellations\n(Theorem schlafli_hyperbolic_condition)',
                fontsize=13, fontweight='bold')
    ax.set_xlim(2.5, 11.5)
    ax.set_ylim(2.5, 11.5)
    ax.grid(True, alpha=0.2)
    
    # ── Right panel: Hyperbolic area growth comparison ──
    ax2 = axes[1]
    
    R = np.linspace(0.01, 8, 500)
    
    # Hyperbolic area: 4π sinh²(R/2)
    hyp_area = 4 * np.pi * np.sinh(R/2)**2
    
    # Euclidean area: πR²
    euc_area = np.pi * R**2
    
    # Spherical area: 4π sin²(R/2) (for R < π)
    sph_area = np.where(R < np.pi, 4 * np.pi * np.sin(R/2)**2, 4*np.pi)
    
    ax2.semilogy(R, hyp_area, 'r-', linewidth=2.5, label='Hyperbolic: 4π sinh²(R/2)')
    ax2.semilogy(R, euc_area, 'g-', linewidth=2.5, label='Euclidean: πR²')
    ax2.semilogy(R, sph_area, 'b-', linewidth=2.5, label='Spherical: 4π sin²(R/2)')
    
    # Asymptotic: π·e^R
    ax2.semilogy(R, np.pi * np.exp(R), 'r:', linewidth=1.5, alpha=0.5,
                 label='Asymptote: πe^R')
    
    ax2.set_xlabel('Radius R', fontsize=12)
    ax2.set_ylabel('Area of disk of radius R', fontsize=12)
    ax2.set_title('Area Growth in Three Geometries\n(Hyperbolic grows exponentially)',
                  fontsize=13, fontweight='bold')
    ax2.legend(fontsize=10, loc='upper left')
    ax2.grid(True, alpha=0.3)
    ax2.set_xlim(0, 8)
    ax2.set_ylim(0.01, 1e4)
    
    plt.tight_layout()
    plt.savefig('viz_schlafli.png', dpi=150, bbox_inches='tight')
    print("Saved viz_schlafli.png")


if __name__ == "__main__":
    main()
