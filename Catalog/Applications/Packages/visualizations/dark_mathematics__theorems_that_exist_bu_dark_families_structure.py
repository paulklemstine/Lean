import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def draw_bipartite(ax, worlds, N):
    m = len(worlds)
    world_keys = list(worlds.keys())
    world_y = np.linspace(0.9, 0.1, m)
    elem_y = np.linspace(0.9, 0.1, N)
    for i, (w, wset) in enumerate(worlds.items()):
        for n in wset:
            ax.plot([0.2, 0.8], [world_y[i], elem_y[n]], color='steelblue', alpha=0.3, linewidth=1)
    for i, w in enumerate(world_keys):
        ax.scatter([0.2], [world_y[i]], s=200, c='darkred', zorder=5)
        ax.text(0.08, world_y[i], f'W{w}', ha='center', va='center', fontsize=9)
    for n in range(N):
        spec_size = sum(1 for wset in worlds.values() if n in wset)
        color = plt.cm.YlOrRd(spec_size / m) if spec_size > 0 else 'lightgray'
        ax.scatter([0.8], [elem_y[n]], s=150, c=[color], zorder=5, edgecolors='black', linewidth=0.5)
        ax.text(0.92, elem_y[n], str(n), ha='center', va='center', fontsize=8)
    ax.set_xlim(0, 1); ax.set_ylim(0, 1); ax.axis('off')

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
draw_bipartite(axes[0], {0: {0,1,2}, 1: {3,4,5}}, 6)
axes[0].set_title('Two-World (Level 3)', fontweight='bold')
draw_bipartite(axes[1], {0: {2,3,4,5}, 1: {0,1,4,5}, 2: {0,1,2,3}}, 6)
axes[1].set_title('Three-World Extremal (Level 4)', fontweight='bold')
draw_bipartite(axes[2], {0: {0,1,4,5}, 1: {0,1,6,7}, 2: {2,3,4,5}, 3: {2,3,6,7}}, 8)
axes[2].set_title('Product (Level 2+2=4)', fontweight='bold')
plt.tight_layout(); plt.savefig('dark_families_structure.png', dpi=150); plt.close()