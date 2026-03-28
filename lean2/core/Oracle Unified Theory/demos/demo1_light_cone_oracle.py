"""
Demo 1: The Light Cone Oracle — Minkowski Geometry and Pythagorean Triples

Visualizes:
1. The light cone a² + b² = c² in 3D
2. Pythagorean triples as integer points on the cone
3. The Berggren tree generating all primitive triples
4. The oracle projection (radial projection onto the cone)
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib.patches import FancyArrowPatch
from mpl_toolkits.mplot3d import proj3d

# ── Berggren matrices ──
B1 = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
B2 = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]])
B3 = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])

def generate_berggren_tree(root, depth):
    """Generate all primitive Pythagorean triples up to given depth."""
    triples = [tuple(root)]
    if depth == 0:
        return triples
    for B in [B1, B2, B3]:
        child = B @ root
        child = np.abs(child)  # Ensure positive
        triples.extend(generate_berggren_tree(child, depth - 1))
    return triples

def minkowski_Q(a, b, c):
    """Minkowski quadratic form Q(a,b,c) = a² + b² - c²"""
    return a**2 + b**2 - c**2

def oracle_project(point):
    """Project a point onto the light cone (radial projection)."""
    a, b, c = point
    r_spatial = np.sqrt(a**2 + b**2)
    if r_spatial < 1e-10:
        return np.array([0, 0, 0])
    # Project to null cone: scale so that a² + b² = c²
    # Keep direction, set c = r_spatial
    scale = r_spatial / max(abs(c), 1e-10)
    return np.array([a, b, r_spatial * np.sign(c)])

# ── Generate data ──
root = np.array([3, 4, 5])
triples = generate_berggren_tree(root, 4)
triples = list(set(triples))  # Remove duplicates

# Verify all triples are on the light cone
for a, b, c in triples:
    Q = minkowski_Q(a, b, c)
    assert Q == 0, f"Triple ({a},{b},{c}) has Q = {Q}"

print(f"Generated {len(triples)} primitive Pythagorean triples")
print(f"All verified on the light cone (Q = 0) ✓")

# ── Figure 1: Light Cone with Pythagorean Triples ──
fig = plt.figure(figsize=(16, 7))

# 3D light cone
ax1 = fig.add_subplot(121, projection='3d')

# Draw the cone surface
theta = np.linspace(0, 2 * np.pi, 100)
z = np.linspace(0, 150, 50)
Theta, Z = np.meshgrid(theta, z)
X = Z * np.cos(Theta)
Y = Z * np.sin(Theta)
ax1.plot_surface(X, Y, Z, alpha=0.15, color='gold', edgecolor='none')

# Plot Pythagorean triples
for a, b, c in triples:
    if c < 150:
        ax1.scatter(a, b, c, c='red', s=30, zorder=5, edgecolors='darkred', linewidth=0.5)

# Highlight the root triple
ax1.scatter(3, 4, 5, c='blue', s=200, marker='*', zorder=10, label='Root (3,4,5)')

# Show some oracle projections
np.random.seed(42)
for _ in range(8):
    # Random point NOT on the cone
    p = np.random.randn(3) * 50
    p[2] = abs(p[2]) + 10
    proj = oracle_project(p)
    ax1.plot([p[0], proj[0]], [p[1], proj[1]], [p[2], proj[2]],
             'g--', alpha=0.5, linewidth=1)
    ax1.scatter(*p, c='green', s=20, alpha=0.5)
    ax1.scatter(*proj, c='lime', s=40, marker='D', zorder=6)

ax1.set_xlabel('a')
ax1.set_ylabel('b')
ax1.set_zlabel('c (hypotenuse)')
ax1.set_title('Light Cone a² + b² = c²\nwith Pythagorean Triple "Photon Addresses"', fontsize=12)
ax1.legend(loc='upper left', fontsize=9)

# ── Figure 2: Oracle Idempotency Demonstration ──
ax2 = fig.add_subplot(122)

# Show Q values for the triples (should all be 0)
cs = [c for _, _, c in triples if c < 200]
Qs_on_cone = [0] * len(cs)

# Generate points off the cone and show Q values
off_cone_points = []
off_cone_Qs = []
projected_Qs = []
for _ in range(200):
    p = np.random.randn(3) * 50
    p[2] = abs(p[2]) + 5
    Q = minkowski_Q(*p)
    off_cone_Qs.append(Q)
    proj = oracle_project(p)
    proj_Q = minkowski_Q(*proj)
    projected_Qs.append(proj_Q)
    # Project again (idempotency check)
    proj2 = oracle_project(proj)
    assert np.allclose(proj, proj2), "Oracle is NOT idempotent!"

ax2.hist(off_cone_Qs, bins=40, alpha=0.5, color='red', label='Before projection (Q ≠ 0)', density=True)
ax2.axvline(x=0, color='gold', linewidth=3, label='After projection (Q = 0)', linestyle='-')
ax2.set_xlabel('Minkowski Q value', fontsize=12)
ax2.set_ylabel('Density', fontsize=12)
ax2.set_title('Oracle Projection: O² = O\nAll points collapse to Q = 0 (the light cone)', fontsize=12)
ax2.legend(fontsize=10)
ax2.annotate('O(O(x)) = O(x)\n"One observation suffices"',
             xy=(0, 0), xytext=(0.5, 0.7), textcoords='axes fraction',
             fontsize=14, fontweight='bold', color='darkblue',
             ha='center', bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

plt.tight_layout()
plt.savefig('/workspace/request-project/research_output/demos/fig1_light_cone_oracle.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: fig1_light_cone_oracle.png")

# ── Figure 2: Berggren Tree Visualization ──
fig2, ax = plt.subplots(figsize=(14, 10))

def draw_tree(ax, node, x, y, dx, depth, max_depth):
    a, b, c = node
    label = f"({a},{b},{c})"
    color = plt.cm.plasma(depth / max(max_depth, 1))
    ax.plot(x, y, 'o', color=color, markersize=max(18 - depth * 3, 6),
            markeredgecolor='black', markeredgewidth=0.5, zorder=5)
    ax.annotate(label, (x, y), textcoords="offset points", xytext=(0, 10),
                ha='center', fontsize=max(9 - depth, 5), fontweight='bold')

    if depth >= max_depth:
        return

    children = []
    for i, B in enumerate([B1, B2, B3]):
        child = np.abs(B @ np.array(node))
        children.append(tuple(child))

    positions = [-dx, 0, dx]
    labels = ['B₁', 'B₂', 'B₃']
    for i, (child, px, lbl) in enumerate(zip(children, positions, labels)):
        cx, cy = x + px, y - 1.5
        ax.plot([x, cx], [y - 0.15, cy + 0.15], '-', color='gray', linewidth=1, alpha=0.6)
        ax.annotate(lbl, ((x + cx)/2, (y + cy)/2 - 0.05),
                    fontsize=7, color='blue', ha='center', alpha=0.7)
        draw_tree(ax, child, cx, cy, dx / 3.2, depth + 1, max_depth)

draw_tree(ax, (3, 4, 5), 0, 0, 6, 0, 3)
ax.set_xlim(-10, 10)
ax.set_ylim(-7, 1.5)
ax.set_aspect('equal')
ax.axis('off')
ax.set_title('The Berggren Tree: All Primitive Pythagorean Triples\n'
             'Each matrix B₁, B₂, B₃ is a discrete Lorentz transformation',
             fontsize=14, fontweight='bold')
ax.text(0, -6.5,
        'BᵢᵀηBᵢ = η   where η = diag(-1, -1, 1)\n'
        'The integer symmetry group of spacetime generates all of Pythagoras',
        ha='center', fontsize=11, style='italic', color='darkblue',
        bbox=dict(facecolor='lightyellow', alpha=0.8, boxstyle='round'))

plt.tight_layout()
plt.savefig('/workspace/request-project/research_output/demos/fig2_berggren_tree.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: fig2_berggren_tree.png")

print("\n✅ Demo 1 complete: Light Cone Oracle visualized")
