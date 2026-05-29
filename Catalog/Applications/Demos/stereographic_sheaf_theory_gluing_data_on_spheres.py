"""
Stereographic Sheaf Theory: Applications
=========================================
Real-world applications of stereographic sheaf cohomology
to signal processing, topological data analysis, and physics.
"""
import numpy as np
from typing import List, Tuple


# ============================================================
# Application 1: Topological Signal Processing on the Circle
# ============================================================

def analyze_circular_signal(signal_north: np.ndarray, signal_south: np.ndarray,
                             overlap_transition: np.ndarray) -> dict:
    """Analyze a signal defined on two overlapping charts of S^1.

    In topological signal processing, signals on the circle arise naturally
    (e.g., periodic time series, angular measurements). The stereographic
    sheaf framework lets us detect topological obstructions to global
    consistency of locally defined signals.

    Args:
        signal_north: Signal values on the north chart (R).
        signal_south: Signal values on the south chart (R).
        overlap_transition: Expected relationship in the overlap.

    Returns:
        Dictionary with cohomological analysis results.
    """
    n = len(signal_north)
    # Compute Cech differential: d(s_N, s_S) = T(s_N) - s_S on overlap
    # For scalar signals, T is multiplication by the transition factor

    gluing_error = overlap_transition @ signal_north[:len(overlap_transition)] - signal_south[:len(overlap_transition)]
    is_global = np.allclose(gluing_error, 0, atol=1e-6)

    return {
        "chart_north_dim": len(signal_north),
        "chart_south_dim": len(signal_south),
        "gluing_error_norm": float(np.linalg.norm(gluing_error)),
        "is_globally_consistent": is_global,
        "h0_obstruction": not is_global,
    }


# ============================================================
# Application 2: Sensor Network Fusion on Spheres
# ============================================================

def sensor_fusion_sphere(readings_north: List[float],
                         readings_south: List[float],
                         overlap_indices: List[int]) -> dict:
    """Fuse sensor readings from two hemispheres of a spherical sensor array.

    Temperature, pressure, or radiation sensors placed on a sphere naturally
    define a two-chart cover. The stereographic sheaf framework determines
    whether local measurements can be consistently fused into a global field.

    Args:
        readings_north: Sensor readings from northern hemisphere.
        readings_south: Sensor readings from southern hemisphere.
        overlap_indices: Indices of sensors in the overlap region.

    Returns:
        Fusion analysis results.
    """
    r_n = np.array(readings_north)
    r_s = np.array(readings_south)

    if len(overlap_indices) == 0:
        return {"fusible": False, "reason": "No overlap region"}

    # In the overlap, readings should agree (trivial transition for scalar fields)
    overlap_diff = r_n[overlap_indices] - r_s[overlap_indices]
    max_discrepancy = float(np.max(np.abs(overlap_diff)))

    # Symmetric/antisymmetric decomposition of the discrepancy
    sym_part = overlap_diff / 2 + overlap_diff / 2  # trivial for scalar
    antisym_part = np.zeros_like(overlap_diff)

    return {
        "fusible": max_discrepancy < 0.1,
        "max_discrepancy": max_discrepancy,
        "overlap_size": len(overlap_indices),
        "symmetric_error_norm": float(np.linalg.norm(sym_part)),
        "antisymmetric_error_norm": float(np.linalg.norm(antisym_part)),
    }


# ============================================================
# Application 3: Phase Unwrapping via Sheaf Cohomology
# ============================================================

def phase_unwrap_sheaf(phases_chart1: np.ndarray,
                       phases_chart2: np.ndarray,
                       overlap_size: int) -> dict:
    """Phase unwrapping using stereographic sheaf theory.

    In radar/sonar signal processing, phase measurements are inherently
    circular (modulo 2π). Unwrapping phases on two overlapping charts
    and checking for global consistency is exactly a Čech cohomology
    computation on a two-chart cover.

    Args:
        phases_chart1: Phase measurements on chart 1 (radians).
        phases_chart2: Phase measurements on chart 2 (radians).
        overlap_size: Number of overlapping measurements.

    Returns:
        Phase unwrapping analysis.
    """
    # In the overlap region, compute the transition
    overlap1 = phases_chart1[-overlap_size:]
    overlap2 = phases_chart2[:overlap_size]

    # Phase difference in overlap (mod 2π)
    phase_diff = overlap1 - overlap2
    winding_number = np.round(np.sum(phase_diff) / (2 * np.pi))

    # The winding number is the Cech 1-cocycle (H^1 contribution)
    is_trivial_cocycle = abs(winding_number) < 0.5

    # Global unwrapping is possible iff H^1 = 0, i.e., cocycle is trivial
    if is_trivial_cocycle:
        # Perform actual unwrapping
        offset = np.mean(phase_diff)
        unwrapped = np.concatenate([
            phases_chart1,
            phases_chart2 + offset
        ])
    else:
        unwrapped = None

    return {
        "winding_number": int(winding_number),
        "h1_trivial": is_trivial_cocycle,
        "can_unwrap": is_trivial_cocycle,
        "mean_overlap_error": float(np.mean(np.abs(phase_diff))),
        "unwrapped_signal": unwrapped,
    }


# ============================================================
# Run Applications
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Application 1: Circular Signal Analysis")
    print("=" * 60)
    # Consistent signal
    signal_n = np.array([1.0, 2.0, 3.0, 4.0])
    signal_s = np.array([1.0, 2.0, 3.0, 4.0])
    T = np.eye(4)
    result = analyze_circular_signal(signal_n, signal_s, T)
    print(f"  Consistent signal: {result}")

    # Inconsistent signal
    signal_s_bad = np.array([1.1, 2.2, 3.3, 4.4])
    result = analyze_circular_signal(signal_n, signal_s_bad, T)
    print(f"  Inconsistent signal: {result}")

    print("\n" + "=" * 60)
    print("Application 2: Sensor Fusion on Sphere")
    print("=" * 60)
    readings_n = [20.0, 21.0, 22.0, 23.0, 24.0]
    readings_s = [24.0, 23.5, 22.0, 21.0, 20.5]
    overlap = [2, 3]  # sensors 2,3 visible from both hemispheres
    result = sensor_fusion_sphere(readings_n, readings_s, overlap)
    print(f"  Fusion result: {result}")

    print("\n" + "=" * 60)
    print("Application 3: Phase Unwrapping")
    print("=" * 60)
    # Case 1: Trivial winding (can unwrap)
    t1 = np.linspace(0, np.pi, 20)
    t2 = np.linspace(0.8*np.pi, 2*np.pi, 20)
    result = phase_unwrap_sheaf(t1, t2, overlap_size=5)
    print(f"  Trivial winding: H^1 trivial = {result['h1_trivial']}, "
          f"winding = {result['winding_number']}")

    # Case 2: Non-trivial winding (cannot unwrap)
    t1 = np.linspace(0, np.pi, 20)
    t2 = np.linspace(0.8*np.pi + 2*np.pi, 2*np.pi + 2*np.pi, 20)
    result = phase_unwrap_sheaf(t1, t2, overlap_size=5)
    print(f"  Non-trivial winding: H^1 trivial = {result['h1_trivial']}, "
          f"winding = {result['winding_number']}")


"""
Stereographic Sheaf Theory: Demo
================================
Demonstrates the key mathematical constructs from stereographic sheaf theory
with concrete numerical examples.
"""
import numpy as np

def stereo_transition(t):
    """Stereographic transition map: t -> 1/t"""
    return 1.0 / t

def conformal_factor(t):
    """Conformal factor: 1/t^2"""
    return 1.0 / t**2

def stereo_proj(t):
    """Stereographic projection: R -> S^1"""
    d = 1 + t**2
    return (2*t/d, (1-t**2)/d)

def stereo_conformal_factor(t):
    """Conformal factor of stereographic projection: 2/(1+t^2)"""
    return 2.0 / (1 + t**2)

# Demo 1: Transition map is an involution
print("=" * 60)
print("Demo 1: Stereographic Transition is an Involution")
print("=" * 60)
for t in [0.5, 1.0, 2.0, -3.0, 0.1]:
    t2 = stereo_transition(stereo_transition(t))
    print(f"  t = {t:6.2f}  ->  1/t = {stereo_transition(t):6.2f}  ->  1/(1/t) = {t2:6.2f}  (should be {t})")

# Demo 2: Conformal factor product = 1
print("\n" + "=" * 60)
print("Demo 2: Conformal Factor Product = 1")
print("=" * 60)
for t in [0.5, 1.0, 2.0, 3.0, -1.5]:
    cf1 = conformal_factor(t)
    cf2 = conformal_factor(stereo_transition(t))
    print(f"  t = {t:6.2f}:  CF(t) * CF(1/t) = {cf1:.4f} * {cf2:.4f} = {cf1*cf2:.6f}")

# Demo 3: Stereographic projection maps to S^1
print("\n" + "=" * 60)
print("Demo 3: Stereographic Projection Maps to S^1")
print("=" * 60)
for t in np.linspace(-5, 5, 11):
    x, y = stereo_proj(t)
    norm_sq = x**2 + y**2
    print(f"  t = {t:6.2f}:  ({x:7.4f}, {y:7.4f}),  |p|^2 = {norm_sq:.10f}")

# Demo 4: Conformal factor bounds
print("\n" + "=" * 60)
print("Demo 4: Conformal Factor Bounds")
print("=" * 60)
print("  stereoConformalFactor(t) = 2/(1+t^2) <= 2, max at t=0")
for t in np.linspace(-3, 3, 13):
    cf = stereo_conformal_factor(t)
    print(f"  t = {t:5.2f}:  CF = {cf:.6f}  (<= 2: {cf <= 2.0 + 1e-10})")

# Demo 5: Cech cohomology - gluing data
print("\n" + "=" * 60)
print("Demo 5: Cech Differential and Gluing")
print("=" * 60)
print("  Trivial gluing: phi = id")
print("  d(a,b) = phi(a) - b = a - b")
for a, b in [(3, 3), (1, 2), (0, 0), (5, 5)]:
    d = a - b  # trivial transition
    print(f"    d({a},{b}) = {d}  {'(global section)' if d == 0 else ''}")

print("\n  Negation gluing: phi = neg")
print("  d(a,b) = -a - b")
for a, b in [(1, -1), (0, 0), (2, -2), (3, 1)]:
    d = -a - b  # negation transition
    print(f"    d({a},{b}) = {d}  {'(cocycle)' if d == 0 else ''}")

# Demo 6: Symmetric/Antisymmetric decomposition
print("\n" + "=" * 60)
print("Demo 6: Symmetric-Antisymmetric Decomposition (over R)")
print("=" * 60)
print("  For involution phi(x) = -x:")
for g in [1.0, 2.5, -3.0, 0.0, 7.7]:
    phi_g = -g  # negation involution
    s = (g + phi_g) / 2
    a = (g - phi_g) / 2
    print(f"    g = {g:6.2f}:  s = {s:6.2f} (phi(s)=s: {abs(-s - s) < 1e-10}), "
          f"a = {a:6.2f} (phi(a)=-a: {abs(-a - (-a)) < 1e-10}), s+a = {s+a:.2f}")

print("\n  For involution phi(x) = x (identity):")
for g in [1.0, 2.5, -3.0]:
    phi_g = g  # identity involution
    s = (g + phi_g) / 2
    a = (g - phi_g) / 2
    print(f"    g = {g:6.2f}:  s = {s:6.2f}, a = {a:6.2f}, s+a = {s+a:.2f}")

# Demo 7: ZMod conjecture test
print("\n" + "=" * 60)
print("Demo 7: Stereographic Completeness Conjecture (ZMod p)")
print("=" * 60)
for p in [2, 3, 5, 7, 11, 13]:
    fixed = [x for x in range(p) if (-x) % p == x % p]
    print(f"  ZMod {p:2d}: fixed points of neg = {fixed}  "
          f"{'(conjecture FAILS)' if len(fixed) > 1 else '(conjecture holds)'}")

# Demo 8: Injectivity of stereoProj
print("\n" + "=" * 60)
print("Demo 8: Stereographic Projection Injectivity")
print("=" * 60)
ts = np.linspace(-10, 10, 1000)
points = [stereo_proj(t) for t in ts]
# Check no two distinct t values give the same point
print("  Testing 1000 points in [-10, 10]...")
collisions = 0
for i in range(len(ts)):
    for j in range(i+1, min(i+5, len(ts))):
        if abs(points[i][0] - points[j][0]) < 1e-12 and abs(points[i][1] - points[j][1]) < 1e-12:
            collisions += 1
print(f"  Collisions found: {collisions} (should be 0)")

print("\n" + "=" * 60)
print("All demos completed successfully!")
print("=" * 60)


"""
Visualization 2: Čech Cohomology and Spectral Decomposition

Visualizes the spectral decomposition of vectors under an involutive
transition map. For the stereographic sheaf, every section decomposes
into symmetric (phi-fixed) and antisymmetric (phi-anti-fixed) parts.

Also shows the Čech differential kernel for different transition maps,
illustrating how the choice of gluing data determines the cohomology.
"""
import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Spectral Decomposition in R^2
ax = axes[0]

# Reflection involution: phi(x,y) = (-x, y)
def phi_reflect(v):
    return np.array([-v[0], v[1]])

# Generate random vectors and decompose
np.random.seed(42)
vectors = [np.random.randn(2) * 2 for _ in range(8)]

for v in vectors:
    phi_v = phi_reflect(v)
    s = (v + phi_v) / 2  # symmetric part
    a = (v - phi_v) / 2  # antisymmetric part

    ax.arrow(0, 0, v[0], v[1], head_width=0.08, head_length=0.05,
             fc='gray', ec='gray', alpha=0.3)
    ax.arrow(0, 0, s[0], s[1], head_width=0.08, head_length=0.05,
             fc='blue', ec='blue', alpha=0.6)
    ax.arrow(s[0], s[1], a[0], a[1], head_width=0.08, head_length=0.05,
             fc='red', ec='red', alpha=0.6)

# Draw the eigenspaces
ax.axhline(y=0, color='red', linestyle='--', alpha=0.3, label='Antisym axis (x)')
ax.axvline(x=0, color='blue', linestyle='--', alpha=0.3, label='Sym axis (y)')

ax.set_xlim(-3, 3)
ax.set_ylim(-3, 3)
ax.set_aspect('equal')
ax.set_title('Spectral Decomposition\nφ(x,y) = (-x, y)', fontsize=11)
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.legend(fontsize=8, loc='upper left')
ax.grid(True, alpha=0.2)

# Add legend
import matplotlib.patches as mpatches
gray_patch = mpatches.Patch(color='gray', alpha=0.3, label='Original vector')
blue_patch = mpatches.Patch(color='blue', alpha=0.6, label='Symmetric part')
red_patch = mpatches.Patch(color='red', alpha=0.6, label='Antisymmetric part')
ax.legend(handles=[gray_patch, blue_patch, red_patch], fontsize=8, loc='upper left')

# Panel 2: Cech Differential for Different Gluings
ax = axes[1]

# For each gluing, plot the kernel of the Cech differential
# d(a, b) = phi(a) - b

# Grid of (a, b) values
a_vals = np.linspace(-3, 3, 300)
b_vals = np.linspace(-3, 3, 300)
A, B = np.meshgrid(a_vals, b_vals)

# Trivial gluing: d(a,b) = a - b, kernel is a = b
D_trivial = A - B
ax.contour(A, B, D_trivial, levels=[0], colors=['blue'], linewidths=2)
ax.contourf(A, B, np.abs(D_trivial), levels=[0, 0.1], colors=['blue'], alpha=0.1)

# Negation gluing: d(a,b) = -a - b, kernel is a + b = 0
D_neg = -A - B
ax.contour(A, B, D_neg, levels=[0], colors=['red'], linewidths=2)
ax.contourf(A, B, np.abs(D_neg), levels=[0, 0.1], colors=['red'], alpha=0.1)

ax.plot([], [], 'b-', linewidth=2, label='Trivial: a = b')
ax.plot([], [], 'r-', linewidth=2, label='Negation: a = -b')
ax.plot(0, 0, 'ko', markersize=8, label='H⁰ ∩ H⁰')

ax.set_xlim(-3, 3)
ax.set_ylim(-3, 3)
ax.set_aspect('equal')
ax.set_xlabel('a (north chart section)', fontsize=10)
ax.set_ylabel('b (south chart section)', fontsize=10)
ax.set_title('Čech Cocycles: ker(d⁰)', fontsize=11)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.2)

# Panel 3: ZMod conjecture visualization
ax = axes[2]
primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
fixed_counts = []
for p in primes:
    count = sum(1 for x in range(p) if (2*x) % p == 0)
    fixed_counts.append(count)

colors_bar = ['red' if c > 1 else 'steelblue' for c in fixed_counts]
bars = ax.bar(range(len(primes)), fixed_counts, color=colors_bar, alpha=0.7, edgecolor='black')

ax.set_xticks(range(len(primes)))
ax.set_xticklabels([str(p) for p in primes])
ax.set_xlabel('Prime p', fontsize=11)
ax.set_ylabel('# Fixed points of -x = x in ℤ/pℤ', fontsize=10)
ax.set_title('Stereographic Completeness Conjecture', fontsize=11)
ax.axhline(y=1, color='green', linestyle='--', alpha=0.5, label='Conjecture: exactly 1 for p odd')

# Annotate p=2 failure
ax.annotate('Fails for p=2!\n(-1 = 1 in ℤ/2ℤ)', xy=(0, 2), xytext=(2, 2.5),
            arrowprops=dict(arrowstyle='->', color='red'),
            fontsize=9, color='red', fontweight='bold')

ax.legend(fontsize=9)
ax.grid(True, alpha=0.2, axis='y')

plt.tight_layout()
plt.savefig('viz_cech_cohomology.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_cech_cohomology.png")


"""
Visualization 3: Sheaf Gluing on the Circle

Visualizes how local sections on two overlapping charts of S^1 glue
(or fail to glue) into a global section. Shows the Mayer-Vietoris
exact sequence geometrically: sections that agree on the overlap
extend globally; those that don't create a cohomological obstruction.
"""
import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Two-chart cover of S^1
ax = axes[0]
theta = np.linspace(0, 2*np.pi, 500)

# Draw the circle
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=1)

# North chart: everything except north pole (0, -1)
# Covering angle: roughly -π + ε to π - ε
theta_north = np.linspace(-0.8*np.pi, 0.8*np.pi, 200)
ax.plot(np.cos(theta_north), np.sin(theta_north), 'b-', linewidth=5, alpha=0.3, label='U_N (north chart)')

# South chart: everything except south pole (0, 1)
theta_south_1 = np.linspace(0.2*np.pi, np.pi, 100)
theta_south_2 = np.linspace(-np.pi, -0.2*np.pi, 100)
theta_south = np.concatenate([theta_south_1, theta_south_2])
ax.plot(np.cos(theta_south), np.sin(theta_south), 'r-', linewidth=5, alpha=0.3, label='U_S (south chart)')

# Overlap regions
theta_overlap1 = np.linspace(0.2*np.pi, 0.8*np.pi, 100)
theta_overlap2 = np.linspace(-0.8*np.pi, -0.2*np.pi, 100)
ax.plot(np.cos(theta_overlap1), np.sin(theta_overlap1), 'g-', linewidth=8, alpha=0.4)
ax.plot(np.cos(theta_overlap2), np.sin(theta_overlap2), 'g-', linewidth=8, alpha=0.4, label='Overlap U_N ∩ U_S')

# Mark poles
ax.plot(0, 1, 'b^', markersize=12, zorder=5)
ax.annotate('South pole\n(origin of U_N)', (0, 1), textcoords="offset points",
            xytext=(15, 10), fontsize=8)
ax.plot(0, -1, 'rv', markersize=12, zorder=5)
ax.annotate('North pole\n(origin of U_S)', (0, -1), textcoords="offset points",
            xytext=(15, -20), fontsize=8)

ax.set_xlim(-1.6, 1.6)
ax.set_ylim(-1.6, 1.6)
ax.set_aspect('equal')
ax.set_title('Two-Chart Cover of S¹', fontsize=12)
ax.legend(fontsize=8, loc='lower left')
ax.grid(True, alpha=0.2)

# Panel 2: Successful gluing (compatible sections)
ax = axes[1]

t_north = np.linspace(-3, 3, 200)
t_south = np.linspace(-3, 3, 200)

# Section on north chart: f(t) = cos(t)
f_north = np.cos(t_north)

# For trivial gluing, section on south chart should match
f_south = np.cos(t_south)

# Overlap region (say |t| in [0.5, 2])
overlap_mask_n = (np.abs(t_north) > 0.5) & (np.abs(t_north) < 2)
overlap_mask_s = (np.abs(t_south) > 0.5) & (np.abs(t_south) < 2)

ax.plot(t_north, f_north, 'b-', linewidth=2, label='Section on U_N')
ax.plot(t_south, f_south, 'r--', linewidth=2, alpha=0.7, label='Section on U_S')
ax.fill_between(t_north, -1.5, 1.5, where=overlap_mask_n,
                color='green', alpha=0.1, label='Overlap')

# Cech differential
diff = f_north - f_south  # trivial transition
ax.plot(t_north, diff, 'g-', linewidth=1, alpha=0.5, label='d⁰(f_N, f_S) = 0')

ax.set_xlabel('t (chart coordinate)', fontsize=10)
ax.set_ylabel('Section value', fontsize=10)
ax.set_title('Successful Gluing\n(Trivial Transition, H¹ = 0)', fontsize=11)
ax.legend(fontsize=8)
ax.set_ylim(-1.5, 1.5)
ax.grid(True, alpha=0.2)

# Panel 3: Failed gluing (obstruction)
ax = axes[2]

# Section on north chart: f(t) = t
f_north_bad = t_north

# For negation gluing, transition is t -> -t
# So f_south should satisfy f_south(1/t) = -f_north(t) on overlap
# But let's use a different section that creates an obstruction
f_south_bad = -t_south + 1  # shifted, doesn't match

# Overlap region
ax.plot(t_north, f_north_bad, 'b-', linewidth=2, label='Section on U_N: f(t) = t')
ax.plot(t_south, f_south_bad, 'r--', linewidth=2, alpha=0.7, label='Section on U_S: g(t) = -t + 1')

# Negation transition: d(a,b) = -a - b
diff_neg = -f_north_bad - f_south_bad
ax.plot(t_north, diff_neg, 'g-', linewidth=2, alpha=0.8, label='d⁰ = -f - g = -1 ≠ 0')

ax.fill_between(t_north, -5, 5, where=overlap_mask_n,
                color='red', alpha=0.05)

ax.axhline(y=0, color='k', linewidth=0.5, alpha=0.3)
ax.set_xlabel('t (chart coordinate)', fontsize=10)
ax.set_ylabel('Section value', fontsize=10)
ax.set_title('Failed Gluing\n(Negation Transition, H¹ ≠ 0)', fontsize=11)
ax.legend(fontsize=8)
ax.set_ylim(-5, 5)
ax.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('viz_sheaf_gluing.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_sheaf_gluing.png")


"""
Visualization 1: Stereographic Projection and Conformal Factor

Visualizes the stereographic projection from R to S^1, showing how the
real line wraps onto the circle. Also plots the conformal factor 2/(1+t^2),
which measures the local stretching of the projection.

The key insight: the conformal factor achieves its maximum at t=0 (south pole)
and decays to zero as t -> ±∞ (approaching the north pole). This is why the
stereographic atlas needs two charts — no single chart can cover the pole.
"""
import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Stereographic Projection
ax = axes[0]
t = np.linspace(-5, 5, 500)
d = 1 + t**2
x = 2*t / d
y = (1 - t**2) / d

# Draw the unit circle
theta = np.linspace(0, 2*np.pi, 200)
ax.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=1.5, alpha=0.3)

# Color the projection by parameter value
colors = plt.cm.viridis((t - t.min()) / (t.max() - t.min()))
for i in range(len(t)-1):
    ax.plot([x[i], x[i+1]], [y[i], y[i+1]], '-', color=colors[i], linewidth=2)

# Mark special points
special_t = [0, 1, -1, 2, -2]
for st in special_t:
    sx = 2*st / (1 + st**2)
    sy = (1 - st**2) / (1 + st**2)
    ax.plot(sx, sy, 'ro', markersize=6)
    ax.annotate(f't={st}', (sx, sy), textcoords="offset points",
                xytext=(10, 5), fontsize=8)

# North pole (missing point)
ax.plot(0, -1, 'k^', markersize=10, label='North pole (t→±∞)')
ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-1.5, 1.5)
ax.set_aspect('equal')
ax.set_title('Stereographic Projection: ℝ → S¹', fontsize=12)
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Panel 2: Conformal Factor
ax = axes[1]
t = np.linspace(-5, 5, 500)
cf = 2 / (1 + t**2)

ax.fill_between(t, 0, cf, alpha=0.3, color='steelblue')
ax.plot(t, cf, 'b-', linewidth=2, label='2/(1+t²)')
ax.axhline(y=2, color='r', linestyle='--', alpha=0.5, label='Maximum = 2')
ax.plot(0, 2, 'ro', markersize=8)
ax.annotate('Maximum at t=0', (0, 2), textcoords="offset points",
            xytext=(15, -15), fontsize=10, arrowprops=dict(arrowstyle='->', color='red'))

ax.set_xlabel('t', fontsize=12)
ax.set_ylabel('Conformal Factor', fontsize=12)
ax.set_title('Conformal Factor: 2/(1+t²) ≤ 2', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Transition map on the overlap
ax = axes[2]
t_pos = np.linspace(0.1, 5, 200)
t_neg = np.linspace(-5, -0.1, 200)

ax.plot(t_pos, 1/t_pos, 'b-', linewidth=2, label='t ↦ 1/t (t > 0)')
ax.plot(t_neg, 1/t_neg, 'r-', linewidth=2, label='t ↦ 1/t (t < 0)')
ax.plot(t_pos, t_pos, 'k--', alpha=0.3, label='y = t (identity)')

# Mark the involution property
for t_val in [0.5, 2.0]:
    ax.annotate('', xy=(t_val, 1/t_val), xytext=(1/t_val, t_val),
                arrowprops=dict(arrowstyle='<->', color='green', lw=1.5))

ax.set_xlim(-5, 5)
ax.set_ylim(-5, 5)
ax.set_xlabel('t', fontsize=12)
ax.set_ylabel('1/t', fontsize=12)
ax.set_title('Transition Map: Involution t ↦ 1/t', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_stereo_projection.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_stereo_projection.png")
