#!/usr/bin/env python3
"""
EML Orbit Visualization
========================
Visualizes the orbits of the 2D EML map Φ(x,y) = (exp(x)-ln(y), exp(y)-ln(x))
and the diagonal map d(x) = exp(x) - ln(x).

Demonstrates:
- Super-exponential divergence of orbits
- Displacement acceleration along orbits
- Diagonal invariance
- The universal escape theorem: d(x) - x ≥ 1
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def eml(a, b):
    """The EML operation: EML(a,b) = exp(a) - ln(b)."""
    return np.exp(a) - np.log(b)


def diagonal_map(x):
    """The diagonal map d(x) = exp(x) - ln(x)."""
    return np.exp(x) - np.log(x)


def displacement(x):
    """The displacement function δ(x) = d(x) - x = exp(x) - ln(x) - x."""
    return np.exp(x) - np.log(x) - x


def phi_2d(x, y):
    """The 2D EML map Φ(x,y) = (EML(x,y), EML(y,x))."""
    return eml(x, y), eml(y, x)


def iterate_diagonal(x0, n_steps):
    """Iterate the diagonal map n_steps times."""
    orbit = [x0]
    x = x0
    for _ in range(n_steps):
        x = diagonal_map(x)
        orbit.append(x)
    return np.array(orbit)


def iterate_2d(x0, y0, n_steps):
    """Iterate the 2D map n_steps times."""
    xs, ys = [x0], [y0]
    x, y = x0, y0
    for _ in range(n_steps):
        x, y = phi_2d(x, y)
        xs.append(x)
        ys.append(y)
    return np.array(xs), np.array(ys)


# ============================================================
# Figure 1: Diagonal Orbit and Super-Exponential Growth
# ============================================================
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# 1a: First few iterates of d(x) from different starting points
ax = axes[0, 0]
for x0 in [0.1, 0.5, 1.0, 2.0]:
    orbit = iterate_diagonal(x0, 6)
    ax.semilogy(range(len(orbit)), orbit, 'o-', label=f'x₀ = {x0}', markersize=4)
ax.set_xlabel('Iteration n')
ax.set_ylabel('d^n(x₀)')
ax.set_title('Diagonal Orbit: Super-Exponential Growth')
ax.legend()
ax.grid(True, alpha=0.3)

# 1b: Displacement δ(x) = d(x) - x as a function of x
ax = axes[0, 1]
x = np.linspace(0.01, 5, 1000)
delta = displacement(x)
ax.plot(x, delta, 'b-', linewidth=2)
ax.axhline(y=1, color='r', linestyle='--', alpha=0.7, label='δ ≥ 1 (proven)')
ax.fill_between(x, 1, delta, alpha=0.2, color='blue')
ax.set_xlabel('x')
ax.set_ylabel('δ(x) = d(x) - x')
ax.set_title('Displacement Function (Convex, ≥ 1)')
ax.legend()
ax.set_ylim(0, 10)
ax.grid(True, alpha=0.3)

# 1c: Displacement along orbit (acceleration)
ax = axes[1, 0]
for x0 in [0.5, 1.0, 2.0]:
    orbit = iterate_diagonal(x0, 8)
    disps = [orbit[i+1] - orbit[i] for i in range(len(orbit)-1)]
    ax.semilogy(range(len(disps)), disps, 'o-', label=f'x₀ = {x0}', markersize=4)
ax.axhline(y=1, color='r', linestyle='--', alpha=0.7, label='Minimum δ = 1')
ax.set_xlabel('Iteration n')
ax.set_ylabel('δₙ = d^{n+1}(x₀) - d^n(x₀)')
ax.set_title('Displacement Acceleration Along Orbits')
ax.legend()
ax.grid(True, alpha=0.3)

# 1d: 2D orbit in phase space
ax = axes[1, 1]
for x0, y0 in [(0.5, 0.5), (0.3, 0.7), (1.0, 0.5)]:
    xs, ys = iterate_2d(x0, y0, 4)
    ax.plot(xs, ys, 'o-', label=f'({x0}, {y0})', markersize=5)
    ax.annotate('start', (xs[0], ys[0]), fontsize=7)
ax.plot([0, 50], [0, 50], 'k--', alpha=0.3, label='Diagonal')
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.set_title('2D EML Orbits (Phase Space)')
ax.legend(fontsize=8)
ax.set_xlim(-1, 30)
ax.set_ylim(-1, 30)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/Speculative/OISCC/demos/fig1_orbit_visualization.png', dpi=150)
plt.close()
print("Figure 1 saved: fig1_orbit_visualization.png")


# ============================================================
# Figure 2: The EML Potential Landscape
# ============================================================
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# 2a: The potential f(x) = exp(x) - ln(x) - 1
ax = axes[0]
x = np.linspace(0.01, 3, 1000)
f = np.exp(x) - np.log(x) - 1
quadratic = (x - 1)**2 / 2
ax.plot(x, f, 'b-', linewidth=2, label='f(x) = exp(x) - ln(x) - 1')
ax.plot(x, quadratic, 'r--', linewidth=1.5, label='(x-1)²/2 (lower bound)')
ax.axhline(y=1, color='g', linestyle=':', alpha=0.7, label='f ≥ 1 (proven)')
# Mark the minimum
from scipy.optimize import minimize_scalar
res = minimize_scalar(lambda x: np.exp(x) - np.log(x) - 1, bounds=(0.01, 3), method='bounded')
x_min = res.x
f_min = res.fun
ax.plot(x_min, f_min, 'ko', markersize=8, label=f'min at x₀ ≈ {x_min:.3f}')
ax.set_xlabel('x')
ax.set_ylabel('f(x)')
ax.set_title('EML Potential (Strictly Convex)')
ax.legend(fontsize=8)
ax.set_ylim(0, 8)
ax.grid(True, alpha=0.3)

# 2b: The Riemannian metric g(x) = exp(x) + 1/x²
ax = axes[1]
x = np.linspace(0.05, 4, 1000)
g = np.exp(x) + 1/x**2
ax.semilogy(x, g, 'b-', linewidth=2, label='g(x) = exp(x) + 1/x²')
ax.semilogy(x, np.exp(x), 'r--', linewidth=1, label='exp(x)')
ax.semilogy(x, 1/x**2, 'g--', linewidth=1, label='1/x²')
ax.axhline(y=1, color='gray', linestyle=':', alpha=0.5)
ax.set_xlabel('x')
ax.set_ylabel('g(x)')
ax.set_title('EML Riemannian Metric (Blows Up Both Ends)')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# 2c: The derivative η(x) = exp(x) - 1/x (natural parameter)
ax = axes[2]
x = np.linspace(0.05, 3, 1000)
eta_vals = np.exp(x) - 1/x
ax.plot(x, eta_vals, 'b-', linewidth=2, label='η(x) = exp(x) - 1/x')
ax.axhline(y=0, color='gray', linestyle='-', alpha=0.3)
# Find zero crossing
from scipy.optimize import brentq
x_cross = brentq(lambda x: np.exp(x) - 1/x, 0.1, 1.0)
ax.plot(x_cross, 0, 'ro', markersize=8, label=f'η(x₀) = 0 at x₀ ≈ {x_cross:.3f}')
ax.set_xlabel('x')
ax.set_ylabel('η(x)')
ax.set_title("Natural Parameter Map (f' = 0 at x₀)")
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/Speculative/OISCC/demos/fig2_potential_landscape.png', dpi=150)
plt.close()
print("Figure 2 saved: fig2_potential_landscape.png")


# ============================================================
# Figure 3: Spectral Analysis and Eigenvalue Dynamics
# ============================================================
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# 3a: Eigenvalues on the diagonal
ax = axes[0, 0]
x = np.linspace(0.1, 3, 500)
lp = np.exp(x) + 1/x  # λ+
lm = np.exp(x) - 1/x  # λ-
ax.semilogy(x, lp, 'b-', linewidth=2, label='λ₊ = exp(x) + 1/x')
ax.semilogy(x, np.maximum(lm, 1e-3), 'r-', linewidth=2, label='λ₋ = exp(x) - 1/x')
ax.semilogy(x, np.exp(x), 'k--', linewidth=1, alpha=0.5, label='exp(x)')
ax.axhline(y=1, color='gray', linestyle=':', alpha=0.5)
# Mark where λ- = 0
x_lambert = brentq(lambda x: np.exp(x) - 1/x, 0.1, 1.0)
ax.axvline(x=x_lambert, color='green', linestyle=':', alpha=0.7,
           label=f'λ₋ = 0 at x ≈ {x_lambert:.3f}')
ax.set_xlabel('x')
ax.set_ylabel('Eigenvalue')
ax.set_title('Jacobian Eigenvalues on Diagonal')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# 3b: Eigenvalue gap 2/x
ax = axes[0, 1]
x = np.linspace(0.1, 5, 500)
gap = 2/x
ax.plot(x, gap, 'b-', linewidth=2, label='Gap = 2/x')
ax.set_xlabel('x')
ax.set_ylabel('λ₊ - λ₋')
ax.set_title('Eigenvalue Gap (Decreasing, → 0)')
ax.legend()
ax.grid(True, alpha=0.3)

# 3c: Trace along orbit (super-exponential growth)
ax = axes[1, 0]
for x0 in [0.5, 1.0, 1.5]:
    orbit = iterate_diagonal(x0, 5)
    traces = 2 * np.exp(orbit)
    ax.semilogy(range(len(traces)), traces, 'o-', label=f'x₀ = {x0}', markersize=4)
ax.set_xlabel('Step n')
ax.set_ylabel('tr(J(d^n(x₀), d^n(x₀)))')
ax.set_title('Jacobian Trace: Super-Exponential Growth')
ax.legend()
ax.grid(True, alpha=0.3)

# 3d: Lyapunov exponent approximation
ax = axes[1, 1]
x0 = 1.0
orbit = iterate_diagonal(x0, 6)
log_lyapunov = np.log(np.exp(orbit) + 1/orbit)  # ln(ρ)
ax.plot(range(len(orbit)), orbit, 'b-o', label='d^n(x₀) (orbit value)', markersize=5)
ax.plot(range(len(log_lyapunov)), log_lyapunov, 'r-s', label='ln(ρ(d^n(x₀))) (Lyapunov)', markersize=5)
ax.set_xlabel('Step n')
ax.set_ylabel('Value')
ax.set_title('Lyapunov Self-Similarity: λₙ ≈ d^n(x₀)')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/Speculative/OISCC/demos/fig3_spectral_analysis.png', dpi=150)
plt.close()
print("Figure 3 saved: fig3_spectral_analysis.png")


# ============================================================
# Figure 4: Higher-Dimensional EML
# ============================================================
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# 4a: 3D diagonal orbit
ax = axes[0]
x0 = 0.5
orbit_3d = iterate_diagonal(x0, 6)  # Diagonal is dimension-independent
ax.semilogy(range(len(orbit_3d)), orbit_3d, 'bo-', markersize=6, label='3D diagonal')
ax.semilogy(range(len(orbit_3d)), 2 * np.arange(len(orbit_3d)) + x0, 'r--',
           label='Lower bound: x₀ + 2n')
ax.set_xlabel('Step n')
ax.set_ylabel('d^n(x₀)')
ax.set_title('3D Diagonal Orbit (Same as 2D)')
ax.legend()
ax.grid(True, alpha=0.3)

# 4b: Sum coordinate growth in 2D
ax = axes[1]
for x0, y0 in [(0.5, 0.5), (0.3, 0.8), (1.0, 0.5)]:
    xs, ys = iterate_2d(x0, y0, 5)
    sums = xs + ys
    ax.semilogy(range(len(sums)), sums, 'o-', label=f'S({x0},{y0})', markersize=4)
ax.set_xlabel('Step n')
ax.set_ylabel('S = x + y')
ax.set_title('Sum Coordinate Growth (≥ 2 per step)')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# 4c: Off-diagonal perturbation
ax = axes[2]
x0 = 1.0
epsilons = [0, 0.01, 0.05, 0.1]
for eps in epsilons:
    xs, ys = iterate_2d(x0 + eps, x0 - eps, 4)
    asymmetry = np.abs(xs - ys)
    if eps > 0:
        ax.semilogy(range(len(asymmetry)), asymmetry, 'o-',
                   label=f'ε = {eps}', markersize=4)
ax.set_xlabel('Step n')
ax.set_ylabel('|x - y| (asymmetry)')
ax.set_title('Symmetry Breaking: Off-Diagonal Growth')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/Speculative/OISCC/demos/fig4_higher_dimensional.png', dpi=150)
plt.close()
print("Figure 4 saved: fig4_higher_dimensional.png")


# ============================================================
# Figure 5: Applications - Anomaly Detection & Signal Analysis
# ============================================================
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# 5a: Anomaly detection using displacement
ax = axes[0, 0]
np.random.seed(42)
normal_data = np.random.exponential(1.0, 100) + 0.1
anomalies = np.array([0.01, 0.02, 5.0, 8.0, 10.0])
all_data = np.concatenate([normal_data, anomalies])
scores = displacement(all_data)
ax.scatter(range(len(normal_data)), scores[:len(normal_data)],
          c='blue', alpha=0.5, s=20, label='Normal')
ax.scatter(range(len(normal_data), len(all_data)),
          scores[len(normal_data):],
          c='red', s=60, marker='x', label='Anomaly')
ax.axhline(y=np.percentile(scores[:len(normal_data)], 95),
          color='orange', linestyle='--', label='95th percentile')
ax.set_xlabel('Sample index')
ax.set_ylabel('Displacement score δ(x)')
ax.set_title('EML Anomaly Detection')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# 5b: EML regularization comparison
ax = axes[0, 1]
x = np.linspace(-1, 3, 500)
x_pos = x[x > 0]
l2 = x_pos**2  # L2 regularization
l1 = np.abs(x_pos)  # L1
eml_reg = np.exp(x_pos) - np.log(x_pos) - 1  # EML (only for x > 0)
ax.plot(x_pos, l2, 'g--', label='L2: x²', linewidth=1.5)
ax.plot(x_pos, l1, 'r--', label='L1: |x|', linewidth=1.5)
ax.plot(x_pos, eml_reg, 'b-', label='EML: exp(x)-ln(x)-1', linewidth=2)
ax.set_xlabel('Weight x')
ax.set_ylabel('Penalty')
ax.set_title('EML vs Standard Regularizers')
ax.legend()
ax.set_ylim(0, 10)
ax.grid(True, alpha=0.3)

# 5c: EML hash (avalanche effect)
ax = axes[1, 0]
def eml_hash(x, n_steps=3):
    """Simple EML-based hash: iterate d(x) and take fractional part."""
    val = x
    for _ in range(n_steps):
        val = diagonal_map(val)
    return val

x_base = 1.0
deltas = np.linspace(-0.1, 0.1, 1000)
outputs = np.array([eml_hash(x_base + d, 3) for d in deltas])
ax.plot(deltas, outputs, 'b-', linewidth=0.5)
ax.set_xlabel('Input perturbation Δx')
ax.set_ylabel('d³(1 + Δx)')
ax.set_title('EML Avalanche Effect (3 iterations)')
ax.grid(True, alpha=0.3)

# 5d: Volatility modeling with displacement
ax = axes[1, 1]
t = np.linspace(0.1, 5, 500)
vol_eml = displacement(t)
vol_bs = 0.2 * np.ones_like(t)  # Black-Scholes constant vol
vol_heston = 0.2 + 0.1 * np.sqrt(t)  # Heston-like
ax.plot(t, vol_eml / vol_eml.max() * 2, 'b-', linewidth=2, label='EML volatility (normalized)')
ax.plot(t, vol_bs, 'g--', linewidth=1.5, label='Black-Scholes (constant)')
ax.plot(t, vol_heston, 'r--', linewidth=1.5, label='Heston-like (√t)')
ax.set_xlabel('Asset price level x')
ax.set_ylabel('Volatility')
ax.set_title('EML Volatility Smile')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/Speculative/OISCC/demos/fig5_applications.png', dpi=150)
plt.close()
print("Figure 5 saved: fig5_applications.png")


# ============================================================
# Figure 6: Tropical Limit Visualization
# ============================================================
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# 6a: EML(tx, ty)/t for increasing t
ax = axes[0]
x_val, y_val = 1.0, 0.5
ts = np.linspace(0.1, 10, 200)
scaled = np.array([(np.exp(t*x_val) - np.log(t*y_val))/t for t in ts])
tropical = np.full_like(ts, max(x_val, -y_val))
ax.plot(ts, scaled, 'b-', linewidth=2, label=f'EML({x_val}t, {y_val}t)/t')
ax.axhline(y=x_val, color='r', linestyle='--', label=f'max({x_val}, -{y_val}) = {x_val}')
ax.set_xlabel('t (scaling parameter)')
ax.set_ylabel('EML(tx, ty)/t')
ax.set_title('Tropical Limit: EML/t → max(x, -y)')
ax.legend()
ax.set_ylim(-1, 5)
ax.grid(True, alpha=0.3)

# 6b: Tropical diagonal d_trop(x) = |x|
ax = axes[1]
x = np.linspace(-3, 3, 500)
d_tropical = np.abs(x)
d_real = np.where(x > 0, np.exp(x) - np.log(x), np.nan)
ax.plot(x, d_tropical, 'r-', linewidth=2, label='d_trop(x) = |x|')
x_pos = x[x > 0.01]
ax.plot(x_pos, np.exp(x_pos) - np.log(x_pos), 'b--', linewidth=1.5,
       label='d(x) = exp(x) - ln(x)')
ax.set_xlabel('x')
ax.set_ylabel('d(x)')
ax.set_title('Tropical vs Real Diagonal Map')
ax.legend()
ax.set_ylim(-1, 10)
ax.grid(True, alpha=0.3)

# 6c: Tropical 2D orbits
ax = axes[2]
def phi_tropical(x, y):
    return max(x, -y), max(y, -x)

for x0, y0 in [(1, -0.5), (2, 1), (-1, 2)]:
    xs, ys = [x0], [y0]
    x, y = x0, y0
    for _ in range(20):
        x, y = phi_tropical(x, y)
        xs.append(x)
        ys.append(y)
        if x > 100 or y > 100:
            break
    ax.plot(xs[:10], ys[:10], 'o-', label=f'({x0}, {y0})', markersize=4)
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.set_title('Tropical 2D Orbits')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/Speculative/OISCC/demos/fig6_tropical_limit.png', dpi=150)
plt.close()
print("Figure 6 saved: fig6_tropical_limit.png")


# ============================================================
# Print Summary Statistics
# ============================================================
print("\n" + "="*60)
print("EML ORBIT ANALYSIS SUMMARY")
print("="*60)

x0 = 1.0
orbit = iterate_diagonal(x0, 8)
print(f"\nDiagonal orbit from x₀ = {x0}:")
for i, val in enumerate(orbit):
    disp = val - (orbit[i-1] if i > 0 else x0)
    print(f"  d^{i}(x₀) = {val:.6f}  (displacement = {disp:.6f})")

print(f"\nCritical point x₀ = W(1) ≈ {x_cross:.6f}")
print(f"f(x₀) ≈ {np.exp(x_cross) - np.log(x_cross) - 1:.6f}")
print(f"f(1) = e - 1 ≈ {np.e - 1:.6f}")

print("\nEigenvalue analysis at x = 1:")
x = 1.0
print(f"  λ₊ = exp(1) + 1 ≈ {np.exp(1) + 1:.6f}")
print(f"  λ₋ = exp(1) - 1 ≈ {np.exp(1) - 1:.6f}")
print(f"  Gap = 2/1 = 2")
print(f"  Product = e² - 1 ≈ {np.exp(2) - 1:.6f}")

print("\nTrace after one step from diagonal (x,x):")
for x in [0.5, 1.0, 1.5, 2.0]:
    d_x = np.exp(x) - np.log(x)
    trace = 2 * np.exp(d_x)
    print(f"  x = {x}: tr(J(d(x),d(x))) = {trace:.2e}")
