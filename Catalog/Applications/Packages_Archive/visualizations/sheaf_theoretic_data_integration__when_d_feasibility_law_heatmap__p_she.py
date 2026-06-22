import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

constraints = np.arange(1, 21)            # C = 1..20
rates = np.linspace(0.0, 0.9, 91)         # r = 0..0.9
C, R = np.meshgrid(constraints, rates)
P = (1.0 - R) ** C                        # P(sheaf) = (1-r)^C

fig, ax = plt.subplots(figsize=(8, 5))
im = ax.pcolormesh(constraints, rates, P, shading='auto', cmap='viridis')
cs = ax.contour(constraints, rates, P, levels=[0.01, 0.1, 0.5, 0.9],
                colors='white', linewidths=1.0)
ax.clabel(cs, inline=True, fontsize=8, fmt='%.2f')
ax.set_xlabel('number of overlap constraints  C')
ax.set_ylabel('missing rate  r')
ax.set_title(r'Feasibility law  $P(\mathrm{sheaf}) = (1-r)^C$')
fig.colorbar(im, ax=ax, label='P(consistent completion)')
fig.tight_layout()
fig.savefig('feasibility_heatmap.png', dpi=150)
print('wrote feasibility_heatmap.png')