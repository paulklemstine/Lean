#!/usr/bin/env python3
"""
EML Fixed-Point Iteration: Numerical Demonstrations

Demonstrates the convergence of the EML operator f(x) = exp(a) * log(b*x + c)
to its unique fixed point under contraction conditions.
"""

import math
from typing import Callable, Tuple, List


def eml_op(a: float, b: float, c: float, x: float) -> float:
    """The EML operator: f(x) = exp(a) * log(b*x + c)."""
    return math.exp(a) * math.log(b * x + c)


def eml_deriv(a: float, b: float, c: float, x: float) -> float:
    """Derivative of the EML operator: f'(x) = exp(a) * b / (b*x + c)."""
    return math.exp(a) * b / (b * x + c)


def iterate_eml(a: float, b: float, c: float, x0: float, n: int) -> List[float]:
    """Compute n iterations of the EML operator starting from x0."""
    seq = [x0]
    x = x0
    for _ in range(n):
        x = eml_op(a, b, c, x)
        seq.append(x)
    return seq


def find_fixed_point(a: float, b: float, c: float, x0: float,
                     tol: float = 1e-15, max_iter: int = 1000) -> Tuple[float, int]:
    """Find the fixed point by iteration until convergence."""
    x = x0
    for i in range(max_iter):
        x_new = eml_op(a, b, c, x)
        if abs(x_new - x) < tol:
            return x_new, i + 1
        x = x_new
    return x, max_iter


def verify_contraction(a: float, b: float, c: float, lo: float, hi: float,
                       n_samples: int = 100) -> Tuple[float, bool]:
    """Verify the contraction condition on [lo, hi] and return max |f'|."""
    max_deriv = 0.0
    for i in range(n_samples + 1):
        x = lo + (hi - lo) * i / n_samples
        d = abs(eml_deriv(a, b, c, x))
        max_deriv = max(max_deriv, d)
    return max_deriv, max_deriv < 1.0


def demonstrate_convergence_rate(a: float, b: float, c: float,
                                 x0: float, xstar: float,
                                 n_iter: int = 30) -> None:
    """Show geometric convergence rate."""
    seq = iterate_eml(a, b, c, x0, n_iter)
    rho = abs(eml_deriv(a, b, c, xstar))

    print(f"\n{'n':>4} {'x_n':>18} {'|x_n - x*|':>18} {'rho^n * C':>18} {'ratio':>12}")
    print("-" * 76)

    errors = []
    for i, x in enumerate(seq):
        err = abs(x - xstar)
        errors.append(err)
        predicted = (rho ** i) * abs(seq[0] - xstar) if i > 0 else abs(seq[0] - xstar)
        ratio = errors[i] / errors[i-1] if i > 0 and errors[i-1] > 1e-16 else float('nan')
        print(f"{i:>4} {x:>18.12f} {err:>18.2e} {predicted:>18.2e} {ratio:>12.6f}")


def main():
    print("=" * 76)
    print("EML FIXED-POINT ITERATION: CONVERGENCE DEMONSTRATIONS")
    print("=" * 76)

    # Demo 1: Standard case a=0.5, b=1, c=2
    print("\n--- Demo 1: a=0.5, b=1, c=2 ---")
    a, b, c = 0.5, 1.0, 2.0
    x0 = 1.0

    xstar, iters = find_fixed_point(a, b, c, x0)
    rho_star = abs(eml_deriv(a, b, c, xstar))
    max_rho, is_contraction = verify_contraction(a, b, c, 0.5, 3.0)

    print(f"Fixed point x* = {xstar:.15f}")
    print(f"Convergence in {iters} iterations")
    print(f"|f'(x*)| = {rho_star:.10f}")
    print(f"Max |f'| on [0.5, 3.0] = {max_rho:.10f}")
    print(f"Is contraction: {is_contraction}")
    print(f"Verification: f(x*) = {eml_op(a, b, c, xstar):.15f}")

    demonstrate_convergence_rate(a, b, c, x0, xstar, 20)

    # Demo 2: Sensitivity analysis - varying a
    print("\n\n--- Demo 2: Parameter Sensitivity (varying a, b=1, c=2) ---")
    deriv_header = "|f'(x*)|"
    print(f"{'a':>8} {'x*(a)':>18} {deriv_header:>12} {'iterations':>12}")
    print("-" * 54)
    for a_val in [0.01, 0.05, 0.1, 0.2, 0.3, 0.5, 0.7, 0.9, 0.95]:
        xstar_a, iters_a = find_fixed_point(a_val, 1.0, 2.0, 1.0)
        rho_a = abs(eml_deriv(a_val, 1.0, 2.0, xstar_a))
        print(f"{a_val:>8.3f} {xstar_a:>18.12f} {rho_a:>12.8f} {iters_a:>12}")

    # Demo 3: Composition of two EML contractions
    print("\n\n--- Demo 3: Composition of EML contractions ---")
    a1, b1, c1 = 0.3, 1.0, 2.0
    a2, b2, c2 = 0.2, 1.0, 2.0

    xstar1, _ = find_fixed_point(a1, b1, c1, 1.0)
    xstar2, _ = find_fixed_point(a2, b2, c2, 1.0)
    rho1 = abs(eml_deriv(a1, b1, c1, xstar1))
    rho2 = abs(eml_deriv(a2, b2, c2, xstar2))

    # Composition f1 ∘ f2
    def f_comp(x):
        return eml_op(a1, b1, c1, eml_op(a2, b2, c2, x))

    xc = 1.0
    for _ in range(1000):
        xc = f_comp(xc)
    xstar_comp = xc

    print(f"f1 has rho1 = {rho1:.8f}")
    print(f"f2 has rho2 = {rho2:.8f}")
    print(f"Product rho1 * rho2 = {rho1 * rho2:.8f}")
    print(f"Fixed point of f1 ∘ f2: {xstar_comp:.12f}")

    # Demo 4: Monotone convergence from below
    print("\n\n--- Demo 4: Monotone convergence from below ---")
    a, b, c = 0.5, 1.0, 2.0
    x0_below = 0.5
    xstar, _ = find_fixed_point(a, b, c, 1.0)
    seq = iterate_eml(a, b, c, x0_below, 15)
    print(f"Starting below fixed point: x0 = {x0_below}")
    print(f"Fixed point: x* = {xstar:.12f}")
    print(f"{'n':>4} {'x_n':>18} {'x_n < x*':>10} {'x_n monotone':>14}")
    for i, x in enumerate(seq):
        mono = "↑" if i > 0 and x > seq[i-1] else ("=" if i > 0 and x == seq[i-1] else "-")
        print(f"{i:>4} {x:>18.12f} {str(x < xstar):>10} {mono:>14}")

    # Demo 5: A priori error bound
    print("\n\n--- Demo 5: A priori error bound verification ---")
    a, b, c = 0.5, 1.0, 2.0
    x0 = 3.0
    xstar, _ = find_fixed_point(a, b, c, 1.0)
    rho = abs(eml_deriv(a, b, c, xstar))
    max_rho, _ = verify_contraction(a, b, c, 0.5, 3.5)

    seq = iterate_eml(a, b, c, x0, 20)
    d0 = abs(eml_op(a, b, c, x0) - x0)
    print(f"rho = {max_rho:.8f}, |f(x0) - x0| = {d0:.8f}")
    print(f"{'n':>4} {'actual |x_n-x*|':>18} {'bound rho^n/(1-rho)*d0':>24} {'bound holds':>14}")
    for i, x in enumerate(seq):
        actual = abs(x - xstar)
        bound = max_rho**i / (1 - max_rho) * d0
        print(f"{i:>4} {actual:>18.2e} {bound:>24.2e} {str(actual <= bound * 1.001):>14}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: EML Fixed-Point Convergence

Produces a multi-panel figure showing:
1. Cobweb diagram of the iteration
2. Error decay (log scale)
3. Contraction ratio as function of a
4. Parameter sensitivity landscape
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def eml_op(a, b, c, x):
    return math.exp(a) * math.log(b * x + c)


def eml_deriv(a, b, c, x):
    return math.exp(a) * b / (b * x + c)


def iterate(a, b, c, x0, n):
    seq = [x0]
    x = x0
    for _ in range(n):
        x = eml_op(a, b, c, x)
        seq.append(x)
    return seq


def find_fp(a, b, c, x0=1.0):
    x = x0
    for _ in range(10000):
        xn = eml_op(a, b, c, x)
        if abs(xn - x) < 1e-15:
            return xn
        x = xn
    return x


fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# Panel 1: Cobweb diagram
ax1 = axes[0, 0]
a, b, c = 0.5, 1.0, 2.0
xstar = find_fp(a, b, c)
xs = np.linspace(0.3, 3.5, 500)
ys = [eml_op(a, b, c, x) for x in xs]

ax1.plot(xs, ys, 'b-', linewidth=2, label=r'$f(x) = e^{0.5}\ln(x+2)$')
ax1.plot(xs, xs, 'k--', linewidth=1, label=r'$y = x$')

# Cobweb
x0 = 0.5
seq = iterate(a, b, c, x0, 15)
cobweb_x = [seq[0]]
cobweb_y = [0]
for i in range(len(seq) - 1):
    cobweb_x.extend([seq[i], seq[i+1]])
    cobweb_y.extend([seq[i+1], seq[i+1]])

ax1.plot(cobweb_x, cobweb_y, 'r-', linewidth=0.8, alpha=0.7)
ax1.plot(xstar, xstar, 'go', markersize=10, zorder=5, label=f'$x^* = {xstar:.4f}$')
ax1.set_xlabel('x', fontsize=12)
ax1.set_ylabel('f(x)', fontsize=12)
ax1.set_title('Cobweb Diagram: EML Iteration', fontsize=14)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Panel 2: Error decay
ax2 = axes[0, 1]
for a_val, color, label in [(0.3, 'blue', 'a=0.3'), (0.5, 'green', 'a=0.5'),
                              (0.7, 'red', 'a=0.7'), (0.9, 'purple', 'a=0.9')]:
    xstar_a = find_fp(a_val, 1.0, 2.0)
    seq = iterate(a_val, 1.0, 2.0, 0.5, 30)
    errors = [abs(x - xstar_a) for x in seq]
    errors = [e for e in errors if e > 1e-16]
    ax2.semilogy(range(len(errors)), errors, 'o-', color=color,
                 markersize=3, label=label, linewidth=1.5)

ax2.set_xlabel('Iteration n', fontsize=12)
ax2.set_ylabel('|x_n - x*|', fontsize=12)
ax2.set_title('Geometric Error Decay', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Panel 3: Contraction ratio vs a
ax3 = axes[1, 0]
a_vals = np.linspace(0.01, 1.5, 200)
rhos = []
for a_val in a_vals:
    try:
        xstar_a = find_fp(float(a_val), 1.0, 2.0)
        rho = abs(eml_deriv(float(a_val), 1.0, 2.0, xstar_a))
        rhos.append(rho)
    except Exception:
        rhos.append(float('nan'))

ax3.plot(a_vals, rhos, 'b-', linewidth=2)
ax3.axhline(y=1.0, color='r', linestyle='--', linewidth=1, label='ρ = 1 (critical)')
ax3.fill_between(a_vals, 0, 1, alpha=0.1, color='green', label='Contraction region')
ax3.set_xlabel('Parameter a', fontsize=12)
ax3.set_ylabel("|f'(x*)| = ρ", fontsize=12)
ax3.set_title('Contraction Ratio at Fixed Point', fontsize=14)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)
ax3.set_ylim(0, 1.5)

# Panel 4: Fixed point landscape
ax4 = axes[1, 1]
a_vals_fp = np.linspace(0.01, 1.5, 200)
fps = []
for a_val in a_vals_fp:
    try:
        fps.append(find_fp(float(a_val), 1.0, 2.0))
    except Exception:
        fps.append(float('nan'))

ax4.plot(a_vals_fp, fps, 'b-', linewidth=2, label='x*(a)')

# Mark specific points
for a_mark in [0.3, 0.5, 0.7, 1.0]:
    xstar_mark = find_fp(a_mark, 1.0, 2.0)
    ax4.plot(a_mark, xstar_mark, 'ro', markersize=8)
    ax4.annotate(f'({a_mark}, {xstar_mark:.3f})', (a_mark, xstar_mark),
                 textcoords="offset points", xytext=(10, 10), fontsize=9)

ax4.set_xlabel('Parameter a', fontsize=12)
ax4.set_ylabel('Fixed point x*(a)', fontsize=12)
ax4.set_title('Fixed Point as Function of a (b=1, c=2)', fontsize=14)
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

plt.suptitle('EML Operator: Contraction Mapping Analysis', fontsize=16, y=1.02)
plt.tight_layout()
plt.savefig('eml_convergence.png', dpi=150, bbox_inches='tight')
print("Saved: eml_convergence.png")
