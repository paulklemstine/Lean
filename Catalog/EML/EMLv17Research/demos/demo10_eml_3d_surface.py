"""Demo 10: EML 3D Surface Visualization

Creates publication-quality 3D surface and wireframe plots of
eml(x,y) = exp(x) - ln(y).
"""
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

x = np.linspace(-2, 2, 100)
y = np.linspace(0.1, 5, 100)
X, Y = np.meshgrid(x, y)
Z = np.exp(X) - np.log(Y)

fig = plt.figure(figsize=(16, 6))

# Plot 1: Surface
ax1 = fig.add_subplot(121, projection='3d')
surf = ax1.plot_surface(X, Y, Z, cmap='viridis', alpha=0.8, edgecolor='none')
ax1.contour(X, Y, Z, levels=[0], zdir='z', offset=Z.min()-1, colors='red',
            linewidths=2)
ax1.set_xlabel('x'); ax1.set_ylabel('y'); ax1.set_zlabel('eml(x,y)')
ax1.set_title('EML Surface: exp(x) - ln(y)')
fig.colorbar(surf, ax=ax1, shrink=0.5, label='eml(x,y)')

# Plot 2: Wireframe with neutral plane
ax2 = fig.add_subplot(122, projection='3d')
ax2.plot_wireframe(X, Y, Z, alpha=0.3, color='blue', rstride=5, cstride=5)
ax2.plot_surface(X, Y, np.zeros_like(Z), alpha=0.1, color='red')
x_nc = np.linspace(-2, np.log(np.log(5)), 50)
y_nc = np.exp(np.exp(x_nc))
ax2.plot(x_nc, y_nc, np.zeros_like(x_nc), 'r-', linewidth=3, label='eml = 0')
ax2.set_xlabel('x'); ax2.set_ylabel('y'); ax2.set_zlabel('eml(x,y)')
ax2.set_title('Neutral Curve: y = exp(exp(x))')
ax2.legend()

plt.tight_layout()
plt.savefig('/workspace/request-project/EML/EMLv17Research/demos/eml_3d_surface.png', dpi=150)
plt.close()
print("Demo 10 complete: eml_3d_surface.png")
