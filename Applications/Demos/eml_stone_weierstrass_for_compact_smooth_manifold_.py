#!/usr/bin/env python3
"""
Practical applications of the retract approximation theorem.

Demonstrates three concrete use cases:
1. Learning sphere-valued functions (unit normal prediction)
2. Rotation matrix approximation via SVD retraction
3. Phase-angle prediction on S¹ with guaranteed constraint satisfaction
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ============================================================
# Application 1: Unit Normal Field Approximation
# ============================================================
print("=" * 60)
print("Application 1: Unit Normal Field on a Surface")
print("=" * 60)

# Simulate a unit normal field on a torus-like surface
# Domain: angles (θ, φ) ∈ [0, 2π]²
# Target: unit normal n(θ,φ) ∈ S² ⊂ ℝ³

def torus_normal(theta, phi, R=2.0, r=0.5):
    """Outward unit normal to a torus at parametric coordinates (θ, φ)."""
    nx = np.cos(phi) * np.cos(theta)
    ny = np.cos(phi) * np.sin(theta)
    nz = np.sin(phi)
    return np.column_stack([nx, ny, nz])

def sphere_retract(pts):
    """r(x) = x/‖x‖ — retraction to S²."""
    norms = np.linalg.norm(pts, axis=1, keepdims=True)
    norms = np.maximum(norms, 1e-12)
    return pts / norms

# Generate training data
np.random.seed(42)
n_train = 200
theta_train = np.random.uniform(0, 2*np.pi, n_train)
phi_train = np.random.uniform(0, 2*np.pi, n_train)
normals_train = torus_normal(theta_train, phi_train)

# "Neural network" approximation: polynomial in (θ,φ) features
# Build feature matrix: products of sin/cos up to degree k
def fourier_features(theta, phi, max_freq=4):
    features = [np.ones(len(theta))]
    for k in range(1, max_freq+1):
        features.extend([
            np.cos(k*theta), np.sin(k*theta),
            np.cos(k*phi), np.sin(k*phi),
            np.cos(k*theta)*np.cos(k*phi),
            np.sin(k*theta)*np.sin(k*phi),
        ])
    return np.column_stack(features)

# Test on a grid
n_test = 50
theta_test = np.linspace(0, 2*np.pi, n_test)
phi_test = np.linspace(0, 2*np.pi, n_test)
TH, PH = np.meshgrid(theta_test, phi_test)
theta_flat = TH.ravel()
phi_flat = PH.ravel()
normals_true = torus_normal(theta_flat, phi_flat)

errors_by_freq = {}
for max_freq in [1, 2, 4, 8]:
    X_train = fourier_features(theta_train, phi_train, max_freq)
    X_test = fourier_features(theta_flat, phi_flat, max_freq)

    # Least squares fit (Euclidean approximation)
    coeffs, _, _, _ = np.linalg.lstsq(X_train, normals_train, rcond=None)
    approx_euclidean = X_test @ coeffs

    # Retract to sphere
    approx_sphere = sphere_retract(approx_euclidean)

    # Errors
    err_euclid = np.linalg.norm(approx_euclidean - normals_true, axis=1)
    err_sphere = np.linalg.norm(approx_sphere - normals_true, axis=1)

    # Check constraint: are Euclidean outputs on the sphere?
    norms_euclid = np.linalg.norm(approx_euclidean, axis=1)
    constraint_violation = np.abs(norms_euclid - 1.0)

    errors_by_freq[max_freq] = {
        'euclid_max': err_euclid.max(),
        'sphere_max': err_sphere.max(),
        'constraint_max': constraint_violation.max(),
        'constraint_mean': constraint_violation.mean(),
    }

    print(f"  Fourier freq {max_freq}: "
          f"Euclid err={err_euclid.max():.4f}, "
          f"Sphere err={err_sphere.max():.4f}, "
          f"Constraint violation={constraint_violation.max():.4f}")

# Plot
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

freqs = sorted(errors_by_freq.keys())
ax = axes[0]
ax.semilogy(freqs, [errors_by_freq[f]['euclid_max'] for f in freqs], 'ro-',
            label='Euclidean max error')
ax.semilogy(freqs, [errors_by_freq[f]['sphere_max'] for f in freqs], 'gs-',
            label='Retracted (sphere) max error')
ax.set_xlabel('Max Fourier frequency')
ax.set_ylabel('Max error')
ax.set_title('Normal Field Approximation Error')
ax.legend()
ax.grid(True, alpha=0.3)

ax = axes[1]
ax.semilogy(freqs, [errors_by_freq[f]['constraint_max'] for f in freqs], 'b^-',
            label='Max ‖output‖−1 (Euclidean)')
ax.axhline(y=0, color='g', linestyle='--', label='Retracted: always 0')
ax.set_xlabel('Max Fourier frequency')
ax.set_ylabel('Constraint violation |‖output‖ - 1|')
ax.set_title('Unit-length Constraint Satisfaction')
ax.legend()
ax.grid(True, alpha=0.3)

plt.suptitle('Application: Unit Normal Field Approximation on S²', fontweight='bold')
plt.tight_layout()
plt.savefig('demos/app_normal_field.png', dpi=150, bbox_inches='tight')
plt.close()
print("  Saved demos/app_normal_field.png\n")

# ============================================================
# Application 2: Rotation Matrix Approximation (SO(3))
# ============================================================
print("=" * 60)
print("Application 2: Rotation Matrix Prediction via SVD Retraction")
print("=" * 60)

def random_rotation():
    """Generate a random rotation matrix via QR decomposition."""
    M = np.random.randn(3, 3)
    Q, R = np.linalg.qr(M)
    Q = Q @ np.diag(np.sign(np.diag(R)))
    if np.linalg.det(Q) < 0:
        Q[:, 0] *= -1
    return Q

def svd_retract(M):
    """Retract a 3x3 matrix to SO(3) via SVD: r(M) = U @ V^T with det correction."""
    U, _, Vt = np.linalg.svd(M)
    R = U @ Vt
    if np.linalg.det(R) < 0:
        U[:, -1] *= -1
        R = U @ Vt
    return R

# Simulate: predict rotation as function of a scalar parameter t
np.random.seed(123)
def rotation_trajectory(t):
    """Smooth rotation trajectory: rotation about z-axis by t, with tilt."""
    c, s = np.cos(t), np.sin(t)
    c2, s2 = np.cos(0.3*t), np.sin(0.3*t)
    Rz = np.array([[c, -s, 0], [s, c, 0], [0, 0, 1]])
    Rx = np.array([[1, 0, 0], [0, c2, -s2], [0, s2, c2]])
    return Rz @ Rx

t_vals = np.linspace(0, 4*np.pi, 100)
true_rots = np.array([rotation_trajectory(t) for t in t_vals])  # shape (100, 3, 3)

# Polynomial approximation of each matrix entry
errors_poly = []
errors_retract = []
for deg in [3, 5, 8, 12, 18]:
    approx_mats = np.zeros_like(true_rots)
    for i in range(3):
        for j in range(3):
            coeffs = np.polyfit(t_vals, true_rots[:, i, j], deg)
            approx_mats[:, i, j] = np.polyval(coeffs, t_vals)

    # Retract each matrix to SO(3)
    retracted_mats = np.array([svd_retract(M) for M in approx_mats])

    # Errors (Frobenius norm)
    err_poly = np.array([np.linalg.norm(approx_mats[k] - true_rots[k]) for k in range(len(t_vals))])
    err_retract = np.array([np.linalg.norm(retracted_mats[k] - true_rots[k]) for k in range(len(t_vals))])

    # Orthogonality violation of polynomial output
    ortho_err = np.array([np.linalg.norm(approx_mats[k].T @ approx_mats[k] - np.eye(3))
                          for k in range(len(t_vals))])

    errors_poly.append(err_poly.max())
    errors_retract.append(err_retract.max())

    print(f"  Degree {deg:2d}: poly err={err_poly.max():.4f}, "
          f"retract err={err_retract.max():.4f}, "
          f"ortho violation={ortho_err.max():.4f}")

fig, ax = plt.subplots(figsize=(10, 6))
degs = [3, 5, 8, 12, 18]
ax.semilogy(degs, errors_poly, 'ro-', markersize=6, label='Polynomial (in ℝ³ˣ³)')
ax.semilogy(degs, errors_retract, 'gs-', markersize=6, label='SVD-retracted (on SO(3))')
ax.set_xlabel('Polynomial degree', fontsize=12)
ax.set_ylabel('Max Frobenius error', fontsize=12)
ax.set_title('Rotation Trajectory Approximation: Polynomial vs. SVD Retraction', fontsize=13)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
plt.savefig('demos/app_rotation_approx.png', dpi=150, bbox_inches='tight')
plt.close()
print("  Saved demos/app_rotation_approx.png\n")

# ============================================================
# Application 3: Phase Angle Prediction on S¹
# ============================================================
print("=" * 60)
print("Application 3: Phase Angle Prediction on S¹")
print("=" * 60)

def phase_signal(t):
    """A phase signal: angle as a function of time, mapped to S¹."""
    angle = 2 * np.sin(3*t) + np.cos(5*t) + 0.5 * np.sin(7*t)
    return np.column_stack([np.cos(angle), np.sin(angle)])

t = np.linspace(0, 2*np.pi, 300)
target = phase_signal(t)

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

for idx, deg in enumerate([4, 8, 15]):
    approx = np.zeros_like(target)
    for col in range(2):
        coeffs = np.polyfit(t, target[:, col], deg)
        approx[:, col] = np.polyval(coeffs, t)

    retracted = approx / np.linalg.norm(approx, axis=1, keepdims=True)

    ax = axes[idx]
    circle = np.linspace(0, 2*np.pi, 200)
    ax.plot(np.cos(circle), np.sin(circle), 'k-', alpha=0.15, lw=1)
    ax.plot(target[:, 0], target[:, 1], 'b-', lw=2, alpha=0.5, label='Target f(t)')
    ax.plot(approx[:, 0], approx[:, 1], 'r--', lw=1, alpha=0.4, label=f'Poly deg {deg}')
    ax.plot(retracted[:, 0], retracted[:, 1], 'g-', lw=2, alpha=0.7, label='r ∘ poly')

    err = np.linalg.norm(retracted - target, axis=1).max()
    ax.set_title(f'Degree {deg}, max err = {err:.4f}')
    ax.set_aspect('equal')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

plt.suptitle('Phase Angle Prediction on S¹: Polynomial + Retraction',
             fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig('demos/app_phase_prediction.png', dpi=150, bbox_inches='tight')
plt.close()
print("  Saved demos/app_phase_prediction.png\n")

print("All application demonstrations complete.")


#!/usr/bin/env python3
"""
Demonstration: Approximating circle-valued and torus-valued maps via Euclidean retraction.

This script illustrates the core idea of the retract approximation theorem:
to approximate a continuous map f: [0,1] → S¹ (the unit circle), we
1. Embed S¹ ↪ ℝ² via the standard inclusion.
2. Approximate the embedded map f̃: [0,1] → ℝ² using polynomials (Stone–Weierstrass).
3. Retract the polynomial approximation back to S¹ via r(x) = x/‖x‖.
4. The retracted map is uniformly close to f on S¹.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

# ============================================================
# Setup: target map f: [0,1] → S¹
# ============================================================
def f_circle(t):
    """A continuous map [0,1] → S¹ that wraps around 1.5 times."""
    theta = 3 * np.pi * t
    return np.column_stack([np.cos(theta), np.sin(theta)])

def retract_to_circle(pts):
    """Retraction r: ℝ²\{0} → S¹, r(x) = x/‖x‖."""
    norms = np.linalg.norm(pts, axis=1, keepdims=True)
    norms = np.maximum(norms, 1e-12)
    return pts / norms

def polynomial_approx(t, degree):
    """Approximate f_circle(t) componentwise by least-squares polynomials."""
    target = f_circle(t)
    approx = np.zeros_like(target)
    for col in range(2):
        coeffs = np.polyfit(t, target[:, col], degree)
        approx[:, col] = np.polyval(coeffs, t)
    return approx

# ============================================================
# Compute approximations at various polynomial degrees
# ============================================================
t = np.linspace(0, 1, 500)
f_vals = f_circle(t)

degrees = [3, 6, 10, 20]

fig = plt.figure(figsize=(16, 12))
gs = GridSpec(2, 2, hspace=0.35, wspace=0.3)

for idx, deg in enumerate(degrees):
    ax = fig.add_subplot(gs[idx])

    poly_approx = polynomial_approx(t, deg)
    retracted = retract_to_circle(poly_approx)

    circle_theta = np.linspace(0, 2*np.pi, 200)
    ax.plot(np.cos(circle_theta), np.sin(circle_theta), 'k-', alpha=0.2, lw=1,
            label='$S^1$')
    ax.plot(f_vals[:, 0], f_vals[:, 1], 'b-', lw=2, alpha=0.6, label='$f(t)$ (target)')
    ax.plot(poly_approx[:, 0], poly_approx[:, 1], 'r--', lw=1, alpha=0.5,
            label=f'Poly deg {deg} (in $\\mathbb{{R}}^2$)')
    ax.plot(retracted[:, 0], retracted[:, 1], 'g-', lw=2, alpha=0.8,
            label=f'$r \\circ$ poly (on $S^1$)')

    euclidean_err = np.linalg.norm(poly_approx - f_vals, axis=1)
    retracted_err = np.linalg.norm(retracted - f_vals, axis=1)

    ax.set_title(f'Degree {deg}:  max‖poly−f‖={euclidean_err.max():.4f},  '
                 f'max‖r∘poly−f‖={retracted_err.max():.4f}', fontsize=10)
    ax.set_aspect('equal')
    ax.legend(fontsize=7, loc='lower left')
    ax.set_xlim(-1.6, 1.6)
    ax.set_ylim(-1.6, 1.6)
    ax.grid(True, alpha=0.3)

fig.suptitle('Retract Approximation: Polynomials → S¹ via r(x)=x/‖x‖',
             fontsize=14, fontweight='bold')
plt.savefig('demos/retract_circle_approx.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved demos/retract_circle_approx.png")

# ============================================================
# Error convergence plot
# ============================================================
degrees_range = range(2, 30)
max_euclid_errors = []
max_retract_errors = []

for deg in degrees_range:
    poly_approx = polynomial_approx(t, deg)
    retracted = retract_to_circle(poly_approx)
    max_euclid_errors.append(np.linalg.norm(poly_approx - f_vals, axis=1).max())
    max_retract_errors.append(np.linalg.norm(retracted - f_vals, axis=1).max())

fig2, ax2 = plt.subplots(figsize=(10, 6))
ax2.semilogy(list(degrees_range), max_euclid_errors, 'ro-', markersize=4,
             label='‖poly − f‖∞ (Euclidean)')
ax2.semilogy(list(degrees_range), max_retract_errors, 'gs-', markersize=4,
             label='‖r∘poly − f‖∞ (on S¹)')
ax2.set_xlabel('Polynomial degree', fontsize=12)
ax2.set_ylabel('Maximum approximation error', fontsize=12)
ax2.set_title('Convergence of retract approximation on the circle', fontsize=13)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
plt.savefig('demos/retract_convergence.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved demos/retract_convergence.png")

# ============================================================
# Torus example: f: [0,1] → T² ⊂ ℝ³
# ============================================================
def torus_embedding(theta, phi, R=2, r_tube=0.7):
    """Standard embedding of T² into ℝ³."""
    x = (R + r_tube * np.cos(phi)) * np.cos(theta)
    y = (R + r_tube * np.cos(phi)) * np.sin(theta)
    z = r_tube * np.sin(phi)
    return np.column_stack([x, y, z])

def torus_retract(pts, R=2, r_tube=0.7):
    """Retraction to the torus: project to nearest point on T²."""
    x, y, z = pts[:, 0], pts[:, 1], pts[:, 2]
    r_xy = np.sqrt(x**2 + y**2)
    r_xy = np.maximum(r_xy, 1e-12)
    cos_theta = x / r_xy
    sin_theta = y / r_xy
    dx = r_xy - R
    dist_tube = np.sqrt(dx**2 + z**2)
    dist_tube = np.maximum(dist_tube, 1e-12)
    cos_phi = dx / dist_tube
    sin_phi = z / dist_tube
    x_ret = (R + r_tube * cos_phi) * cos_theta
    y_ret = (R + r_tube * cos_phi) * sin_theta
    z_ret = r_tube * sin_phi
    return np.column_stack([x_ret, y_ret, z_ret])

def f_torus(t):
    """A curve on the torus: (3,2)-torus knot."""
    theta = 6 * np.pi * t
    phi = 4 * np.pi * t
    return torus_embedding(theta, phi)

def polynomial_approx_3d(t, degree, target_fn):
    target = target_fn(t)
    approx = np.zeros_like(target)
    for col in range(3):
        coeffs = np.polyfit(t, target[:, col], degree)
        approx[:, col] = np.polyval(coeffs, t)
    return approx

fig3 = plt.figure(figsize=(16, 6))

for idx, deg in enumerate([5, 15, 30]):
    ax3 = fig3.add_subplot(1, 3, idx+1, projection='3d')

    theta_grid = np.linspace(0, 2*np.pi, 40)
    phi_grid = np.linspace(0, 2*np.pi, 20)
    TH, PH = np.meshgrid(theta_grid, phi_grid)
    torus_pts = torus_embedding(TH.ravel(), PH.ravel())
    torus_pts = torus_pts.reshape(PH.shape[0], PH.shape[1], 3)
    ax3.plot_wireframe(torus_pts[:,:,0], torus_pts[:,:,1], torus_pts[:,:,2],
                       alpha=0.1, color='gray')

    target = f_torus(t)
    ax3.plot(target[:,0], target[:,1], target[:,2], 'b-', lw=1.5, alpha=0.6,
             label='Target')

    poly = polynomial_approx_3d(t, deg, f_torus)
    retracted = torus_retract(poly)
    ax3.plot(retracted[:,0], retracted[:,1], retracted[:,2], 'g-', lw=1.5,
             alpha=0.8, label=f'Retracted (deg {deg})')

    err = np.linalg.norm(retracted - target, axis=1).max()
    ax3.set_title(f'Deg {deg}, max err = {err:.4f}', fontsize=10)
    ax3.legend(fontsize=7)

fig3.suptitle('Retract Approximation on the Torus T²', fontsize=13, fontweight='bold')
plt.savefig('demos/retract_torus_approx.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved demos/retract_torus_approx.png")

print("\nAll demonstrations complete.")
