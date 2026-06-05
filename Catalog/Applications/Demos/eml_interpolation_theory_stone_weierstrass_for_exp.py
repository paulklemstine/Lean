#!/usr/bin/env python3
"""
EML Interpolation Theory: Demonstrations and Numerical Examples

This script demonstrates the key results from the EML interpolation theory:
1. EML kernel properties (symmetry, peak at diagonal, decay)
2. Stone-Weierstrass density: EML approximation of continuous functions
3. EML Vandermonde matrix non-degeneracy
4. Depth hierarchy visualization
"""

import numpy as np

def eml_kernel(x, y):
    """EML interpolation kernel: K(x,y) = exp(-(log(x/y))^2)"""
    return np.exp(-(np.log(x / y))**2)

def eml_function(x, y):
    """Basic EML function: eml(x,y) = exp(x) - log(y)"""
    return np.exp(x) - np.log(y)

def exp_tower(n, x):
    """Iterated exponential tower of height n"""
    result = x
    for _ in range(n):
        result = np.exp(result)
    return result

def vandermonde_matrix(x):
    """Construct Vandermonde matrix V[i,j] = x[i]^j"""
    n = len(x)
    return np.array([[xi**j for j in range(n)] for xi in x])


# ============================================================
# Example 1: EML Kernel Properties
# ============================================================
print("=" * 60)
print("EXAMPLE 1: EML Kernel Properties")
print("=" * 60)

# Symmetry
x, y = 2.0, 3.0
k_xy = eml_kernel(x, y)
k_yx = eml_kernel(y, x)
print(f"\nKernel symmetry: K({x},{y}) = {k_xy:.8f}")
print(f"                 K({y},{x}) = {k_yx:.8f}")
print(f"                 Difference = {abs(k_xy - k_yx):.2e}")

# Peak at diagonal
for z in [1.0, 2.0, 5.0, 10.0]:
    print(f"K({z},{z}) = {eml_kernel(z, z):.8f}  (should be 1.0)")

# Decay away from diagonal
print("\nKernel decay (x=2.0):")
for y_val in [1.5, 1.8, 1.9, 1.99, 2.0, 2.01, 2.1, 2.5, 3.0]:
    print(f"  K(2.0, {y_val:.2f}) = {eml_kernel(2.0, y_val):.8f}")

# Lower bound verification
delta = 0.5
x_test, y_test = 2.0, 2.5
log_diff = abs(np.log(x_test) - np.log(y_test))
print(f"\nLower bound test: |log({x_test})-log({y_test})| = {log_diff:.4f}")
print(f"  δ = {delta}, exp(-δ²) = {np.exp(-delta**2):.8f}")
print(f"  K({x_test},{y_test}) = {eml_kernel(x_test, y_test):.8f}")
print(f"  Lower bound holds: {np.exp(-delta**2) <= eml_kernel(x_test, y_test)}")


# ============================================================
# Example 2: EML Approximation of Continuous Functions
# ============================================================
print("\n" + "=" * 60)
print("EXAMPLE 2: EML Polynomial Approximation (Stone-Weierstrass)")
print("=" * 60)

# Approximate f(x) = sin(x) on [0.5, 3.0] using polynomials
# (polynomials are in the EML algebra since x = exp(log(x)))
a, b = 0.5, 3.0
f_target = np.sin

# Chebyshev nodes for good polynomial approximation
for degree in [3, 5, 8, 12, 20]:
    # Chebyshev nodes on [a,b]
    k = np.arange(degree + 1)
    nodes = 0.5 * (a + b) + 0.5 * (b - a) * np.cos(np.pi * k / degree)
    # Polynomial interpolation
    coeffs = np.polyfit(nodes, f_target(nodes), degree)
    # Evaluate error on dense grid
    x_dense = np.linspace(a, b, 1000)
    approx = np.polyval(coeffs, x_dense)
    error = np.max(np.abs(f_target(x_dense) - approx))
    print(f"  Degree {degree:2d}: max error = {error:.2e}")


# ============================================================
# Example 3: EML Vandermonde Matrix
# ============================================================
print("\n" + "=" * 60)
print("EXAMPLE 3: EML Vandermonde Non-degeneracy")
print("=" * 60)

for n in [3, 5, 8, 10]:
    # Distinct positive reals
    x_points = np.array([1.0 + 0.5 * i for i in range(n)])
    V = vandermonde_matrix(x_points)
    det_val = np.linalg.det(V)
    cond = np.linalg.cond(V)
    print(f"  n={n:2d}: det = {det_val:+.4e}, cond = {cond:.2e}")

# Verify: Vandermonde det = prod_{i<j} (x_j - x_i)
x3 = np.array([1.0, 2.0, 4.0])
V3 = vandermonde_matrix(x3)
det_formula = (x3[1] - x3[0]) * (x3[2] - x3[0]) * (x3[2] - x3[1])
print(f"\n  Verification (n=3, x=[1,2,4]):")
print(f"    det(V) = {np.linalg.det(V3):.8f}")
print(f"    Π(xⱼ-xᵢ) = {det_formula:.8f}")


# ============================================================
# Example 4: Depth Hierarchy
# ============================================================
print("\n" + "=" * 60)
print("EXAMPLE 4: Depth Hierarchy (exp tower growth)")
print("=" * 60)

x_val = 1.0
for d in range(6):
    try:
        tower = exp_tower(d, x_val)
        print(f"  expTower({d}, {x_val}) = {tower:.6e}")
    except OverflowError:
        print(f"  expTower({d}, {x_val}) = OVERFLOW")


# ============================================================
# Example 5: Log-diameter and EML geometry
# ============================================================
print("\n" + "=" * 60)
print("EXAMPLE 5: Log-diameter")
print("=" * 60)

intervals = [(0.5, 1.0), (1.0, 2.0), (1.0, 10.0), (0.1, 100.0)]
for a_val, b_val in intervals:
    ld = np.log(b_val) - np.log(a_val)
    print(f"  logDiam({a_val}, {b_val}) = {ld:.4f}")


# ============================================================
# Example 6: Constant EML approximation error bound
# ============================================================
print("\n" + "=" * 60)
print("EXAMPLE 6: Constant Approximation Error Bound")
print("=" * 60)

# f(x) = x^2, which is Lipschitz with L = 2b on [a,b]
a_val, b_val = 1.0, 3.0
L = 2 * b_val  # Lipschitz constant of x^2 on [1,3]
bound = L * (b_val - a_val)

x_test = np.linspace(a_val, b_val, 100)
f_vals = x_test**2
const_approx = a_val**2  # f(a) = 1
actual_error = np.max(np.abs(f_vals - const_approx))

print(f"  f(x) = x² on [{a_val}, {b_val}]")
print(f"  Lipschitz constant L = {L}")
print(f"  Constant approx g = f({a_val}) = {const_approx}")
print(f"  Actual max error = {actual_error:.4f}")
print(f"  Theoretical bound L·(b-a) = {bound:.4f}")
print(f"  Bound holds: {actual_error <= bound}")

print("\n" + "=" * 60)
print("All examples completed successfully!")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: EML Polynomial Approximation Convergence

Demonstrates Stone-Weierstrass density by showing polynomial (EML depth-0)
approximations converging to continuous functions on compact intervals.
"""
import numpy as np
import matplotlib.pyplot as plt

def chebyshev_approx(f, a, b, degree):
    """Polynomial approximation using Chebyshev nodes."""
    k = np.arange(degree + 1)
    nodes = 0.5 * (a + b) + 0.5 * (b - a) * np.cos(np.pi * k / degree)
    coeffs = np.polyfit(nodes, f(nodes), degree)
    return coeffs

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Target functions
targets = [
    (lambda x: np.sin(x), "sin(x)", 0.5, 3.0),
    (lambda x: np.exp(-x) * np.cos(5*x), "exp(-x)cos(5x)", 0.5, 4.0),
    (lambda x: np.sqrt(x), "√x", 0.5, 4.0),
    (lambda x: 1.0 / (1 + 25*(x-2)**2), "Runge function", 0.5, 3.5),
]

degrees = [2, 4, 8, 16, 32]
colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(degrees)))

for idx, (f, name, a, b) in enumerate(targets):
    ax = axes[idx // 2][idx % 2]
    x_dense = np.linspace(a, b, 1000)

    # Plot target
    ax.plot(x_dense, f(x_dense), 'k-', linewidth=2, label='Target')

    # Plot approximations
    for deg, color in zip(degrees[:4], colors):
        coeffs = chebyshev_approx(f, a, b, deg)
        approx = np.polyval(coeffs, x_dense)
        error = np.max(np.abs(f(x_dense) - approx))
        ax.plot(x_dense, approx, '--', color=color,
                label=f'deg {deg} (err={error:.1e})')

    ax.set_title(f'EML Approximation: f(x) = {name}')
    ax.set_xlabel('x')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

plt.suptitle('Stone-Weierstrass Density: EML Polynomial Convergence', fontsize=14)
plt.tight_layout()
plt.savefig('Applications/eml_approximation_viz.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: Applications/eml_approximation_viz.png")

# Convergence rate plot
fig, ax = plt.subplots(figsize=(8, 6))
for f, name, a, b in targets:
    errors = []
    degs = list(range(1, 30))
    for deg in degs:
        coeffs = chebyshev_approx(f, a, b, deg)
        x_dense = np.linspace(a, b, 1000)
        error = np.max(np.abs(f(x_dense) - np.polyval(coeffs, x_dense)))
        errors.append(max(error, 1e-16))
    ax.semilogy(degs, errors, '-o', markersize=3, label=name)

ax.set_xlabel('Polynomial degree (EML term size)')
ax.set_ylabel('Maximum approximation error')
ax.set_title('EML Approximation Convergence Rate')
ax.legend()
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('Applications/eml_convergence_viz.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: Applications/eml_convergence_viz.png")


#!/usr/bin/env python3
"""
Visualization: EML Interpolation Kernel Heatmap and Decay Profile

Shows the kernel K(x,y) = exp(-(log(x/y))^2) as a 2D heatmap
and its 1D cross-section showing Gaussian-like decay in log-space.
"""
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm

def eml_kernel(x, y):
    return np.exp(-(np.log(x / y))**2)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: 2D kernel heatmap
x_grid = np.linspace(0.5, 5.0, 200)
y_grid = np.linspace(0.5, 5.0, 200)
X, Y = np.meshgrid(x_grid, y_grid)
K = eml_kernel(X, Y)

im = axes[0].imshow(K, extent=[0.5, 5, 0.5, 5], origin='lower',
                     cmap='magma', vmin=0, vmax=1, aspect='auto')
axes[0].set_xlabel('x')
axes[0].set_ylabel('y')
axes[0].set_title('EML Kernel K(x,y) = exp(-(log(x/y))²)')
plt.colorbar(im, ax=axes[0], label='K(x,y)')

# Panel 2: 1D cross-sections
x_fixed_values = [1.0, 2.0, 3.0]
y_range = np.linspace(0.3, 6.0, 500)
for xf in x_fixed_values:
    k_vals = eml_kernel(xf, y_range)
    axes[1].plot(y_range, k_vals, label=f'K({xf}, y)')
axes[1].set_xlabel('y')
axes[1].set_ylabel('K(x₀, y)')
axes[1].set_title('Kernel Cross-sections')
axes[1].legend()
axes[1].set_ylim(0, 1.05)
axes[1].axhline(y=1, color='gray', linestyle='--', alpha=0.3)

# Panel 3: Kernel in log-space (shows Gaussian shape)
log_y = np.linspace(-2, 2, 500)
for xf in x_fixed_values:
    y_vals = np.exp(np.log(xf) + log_y)
    k_vals = eml_kernel(xf, y_vals)
    axes[2].plot(log_y, k_vals, label=f'x₀ = {xf}')
# Overlay Gaussian envelope
gaussian = np.exp(-log_y**2)
axes[2].plot(log_y, gaussian, 'k--', alpha=0.5, label='exp(-δ²)')
axes[2].set_xlabel('log(y/x₀)')
axes[2].set_ylabel('K(x₀, y)')
axes[2].set_title('Kernel in Log-space (Gaussian shape)')
axes[2].legend()

plt.tight_layout()
plt.savefig('Applications/eml_kernel_viz.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: Applications/eml_kernel_viz.png")
