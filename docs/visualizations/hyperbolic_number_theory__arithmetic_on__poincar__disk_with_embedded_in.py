"""
Visualization 1: The Poincaré Disk with Hyperbolic Geodesics and Lattice Points

Visualizes the Poincaré disk model of hyperbolic geometry:
- The unit disk boundary
- Hyperbolic geodesics (circular arcs orthogonal to boundary)
- Embedded natural numbers along the x-axis
- Concentric hyperbolic circles showing metric distortion
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# --- Left panel: Disk with geodesics and embedded integers ---
ax = axes[0]
ax.set_aspect('equal')
ax.set_xlim(-1.15, 1.15)
ax.set_ylim(-1.15, 1.15)
ax.set_title('Poincaré Disk: Integers in Curved Space', fontsize=13)

# Draw unit circle
theta = np.linspace(0, 2*np.pi, 200)
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=2)
ax.fill(np.cos(theta), np.sin(theta), alpha=0.05, color='blue')

# Draw concentric hyperbolic circles (loci of constant hyp distance)
for hyp_r in [0.5, 1.0, 1.5, 2.0, 3.0]:
    # Euclidean radius for given hyperbolic distance: r = tanh(d/2)
    euc_r = np.tanh(hyp_r / 2)
    circle = plt.Circle((0, 0), euc_r, fill=False, linestyle='--',
                        color='lightblue', alpha=0.7, linewidth=0.8)
    ax.add_patch(circle)
    ax.text(euc_r + 0.02, 0.02, f'd={hyp_r}', fontsize=7, color='steelblue')

# Embed integers 0-9 along x-axis
N = 10
colors = plt.cm.viridis(np.linspace(0.2, 0.9, N))
for n in range(N):
    x = (n + 1) / (N + 2)
    hyp_norm = np.log((1 + x) / (1 - x))
    ax.plot(x, 0, 'o', color=colors[n], markersize=8, zorder=5)
    ax.annotate(f'{n}', (x, 0), textcoords="offset points",
               xytext=(0, 10), ha='center', fontsize=8, color=colors[n])

# Draw a few hyperbolic geodesics (arcs of circles orthogonal to unit circle)
def draw_geodesic(ax, p1, p2, color='red', alpha=0.5):
    """Draw the hyperbolic geodesic between two disk points."""
    x1, y1 = p1
    x2, y2 = p2
    if abs(x1*y2 - x2*y1) < 1e-10:
        # Points are collinear with origin — geodesic is a diameter
        ax.plot([x1, x2], [y1, y2], '-', color=color, alpha=alpha, linewidth=1.5)
        return
    # Find circle through p1, p2 orthogonal to unit circle
    d1, d2 = x1**2 + y1**2, x2**2 + y2**2
    denom = 2*(x1*y2 - x2*y1)
    if abs(denom) < 1e-10:
        return
    cx = ((d1 - 1)*y2 - (d2 - 1)*y1) / denom
    cy = ((d2 - 1)*x1 - (d1 - 1)*x2) / denom
    cr = np.sqrt((x1 - cx)**2 + (y1 - cy)**2)

    # Draw arc
    a1 = np.arctan2(y1 - cy, x1 - cx)
    a2 = np.arctan2(y2 - cy, x2 - cx)
    if a2 < a1:
        a1, a2 = a2, a1
    if a2 - a1 > np.pi:
        a1, a2 = a2, a1 + 2*np.pi

    t = np.linspace(a1, a2, 100)
    ax.plot(cx + cr*np.cos(t), cy + cr*np.sin(t), '-',
            color=color, alpha=alpha, linewidth=1.5)

# Geodesics between some embedded integers
for i, j in [(0, 5), (2, 7), (1, 9), (3, 6)]:
    x1, x2 = (i+1)/(N+2), (j+1)/(N+2)
    draw_geodesic(ax, (x1, 0), (x2, 0.001), color='coral', alpha=0.4)

ax.plot(0, 0, 'k+', markersize=10, markeredgewidth=2)
ax.set_xlabel('x')
ax.set_ylabel('y')

# --- Right panel: Hyperbolic norm vs Euclidean norm ---
ax2 = axes[1]
r_vals = np.linspace(0, 0.999, 500)
hyp_norms = np.log((1 + r_vals) / (1 - r_vals))

ax2.plot(r_vals, hyp_norms, 'b-', linewidth=2, label=r'$d_H(0,p) = \ln\frac{1+|p|}{1-|p|}$')
ax2.plot(r_vals, 2*r_vals, 'r--', linewidth=1.5, alpha=0.7, label=r'$2|p|$ (Euclidean approx)')
ax2.axhline(y=0, color='gray', linewidth=0.5)
ax2.axvline(x=1, color='gray', linewidth=0.5, linestyle=':')

# Mark embedded integers
for n in range(N):
    x = (n+1)/(N+2)
    hn = np.log((1+x)/(1-x))
    ax2.plot(x, hn, 'o', color=colors[n], markersize=6, zorder=5)

ax2.set_xlabel('Euclidean norm |p|')
ax2.set_ylabel('Hyperbolic norm $d_H(0, p)$')
ax2.set_title('Hyperbolic vs Euclidean Distance', fontsize=13)
ax2.set_ylim(0, 10)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_poincare_disk.png', dpi=150, bbox_inches='tight')
plt.close()
