"""
Demo 4: The Millennium Problem Landscape
==========================================
A comprehensive visualization mapping all seven Millennium Problems
onto a unified landscape, showing their local-global structure,
obstruction types, and interconnections.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
import matplotlib.gridspec as gridspec


def draw_problem_card(ax, problem_data, y_pos):
    """Draw a single problem card."""
    name, status, local, globe, pole, pole_type, color = problem_data

    # Background card
    card = FancyBboxPatch((0.02, y_pos - 0.04), 0.96, 0.11,
                           boxstyle="round,pad=0.01",
                           facecolor=color, alpha=0.12,
                           edgecolor=color, linewidth=2,
                           transform=ax.transAxes)
    ax.add_patch(card)

    # Status indicator
    if status == 'SOLVED':
        status_color = '#6bcb77'
        status_symbol = '✓'
    else:
        status_color = '#ff6b6b'
        status_symbol = '?'

    ax.text(0.04, y_pos + 0.04, status_symbol, color=status_color,
            fontsize=18, fontweight='bold', transform=ax.transAxes,
            va='center', ha='center',
            bbox=dict(boxstyle='circle', facecolor=status_color, alpha=0.2))

    # Problem name
    ax.text(0.09, y_pos + 0.055, name, color='white', fontsize=12,
            fontweight='bold', transform=ax.transAxes, va='center')

    # Local/Global/Pole info
    ax.text(0.09, y_pos + 0.02, f'Local: {local}', color='#4d96ff',
            fontsize=8, transform=ax.transAxes, va='center')
    ax.text(0.40, y_pos + 0.02, f'Global: {globe}', color='#ff6b6b',
            fontsize=8, transform=ax.transAxes, va='center')
    ax.text(0.72, y_pos + 0.02, f'North Pole: {pole}', color='#ffd93d',
            fontsize=8, transform=ax.transAxes, va='center')

    # Pole type indicator
    type_colors = {'I': '#6bcb77', 'II': '#ffd93d', 'III': '#ff6b6b', '?': '#888888'}
    ax.text(0.95, y_pos + 0.04, f'Type {pole_type}',
            color=type_colors.get(pole_type, '#888888'),
            fontsize=9, fontweight='bold', transform=ax.transAxes,
            va='center', ha='center',
            bbox=dict(boxstyle='round,pad=0.3',
                      facecolor=type_colors.get(pole_type, '#888888'),
                      alpha=0.2, edgecolor=type_colors.get(pole_type, '#888888')))


def draw_connections_web(ax):
    """Draw the interconnections between problems."""
    ax.set_facecolor('#0a0a2e')
    ax.set_xlim([0, 10])
    ax.set_ylim([0, 10])
    ax.set_axis_off()
    ax.set_title('Interconnection Web\nof the Millennium Problems',
                 color='white', fontsize=14, fontweight='bold', pad=15)

    # Problem positions on a circle
    problems = [
        ('Poincaré\n✓', '#6bcb77'),
        ('Riemann', '#ff6b6b'),
        ('P vs NP', '#ffd93d'),
        ('Yang-Mills', '#4d96ff'),
        ('Navier-\nStokes', '#ff6bd6'),
        ('BSD', '#ff8c42'),
        ('Hodge', '#a855f7'),
    ]

    n = len(problems)
    angles = np.linspace(0, 2*np.pi, n, endpoint=False) - np.pi/2
    cx, cy = 5, 5
    r = 3.5

    positions = []
    for i, (name, color) in enumerate(problems):
        x = cx + r * np.cos(angles[i])
        y = cy + r * np.sin(angles[i])
        positions.append((x, y))

        # Node
        circle = plt.Circle((x, y), 0.6, facecolor=color, alpha=0.3,
                            edgecolor=color, linewidth=2)
        ax.add_patch(circle)
        ax.text(x, y, name, color='white', fontsize=8, fontweight='bold',
                ha='center', va='center')

    # Connections (selected meaningful ones)
    connections = [
        (0, 1, 'Topology ↔\nArithmetic', '#aaaaaa'),    # Poincaré - Riemann
        (0, 3, 'Geometric\nAnalysis', '#aaaaaa'),         # Poincaré - Yang-Mills
        (0, 4, 'PDE\nSingularities', '#aaaaaa'),          # Poincaré - Navier-Stokes
        (1, 5, 'L-functions', '#ff8c42'),                  # Riemann - BSD
        (1, 6, 'Cohomology', '#a855f7'),                   # Riemann - Hodge
        (3, 4, 'Fluid/Gauge\nTheory', '#4d96ff'),          # Yang-Mills - Navier-Stokes
        (5, 6, 'Algebraic\nGeometry', '#ffd93d'),          # BSD - Hodge
        (2, 3, 'Computational\nComplexity', '#ffd93d'),    # P vs NP - Yang-Mills
    ]

    for i, j, label, color in connections:
        x1, y1 = positions[i]
        x2, y2 = positions[j]
        mid_x = (x1 + x2) / 2
        mid_y = (y1 + y2) / 2

        ax.plot([x1, x2], [y1, y2], color=color, alpha=0.3, linewidth=1.5,
                linestyle='--')
        ax.text(mid_x, mid_y, label, color=color, fontsize=6, ha='center',
                va='center', alpha=0.7,
                bbox=dict(boxstyle='round,pad=0.15', facecolor='#0a0a2e',
                          edgecolor='none', alpha=0.8))

    # Central "North Pole" label
    ax.text(cx, cy, 'N', color='red', fontsize=28, fontweight='bold',
            ha='center', va='center', alpha=0.3)
    ax.text(cx, cy - 0.6, 'The Universal\nNorth Pole', color='red',
            fontsize=8, ha='center', style='italic', alpha=0.5)


def draw_type_spectrum(ax):
    """Draw the spectrum of north pole types."""
    ax.set_facecolor('#0a0a2e')
    ax.set_xlim([0, 10])
    ax.set_ylim([0, 3])
    ax.set_axis_off()
    ax.set_title('Taxonomy of North Poles',
                 color='white', fontsize=14, fontweight='bold', pad=10)

    types = [
        ('Type I\nREMOVABLE', '#6bcb77',
         'The singularity is an\nartifact of description.\nSurgery removes it.\n\nEx: Poincaré ✓'),
        ('Type II\nQUANTIFIABLE', '#ffd93d',
         'The singularity is real\nbut finite & structured.\nIt encodes information.\n\nEx: RH, BSD, Hodge'),
        ('Type III\nESSENTIAL', '#ff6b6b',
         'The singularity is\nfundamental. It cannot\nbe removed.\n\nEx: P ≠ NP (if true)'),
    ]

    for i, (title, color, desc) in enumerate(types):
        x = 1.5 + i * 3.3

        # Box
        box = FancyBboxPatch((x - 1.2, 0.3), 2.8, 2.2,
                              boxstyle="round,pad=0.1",
                              facecolor=color, alpha=0.1,
                              edgecolor=color, linewidth=2)
        ax.add_patch(box)

        ax.text(x + 0.2, 2.2, title, color=color, fontsize=12,
                fontweight='bold', ha='center', va='center')
        ax.text(x + 0.2, 1.2, desc, color='#aaaacc', fontsize=8,
                ha='center', va='center')

    # Arrows between types
    for i in range(2):
        x1 = 1.5 + i * 3.3 + 1.4
        x2 = 1.5 + (i+1) * 3.3 - 1.2
        ax.annotate('', xy=(x2, 1.4), xytext=(x1, 1.4),
                     arrowprops=dict(arrowstyle='->', color='white',
                                     lw=1.5, alpha=0.5))


def main():
    fig = plt.figure(figsize=(22, 22), facecolor='#0a0a2e')
    gs = gridspec.GridSpec(3, 2, figure=fig, hspace=0.25, wspace=0.2,
                           height_ratios=[1.4, 1, 0.7])

    # ===== Panel 1: Problem Cards =====
    ax1 = fig.add_subplot(gs[0, :])
    ax1.set_facecolor('#0a0a2e')
    ax1.set_xlim([0, 1])
    ax1.set_ylim([0, 1])
    ax1.set_axis_off()
    ax1.set_title('THE SEVEN MILLENNIUM PROBLEMS — Local-Global Atlas',
                   color='white', fontsize=18, fontweight='bold', pad=20)

    problems = [
        ('Poincaré Conjecture', 'SOLVED', 'Simply connected', 'Homeomorphic to S³',
         'Ricci flow singularity', 'I', '#6bcb77'),
        ('Riemann Hypothesis', 'OPEN', 'Euler product (Re s > 1)', 'Zeros on Re s = ½',
         'Critical strip / archimedean place', 'II', '#ff6b6b'),
        ('P vs NP', 'OPEN', 'Polynomial verification', 'Complexity separation',
         'Search-decision gap', 'III', '#ffd93d'),
        ('Yang-Mills Mass Gap', 'OPEN', 'Perturbative QFT', 'Non-perturbative mass gap',
         'UV divergence / strong coupling', '?', '#4d96ff'),
        ('Navier-Stokes', 'OPEN', 'Short-time existence', 'Global smooth solutions',
         'Vorticity blowup', '?', '#ff6bd6'),
        ('Birch & Swinnerton-Dyer', 'OPEN', 'E(𝔽_p) for each prime p', 'rank E(ℚ)',
         'Ш group / L(E,1)', 'II', '#ff8c42'),
        ('Hodge Conjecture', 'OPEN', 'Smooth cohomology classes', 'Algebraic representatives',
         'Topology-algebra gap', 'II', '#a855f7'),
    ]

    for i, p in enumerate(problems):
        draw_problem_card(ax1, p, 0.87 - i * 0.125)

    # ===== Panel 2: Connection Web =====
    ax2 = fig.add_subplot(gs[1, 0])
    draw_connections_web(ax2)

    # ===== Panel 3: Historical Timeline =====
    ax3 = fig.add_subplot(gs[1, 1], facecolor='#0a0a2e')
    ax3.set_title('Historical Arc: From Stereographic Projection to Millennium Problems',
                   color='white', fontsize=13, fontweight='bold', pad=15)

    events = [
        (150, 'Hipparchus\nStereographic\nprojection', '#ffd93d'),
        (300, 'Pappus\nProjective\ngeometry', '#ffd93d'),
        (1590, 'Galileo\nProjection in\nastronomy', '#ff8c42'),
        (1859, 'Riemann\nZeta function\n& hypothesis', '#ff6b6b'),
        (1904, 'Poincaré\nThe conjecture', '#6bcb77'),
        (1950, 'Hodge\nThe conjecture', '#a855f7'),
        (1965, 'BSD\nConjecture', '#ff8c42'),
        (2000, 'Clay\nMillennium\nPrizes', '#4d96ff'),
        (2003, 'Perelman\nPoincaré\nSOLVED ✓', '#6bcb77'),
    ]

    # Logarithmic-ish time axis
    min_year, max_year = 100, 2050
    ax3.set_xlim([min_year - 50, max_year + 50])
    ax3.set_ylim([-1, 2.5])

    # Timeline
    ax3.axhline(y=0, color='white', linewidth=2, alpha=0.3)

    for i, (year, label, color) in enumerate(events):
        direction = 1 if i % 2 == 0 else -0.6
        ax3.plot(year, 0, 'o', color=color, markersize=10, zorder=5)
        ax3.plot([year, year], [0, direction * 0.8], color=color,
                 linewidth=1.5, alpha=0.5)
        ax3.text(year, direction * 1.0, label, color=color, fontsize=7,
                 ha='center', va='center' if direction > 0 else 'top',
                 fontweight='bold')
        ax3.text(year, -0.15 if direction > 0 else 0.15,
                 str(year), color='white', fontsize=6, ha='center',
                 alpha=0.5)

    ax3.set_axis_off()

    # ===== Panel 4: Type Spectrum =====
    ax4 = fig.add_subplot(gs[2, :])
    draw_type_spectrum(ax4)

    fig.suptitle('THE ORACLE COUNCIL — Mapping the Landscape of Unsolved Mathematics\n'
                 '"The sphere and the plane are equivalent. The local and the global are isomorphic."',
                 color='white', fontsize=20, fontweight='bold', y=0.995,
                 fontstyle='italic')

    plt.savefig('/workspace/request-project/oracle_council/demos/demo4_millennium_landscape.png',
                dpi=150, bbox_inches='tight', facecolor='#0a0a2e')
    plt.close()
    print("✓ Saved: demo4_millennium_landscape.png")


if __name__ == '__main__':
    main()
