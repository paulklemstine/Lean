#!/usr/bin/env python3
"""
Arrow-Curvature Bridge: Numerical Demonstrations

Demonstrates the key results connecting Arrow's impossibility theorem
to the positive curvature of the Fisher information manifold.
"""

import numpy as np
from algorithms import (
    bhattacharyya_coefficient,
    hellinger_distance_sq,
    sqrt_embedding,
    angular_distance,
    polarization_index,
    spherical_midpoint,
    curvature_contraction_ratio,
    fisher_rao_distance,
    ultrafilter_on_finite_set,
)


def demo_sqrt_embedding():
    """Demonstrate that sqrt embedding maps simplex to sphere."""
    print("=" * 60)
    print("DEMO 1: Square-Root Embedding Δₙ → S⁺")
    print("=" * 60)

    distributions = [
        ("Uniform(3)", np.array([1/3, 1/3, 1/3])),
        ("Peaked",     np.array([0.8, 0.1, 0.1])),
        ("Skewed",     np.array([0.5, 0.3, 0.2])),
        ("Vertex",     np.array([1.0, 0.0, 0.0])),
    ]

    for name, p in distributions:
        sp = sqrt_embedding(p)
        norm_sq = np.sum(sp**2)
        print(f"  {name:12s}: p = {p}")
        print(f"               √p = [{', '.join(f'{x:.4f}' for x in sp)}]")
        print(f"               ‖√p‖² = {norm_sq:.6f} (should be 1.0)")
        print()


def demo_hellinger_bhattacharyya():
    """Demonstrate Hellinger distance and Bhattacharyya coefficient."""
    print("=" * 60)
    print("DEMO 2: Hellinger Distance = Spherical Distance")
    print("=" * 60)

    p = np.array([0.6, 0.3, 0.1])
    q = np.array([0.2, 0.5, 0.3])

    bc = bhattacharyya_coefficient(p, q)
    h2 = hellinger_distance_sq(p, q)
    theta = angular_distance(p, q)
    fr_dist = fisher_rao_distance(p, q)

    # Verify H² = ½‖√p - √q‖²
    sp, sq_ = sqrt_embedding(p), sqrt_embedding(q)
    half_sq_dist = 0.5 * np.sum((sp - sq_)**2)

    print(f"  p = {p}")
    print(f"  q = {q}")
    print(f"  BC(p,q) = ⟨√p, √q⟩ = {bc:.6f}")
    print(f"  H²(p,q) = 1 - BC    = {h2:.6f}")
    print(f"  ½‖√p-√q‖²           = {half_sq_dist:.6f}  (should equal H²)")
    print(f"  Angular distance θ   = {theta:.6f} rad = {np.degrees(theta):.2f}°")
    print(f"  Fisher-Rao distance  = {fr_dist:.6f} (= 2θ)")
    print()


def demo_curvature_contraction():
    """Demonstrate that positive curvature contracts midpoints."""
    print("=" * 60)
    print("DEMO 3: Curvature Contraction (K = 1)")
    print("=" * 60)
    print("  On a sphere, midpoints are closer to reference points")
    print("  than flat-space averaging predicts. This is Arrow's")
    print("  impossibility in geometric form.")
    print()

    # Three probability distributions
    p = np.array([0.7, 0.2, 0.1])
    q = np.array([0.1, 0.6, 0.3])
    z = np.array([0.3, 0.3, 0.4])  # Reference point

    # Distances from z
    d_zp = angular_distance(z, p)
    d_zq = angular_distance(z, q)
    avg_dist = (d_zp + d_zq) / 2

    # Spherical midpoint of √p and √q
    sp, sq_ = sqrt_embedding(p), sqrt_embedding(q)
    mid = spherical_midpoint(sp, sq_)
    # Map back to probability (square the coordinates)
    mid_prob = mid**2

    d_z_mid = angular_distance(z, mid_prob)

    contraction = curvature_contraction_ratio(d_zp, d_zq)

    print(f"  p = {p}")
    print(f"  q = {q}")
    print(f"  z = {z} (reference)")
    print(f"  d(z, p)              = {d_zp:.6f}")
    print(f"  d(z, q)              = {d_zq:.6f}")
    print(f"  (d(z,p) + d(z,q))/2  = {avg_dist:.6f}  (flat average)")
    print(f"  d(z, midpoint(p,q))  = {d_z_mid:.6f}  (spherical)")
    print(f"  Contraction: {d_z_mid:.6f} < {avg_dist:.6f} ✓" if d_z_mid < avg_dist
          else f"  No contraction (degenerate case)")
    print(f"  Contraction ratio    = {contraction:.6f}")
    print()


def demo_polarization_index():
    """Demonstrate the polarization index for voter configurations."""
    print("=" * 60)
    print("DEMO 4: Polarization Index")
    print("=" * 60)
    print("  Higher polarization ⟹ Arrow's impossibility more binding")
    print()

    scenarios = {
        "Consensus": np.array([
            [0.7, 0.2, 0.1],
            [0.65, 0.25, 0.1],
            [0.7, 0.15, 0.15],
        ]),
        "Moderate disagreement": np.array([
            [0.6, 0.3, 0.1],
            [0.2, 0.5, 0.3],
            [0.3, 0.2, 0.5],
        ]),
        "Extreme polarization": np.array([
            [0.9, 0.05, 0.05],
            [0.05, 0.9, 0.05],
            [0.05, 0.05, 0.9],
        ]),
    }

    for name, voters in scenarios.items():
        pi_val = polarization_index(voters)
        print(f"  {name}:")
        for i, v in enumerate(voters):
            print(f"    Voter {i+1}: {v}")
        print(f"    Polarization index = {pi_val:.6f}")
        print()


def demo_ultrafilter_principal():
    """Demonstrate that ultrafilters on finite sets are principal."""
    print("=" * 60)
    print("DEMO 5: Ultrafilters on Finite Sets = Dictators")
    print("=" * 60)

    for n in [3, 4]:
        ufs = ultrafilter_on_finite_set(n)
        print(f"  Set size n = {n}: exactly {len(ufs)} ultrafilters")
        for i, uf in enumerate(ufs):
            min_set = min(uf, key=len)
            print(f"    Ultrafilter {i}: principal, generated by {{{i}}}")
            print(f"      Smallest member: {min_set}")
            print(f"      Total sets: {len(uf)}")
        print()

    print("  Key insight: Every ultrafilter is principal (generated by")
    print("  a single point). Under Arrow's conditions, decisive")
    print("  coalitions form an ultrafilter ⟹ there's a dictator.")
    print()


def demo_cosine_concavity():
    """Demonstrate the concavity of cosine on [0, π/2]."""
    print("=" * 60)
    print("DEMO 6: Cosine Concavity on [0, π/2]")
    print("=" * 60)
    print("  cos((θ₁+θ₂)/2) ≥ (cos θ₁ + cos θ₂)/2")
    print("  (Jensen's inequality for concave functions)")
    print()

    test_pairs = [
        (0.3, 0.8),
        (0.0, np.pi/2),
        (0.5, 1.2),
        (np.pi/4, np.pi/4),
        (0.1, 1.5),
    ]

    for t1, t2 in test_pairs:
        lhs = np.cos((t1 + t2) / 2)
        rhs = (np.cos(t1) + np.cos(t2)) / 2
        print(f"  θ₁={t1:.3f}, θ₂={t2:.3f}: "
              f"cos(avg) = {lhs:.6f} ≥ avg(cos) = {rhs:.6f}  "
              f"{'✓' if lhs >= rhs - 1e-10 else '✗'}")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Arrow-Curvature Bridge: Numerical Demonstrations      ║")
    print("║  Connecting Social Choice to Fisher-Rao Geometry        ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_sqrt_embedding()
    demo_hellinger_bhattacharyya()
    demo_curvature_contraction()
    demo_polarization_index()
    demo_ultrafilter_principal()
    demo_cosine_concavity()

    print("=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print("  The probability simplex Δₙ with Fisher metric ≅ sphere S⁺")
    print("  Positive curvature K=1 ⟹ midpoint contraction")
    print("  Contraction ⟹ no fair aggregation preserving all info")
    print("  Only projections (dictatorships) avoid contraction")
    print("  Decisive coalitions form ultrafilter ⟹ principal ⟹ dictator")
    print()


#!/usr/bin/env python3
"""
Visualization: Curvature Contraction on the Fisher-Rao Sphere

Shows how positive curvature (K=1) contracts midpoints on the probability
simplex, creating the geometric obstruction behind Arrow's impossibility.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D


def sqrt_embedding(p):
    return np.sqrt(p)

def bhattacharyya(p, q):
    return np.sum(np.sqrt(p * q))

def angular_dist(p, q):
    bc = np.clip(bhattacharyya(p, q), -1, 1)
    return np.arccos(bc)

def spherical_midpoint(x, y):
    avg = (x + y) / 2
    norm = np.linalg.norm(avg)
    return avg / norm if norm > 1e-12 else avg

def geodesic_arc(x, y, n_points=100):
    """Generate points along the geodesic from x to y on the sphere."""
    x = x / np.linalg.norm(x)
    y = y / np.linalg.norm(y)
    dot = np.clip(np.dot(x, y), -1, 1)
    theta = np.arccos(dot)
    if theta < 1e-10:
        return np.array([x])
    ts = np.linspace(0, 1, n_points)
    points = []
    for t in ts:
        pt = np.sin((1-t)*theta)/np.sin(theta) * x + np.sin(t*theta)/np.sin(theta) * y
        points.append(pt)
    return np.array(points)


fig = plt.figure(figsize=(14, 6))

# --- Left panel: 3D sphere with probability simplex ---
ax1 = fig.add_subplot(121, projection='3d')

# Draw sphere wireframe (positive octant only)
u = np.linspace(0, np.pi/2, 30)
v = np.linspace(0, np.pi/2, 30)
U, V = np.meshgrid(u, v)
X = np.cos(U) * np.sin(V)
Y = np.sin(U) * np.sin(V)
Z = np.cos(V)
ax1.plot_surface(X, Y, Z, alpha=0.1, color='skyblue')

# Three probability distributions
p = np.array([0.7, 0.2, 0.1])
q = np.array([0.1, 0.6, 0.3])
z = np.array([0.3, 0.3, 0.4])

sp = sqrt_embedding(p)
sq = sqrt_embedding(q)
sz = sqrt_embedding(z)

# Spherical midpoint
mid = spherical_midpoint(sp, sq)

# Plot points
ax1.scatter(*sp, s=100, c='red', marker='o', label=f'√p', zorder=5)
ax1.scatter(*sq, s=100, c='blue', marker='o', label=f'√q', zorder=5)
ax1.scatter(*sz, s=100, c='green', marker='^', label=f'√z (ref)', zorder=5)
ax1.scatter(*mid, s=100, c='purple', marker='D', label='midpoint', zorder=5)

# Geodesic arcs
arc_pq = geodesic_arc(sp, sq)
arc_zm = geodesic_arc(sz, mid)
ax1.plot(arc_pq[:,0], arc_pq[:,1], arc_pq[:,2], 'k-', linewidth=2, alpha=0.7)
ax1.plot(arc_zm[:,0], arc_zm[:,1], arc_zm[:,2], 'g--', linewidth=2, alpha=0.7)

# Flat midpoint for comparison
flat_mid = (sp + sq) / 2
flat_norm = flat_mid / np.linalg.norm(flat_mid)
ax1.scatter(*flat_norm, s=60, c='orange', marker='x', label='flat mid (proj)', zorder=5)

ax1.set_xlabel('$\\sqrt{p_1}$')
ax1.set_ylabel('$\\sqrt{p_2}$')
ax1.set_zlabel('$\\sqrt{p_3}$')
ax1.set_title('Fisher-Rao Sphere (Positive Octant)\nK = 1: Positive Curvature', fontsize=12)
ax1.legend(fontsize=8, loc='upper left')

# --- Right panel: Contraction ratio vs angle ---
ax2 = fig.add_subplot(122)

theta_range = np.linspace(0.01, np.pi/2 - 0.01, 100)
for theta_fixed in [0.2, 0.5, 0.8, 1.2]:
    ratios = []
    for theta in theta_range:
        avg_cos = (np.cos(theta) + np.cos(theta_fixed)) / 2
        mid_cos = np.cos((theta + theta_fixed) / 2)
        if abs(avg_cos) > 1e-10:
            ratios.append(mid_cos / avg_cos)
        else:
            ratios.append(np.nan)
    ax2.plot(np.degrees(theta_range), ratios,
             label=f'$\\theta_2$ = {np.degrees(theta_fixed):.0f}°')

ax2.axhline(y=1, color='k', linestyle='--', alpha=0.5, label='Flat space (K=0)')
ax2.set_xlabel('$\\theta_1$ (degrees)')
ax2.set_ylabel('Contraction ratio')
ax2.set_title('Curvature Contraction Ratio\n$\\cos(\\theta_{mid}) / \\mathrm{avg}(\\cos\\theta_i)$', fontsize=12)
ax2.legend(fontsize=9)
ax2.set_ylim(0.95, 1.15)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_curvature_contraction.png', dpi=150, bbox_inches='tight')
print("Saved viz_curvature_contraction.png")


#!/usr/bin/env python3
"""
Visualization: Polarization Index on the Probability Simplex

Shows how voter distributions on the simplex create varying levels
of polarization, and how this connects to Arrow's impossibility.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def hellinger_sq(p, q):
    return 1.0 - np.sum(np.sqrt(p * q))

def polarization_index(voters):
    m = len(voters)
    if m <= 1:
        return 0.0
    total = sum(hellinger_sq(voters[i], voters[j])
                for i in range(m) for j in range(m) if i != j)
    return total / (m * (m - 1))

def simplex_to_cartesian(p):
    """Convert 3D simplex coords to 2D Cartesian for plotting."""
    x = p[1] + p[2] / 2
    y = p[2] * np.sqrt(3) / 2
    return x, y


fig, axes = plt.subplots(1, 3, figsize=(15, 5))

scenarios = [
    ("Low Polarization\n(Consensus)",
     np.array([[0.6, 0.25, 0.15], [0.55, 0.3, 0.15],
               [0.65, 0.2, 0.15], [0.6, 0.22, 0.18], [0.58, 0.27, 0.15]])),
    ("Medium Polarization\n(Disagreement)",
     np.array([[0.6, 0.3, 0.1], [0.2, 0.5, 0.3],
               [0.3, 0.2, 0.5], [0.4, 0.4, 0.2], [0.15, 0.35, 0.5]])),
    ("High Polarization\n(Extreme)",
     np.array([[0.9, 0.05, 0.05], [0.05, 0.9, 0.05],
               [0.05, 0.05, 0.9], [0.85, 0.1, 0.05], [0.05, 0.1, 0.85]])),
]

for ax, (title, voters) in zip(axes, scenarios):
    # Draw simplex
    corners = np.array([[0, 0], [1, 0], [0.5, np.sqrt(3)/2]])
    triangle = plt.Polygon(corners, fill=False, edgecolor='gray', linewidth=2)
    ax.add_patch(triangle)

    # Plot voter positions
    colors = plt.cm.Set1(np.linspace(0, 1, len(voters)))
    for i, v in enumerate(voters):
        x, y = simplex_to_cartesian(v)
        ax.scatter(x, y, c=[colors[i]], s=150, zorder=5, edgecolors='black')
        ax.annotate(f'V{i+1}', (x, y), textcoords="offset points",
                   xytext=(5, 5), fontsize=9)

    # Draw pairwise connections
    for i in range(len(voters)):
        for j in range(i+1, len(voters)):
            xi, yi = simplex_to_cartesian(voters[i])
            xj, yj = simplex_to_cartesian(voters[j])
            h2 = hellinger_sq(voters[i], voters[j])
            ax.plot([xi, xj], [yi, yj], 'r-', alpha=min(h2 * 5, 0.8),
                   linewidth=h2 * 10 + 0.5)

    pi_val = polarization_index(voters)
    ax.set_title(f'{title}\nπ = {pi_val:.4f}', fontsize=12)
    ax.set_xlim(-0.1, 1.1)
    ax.set_ylim(-0.1, 1.0)
    ax.set_aspect('equal')
    ax.axis('off')

    # Label vertices
    ax.text(-0.05, -0.05, 'A', fontsize=12, fontweight='bold')
    ax.text(1.02, -0.05, 'B', fontsize=12, fontweight='bold')
    ax.text(0.48, np.sqrt(3)/2 + 0.03, 'C', fontsize=12, fontweight='bold')

plt.suptitle('Polarization Index on the Probability Simplex\n'
             'Red lines = Hellinger distance (thicker = more different)',
             fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('viz_polarization.png', dpi=150, bbox_inches='tight')
print("Saved viz_polarization.png")
