#!/usr/bin/env python3
"""
Demo 4: The Zariski Topology — Closed Sets as Vanishing Loci
=============================================================
Visualizes V(I) ↔ I for polynomial rings, showing how ideals
correspond to geometric vanishing sets in the plane.

Run: python demo4_zariski_topology.py
Output: zariski_topology.png
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

def create_zariski_topology():
    fig, axes = plt.subplots(2, 3, figsize=(18, 12))
    fig.suptitle('The Zariski Topology: Ideals ↔ Closed Sets in 𝔸²',
                 fontsize=20, fontweight='bold', fontfamily='serif', y=0.98)

    t = np.linspace(-3, 3, 1000)
    xx, yy = np.meshgrid(np.linspace(-3, 3, 500), np.linspace(-3, 3, 500))

    examples = [
        {
            'title': 'V(x) — the y-axis',
            'ideal': 'I = (x)',
            'desc': 'Points where x = 0',
            'plot': lambda ax: ax.axvline(x=0, color='#e94560', lw=3),
            'color': '#e94560'
        },
        {
            'title': 'V(x² + y² - 1) — unit circle',
            'ideal': 'I = (x² + y² − 1)',
            'desc': 'Points where x² + y² = 1',
            'plot': lambda ax: ax.contour(xx, yy, xx**2 + yy**2 - 1,
                                           levels=[0], colors=['#0f3460'], linewidths=3),
            'color': '#0f3460'
        },
        {
            'title': 'V(y - x²) — parabola',
            'ideal': 'I = (y − x²)',
            'desc': 'Points where y = x²',
            'plot': lambda ax: ax.plot(t, t**2, color='#533483', lw=3),
            'color': '#533483'
        },
        {
            'title': 'V(xy) — coordinate axes',
            'ideal': 'I = (xy)',
            'desc': 'Points where xy = 0',
            'plot': lambda ax: (ax.axhline(y=0, color='#2196F3', lw=3),
                                ax.axvline(x=0, color='#2196F3', lw=3)),
            'color': '#2196F3'
        },
        {
            'title': 'V(x-1, y-2) — single point',
            'ideal': 'I = (x−1, y−2)',
            'desc': 'The point (1, 2)',
            'plot': lambda ax: ax.plot(1, 2, 'o', markersize=15, color='#4CAF50',
                                       markeredgecolor='#1a1a2e', markeredgewidth=2),
            'color': '#4CAF50'
        },
        {
            'title': 'V(y² - x³ + x) — elliptic curve',
            'ideal': 'I = (y² − x³ + x)',
            'desc': 'Points where y² = x³ − x',
            'plot': lambda ax: ax.contour(xx, yy, yy**2 - xx**3 + xx,
                                           levels=[0], colors=['#FF9800'], linewidths=3),
            'color': '#FF9800'
        },
    ]

    for idx, ex in enumerate(examples):
        ax = axes[idx // 3][idx % 3]
        ax.set_xlim(-3, 3)
        ax.set_ylim(-3, 3)
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.2)
        ax.axhline(y=0, color='#cccccc', lw=0.5)
        ax.axvline(x=0, color='#cccccc', lw=0.5)

        # Background: complement is "open"
        ax.set_facecolor('#f8f9fa')

        # Plot the variety
        ex['plot'](ax)

        ax.set_title(ex['title'], fontsize=13, fontweight='bold',
                     fontfamily='serif', color=ex['color'])
        ax.text(0.02, 0.98, ex['ideal'], transform=ax.transAxes,
                fontsize=10, va='top', ha='left', color=ex['color'],
                fontfamily='serif', style='italic',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='white', alpha=0.8))
        ax.text(0.02, 0.88, ex['desc'], transform=ax.transAxes,
                fontsize=9, va='top', ha='left', color='#666666',
                fontfamily='serif')

    plt.tight_layout()
    plt.savefig('zariski_topology.png', dpi=200, bbox_inches='tight',
                facecolor='white')
    print("✓ Saved zariski_topology.png")
    plt.close()

if __name__ == '__main__':
    create_zariski_topology()
