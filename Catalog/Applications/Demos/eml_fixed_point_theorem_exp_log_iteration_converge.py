#!/usr/bin/env python3
"""
EML Fixed-Point Iteration Demo

Demonstrates convergence of the EML operator T(x) = exp(a) * log(x + c)
to its unique fixed point under contraction conditions.
"""

import math

def eml_op(a: float, c: float, x: float) -> float:
    """The EML operator T(x) = exp(a) * log(x + c)."""
    return math.exp(a) * math.log(x + c)

def eml_deriv(a: float, c: float, x: float) -> float:
    """Derivative T'(x) = exp(a) / (x + c)."""
    return math.exp(a) / (x + c)

def eml_K(a: float, c: float, L: float) -> float:
    """Contraction constant K = exp(a) / (L + c)."""
    return math.exp(a) / (L + c)

def find_fixed_point(a: float, c: float, x0: float, tol: float = 1e-15, max_iter: int = 1000):
    """Find fixed point by iteration."""
    x = x0
    history = [x]
    for i in range(max_iter):
        x_new = eml_op(a, c, x)
        history.append(x_new)
        if abs(x_new - x) < tol:
            return x_new, history, i + 1
        x = x_new
    return x, history, max_iter

def main():
    print("=" * 70)
    print("EML Fixed-Point Iteration Convergence Demo")
    print("T(x) = exp(a) * log(x + c)")
    print("=" * 70)

    # Test cases with different parameters
    test_cases = [
        (0.5, 3.0, "Small a, moderate c"),
        (0.3, 5.0, "Very small a, large c"),
        (0.9, 4.0, "Near-boundary a"),
        (0.1, 2.0, "Minimal parameters"),
    ]

    for a, c, desc in test_cases:
        print(f"\n{'─' * 60}")
        print(f"Case: {desc}")
        print(f"  Parameters: a = {a}, c = {c}")

        K = eml_K(a, c, 0.0)
        print(f"  Contraction constant K = exp({a})/{c} = {K:.6f}")
        print(f"  K < 1? {K < 1} (contraction condition)")

        x_star, history, iters = find_fixed_point(a, c, 1.0)
        print(f"  Fixed point x* = {x_star:.12f}")
        print(f"  Converged in {iters} iterations")

        # Verify fixed point equation
        residual = abs(x_star - eml_op(a, c, x_star))
        print(f"  |x* - T(x*)| = {residual:.2e}")

        # Compute derivative at fixed point
        deriv_at_fp = eml_deriv(a, c, x_star)
        print(f"  |T'(x*)| = {deriv_at_fp:.6f} (asymptotic rate)")

        # Self-consistency relation
        if x_star > 0 and math.log(x_star + c) > 0:
            rate_alt = x_star / ((x_star + c) * math.log(x_star + c))
            print(f"  x*/((x*+c)*log(x*+c)) = {rate_alt:.6f} (should match)")

        # Show geometric convergence
        print(f"\n  Convergence history (|x_n - x*|):")
        for i in range(min(10, len(history))):
            err = abs(history[i] - x_star)
            predicted = K**i * abs(history[0] - x_star) if i > 0 else err
            ratio = err / predicted if predicted > 1e-20 else float('nan')
            print(f"    n={i:2d}: error = {err:.6e}  "
                  f"K^n*|x0-x*| = {predicted:.6e}  "
                  f"ratio = {ratio:.4f}")

    # Demonstrate convergence from multiple starting points
    print(f"\n{'=' * 70}")
    print("Convergence from multiple starting points (a=0.5, c=3.0)")
    print("=" * 70)
    a, c = 0.5, 3.0
    starting_points = [0.1, 1.0, 5.0, 10.0, 50.0, 100.0]
    x_star, _, _ = find_fixed_point(a, c, 1.0)

    for x0 in starting_points:
        _, history, iters = find_fixed_point(a, c, x0)
        print(f"  x0 = {x0:6.1f} → x* = {history[-1]:.12f} in {iters:3d} iterations")

    # Bifurcation analysis: vary a
    print(f"\n{'=' * 70}")
    print("Fixed point vs parameter a (c = 3.0)")
    print("=" * 70)
    c = 3.0
    for a in [0.1, 0.2, 0.3, 0.5, 0.7, 0.9, 1.0, 1.05, 1.09]:
        K = eml_K(a, c, 0.0)
        x_star, _, iters = find_fixed_point(a, c, 1.0)
        deriv = eml_deriv(a, c, x_star)
        stable = "STABLE" if deriv < 1 else "UNSTABLE"
        print(f"  a = {a:.2f}: K = {K:.4f}, x* = {x_star:.8f}, "
              f"|T'(x*)| = {deriv:.4f} [{stable}]")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: EML Iteration Convergence

Shows geometric convergence of the EML iteration T(x) = exp(a)*log(x+c)
to its unique fixed point, with comparison to the theoretical bound K^n.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def eml_op(a, c, x):
    return math.exp(a) * math.log(x + c)

def eml_K(a, c, L):
    return math.exp(a) / (L + c)

def iterate_eml(a, c, x0, n_iter):
    history = [x0]
    x = x0
    for _ in range(n_iter):
        x = eml_op(a, c, x)
        history.append(x)
    return history

def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('EML Fixed-Point Iteration Convergence', fontsize=16, fontweight='bold')

    # Panel 1: Convergence from multiple starting points
    ax = axes[0, 0]
    a, c = 0.5, 3.0
    x_star_approx = iterate_eml(a, c, 1.0, 200)[-1]
    for x0 in [0.5, 2.0, 5.0, 15.0, 30.0]:
        hist = iterate_eml(a, c, x0, 30)
        errors = [abs(h - x_star_approx) for h in hist]
        errors = [max(e, 1e-16) for e in errors]
        ax.semilogy(range(len(errors)), errors, 'o-', markersize=3, label=f'x₀={x0}')

    K = eml_K(a, c, 0.0)
    n_range = np.arange(31)
    ax.semilogy(n_range, 30 * K**n_range, 'k--', alpha=0.5, label=f'K^n (K={K:.3f})')
    ax.set_xlabel('Iteration n')
    ax.set_ylabel('|xₙ - x*|')
    ax.set_title(f'Geometric Convergence (a={a}, c={c})')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Panel 2: Cobweb diagram
    ax = axes[0, 1]
    a, c = 0.5, 3.0
    xs = np.linspace(0, 5, 200)
    ys = [math.exp(a) * math.log(x + c) for x in xs]
    ax.plot(xs, ys, 'b-', linewidth=2, label='T(x) = e^a log(x+c)')
    ax.plot(xs, xs, 'k--', linewidth=1, label='y = x')

    # Cobweb from x0=0.5
    x = 0.5
    for _ in range(15):
        x_new = eml_op(a, c, x)
        ax.plot([x, x], [x, x_new], 'r-', alpha=0.6, linewidth=0.8)
        ax.plot([x, x_new], [x_new, x_new], 'r-', alpha=0.6, linewidth=0.8)
        x = x_new

    ax.plot(x_star_approx, x_star_approx, 'go', markersize=8, label=f'x*={x_star_approx:.4f}')
    ax.set_xlabel('x')
    ax.set_ylabel('T(x)')
    ax.set_title('Cobweb Diagram')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Panel 3: Contraction constant vs parameter a
    ax = axes[1, 0]
    c_vals = [2.0, 3.0, 5.0, 10.0]
    a_range = np.linspace(0.01, 2.5, 200)
    for c in c_vals:
        K_vals = [math.exp(a) / c for a in a_range]
        ax.plot(a_range, K_vals, linewidth=2, label=f'c={c}')
    ax.axhline(y=1.0, color='red', linestyle='--', linewidth=1.5, label='K=1 boundary')
    ax.set_xlabel('Parameter a')
    ax.set_ylabel('Contraction constant K')
    ax.set_title('Contraction Boundary in Parameter Space')
    ax.legend(fontsize=8)
    ax.set_ylim(0, 3)
    ax.grid(True, alpha=0.3)

    # Panel 4: Fixed point and spectral radius
    ax = axes[1, 1]
    c = 3.0
    a_vals = np.linspace(0.01, 1.08, 100)
    fp_vals = []
    rho_vals = []
    for a in a_vals:
        try:
            hist = iterate_eml(a, c, 1.0, 500)
            x_star = hist[-1]
            rho = math.exp(a) / (x_star + c)
            fp_vals.append(x_star)
            rho_vals.append(rho)
        except (ValueError, OverflowError):
            fp_vals.append(None)
            rho_vals.append(None)

    valid = [(a, fp, rho) for a, fp, rho in zip(a_vals, fp_vals, rho_vals) if fp is not None]
    ax.plot([v[0] for v in valid], [v[1] for v in valid], 'b-', linewidth=2, label='Fixed point x*')
    ax2 = ax.twinx()
    ax2.plot([v[0] for v in valid], [v[2] for v in valid], 'r-', linewidth=2, label='|T\'(x*)|')
    ax2.axhline(y=1.0, color='red', linestyle='--', alpha=0.5)
    ax.set_xlabel('Parameter a')
    ax.set_ylabel('Fixed point x*', color='blue')
    ax2.set_ylabel('Spectral radius |T\'(x*)|', color='red')
    ax.set_title(f'Fixed Point & Stability (c={c})')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('eml_convergence.png', dpi=150, bbox_inches='tight')
    print("Saved eml_convergence.png")

if __name__ == "__main__":
    main()
