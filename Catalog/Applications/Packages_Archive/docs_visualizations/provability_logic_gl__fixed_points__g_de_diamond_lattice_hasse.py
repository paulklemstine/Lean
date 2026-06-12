try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches

    fig, ax = plt.subplots(1, 1, figsize=(8, 8))

    # Node positions
    pos = {'⊥': (0.5, 0.1), 'g': (0.2, 0.5), '□g': (0.8, 0.5), '⊤': (0.5, 0.9)}

    # Draw Hasse edges
    edges = [('⊥', 'g'), ('⊥', '□g'), ('g', '⊤'), ('□g', '⊤')]
    for a, b in edges:
        ax.plot([pos[a][0], pos[b][0]], [pos[a][1], pos[b][1]], 'k-', lw=2)

    # Draw nodes
    colors = {'⊥': '#ff6b6b', 'g': '#4ecdc4', '□g': '#45b7d1', '⊤': '#96ceb4'}
    for name, (x, y) in pos.items():
        circle = plt.Circle((x, y), 0.06, color=colors[name], ec='black', lw=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, name, ha='center', va='center', fontsize=14, fontweight='bold', zorder=6)

    # Draw box arrows
    box_map = {'⊥': '⊥', 'g': '□g', '□g': '⊤', '⊤': '⊤'}
    for src, dst in box_map.items():
        if src != dst:
            sx, sy = pos[src]
            dx, dy = pos[dst]
            ax.annotate('', xy=(dx, dy), xytext=(sx, sy),
                       arrowprops=dict(arrowstyle='->', color='red', lw=2, ls='--',
                                      connectionstyle='arc3,rad=0.3'))

    ax.set_xlim(-0.1, 1.1)
    ax.set_ylim(-0.05, 1.05)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Diamond Provability Lattice with Gödel Element\n(Red dashed = □ operator)', fontsize=14)

    # Legend
    ax.text(0.02, 0.02, 'g ⊓ □g = ⊥ (self-refuting)\ng ⊔ □g = ⊤ (self-affirming)\n□g ≠ ⊤ (not provable)', 
            fontsize=10, transform=ax.transAxes, verticalalignment='bottom',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    plt.tight_layout()
    plt.savefig('diamond_lattice.png', dpi=150, bbox_inches='tight')
    print('Saved diamond_lattice.png')
except ImportError:
    print('matplotlib not available; skipping visualization')