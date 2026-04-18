#!/usr/bin/env python3
"""
EML Curvature and Geodesic Computation
========================================
Numerical computation of the Gaussian curvature K(x) of the EML
Riemannian manifold (ℝ₊, g) where g(x) = exp(x) + 1/x².

Also computes geodesics and arc lengths numerically.
"""

import numpy as np
from scipy.integrate import solve_ivp, quad
from scipy.optimize import brentq
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def g_metric(x):
    """The EML Riemannian metric g(x) = exp(x) + 1/x²."""
    return np.exp(x) + 1/x**2


def g_deriv(x):
    """g'(x) = exp(x) - 2/x³."""
    return np.exp(x) - 2/x**3


def g_second_deriv(x):
    """g''(x) = exp(x) + 6/x⁴."""
    return np.exp(x) + 6/x**4


def gaussian_curvature(x):
    """
    Gaussian curvature of the 1D Riemannian manifold.
    For a metric ds² = g(x) dx², the curvature is:
    K(x) = -1/(2√g) · d²/dx²(1/√g)
    """
    g = g_metric(x)
    gp = g_deriv(x)
    gpp = g_second_deriv(x)
    sqrt_g = np.sqrt(g)

    # d/dx(1/√g) = -g'/(2g^{3/2})
    # d²/dx²(1/√g) = -g''/(2g^{3/2}) + 3(g')²/(4g^{5/2})
    d2_inv_sqrt_g = -gpp / (2 * g**1.5) + 3 * gp**2 / (4 * g**2.5)

    return -d2_inv_sqrt_g / (2 * sqrt_g)


def arc_length(a, b, n_points=10000):
    """Compute arc length ∫_a^b √g(x) dx."""
    result, error = quad(lambda x: np.sqrt(g_metric(x)), a, b)
    return result


def geodesic_ode(t, state):
    """
    Geodesic equation for (ℝ₊, g):
    x'' + Γ x'² = 0 where Γ = g'/(2g)
    Written as first-order system: x' = v, v' = -Γv²
    """
    x, v = state
    if x <= 0:
        return [v, 0]
    g = g_metric(x)
    gp = g_deriv(x)
    gamma = gp / (2 * g)
    return [v, -gamma * v**2]


# ============================================================
# Figure 1: Gaussian Curvature
# ============================================================
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# 1a: Curvature as a function of x
ax = axes[0, 0]
x = np.linspace(0.05, 5, 2000)
K = np.array([gaussian_curvature(xi) for xi in x])
ax.plot(x, K, 'b-', linewidth=2)
ax.axhline(y=0, color='gray', linestyle='-', alpha=0.3)
ax.set_xlabel('x')
ax.set_ylabel('K(x)')
ax.set_title('Gaussian Curvature of EML Manifold')
ax.grid(True, alpha=0.3)

# Find where curvature changes sign
sign_changes = []
for i in range(len(K)-1):
    if K[i] * K[i+1] < 0:
        x_cross = brentq(gaussian_curvature, x[i], x[i+1])
        sign_changes.append(x_cross)
        ax.axvline(x=x_cross, color='red', linestyle=':', alpha=0.7)
        ax.annotate(f'x ≈ {x_cross:.3f}', (x_cross, 0),
                   fontsize=8, color='red')

print(f"Curvature sign changes at: {sign_changes}")

# 1b: Metric and its derivative
ax = axes[0, 1]
x = np.linspace(0.1, 4, 500)
ax.semilogy(x, g_metric(x), 'b-', linewidth=2, label='g(x)')
gp = g_deriv(x)
ax.plot(x, np.abs(gp), 'r-', linewidth=1.5, label="|g'(x)|")
# Mark where g' = 0
try:
    x_gp_zero = brentq(g_deriv, 0.5, 2.0)
    ax.axvline(x=x_gp_zero, color='green', linestyle=':', alpha=0.7,
              label=f"g'=0 at x≈{x_gp_zero:.3f}")
except:
    pass
ax.set_xlabel('x')
ax.set_ylabel('Value')
ax.set_title('EML Metric and Derivative')
ax.legend()
ax.grid(True, alpha=0.3)

# 1c: Arc length from x=1 to various endpoints
ax = axes[1, 0]
endpoints = np.linspace(0.01, 0.99, 50)
arc_to_zero = [arc_length(ep, 1.0) for ep in endpoints]
ax.plot(endpoints, arc_to_zero, 'b-', linewidth=2)
ax.set_xlabel('Lower endpoint a')
ax.set_ylabel('Arc length from a to 1')
ax.set_title('Arc Length to x=1 (Diverges as a → 0⁺)')
ax.grid(True, alpha=0.3)

endpoints_right = np.linspace(1.01, 10, 50)
arc_to_inf = [arc_length(1.0, ep) for ep in endpoints_right]
ax.twinx().plot(endpoints_right, arc_to_inf, 'r-', linewidth=2)
ax.set_ylabel('Arc length from 1 to b (red)')

# 1d: Geodesic curves
ax = axes[1, 1]
x0 = 1.0
for v0 in [-2, -1, -0.5, 0.5, 1, 2]:
    try:
        sol = solve_ivp(geodesic_ode, [0, 3], [x0, v0],
                       max_step=0.01, events=lambda t, y: y[0] - 0.001)
        valid = sol.y[0] > 0
        ax.plot(sol.t[valid], sol.y[0][valid], linewidth=1.5,
               label=f'v₀ = {v0}')
    except:
        pass
ax.set_xlabel('Parameter t')
ax.set_ylabel('x(t)')
ax.set_title('Geodesics from x₀ = 1')
ax.legend(fontsize=8)
ax.set_ylim(0, 10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/Speculative/OISCC/demos/fig7_curvature_geodesics.png', dpi=150)
plt.close()
print("Figure 7 saved: fig7_curvature_geodesics.png")


# ============================================================
# Figure 2: Bregman Divergence and Information Geometry
# ============================================================
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

def f_potential(x):
    return np.exp(x) - np.log(x) - 1

def f_deriv(x):
    return np.exp(x) - 1/x

def bregman_div(x, y):
    """B_f(x, y) = f(x) - f(y) - f'(y)(x - y)."""
    return f_potential(x) - f_potential(y) - f_deriv(y) * (x - y)

# 2a: Bregman divergence B(x, y) as a heatmap
ax = axes[0]
xs = np.linspace(0.1, 3, 200)
ys = np.linspace(0.1, 3, 200)
X, Y = np.meshgrid(xs, ys)
B = bregman_div(X, Y)
im = ax.contourf(X, Y, np.log10(B + 1e-10), levels=20, cmap='viridis')
ax.plot([0.1, 3], [0.1, 3], 'w--', linewidth=1, label='x = y (B = 0)')
plt.colorbar(im, ax=ax, label='log₁₀(B(x,y))')
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.set_title('Bregman Divergence (log scale)')
ax.legend()

# 2b: Bregman divergence B(x, 1) as a function of x
ax = axes[1]
x = np.linspace(0.1, 4, 500)
B_x_1 = bregman_div(x, 1.0)
ax.plot(x, B_x_1, 'b-', linewidth=2, label='B(x, 1)')
ax.plot(x, (x - 1)**2 / 2, 'r--', linewidth=1.5, label='(x-1)²/2')
ax.set_xlabel('x')
ax.set_ylabel('B(x, 1)')
ax.set_title('Bregman Divergence from x = 1')
ax.legend()
ax.set_ylim(0, 10)
ax.grid(True, alpha=0.3)

# 2c: Natural gradient magnitude ||∇f||_g = |f'(x)|/√g(x)
ax = axes[2]
x = np.linspace(0.1, 4, 500)
natural_grad = np.abs(f_deriv(x)) / np.sqrt(g_metric(x))
standard_grad = np.abs(f_deriv(x))
ax.plot(x, standard_grad, 'r--', linewidth=1.5, label='|f\'(x)| (standard)')
ax.plot(x, natural_grad, 'b-', linewidth=2, label='|f\'(x)|/√g(x) (natural)')
ax.set_xlabel('x')
ax.set_ylabel('Gradient magnitude')
ax.set_title('Natural vs Standard Gradient')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/Speculative/OISCC/demos/fig8_information_geometry.png', dpi=150)
plt.close()
print("Figure 8 saved: fig8_information_geometry.png")


# ============================================================
# Numerical Curvature Analysis
# ============================================================
print("\n" + "="*60)
print("CURVATURE ANALYSIS SUMMARY")
print("="*60)

# Sample curvature values
for xi in [0.1, 0.2, 0.5, 1.0, 1.5, 2.0, 3.0, 5.0]:
    K_val = gaussian_curvature(xi)
    g_val = g_metric(xi)
    print(f"  x = {xi:.1f}: K = {K_val:.6f}, g = {g_val:.4f}")

print(f"\nCurvature sign changes at: {[f'{x:.4f}' for x in sign_changes]}")

if len(sign_changes) > 0:
    # Find curvature extrema
    x_fine = np.linspace(0.05, 5, 5000)
    K_fine = np.array([gaussian_curvature(xi) for xi in x_fine])
    K_min_idx = np.argmin(K_fine)
    K_max_idx = np.argmax(K_fine)
    print(f"  Curvature minimum: K({x_fine[K_min_idx]:.4f}) = {K_fine[K_min_idx]:.6f}")
    print(f"  Curvature maximum: K({x_fine[K_max_idx]:.4f}) = {K_fine[K_max_idx]:.6f}")

# Arc length estimates
print("\nArc length estimates:")
for a in [0.01, 0.05, 0.1]:
    L = arc_length(a, 1.0)
    print(f"  ∫_{a}^1 √g dx = {L:.4f}")
for b in [2, 5, 10, 20]:
    L = arc_length(1.0, b)
    print(f"  ∫_1^{b} √g dx = {L:.4f}")

print(f"\nLower bound check: ∫_0.01^1 1/x dx = {np.log(1/0.01):.4f}")
print("Actual arc length is larger (proven: √g ≥ 1/x)")
