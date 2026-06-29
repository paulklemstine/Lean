import math
import numpy as np
import matplotlib.pyplot as plt

R, C, L, delta = 0.05, 8192*math.log(2), 1.6, 0.05
rhos = np.linspace(0, 0.4, 200)
ns = np.logspace(2, 8, 200)
RHO, N = np.meshgrid(rhos, ns)
Z = (R + L*RHO) + np.sqrt((C + math.log(1/delta)) / (2*N))
fig, ax = plt.subplots(figsize=(9, 6))
pc = ax.pcolormesh(RHO, N, Z, shading='auto', cmap='viridis')
cs = ax.contour(RHO, N, Z, colors='white', linewidths=0.7, levels=10)
ax.clabel(cs, inline=True, fontsize=7)
ax.set_yscale('log')
ax.set_xlabel('perturbation radius rho')
ax.set_ylabel('sample size n (log scale)')
ax.set_title('Perturbation-stable Occam bound surface')
fig.colorbar(pc, ax=ax, label='certified true-risk bound')
plt.tight_layout()
plt.savefig('tradeoff_surface.png', dpi=150)
print('saved tradeoff_surface.png')
