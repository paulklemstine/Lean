"""Demo 1: EML Heat Map with Neutral Curve and Critical Analysis

Visualizes eml(x,y) = exp(x) - ln(y) as a heat map with the neutral curve
y = exp(exp(x)) overlaid, showing the sign decomposition of the plane.
"""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import TwoSlopeNorm

x = np.linspace(-2, 2, 400)
y = np.linspace(0.01, 15, 400)
X, Y = np.meshgrid(x, y)
Z = np.exp(X) - np.log(Y)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Heat map
norm = TwoSlopeNorm(vmin=Z.min(), vcenter=0, vmax=min(Z.max(), 10))
im = axes[0].pcolormesh(X, Y, Z, cmap='RdBu_r', norm=norm, shading='auto')
plt.colorbar(im, ax=axes[0], label='eml(x,y)')

# Neutral curve y = exp(exp(x))
x_nc = np.linspace(-2, np.log(np.log(15)), 200)
y_nc = np.exp(np.exp(x_nc))
axes[0].plot(x_nc, y_nc, 'k-', linewidth=2, label=r'$y = e^{e^x}$ (neutral)')
axes[0].set_xlabel('x'); axes[0].set_ylabel('y')
axes[0].set_title('EML Heat Map with Neutral Curve')
axes[0].legend()
axes[0].set_ylim(0, 15)

# Sign regions
sign = np.sign(Z)
axes[1].contourf(X, Y, sign, levels=[-1.5, -0.5, 0.5, 1.5],
                 colors=['#2196F3', '#FFFFFF', '#F44336'], alpha=0.7)
axes[1].plot(x_nc, y_nc, 'k-', linewidth=2, label='Neutral curve')
axes[1].set_xlabel('x'); axes[1].set_ylabel('y')
axes[1].set_title('Sign Regions: Red (+), Blue (−)')
axes[1].legend()
axes[1].set_ylim(0, 15)

plt.tight_layout()
plt.savefig('/workspace/request-project/EML/EMLv17Research/demos/eml_heat_map.png', dpi=150)
plt.close()
print("Demo 1 complete: eml_heat_map.png")
