"""
Demo 14: EML Level Set Convexity
Demonstrates that all sublevel sets {(x,y) : eml(x,y) ≤ c} are convex.
Also shows the Hessian eigenvalues confirming joint convexity.
"""
import numpy as np
import matplotlib.pyplot as plt

def eml(x, y):
    return np.exp(x) - np.log(y)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: Convex level curves with random midpoints
ax = axes[0]
x = np.linspace(-3, 2, 300)
y = np.linspace(0.1, 20, 300)
X, Y = np.meshgrid(x, y)
Z = eml(X, Y)

levels = [0, 1, 2, 3, 5]
cs = ax.contour(X, Y, Z, levels=levels, linewidths=2)
ax.clabel(cs, inline=True, fontsize=10)

# Demonstrate convexity: midpoint of two points on level set
np.random.seed(123)
for level in [2, 5]:
    # Find points on the level curve
    from matplotlib.contour import QuadContourSet
    # Just pick two points satisfying eml ≈ level
    for _ in range(3):
        x1 = np.random.uniform(-2, 1.5)
        y1 = np.exp(np.exp(x1) - level)  # exact level
        x2 = np.random.uniform(-2, 1.5)
        y2 = np.exp(np.exp(x2) - level)
        if y1 > 0.1 and y1 < 20 and y2 > 0.1 and y2 < 20:
            xm, ym = (x1+x2)/2, (y1+y2)/2
            eml_mid = eml(xm, ym)
            ax.plot([x1, x2], [y1, y2], 'k-', alpha=0.3)
            marker = 'v' if eml_mid <= level else '^'
            color = 'green' if eml_mid <= level else 'red'
            ax.plot(xm, ym, marker, color=color, markersize=6)

ax.set_xlabel('x')
ax.set_ylabel('y')
ax.set_title('Level Curves (midpoints are inside sublevel sets)')
ax.grid(True, alpha=0.3)

# Right: Hessian eigenvalues
ax = axes[1]
x_pts = np.linspace(-2, 2, 100)
y_pts = np.linspace(0.5, 5, 100)
X2, Y2 = np.meshgrid(x_pts, y_pts)

# Hessian of eml(x,y): [[exp(x), 0], [0, 1/y²]]
# Eigenvalues: exp(x) and 1/y²
eig1 = np.exp(X2)
eig2 = 1/Y2**2

min_eig = np.minimum(eig1, eig2)
im = ax.imshow(min_eig, extent=[x_pts[0], x_pts[-1], y_pts[0], y_pts[-1]],
               aspect='auto', origin='lower', cmap='YlOrRd')
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.set_title('Minimum Hessian Eigenvalue (always > 0 = strict convexity)')
fig.colorbar(im, ax=ax, label='min(exp(x), 1/y²)')

plt.tight_layout()
plt.savefig('eml_level_convexity.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved eml_level_convexity.png")
