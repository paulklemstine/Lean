#!/usr/bin/env python3
"""
Orbit Shadowing Demo

Demonstrates the contractive shadowing lemma, shadowing certificates,
and expansive uniqueness with numerical examples.
"""

import random
import math
from algorithms import (
    is_pseudo_orbit,
    compute_true_orbit,
    shadowing_certificate,
    shadowing_defect,
    generate_pseudo_orbit,
    contraction_convergence_rate,
)

random.seed(42)


def demo_contractive_shadowing():
    """Demonstrate the contractive shadowing lemma with various contraction rates."""
    print("=" * 70)
    print("DEMO 1: Contractive Shadowing Lemma")
    print("=" * 70)
    print()
    print("For f(x) = L·x with L < 1, every δ-pseudo-orbit is shadowed")
    print("by a true orbit within distance δ/(1-L).")
    print()

    for L in [0.1, 0.3, 0.5, 0.7, 0.9]:
        f = lambda x, L=L: L * x
        delta = 0.05
        pseudo, actual_delta = generate_pseudo_orbit(f, 1.0, 50, delta)

        shadow = compute_true_orbit(f, pseudo[0], len(pseudo))
        max_err = shadowing_defect(shadow, pseudo)
        bound = actual_delta / (1 - L)

        print(f"  L = {L:.1f}: δ = {actual_delta:.4f}, "
              f"bound δ/(1-L) = {bound:.4f}, "
              f"actual max error = {max_err:.4f}, "
              f"ratio = {max_err/bound:.3f}")

    print()


def demo_shadowing_certificate():
    """Demonstrate shadowing certificate construction and verification."""
    print("=" * 70)
    print("DEMO 2: Shadowing Certificate Construction")
    print("=" * 70)
    print()

    L = 0.6
    f = lambda x: L * x
    delta = 0.1

    pseudo, actual_delta = generate_pseudo_orbit(f, 2.0, 30, delta)
    cert = shadowing_certificate(f, pseudo, L, actual_delta)

    print(f"  Map: f(x) = {L}·x")
    print(f"  Pseudo-orbit length: {cert['length']}")
    print(f"  Per-step error δ: {cert['delta']:.6f}")
    print(f"  Shadowing bound ε = δ/(1-L): {cert['epsilon']:.6f}")
    print(f"  Actual max error: {cert['actual_max_error']:.6f}")
    print(f"  Certificate valid: {cert['bound_satisfied']}")
    print()

    # Show convergence over time
    print("  Step-by-step shadowing distances:")
    for n in [0, 5, 10, 15, 20, 25, 29]:
        dist = abs(cert['shadow'][n] - cert['pseudo'][n])
        print(f"    n={n:3d}: |shadow - pseudo| = {dist:.6f}")
    print()


def demo_exponential_convergence():
    """Demonstrate exponential convergence of orbits under contraction."""
    print("=" * 70)
    print("DEMO 3: Exponential Convergence Under Contraction")
    print("=" * 70)
    print()

    L = 0.7
    f = lambda x: L * x
    x0, y0 = 1.0, 3.0

    print(f"  Map: f(x) = {L}·x, starting points: x = {x0}, y = {y0}")
    print(f"  Lipschitz constant L = {L}")
    print(f"  Theoretical bound: dist(f^n(x), f^n(y)) ≤ L^n · dist(x,y)")
    print()

    results = contraction_convergence_rate(f, L, x0, y0, 15)
    for n, actual, bound in results:
        ratio = actual / bound if bound > 1e-15 else 0
        print(f"    n={n:3d}: actual dist = {actual:.8f}, "
              f"bound = {bound:.8f}, ratio = {ratio:.4f}")
    print()


def demo_pseudo_orbit_perturbation():
    """Demonstrate pseudo-orbit perturbation stability."""
    print("=" * 70)
    print("DEMO 4: Pseudo-Orbit Perturbation Stability")
    print("=" * 70)
    print()

    L = 0.5
    f = lambda x: L * x
    delta = 0.05

    # Create a pseudo-orbit
    pseudo, actual_delta = generate_pseudo_orbit(f, 1.0, 20, delta)

    # Verify it's a pseudo-orbit
    assert is_pseudo_orbit(f, pseudo, actual_delta + 1e-10)
    print(f"  Original: {actual_delta:.6f}-pseudo-orbit of f(x) = {L}·x")

    # Perturb it
    for r in [0.01, 0.05, 0.1]:
        perturbed = [p + random.uniform(-r, r) for p in pseudo]
        new_delta = actual_delta + 2 * r

        # Check it's still a pseudo-orbit with larger δ
        valid = is_pseudo_orbit(f, perturbed, new_delta + 1e-10)
        actual_errors = [abs(f(perturbed[n]) - perturbed[n + 1])
                         for n in range(len(perturbed) - 1)]
        max_err = max(actual_errors)

        print(f"  Perturbation r = {r:.2f}: "
              f"new bound δ+2r = {new_delta:.4f}, "
              f"actual max error = {max_err:.4f}, "
              f"valid = {valid}")

    print()


def demo_multiple_maps():
    """Compare shadowing behavior across different contraction types."""
    print("=" * 70)
    print("DEMO 5: Shadowing Across Different Contractions")
    print("=" * 70)
    print()

    maps = [
        ("Linear: f(x) = 0.5x", lambda x: 0.5 * x, 0.5),
        ("Quadratic: f(x) = 0.3x²", lambda x: 0.3 * x * x, 0.6),  # L ≈ 0.6 near x=1
        ("Trig: f(x) = 0.4·sin(x)", lambda x: 0.4 * math.sin(x), 0.4),
        ("Logistic: f(x) = 0.8x(1-x)", lambda x: 0.8 * x * (1 - x), 0.8),  # near fixed point
    ]

    delta = 0.03
    for name, f, L in maps:
        pseudo, actual_delta = generate_pseudo_orbit(f, 0.5, 30, delta)
        shadow = compute_true_orbit(f, pseudo[0], len(pseudo))
        max_err = shadowing_defect(shadow, pseudo)
        bound = actual_delta / (1 - L) if L < 1 else float('inf')

        print(f"  {name}")
        print(f"    L = {L}, δ = {actual_delta:.4f}, "
              f"bound = {bound:.4f}, actual = {max_err:.4f}")

    print()


def demo_geometric_series_bound():
    """Show how partial geometric sums approach the infinite series bound."""
    print("=" * 70)
    print("DEMO 6: Geometric Series Convergence in Shadowing Bound")
    print("=" * 70)
    print()

    L = 0.7
    print(f"  For L = {L}, 1/(1-L) = {1/(1-L):.6f}")
    print(f"  Partial sums Σ_{'{i=0}'}^{'{n-1}'} L^i approach this limit:")
    print()

    for n in [1, 2, 5, 10, 20, 50, 100]:
        partial = sum(L ** i for i in range(n))
        ratio = partial / (1 / (1 - L))
        print(f"    n = {n:4d}: Σ L^i = {partial:.8f}, "
              f"ratio to limit = {ratio:.8f}")
    print()


if __name__ == "__main__":
    demo_contractive_shadowing()
    demo_shadowing_certificate()
    demo_exponential_convergence()
    demo_pseudo_orbit_perturbation()
    demo_multiple_maps()
    demo_geometric_series_bound()

    print("=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Exponential Convergence Under Contraction

Shows how orbits of a contraction map converge exponentially,
comparing actual convergence to the theoretical L^n bound.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def compute_orbit(f, x0, steps):
    orbit = [x0]
    for _ in range(steps):
        orbit.append(f(orbit[-1]))
    return orbit


fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left: convergence for different L values
ax1 = axes[0]
x0, y0 = 1.0, 3.0
steps = 25

for L, color in [(0.3, 'blue'), (0.5, 'green'), (0.7, 'orange'), (0.9, 'red')]:
    f = lambda x, L=L: L * x
    ox = compute_orbit(f, x0, steps)
    oy = compute_orbit(f, y0, steps)
    dists = [abs(ox[n] - oy[n]) for n in range(steps + 1)]
    bounds = [L ** n * abs(x0 - y0) for n in range(steps + 1)]

    ax1.semilogy(range(steps + 1), dists, f'{color[0]}o-', markersize=3,
                 label=f'L={L} (actual)', alpha=0.7)
    ax1.semilogy(range(steps + 1), bounds, f'--', color=color,
                 alpha=0.4, linewidth=2)

ax1.set_xlabel('Iteration n', fontsize=12)
ax1.set_ylabel('dist(f^n(x), f^n(y))', fontsize=12)
ax1.set_title('Exponential Convergence: dist ≤ L^n · d₀', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Right: shadowing bound δ/(1-L) vs L
ax2 = axes[1]
L_vals = np.linspace(0.01, 0.99, 200)
delta = 0.1

bounds = delta / (1 - L_vals)
ax2.plot(L_vals, bounds, 'b-', linewidth=2)
ax2.fill_between(L_vals, 0, bounds, alpha=0.1, color='blue')
ax2.set_xlabel('Lipschitz constant L', fontsize=12)
ax2.set_ylabel('Shadowing bound δ/(1-L)', fontsize=12)
ax2.set_title(f'Shadowing Radius vs Contraction Rate (δ = {delta})', fontsize=13)
ax2.set_ylim(0, 2)
ax2.axhline(y=delta, color='red', linestyle=':', label=f'δ = {delta}')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('convergence_visualization.png', dpi=150, bbox_inches='tight')
print("Saved convergence_visualization.png")


#!/usr/bin/env python3
"""
Visualization: Shadowing Defect and Geometric Series Convergence

Shows how the shadowing defect evolves over time and how partial
geometric sums converge to the infinite series bound.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

np.random.seed(123)

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left: Shadowing defect over time for different L values
ax1 = axes[0]
N = 50
delta = 0.1

for L, color in [(0.3, 'blue'), (0.5, 'green'), (0.7, 'orange'), (0.9, 'red')]:
    f = lambda x, L=L: L * x

    # Generate pseudo-orbit
    pseudo = [1.0]
    for _ in range(N - 1):
        pseudo.append(f(pseudo[-1]) + np.random.uniform(-delta, delta))

    # Compute shadow
    shadow = [pseudo[0]]
    for _ in range(N - 1):
        shadow.append(f(shadow[-1]))

    # Running max defect
    dists = [abs(shadow[n] - pseudo[n]) for n in range(N)]
    running_max = np.maximum.accumulate(dists)

    bound = delta / (1 - L)
    ax1.plot(range(N), running_max, color=color, linewidth=1.5,
             label=f'L={L}, bound={bound:.2f}')
    ax1.axhline(y=bound, color=color, linestyle='--', alpha=0.4)

ax1.set_xlabel('Step n', fontsize=12)
ax1.set_ylabel('Shadowing Defect D(n)', fontsize=12)
ax1.set_title(f'Running Maximum Defect (δ = {delta})', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Right: Partial geometric sum convergence
ax2 = axes[1]
max_n = 30

for L, color in [(0.3, 'blue'), (0.5, 'green'), (0.7, 'orange'), (0.9, 'red')]:
    limit = 1 / (1 - L)
    partials = [sum(L ** i for i in range(n)) for n in range(1, max_n + 1)]
    ratios = [p / limit for p in partials]

    ax2.plot(range(1, max_n + 1), ratios, color=color, linewidth=2,
             marker='o', markersize=2, label=f'L={L}')

ax2.axhline(y=1.0, color='black', linestyle='--', alpha=0.5, label='Limit = 1')
ax2.set_xlabel('Number of terms n', fontsize=12)
ax2.set_ylabel('Σᵢ Lⁱ / (1/(1-L))', fontsize=12)
ax2.set_title('Geometric Series: Partial Sum / Infinite Sum', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, 1.1)

plt.tight_layout()
plt.savefig('defect_visualization.png', dpi=150, bbox_inches='tight')
print("Saved defect_visualization.png")


#!/usr/bin/env python3
"""
Visualization: Pseudo-orbit vs True Orbit Shadowing

Shows how a noisy pseudo-orbit is shadowed by a genuine orbit,
with the shadowing bound δ/(1-L) visualized as a band.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random

random.seed(42)
np.random.seed(42)


def generate_pseudo_orbit(f, x0, length, delta):
    pseudo = [x0]
    for _ in range(length - 1):
        noise = np.random.uniform(-delta, delta)
        pseudo.append(f(pseudo[-1]) + noise)
    return pseudo


def compute_true_orbit(f, x0, length):
    orbit = [x0]
    for _ in range(length - 1):
        orbit.append(f(orbit[-1]))
    return orbit


# Parameters
L = 0.6
f = lambda x: L * x
delta = 0.15
N = 40

# Generate pseudo-orbit and true orbit
pseudo = generate_pseudo_orbit(f, 2.0, N, delta)
shadow = compute_true_orbit(f, pseudo[0], N)
epsilon = delta / (1 - L)

# Compute distances
dists = [abs(s - p) for s, p in zip(shadow, pseudo)]

fig, axes = plt.subplots(2, 1, figsize=(12, 8))

# Plot 1: Orbits with shadowing band
ax1 = axes[0]
steps = range(N)
ax1.fill_between(steps, [s - epsilon for s in shadow], [s + epsilon for s in shadow],
                 alpha=0.15, color='blue', label=f'Shadowing band ε = δ/(1-L) = {epsilon:.3f}')
ax1.plot(steps, pseudo, 'ro-', markersize=3, linewidth=0.8, label='Pseudo-orbit (numerical)', alpha=0.8)
ax1.plot(steps, shadow, 'b-', linewidth=2, label='True orbit (shadow)', alpha=0.9)
ax1.set_xlabel('Step n', fontsize=12)
ax1.set_ylabel('x_n', fontsize=12)
ax1.set_title(f'Contractive Shadowing: f(x) = {L}x, δ = {delta}, L = {L}', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Plot 2: Distance between shadow and pseudo-orbit
ax2 = axes[1]
ax2.bar(steps, dists, color='steelblue', alpha=0.7, label='|shadow_n - pseudo_n|')
ax2.axhline(y=epsilon, color='red', linestyle='--', linewidth=2,
            label=f'Bound δ/(1-L) = {epsilon:.3f}')
ax2.set_xlabel('Step n', fontsize=12)
ax2.set_ylabel('Distance', fontsize=12)
ax2.set_title('Shadowing Distance vs Theoretical Bound', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('shadowing_visualization.png', dpi=150, bbox_inches='tight')
print("Saved shadowing_visualization.png")
