#!/usr/bin/env python3
"""
EML Fixed-Point Convergence Demo

Demonstrates the convergence of the EML iteration x_{n+1} = exp(a) * log(b*x + c)
to a unique fixed point, with geometric decay of errors.
"""

import math
from typing import List, Tuple


def eml_iter_op(a: float, b: float, c: float, x: float) -> float:
    """The EML single operator: f(x) = exp(a) * log(b*x + c)."""
    arg = b * x + c
    if arg <= 0:
        raise ValueError(f"log argument b*x+c = {arg} is non-positive")
    return math.exp(a) * math.log(arg)


def eml_deriv(a: float, b: float, c: float, x: float) -> float:
    """Derivative of the EML operator: f'(x) = exp(a) * b / (b*x + c)."""
    return math.exp(a) * b / (b * x + c)


def find_fixed_point(a: float, b: float, c: float, x0: float,
                     tol: float = 1e-15, max_iter: int = 1000) -> Tuple[float, List[float]]:
    """Find the fixed point by iteration, returning (x*, trajectory)."""
    trajectory = [x0]
    x = x0
    for i in range(max_iter):
        x_new = eml_iter_op(a, b, c, x)
        trajectory.append(x_new)
        if abs(x_new - x) < tol:
            return x_new, trajectory
        x = x_new
    return x, trajectory


def verify_contraction(a: float, b: float, c: float,
                       lo: float, hi: float, n_points: int = 1000) -> Tuple[bool, float]:
    """Verify contraction on [lo, hi], return (is_contraction, rho)."""
    rho = 0.0
    for i in range(n_points + 1):
        x = lo + i * (hi - lo) / n_points
        d = abs(eml_deriv(a, b, c, x))
        rho = max(rho, d)

    # Check interval invariance
    f_lo = eml_iter_op(a, b, c, lo)
    f_hi = eml_iter_op(a, b, c, hi)
    invariant = (lo <= f_lo <= hi) and (lo <= f_hi <= hi)

    return (rho < 1 and invariant), rho


def main():
    print("=" * 70)
    print("EML Fixed-Point Convergence Demo")
    print("f(x) = exp(a) * log(b*x + c)")
    print("=" * 70)

    # --- Demo 1: Basic convergence ---
    print("\n--- Demo 1: Convergence for a=0.3, b=1, c=2 ---")
    a, b, c = 0.3, 1.0, 2.0
    x0 = 5.0
    xstar, traj = find_fixed_point(a, b, c, x0)
    print(f"Starting point: x₀ = {x0}")
    print(f"Fixed point: x* = {xstar:.15f}")
    print(f"Verification: f(x*) = {eml_iter_op(a, b, c, xstar):.15f}")
    print(f"Iterations to converge: {len(traj) - 1}")
    print(f"Derivative at x*: f'(x*) = {eml_deriv(a, b, c, xstar):.6f}")

    print("\nIteration trajectory (first 15 steps):")
    for i, x in enumerate(traj[:15]):
        err = abs(x - xstar)
        print(f"  x_{i:2d} = {x:12.8f}  |x_n - x*| = {err:.2e}")

    # --- Demo 2: Geometric decay ---
    print("\n--- Demo 2: Geometric Decay of Errors ---")
    print(f"Contraction ratio ρ = |f'(x*)| = {abs(eml_deriv(a, b, c, xstar)):.6f}")
    rho = abs(eml_deriv(a, b, c, xstar))
    print("\nConsecutive differences and predicted geometric decay:")
    for i in range(min(12, len(traj) - 1)):
        diff = abs(traj[i + 1] - traj[i])
        predicted = rho ** i * abs(traj[1] - traj[0])
        ratio = diff / predicted if predicted > 0 else float('inf')
        print(f"  |x_{i+1}-x_{i}| = {diff:.2e}  ≤ ρ^{i}·|x₁-x₀| = {predicted:.2e}  (ratio: {ratio:.4f})")

    # --- Demo 3: Contraction verification ---
    print("\n--- Demo 3: Contraction Verification on [0.5, 4] ---")
    is_contr, rho_bound = verify_contraction(a, b, c, 0.5, 4.0)
    print(f"Is contraction: {is_contr}")
    print(f"ρ bound: {rho_bound:.6f}")

    # --- Demo 4: Multiple starting points ---
    print("\n--- Demo 4: Convergence from Multiple Starting Points ---")
    for x0 in [0.5, 1.0, 2.0, 3.5, 10.0]:
        xstar_i, traj_i = find_fixed_point(a, b, c, x0)
        print(f"  x₀ = {x0:5.1f} → x* = {xstar_i:.12f} ({len(traj_i)-1} iters)")

    # --- Demo 5: Parameter sweep ---
    print("\n--- Demo 5: Fixed Point vs Parameter a ---")
    header_fprime = "f'(x*)"
    print(f"  {'a':>6s}  {'x*(a)':>12s}  {header_fprime:>10s}  {'iters':>6s}")
    for a_val in [0.0, 0.05, 0.1, 0.2, 0.3, 0.4, 0.49]:
        try:
            xs, tr = find_fixed_point(a_val, 1, 2, 2.0)
            d = eml_deriv(a_val, 1, 2, xs)
            print(f"  {a_val:6.2f}  {xs:12.8f}  {d:10.6f}  {len(tr)-1:6d}")
        except Exception as e:
            print(f"  {a_val:6.2f}  FAILED: {e}")

    # --- Demo 6: Power series test ---
    print("\n--- Demo 6: Power Series Conjecture Test ---")
    # At a=0, find x*(0)
    x0_star, _ = find_fixed_point(0.0, 1, 2, 2.0)
    print(f"x*(0) = {x0_star:.10f}")

    # First-order coefficient: c₁ = x*(0) / (1 - 1/(x*(0)+2))
    c1 = x0_star / (1 - 1 / (x0_star + 2))
    print(f"Predicted c₁ = {c1:.10f}")

    print(f"\n  {'a':>6s}  {'x*(a) actual':>14s}  {'x*(0)+c₁·a':>14s}  {'error':>12s}  {'O(a²)':>12s}")
    for a_val in [0.01, 0.05, 0.1, 0.2, 0.3]:
        xs_actual, _ = find_fixed_point(a_val, 1, 2, 2.0)
        xs_approx = x0_star + c1 * a_val
        error = abs(xs_actual - xs_approx)
        oa2 = a_val ** 2
        print(f"  {a_val:6.3f}  {xs_actual:14.10f}  {xs_approx:14.10f}  {error:12.2e}  {oa2:12.2e}")

    # --- Demo 7: Uniqueness demonstration ---
    print("\n--- Demo 7: Uniqueness (different b, c values) ---")
    for params in [(1, 3), (0.5, 5), (2, 1)]:
        b_val, c_val = params
        a_val = 0.2
        try:
            xs1, _ = find_fixed_point(a_val, b_val, c_val, 0.5)
            xs2, _ = find_fixed_point(a_val, b_val, c_val, 10.0)
            print(f"  b={b_val}, c={c_val}: x*(from 0.5) = {xs1:.10f}, "
                  f"x*(from 10) = {xs2:.10f}, diff = {abs(xs1-xs2):.2e}")
        except Exception as e:
            print(f"  b={b_val}, c={c_val}: {e}")

    print("\n" + "=" * 70)
    print("All demos completed successfully.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: EML Bifurcation Diagram

Shows how the fixed point behavior changes as parameter a increases,
revealing the transition from contraction (convergence) to non-contraction.
"""

import math
import numpy as np

try:
    import matplotlib.pyplot as plt
except ImportError:
    print("matplotlib not available")
    exit(0)


def eml_iter_op(a, b, c, x):
    arg = b * x + c
    if arg <= 0:
        return float('nan')
    return math.exp(a) * math.log(arg)


def iterate_and_collect(a, b, c, x0, n_warmup=200, n_collect=50):
    """Iterate and collect the last n_collect values after warmup."""
    x = x0
    for _ in range(n_warmup):
        try:
            x = eml_iter_op(a, b, c, x)
            if abs(x) > 1e10 or math.isnan(x):
                return []
        except (ValueError, OverflowError):
            return []
    values = []
    for _ in range(n_collect):
        try:
            x = eml_iter_op(a, b, c, x)
            if abs(x) > 1e10 or math.isnan(x):
                return values
            values.append(x)
        except (ValueError, OverflowError):
            return values
    return values


def main():
    b, c = 1.0, 2.0
    x0 = 2.0

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Panel 1: Bifurcation diagram
    ax1 = axes[0]
    a_values = np.linspace(0.01, 2.5, 500)
    for a_val in a_values:
        vals = iterate_and_collect(a_val, b, c, x0)
        if vals:
            ax1.plot([a_val] * len(vals), vals, 'k.', markersize=0.3, alpha=0.5)

    ax1.set_xlabel('Parameter a', fontsize=12)
    ax1.set_ylabel('Attractor values', fontsize=12)
    ax1.set_title('EML Bifurcation Diagram', fontsize=14)
    ax1.set_ylim(-5, 15)
    ax1.grid(True, alpha=0.3)

    # Panel 2: Contraction ratio vs a
    ax2 = axes[1]
    a_fine = np.linspace(0.01, 2.5, 200)
    rhos = []
    xstars = []
    for a_val in a_fine:
        vals = iterate_and_collect(a_val, b, c, x0, n_warmup=500, n_collect=1)
        if vals:
            xs = vals[0]
            xstars.append(xs)
            rho = abs(math.exp(a_val) * b / (b * xs + c))
            rhos.append(rho)
        else:
            xstars.append(float('nan'))
            rhos.append(float('nan'))

    ax2.plot(a_fine, rhos, 'b-', linewidth=2)
    ax2.axhline(y=1.0, color='r', linestyle='--', linewidth=1.5, label='ρ = 1 (boundary)')
    ax2.set_xlabel('Parameter a', fontsize=12)
    ax2.set_ylabel('|f\'(x*)|', fontsize=12)
    ax2.set_title('Contraction Ratio at Fixed Point', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, 3)

    plt.suptitle('EML Bifurcation Analysis: f(x) = eᵃ · log(x + 2)',
                 fontsize=15, fontweight='bold')
    plt.tight_layout()
    plt.savefig('bifurcation_diagram.png', dpi=150, bbox_inches='tight')
    print("Saved bifurcation_diagram.png")
    plt.close()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: EML Iteration Convergence

Creates a multi-panel figure showing:
1. The function f(x) = exp(a)*log(x+c) vs y=x with the fixed point
2. Cobweb diagram of the iteration
3. Error decay (log scale) showing geometric convergence
4. Parameter sweep of fixed point vs a
"""

import math
import numpy as np

try:
    import matplotlib.pyplot as plt
    import matplotlib.gridspec as gridspec
except ImportError:
    print("matplotlib not available, skipping visualization")
    exit(0)


def eml_iter_op(a, b, c, x):
    return math.exp(a) * math.log(b * x + c)


def eml_deriv(a, b, c, x):
    return math.exp(a) * b / (b * x + c)


def find_fixed_point(a, b, c, x0, tol=1e-15, max_iter=1000):
    trajectory = [x0]
    x = x0
    for _ in range(max_iter):
        x_new = eml_iter_op(a, b, c, x)
        trajectory.append(x_new)
        if abs(x_new - x) < tol:
            return x_new, trajectory
        x = x_new
    return x, trajectory


def main():
    a, b, c = 0.3, 1.0, 2.0
    x0 = 5.0

    xstar, traj = find_fixed_point(a, b, c, x0)
    rho = abs(eml_deriv(a, b, c, xstar))

    fig = plt.figure(figsize=(14, 10))
    gs = gridspec.GridSpec(2, 2, hspace=0.3, wspace=0.3)

    # Panel 1: Function plot
    ax1 = fig.add_subplot(gs[0, 0])
    xs = np.linspace(0.1, 6, 500)
    ys = [eml_iter_op(a, b, c, x) for x in xs]
    ax1.plot(xs, ys, 'b-', linewidth=2, label=f'f(x) = e^{{{a}}} · log(x + {c})')
    ax1.plot(xs, xs, 'k--', linewidth=1, label='y = x')
    ax1.plot(xstar, xstar, 'ro', markersize=10, zorder=5, label=f'x* = {xstar:.4f}')
    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('f(x)', fontsize=12)
    ax1.set_title('EML Operator and Fixed Point', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.set_xlim(0, 6)
    ax1.set_ylim(0, 3)

    # Panel 2: Cobweb diagram
    ax2 = fig.add_subplot(gs[0, 1])
    xs_plot = np.linspace(0.1, 6, 500)
    ys_plot = [eml_iter_op(a, b, c, x) for x in xs_plot]
    ax2.plot(xs_plot, ys_plot, 'b-', linewidth=2)
    ax2.plot(xs_plot, xs_plot, 'k--', linewidth=1)

    # Draw cobweb
    cobweb_x = [traj[0]]
    cobweb_y = [0]
    for i in range(min(15, len(traj) - 1)):
        fx = traj[i + 1]
        cobweb_x.extend([traj[i], fx])
        cobweb_y.extend([fx, fx])
    ax2.plot(cobweb_x, cobweb_y, 'r-', linewidth=0.8, alpha=0.7)
    ax2.plot(xstar, xstar, 'go', markersize=8, zorder=5)
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('f(x)', fontsize=12)
    ax2.set_title(f'Cobweb Diagram (x₀ = {x0})', fontsize=14)
    ax2.grid(True, alpha=0.3)
    ax2.set_xlim(0, 6)
    ax2.set_ylim(0, 3)

    # Panel 3: Error decay
    ax3 = fig.add_subplot(gs[1, 0])
    errors = [abs(traj[i] - xstar) for i in range(min(25, len(traj)))]
    steps = list(range(len(errors)))
    ax3.semilogy(steps, errors, 'bo-', markersize=4, label='Actual error |x_n - x*|')
    # Predicted geometric decay
    if errors[0] > 0:
        predicted = [errors[0] * rho ** n for n in steps]
        ax3.semilogy(steps, predicted, 'r--', linewidth=1.5,
                     label=f'ρⁿ · |x₀-x*|  (ρ={rho:.4f})')
    ax3.set_xlabel('Iteration n', fontsize=12)
    ax3.set_ylabel('Error', fontsize=12)
    ax3.set_title('Geometric Error Decay', fontsize=14)
    ax3.legend(fontsize=10)
    ax3.grid(True, alpha=0.3)

    # Panel 4: Parameter sweep
    ax4 = fig.add_subplot(gs[1, 1])
    a_values = np.linspace(0.01, 0.49, 50)
    xstars = []
    rhos = []
    for a_val in a_values:
        xs, _ = find_fixed_point(a_val, 1, 2, 2.0)
        xstars.append(xs)
        rhos.append(abs(eml_deriv(a_val, 1, 2, xs)))

    ax4_twin = ax4.twinx()
    l1, = ax4.plot(a_values, xstars, 'b-', linewidth=2, label='x*(a)')
    l2, = ax4_twin.plot(a_values, rhos, 'r-', linewidth=2, label='ρ(a)')
    ax4_twin.axhline(y=1.0, color='gray', linestyle=':', alpha=0.5)
    ax4.set_xlabel('Parameter a', fontsize=12)
    ax4.set_ylabel('Fixed point x*(a)', color='b', fontsize=12)
    ax4_twin.set_ylabel('Contraction ratio ρ(a)', color='r', fontsize=12)
    ax4.set_title('Fixed Point and Convergence Rate vs a', fontsize=14)
    ax4.legend(handles=[l1, l2], fontsize=10, loc='upper left')
    ax4.grid(True, alpha=0.3)

    plt.suptitle('EML Fixed-Point Convergence: f(x) = eᵃ · log(bx + c)',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.savefig('convergence_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved convergence_visualization.png")
    plt.close()


if __name__ == "__main__":
    main()
