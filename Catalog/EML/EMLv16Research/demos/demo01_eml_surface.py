"""
Demo 1: EML Surface Plot
Visualizes eml(x, y) = exp(x) - ln(y) as a 3D surface and contour plot.
Shows the neutral curve where eml = 0: y = exp(exp(x)).
"""
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

def eml(x, y):
    return np.exp(x) - np.log(y)

x = np.linspace(-2, 2, 200)
y = np.linspace(0.1, 10, 200)
X, Y = np.meshgrid(x, y)
Z = eml(X, Y)

fig = plt.figure(figsize=(16, 6))

# 3D surface
ax1 = fig.add_subplot(121, projection='3d')
surf = ax1.plot_surface(X, Y, Z, cmap='viridis', alpha=0.8, edgecolor='none')
ax1.set_xlabel('x')
ax1.set_ylabel('y')
ax1.set_zlabel('eml(x, y)')
ax1.set_title('EML Surface: eml(x,y) = exp(x) - ln(y)')
fig.colorbar(surf, ax=ax1, shrink=0.5)

# Contour plot with neutral curve
ax2 = fig.add_subplot(122)
levels = np.linspace(-5, 10, 30)
cs = ax2.contourf(X, Y, Z, levels=levels, cmap='RdBu_r')
ax2.contour(X, Y, Z, levels=[0], colors='black', linewidths=2)
x_curve = np.linspace(-2, 1, 100)
y_curve = np.exp(np.exp(x_curve))
mask = y_curve <= 10
ax2.plot(x_curve[mask], y_curve[mask], 'k--', linewidth=2, label='eml = 0 curve')
ax2.set_xlabel('x')
ax2.set_ylabel('y')
ax2.set_title('EML Contours (black = zero curve)')
ax2.legend()
fig.colorbar(cs, ax=ax2)

plt.tight_layout()
plt.savefig('eml_surface.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved eml_surface.png")
