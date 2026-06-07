#!/usr/bin/env python3
"""
EML Fixed-Point Theorem: Numerical Demonstration

Demonstrates convergence of the EML iteration x_{n+1} = exp(a) * log(b*x_n + c)
to a unique fixed point, with geometric convergence rate rho = exp(a)*b/(b*x*+c).
"""

import math

def eml_fun(a: float, b: float, c: float, x: float) -> float:
    """The EML operator f(x) = exp(a) * log(b*x + c)."""
    return math.exp(a) * math.log(b * x + c)

def eml_deriv(a: float, b: float, c: float, x: float) -> float:
    """Derivative f'(x) = exp(a) * b / (b*x + c)."""
    return math.exp(a) * b / (b * x + c)

def find_fixed_point(a: float, b: float, c: float, x0: float,
                     max_iter: int = 1000, tol: float = 1e-15) -> tuple:
    """Iterate to find fixed point, returning (fixed_point, iterates, errors)."""
    x = x0
    iterates = [x]
    for i in range(max_iter):
        x_new = eml_fun(a, b, c, x)
        iterates.append(x_new)
        if abs(x_new - x) < tol:
            break
        x = x_new
    return x, iterates

def contraction_constant(a: float, b: float, c: float, L: float) -> float:
    """Lipschitz/contraction constant rho = exp(a) * b / (b*L + c)."""
    return math.exp(a) * b / (b * L + c)


def demo_convergence(a: float, b: float, c: float, x0: float, L: float):
    """Full demo: compute fixed point, verify convergence rate."""
    print(f"\n{'='*60}")
    print(f"EML Parameters: a={a}, b={b}, c={c}")
    print(f"Starting point: x0={x0}")
    print(f"{'='*60}")

    # Compute contraction constant
    rho = contraction_constant(a, b, c, L)
    print(f"Contraction constant rho = exp({a})*{b}/({b}*{L}+{c}) = {rho:.6f}")
    print(f"Contraction condition (rho < 1): {rho < 1}")

    # Find fixed point
    xstar, iterates = find_fixed_point(a, b, c, x0)
    print(f"\nFixed point x* = {xstar:.15f}")
    print(f"Verification: f(x*) = {eml_fun(a, b, c, xstar):.15f}")
    print(f"Error |f(x*) - x*| = {abs(eml_fun(a, b, c, xstar) - xstar):.2e}")

    # Derivative at fixed point
    rho_star = abs(eml_deriv(a, b, c, xstar))
    print(f"Local contraction rate |f'(x*)| = {rho_star:.6f}")

    # Convergence table
    print(f"\n{'n':>4} {'x_n':>20} {'|x_n - x*|':>15} {'rho^n * d0':>15} {'ratio':>10}")
    print("-" * 70)
    d0 = abs(iterates[0] - xstar)
    for n in range(min(20, len(iterates))):
        err = abs(iterates[n] - xstar)
        predicted = rho**n * d0
        ratio = err / predicted if predicted > 0 else 0
        print(f"{n:>4} {iterates[n]:>20.12f} {err:>15.2e} {predicted:>15.2e} {ratio:>10.4f}")


def demo_comparison():
    """Demo the comparison principle: larger a -> larger fixed point."""
    print(f"\n{'='*60}")
    print("Comparison Principle: Fixed point increases with parameter a")
    print(f"{'='*60}")
    b, c = 1.0, 2.0
    print(f"b={b}, c={c}")
    header = "rho=|f'(x*)|"
    print(f"\n{'a':>8} {'x*':>20} {header:>15}")
    print("-" * 48)
    for a in [0.1, 0.2, 0.3, 0.5, 0.7, 0.9]:
        xstar, _ = find_fixed_point(a, b, c, 3.0)
        rho = abs(eml_deriv(a, b, c, xstar))
        print(f"{a:>8.2f} {xstar:>20.12f} {rho:>15.6f}")


def demo_composition():
    """Demo composition: two EML contractions compose with product rate."""
    print(f"\n{'='*60}")
    print("Composition: Two EML layers with product contraction rate")
    print(f"{'='*60}")
    a1, b1, c1 = 0.3, 1.0, 2.0
    a2, b2, c2 = 0.2, 1.0, 3.0
    L = 1.0

    rho1 = contraction_constant(a1, b1, c1, L)
    rho2 = contraction_constant(a2, b2, c2, L)
    print(f"Layer 1: a={a1}, b={b1}, c={c1}, rho1={rho1:.6f}")
    print(f"Layer 2: a={a2}, b={b2}, c={c2}, rho2={rho2:.6f}")
    print(f"Product rate: rho1*rho2 = {rho1*rho2:.6f}")

    # Verify numerically
    x, y = 2.0, 3.0
    fx = eml_fun(a1, b1, c1, eml_fun(a2, b2, c2, x))
    fy = eml_fun(a1, b1, c1, eml_fun(a2, b2, c2, y))
    actual_lip = abs(fy - fx) / abs(y - x)
    print(f"\nNumerical Lipschitz ratio |f1(f2(y))-f1(f2(x))|/|y-x| = {actual_lip:.6f}")
    print(f"Bound rho1*rho2 = {rho1*rho2:.6f}")
    print(f"Bound holds: {actual_lip <= rho1*rho2}")


if __name__ == "__main__":
    # Test case 1: a=0.5, b=1, c=1 (from the research direction)
    demo_convergence(a=0.5, b=1.0, c=1.0, x0=3.0, L=1.0)

    # Test case 2: a=0.3, b=1, c=2
    demo_convergence(a=0.3, b=1.0, c=2.0, x0=3.0, L=1.0)

    # Comparison principle
    demo_comparison()

    # Composition
    demo_composition()


#!/usr/bin/env python3
"""
Visualization: EML Fixed-Point Convergence
Shows the cobweb diagram and convergence rate for the EML iteration.
"""

import math
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def eml_fun(a, b, c, x):
    return math.exp(a) * math.log(b * x + c)


def eml_deriv(a, b, c, x):
    return math.exp(a) * b / (b * x + c)


def find_fixed_point(a, b, c, x0, max_iter=200, tol=1e-15):
    x = x0
    iterates = [x]
    for _ in range(max_iter):
        x_new = eml_fun(a, b, c, x)
        iterates.append(x_new)
        if abs(x_new - x) < tol:
            break
        x = x_new
    return iterates[-1], iterates


def plot_cobweb_and_convergence():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Parameters
    a, b, c = 0.5, 1.0, 1.0
    x0 = 3.0
    L = 1.0
    rho = math.exp(a) * b / (b * L + c)

    xstar, iterates = find_fixed_point(a, b, c, x0)

    # Panel 1: Cobweb diagram
    ax = axes[0]
    xs = np.linspace(0.5, 4.0, 300)
    ys = [math.exp(a) * math.log(b * x + c) for x in xs]
    ax.plot(xs, ys, 'b-', linewidth=2, label=r'$f(x) = e^a \ln(bx+c)$')
    ax.plot(xs, xs, 'k--', linewidth=1, label='$y = x$')

    # Cobweb
    x = x0
    for i in range(15):
        y = eml_fun(a, b, c, x)
        ax.plot([x, x], [x, y], 'r-', alpha=0.6, linewidth=0.8)
        ax.plot([x, y], [y, y], 'r-', alpha=0.6, linewidth=0.8)
        x = y

    ax.plot(xstar, xstar, 'go', markersize=8, zorder=5, label=f'$x^* = {xstar:.4f}$')
    ax.set_xlabel('$x$', fontsize=12)
    ax.set_ylabel('$f(x)$', fontsize=12)
    ax.set_title(f'Cobweb Diagram ($a={a}, b={b}, c={c}$)', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_xlim(0.5, 4.0)
    ax.set_ylim(0.5, 4.0)
    ax.grid(True, alpha=0.3)

    # Panel 2: Convergence rate
    ax = axes[1]
    errors = [abs(iterates[n] - xstar) for n in range(min(30, len(iterates)))]
    ns = list(range(len(errors)))
    d0 = errors[0]
    bounds = [rho**n * d0 for n in ns]

    ax.semilogy(ns, errors, 'bo-', markersize=4, label='Actual error $|x_n - x^*|$')
    ax.semilogy(ns, bounds, 'r--', linewidth=2, label=f'Bound $\\rho^n d_0$, $\\rho={rho:.3f}$')

    # Local rate
    rho_local = abs(eml_deriv(a, b, c, xstar))
    local_bounds = [rho_local**n * d0 for n in ns]
    ax.semilogy(ns, local_bounds, 'g:', linewidth=2,
                label=f"Local rate $|f'(x^*)|^n d_0$, $|f'|={rho_local:.3f}$")

    ax.set_xlabel('Iteration $n$', fontsize=12)
    ax.set_ylabel('Error', fontsize=12)
    ax.set_title('Geometric Convergence Rate', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel 3: Comparison principle
    ax = axes[2]
    b_val, c_val = 1.0, 2.0
    a_values = np.linspace(0.05, 0.95, 40)
    fixed_pts = []
    rho_values = []
    for aa in a_values:
        xst, _ = find_fixed_point(aa, b_val, c_val, 3.0)
        fixed_pts.append(xst)
        rho_values.append(abs(eml_deriv(aa, b_val, c_val, xst)))

    ax2 = ax.twinx()
    l1, = ax.plot(a_values, fixed_pts, 'b-', linewidth=2, label='Fixed point $x^*(a)$')
    l2, = ax2.plot(a_values, rho_values, 'r--', linewidth=2, label="Contraction rate $|f'(x^*)|$")

    ax.set_xlabel('Parameter $a$', fontsize=12)
    ax.set_ylabel('Fixed point $x^*$', fontsize=12, color='b')
    ax2.set_ylabel("Local rate $|f'(x^*)|$", fontsize=12, color='r')
    ax.set_title(f'Parameter Dependence ($b={b_val}, c={c_val}$)', fontsize=13)
    ax.legend(handles=[l1, l2], fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/Applications/eml_convergence.png', dpi=150)
    plt.close()
    print("Saved eml_convergence.png")


if __name__ == "__main__":
    plot_cobweb_and_convergence()
