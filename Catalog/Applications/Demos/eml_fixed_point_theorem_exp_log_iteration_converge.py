#!/usr/bin/env python3
"""
EML Fixed-Point Iteration Demo
==============================

Demonstrates convergence of the EML operator f(x) = exp(a) * log(b*x + c)
to its unique fixed point under contraction conditions.
"""

import math
from typing import Tuple, List


def eml_op(a: float, b: float, c: float, x: float) -> float:
    """The EML operator f(x) = exp(a) * log(b*x + c)."""
    return math.exp(a) * math.log(b * x + c)


def eml_deriv(a: float, b: float, c: float, x: float) -> float:
    """Derivative f'(x) = exp(a) * b / (b*x + c)."""
    return math.exp(a) * b / (b * x + c)


def eml_iterate(a: float, b: float, c: float, x0: float, n: int) -> List[float]:
    """Run n iterations of the EML operator starting from x0."""
    seq = [x0]
    x = x0
    for _ in range(n):
        x = eml_op(a, b, c, x)
        seq.append(x)
    return seq


def find_fixed_point(a: float, b: float, c: float, x0: float = 1.0,
                     tol: float = 1e-15, max_iter: int = 1000) -> Tuple[float, int]:
    """Find the fixed point by iteration."""
    x = x0
    for i in range(max_iter):
        x_new = eml_op(a, b, c, x)
        if abs(x_new - x) < tol:
            return x_new, i + 1
        x = x_new
    return x, max_iter


def contraction_rate(a: float, b: float, c: float, xstar: float) -> float:
    """Compute the spectral contraction rate |f'(x*)| at the fixed point."""
    return abs(eml_deriv(a, b, c, xstar))


def demo_convergence():
    """Main demonstration of EML fixed-point convergence."""
    print("=" * 70)
    print("EML FIXED-POINT ITERATION CONVERGENCE DEMO")
    print("=" * 70)

    # Case 1: b=1, c=2, a=0.5
    print("\n--- Case 1: a=0.5, b=1, c=2 ---")
    a, b, c = 0.5, 1.0, 2.0
    xstar, iters = find_fixed_point(a, b, c, x0=1.0)
    rho = contraction_rate(a, b, c, xstar)
    print(f"Fixed point x* = {xstar:.15f}")
    print(f"Converged in {iters} iterations")
    print(f"Spectral rate |f'(x*)| = {rho:.15f}")
    print(f"Verification: f(x*) = {eml_op(a, b, c, xstar):.15f}")
    print(f"Contraction check: rho < 1? {rho < 1}")

    # Show geometric convergence
    seq = eml_iterate(a, b, c, 1.0, 30)
    print("\nIteration convergence:")
    print(f"{'n':>4} {'x_n':>20} {'|x_n - x*|':>20} {'ratio':>15}")
    for i in range(min(15, len(seq))):
        err = abs(seq[i] - xstar)
        ratio = abs(seq[i] - xstar) / abs(seq[i-1] - xstar) if i > 0 and abs(seq[i-1] - xstar) > 1e-16 else float('nan')
        print(f"{i:4d} {seq[i]:20.15f} {err:20.2e} {ratio:15.10f}")

    # Case 2: a=0.1, b=1, c=1
    print("\n--- Case 2: a=0.1, b=1, c=1 ---")
    a, b, c = 0.1, 1.0, 1.0
    xstar, iters = find_fixed_point(a, b, c, x0=0.5)
    rho = contraction_rate(a, b, c, xstar)
    print(f"Fixed point x* = {xstar:.15f}")
    print(f"Spectral rate |f'(x*)| = {rho:.15f}")

    # Case 3: a=0.3, b=0.5, c=3
    print("\n--- Case 3: a=0.3, b=0.5, c=3 ---")
    a, b, c = 0.3, 0.5, 3.0
    xstar, iters = find_fixed_point(a, b, c, x0=1.0)
    rho = contraction_rate(a, b, c, xstar)
    print(f"Fixed point x* = {xstar:.15f}")
    print(f"Spectral rate |f'(x*)| = {rho:.15f}")

    # Parameter sweep: fixed point as function of a
    print("\n--- Parameter Sweep: x*(a) for b=1, c=2 ---")
    header = "|f'(x*)|"
    print(f"{'a':>8} {'x*(a)':>15} {header:>15}")
    for a_val in [0.01, 0.05, 0.1, 0.2, 0.3, 0.5, 0.7, 0.9, 1.0, 1.2, 1.5]:
        try:
            xs, _ = find_fixed_point(a_val, 1.0, 2.0, x0=1.0)
            rho_val = contraction_rate(a_val, 1.0, 2.0, xs)
            marker = " <-- contraction fails!" if rho_val >= 1 else ""
            print(f"{a_val:8.2f} {xs:15.10f} {rho_val:15.10f}{marker}")
        except (ValueError, ZeroDivisionError):
            print(f"{a_val:8.2f}   (diverged)")

    # Composition test
    print("\n--- Composition: f∘f has rate ρ² ---")
    a, b, c = 0.3, 1.0, 2.0
    xstar, _ = find_fixed_point(a, b, c)
    rho1 = contraction_rate(a, b, c, xstar)
    # f∘f at xstar
    x = 1.5
    fx = eml_op(a, b, c, x)
    ffx = eml_op(a, b, c, fx)
    print(f"ρ = {rho1:.10f}")
    print(f"ρ² = {rho1**2:.10f}")
    print(f"|f∘f(x) - f∘f(y)| / |x - y| ≈ {abs(ffx - xstar) / abs(x - xstar):.10f}")

    # Lyapunov function demo
    print("\n--- Lyapunov Function V(x) = (x - x*)² ---")
    a, b, c = 0.5, 1.0, 2.0
    xstar, _ = find_fixed_point(a, b, c)
    x = 3.0
    print(f"{'n':>4} {'V(x_n)':>20} {'V(x_n)/V(x_{n-1})':>20}")
    v_prev = (x - xstar) ** 2
    print(f"{0:4d} {v_prev:20.15f}")
    for i in range(1, 12):
        x = eml_op(a, b, c, x)
        v = (x - xstar) ** 2
        print(f"{i:4d} {v:20.15f} {v/v_prev:20.15f}")
        v_prev = v


if __name__ == "__main__":
    demo_convergence()


#!/usr/bin/env python3
"""
Visualization: EML Fixed-Point Convergence
==========================================

Creates three plots:
1. Cobweb diagram showing iteration convergence
2. Error decay (log scale) showing geometric convergence
3. Parameter space showing contraction boundary
"""

import math
import numpy as np

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    HAS_MPL = True
except ImportError:
    HAS_MPL = False
    print("matplotlib not available; skipping visualization")


def eml_op(a, b, c, x):
    return math.exp(a) * math.log(b * x + c)

def eml_deriv(a, b, c, x):
    return math.exp(a) * b / (b * x + c)

def find_fp(a, b, c, x0=1.0, n=5000, tol=1e-15):
    x = x0
    for _ in range(n):
        xn = eml_op(a, b, c, x)
        if abs(xn - x) < tol:
            return xn
        x = xn
    return x


def plot_cobweb():
    """Plot cobweb diagram for EML iteration."""
    a, b, c = 0.5, 1.0, 2.0
    xstar = find_fp(a, b, c)

    fig, ax = plt.subplots(1, 1, figsize=(8, 8))

    xs = np.linspace(0.3, 5.0, 500)
    ys = [eml_op(a, b, c, x) for x in xs]
    ax.plot(xs, ys, 'b-', linewidth=2, label=r'$f(x) = e^{0.5} \ln(x+2)$')
    ax.plot(xs, xs, 'k--', linewidth=1, label=r'$y = x$')

    # Cobweb from x0 = 4
    x = 4.0
    cobweb_x, cobweb_y = [x], [0]
    for _ in range(15):
        fx = eml_op(a, b, c, x)
        cobweb_x.extend([x, fx])
        cobweb_y.extend([fx, fx])
        x = fx
    ax.plot(cobweb_x, cobweb_y, 'r-', linewidth=1.0, alpha=0.8)
    ax.plot(xstar, xstar, 'go', markersize=10, zorder=5,
            label=f'Fixed point $x^* \\approx {xstar:.4f}$')

    ax.set_xlabel('x', fontsize=14)
    ax.set_ylabel('f(x)', fontsize=14)
    ax.set_title('EML Cobweb Diagram: Convergence to Fixed Point', fontsize=16)
    ax.legend(fontsize=12)
    ax.set_xlim(0.3, 5.0)
    ax.set_ylim(0.3, 5.0)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('cobweb.png', dpi=150)
    plt.close(fig)
    print("Saved cobweb.png")


def plot_error_decay():
    """Plot error decay showing geometric convergence."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    configs = [
        (0.3, 1.0, 2.0, 'blue', r'$a=0.3, c=2$'),
        (0.5, 1.0, 2.0, 'red', r'$a=0.5, c=2$'),
        (0.7, 1.0, 2.0, 'green', r'$a=0.7, c=2$'),
        (0.5, 1.0, 5.0, 'purple', r'$a=0.5, c=5$'),
    ]

    for a, b_val, c, color, label in configs:
        xstar = find_fp(a, b_val, c)
        rho = abs(eml_deriv(a, b_val, c, xstar))
        x = 4.0
        errors = []
        for _ in range(30):
            errors.append(abs(x - xstar))
            x = eml_op(a, b_val, c, x)

        errors_pos = [e for e in errors if e > 1e-16]
        ns = range(len(errors_pos))
        ax.semilogy(ns, errors_pos, 'o-', color=color, markersize=4,
                     label=f'{label}, $\\rho={rho:.3f}$')

    ax.set_xlabel('Iteration n', fontsize=14)
    ax.set_ylabel('$|x_n - x^*|$', fontsize=14)
    ax.set_title('Geometric Convergence of EML Iteration', fontsize=16)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('error_decay.png', dpi=150)
    plt.close(fig)
    print("Saved error_decay.png")


def plot_parameter_space():
    """Plot the contraction boundary in (a, c) space."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: fixed point as function of a
    a_vals = np.linspace(0.01, 2.0, 100)
    ax = axes[0]
    for c_val, color in [(2, 'blue'), (3, 'red'), (5, 'green'), (10, 'purple')]:
        xstars = []
        rhos = []
        for a in a_vals:
            try:
                xs = find_fp(a, 1.0, c_val)
                rho = abs(eml_deriv(a, 1.0, c_val, xs))
                if rho < 2:
                    xstars.append(xs)
                    rhos.append(rho)
                else:
                    xstars.append(float('nan'))
                    rhos.append(float('nan'))
            except (ValueError, OverflowError):
                xstars.append(float('nan'))
                rhos.append(float('nan'))
        ax.plot(a_vals, xstars, color=color, label=f'c={c_val}')

    ax.set_xlabel('Parameter a', fontsize=14)
    ax.set_ylabel('Fixed point $x^*(a)$', fontsize=14)
    ax.set_title('Fixed Point vs Parameter $a$', fontsize=16)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Right: contraction rate as function of a
    ax = axes[1]
    for c_val, color in [(2, 'blue'), (3, 'red'), (5, 'green'), (10, 'purple')]:
        rhos = []
        for a in a_vals:
            try:
                xs = find_fp(a, 1.0, c_val)
                rho = abs(eml_deriv(a, 1.0, c_val, xs))
                rhos.append(rho)
            except (ValueError, OverflowError):
                rhos.append(float('nan'))
        ax.plot(a_vals, rhos, color=color, label=f'c={c_val}')

    ax.axhline(y=1.0, color='black', linestyle='--', linewidth=2, label='$\\rho = 1$ boundary')
    ax.set_xlabel('Parameter a', fontsize=14)
    ax.set_ylabel('Spectral rate $|f\'(x^*)|$', fontsize=14)
    ax.set_title('Contraction Rate vs Parameter $a$', fontsize=16)
    ax.legend(fontsize=11)
    ax.set_ylim(0, 2)
    ax.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('parameter_space.png', dpi=150)
    plt.close(fig)
    print("Saved parameter_space.png")


if __name__ == "__main__" and HAS_MPL:
    plot_cobweb()
    plot_error_decay()
    plot_parameter_space()
