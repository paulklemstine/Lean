"""
Product Codomain Approximation Demo
====================================

Demonstrates the core theorem: if we can approximate continuous maps into Y and Z
separately, then we can approximate continuous maps into Y × Z by pairing the
coordinate approximants.

The key insight is that the product metric is the sup/max metric:
    dist((y₁,z₁), (y₂,z₂)) = max(dist(y₁,y₂), dist(z₁,z₂))

so coordinatewise ε-approximation immediately gives productwise ε-approximation
with NO need to split ε/2.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

# ─────────────────────────────────────────────────────────
# 1. Setup: target function and approximation classes
# ─────────────────────────────────────────────────────────

def target_y(x):
    """Target map into Y = ℝ: a smooth oscillation."""
    return np.sin(2 * np.pi * x) * np.exp(-x)

def target_z(x):
    """Target map into Z = ℝ: a different smooth function."""
    return np.cos(3 * np.pi * x) * (1 - x**2)

def target_yz(x):
    """Target map into Y × Z."""
    return np.column_stack([target_y(x), target_z(x)])


def approx_y(x, n_terms=5):
    """Polynomial approximation of target_y (truncated Taylor-like)."""
    coeffs = np.polyfit(x, target_y(x), n_terms)
    return np.polyval(coeffs, x)

def approx_z(x, n_terms=5):
    """Polynomial approximation of target_z (truncated Taylor-like)."""
    coeffs = np.polyfit(x, target_z(x), n_terms)
    return np.polyval(coeffs, x)


# ─────────────────────────────────────────────────────────
# 2. Compute approximations at various fidelities
# ─────────────────────────────────────────────────────────

x = np.linspace(-1, 1, 500)
fy = target_y(x)
fz = target_z(x)

fig = plt.figure(figsize=(16, 12))
gs = GridSpec(3, 2, figure=fig, hspace=0.35, wspace=0.3)

degrees = [3, 6, 12]
colors = ['#e74c3c', '#3498db', '#2ecc71']

# ── Panel 1: Y-coordinate approximation ──
ax1 = fig.add_subplot(gs[0, 0])
ax1.plot(x, fy, 'k-', linewidth=2, label='Target $f_Y$')
for deg, col in zip(degrees, colors):
    gy = approx_y(x, deg)
    err = np.max(np.abs(gy - fy))
    ax1.plot(x, gy, '--', color=col, linewidth=1.5,
             label=f'deg {deg} (max err = {err:.4f})')
ax1.set_title('Y-coordinate: $f_Y(x) = \\sin(2\\pi x)e^{-x}$', fontsize=12)
ax1.set_xlabel('$x$')
ax1.set_ylabel('$y$')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# ── Panel 2: Z-coordinate approximation ──
ax2 = fig.add_subplot(gs[0, 1])
ax2.plot(x, fz, 'k-', linewidth=2, label='Target $f_Z$')
for deg, col in zip(degrees, colors):
    gz = approx_z(x, deg)
    err = np.max(np.abs(gz - fz))
    ax2.plot(x, gz, '--', color=col, linewidth=1.5,
             label=f'deg {deg} (max err = {err:.4f})')
ax2.set_title('Z-coordinate: $f_Z(x) = \\cos(3\\pi x)(1-x^2)$', fontsize=12)
ax2.set_xlabel('$x$')
ax2.set_ylabel('$z$')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# ── Panel 3: Product distance = max of coordinate distances ──
ax3 = fig.add_subplot(gs[1, :])
for deg, col in zip(degrees, colors):
    gy = approx_y(x, deg)
    gz = approx_z(x, deg)
    err_y = np.abs(gy - fy)
    err_z = np.abs(gz - fz)
    err_prod = np.maximum(err_y, err_z)  # sup/max metric

    ax3.plot(x, err_y, ':', color=col, alpha=0.5, linewidth=1)
    ax3.plot(x, err_z, '--', color=col, alpha=0.5, linewidth=1)
    ax3.plot(x, err_prod, '-', color=col, linewidth=2,
             label=f'deg {deg}: max(|err_Y|, |err_Z|)')

ax3.set_title('Product distance = max of coordinate errors (sup metric)', fontsize=12)
ax3.set_xlabel('$x$')
ax3.set_ylabel('Error')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)
ax3.set_yscale('log')

# ── Panel 4: Convergence rates ──
ax4 = fig.add_subplot(gs[2, 0])
deg_range = range(2, 20)
max_errs_y = []
max_errs_z = []
max_errs_prod = []
for d in deg_range:
    gy = approx_y(x, d)
    gz = approx_z(x, d)
    ey = np.max(np.abs(gy - fy))
    ez = np.max(np.abs(gz - fz))
    max_errs_y.append(ey)
    max_errs_z.append(ez)
    max_errs_prod.append(max(ey, ez))

ax4.semilogy(list(deg_range), max_errs_y, 'o-', color='#e74c3c', label='$\\|g_Y - f_Y\\|_\\infty$')
ax4.semilogy(list(deg_range), max_errs_z, 's-', color='#3498db', label='$\\|g_Z - f_Z\\|_\\infty$')
ax4.semilogy(list(deg_range), max_errs_prod, 'D-', color='#2ecc71', linewidth=2,
             label='$\\|g_{Y\\times Z} - f\\|_\\infty$ (product)')
ax4.set_title('Convergence: product error = max of coordinate errors', fontsize=12)
ax4.set_xlabel('Polynomial degree')
ax4.set_ylabel('Sup-norm error')
ax4.legend(fontsize=9)
ax4.grid(True, alpha=0.3)

# ── Panel 5: Parametric curve in Y × Z ──
ax5 = fig.add_subplot(gs[2, 1])
ax5.plot(fy, fz, 'k-', linewidth=2, label='Target curve $(f_Y, f_Z)$')
for deg, col in zip(degrees, colors):
    gy = approx_y(x, deg)
    gz = approx_z(x, deg)
    ax5.plot(gy, gz, '--', color=col, linewidth=1.5, label=f'Paired approx deg {deg}')
ax5.set_title('Product space $Y \\times Z$: paired approximation', fontsize=12)
ax5.set_xlabel('$Y$ coordinate')
ax5.set_ylabel('$Z$ coordinate')
ax5.legend(fontsize=9)
ax5.grid(True, alpha=0.3)
ax5.set_aspect('equal')

plt.suptitle('Stone–Weierstrass for Product Codomains:\nFactorwise Approximation + Diagonal Assembly',
             fontsize=14, fontweight='bold', y=1.02)
plt.savefig('/workspace/request-project/EML/product_approximation_demo.png',
            dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved product_approximation_demo.png")


# ─────────────────────────────────────────────────────────
# 3. Numerical verification of the key theorem
# ─────────────────────────────────────────────────────────

print("\n" + "="*70)
print("NUMERICAL VERIFICATION OF PRODUCT APPROXIMATION THEOREM")
print("="*70)
print()
print("Key identity (Prod.dist_eq in Mathlib):")
print("  dist((y₁,z₁), (y₂,z₂)) = max(dist(y₁,y₂), dist(z₁,z₂))")
print()

for deg in [3, 6, 9, 12, 15]:
    gy = approx_y(x, deg)
    gz = approx_z(x, deg)
    err_y = np.max(np.abs(gy - fy))
    err_z = np.max(np.abs(gz - fz))
    err_prod = np.max(np.maximum(np.abs(gy - fy), np.abs(gz - fz)))
    check = max(err_y, err_z)
    print(f"  deg={deg:2d}: ‖gY-fY‖∞ = {err_y:.6f},  ‖gZ-fZ‖∞ = {err_z:.6f}")
    print(f"          ‖paired-f‖∞ = {err_prod:.6f}  =  max({err_y:.6f}, {err_z:.6f}) = {check:.6f}  ✓")
    assert np.isclose(err_prod, check), "Product metric identity violated!"
    print()

print("All checks passed: product error = max(coord errors) in every case.")
print()
print("="*70)
print("THEOREM (Lean 4, formally verified):")
print("="*70)
print("""
  pairClass_uniform_dense:
    If AY uniformly approximates C(X,Y) and AZ uniformly approximates C(X,Z),
    then PairClass AY AZ uniformly approximates C(X, Y×Z).

  The proof:
  1. Decompose f : C(X, Y×Z) into (f.projFst, f.projSnd)
  2. Approximate each coordinate with same tolerance ε
  3. Pair the approximants: g = prodMk gY gZ
  4. Apply dist_prod_mk_lt_of_lt: coordinatewise < ε ⟹ productwise < ε

  No ε/2 splitting needed — the sup metric is exactly designed for this!
""")


# ─────────────────────────────────────────────────────────
# 4. EML-specific demo: exp-based approximation
# ─────────────────────────────────────────────────────────

print("="*70)
print("EML APPLICATION: Exponential-multiplicative approximation of product maps")
print("="*70)

def eml_approx(x, target_fn, n_neurons=10):
    """Simple EML-style approximation using exp neurons."""
    # Use random features for demonstration
    np.random.seed(42)
    w = np.random.randn(n_neurons)
    b = np.random.randn(n_neurons)
    # Feature matrix: exp(w_i * x + b_i) for each neuron
    features = np.exp(np.outer(x, w) + b)
    # Least squares fit
    target = target_fn(x)
    coeffs, _, _, _ = np.linalg.lstsq(features, target, rcond=None)
    return features @ coeffs

fig2, axes = plt.subplots(1, 3, figsize=(15, 4))

for n_neurons, ax, color in zip([5, 15, 40], axes, ['#e74c3c', '#3498db', '#2ecc71']):
    gy = eml_approx(x, target_y, n_neurons)
    gz = eml_approx(x, target_z, n_neurons)
    err_y = np.max(np.abs(gy - fy))
    err_z = np.max(np.abs(gz - fz))
    err_prod = max(err_y, err_z)

    ax.plot(fy, fz, 'k-', linewidth=2, label='Target')
    ax.plot(gy, gz, '--', color=color, linewidth=1.5,
            label=f'EML paired ({n_neurons} neurons)')
    ax.set_title(f'{n_neurons} neurons, prod err = {err_prod:.4f}', fontsize=11)
    ax.set_xlabel('Y'); ax.set_ylabel('Z')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

plt.suptitle('EML (Exponential) Approximation of Product-Valued Maps', fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig('/workspace/request-project/EML/eml_product_demo.png', dpi=150, bbox_inches='tight')
plt.close()
print("✓ Saved eml_product_demo.png")

print("\nConclusion: The product approximation theorem upgrades codomain")
print("approximation from isolated target-specific results to a compositional")
print("calculus. Once approximation is known for basic codomains Y and Z,")
print("finite products Y×Z follow formally by pairing — no new approximation")
print("theory is needed.")
