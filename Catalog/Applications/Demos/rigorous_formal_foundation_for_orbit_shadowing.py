#!/usr/bin/env python3
"""
Orbit Shadowing: Numerical Demonstrations

Demonstrates the key results:
1. Contractive shadowing with δ/(1-L) bound
2. Structural stability under map perturbation
3. Gradient descent shadowing (SGD vs exact GD)
4. Tightness of the optimal shadowing radius
5. Exponential error decay to fixed point
"""

import numpy as np
from typing import Callable, Tuple, List


def true_orbit(f: Callable[[float], float], x0: float, n: int) -> np.ndarray:
    """Compute the true orbit of f starting at x0 for n steps."""
    orbit = np.zeros(n + 1)
    orbit[0] = x0
    for i in range(n):
        orbit[i + 1] = f(orbit[i])
    return orbit


def pseudo_orbit(f: Callable[[float], float], x0: float, n: int,
                 delta: float, rng: np.random.Generator) -> np.ndarray:
    """Compute a δ-pseudo-orbit: each step adds noise bounded by δ."""
    orbit = np.zeros(n + 1)
    orbit[0] = x0
    for i in range(n):
        noise = rng.uniform(-delta, delta)
        orbit[i + 1] = f(orbit[i]) + noise
    return orbit


def shadowing_defect(y: np.ndarray, x: np.ndarray) -> float:
    """Compute the maximum pointwise distance (shadowing defect)."""
    return np.max(np.abs(y - x))


def demo_contractive_shadowing():
    """Demo 1: Contractive shadowing with δ/(1-L) bound."""
    print("=" * 60)
    print("DEMO 1: Contractive Shadowing Lemma")
    print("=" * 60)

    L = 0.5  # Lipschitz constant
    delta = 0.1  # Per-step error
    n = 100
    rng = np.random.default_rng(42)

    f = lambda x: L * x  # Linear contraction
    x0 = 1.0

    # Compute pseudo-orbit and true orbit
    px = pseudo_orbit(f, x0, n, delta, rng)
    tx = true_orbit(f, px[0], n)  # Shadow starting at same point

    theoretical_bound = delta / (1 - L)
    actual_defect = shadowing_defect(tx, px)

    print(f"  Contraction factor L = {L}")
    print(f"  Per-step error δ = {delta}")
    print(f"  Steps = {n}")
    print(f"  Theoretical bound δ/(1-L) = {theoretical_bound:.4f}")
    print(f"  Actual shadowing defect = {actual_defect:.4f}")
    print(f"  Bound holds: {actual_defect <= theoretical_bound + 1e-10}")
    print()


def demo_structural_stability():
    """Demo 2: Structural stability under map perturbation."""
    print("=" * 60)
    print("DEMO 2: Structural Stability of Shadowing")
    print("=" * 60)

    L = 0.4
    rho = 0.05  # Map perturbation
    delta = 0.08  # Pseudo-orbit error
    n = 200
    rng = np.random.default_rng(123)

    f = lambda x: L * x  # True map (contraction)
    g = lambda x: L * x + rho * np.sin(x)  # Perturbed map (ρ-close to f)

    # Pseudo-orbit of g
    px = pseudo_orbit(g, 1.0, n, delta, rng)
    # True orbit of f starting at same point
    tx = true_orbit(f, px[0], n)

    structural_bound = (delta + rho) / (1 - L)
    actual_defect = shadowing_defect(tx, px)

    print(f"  True map: f(x) = {L}x")
    print(f"  Perturbed map: g(x) = {L}x + {rho}sin(x)")
    print(f"  Map perturbation ρ = {rho}")
    print(f"  Pseudo-orbit error δ = {delta}")
    print(f"  Structural bound (δ+ρ)/(1-L) = {structural_bound:.4f}")
    print(f"  Actual shadowing defect = {actual_defect:.4f}")
    print(f"  Bound holds: {actual_defect <= structural_bound + 1e-10}")
    print()


def demo_gradient_descent_shadowing():
    """Demo 3: SGD as pseudo-orbit of exact GD."""
    print("=" * 60)
    print("DEMO 3: Gradient Descent Shadowing (SGD vs GD)")
    print("=" * 60)

    # Strongly convex quadratic: f(x) = (mu/2)x^2
    mu = 2.0  # Strong convexity
    M = 2.0   # Smoothness (= mu for quadratic)
    eta = 1.0 / M  # Step size
    L_contract = 1 - eta * mu  # = 0 for this case
    # Use a less trivial example
    mu, M = 1.0, 5.0
    eta = 2.0 / (mu + M)
    L_contract = (M - mu) / (M + mu)  # Contraction constant

    n = 50
    sigma = 0.3  # SGD noise bound
    rng = np.random.default_rng(7)

    # GD step: x - eta * mu * x = (1 - eta*mu) * x
    gd_step = lambda x: x - eta * mu * x  # For quadratic f(x) = (mu/2)x^2

    # SGD: GD + bounded noise
    x0 = 5.0
    sgd_traj = np.zeros(n + 1)
    sgd_traj[0] = x0
    for i in range(n):
        noise = rng.uniform(-sigma, sigma)
        sgd_traj[i + 1] = gd_step(sgd_traj[i]) + noise

    # Exact GD from same starting point
    gd_traj = true_orbit(gd_step, x0, n)

    theoretical_bound = sigma / (1 - L_contract) if L_contract < 1 else float('inf')
    actual_defect = shadowing_defect(gd_traj, sgd_traj)

    print(f"  Strong convexity μ = {mu}, Smoothness M = {M}")
    print(f"  Step size η = {eta:.4f}")
    print(f"  Contraction constant L = {L_contract:.4f}")
    print(f"  SGD noise bound σ = {sigma}")
    print(f"  Theoretical bound σ/(1-L) = {theoretical_bound:.4f}")
    print(f"  Actual SGD-GD defect = {actual_defect:.4f}")
    print(f"  Bound holds: {actual_defect <= theoretical_bound + 1e-10}")
    print(f"  GD converges to: {gd_traj[-1]:.6f}")
    print(f"  SGD final point: {sgd_traj[-1]:.6f}")
    print()


def demo_tightness():
    """Demo 4: Tightness of δ/(1-L) bound."""
    print("=" * 60)
    print("DEMO 4: Tightness of Optimal Shadowing Radius")
    print("=" * 60)

    L = 0.5
    delta = 1.0

    # Optimal pseudo-orbit: x(n) = δ * Σ_{i<n} L^i = δ(1-L^n)/(1-L)
    for n_steps in [10, 50, 100, 500, 1000]:
        x_n = delta * (1 - L**n_steps) / (1 - L)
        optimal_radius = delta / (1 - L)
        gap = optimal_radius - x_n

        print(f"  n={n_steps:4d}: dist = {x_n:.8f}, "
              f"bound = {optimal_radius:.4f}, gap = {gap:.2e}")

    print(f"\n  The bound δ/(1-L) = {delta/(1-L):.4f} is achieved in the limit.")
    print()


def demo_fixed_point_convergence():
    """Demo 5: Shadow convergence to fixed point."""
    print("=" * 60)
    print("DEMO 5: Shadow Convergence to Fixed Point")
    print("=" * 60)

    L = 0.7
    delta = 0.1
    x0 = 10.0
    n = 50
    rng = np.random.default_rng(99)

    f = lambda x: L * x  # Fixed point at 0
    fix = 0.0

    px = pseudo_orbit(f, x0, n, delta, rng)
    tx = true_orbit(f, px[0], n)

    print(f"  f(x) = {L}x, fixed point = {fix}")
    print(f"  x0 = {x0}, δ = {delta}")
    print(f"  Noise floor δ/(1-L) = {delta/(1-L):.4f}")
    print()
    print(f"  {'Step':>6s}  {'dist(orbit,fix)':>16s}  {'L^n*d(x0,fix)+δ/(1-L)':>24s}  {'Holds':>6s}")
    print(f"  {'-'*6}  {'-'*16}  {'-'*24}  {'-'*6}")

    for step in [0, 5, 10, 20, 30, 40, 50]:
        actual = abs(tx[step] - fix)
        bound = L**step * abs(x0 - fix) + delta / (1 - L)
        print(f"  {step:6d}  {actual:16.8f}  {bound:24.8f}  {actual <= bound + 1e-10!s:>6s}")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  ORBIT SHADOWING: NUMERICAL DEMONSTRATIONS")
    print("=" * 60 + "\n")

    demo_contractive_shadowing()
    demo_structural_stability()
    demo_gradient_descent_shadowing()
    demo_tightness()
    demo_fixed_point_convergence()

    print("All demonstrations complete.")


#!/usr/bin/env python3
"""Visualization: SGD as Shadowed Pseudo-Orbit of Exact GD."""
import numpy as np
import matplotlib.pyplot as plt

mu, M = 1.0, 5.0
eta = 2.0 / (mu + M)
L = (M - mu) / (M + mu)
sigma = 0.5
n = 60
x0 = 8.0
rng = np.random.default_rng(7)

gd_step = lambda x: x - eta * mu * x

# SGD trajectory
sgd = np.zeros(n + 1)
sgd[0] = x0
for i in range(n):
    sgd[i + 1] = gd_step(sgd[i]) + rng.uniform(-sigma, sigma)

# Exact GD from same start
gd = np.zeros(n + 1)
gd[0] = x0
for i in range(n):
    gd[i + 1] = gd_step(gd[i])

bound = sigma / (1 - L)
steps = np.arange(n + 1)

fig, axes = plt.subplots(2, 2, figsize=(12, 9))

# Top left: trajectories
ax = axes[0, 0]
ax.plot(steps, sgd, 'r-', alpha=0.7, linewidth=1.5, label='SGD (noisy)')
ax.plot(steps, gd, 'b-', linewidth=2, label='Exact GD (shadow)')
ax.fill_between(steps, gd - bound, gd + bound, alpha=0.12, color='blue',
                label=f'σ/(1-L) = {bound:.2f} band')
ax.set_xlabel('Step')
ax.set_ylabel('x')
ax.set_title(f'SGD vs Exact GD: μ={mu}, M={M}, L={L:.2f}')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Top right: tracking error
ax = axes[0, 1]
dists = np.abs(gd - sgd)
ax.plot(steps, dists, 'k-', linewidth=1.5)
ax.axhline(y=bound, color='red', linestyle='--', linewidth=2,
           label=f'σ/(1-L) = {bound:.2f}')
ax.set_xlabel('Step')
ax.set_ylabel('|GD - SGD|')
ax.set_title('Tracking Error')
ax.legend()
ax.grid(True, alpha=0.3)

# Bottom left: convergence to fixed point
ax = axes[1, 0]
fix = 0.0
gd_dist = np.abs(gd - fix)
combined_bound = np.array([L**k * abs(x0 - fix) + bound for k in range(n + 1)])
ax.semilogy(steps, gd_dist + 1e-16, 'b-', linewidth=2, label='dist(GD, fix)')
ax.semilogy(steps, combined_bound, 'r--', linewidth=2, label='L^n·d₀ + σ/(1-L)')
ax.axhline(y=bound, color='green', linestyle=':', linewidth=1.5,
           label=f'Noise floor = {bound:.2f}')
ax.set_xlabel('Step')
ax.set_ylabel('Distance to fixed point')
ax.set_title('Exponential Convergence to Fixed Point')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Bottom right: L sweep
ax = axes[1, 1]
Ls = np.linspace(0.01, 0.99, 100)
radii = sigma / (1 - Ls)
ax.plot(Ls, radii, 'b-', linewidth=2)
ax.axvline(x=L, color='red', linestyle='--', alpha=0.7,
           label=f'L={L:.2f}, ε={bound:.2f}')
ax.set_xlabel('Contraction constant L')
ax.set_ylabel('Shadowing radius σ/(1-L)')
ax.set_title('Shadowing Radius vs Contraction Strength')
ax.legend()
ax.grid(True, alpha=0.3)
ax.set_ylim(0, 10)

plt.tight_layout()
plt.savefig('sgd_shadowing.png', dpi=150, bbox_inches='tight')
plt.show()
print("Saved sgd_shadowing.png")


#!/usr/bin/env python3
"""Visualization: Contractive Shadowing with δ/(1-L) bound."""
import numpy as np
import matplotlib.pyplot as plt

def true_orbit(f, x0, n):
    orbit = np.zeros(n + 1)
    orbit[0] = x0
    for i in range(n):
        orbit[i + 1] = f(orbit[i])
    return orbit

def pseudo_orbit(f, x0, n, delta, rng):
    orbit = np.zeros(n + 1)
    orbit[0] = x0
    for i in range(n):
        orbit[i + 1] = f(orbit[i]) + rng.uniform(-delta, delta)
    return orbit

L = 0.6
delta = 0.3
n = 80
rng = np.random.default_rng(42)
f = lambda x: L * x

px = pseudo_orbit(f, 3.0, n, delta, rng)
tx = true_orbit(f, px[0], n)
bound = delta / (1 - L)

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8))

steps = np.arange(n + 1)
ax1.plot(steps, px, 'r-', alpha=0.7, linewidth=1.5, label='Pseudo-orbit (noisy)')
ax1.plot(steps, tx, 'b-', linewidth=2, label='Shadow (true orbit)')
ax1.fill_between(steps, tx - bound, tx + bound, alpha=0.15, color='blue',
                  label=f'δ/(1-L) = {bound:.2f} band')
ax1.set_xlabel('Step n')
ax1.set_ylabel('x(n)')
ax1.set_title(f'Contractive Shadowing: L={L}, δ={delta}')
ax1.legend()
ax1.grid(True, alpha=0.3)

dists = np.abs(tx - px)
ax2.plot(steps, dists, 'k-', linewidth=1.5, label='|shadow(n) - pseudo(n)|')
ax2.axhline(y=bound, color='red', linestyle='--', linewidth=2,
            label=f'δ/(1-L) = {bound:.2f}')
ax2.set_xlabel('Step n')
ax2.set_ylabel('Distance')
ax2.set_title('Shadowing Distance vs Theoretical Bound')
ax2.legend()
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('shadowing_demo.png', dpi=150, bbox_inches='tight')
plt.show()
print("Saved shadowing_demo.png")


#!/usr/bin/env python3
"""Visualization: Tightness of the δ/(1-L) Shadowing Bound."""
import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Left: optimal pseudo-orbit convergence for different L
ax = axes[0]
delta = 1.0
for L in [0.3, 0.5, 0.7, 0.9]:
    n = 200
    steps = np.arange(n + 1)
    # Optimal pseudo-orbit distance: δ(1-L^n)/(1-L)
    dists = delta * (1 - L**steps) / (1 - L)
    optimal = delta / (1 - L)
    ax.plot(steps, dists, linewidth=2, label=f'L={L}, δ/(1-L)={optimal:.2f}')
    ax.axhline(y=optimal, linestyle=':', alpha=0.4)

ax.set_xlabel('Step n')
ax.set_ylabel('dist(orbit(n), pseudo(n))')
ax.set_title('Convergence to Optimal Bound')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Middle: gap from optimal vs L
ax = axes[1]
ns = [10, 25, 50, 100]
Ls = np.linspace(0.01, 0.98, 200)
for n in ns:
    gaps = Ls**n / (1 - Ls)  # gap = L^n * δ/(1-L), normalized by δ
    ax.semilogy(Ls, gaps, linewidth=2, label=f'n={n}')

ax.set_xlabel('Contraction constant L')
ax.set_ylabel('Gap from optimal (× δ)')
ax.set_title('How Fast the Bound Tightens')
ax.legend()
ax.grid(True, alpha=0.3)
ax.set_ylim(1e-10, 100)

# Right: δ/(1-L) surface
ax = axes[2]
deltas = np.linspace(0.01, 1.0, 50)
Ls_grid = np.linspace(0.01, 0.95, 50)
D, LL = np.meshgrid(deltas, Ls_grid)
radii = D / (1 - LL)
c = ax.pcolormesh(D, LL, radii, cmap='viridis', shading='auto', vmax=5)
ax.set_xlabel('δ (per-step error)')
ax.set_ylabel('L (contraction constant)')
ax.set_title('Shadowing Radius δ/(1-L)')
plt.colorbar(c, ax=ax, label='ε')
ax.contour(D, LL, radii, levels=[0.5, 1, 2, 3, 5], colors='white', linewidths=0.8)

plt.tight_layout()
plt.savefig('tightness.png', dpi=150, bbox_inches='tight')
plt.show()
print("Saved tightness.png")
