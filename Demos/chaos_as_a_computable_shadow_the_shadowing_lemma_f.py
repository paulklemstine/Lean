#!/usr/bin/env python3
"""
Shadowing Lemma Demonstration
==============================
Demonstrates orbit shadowing for the logistic map f(x) = 4x(1-x).
Shows that floating-point trajectories are pseudo-orbits that shadow true orbits.
"""

import struct


def logistic(x: float, r: float = 4.0) -> float:
    """The logistic map f(x) = r*x*(1-x)."""
    return r * x * (1.0 - x)


def compute_pseudo_orbit(x0: float, n_steps: int, r: float = 4.0) -> list[float]:
    """Compute a floating-point trajectory (pseudo-orbit) of the logistic map."""
    orbit = [x0]
    x = x0
    for _ in range(n_steps):
        x = logistic(x, r)
        orbit.append(x)
    return orbit


def pseudo_orbit_errors(orbit: list[float], r: float = 4.0) -> list[float]:
    """Compute the pseudo-orbit errors: |x_{n+1} - f(x_n)| for each step."""
    errors = []
    for i in range(len(orbit) - 1):
        true_next = logistic(orbit[i], r)
        error = abs(orbit[i + 1] - true_next)
        errors.append(error)
    return errors


def find_shadowing_orbit(
    pseudo: list[float], r: float = 4.0, tol: float = 1e-12, max_iter: int = 100
) -> tuple[float, list[float]]:
    """
    Use binary search to find an initial condition y0 such that
    the true orbit of y0 shadows the pseudo-orbit.
    Returns (y0, shadowing_orbit).
    """
    n = len(pseudo) - 1

    def shadowing_distance(y0: float) -> float:
        y = y0
        max_dist = 0.0
        for i in range(n + 1):
            max_dist = max(max_dist, abs(pseudo[i] - y))
            if i < n:
                y = logistic(y, r)
        return max_dist

    # Search around the initial condition
    best_y0 = pseudo[0]
    best_dist = shadowing_distance(best_y0)

    # Grid search first
    for offset in range(-1000, 1001):
        y0_candidate = pseudo[0] + offset * 1e-14
        if 0 < y0_candidate < 1:
            d = shadowing_distance(y0_candidate)
            if d < best_dist:
                best_dist = d
                best_y0 = y0_candidate

    # Compute the shadowing orbit
    shadow = [best_y0]
    y = best_y0
    for _ in range(n):
        y = logistic(y, r)
        shadow.append(y)

    return best_y0, shadow


def contractive_shadowing_demo():
    """Demonstrate shadowing for a contractive map f(x) = L*x + c."""
    print("=" * 60)
    print("CONTRACTIVE SHADOWING DEMO")
    print("=" * 60)

    L = 0.5  # contraction ratio
    c = 0.3  # offset

    def f(x: float) -> float:
        return L * x + c

    # Create a pseudo-orbit with controlled errors
    delta = 1e-6
    import random
    random.seed(42)

    x = [0.5]
    for i in range(20):
        true_next = f(x[-1])
        error = random.uniform(-delta, delta)
        x.append(true_next + error)

    # Compute true orbit from same start
    y = [x[0]]
    for i in range(20):
        y.append(f(y[-1]))

    # Check shadowing bound
    theoretical_bound = delta / (1 - L)
    max_shadow_dist = max(abs(x[i] - y[i]) for i in range(21))

    print(f"Contraction ratio L = {L}")
    print(f"Pseudo-orbit error delta = {delta:.2e}")
    print(f"Theoretical shadowing bound delta/(1-L) = {theoretical_bound:.2e}")
    print(f"Actual max shadowing distance = {max_shadow_dist:.2e}")
    print(f"Bound satisfied: {max_shadow_dist <= theoretical_bound}")
    print()


def logistic_shadowing_demo():
    """Demonstrate shadowing for the logistic map at r=4."""
    print("=" * 60)
    print("LOGISTIC MAP SHADOWING DEMO")
    print("=" * 60)

    x0 = 0.1
    n_steps = 1000

    # Compute pseudo-orbit
    pseudo = compute_pseudo_orbit(x0, n_steps)

    # Compute pseudo-orbit errors
    errors = pseudo_orbit_errors(pseudo)
    max_error = max(errors)
    mean_error = sum(errors) / len(errors)

    print(f"Initial condition: x0 = {x0}")
    print(f"Number of steps: {n_steps}")
    print(f"Max pseudo-orbit error (delta): {max_error:.2e}")
    print(f"Mean pseudo-orbit error: {mean_error:.2e}")
    print(f"Machine epsilon: {2.220446049250313e-16:.2e}")
    print()

    # Find shadowing orbit
    y0, shadow = find_shadowing_orbit(pseudo[:101])  # First 100 steps

    shadow_dists = [abs(pseudo[i] - shadow[i]) for i in range(len(shadow))]
    max_shadow = max(shadow_dists)

    print(f"Shadowing orbit found with y0 = {y0}")
    print(f"y0 - x0 = {y0 - x0:.2e}")
    print(f"Max shadowing distance (first 100 steps): {max_shadow:.2e}")
    print()


def amplification_sweep():
    """Sweep contraction ratio and verify the amplification bound."""
    print("=" * 60)
    print("SHADOWING AMPLIFICATION SWEEP")
    print("=" * 60)

    import random
    random.seed(123)

    delta = 1e-8
    n_steps = 100

    print(f"{'L':>6} {'1/(1-L)':>10} {'Actual Ratio':>14} {'Bound OK':>10}")
    print("-" * 44)

    for L_int in range(10, 100, 10):
        L = L_int / 100.0
        c = 0.1

        def f(x: float, L=L, c=c) -> float:
            return L * x + c

        # Create pseudo-orbit
        x = [0.5]
        for _ in range(n_steps):
            error = random.uniform(-delta, delta)
            x.append(f(x[-1]) + error)

        # True orbit
        y = [x[0]]
        for _ in range(n_steps):
            y.append(f(y[-1]))

        max_dist = max(abs(x[i] - y[i]) for i in range(n_steps + 1))
        ratio = max_dist / delta
        bound = 1.0 / (1.0 - L)

        print(f"{L:>6.2f} {bound:>10.2f} {ratio:>14.4f} {'✓' if ratio <= bound * 1.01 else '✗':>10}")

    print()


def fixed_point_demo():
    """Demonstrate fixed points of the logistic map."""
    print("=" * 60)
    print("LOGISTIC MAP FIXED POINTS")
    print("=" * 60)

    # f(0) = 0
    print(f"f(0) = {logistic(0.0)}")
    # f(3/4) = 4 * 3/4 * 1/4 = 3/4
    print(f"f(3/4) = {logistic(0.75)}")
    # f(1/2) = 4 * 1/2 * 1/2 = 1 (maximum)
    print(f"f(1/2) = {logistic(0.5)} (maximum)")
    print()

    # Derivative at fixed points
    print("Derivative f'(x) = 4(1 - 2x):")
    for x_val, name in [(0.0, "x=0"), (0.75, "x=3/4"), (0.5, "x=1/2")]:
        deriv = 4.0 * (1.0 - 2.0 * x_val)
        print(f"  f'({name}) = {deriv}")
    print()


if __name__ == "__main__":
    contractive_shadowing_demo()
    logistic_shadowing_demo()
    amplification_sweep()
    fixed_point_demo()

    print("=" * 60)
    print("KEY INSIGHT: Numerical chaos is not error.")
    print("It is a computable shadow of mathematical truth.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Shadowing Amplification Ratio
Shows how the shadowing bound δ/(1-L) varies with the contraction ratio L.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    L_values = np.linspace(0.01, 0.99, 200)
    amplification = 1.0 / (1.0 - L_values)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Amplification ratio
    ax1 = axes[0]
    ax1.plot(L_values, amplification, color='#e74c3c', linewidth=2.5)
    ax1.set_xlabel('Contraction ratio L', fontsize=13)
    ax1.set_ylabel('Amplification 1/(1-L)', fontsize=13)
    ax1.set_title('Shadowing Amplification Ratio', fontsize=14)
    ax1.set_yscale('log')
    ax1.grid(True, alpha=0.3)
    ax1.axhline(y=10, color='#3498db', linestyle='--', alpha=0.5, label='10x amplification (L=0.9)')
    ax1.axhline(y=2, color='#2ecc71', linestyle='--', alpha=0.5, label='2x amplification (L=0.5)')
    ax1.legend(fontsize=10)

    # Plot 2: Shadowing bound for fixed delta
    ax2 = axes[1]
    delta = 1e-16  # machine epsilon
    bounds = delta / (1.0 - L_values)
    ax2.plot(L_values, bounds, color='#9b59b6', linewidth=2.5)
    ax2.set_xlabel('Contraction ratio L', fontsize=13)
    ax2.set_ylabel('Shadowing bound ε', fontsize=13)
    ax2.set_title(f'Shadowing Bound for δ = {delta:.0e} (machine ε)', fontsize=14)
    ax2.set_yscale('log')
    ax2.grid(True, alpha=0.3)

    # Annotate key points
    for L_mark in [0.5, 0.9, 0.99]:
        bound_mark = delta / (1.0 - L_mark)
        ax2.annotate(f'L={L_mark}: ε={bound_mark:.1e}',
                     xy=(L_mark, bound_mark),
                     xytext=(L_mark - 0.15, bound_mark * 5),
                     arrowprops=dict(arrowstyle='->', color='black'),
                     fontsize=9)

    plt.tight_layout()
    plt.savefig('amplification_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved amplification_visualization.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Logistic Map Pseudo-Orbit Analysis
Shows how floating-point errors create pseudo-orbits of the logistic map.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def logistic(x, r=4.0):
    return r * x * (1.0 - x)


def main():
    np.random.seed(42)

    x0 = 0.1
    n_steps = 200

    # Compute orbit
    orbit = [x0]
    x = x0
    for _ in range(n_steps):
        x = logistic(x)
        orbit.append(x)

    # Compute step errors (pseudo-orbit tolerance)
    errors = []
    for i in range(len(orbit) - 1):
        e = abs(orbit[i + 1] - logistic(orbit[i]))
        errors.append(e)

    # Cobweb data
    cobweb_x = np.linspace(0, 1, 500)
    cobweb_y = [logistic(xi) for xi in cobweb_x]

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Plot 1: Orbit
    ax1 = axes[0, 0]
    ax1.plot(range(n_steps + 1), orbit, linewidth=0.8, color='#3498db', alpha=0.8)
    ax1.set_xlabel('Step n', fontsize=11)
    ax1.set_ylabel('x_n', fontsize=11)
    ax1.set_title('Logistic Map Orbit: f(x) = 4x(1-x)', fontsize=13)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Pseudo-orbit errors
    ax2 = axes[0, 1]
    ax2.semilogy(range(len(errors)), errors, '.', markersize=2, color='#e74c3c', alpha=0.6)
    ax2.axhline(y=2.22e-16, color='#2ecc71', linestyle='--', linewidth=1.5, label='Machine epsilon')
    ax2.set_xlabel('Step n', fontsize=11)
    ax2.set_ylabel('|x_{n+1} - f(x_n)|', fontsize=11)
    ax2.set_title('Pseudo-Orbit Errors (δ per step)', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    # Plot 3: Cobweb diagram
    ax3 = axes[1, 0]
    ax3.plot(cobweb_x, cobweb_y, color='#2ecc71', linewidth=2, label='f(x) = 4x(1-x)')
    ax3.plot([0, 1], [0, 1], color='gray', linewidth=1, linestyle='--', label='y = x')

    # Draw cobweb for first 30 steps
    cx, cy = orbit[0], 0
    for i in range(min(30, n_steps)):
        ny = logistic(cx)
        ax3.plot([cx, cx], [cy, ny], color='#e74c3c', linewidth=0.5, alpha=0.6)
        ax3.plot([cx, ny], [ny, ny], color='#e74c3c', linewidth=0.5, alpha=0.6)
        cx, cy = ny, ny

    ax3.set_xlabel('x', fontsize=11)
    ax3.set_ylabel('f(x)', fontsize=11)
    ax3.set_title('Cobweb Diagram (first 30 steps)', fontsize=13)
    ax3.legend(fontsize=10)
    ax3.set_xlim(0, 1)
    ax3.set_ylim(0, 1.05)
    ax3.grid(True, alpha=0.3)

    # Plot 4: Derivative magnitude along orbit
    ax4 = axes[1, 1]
    derivs = [abs(4.0 * (1.0 - 2.0 * orbit[i])) for i in range(n_steps)]
    ax4.plot(range(n_steps), derivs, linewidth=0.8, color='#9b59b6', alpha=0.8)
    ax4.axhline(y=1, color='#e74c3c', linestyle='--', linewidth=1.5, label='|f\'| = 1 (stability boundary)')
    ax4.set_xlabel('Step n', fontsize=11)
    ax4.set_ylabel('|f\'(x_n)|', fontsize=11)
    ax4.set_title('Derivative Along Orbit: |4(1-2x_n)|', fontsize=13)
    ax4.legend(fontsize=10)
    ax4.grid(True, alpha=0.3)

    plt.suptitle('Logistic Map: Chaos as a Computable Shadow', fontsize=15, y=1.02)
    plt.tight_layout()
    plt.savefig('logistic_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved logistic_visualization.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Pseudo-orbit vs True Orbit Shadowing
Shows how a pseudo-orbit (with controlled errors) is shadowed
by a true orbit of a contractive map.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random


def main():
    random.seed(42)
    np.random.seed(42)

    L = 0.7
    c = 0.15
    delta = 0.05
    n_steps = 40

    def f(x):
        return L * x + c

    # Generate pseudo-orbit with controlled errors
    pseudo = [0.5]
    for _ in range(n_steps):
        error = random.uniform(-delta, delta)
        pseudo.append(f(pseudo[-1]) + error)

    # True orbit from same start
    true_orbit = [pseudo[0]]
    for _ in range(n_steps):
        true_orbit.append(f(true_orbit[-1]))

    # Compute distances
    distances = [abs(pseudo[i] - true_orbit[i]) for i in range(n_steps + 1)]
    bound = delta / (1 - L)

    # Inductive bounds
    inductive_bounds = [delta * (1 - L**n) / (1 - L) for n in range(n_steps + 1)]

    fig, axes = plt.subplots(2, 1, figsize=(12, 8))

    # Plot 1: Orbits
    ax1 = axes[0]
    steps = range(n_steps + 1)
    ax1.plot(steps, pseudo, 'o-', color='#e74c3c', markersize=4, label='Pseudo-orbit (with errors)', alpha=0.8)
    ax1.plot(steps, true_orbit, 's-', color='#2ecc71', markersize=4, label='True orbit (shadow)', alpha=0.8)
    ax1.fill_between(steps,
                      [true_orbit[i] - bound for i in range(n_steps + 1)],
                      [true_orbit[i] + bound for i in range(n_steps + 1)],
                      alpha=0.15, color='#2ecc71', label=f'Shadowing bound δ/(1-L) = {bound:.3f}')
    ax1.set_xlabel('Step n', fontsize=12)
    ax1.set_ylabel('x_n', fontsize=12)
    ax1.set_title(f'Contractive Shadowing: f(x) = {L}x + {c}, δ = {delta}', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Distances
    ax2 = axes[1]
    ax2.plot(steps, distances, 'o-', color='#3498db', markersize=4, label='Actual distance |x_n - y_n|')
    ax2.plot(steps, inductive_bounds, '--', color='#e67e22', linewidth=2, label='Inductive bound δ(1-L^n)/(1-L)')
    ax2.axhline(y=bound, color='#e74c3c', linestyle=':', linewidth=2, label=f'Asymptotic bound δ/(1-L) = {bound:.3f}')
    ax2.set_xlabel('Step n', fontsize=12)
    ax2.set_ylabel('Distance', fontsize=12)
    ax2.set_title('Shadowing Distance vs Theoretical Bounds', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('shadowing_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved shadowing_visualization.png")


if __name__ == "__main__":
    main()
