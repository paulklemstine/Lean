import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

fig, ax = plt.subplots(1, 1, figsize=(6, 6))
ax.set_xlim(-2, 2)
ax.set_ylim(-2, 2)
ax.set_aspect('equal')
ax.axis('off')
ax.set_title('Belnap\'s FOUR: Truth Ordering', fontsize=16, fontweight='bold')

# Positions
positions = {'F': (0, -1.2), 'N': (-1.2, 0), 'B': (1.2, 0), 'T': (0, 1.2)}
designated = {'T', 'B'}

# Draw edges
edges = [('F', 'N'), ('F', 'B'), ('N', 'T'), ('B', 'T')]
for a, b in edges:
    ax.plot([positions[a][0], positions[b][0]], [positions[a][1], positions[b][1]],
            'k-', linewidth=2, zorder=1)

# Draw nodes
for name, (x, y) in positions.items():
    color = '#4CAF50' if name in designated else '#f44336'
    circle = plt.Circle((x, y), 0.35, color=color, ec='black', linewidth=2, zorder=2)
    ax.add_patch(circle)
    ax.text(x, y, name, ha='center', va='center', fontsize=18, fontweight='bold',
            color='white', zorder=3)

# Labels
ax.text(0, -1.8, 'False only', ha='center', fontsize=10, style='italic')
ax.text(-1.2, -0.6, 'Neither', ha='center', fontsize=10, style='italic')
ax.text(1.2, -0.6, 'Both (glut)', ha='center', fontsize=10, style='italic')
ax.text(0, 1.7, 'True only', ha='center', fontsize=10, style='italic')

# Legend
desig_patch = mpatches.Patch(color='#4CAF50', label='Designated')
nondesig_patch = mpatches.Patch(color='#f44336', label='Non-designated')
ax.legend(handles=[desig_patch, nondesig_patch], loc='lower right', fontsize=11)

plt.tight_layout()
plt.savefig('belnap_lattice.png', dpi=150, bbox_inches='tight')
print('Saved belnap_lattice.png')