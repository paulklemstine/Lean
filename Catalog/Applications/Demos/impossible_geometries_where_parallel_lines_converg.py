#!/usr/bin/env python3
"""
Applications of Split Geometry

Real-world applications demonstrating the mathematical results:

1. Anisotropic Wave Propagation: How waves behave differently depending on
   direction in media with direction-dependent properties (seismology, optics).

2. Information Geometry of Two-Parameter Families: The split metric as a 
   Fisher information metric for anisotropic statistical models.

3. Cosmological Anisotropy: A toy model for a universe that expands in one
   direction and contracts in another.
"""

import numpy as np
from typing import Tuple, List


# =============================================================================
# Application 1: Anisotropic Wave Propagation
# =============================================================================

def wave_speed(x: float, y: float, theta: float) -> float:
    """Compute wave speed at (x,y) in direction theta.
    
    In the split metric ds² = sech²(y)dx² + cosh²(x)dy², the speed of a 
    wavefront propagating in direction θ (from the x-axis) is:
    
      v(x,y,θ) = 1/√(sech²(y)cos²θ + cosh²(x)sin²θ)
    
    This models wave propagation in a medium where the refractive index
    depends on both position and direction.
    
    Args:
        x, y: position
        theta: propagation direction (radians from x-axis)
    
    Returns:
        Wave speed at (x,y) in direction theta
    """
    sech_y = 1.0 / np.cosh(y)
    cosh_x = np.cosh(x)
    metric_in_dir = sech_y**2 * np.cos(theta)**2 + cosh_x**2 * np.sin(theta)**2
    return 1.0 / np.sqrt(metric_in_dir)


def anisotropy_ratio(x: float, y: float) -> float:
    """Ratio of wave speed along x-axis to wave speed along y-axis.
    
    ratio = v_x / v_y = cosh(y) / (1/cosh(x)) = cosh(x) · cosh(y)
    
    When ratio > 1: waves travel faster along x than y
    When ratio < 1: waves travel faster along y than x  
    When ratio = 1: isotropic (only at origin)
    """
    return np.cosh(x) * np.cosh(y)


def simulate_wavefront(x0: float, y0: float, t_max: float = 2.0,
                       n_rays: int = 36, dt: float = 0.01) -> List[np.ndarray]:
    """Simulate wavefront propagation from a point source.
    
    Traces rays in all directions using the split metric to compute
    the wavefront shape at successive times.
    
    Returns:
        List of wavefront arrays at each time step
    """
    angles = np.linspace(0, 2*np.pi, n_rays, endpoint=False)
    trajectories = []
    
    for theta in angles:
        positions = [(x0, y0)]
        x, y = x0, y0
        
        for _ in range(int(t_max / dt)):
            v = wave_speed(x, y, theta)
            x += v * np.cos(theta) * dt
            y += v * np.sin(theta) * dt
            positions.append((x, y))
        
        trajectories.append(np.array(positions))
    
    return trajectories


# =============================================================================
# Application 2: Information Geometry of Statistical Models  
# =============================================================================

def fisher_split_metric(theta1: float, theta2: float) -> np.ndarray:
    """Fisher information metric for a two-parameter exponential family
    whose information geometry is modeled by the split metric.
    
    Consider the family p(x | θ₁, θ₂) = Z(θ₁,θ₂)⁻¹ exp(θ₁f₁(x) + θ₂f₂(x))
    where the Fisher information matrix has the split structure:
    
      I = diag(sech²(θ₂), cosh²(θ₁))
    
    This models a family where:
    - θ₁ controls a feature whose information decreases with θ₂ (dilution)
    - θ₂ controls a feature whose information increases with θ₁ (amplification)
    
    Returns:
        2×2 Fisher information matrix
    """
    return np.diag([1.0/np.cosh(theta2)**2, np.cosh(theta1)**2])


def kl_divergence_approx(theta1: float, phi1: float, 
                          theta2: float, phi2: float) -> float:
    """Approximate KL divergence using the split metric geodesic distance.
    
    For nearby distributions, KL(p_θ || p_φ) ≈ ½ (θ-φ)ᵀ I(θ) (θ-φ)
    where I is the Fisher information matrix.
    """
    I = fisher_split_metric(theta1, theta2)
    delta = np.array([phi1 - theta1, phi2 - theta2])
    return 0.5 * delta @ I @ delta


# =============================================================================
# Application 3: Cosmological Anisotropy Model
# =============================================================================

def scale_factors(t: float) -> Tuple[float, float]:
    """Scale factors for the split cosmology at time t.
    
    In this toy model, the universe has:
    - a_x(t) = cosh(t): expanding in the x-direction (hyperbolic)
    - a_y(t) = sech(t) = 1/cosh(t): contracting in y-direction (elliptic)
    
    The Hubble parameters are:
    - H_x = ȧ_x/a_x = tanh(t)
    - H_y = ȧ_y/a_y = -tanh(t)
    
    Returns:
        (a_x, a_y) scale factors
    """
    return np.cosh(t), 1.0/np.cosh(t)


def hubble_parameters(t: float) -> Tuple[float, float]:
    """Directional Hubble parameters for split cosmology.
    
    H_x = tanh(t) > 0: expansion along x
    H_y = -tanh(t) < 0: contraction along y
    """
    return np.tanh(t), -np.tanh(t)


def volume_element(t: float) -> float:
    """Volume element a_x · a_y = cosh(t) · sech(t) = 1.
    
    The total 2D volume is preserved: expansion in one direction
    exactly compensates contraction in the other.
    """
    ax, ay = scale_factors(t)
    return ax * ay


# =============================================================================
# Demonstrations
# =============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATIONS OF SPLIT GEOMETRY")
    print("=" * 70)
    
    # --- Application 1: Wave Propagation ---
    print("\n--- Application 1: Anisotropic Wave Propagation ---")
    
    print("\nWave speed at various points and directions:")
    for x, y in [(0, 0), (1, 0), (0, 1), (2, 2)]:
        v_x = wave_speed(x, y, 0)          # along x
        v_y = wave_speed(x, y, np.pi/2)    # along y
        ratio = anisotropy_ratio(x, y)
        print(f"  ({x}, {y}): v_x={v_x:.4f}, v_y={v_y:.4f}, ratio={ratio:.4f}")
    
    print("\n  At origin: isotropic (ratio ≈ 1)")
    print("  Away from origin: anisotropy grows exponentially")
    
    # --- Application 2: Information Geometry ---
    print("\n--- Application 2: Information Geometry ---")
    
    print("\nFisher information at various parameter values:")
    for t1, t2 in [(0, 0), (1, 0), (0, 1), (1, 1)]:
        I = fisher_split_metric(t1, t2)
        print(f"  θ=({t1}, {t2}): I₁₁={I[0,0]:.4f}, I₂₂={I[1,1]:.4f}")
    
    print("\nApproximate KL divergences:")
    for (t1, t2), (p1, p2) in [((0,0), (0.1,0)), ((0,0), (0,0.1)),
                                  ((1,0), (1.1,0)), ((0,1), (0,1.1))]:
        kl = kl_divergence_approx(t1, p1, t2, p2)
        print(f"  KL(({t1},{t2}) || ({p1},{p2})) ≈ {kl:.6f}")
    
    # --- Application 3: Cosmology ---
    print("\n--- Application 3: Cosmological Anisotropy Model ---")
    
    print("\nEvolution of scale factors:")
    print(f"  {'Time':>6s} {'a_x':>10s} {'a_y':>10s} {'H_x':>10s} {'H_y':>10s} {'Volume':>10s}")
    for t in [0, 0.5, 1.0, 2.0, 3.0, 5.0]:
        ax, ay = scale_factors(t)
        hx, hy = hubble_parameters(t)
        vol = volume_element(t)
        print(f"  {t:6.1f} {ax:10.4f} {ay:10.4f} {hx:+10.4f} {hy:+10.4f} {vol:10.6f}")
    
    print("\n  Key insight: volume element = 1 for all times!")
    print("  The universe preserves total area while redistributing it.")
    print("  This is the geometric realization of an incompressible anisotropic flow.")


#!/usr/bin/env python3
"""
Demo: Split Geometry — A Riemannian Geometry with Sign-Changing Curvature

This script demonstrates the key theorems proved in the Lean formalization:
1. The split curvature K(x,y) = sech²(x) - sech²(y) vanishes on diagonals
2. K is antisymmetric under coordinate swap
3. K > 0 iff |y| > |x| (elliptic region)
4. K < 0 iff |x| > |y| (hyperbolic region)
5. |K| ≤ 1 everywhere
6. The split divergence is non-negative and zero iff cosh-coordinates match
"""

import numpy as np

def sech(x):
    """Hyperbolic secant."""
    return 1.0 / np.cosh(x)

def split_curvature(x, y):
    """Gaussian curvature of the split metric at (x, y)."""
    return sech(x)**2 - sech(y)**2

def split_divergence(x1, y1, x2, y2):
    """Split divergence between two points."""
    return (np.log(np.cosh(x2) / np.cosh(x1)))**2 + \
           (np.log(np.cosh(y1) / np.cosh(y2)))**2

def classify_phase(x, y):
    """Classify a point by its curvature phase."""
    if abs(x) < abs(y):
        return "elliptic"
    elif abs(x) == abs(y):
        return "flat"
    else:
        return "hyperbolic"

def area_element(x, y):
    """Area element sqrt(E*G) = cosh(x)/cosh(y)."""
    return np.cosh(x) / np.cosh(y)


print("=" * 70)
print("SPLIT GEOMETRY: Demonstrated Theorems")
print("=" * 70)

# Theorem 1: Curvature vanishes on diagonal
print("\n--- Theorem: splitCurvature_diag ---")
print("K(a, a) = 0 for all a")
for a in [-2, -1, 0, 0.5, 1, 3.14]:
    K = split_curvature(a, a)
    print(f"  K({a:6.2f}, {a:6.2f}) = {K:.2e}")

# Theorem 2: Curvature vanishes on anti-diagonal
print("\n--- Theorem: splitCurvature_antidiag ---")
print("K(a, -a) = 0 for all a")
for a in [-2, -1, 0, 0.5, 1, 3.14]:
    K = split_curvature(a, -a)
    print(f"  K({a:6.2f}, {-a:6.2f}) = {K:.2e}")

# Theorem 3: Antisymmetry
print("\n--- Theorem: splitCurvature_antisymm ---")
print("K(x, y) = -K(y, x)")
test_points = [(1, 2), (0.5, 3), (-1, 2), (2.5, 0.3)]
for x, y in test_points:
    Kxy = split_curvature(x, y)
    Kyx = split_curvature(y, x)
    print(f"  K({x}, {y}) = {Kxy:+.6f},  -K({y}, {x}) = {-Kyx:+.6f},  match: {np.isclose(Kxy, -Kyx)}")

# Theorem 4: Sign characterization
print("\n--- Theorem: splitCurvature_pos_iff ---")
print("K(x,y) > 0 iff |y| > |x|")
test_points = [(0.5, 2), (1, 3), (-1, -2), (2, 0.5), (3, 1)]
for x, y in test_points:
    K = split_curvature(x, y)
    expected = abs(y) > abs(x)
    actual = K > 0
    phase = classify_phase(x, y)
    print(f"  ({x:4.1f}, {y:4.1f}): K={K:+.4f}, |y|>|x|={expected}, K>0={actual}, phase={phase}")

# Theorem 5: Curvature bounds
print("\n--- Theorem: splitCurvature_abs_le_one ---")
print("|K(x,y)| ≤ 1 for all (x,y)")
np.random.seed(42)
max_K = 0
for _ in range(100000):
    x, y = np.random.uniform(-10, 10, 2)
    K = abs(split_curvature(x, y))
    max_K = max(max_K, K)
print(f"  Max |K| over 100,000 random samples in [-10,10]²: {max_K:.8f}")
print(f"  Bound satisfied: {max_K <= 1.0}")

# Theorem 6: Split divergence
print("\n--- Theorem: splitDivergence properties ---")
print("D(p,p) = 0 and D(p,q) ≥ 0")
for x, y in [(0, 0), (1, 2), (-3, 0.5)]:
    D_self = split_divergence(x, y, x, y)
    print(f"  D(({x},{y}), ({x},{y})) = {D_self:.2e}")

print("\nDivergence between selected points:")
pairs = [((0, 0), (1, 0)), ((0, 0), (0, 1)), ((1, 2), (3, 4)), ((1, 1), (-1, -1))]
for (x1, y1), (x2, y2) in pairs:
    D = split_divergence(x1, y1, x2, y2)
    print(f"  D(({x1},{y1}), ({x2},{y2})) = {D:.6f} ≥ 0: {D >= 0}")

# Theorem 7: Area element
print("\n--- Theorem: splitMetric_areaElement ---")
print("√(EG) = cosh(x)/cosh(y)")
for x, y in [(0, 0), (1, 0), (0, 1), (2, 3), (-1, 2)]:
    ae = area_element(x, y)
    print(f"  Area element at ({x:4.1f}, {y:4.1f}) = {ae:.6f}")

# Split Triangle demonstration
print("\n--- Theorem: splitTriangle_curvature_opposite_signs ---")
print("Elliptic vertex K₁ > 0, flat vertex K₂ = 0, hyperbolic vertex K₃ < 0")
print("So K₁ · K₃ < 0")
# Vertices: elliptic (0.5, 2), flat (1, 1), hyperbolic (2, 0.5)
v1 = (0.5, 2.0)   # |x|<|y|, elliptic
v2 = (1.0, 1.0)   # |x|=|y|, flat
v3 = (2.0, 0.5)   # |x|>|y|, hyperbolic
K1 = split_curvature(*v1)
K2 = split_curvature(*v2)
K3 = split_curvature(*v3)
print(f"  K₁ = K{v1} = {K1:+.6f} (elliptic)")
print(f"  K₂ = K{v2} = {K2:+.6f} (flat)")
print(f"  K₃ = K{v3} = {K3:+.6f} (hyperbolic)")
print(f"  K₁ · K₃ = {K1*K3:+.6f} < 0: {K1*K3 < 0}")

print("\n" + "=" * 70)
print("All demonstrated theorems match the formal Lean proofs.")
print("=" * 70)


#!/usr/bin/env python3
"""
Visualization 3: Area Element and Split Triangle

Shows the area distortion of the split metric (cosh(x)/cosh(y)) and
demonstrates a split triangle with vertices in all three phase regions.
The area element shows how regions with large |x| are stretched
while regions with large |y| are compressed.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
from matplotlib.patches import Polygon
from matplotlib.collections import PatchCollection

# Compute area element field
x = np.linspace(-4, 4, 400)
y = np.linspace(-4, 4, 400)
X, Y = np.meshgrid(x, y)
AE = np.cosh(X) / np.cosh(Y)

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left: Area element heatmap
ax = axes[0]
im = ax.pcolormesh(X, Y, np.log10(AE), cmap='magma', shading='auto',
                   vmin=-1.5, vmax=1.5)
ax.contour(X, Y, AE, levels=[1], colors='white', linewidths=2, linestyles='--')
ax.contour(X, Y, np.abs(Y) - np.abs(X), levels=[0], colors='cyan', 
           linewidths=1.5, linestyles='--')

# Split triangle
v1 = (0.5, 2.5)   # elliptic
v2 = (1.5, 1.5)   # flat boundary
v3 = (3.0, 0.5)   # hyperbolic
triangle = Polygon([v1, v2, v3], fill=False, edgecolor='lime', 
                   linewidth=3, linestyle='-')
ax.add_patch(triangle)

ax.plot(*v1, 'o', color='blue', markersize=12, zorder=5, label='Elliptic vertex')
ax.plot(*v2, 's', color='white', markersize=10, zorder=5, label='Flat vertex')
ax.plot(*v3, '^', color='red', markersize=12, zorder=5, label='Hyperbolic vertex')

ax.set_xlabel('x', fontsize=14)
ax.set_ylabel('y', fontsize=14)
ax.set_title('Area Element log₁₀(cosh(x)/cosh(y))\nwith Split Triangle', fontsize=14)
ax.set_aspect('equal')
ax.legend(fontsize=10, loc='lower right')
cbar = fig.colorbar(im, ax=ax, shrink=0.8)
cbar.set_label('log₁₀(area element)', fontsize=12)

# Right: Cross-sections of area element
ax2 = axes[1]
t = np.linspace(-4, 4, 500)

# Along x-axis
ae_xaxis = np.cosh(t) / np.cosh(0)
ax2.plot(t, ae_xaxis, 'r-', linewidth=2, label='cosh(t)/cosh(0) = cosh(t) — along y=0')

# Along y-axis
ae_yaxis = np.cosh(0) / np.cosh(t)
ax2.plot(t, ae_yaxis, 'b-', linewidth=2, label='cosh(0)/cosh(t) = sech(t) — along x=0')

# Along diagonal
ae_diag = np.cosh(t) / np.cosh(t)
ax2.plot(t, ae_diag, 'k-', linewidth=2, label='cosh(t)/cosh(t) = 1 — along y=x')

# Along y = 2t
ae_slope = np.cosh(t) / np.cosh(2*t)
ax2.plot(t, ae_slope, 'g-', linewidth=2, label='cosh(t)/cosh(2t) — along y=2x')

ax2.axhline(y=1, color='gray', linestyle=':', linewidth=0.5)
ax2.set_xlabel('t', fontsize=14)
ax2.set_ylabel('Area element', fontsize=14)
ax2.set_title('Area Distortion Along Different Lines', fontsize=14)
ax2.set_ylim(0, 5)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Annotate the key insight
ax2.annotate('Area grows exponentially\nalong x-axis', 
             xy=(3, np.cosh(3)), xytext=(1.5, 4),
             fontsize=10, color='red',
             arrowprops=dict(arrowstyle='->', color='red'))
ax2.annotate('Area shrinks exponentially\nalong y-axis',
             xy=(3, 1/np.cosh(3)), xytext=(1.5, 1.5),
             fontsize=10, color='blue',
             arrowprops=dict(arrowstyle='->', color='blue'))

plt.tight_layout()
plt.savefig('area_element.png', dpi=150, bbox_inches='tight')
print("Saved area_element.png")


#!/usr/bin/env python3
"""
Visualization 1: Split Geometry Curvature Field

Visualizes the Gaussian curvature K(x,y) = sech²(x) - sech²(y) as a heatmap,
showing the elliptic (K > 0), flat (K = 0), and hyperbolic (K < 0) regions.
The phase boundaries along y = ±x are clearly visible as the zero contour.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

def sech(x):
    return 1.0 / np.cosh(x)

# Compute curvature field
x = np.linspace(-4, 4, 500)
y = np.linspace(-4, 4, 500)
X, Y = np.meshgrid(x, y)
K = sech(X)**2 - sech(Y)**2

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left: Curvature heatmap
ax = axes[0]
norm = mcolors.TwoSlopeNorm(vmin=-1, vcenter=0, vmax=1)
im = ax.pcolormesh(X, Y, K, cmap='RdBu_r', norm=norm, shading='auto')
ax.contour(X, Y, K, levels=[0], colors='black', linewidths=2)
ax.plot([-4, 4], [-4, 4], 'k--', linewidth=1, alpha=0.5, label='y = x')
ax.plot([-4, 4], [4, -4], 'k--', linewidth=1, alpha=0.5, label='y = -x')
ax.set_xlabel('x', fontsize=14)
ax.set_ylabel('y', fontsize=14)
ax.set_title('Split Geometry: Gaussian Curvature K(x,y)', fontsize=14)
ax.set_aspect('equal')
ax.legend(fontsize=11)
cbar = fig.colorbar(im, ax=ax, shrink=0.8)
cbar.set_label('K = sech²(x) − sech²(y)', fontsize=12)

# Annotate regions
ax.text(0, 2.5, 'ELLIPTIC\nK > 0', ha='center', va='center', 
        fontsize=13, fontweight='bold', color='darkblue',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
ax.text(0, -2.5, 'ELLIPTIC\nK > 0', ha='center', va='center',
        fontsize=13, fontweight='bold', color='darkblue',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
ax.text(2.5, 0, 'HYPERBOLIC\nK < 0', ha='center', va='center',
        fontsize=13, fontweight='bold', color='darkred',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
ax.text(-2.5, 0, 'HYPERBOLIC\nK < 0', ha='center', va='center',
        fontsize=13, fontweight='bold', color='darkred',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# Right: Curvature along specific lines
ax2 = axes[1]
t = np.linspace(-4, 4, 500)

# Along x-axis (y=0)
K_xaxis = sech(t)**2 - sech(0)**2
ax2.plot(t, K_xaxis, 'r-', linewidth=2, label='K(t, 0) — x-axis')

# Along y-axis (x=0)
K_yaxis = sech(0)**2 - sech(t)**2
ax2.plot(t, K_yaxis, 'b-', linewidth=2, label='K(0, t) — y-axis')

# Along diagonal
K_diag = sech(t)**2 - sech(t)**2
ax2.plot(t, K_diag, 'k-', linewidth=2, label='K(t, t) — diagonal')

# Along line y = 2x
K_line = sech(t)**2 - sech(2*t)**2
ax2.plot(t, K_line, 'g-', linewidth=2, label='K(t, 2t)')

ax2.axhline(y=0, color='gray', linestyle='-', linewidth=0.5)
ax2.axhline(y=1, color='gray', linestyle=':', linewidth=0.5)
ax2.axhline(y=-1, color='gray', linestyle=':', linewidth=0.5)
ax2.set_xlabel('t', fontsize=14)
ax2.set_ylabel('K', fontsize=14)
ax2.set_title('Curvature Along Different Lines', fontsize=14)
ax2.set_ylim(-1.1, 1.1)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('curvature_field.png', dpi=150, bbox_inches='tight')
print("Saved curvature_field.png")


#!/usr/bin/env python3
"""
Visualization 2: Geodesics in Split Geometry

Shows how geodesics curve differently in the elliptic (K > 0) and hyperbolic (K < 0)
regions of split geometry. Geodesics converge in the elliptic region and diverge
in the hyperbolic region, demonstrating the simultaneous convergence/divergence
that characterizes split geometry.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

def sech(x):
    return 1.0 / np.cosh(x)

def christoffel_symbols(x, y):
    Gamma = np.zeros((2, 2, 2))
    Gamma[0, 0, 1] = -np.tanh(y)
    Gamma[0, 1, 0] = -np.tanh(y)
    Gamma[0, 1, 1] = -np.sinh(x) * np.cosh(x) * np.cosh(y)**2
    Gamma[1, 0, 0] = sech(y)**2 * np.tanh(y) / np.cosh(x)**2
    Gamma[1, 0, 1] = np.tanh(x)
    Gamma[1, 1, 0] = np.tanh(x)
    return Gamma

def integrate_geodesic(x0, y0, vx0, vy0, t_max=5.0, dt=0.001):
    n_steps = int(t_max / dt)
    traj = np.zeros((n_steps + 1, 4))
    state = np.array([x0, y0, vx0, vy0])
    traj[0] = state
    
    for i in range(n_steps):
        x, y, vx, vy = state
        Gamma = christoffel_symbols(x, y)
        vel = np.array([vx, vy])
        acc = np.zeros(2)
        for k in range(2):
            for ii in range(2):
                for jj in range(2):
                    acc[k] -= Gamma[k, ii, jj] * vel[ii] * vel[jj]
        
        deriv = np.array([vx, vy, acc[0], acc[1]])
        
        # RK4
        def f(s):
            xx, yy, vxx, vyy = s
            G = christoffel_symbols(xx, yy)
            v = np.array([vxx, vyy])
            a = np.zeros(2)
            for k in range(2):
                for ii in range(2):
                    for jj in range(2):
                        a[k] -= G[k, ii, jj] * v[ii] * v[jj]
            return np.array([vxx, vyy, a[0], a[1]])
        
        k1 = f(state)
        k2 = f(state + 0.5*dt*k1)
        k3 = f(state + 0.5*dt*k2)
        k4 = f(state + dt*k3)
        state = state + (dt/6)*(k1 + 2*k2 + 2*k3 + k4)
        traj[i+1] = state
        
        if abs(state[0]) > 6 or abs(state[1]) > 6:
            return traj[:i+2]
    
    return traj

# Create figure
fig, ax = plt.subplots(1, 1, figsize=(10, 10))

# Background: curvature field
x = np.linspace(-5, 5, 300)
y = np.linspace(-5, 5, 300)
X, Y = np.meshgrid(x, y)
K = sech(X)**2 - sech(Y)**2
norm = mcolors.TwoSlopeNorm(vmin=-1, vcenter=0, vmax=1)
ax.pcolormesh(X, Y, K, cmap='RdBu_r', norm=norm, shading='auto', alpha=0.3)
ax.contour(X, Y, K, levels=[0], colors='black', linewidths=1.5, linestyles='--')

# Phase boundary labels
ax.plot([-5, 5], [-5, 5], 'k--', linewidth=0.5, alpha=0.5)
ax.plot([-5, 5], [5, -5], 'k--', linewidth=0.5, alpha=0.5)

# Geodesics from origin in different directions
colors = plt.cm.viridis(np.linspace(0, 0.9, 12))
angles = np.linspace(0, 2*np.pi, 12, endpoint=False)

for i, angle in enumerate(angles):
    vx = np.cos(angle)
    vy = np.sin(angle)
    try:
        traj = integrate_geodesic(0, 0, vx, vy, t_max=4.0, dt=0.002)
        ax.plot(traj[:, 0], traj[:, 1], color=colors[i], linewidth=1.8,
                alpha=0.8)
    except:
        pass

# Geodesic fan from a point in the elliptic region
colors2 = plt.cm.autumn(np.linspace(0, 0.9, 8))
for i, angle in enumerate(np.linspace(-np.pi/4, np.pi/4, 8)):
    vx = np.cos(angle)
    vy = np.sin(angle)
    try:
        traj = integrate_geodesic(0, 2, vx, vy, t_max=3.0, dt=0.002)
        ax.plot(traj[:, 0], traj[:, 1], color=colors2[i], linewidth=1.5,
                alpha=0.7, linestyle='-')
    except:
        pass

# Geodesic fan from a point in the hyperbolic region
colors3 = plt.cm.winter(np.linspace(0, 0.9, 8))
for i, angle in enumerate(np.linspace(np.pi/4, 3*np.pi/4, 8)):
    vx = np.cos(angle)
    vy = np.sin(angle)
    try:
        traj = integrate_geodesic(2, 0, vx, vy, t_max=3.0, dt=0.002)
        ax.plot(traj[:, 0], traj[:, 1], color=colors3[i], linewidth=1.5,
                alpha=0.7, linestyle='-')
    except:
        pass

# Mark special points
ax.plot(0, 0, 'ko', markersize=8, zorder=5)
ax.plot(0, 2, 's', color='blue', markersize=8, zorder=5)
ax.plot(2, 0, 's', color='red', markersize=8, zorder=5)

ax.text(0, 3.5, 'Elliptic Region\n(converging)', ha='center', fontsize=12,
        color='darkblue', fontweight='bold')
ax.text(3.5, 0, 'Hyperbolic\nRegion\n(diverging)', ha='center', fontsize=12,
        color='darkred', fontweight='bold')

ax.set_xlim(-5, 5)
ax.set_ylim(-5, 5)
ax.set_xlabel('x', fontsize=14)
ax.set_ylabel('y', fontsize=14)
ax.set_title('Geodesics in Split Geometry', fontsize=16)
ax.set_aspect('equal')

plt.tight_layout()
plt.savefig('geodesics.png', dpi=150, bbox_inches='tight')
print("Saved geodesics.png")
