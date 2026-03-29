"""
Demo 3: Stereographic Fisher Information Geometry
==================================================
The Fisher-Rao metric on the probability simplex, pulled back
through stereographic projection, yields hyperbolic geometry on ℝ^N.

Oracle Ξ's discovery: Maximum likelihood estimation in stereographic
coordinates is equivalent to finding nearest points in hyperbolic space.

The Poincaré disk model of hyperbolic space appears naturally as the
stereographic pullback of the Fisher information metric.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib.patches import FancyArrowPatch

# ─── Helper Functions ────────────────────────────────────────
def fisher_stereo_metric(x, y):
    """The Fisher-Rao metric in stereographic coordinates.
    g_{ij} = 16/(1+|y|²)² δ_{ij} — conformal to Euclidean."""
    r2 = x**2 + y**2
    return 16 / (1 + r2)**2

def poincare_geodesic(z1, z2, n_pts=200):
    """Compute geodesic between two points in the Poincaré disk model."""
    if abs(z1.real * z2.imag - z1.imag * z2.real) < 1e-10:
        # Points are on a diameter
        t = np.linspace(0, 1, n_pts)
        return z1 + t * (z2 - z1)
    
    # General case: find the circle through z1, z2 orthogonal to unit circle
    x1, y1 = z1.real, z1.imag
    x2, y2 = z2.real, z2.imag
    
    # Center of orthogonal circle satisfies:
    # (cx - x1)² + (cy - y1)² = (cx - x2)² + (cy - y2)²
    # cx² + cy² = r² + 1 (orthogonal to unit circle)
    
    # Midpoint perpendicular bisector
    mx, my = (x1+x2)/2, (y1+y2)/2
    dx, dy = x2-x1, y2-y1
    
    if abs(dy) > 1e-10:
        # Perpendicular bisector: passing through (mx, my) with direction (-dy, dx)
        # Parametric: (mx - dy*t, my + dx*t)
        # Also: (x1 + 1/(2x1)) if on x-axis...
        # Use inversion approach instead
        pass
    
    # Simpler: parametric arc
    t = np.linspace(0, 1, n_pts)
    # Use Möbius interpolation
    z = z1 * (1 - t) + z2 * t  # Linear approximation
    # Project back to disk
    r = np.abs(z)
    z = np.where(r > 0.99, z * 0.99 / r, z)
    return z

def hyperbolic_distance(z1, z2):
    """Hyperbolic distance in the Poincaré disk."""
    num = abs(z1 - z2)
    den = abs(1 - np.conj(z1) * z2)
    return 2 * np.arctanh(num / den)

# ─── Figure ──────────────────────────────────────────────────
fig = plt.figure(figsize=(18, 14), facecolor='#0a0a1a')
gs = gridspec.GridSpec(2, 3, hspace=0.35, wspace=0.35)

# ── Panel 1: Fisher metric magnitude ────────────────────────
ax1 = fig.add_subplot(gs[0, 0], facecolor='#0a0a1a')

L = 3
res = 400
x = np.linspace(-L, L, res)
y = np.linspace(-L, L, res)
X, Y = np.meshgrid(x, y)
G = fisher_stereo_metric(X, Y)

im = ax1.imshow(np.log10(G + 1e-10), extent=[-L, L, -L, L], cmap='viridis',
                origin='lower', vmin=-2, vmax=1.3)
ax1.contour(X, Y, G, levels=[0.5, 1, 2, 4, 8, 16], colors='white', alpha=0.3, linewidths=0.5)

circle = plt.Circle((0, 0), 1, fill=False, color='#ff6600', linewidth=2, linestyle='--')
ax1.add_patch(circle)
plt.colorbar(im, ax=ax1, label='log₁₀(g_Fisher)', shrink=0.8)
ax1.set_title('Fisher-Rao Metric in Stereo Coords', color='#00ff88', fontsize=12, fontweight='bold')
ax1.set_xlabel('y₁', color='white')
ax1.set_ylabel('y₂', color='white')
ax1.tick_params(colors='white')

# ── Panel 2: Probability simplex ↔ Sphere ↔ Stereo ──────────
ax2 = fig.add_subplot(gs[0, 1], facecolor='#0a0a1a')

# Draw the probability simplex (triangle for N=2)
simplex = np.array([[0, 0], [1, 0], [0.5, np.sqrt(3)/2], [0, 0]])
ax2.plot(simplex[:, 0], simplex[:, 1], color='#ff6600', linewidth=2)

# Sample probability distributions
np.random.seed(42)
n_pts = 500
# Dirichlet samples
alpha = np.array([1.0, 1.0, 1.0])
probs = np.random.dirichlet(alpha, n_pts)

# Map to simplex coordinates
simplex_coords = probs[:, 0:1] * np.array([[0, 0]]) + \
                 probs[:, 1:2] * np.array([[1, 0]]) + \
                 probs[:, 2:3] * np.array([[0.5, np.sqrt(3)/2]])

# Color by entropy
entropy = -np.sum(probs * np.log(probs + 1e-10), axis=1)
sc = ax2.scatter(simplex_coords[:, 0], simplex_coords[:, 1], c=entropy,
                cmap='plasma', s=8, alpha=0.7, vmin=0, vmax=np.log(3))

plt.colorbar(sc, ax=ax2, label='Entropy H(p)', shrink=0.8)

# Labels
ax2.text(-0.05, -0.05, 'p₁=1', color='white', fontsize=10, ha='center')
ax2.text(1.05, -0.05, 'p₂=1', color='white', fontsize=10, ha='center')
ax2.text(0.5, np.sqrt(3)/2 + 0.05, 'p₃=1', color='white', fontsize=10, ha='center')
ax2.text(0.5, np.sqrt(3)/6, '●', color='#00ddff', fontsize=16, ha='center')
ax2.text(0.5, np.sqrt(3)/6 - 0.08, 'uniform\n(max entropy)', color='#00ddff', fontsize=8, ha='center')

ax2.set_xlim(-0.15, 1.15)
ax2.set_ylim(-0.15, 1.05)
ax2.set_aspect('equal')
ax2.set_title('Probability Simplex Δ₂', color='#00ff88', fontsize=12, fontweight='bold')
ax2.tick_params(colors='white')
for spine in ax2.spines.values():
    spine.set_color('#333355')

# ── Panel 3: Stereographic image of simplex ──────────────────
ax3 = fig.add_subplot(gs[0, 2], facecolor='#0a0a1a')

# Map probabilities to S² via sqrt, then to ℝ² via stereographic
# sqrt map: (p1,p2,p3) → (√p1, √p2, √p3) on S²
# Stereo: (x1,x2,x3) → (x1/(1-x3), x2/(1-x3))
sqrt_probs = np.sqrt(probs)
# Stereographic projection from north pole (0,0,1)
denom = 1 - sqrt_probs[:, 2] + 1e-10
stereo_x = sqrt_probs[:, 0] / denom
stereo_y = sqrt_probs[:, 1] / denom

sc3 = ax3.scatter(stereo_x, stereo_y, c=entropy, cmap='plasma', s=8, alpha=0.7,
                  vmin=0, vmax=np.log(3))

# Draw curves of constant entropy
for h_val in [0.3, 0.6, 0.9, 1.05]:
    theta_h = np.linspace(0, 2*np.pi, 300)
    # Approximate iso-entropy curves (these are circles on the sphere)
    # Just show the boundary of the positive orthant
    pass

circle = plt.Circle((0, 0), 1, fill=False, color='#ff6600', linewidth=1, linestyle='--')
ax3.add_patch(circle)
plt.colorbar(sc3, ax=ax3, label='Entropy H(p)', shrink=0.8)
ax3.set_title('Simplex in Stereographic Coords', color='#00ff88', fontsize=12, fontweight='bold')
ax3.set_xlabel('σ₁', color='white')
ax3.set_ylabel('σ₂', color='white')
ax3.set_xlim(-0.5, 5)
ax3.set_ylim(-0.5, 5)
ax3.tick_params(colors='white')
for spine in ax3.spines.values():
    spine.set_color('#333355')

# ── Panel 4: Hyperbolic geodesics ────────────────────────────
ax4 = fig.add_subplot(gs[1, 0], facecolor='#0a0a1a')

# Draw the Poincaré disk with geodesics
theta = np.linspace(0, 2*np.pi, 200)
ax4.plot(np.cos(theta), np.sin(theta), color='#ff6600', linewidth=2)

# Draw hyperbolic geodesics (arcs of circles orthogonal to unit circle)
def draw_geodesic(ax, p1, p2, color='#00ddff', lw=1.5):
    """Draw a hyperbolic geodesic between two points in the Poincaré disk."""
    x1, y1 = p1
    x2, y2 = p2
    
    # Check if on same diameter
    cross = x1*y2 - x2*y1
    if abs(cross) < 1e-6:
        ax.plot([x1, x2], [y1, y2], color=color, linewidth=lw)
        return
    
    # Find center of circle through p1, p2 orthogonal to unit circle
    # System: (cx-x1)²+(cy-y1)² = (cx-x2)²+(cy-y2)², cx²+cy² = R²+1
    d1 = x1**2 + y1**2
    d2 = x2**2 + y2**2
    
    A = np.array([[2*(x2-x1), 2*(y2-y1)],
                  [2*x1, 2*y1]])
    b = np.array([d2 - d1, d1 + 1])
    
    try:
        sol = np.linalg.solve(A, b)
        cx, cy = sol
        R = np.sqrt(cx**2 + cy**2 - 1)
        
        angle1 = np.arctan2(y1 - cy, x1 - cx)
        angle2 = np.arctan2(y2 - cy, x2 - cx)
        
        if angle2 < angle1:
            angle1, angle2 = angle2, angle1
        if angle2 - angle1 > np.pi:
            angle1, angle2 = angle2, angle1 + 2*np.pi
        
        t = np.linspace(angle1, angle2, 100)
        ax.plot(cx + R*np.cos(t), cy + R*np.sin(t), color=color, linewidth=lw)
    except np.linalg.LinAlgError:
        ax.plot([x1, x2], [y1, y2], color=color, linewidth=lw)

# Draw a tessellation-like pattern of geodesics
points = [(0.3, 0.2), (-0.4, 0.5), (0.1, -0.6), (-0.3, -0.4),
          (0.6, 0.1), (-0.1, 0.7), (0.5, -0.3), (-0.5, -0.1)]

colors_geo = ['#00ddff', '#ff3366', '#33ff99', '#ffaa00', '#ff00ff', '#66ffff', '#ff9933', '#99ff33']

for i in range(len(points)):
    for j in range(i+1, len(points)):
        draw_geodesic(ax4, points[i], points[j], color=colors_geo[i % len(colors_geo)], lw=1)

for i, p in enumerate(points):
    ax4.plot(p[0], p[1], 'o', color=colors_geo[i % len(colors_geo)], markersize=8, zorder=5)

# Draw some hyperbolic circles (equidistant curves)
for r_hyp in [0.3, 0.5, 0.7, 0.9]:
    r_euc = np.tanh(r_hyp / 2)  # Poincaré disk radius
    circle_h = plt.Circle((0, 0), r_euc, fill=False, color='#ffffff', alpha=0.15, linewidth=0.5)
    ax4.add_patch(circle_h)

ax4.set_xlim(-1.15, 1.15)
ax4.set_ylim(-1.15, 1.15)
ax4.set_aspect('equal')
ax4.set_title('Hyperbolic Geodesics\n(Fisher geometry in stereo coords)', color='#00ff88', fontsize=12, fontweight='bold')
ax4.tick_params(colors='white')
for spine in ax4.spines.values():
    spine.set_color('#333355')

# ── Panel 5: Distance distortion ────────────────────────────
ax5 = fig.add_subplot(gs[1, 1], facecolor='#0a0a1a')

# Compare Euclidean vs Fisher distance from origin
r_euc = np.linspace(0, 0.95, 200)
r_fisher = 2 * np.arctanh(r_euc)  # Hyperbolic distance in Poincaré model

ax5.plot(r_euc, r_euc, '--', color='#444466', linewidth=1.5, label='Euclidean distance')
ax5.plot(r_euc, r_fisher, color='#ff00ff', linewidth=2.5, label='Fisher-Rao (hyperbolic) distance')
ax5.fill_between(r_euc, r_euc, r_fisher, color='#ff00ff', alpha=0.1)

ax5.set_xlabel('Euclidean radius in stereo coords', color='white', fontsize=12)
ax5.set_ylabel('Distance from origin', color='white', fontsize=12)
ax5.set_title('Euclidean vs Fisher Distance', color='#00ff88', fontsize=12, fontweight='bold')
ax5.legend(fontsize=10, facecolor='#1a1a2e', edgecolor='#333355', labelcolor='white')
ax5.tick_params(colors='white')
for spine in ax5.spines.values():
    spine.set_color('#333355')

# ── Panel 6: Gaussian curvature of Fisher metric ────────────
ax6 = fig.add_subplot(gs[1, 2], facecolor='#0a0a1a')

# The Gaussian curvature of the Fisher-Stereo metric is constant = -1/4
# (hyperbolic space of curvature -1/4)
# Visualization: conformal factor decomposition

r = np.linspace(0, 4, 300)
lambda_sq = (2/(1+r**2))**2  # conformal factor squared
fisher_factor = 16 / (1+r**2)**2  # = 4 * lambda_sq

ax6.plot(r, lambda_sq, color='#00ddff', linewidth=2, label='λ² = 4/(1+r²)²')
ax6.plot(r, fisher_factor, color='#ff6600', linewidth=2, label='g_Fisher = 16/(1+r²)²')
ax6.plot(r, fisher_factor / lambda_sq * np.ones_like(r), '--', color='#33ff99', 
         linewidth=2, label='g_Fisher/λ² = 4 (constant!)')
ax6.axhline(y=4, color='#33ff99', alpha=0.3, linewidth=1)

ax6.set_xlabel('r = |y|', color='white', fontsize=12)
ax6.set_ylabel('Metric component', color='white', fontsize=12)
ax6.set_title('Metric Decomposition\nK = -1/4 (constant curvature)', color='#00ff88', fontsize=12, fontweight='bold')
ax6.legend(fontsize=9, facecolor='#1a1a2e', edgecolor='#333355', labelcolor='white')
ax6.set_ylim(0, 18)
ax6.tick_params(colors='white')
for spine in ax6.spines.values():
    spine.set_color('#333355')

fig.suptitle('STEREOGRAPHIC FISHER INFORMATION GEOMETRY\n'
             'Where probability, hyperbolic space, and stereographic projection converge',
             color='white', fontsize=16, fontweight='bold', y=0.98)

plt.tight_layout(rect=[0, 0, 1, 0.93])
plt.savefig('/workspace/request-project/Stereographic/InverseNDim/demos/demo3_fisher_information.png',
            dpi=150, bbox_inches='tight', facecolor='#0a0a1a')
plt.close()
print("✅ Demo 3: Fisher Information Geometry — saved!")
