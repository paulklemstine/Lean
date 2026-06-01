import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

fig, ax = plt.subplots(figsize=(10, 8))
depth = 6
colors = plt.cm.viridis(np.linspace(0.2, 0.9, depth))
for k in range(depth):
    y = k * 1.2
    w = 3 + k * 0.3
    rect = patches.FancyBboxPatch((5-w/2, y), w, 0.9, boxstyle='round,pad=0.1', facecolor=colors[k], edgecolor='black', linewidth=2)
    ax.add_patch(rect)
    ax.text(5, y+0.45, f'Level {k}', ha='center', va='center', fontsize=14, fontweight='bold', color='white')
    if k == 0:
        ax.text(8.5, y+0.45, 'Computable functions', fontsize=11, va='center', style='italic')
    else:
        ax.text(8.5, y+0.45, f'+ Halting oracle for Level {k-1}', fontsize=11, va='center', style='italic')
    if k > 0:
        ax.annotate('', xy=(5, y), xytext=(5, y-0.3), arrowprops=dict(arrowstyle='->', lw=2, color='red'))
ax.text(5, depth*1.2+0.3, '...', fontsize=24, ha='center')
ax.set_xlim(0, 12); ax.set_ylim(-0.5, depth*1.2+1.5); ax.set_aspect('equal'); ax.axis('off')
ax.set_title('Oracle Hierarchy', fontsize=16, fontweight='bold')
plt.tight_layout(); plt.savefig('oracle_hierarchy.png', dpi=150, bbox_inches='tight'); plt.close()