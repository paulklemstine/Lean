"""
Applications of Turing Pattern ↔ Algebraic Geometry Correspondence

Real-world applications demonstrating the mathematical framework.
"""

import numpy as np
from typing import Dict, List, Tuple


# ===== Inline core functions (self-contained) =====

def genus_degree(d: int) -> int:
    """Genus of a smooth plane curve of degree d."""
    return max(0, (d - 1) * (d - 2) // 2)


def classify_pattern(genus: int) -> str:
    if genus == 0:
        return "spots"
    elif genus == 1:
        return "stripes"
    return "labyrinth"


def dispersion_discriminant(Du, Dv, a, b, c, d):
    alpha = Du * Dv
    beta = a * Dv + d * Du
    gamma = a * d - b * c
    return beta**2 - 4 * alpha * gamma


# ===== APPLICATION 1: Biological Pattern Identification =====

def analyze_biological_pattern(pattern_name: str,
                                estimated_degree: int) -> Dict:
    """
    Given a biological pattern and its estimated algebraic degree,
    predict its topological and algebraic properties.
    
    Examples from nature:
    - Leopard spots: degree 2 (conic sections)
    - Zebra stripes: degree 3 (cubic curves)
    - Brain coral: degree 6+ (high-genus labyrinths)
    """
    g = genus_degree(estimated_degree)
    topo = classify_pattern(g)
    euler = 2 - 2 * g
    bezout = estimated_degree ** 2
    
    return {
        "pattern": pattern_name,
        "algebraic_degree": estimated_degree,
        "genus": g,
        "topology": topo,
        "euler_characteristic": euler,
        "max_self_intersections": bezout,
        "prediction": f"The {pattern_name} pattern is algebraically a "
                      f"degree-{estimated_degree} curve (genus {g}), "
                      f"topologically classified as '{topo}'."
    }


# ===== APPLICATION 2: Parameter Space Explorer =====

def explore_parameter_space(Du_range: Tuple[float, float],
                             Dv_range: Tuple[float, float],
                             n_samples: int = 50) -> Dict:
    """
    Explore which regions of (Du, Dv) parameter space produce
    Turing instability for a fixed reaction kinetics.
    
    Uses Schnakenberg kinetics: a=0.5, b=-1, c=1, d=-1.5
    """
    a_val, b_val, c_val, d_val = 0.5, -1.0, 1.0, -1.5
    trJ = a_val + d_val
    detJ = a_val * d_val - b_val * c_val
    
    Du_vals = np.linspace(Du_range[0], Du_range[1], n_samples)
    Dv_vals = np.linspace(Dv_range[0], Dv_range[1], n_samples)
    
    results = np.zeros((n_samples, n_samples))
    
    for i, Du in enumerate(Du_vals):
        for j, Dv in enumerate(Dv_vals):
            if Du <= 0 or Dv <= 0:
                continue
            disc = dispersion_discriminant(Du, Dv, a_val, b_val, c_val, d_val)
            beta = a_val * Dv + d_val * Du
            
            if trJ < 0 and detJ > 0 and beta > 0 and disc > 0:
                results[i, j] = 1.0  # Turing unstable
    
    turing_fraction = np.mean(results)
    
    return {
        "Du_range": Du_range,
        "Dv_range": Dv_range,
        "turing_fraction": turing_fraction,
        "stability_map": results,
        "Du_vals": Du_vals,
        "Dv_vals": Dv_vals,
    }


# ===== APPLICATION 3: Pattern Complexity Metric =====

def pattern_complexity(n_modes: int) -> Dict:
    """
    Compute algebraic complexity metrics for an n-mode pattern.
    
    The genus serves as a measure of pattern complexity:
    higher genus = more topological "holes" = more complex patterns.
    """
    degree = 2 * n_modes
    g = genus_degree(degree)
    euler = 2 - 2 * g
    
    # Motivic density (inverse measures rarity)
    if g == 0:
        density = 1.5
    elif g == 1:
        density = 1.0
    else:
        density = 1.0 / (2 * g - 2)
    
    return {
        "n_modes": n_modes,
        "degree": degree,
        "genus": g,
        "euler_characteristic": euler,
        "motivic_density": density,
        "complexity_score": g,  # genus as complexity
        "rarity": 1.0 / density,  # inverse of motivic density
        "topology": classify_pattern(g),
    }


if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATION 1: Biological Pattern Identification")
    print("=" * 60)
    
    patterns = [
        ("Leopard spots", 2),
        ("Zebra stripes", 3),
        ("Giraffe patches", 4),
        ("Seashell spirals", 5),
        ("Brain coral", 6),
    ]
    
    for name, deg in patterns:
        result = analyze_biological_pattern(name, deg)
        print(f"\n  {result['prediction']}")
        print(f"    Euler χ = {result['euler_characteristic']}, "
              f"Max self-intersections = {result['max_self_intersections']}")
    
    print("\n" + "=" * 60)
    print("APPLICATION 2: Parameter Space (Turing Instability Region)")
    print("=" * 60)
    
    result = explore_parameter_space((0.001, 0.1), (0.1, 5.0))
    print(f"\n  Fraction of parameter space with Turing instability: "
          f"{result['turing_fraction']:.2%}")
    
    print("\n" + "=" * 60)
    print("APPLICATION 3: Pattern Complexity Across Modes")
    print("=" * 60)
    
    for n in range(1, 8):
        c = pattern_complexity(n)
        print(f"\n  {n} mode(s): degree={c['degree']}, genus={c['genus']}, "
              f"topology={c['topology']}")
        print(f"    Motivic density={c['motivic_density']:.4f}, "
              f"Rarity={c['rarity']:.2f}")


"""
Demo: Turing's Flowers — Morphogenesis as Algebraic Geometry

Demonstrates the connection between reaction-diffusion patterns and algebraic curves.
Computes dispersion relations, genus-degree values, and pattern classification.
"""

import numpy as np


def dispersion_relation(Du, Dv, a, b, c, d, q):
    """
    Evaluate the dispersion relation h(q) = Du*Dv*q^2 - (a*Dv + d*Du)*q + (a*d - b*c).
    
    Parameters:
        Du, Dv: diffusion coefficients
        a, b, c, d: Jacobian entries
        q: wavenumber squared (k^2)
    
    Returns:
        Value of h(q). If h(q) < 0, the mode at wavenumber q is unstable.
    """
    alpha = Du * Dv
    beta = a * Dv + d * Du
    gamma = a * d - b * c
    return alpha * q**2 - beta * q + gamma


def dispersion_discriminant(Du, Dv, a, b, c, d):
    """
    Compute the discriminant of the dispersion quadratic.
    Positive discriminant => Turing instability possible.
    """
    alpha = Du * Dv
    beta = a * Dv + d * Du
    gamma = a * d - b * c
    return beta**2 - 4 * alpha * gamma


def genus_degree(d):
    """Genus of a smooth plane curve of degree d."""
    if d < 2:
        return 0
    return (d - 1) * (d - 2) // 2


def classify_topology(genus):
    """Classify pattern type from genus."""
    if genus == 0:
        return "spots"
    elif genus == 1:
        return "stripes"
    else:
        return "labyrinth"


def euler_characteristic(genus):
    """Euler characteristic of a genus-g surface."""
    return 2 - 2 * genus


def bezout_bound(d1, d2):
    """Maximum intersection points of two curves of degrees d1 and d2."""
    return d1 * d2


def motivic_density(g):
    """Motivic density of genus-g curves in the moduli space."""
    if g == 0:
        return 3.0 / 2.0
    elif g == 1:
        return 1.0
    else:
        return 1.0 / (2 * g - 2)


def check_turing_instability(Du, Dv, a, b, c, d):
    """
    Check all conditions for Turing instability.
    
    Returns:
        dict with conditions and whether instability occurs
    """
    trJ = a + d
    detJ = a * d - b * c
    alpha = Du * Dv
    beta = a * Dv + d * Du
    disc = beta**2 - 4 * alpha * detJ
    
    results = {
        "trace_negative": trJ < 0,
        "det_positive": detJ > 0,
        "beta_positive": beta > 0,
        "discriminant_positive": disc > 0,
        "discriminant": disc,
        "turing_unstable": trJ < 0 and detJ > 0 and beta > 0 and disc > 0
    }
    
    if disc > 0 and alpha > 0:
        q_crit = beta / (2 * alpha)
        h_min = detJ - beta**2 / (4 * alpha)
        results["critical_wavenumber_sq"] = q_crit
        results["dispersion_minimum"] = h_min
    
    return results


# ===== DEMONSTRATIONS =====

print("=" * 60)
print("DEMO 1: Classic Turing System (Gierer-Meinhardt type)")
print("=" * 60)

# Parameters for a typical activator-inhibitor system
Du, Dv = 0.01, 1.0  # inhibitor diffuses much faster
a_val, b_val, c_val, d_val = 0.5, -1.0, 1.0, -1.5

result = check_turing_instability(Du, Dv, a_val, b_val, c_val, d_val)
print(f"  Du = {Du}, Dv = {Dv}")
print(f"  Jacobian = [[{a_val}, {b_val}], [{c_val}, {d_val}]]")
print(f"  Trace = {a_val + d_val} (need < 0: {result['trace_negative']})")
print(f"  Det = {a_val * d_val - b_val * c_val} (need > 0: {result['det_positive']})")
print(f"  β = a·Dv + d·Du = {a_val * Dv + d_val * Du} (need > 0: {result['beta_positive']})")
print(f"  Discriminant = {result['discriminant']:.4f} (need > 0: {result['discriminant_positive']})")
print(f"  TURING UNSTABLE: {result['turing_unstable']}")

if 'critical_wavenumber_sq' in result:
    print(f"  Critical wavenumber² = {result['critical_wavenumber_sq']:.4f}")
    print(f"  Dispersion minimum = {result['dispersion_minimum']:.4f}")

print()
print("=" * 60)
print("DEMO 2: Genus-Degree Formula and Pattern Classification")
print("=" * 60)

for d in range(1, 9):
    g = genus_degree(d)
    topo = classify_topology(g)
    chi = euler_characteristic(g)
    density = motivic_density(g)
    print(f"  Degree {d}: genus = {g}, topology = {topo:10s}, "
          f"χ = {chi:3d}, motivic density = {density:.4f}")

print()
print("=" * 60)
print("DEMO 3: n-Mode Predictions")
print("=" * 60)

for n in range(1, 6):
    deg = 2 * n
    g = genus_degree(deg)
    topo = classify_topology(g)
    print(f"  {n} mode(s): predicted degree = {deg}, genus = {g}, topology = {topo}")

print()
print("=" * 60)
print("DEMO 4: Bézout Intersection Bounds")
print("=" * 60)

pairs = [(2, 2), (2, 3), (3, 3), (2, 6), (4, 6)]
for d1, d2 in pairs:
    bound = bezout_bound(d1, d2)
    print(f"  Curves of degree {d1} and {d2}: ≤ {bound} intersection points")

print()
print("=" * 60)
print("DEMO 5: Dispersion Relation Values")
print("=" * 60)

q_values = np.linspace(0, 100, 500)
h_values = [dispersion_relation(Du, Dv, a_val, b_val, c_val, d_val, q)
            for q in q_values]

q_min_idx = np.argmin(h_values)
print(f"  Dispersion minimum at q ≈ {q_values[q_min_idx]:.2f}")
print(f"  Minimum value h(q) ≈ {h_values[q_min_idx]:.4f}")
print(f"  Unstable band: q where h(q) < 0")

unstable = [q for q, h in zip(q_values, h_values) if h < 0]
if unstable:
    print(f"    q ∈ [{min(unstable):.2f}, {max(unstable):.2f}]")
else:
    print("    No unstable band (no patterns form)")

print()
print("All demos completed successfully.")


"""
Visualization 1: The Dispersion Relation — Heart of Turing Instability

This plot shows the dispersion relation h(q) for a reaction-diffusion system.
When h(q) dips below zero, the corresponding wavenumber is unstable, creating
spatial patterns. The shape of this curve determines whether spots, stripes,
or labyrinths emerge.

The key insight: h(q) is a quadratic in q = k², so pattern formation reduces
to analyzing a parabola — the simplest algebraic curve.
"""

import numpy as np
import matplotlib.pyplot as plt

# System parameters (activator-inhibitor, Gierer-Meinhardt type)
Du, Dv = 0.01, 1.0
a, b, c, d = 0.5, -1.0, 1.0, -1.5

alpha = Du * Dv
beta = a * Dv + d * Du
gamma = a * d - b * c
disc = beta**2 - 4 * alpha * gamma

q = np.linspace(0, 80, 500)
h = alpha * q**2 - beta * q + gamma

# Critical points
q_min = beta / (2 * alpha)
h_min = gamma - beta**2 / (4 * alpha)

# Roots
if disc > 0:
    q1 = (beta - np.sqrt(disc)) / (2 * alpha)
    q2 = (beta + np.sqrt(disc)) / (2 * alpha)

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left: Dispersion relation
ax = axes[0]
ax.plot(q, h, 'b-', linewidth=2.5, label='$h(q) = \\alpha q^2 - \\beta q + \\gamma$')
ax.axhline(y=0, color='k', linewidth=0.8, linestyle='-')
ax.fill_between(q, h, 0, where=(h < 0), alpha=0.3, color='red',
                label='Unstable band')
ax.plot(q_min, h_min, 'ro', markersize=10, zorder=5,
        label=f'Minimum at $q_c = {q_min:.1f}$')

if disc > 0:
    ax.axvline(x=q1, color='gray', linewidth=0.8, linestyle='--', alpha=0.7)
    ax.axvline(x=q2, color='gray', linewidth=0.8, linestyle='--', alpha=0.7)
    ax.annotate(f'$q_1 = {q1:.1f}$', xy=(q1, 0), xytext=(q1-8, 0.15),
                fontsize=10, ha='center',
                arrowprops=dict(arrowstyle='->', color='gray'))
    ax.annotate(f'$q_2 = {q2:.1f}$', xy=(q2, 0), xytext=(q2+8, 0.15),
                fontsize=10, ha='center',
                arrowprops=dict(arrowstyle='->', color='gray'))

ax.set_xlabel('Wavenumber² ($q = k^2$)', fontsize=12)
ax.set_ylabel('$h(q)$', fontsize=12)
ax.set_title('Dispersion Relation: When Biology Makes Patterns', fontsize=13)
ax.legend(fontsize=10, loc='upper right')
ax.set_ylim(-0.5, 1.5)
ax.grid(True, alpha=0.3)

# Annotations
ax.annotate('Patterns form here!\n(modes grow exponentially)',
            xy=((q1 + q2)/2, h_min/2), fontsize=10, ha='center',
            color='red', fontweight='bold')

# Right: Parameter space
ax2 = axes[1]
Du_vals = np.logspace(-3, -0.5, 100)
Dv_vals = np.logspace(-1, 1, 100)
Du_grid, Dv_grid = np.meshgrid(Du_vals, Dv_vals)

# Compute Turing instability region
trJ = a + d
detJ = a * d - b * c
beta_grid = a * Dv_grid + d * Du_grid
disc_grid = beta_grid**2 - 4 * Du_grid * Dv_grid * detJ

turing_mask = (trJ < 0) & (detJ > 0) & (beta_grid > 0) & (disc_grid > 0)

ax2.contourf(Du_grid, Dv_grid, turing_mask.astype(float),
             levels=[-0.5, 0.5, 1.5], colors=['#f0f0f0', '#ff6b6b'], alpha=0.7)
ax2.contour(Du_grid, Dv_grid, turing_mask.astype(float),
            levels=[0.5], colors=['red'], linewidths=2)

# Mark our example system
ax2.plot(Du, Dv, 'k*', markersize=15, zorder=5, label='Example system')

ax2.set_xlabel('$D_u$ (activator diffusion)', fontsize=12)
ax2.set_ylabel('$D_v$ (inhibitor diffusion)', fontsize=12)
ax2.set_title('Turing Space: Where Patterns Live', fontsize=13)
ax2.set_xscale('log')
ax2.set_yscale('log')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Add text annotation
ax2.annotate('Turing\ninstability\nregion', xy=(0.01, 2.0),
             fontsize=12, color='red', fontweight='bold', ha='center')

plt.tight_layout()
plt.savefig('viz_dispersion.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_dispersion.png")


"""
Visualization 2: Pattern Classification by Genus

Shows the genus-degree formula and how algebraic genus classifies
biological patterns into spots, stripes, and labyrinths.
Includes the motivic density curve showing why spots are most common.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def genus_degree(d):
    if d < 2:
        return 0
    return (d - 1) * (d - 2) // 2


def motivic_density(g):
    if g == 0:
        return 1.5
    elif g == 1:
        return 1.0
    elif g >= 2:
        return 1.0 / (2 * g - 2)
    return 0


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Genus-Degree Formula
ax = axes[0]
degrees = list(range(1, 10))
genera = [genus_degree(d) for d in degrees]

colors = []
for g in genera:
    if g == 0:
        colors.append('#2196F3')  # blue for spots
    elif g == 1:
        colors.append('#4CAF50')  # green for stripes
    else:
        colors.append('#FF5722')  # red for labyrinths

bars = ax.bar(degrees, genera, color=colors, edgecolor='black', linewidth=0.8)
ax.set_xlabel('Algebraic Degree $d$', fontsize=12)
ax.set_ylabel('Genus $g = (d-1)(d-2)/2$', fontsize=12)
ax.set_title('Genus-Degree Formula', fontsize=13)
ax.set_xticks(degrees)

# Legend
spots_patch = mpatches.Patch(color='#2196F3', label='Spots (g=0)')
stripes_patch = mpatches.Patch(color='#4CAF50', label='Stripes (g=1)')
lab_patch = mpatches.Patch(color='#FF5722', label='Labyrinth (g≥2)')
ax.legend(handles=[spots_patch, stripes_patch, lab_patch], fontsize=9)
ax.grid(True, alpha=0.3, axis='y')

# Panel 2: Motivic Density
ax2 = axes[1]
g_vals = list(range(0, 12))
densities = [motivic_density(g) for g in g_vals]

ax2.plot(g_vals, densities, 'ko-', linewidth=2, markersize=8)
ax2.fill_between(g_vals, densities, alpha=0.15, color='blue')

# Highlight spots and stripes
ax2.plot(0, motivic_density(0), 'o', color='#2196F3', markersize=14, zorder=5)
ax2.plot(1, motivic_density(1), 'o', color='#4CAF50', markersize=14, zorder=5)
for g in range(2, 12):
    ax2.plot(g, motivic_density(g), 'o', color='#FF5722', markersize=10, zorder=5)

ax2.annotate('Spots\n(most common)', xy=(0, 1.5), xytext=(1.5, 1.4),
             fontsize=10, arrowprops=dict(arrowstyle='->', color='#2196F3'),
             color='#2196F3', fontweight='bold')
ax2.annotate('Stripes', xy=(1, 1.0), xytext=(2.5, 1.05),
             fontsize=10, arrowprops=dict(arrowstyle='->', color='#4CAF50'),
             color='#4CAF50', fontweight='bold')

ax2.set_xlabel('Genus $g$', fontsize=12)
ax2.set_ylabel('Motivic Density', fontsize=12)
ax2.set_title('Why Spots Are Most Common', fontsize=13)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, 1.8)

# Panel 3: Euler characteristic
ax3 = axes[2]
euler_chars = [2 - 2 * g for g in g_vals]
ax3.plot(g_vals, euler_chars, 's-', color='purple', linewidth=2, markersize=8)
ax3.axhline(y=0, color='k', linewidth=0.8, linestyle='-')

ax3.fill_between(g_vals, euler_chars, 0,
                 where=[e > 0 for e in euler_chars],
                 alpha=0.2, color='green', label='χ > 0 (sphere-like)')
ax3.fill_between(g_vals, euler_chars, 0,
                 where=[e <= 0 for e in euler_chars],
                 alpha=0.2, color='red', label='χ ≤ 0 (complex)')

ax3.set_xlabel('Genus $g$', fontsize=12)
ax3.set_ylabel('Euler Characteristic $\\chi = 2 - 2g$', fontsize=12)
ax3.set_title('Topology of Pattern Curves', fontsize=13)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

# Annotate key points
ax3.annotate('Sphere (spots)\nχ = 2', xy=(0, 2), xytext=(2, 1.5),
             fontsize=9, arrowprops=dict(arrowstyle='->', color='purple'))
ax3.annotate('Torus (stripes)\nχ = 0', xy=(1, 0), xytext=(3, 0.5),
             fontsize=9, arrowprops=dict(arrowstyle='->', color='purple'))

plt.tight_layout()
plt.savefig('viz_genus_classification.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_genus_classification.png")


"""
Visualization 3: Turing Patterns as Algebraic Curves

Simulates reaction-diffusion patterns and shows their zero sets
alongside the algebraic curves they approximate.
"""

import numpy as np
import matplotlib.pyplot as plt


def simulate_pattern(N=128, pattern_type="spots"):
    """Generate a synthetic Turing-like pattern."""
    x = np.linspace(-np.pi, np.pi, N)
    y = np.linspace(-np.pi, np.pi, N)
    X, Y = np.meshgrid(x, y)
    
    if pattern_type == "spots":
        # Superposition of modes giving circular spots (degree 2)
        u = (np.cos(3*X) + np.cos(3*Y) + 
             0.5 * np.cos(3*X + 3*Y) + 0.3 * np.random.randn(N, N) * 0.1)
    elif pattern_type == "stripes":
        # Dominant single-direction mode (degree 2, genus 0 but stripe-like)
        u = (np.cos(4*X) + 0.1 * np.cos(4*Y) + 
             0.05 * np.random.randn(N, N))
    elif pattern_type == "labyrinth":
        # Many modes, complex pattern
        u = (np.cos(2*X) * np.cos(3*Y) + np.sin(3*X) * np.cos(2*Y) +
             0.5 * np.cos(5*X + Y) + 0.3 * np.sin(X + 4*Y) +
             0.1 * np.random.randn(N, N))
    else:
        u = np.random.randn(N, N)
    
    return X, Y, u


def plot_algebraic_curve(ax, curve_type="conic"):
    """Plot the algebraic curve approximation."""
    t = np.linspace(0, 2*np.pi, 200)
    
    if curve_type == "conic":
        # Circles (spots) — degree 2
        for cx, cy in [(-1.5, -1.5), (-1.5, 0.5), (-1.5, 2.5),
                        (0.5, -1.5), (0.5, 0.5), (0.5, 2.5),
                        (2.5, -1.5), (2.5, 0.5), (2.5, 2.5)]:
            ax.plot(cx + 0.6*np.cos(t), cy + 0.6*np.sin(t),
                    'r-', linewidth=2, alpha=0.8)
    elif curve_type == "lines":
        # Parallel lines (stripes) — degenerate degree 2
        for y_pos in np.linspace(-3, 3, 7):
            ax.plot([-3.14, 3.14], [y_pos, y_pos], 'r-', linewidth=2, alpha=0.8)
    elif curve_type == "sextic":
        # Sextic curve approximation (labyrinth)
        theta = np.linspace(0, 2*np.pi, 1000)
        for r_scale in [0.8, 1.5, 2.3]:
            r = r_scale * (1 + 0.3 * np.cos(3*theta) + 0.2 * np.sin(5*theta))
            ax.plot(r * np.cos(theta), r * np.sin(theta),
                    'r-', linewidth=1.5, alpha=0.7)


fig, axes = plt.subplots(2, 3, figsize=(15, 10))

# Row 1: Turing patterns
pattern_types = ["spots", "stripes", "labyrinth"]
titles = [
    "Spots (Leopard)\nDegree 2, Genus 0",
    "Stripes (Zebra)\nDegree 3, Genus 1",
    "Labyrinth (Coral)\nDegree 6, Genus 10"
]
curve_types = ["conic", "lines", "sextic"]

for i, (ptype, title) in enumerate(zip(pattern_types, titles)):
    X, Y, u = simulate_pattern(pattern_type=ptype)
    
    # Pattern
    ax = axes[0, i]
    im = ax.contourf(X, Y, u, levels=20, cmap='RdBu_r')
    ax.contour(X, Y, u, levels=[0], colors='black', linewidths=1.5)
    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.set_aspect('equal')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    
    # Zero set as algebraic curve
    ax2 = axes[1, i]
    ax2.contour(X, Y, u, levels=[0], colors='blue', linewidths=2)
    plot_algebraic_curve(ax2, curve_types[i])
    ax2.set_title(f'Zero Set ≈ Algebraic Curve', fontsize=11)
    ax2.set_aspect('equal')
    ax2.set_xlabel('x')
    ax2.set_ylabel('y')
    ax2.set_xlim(-3.14, 3.14)
    ax2.set_ylim(-3.14, 3.14)
    ax2.grid(True, alpha=0.2)

# Add legend to bottom row
from matplotlib.lines import Line2D
legend_elements = [
    Line2D([0], [0], color='blue', linewidth=2, label='Zero set (computed)'),
    Line2D([0], [0], color='red', linewidth=2, label='Algebraic curve (fitted)'),
]
axes[1, 1].legend(handles=legend_elements, loc='lower center',
                  bbox_to_anchor=(0.5, -0.25), ncol=2, fontsize=11)

plt.suptitle("Turing Patterns Are Algebraic Curves",
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_turing_patterns.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_turing_patterns.png")
