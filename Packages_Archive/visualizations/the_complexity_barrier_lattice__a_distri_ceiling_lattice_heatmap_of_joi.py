import numpy as np
import matplotlib.pyplot as plt

N = 16
c = np.arange(N)
C1, C2 = np.meshgrid(c, c)
join_ceiling = np.maximum(C1, C2)
meet_ceiling = np.minimum(C1, C2)

fig, axes = plt.subplots(1, 2, figsize=(11, 5))
for ax, data, title in zip(axes, [join_ceiling, meet_ceiling],
                           ['JOIN ceiling = max(c1, c2)', 'MEET ceiling = min(c1, c2)']):
    im = ax.imshow(data, origin='lower', cmap='viridis')
    ax.set_title(title)
    ax.set_xlabel('c1 (ceiling of B1)')
    ax.set_ylabel('c2 (ceiling of B2)')
    fig.colorbar(im, ax=ax, shrink=0.8)
fig.suptitle('The complexity-barrier lattice: ceiling map onto (N, max, min)')
plt.tight_layout()
plt.savefig('ceiling_lattice_heatmap.png', dpi=150)
print('wrote ceiling_lattice_heatmap.png')