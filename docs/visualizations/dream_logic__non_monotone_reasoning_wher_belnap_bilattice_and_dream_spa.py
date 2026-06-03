"""
Visualization: Belnap's Four-Valued Bilattice
==============================================

Displays the knowledge ordering and truth operations as a Hasse diagram.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_belnap_bilattice():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # ── Panel 1: Knowledge Ordering ──
    ax = axes[0]
    ax.set_title("Knowledge Ordering ≤_k", fontsize=14, fontweight='bold')
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-0.5, 3.5)
    ax.set_aspect('equal')
    ax.axis('off')

    positions = {
        '⊥ (neither)': (0, 0),
        'T (true)': (-1, 1.5),
        'F (false)': (1, 1.5),
        '⊤ (both)': (0, 3),
    }

    colors = {
        '⊥ (neither)': '#E8E8E8',
        'T (true)': '#90EE90',
        'F (false)': '#FFB6C1',
        '⊤ (both)': '#DDA0DD',
    }

    edges = [
        ('⊥ (neither)', 'T (true)'),
        ('⊥ (neither)', 'F (false)'),
        ('T (true)', '⊤ (both)'),
        ('F (false)', '⊤ (both)'),
    ]

    for (n1, n2) in edges:
        x1, y1 = positions[n1]
        x2, y2 = positions[n2]
        ax.annotate("", xy=(x2, y2 - 0.25), xytext=(x1, y1 + 0.25),
                     arrowprops=dict(arrowstyle='->', color='#555', lw=1.5))

    for name, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.35, color=colors[name], ec='black', lw=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, name.split('(')[0].strip(), ha='center', va='center',
                fontsize=11, fontweight='bold', zorder=6)
        ax.text(x, y - 0.55, f"({name.split('(')[1]}", ha='center', va='center',
                fontsize=8, color='#555', zorder=6)

    ax.text(0, -0.3, "More knowledge ↑", ha='center', fontsize=9, style='italic', color='#777')

    # ── Panel 2: Truth Table (Conjunction) ──
    ax = axes[1]
    ax.set_title("Truth Conjunction (∧)", fontsize=14, fontweight='bold')
    ax.axis('off')

    vals = ['⊥', 'T', 'F', '⊤']
    table_data = [
        ['⊥', '⊥', 'F', 'F'],
        ['⊥', 'T', 'F', '⊤'],
        ['F', 'F', 'F', 'F'],
        ['F', '⊤', 'F', '⊤'],
    ]

    cell_colors_data = []
    color_map = {'⊥': '#E8E8E8', 'T': '#90EE90', 'F': '#FFB6C1', '⊤': '#DDA0DD'}
    for row in table_data:
        cell_colors_data.append([color_map[v] for v in row])

    table = ax.table(cellText=table_data,
                     rowLabels=vals,
                     colLabels=vals,
                     cellColours=cell_colors_data,
                     loc='center',
                     cellLoc='center')
    table.auto_set_font_size(False)
    table.set_fontsize(12)
    table.scale(1.2, 1.8)

    # ── Panel 3: Self-Contradiction ──
    ax = axes[2]
    ax.set_title("Self-Contradiction v ∧ ¬v", fontsize=14, fontweight='bold')
    ax.axis('off')

    sc_data = [
        ['⊥', '⊥', '⊥', '✗'],
        ['T', 'F', 'F', '✗'],
        ['F', 'T', 'F', '✗'],
        ['⊤', '⊤', '⊤', '✓ (!!)'],
    ]

    sc_colors = []
    for row in sc_data:
        colors_row = []
        for i, v in enumerate(row):
            if i == 3:
                colors_row.append('#90EE90' if '✓' in v else '#FFB6C1')
            else:
                colors_row.append(color_map.get(v, 'white'))
        sc_colors.append(colors_row)

    table2 = ax.table(cellText=sc_data,
                      rowLabels=vals,
                      colLabels=['v', '¬v', 'v∧¬v', 'Designated?'],
                      cellColours=sc_colors,
                      loc='center',
                      cellLoc='center')
    table2.auto_set_font_size(False)
    table2.set_fontsize(11)
    table2.scale(1.2, 1.8)

    fig.suptitle("Belnap's Four-Valued Paraconsistent Logic",
                 fontsize=16, fontweight='bold', y=0.98)
    plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.savefig('belnap_bilattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: belnap_bilattice.png")


def draw_dream_space():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # ── Panel 1: Singleton Dream Space ──
    ax = axes[0]
    ax.set_title("Singleton Dream Space on ℕ", fontsize=14, fontweight='bold')

    # Draw some singletons
    n_show = 8
    for i in range(n_show):
        circle = plt.Circle((i, 0), 0.3, color='#90EE90', ec='black', lw=1.5, alpha=0.8)
        ax.add_patch(circle)
        ax.text(i, 0, f"{{{i}}}", ha='center', va='center', fontsize=9)

    # Show union of even singletons
    for i in range(0, n_show, 2):
        rect = mpatches.FancyBboxPatch((i - 0.35, -0.8), 0.7, 0.5,
                                        boxstyle="round,pad=0.1",
                                        facecolor='#FFB6C1', edgecolor='red',
                                        lw=2, alpha=0.7)
        ax.add_patch(rect)
        ax.text(i, -0.55, f"{{{i}}}", ha='center', va='center', fontsize=8, color='red')

    # Arrow showing union
    ax.annotate("∪ = {0,2,4,6,...}", xy=(3.5, -1.3), fontsize=11,
                ha='center', color='red', fontweight='bold')
    ax.annotate("NOT OPEN!", xy=(3.5, -1.7), fontsize=12,
                ha='center', color='red', fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='#FFE4E1', edgecolor='red'))

    ax.set_xlim(-1, n_show)
    ax.set_ylim(-2.2, 1.2)
    ax.set_aspect('equal')
    ax.axis('off')

    # ── Panel 2: Topological vs Dream ──
    ax = axes[1]
    ax.set_title("Topological vs Dream Space", fontsize=14, fontweight='bold')

    # Venn-like diagram
    theta = np.linspace(0, 2 * np.pi, 100)

    # Large circle: Dream spaces
    r_dream = 2.5
    ax.plot(r_dream * np.cos(theta), r_dream * np.sin(theta),
            color='#DDA0DD', lw=3)
    ax.fill(r_dream * np.cos(theta), r_dream * np.sin(theta),
            color='#DDA0DD', alpha=0.15)
    ax.text(0, 2.8, "Dream Spaces", ha='center', fontsize=12,
            fontweight='bold', color='#8B008B')

    # Smaller circle: Topological spaces
    r_topo = 1.5
    cx, cy = -0.3, -0.3
    ax.plot(cx + r_topo * np.cos(theta), cy + r_topo * np.sin(theta),
            color='#4682B4', lw=3)
    ax.fill(cx + r_topo * np.cos(theta), cy + r_topo * np.sin(theta),
            color='#4682B4', alpha=0.2)
    ax.text(cx, cy, "Topological\nSpaces", ha='center', fontsize=11,
            fontweight='bold', color='#00008B')

    # Mark the singleton dream space
    ax.plot(1.8, 1.2, 'r*', markersize=20, zorder=5)
    ax.text(1.8, 0.7, "Singleton\nDream Space", ha='center', fontsize=9,
            color='red', fontweight='bold')

    ax.set_xlim(-3.5, 3.5)
    ax.set_ylim(-3.5, 3.5)
    ax.set_aspect('equal')
    ax.axis('off')

    fig.suptitle("Dream Spaces Strictly Generalize Topological Spaces",
                 fontsize=16, fontweight='bold', y=0.98)
    plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.savefig('dream_space.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: dream_space.png")


if __name__ == "__main__":
    draw_belnap_bilattice()
    draw_dream_space()
