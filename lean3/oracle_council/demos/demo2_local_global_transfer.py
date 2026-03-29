"""
Demo 2: Local-Global Transfer Visualization
=============================================
Shows how local data on charts fails to determine global structure
when the north pole (obstruction) is present, and how removing the
obstruction restores the transfer.

Part of the Oracle Council research project.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib.colors import LinearSegmentedColormap


def make_custom_cmap():
    """Dark-themed colormap."""
    colors = ['#0a0a2e', '#1a0a4e', '#4a0a8e', '#8a2be2', '#ff6bd6', '#ffd93d']
    return LinearSegmentedColormap.from_list('oracle', colors, N=256)


def draw_mobius_flow(ax, title, has_obstruction=True):
    """Draw a flow field showing local-global transfer with/without obstruction."""
    x = np.linspace(-3, 3, 30)
    y = np.linspace(-3, 3, 30)
    X, Y = np.meshgrid(x, y)
    R = np.sqrt(X**2 + Y**2)

    if has_obstruction:
        # Flow with a singularity at origin (the "north pole")
        denom = (R**2 + 0.1)
        U = -Y / denom + 0.1 * X / denom
        V = X / denom + 0.1 * Y / denom

        # Mark singularity
        ax.plot(0, 0, 'o', color='red', markersize=15, zorder=10,
                markeredgecolor='white', markeredgewidth=2)
        ax.text(0, 0.4, 'NORTH\nPOLE', color='red', fontsize=8,
                ha='center', fontweight='bold')
    else:
        # Smooth flow (obstruction removed)
        U = -Y * np.exp(-R**2 / 8)
        V = X * np.exp(-R**2 / 8)

        ax.plot(0, 0, 'o', color='#6bcb77', markersize=15, zorder=10,
                markeredgecolor='white', markeredgewidth=2)
        ax.text(0, 0.4, 'REMOVED', color='#6bcb77', fontsize=8,
                ha='center', fontweight='bold')

    speed = np.sqrt(U**2 + V**2)
    speed_norm = speed / (speed.max() + 1e-10)

    ax.streamplot(X, Y, U, V, color=speed_norm, cmap='plasma',
                  density=1.5, linewidth=1.5, arrowsize=1.5,
                  arrowstyle='->')

    ax.set_xlim([-3, 3])
    ax.set_ylim([-3, 3])
    ax.set_aspect('equal')
    ax.set_title(title, color='white', fontsize=13, fontweight='bold', pad=10)
    ax.set_facecolor('#0a0a2e')
    ax.tick_params(colors='white', labelsize=8)
    for spine in ax.spines.values():
        spine.set_color('#333366')


def draw_covering_charts(ax, title, n_charts=4, show_gap=True):
    """Draw overlapping charts covering a circle, possibly with a gap."""
    theta = np.linspace(0, 2*np.pi, 200)
    R = 2.0
    ax.plot(R*np.cos(theta), R*np.sin(theta), color='cyan', linewidth=2, alpha=0.5)

    chart_colors = ['#ff6b6b', '#ffd93d', '#6bcb77', '#4d96ff']
    chart_angles = np.linspace(0, 2*np.pi, n_charts, endpoint=False)
    chart_width = 2*np.pi / n_charts

    if show_gap:
        coverage = 1.0  # Each chart covers exactly its share (no overlap at north)
    else:
        coverage = 1.4  # Charts overlap generously

    for i in range(n_charts):
        a_start = chart_angles[i] - chart_width * coverage / 2
        a_end = chart_angles[i] + chart_width * coverage / 2
        a = np.linspace(a_start, a_end, 100)

        # Draw arc
        ax.plot(R*np.cos(a), R*np.sin(a), color=chart_colors[i % len(chart_colors)],
                linewidth=6, alpha=0.7, solid_capstyle='round')

        # Label
        mid_a = chart_angles[i]
        label_r = R + 0.5
        ax.text(label_r*np.cos(mid_a), label_r*np.sin(mid_a),
                f'U_{i+1}', color=chart_colors[i % len(chart_colors)],
                fontsize=11, ha='center', va='center', fontweight='bold')

    if show_gap:
        # Mark the gap (north pole)
        gap_angle = chart_angles[0] + chart_width / 2  # Between chart 1 and 2
        gap_a = np.linspace(gap_angle - 0.15, gap_angle + 0.15, 20)
        ax.plot(R*np.cos(gap_a), R*np.sin(gap_a), color='red',
                linewidth=6, alpha=0.9)
        ax.annotate('GAP\n(North Pole)', xy=(R*np.cos(gap_angle), R*np.sin(gap_angle)),
                     xytext=(0, 0.3), color='red', fontsize=10, fontweight='bold',
                     ha='center', arrowprops=dict(arrowstyle='->', color='red'))

    ax.set_xlim([-3.5, 3.5])
    ax.set_ylim([-3.5, 3.5])
    ax.set_aspect('equal')
    ax.set_title(title, color='white', fontsize=13, fontweight='bold', pad=10)
    ax.set_facecolor('#0a0a2e')
    ax.set_axis_off()


def draw_energy_landscape(ax, title, has_gap=True):
    """Draw an energy/potential landscape with or without a mass gap."""
    x = np.linspace(-4, 4, 500)

    if has_gap:
        # Mexican hat potential with gap
        V = (x**2 - 1)**2 + 0.5
        gap_y = 0.5
        min_y = 0.5

        # Mark the mass gap
        ax.annotate('', xy=(2.5, 0), xytext=(2.5, gap_y),
                     arrowprops=dict(arrowstyle='<->', color='#ffd93d', lw=2))
        ax.text(3.0, gap_y/2, 'MASS\nGAP\nΔ > 0', color='#ffd93d',
                fontsize=10, fontweight='bold', va='center')

        # Mark north pole
        ax.plot(0, V[250], 'v', color='red', markersize=15, zorder=10)
        ax.text(0, V[250] + 0.3, 'North Pole\n(Unstable)', color='red',
                fontsize=9, ha='center', fontweight='bold')
    else:
        # Flat bottom potential (no gap, massless)
        V = x**4 / 16
        ax.text(0, 0.3, 'NO GAP\n(Massless)', color='#6bcb77',
                fontsize=10, ha='center', fontweight='bold')

    ax.fill_between(x, V, -0.5, alpha=0.15, color='#8a2be2')
    ax.plot(x, V, color='#ff6bd6', linewidth=3)
    ax.axhline(y=0, color='cyan', linewidth=1, alpha=0.3, linestyle='--')

    ax.set_xlim([-4, 4])
    ax.set_ylim([-0.5, 3])
    ax.set_xlabel('Field configuration φ', color='white', fontsize=10)
    ax.set_ylabel('Energy V(φ)', color='white', fontsize=10)
    ax.set_title(title, color='white', fontsize=13, fontweight='bold', pad=10)
    ax.set_facecolor('#0a0a2e')
    ax.tick_params(colors='white', labelsize=8)
    for spine in ax.spines.values():
        spine.set_color('#333366')


def draw_local_vs_global(ax):
    """Draw the fundamental local-global diagram."""
    ax.set_facecolor('#0a0a2e')
    ax.set_xlim([0, 10])
    ax.set_ylim([0, 6])
    ax.set_axis_off()
    ax.set_title('The Local-Global Transfer Principle',
                 color='white', fontsize=14, fontweight='bold', pad=15)

    # LOCAL box
    local_box = plt.Rectangle((0.5, 1), 3, 4, fill=True, facecolor='#1a3a5e',
                                edgecolor='#4d96ff', linewidth=2, alpha=0.8)
    ax.add_patch(local_box)
    ax.text(2, 4.2, 'LOCAL', color='#4d96ff', fontsize=16, fontweight='bold',
            ha='center')
    local_items = [
        'Charts & neighborhoods',
        'Perturbation theory',
        'Polynomial verification',
        'Individual primes p',
        'Short-time existence'
    ]
    for i, item in enumerate(local_items):
        ax.text(2, 3.5 - i*0.5, item, color='white', fontsize=8, ha='center')

    # GLOBAL box
    global_box = plt.Rectangle((6.5, 1), 3, 4, fill=True, facecolor='#3a1a1a',
                                edgecolor='#ff6b6b', linewidth=2, alpha=0.8)
    ax.add_patch(global_box)
    ax.text(8, 4.2, 'GLOBAL', color='#ff6b6b', fontsize=16, fontweight='bold',
            ha='center')
    global_items = [
        'Topological type',
        'Non-perturbative physics',
        'Complexity class',
        'Rank of E(ℚ)',
        'Smooth for all time'
    ]
    for i, item in enumerate(global_items):
        ax.text(8, 3.5 - i*0.5, item, color='white', fontsize=8, ha='center')

    # Arrow with north pole obstruction
    ax.annotate('', xy=(6.3, 3), xytext=(3.7, 3),
                arrowprops=dict(arrowstyle='->', color='white', lw=2,
                                connectionstyle='arc3,rad=0.15'))
    ax.annotate('', xy=(3.7, 2.5), xytext=(6.3, 2.5),
                arrowprops=dict(arrowstyle='->', color='white', lw=2,
                                connectionstyle='arc3,rad=0.15', linestyle='dashed'))

    # North pole in the middle
    ax.plot(5, 3.0, 'o', color='red', markersize=20, zorder=10,
            markeredgecolor='white', markeredgewidth=2)
    ax.text(5, 3.5, 'N', color='red', fontsize=14, fontweight='bold', ha='center')
    ax.text(5, 0.5, 'THE OBSTRUCTION\n"North Pole"', color='red',
            fontsize=11, fontweight='bold', ha='center', style='italic')


def main():
    fig = plt.figure(figsize=(22, 18), facecolor='#0a0a2e')
    gs = gridspec.GridSpec(3, 2, figure=fig, hspace=0.35, wspace=0.25)

    # Panel 1: Flow with obstruction
    ax1 = fig.add_subplot(gs[0, 0])
    draw_mobius_flow(ax1, 'Flow WITH North Pole\n(Singularity obstructs global structure)',
                     has_obstruction=True)

    # Panel 2: Flow without obstruction
    ax2 = fig.add_subplot(gs[0, 1])
    draw_mobius_flow(ax2, 'Flow WITHOUT North Pole\n(Obstruction removed — smooth global flow)',
                     has_obstruction=False)

    # Panel 3: Charts with gap
    ax3 = fig.add_subplot(gs[1, 0])
    draw_covering_charts(ax3, 'Incomplete Atlas\n(North Pole = uncovered gap)', show_gap=True)

    # Panel 4: Charts without gap
    ax4 = fig.add_subplot(gs[1, 1])
    draw_covering_charts(ax4, 'Complete Atlas\n(Overlap covers everything)', show_gap=False)

    # Panel 5: Energy with mass gap
    ax5 = fig.add_subplot(gs[2, 0])
    draw_energy_landscape(ax5, 'Yang-Mills: Energy WITH Mass Gap\n(North Pole = local maximum)',
                          has_gap=True)

    # Panel 6: Local-global principle
    ax6 = fig.add_subplot(gs[2, 1])
    draw_local_vs_global(ax6)

    fig.suptitle('LOCAL-GLOBAL TRANSFER & THE NORTH POLE OBSTRUCTION\n'
                 'Oracle Council Visualization Suite',
                 color='white', fontsize=20, fontweight='bold', y=0.99)

    plt.savefig('/workspace/request-project/oracle_council/demos/demo2_local_global_transfer.png',
                dpi=150, bbox_inches='tight', facecolor='#0a0a2e')
    plt.close()
    print("✓ Saved: demo2_local_global_transfer.png")


if __name__ == '__main__':
    main()
