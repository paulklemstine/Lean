"""
Demo 6: The Seven North Poles — Grand Unified Visualization
=============================================================
A single comprehensive figure showing all seven Millennium Problems
as stereographic projections, each with its own sphere, north pole,
and local-global structure.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib.patches import Circle, FancyBboxPatch, Arc
from matplotlib.collections import LineCollection


def draw_mini_sphere(ax, cx, cy, r, color, north_pole_label, problem_name,
                     status='OPEN', annotations=None):
    """Draw a miniature sphere with marked north pole."""
    # Draw sphere outline
    theta = np.linspace(0, 2*np.pi, 200)
    ax.plot(cx + r*np.cos(theta), cy + r*np.sin(theta),
            color=color, linewidth=2, alpha=0.8)

    # Fill with gradient-like effect
    for dr in np.linspace(0, r, 20):
        circle = Circle((cx, cy), dr, fill=False, edgecolor=color,
                        alpha=0.03, linewidth=1)
        ax.add_patch(circle)

    # Equator line
    ax.plot([cx - r, cx + r], [cy, cy], color=color, linewidth=1, alpha=0.3)

    # North pole
    pole_x, pole_y = cx, cy + r * 0.9
    if status == 'SOLVED':
        ax.plot(pole_x, pole_y, 'o', color='#6bcb77', markersize=10,
                zorder=10, markeredgecolor='white', markeredgewidth=1.5)
        ax.text(pole_x, pole_y + r * 0.15, '✓', color='#6bcb77',
                fontsize=12, ha='center', fontweight='bold')
    else:
        ax.plot(pole_x, pole_y, 'o', color='red', markersize=10,
                zorder=10, markeredgecolor='white', markeredgewidth=1.5)
        ax.text(pole_x, pole_y + r * 0.15, 'N', color='red',
                fontsize=10, ha='center', fontweight='bold')

    # Problem name below
    ax.text(cx, cy - r - r * 0.2, problem_name, color='white',
            fontsize=10, fontweight='bold', ha='center', va='top')

    # North pole label
    ax.text(cx, cy + r + r * 0.35, north_pole_label, color=color,
            fontsize=7, ha='center', va='bottom', style='italic')

    # Status
    status_color = '#6bcb77' if status == 'SOLVED' else '#ff6b6b'
    ax.text(cx + r * 0.8, cy - r + r * 0.15, status,
            color=status_color, fontsize=7, fontweight='bold', ha='center',
            bbox=dict(boxstyle='round,pad=0.1', facecolor=status_color,
                      alpha=0.15, edgecolor=status_color))

    # Projection lines from north pole to "plane" below
    n_lines = 5
    for i in range(n_lines):
        angle = np.pi * 0.2 + i * np.pi * 0.6 / (n_lines - 1)
        # Point on sphere
        sx = cx + r * 0.8 * np.cos(angle)
        sy = cy + r * 0.8 * np.sin(angle) * 0.5  # Squish for perspective
        # Point on "plane" below
        px = cx + (sx - pole_x) * 2
        py = cy - r - r * 0.05

        ax.plot([pole_x, sx], [pole_y, sy], color=color, alpha=0.15,
                linewidth=0.5)
        ax.plot([sx, px], [sy, py], color=color, alpha=0.08,
                linewidth=0.5, linestyle='--')


def main():
    fig = plt.figure(figsize=(24, 20), facecolor='#0a0a2e')

    # Title
    fig.suptitle('THE SEVEN NORTH POLES\n'
                 'Each Millennium Problem as a Stereographic Projection',
                 color='white', fontsize=22, fontweight='bold', y=0.97)

    # Main area
    ax = fig.add_axes([0.02, 0.08, 0.96, 0.85], facecolor='#0a0a2e')
    ax.set_xlim([-1, 22])
    ax.set_ylim([-2, 14])
    ax.set_axis_off()

    # Define the seven problems
    problems = [
        {
            'name': 'POINCARÉ\nCONJECTURE',
            'pole': 'Ricci flow\nsingularity',
            'color': '#6bcb77',
            'status': 'SOLVED',
            'cx': 3, 'cy': 10.5, 'r': 1.5,
            'details': [
                'Local: Simply connected',
                'Global: ≅ S³',
                'Flow: Ricci flow',
                'Surgery: Cut & cap',
            ]
        },
        {
            'name': 'RIEMANN\nHYPOTHESIS',
            'pole': 'Archimedean\nplace',
            'color': '#ff6b6b',
            'status': 'OPEN',
            'cx': 8, 'cy': 10.5, 'r': 1.5,
            'details': [
                'Local: Euler product',
                'Global: Zeros on Re=½',
                'Flow: ???',
                'Pole type: II',
            ]
        },
        {
            'name': 'P vs NP',
            'pole': 'Search-decision\ngap',
            'color': '#ffd93d',
            'status': 'OPEN',
            'cx': 13, 'cy': 10.5, 'r': 1.5,
            'details': [
                'Local: Poly verification',
                'Global: Separation',
                'Flow: ???',
                'Pole type: III',
            ]
        },
        {
            'name': 'YANG-MILLS\nMASS GAP',
            'pole': 'UV divergence',
            'color': '#4d96ff',
            'status': 'OPEN',
            'cx': 18, 'cy': 10.5, 'r': 1.5,
            'details': [
                'Local: Perturbative QFT',
                'Global: Mass gap Δ>0',
                'Flow: RG flow',
                'Pole type: ?',
            ]
        },
        {
            'name': 'NAVIER-\nSTOKES',
            'pole': 'Vorticity\nblowup',
            'color': '#ff6bd6',
            'status': 'OPEN',
            'cx': 5.5, 'cy': 4.5, 'r': 1.5,
            'details': [
                'Local: Short-time exist.',
                'Global: All-time smooth',
                'Flow: NS flow itself',
                'Pole type: ?',
            ]
        },
        {
            'name': 'BIRCH &\nSWINNERTON-DYER',
            'pole': 'Ш group\nL(E,1)',
            'color': '#ff8c42',
            'status': 'OPEN',
            'cx': 10.5, 'cy': 4.5, 'r': 1.5,
            'details': [
                'Local: E(𝔽_p) each p',
                'Global: rank E(ℚ)',
                'Flow: p-adic?',
                'Pole type: II',
            ]
        },
        {
            'name': 'HODGE\nCONJECTURE',
            'pole': 'Topology-algebra\ngap',
            'color': '#a855f7',
            'status': 'OPEN',
            'cx': 15.5, 'cy': 4.5, 'r': 1.5,
            'details': [
                'Local: Smooth cycles',
                'Global: Algebraic cycles',
                'Flow: Deformation?',
                'Pole type: II',
            ]
        },
    ]

    for p in problems:
        draw_mini_sphere(ax, p['cx'], p['cy'], p['r'], p['color'],
                        p['pole'], p['name'], p['status'])

        # Draw detail text
        for j, detail in enumerate(p['details']):
            ax.text(p['cx'], p['cy'] - p['r'] - 0.6 - j * 0.3,
                   detail, color='#888899', fontsize=6.5, ha='center')

    # Draw connections
    connections = [
        (0, 3, 'Geometric Analysis'),
        (0, 4, 'PDE Singularities'),
        (1, 5, 'L-functions'),
        (1, 6, 'Cohomology'),
        (3, 4, 'Physics PDEs'),
        (5, 6, 'Algebraic Geometry'),
    ]

    for i, j, label in connections:
        p1, p2 = problems[i], problems[j]
        mid_x = (p1['cx'] + p2['cx']) / 2
        mid_y = (p1['cy'] + p2['cy']) / 2
        ax.plot([p1['cx'], p2['cx']], [p1['cy'], p2['cy']],
                color='white', alpha=0.08, linewidth=1, linestyle=':')
        ax.text(mid_x, mid_y, label, color='#444466', fontsize=5.5,
                ha='center', va='center', rotation=0)

    # Bottom quote
    ax.text(11, -1, '"The ancient Greeks drew maps of the Earth using stereographic projection.\n'
            'Two millennia later, mathematicians are using the same technique to map the landscape of unsolved mathematics.\n'
            'The sphere and the plane are equivalent. The local and the global are isomorphic.\n'
            'And the hardest problems in mathematics are all asking the same question, in different languages.\n'
            'The north pole is waiting."',
            color='#666688', fontsize=10, ha='center', va='center',
            style='italic', family='serif',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='#0a0a2e',
                      edgecolor='#333355', linewidth=1))

    plt.savefig('/workspace/request-project/oracle_council/demos/demo6_seven_north_poles.png',
                dpi=150, bbox_inches='tight', facecolor='#0a0a2e')
    plt.close()
    print("✓ Saved: demo6_seven_north_poles.png")


if __name__ == '__main__':
    main()
