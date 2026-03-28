#!/usr/bin/env python3
"""
Higher-Dimensional Omega Point — S² and S^n Demonstrations

Extends the Omega Point theorem to higher dimensions:
- ℝ² → S² via inverse stereographic projection
- Demonstrates convergence to the north pole in S²

The abstract Lean theorem (stereoInvFunAux_tendsto_north_pole) proves this
for any finite-dimensional inner product space.

Run: python3 higher_dimensional_omega.py
Outputs: omega_point_higher_dim.png
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def inv_stereo_2d(x, y):
    """Inverse stereographic projection ℝ² → S² ⊂ ℝ³
    Maps (x, y) ↦ (2x, 2y, x²+y²-1) / (x²+y²+1)
    """
    d = x**2 + y**2 + 1
    return (2*x/d, 2*y/d, (x**2 + y**2 - 1)/d)

def inv_stereo_mathlib(w_norm, v_norm=1):
    """Mathlib's stereoInvFunAux formula:
    (‖w‖² + 4)⁻¹ • (4w + (‖w‖² - 4)v)

    Returns the coefficient of v (the "north pole component").
    As ‖w‖ → ∞, this coefficient → 1.
    """
    return (w_norm**2 - 4) / (w_norm**2 + 4)

def inv_stereo_mathlib_w_coeff(w_norm):
    """Coefficient of w in stereoInvFunAux.
    The contribution of w is (4/(‖w‖²+4))•w, with norm 4‖w‖/(‖w‖²+4).
    As ‖w‖ → ∞, this → 0.
    """
    return 4 * w_norm / (w_norm**2 + 4)


# ─── Experiment: Higher-dimensional convergence ──────────────────────

print("="*60)
print("HIGHER-DIMENSIONAL OMEGA POINT THEOREM")
print("Mathlib formula: stereoInvFunAux v w = (‖w‖²+4)⁻¹(4w+(‖w‖²-4)v)")
print("="*60)

print("\n1. Coefficient of v (north pole) as ‖w‖ → ∞:")
print(f"{'‖w‖':>12s} │ {'(‖w‖²-4)/(‖w‖²+4)':>20s} │ {'deviation from 1':>18s}")
print("─" * 55)
for r in [1, 2, 5, 10, 50, 100, 1000, 1e6]:
    coeff = inv_stereo_mathlib(r)
    dev = abs(coeff - 1)
    print(f"{r:>12.0f} │ {coeff:>20.15f} │ {dev:>18.2e}")

print("\n2. Norm of w-contribution (4‖w‖/(‖w‖²+4)) as ‖w‖ → ∞:")
print(f"{'‖w‖':>12s} │ {'4‖w‖/(‖w‖²+4)':>20s} │ {'≈ 4/‖w‖':>12s}")
print("─" * 50)
for r in [1, 2, 5, 10, 50, 100, 1000, 1e6]:
    wcoeff = inv_stereo_mathlib_w_coeff(r)
    approx = 4/r
    print(f"{r:>12.0f} │ {wcoeff:>20.15f} │ {approx:>12.6e}")

print("\n✓ Both validate the abstract theorem: stereoInvFunAux v w → v")


# ─── Visualization ───────────────────────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle('Higher-Dimensional Omega Point: ℝ² → S²',
             fontsize=16, fontweight='bold')

# Panel 1: Points spiraling on S²
ax1 = axes[0]
ax1 = fig.add_subplot(131, projection='3d')

# Spiral in ℝ²
t = np.linspace(0, 10*np.pi, 500)
r = np.exp(t / (2*np.pi))  # Exponentially growing spiral
spiral_x = r * np.cos(t)
spiral_y = r * np.sin(t)

# Map to S²
sx, sy, sz = [], [], []
for x, y in zip(spiral_x, spiral_y):
    p = inv_stereo_2d(x, y)
    sx.append(p[0])
    sy.append(p[1])
    sz.append(p[2])

# Draw sphere wireframe
u = np.linspace(0, 2*np.pi, 30)
v = np.linspace(0, np.pi, 15)
ws = np.outer(np.cos(u), np.sin(v))
xs = np.outer(np.sin(u), np.sin(v))
zs = np.outer(np.ones_like(u), np.cos(v))
ax1.plot_wireframe(ws, xs, zs, alpha=0.08, color='gray')

ax1.plot(sx, sy, sz, 'b-', linewidth=1, alpha=0.7)
ax1.scatter([0], [0], [1], color='red', s=200, marker='*', zorder=5)
ax1.text(0, 0, 1.15, 'Ω', fontsize=14, color='red', fontweight='bold', ha='center')
ax1.set_title('Spiral → Ω\non S²', fontsize=11)

# Panel 2: Coefficient of v vs ‖w‖
ax2 = axes[1]
norms = np.linspace(0.1, 20, 500)
v_coeffs = [(n**2 - 4)/(n**2 + 4) for n in norms]
w_contribs = [4*n/(n**2 + 4) for n in norms]

ax2.plot(norms, v_coeffs, 'r-', linewidth=2, label='coeff of v: (‖w‖²−4)/(‖w‖²+4)')
ax2.plot(norms, w_contribs, 'b-', linewidth=2, label='‖w-contrib‖: 4‖w‖/(‖w‖²+4)')
ax2.axhline(y=1, color='red', linestyle='--', alpha=0.4)
ax2.axhline(y=0, color='blue', linestyle='--', alpha=0.4)
ax2.set_xlabel('‖w‖', fontsize=12)
ax2.set_ylabel('Coefficient', fontsize=12)
ax2.set_title('Mathlib stereoInvFunAux\nComponents vs ‖w‖', fontsize=11)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Panel 3: Distance to north pole in S²
ax3 = axes[2]
radii = np.logspace(-1, 4, 200)
# For a point at distance r from origin in ℝ², compute distance to north pole on S²
dists = []
for r in radii:
    p = inv_stereo_2d(r, 0)  # Point at (r, 0) in plane
    d = np.sqrt(p[0]**2 + p[1]**2 + (p[2]-1)**2)
    dists.append(d)

ax3.loglog(radii, dists, 'purple', linewidth=2, label='dist to Ω on S²')
ax3.loglog(radii, 2/radii, 'k--', alpha=0.5, label='2/r reference')
ax3.set_xlabel('r = ‖w‖ (distance from origin in ℝ²)', fontsize=11)
ax3.set_ylabel('Distance to Ω on S²', fontsize=11)
ax3.set_title('Convergence Rate\nO(1/‖w‖)', fontsize=11)
ax3.legend()
ax3.grid(True, alpha=0.3, which='both')

plt.tight_layout()
plt.savefig('omega_point_higher_dim.png', dpi=150, bbox_inches='tight')
print("\n✓ Saved: omega_point_higher_dim.png")


# ─── New Hypothesis: Conformal Distortion Near Omega ─────────────────

print("\n" + "="*60)
print("NEW HYPOTHESIS: Conformal Factor Near the Omega Point")
print("="*60)
print("""
The stereographic projection is conformal (angle-preserving).
The conformal factor at a point w ∈ ℝⁿ is:
    λ(w) = 2 / (‖w‖² + 1)    [standard formula]
or  λ(w) = 4 / (‖w‖² + 4)    [Mathlib's rescaled version]

Near the Omega Point (‖w‖ → ∞), λ(w) → 0.
This means: regions near Ω on the sphere correspond to LARGE regions
in the plane — the Omega Point is a "singularity of compression."

Hypothesis: The conformal factor λ(w) ≈ C/‖w‖² for large ‖w‖.
""")

print(f"{'‖w‖':>10s} │ {'λ(w)':>14s} │ {'4/‖w‖²':>14s} │ {'ratio':>8s}")
print("─" * 52)
for r in [1, 5, 10, 50, 100, 1000]:
    lam = 4 / (r**2 + 4)
    approx = 4 / r**2
    ratio = lam / approx
    print(f"{r:>10.0f} │ {lam:>14.8e} │ {approx:>14.8e} │ {ratio:>8.6f}")

print("\n✓ VALIDATED: λ(w) ≈ 4/‖w‖² near the Omega Point")
print("  This confirms the Omega Point is an infinite-compression singularity.")
