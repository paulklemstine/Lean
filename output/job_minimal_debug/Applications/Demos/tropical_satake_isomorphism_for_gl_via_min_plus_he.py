"""
Tropical Satake Isomorphism for GL₄ — Interactive Demonstration
===============================================================

This script demonstrates the formally verified tropical Satake isomorphism
for GL₄ with concrete numerical examples and visualizations.

The main theorem states:
    𝒮(1_{KμK}^{trop})(z) = s_{λ(μ)}^{trop}(z)

where the Satake transform (geometric side) equals the tropical Schur
polynomial (spectral side).
"""

import itertools
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm
from mpl_toolkits.mplot3d import Axes3D

# ============================================================
# Core Definitions (matching the Lean formalization)
# ============================================================

def all_permutations(n):
    """Generate all permutations of {0, 1, ..., n-1}."""
    return list(itertools.permutations(range(n)))

S4 = all_permutations(4)  # All 24 elements of S₄

def tropical_schur_polynomial(nu, z):
    """
    Tropical Schur polynomial: min over S₄ of ∑ᵢ ν(σ(i)) · z(i).

    This is the tropicalization (Maslov dequantization) of the classical
    monomial symmetric polynomial / Weyl orbit sum.

    Parameters
    ----------
    nu : array-like of length 4
        Dominant coweight (weakly decreasing integers).
    z : array-like of length 4
        Spectral variables (real numbers).
    """
    nu, z = np.asarray(nu, dtype=float), np.asarray(z, dtype=float)
    return min(sum(nu[sigma[i]] * z[i] for i in range(4)) for sigma in S4)

def basis_double_coset(mu, z):
    """
    Hecke basis element: min over S₄ of ∑ᵢ μ(i) · z(σ(i)).

    This represents the tropical indicator of the double coset KμK
    in the Cartan decomposition G = KAK.

    Parameters
    ----------
    mu : array-like of length 4
        Dominant coweight.
    z : array-like of length 4
        Spectral variables.
    """
    mu, z = np.asarray(mu, dtype=float), np.asarray(z, dtype=float)
    return min(sum(mu[i] * z[sigma[i]] for i in range(4)) for sigma in S4)

def satake_transform_GL4(f, z):
    """
    Tropical Satake transform: min over w ∈ S₄ of f(w · z).

    Symmetrizes f over the Weyl group, implementing the tropical
    Harish-Chandra homomorphism.

    Parameters
    ----------
    f : callable
        Function on the maximal torus (takes array of length 4).
    z : array-like of length 4
        Spectral variables.
    """
    z = np.asarray(z, dtype=float)
    return min(f(np.array([z[w[i]] for i in range(4)])) for w in S4)

def coweight_to_partition(mu):
    """Identity map: the coweight IS the partition for GL₄."""
    return np.array(mu, dtype=float)

# ============================================================
# Verification of the Main Theorem
# ============================================================

def verify_isomorphism(mu, z, label=""):
    """Verify that 𝒮(basisDoubleCoset(μ))(z) = tropicalSchur(μ)(z)."""
    lhs = satake_transform_GL4(lambda z_: basis_double_coset(mu, z_), z)
    rhs = tropical_schur_polynomial(coweight_to_partition(mu), z)
    match = np.isclose(lhs, rhs, atol=1e-10)
    status = "✓" if match else "✗"
    print(f"  {status} {label:30s}  LHS = {lhs:10.4f}  RHS = {rhs:10.4f}")
    return match

print("=" * 70)
print("TROPICAL SATAKE ISOMORPHISM FOR GL₄ — NUMERICAL VERIFICATION")
print("=" * 70)
print()
print("Theorem: 𝒮(1_{KμK}^{trop})(z) = s_{λ(μ)}^{trop}(z)")
print()

# Test with various dominant coweights and spectral variables
test_cases = [
    # (coweight μ, spectral z, description)
    ([4, 3, 2, 1], [1.0, 2.0, 3.0, 4.0], "μ=(4,3,2,1), z=(1,2,3,4)"),
    ([3, 1, 0, -1], [0.5, -0.5, 1.5, -1.0], "μ=(3,1,0,-1), z mixed"),
    ([5, 5, 2, 2], [1.0, 1.0, 1.0, 1.0], "μ with repeats, z uniform"),
    ([10, 7, 3, 0], [0.1, 0.2, 0.3, 0.4], "large μ, small z"),
    ([1, 0, 0, 0], [1.0, 2.0, 3.0, 4.0], "fundamental coweight ω₁"),
    ([1, 1, 0, 0], [1.0, 2.0, 3.0, 4.0], "fundamental coweight ω₂"),
    ([1, 1, 1, 0], [1.0, 2.0, 3.0, 4.0], "fundamental coweight ω₃"),
    ([0, 0, 0, 0], [1.0, 2.0, 3.0, 4.0], "trivial coweight"),
    ([3, 2, 1, 0], [-1.0, 0.5, 2.0, -0.5], "ρ-shift, mixed z"),
]

all_pass = True
print("Verification Results:")
for mu, z, desc in test_cases:
    if not verify_isomorphism(mu, z, desc):
        all_pass = False

print()
if all_pass:
    print("All tests PASSED ✓")
else:
    print("Some tests FAILED ✗")

# ============================================================
# Verification of W-invariance
# ============================================================

print()
print("=" * 70)
print("WEYL GROUP (S₄) INVARIANCE VERIFICATION")
print("=" * 70)
print()

mu = [4, 3, 1, 0]
z = [1.0, 2.5, -0.5, 3.0]
base_val = tropical_schur_polynomial(mu, z)
print(f"Base: tropicalSchur({mu}, {z}) = {base_val:.4f}")
print()

# Check invariance under a few generators of S₄
generators = [
    ([1, 0, 2, 3], "swap(0,1)"),
    ([0, 2, 1, 3], "swap(1,2)"),
    ([0, 1, 3, 2], "swap(2,3)"),
    ([3, 2, 1, 0], "reverse"),
    ([1, 2, 3, 0], "cyclic shift"),
]

print("W-invariance of tropical Schur polynomial:")
for perm, name in generators:
    z_perm = [z[perm[i]] for i in range(4)]
    val = tropical_schur_polynomial(mu, z_perm)
    match = np.isclose(val, base_val)
    print(f"  {'✓' if match else '✗'} {name:20s}: "
          f"s(z_{{{','.join(str(p) for p in perm)}}}) = {val:.4f}")

print()
print("W-invariance of Hecke basis element:")
for perm, name in generators:
    z_perm = [z[perm[i]] for i in range(4)]
    val = basis_double_coset(mu, z_perm)
    base_hecke = basis_double_coset(mu, z)
    match = np.isclose(val, base_hecke)
    print(f"  {'✓' if match else '✗'} {name:20s}: "
          f"1_KμK(z_{{{','.join(str(p) for p in perm)}}}) = {val:.4f}")

# ============================================================
# Visualization 1: 2D slice of the tropical Schur polynomial
# ============================================================

print()
print("=" * 70)
print("GENERATING VISUALIZATIONS...")
print("=" * 70)

fig, axes = plt.subplots(2, 2, figsize=(14, 12))

mu_examples = [
    ([3, 2, 1, 0], "μ = (3,2,1,0) — Weyl vector"),
    ([4, 2, 1, 0], "μ = (4,2,1,0)"),
    ([3, 3, 0, 0], "μ = (3,3,0,0) — with repeats"),
    ([1, 0, 0, 0], "μ = (1,0,0,0) — fundamental"),
]

for ax, (mu, title) in zip(axes.flat, mu_examples):
    # Fix z₃ = 0, z₄ = 0, vary z₁ and z₂
    z1_range = np.linspace(-3, 3, 200)
    z2_range = np.linspace(-3, 3, 200)
    Z1, Z2 = np.meshgrid(z1_range, z2_range)
    V = np.zeros_like(Z1)

    for ii in range(Z1.shape[0]):
        for jj in range(Z1.shape[1]):
            z_val = [Z1[ii, jj], Z2[ii, jj], 0.0, 0.0]
            V[ii, jj] = tropical_schur_polynomial(mu, z_val)

    cf = ax.contourf(Z1, Z2, V, levels=30, cmap='viridis')
    ax.contour(Z1, Z2, V, levels=15, colors='white', linewidths=0.3, alpha=0.5)
    plt.colorbar(cf, ax=ax, shrink=0.8)
    ax.set_xlabel('z₁')
    ax.set_ylabel('z₂')
    ax.set_title(title, fontsize=11)
    ax.set_aspect('equal')

plt.suptitle('Tropical Schur Polynomials for GL₄\n'
             '(2D slices: z₃ = z₄ = 0)', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('demo/tropical_schur_contours.png', dpi=150, bbox_inches='tight')
print("  Saved: demo/tropical_schur_contours.png")
plt.close()

# ============================================================
# Visualization 2: Satake transform verification heatmap
# ============================================================

fig, ax = plt.subplots(figsize=(10, 8))

mu = [4, 3, 1, 0]
z1_range = np.linspace(-2, 2, 80)
z2_range = np.linspace(-2, 2, 80)
Z1, Z2 = np.meshgrid(z1_range, z2_range)
Diff = np.zeros_like(Z1)

for ii in range(Z1.shape[0]):
    for jj in range(Z1.shape[1]):
        z_val = [Z1[ii, jj], Z2[ii, jj], 0.5, -0.5]
        lhs = satake_transform_GL4(
            lambda z_: basis_double_coset(mu, z_), z_val)
        rhs = tropical_schur_polynomial(
            coweight_to_partition(mu), z_val)
        Diff[ii, jj] = abs(lhs - rhs)

im = ax.imshow(Diff, extent=[-2, 2, -2, 2], origin='lower',
               cmap='RdYlGn_r', vmin=0, vmax=1e-10)
plt.colorbar(im, ax=ax, label='|LHS - RHS|')
ax.set_xlabel('z₁')
ax.set_ylabel('z₂')
ax.set_title(f'Tropical Satake Isomorphism Verification\n'
             f'μ = {mu}, z₃ = 0.5, z₄ = -0.5\n'
             f'Max difference: {Diff.max():.2e}',
             fontsize=12)
plt.tight_layout()
plt.savefig('demo/satake_verification_heatmap.png', dpi=150, bbox_inches='tight')
print("  Saved: demo/satake_verification_heatmap.png")
plt.close()

# ============================================================
# Visualization 3: Piecewise-linear structure
# ============================================================

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

mu = [3, 2, 1, 0]
z_fixed = [0.0, 0.0]  # z₃, z₄ fixed

# Plot 1: 1D slice along z₁ (z₂ = z₃ = z₄ = 0)
z1_vals = np.linspace(-4, 4, 500)
schur_vals = [tropical_schur_polynomial(mu, [z1, 0, 0, 0]) for z1 in z1_vals]
hecke_vals = [basis_double_coset(mu, [z1, 0, 0, 0]) for z1 in z1_vals]

axes[0].plot(z1_vals, schur_vals, 'b-', linewidth=2, label='Tropical Schur')
axes[0].plot(z1_vals, hecke_vals, 'r--', linewidth=2, label='Hecke basis', alpha=0.7)
axes[0].set_xlabel('z₁')
axes[0].set_ylabel('Value')
axes[0].set_title('1D slice: z₂ = z₃ = z₄ = 0')
axes[0].legend()
axes[0].grid(True, alpha=0.3)

# Plot 2: Along the diagonal z₁ = z₂ = t, z₃ = z₄ = 0
t_vals = np.linspace(-3, 3, 500)
schur_diag = [tropical_schur_polynomial(mu, [t, t, 0, 0]) for t in t_vals]
hecke_diag = [basis_double_coset(mu, [t, t, 0, 0]) for t in t_vals]

axes[1].plot(t_vals, schur_diag, 'b-', linewidth=2, label='Tropical Schur')
axes[1].plot(t_vals, hecke_diag, 'r--', linewidth=2, label='Hecke basis', alpha=0.7)
axes[1].set_xlabel('t (z₁ = z₂ = t)')
axes[1].set_ylabel('Value')
axes[1].set_title('Diagonal slice: z₁ = z₂ = t')
axes[1].legend()
axes[1].grid(True, alpha=0.3)

# Plot 3: Individual permutation contributions
axes[2].set_title('Permutation contributions\n(μ = (3,2,1,0), z₂=z₃=z₄=0)')
z1_fine = np.linspace(-2, 2, 300)

# Show a few representative permutations
sample_perms = [(0,1,2,3), (3,2,1,0), (1,0,3,2), (2,3,0,1), (0,2,1,3)]
colors = ['blue', 'red', 'green', 'orange', 'purple']

for perm, color in zip(sample_perms, colors):
    vals = [sum(mu[perm[i]] * ([z1, 0, 0, 0])[i] for i in range(4))
            for z1 in z1_fine]
    axes[2].plot(z1_fine, vals, color=color, alpha=0.4,
                 label=f'σ={perm}')

# The tropical Schur polynomial (the minimum envelope)
env = [tropical_schur_polynomial(mu, [z1, 0, 0, 0]) for z1 in z1_fine]
axes[2].plot(z1_fine, env, 'k-', linewidth=3, label='min (Schur)')
axes[2].legend(fontsize=7, loc='upper left')
axes[2].grid(True, alpha=0.3)
axes[2].set_xlabel('z₁')

plt.suptitle('Piecewise-Linear Structure of Tropical Polynomials',
             fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig('demo/piecewise_linear_structure.png', dpi=150, bbox_inches='tight')
print("  Saved: demo/piecewise_linear_structure.png")
plt.close()

# ============================================================
# Visualization 4: Tropical Newton polytope
# ============================================================

fig = plt.figure(figsize=(10, 8))
ax = fig.add_subplot(111, projection='3d')

mu = [3, 2, 1, 0]

# The tropical Schur polynomial is piecewise linear, so its
# "tropical hypersurface" (where the minimum is achieved by
# at least two permutations) forms a polyhedral complex.
# Let's visualize the 3D tropical variety by plotting the surface.

z1_range = np.linspace(-2, 2, 60)
z2_range = np.linspace(-2, 2, 60)
Z1, Z2 = np.meshgrid(z1_range, z2_range)
V = np.zeros_like(Z1)

for ii in range(Z1.shape[0]):
    for jj in range(Z1.shape[1]):
        V[ii, jj] = tropical_schur_polynomial(mu, [Z1[ii,jj], Z2[ii,jj], 0, 0])

ax.plot_surface(Z1, Z2, V, cmap='coolwarm', alpha=0.8, linewidth=0,
                antialiased=True)
ax.set_xlabel('z₁')
ax.set_ylabel('z₂')
ax.set_zlabel('s_μ^{trop}(z)')
ax.set_title(f'Tropical Schur Polynomial Surface\nμ = {mu}, z₃ = z₄ = 0',
             fontsize=12)
ax.view_init(elev=25, azim=135)

plt.tight_layout()
plt.savefig('demo/tropical_surface_3d.png', dpi=150, bbox_inches='tight')
print("  Saved: demo/tropical_surface_3d.png")
plt.close()

# ============================================================
# Application: Tropical Convexity Check
# ============================================================

print()
print("=" * 70)
print("APPLICATION: TROPICAL CONVEXITY OF SCHUR POLYNOMIALS")
print("=" * 70)
print()

mu = [4, 3, 1, 0]
print(f"Testing tropical convexity of s_μ^trop for μ = {mu}")
print()

# A tropical polynomial is tropically convex if it satisfies:
# f(min(x,y)) ≤ min(f(x), f(y))  (not generally true)
# But the Hecke basis / Schur polynomial IS convex in the classical sense
# (piecewise linear, inf of affine functions = concave, not convex)
# Actually, inf of linear functions is concave.

np.random.seed(42)
n_tests = 1000
concave_violations = 0

for _ in range(n_tests):
    z_a = np.random.randn(4)
    z_b = np.random.randn(4)
    t = np.random.rand()
    z_mid = t * z_a + (1 - t) * z_b

    f_a = tropical_schur_polynomial(mu, z_a)
    f_b = tropical_schur_polynomial(mu, z_b)
    f_mid = tropical_schur_polynomial(mu, z_mid)

    # Concavity: f(t·a + (1-t)·b) ≥ t·f(a) + (1-t)·f(b)
    if f_mid < t * f_a + (1 - t) * f_b - 1e-10:
        concave_violations += 1

print(f"Concavity test ({n_tests} random pairs):")
print(f"  Violations: {concave_violations}")
print(f"  Result: {'CONCAVE ✓' if concave_violations == 0 else 'NOT CONCAVE ✗'}")
print()
print("  (The tropical Schur polynomial is concave because it is")
print("   the infimum of linear functions — a key structural property)")

# ============================================================
# Application: Tropical eigenvalue bounds
# ============================================================

print()
print("=" * 70)
print("APPLICATION: TROPICAL SPECTRAL BOUNDS")
print("=" * 70)
print()

print("The tropical Satake isomorphism connects:")
print("  • Geometric side: min-plus convolution on the affine building")
print("  • Spectral side: tropical Schur polynomials (Weyl orbit sums)")
print()
print("This gives explicit bounds on 'tropical eigenvalues' of matrices")
print("via the piecewise-linear structure of the Schur polynomial.")
print()

mu = [5, 3, 1, 0]
z = np.array([1.0, 0.5, -0.5, -1.0])

# The minimum is achieved by some permutation σ*
vals_by_perm = []
for sigma in S4:
    v = sum(mu[sigma[i]] * z[i] for i in range(4))
    vals_by_perm.append((v, sigma))

vals_by_perm.sort()
print(f"For μ = {mu}, z = {list(z)}:")
print(f"  Tropical Schur value = {vals_by_perm[0][0]:.4f}")
print(f"  Achieving permutation σ* = {vals_by_perm[0][1]}")
print()
print("  All permutation values (sorted):")
for v, sigma in vals_by_perm[:6]:
    print(f"    σ = {sigma} → ∑ μ(σ(i))·z(i) = {v:.4f}")
print(f"    ... ({len(vals_by_perm) - 6} more)")

print()
print("=" * 70)
print("DEMONSTRATION COMPLETE")
print("=" * 70)
