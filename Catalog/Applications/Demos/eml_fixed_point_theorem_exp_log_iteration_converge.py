#!/usr/bin/env python3
"""
EML Fixed-Point Theorem: Numerical Demonstrations

Demonstrates convergence of the EML iteration T(x) = exp(a) * log(x + c)
to its unique fixed point, with geometric convergence rate verification.
"""

import math


def eml_fun(a: float, c: float, x: float) -> float:
    """EML operator: f(x) = exp(a) * log(x + c)"""
    if x + c <= 0:
        raise ValueError(f"Domain error: x + c = {x + c} <= 0")
    return math.exp(a) * math.log(x + c)


def eml_deriv(a: float, c: float, x: float) -> float:
    """Derivative of EML operator: f'(x) = exp(a) / (x + c)"""
    return math.exp(a) / (x + c)


def contraction_ratio(a: float, c: float, L: float) -> float:
    """Contraction ratio on [L, inf): rho = exp(a) / (L + c)"""
    return math.exp(a) / (L + c)


def find_fixed_point(a: float, c: float, x0: float, tol: float = 1e-15, max_iter: int = 1000):
    """Find fixed point by iteration, returning (x*, iterations, history)"""
    x = x0
    history = [x]
    for i in range(max_iter):
        x_new = eml_fun(a, c, x)
        history.append(x_new)
        if abs(x_new - x) < tol:
            return x_new, i + 1, history
        x = x_new
    return x, max_iter, history


def demo_convergence():
    """Demonstrate geometric convergence for specific parameters."""
    print("=" * 70)
    print("EML Fixed-Point Theorem: Convergence Demonstration")
    print("=" * 70)
    
    # Case 1: a=0.5, c=1.0, L=1.0
    a, c, L = 0.5, 1.0, 1.0
    rho = contraction_ratio(a, c, L)
    print(f"\nCase 1: a={a}, c={c}, L={L}")
    print(f"  Contraction ratio rho = exp({a})/({L}+{c}) = {rho:.6f}")
    print(f"  Contraction condition: exp({a}) = {math.exp(a):.6f} < {L+c} = {L+c} ✓" 
          if math.exp(a) < L + c else "  ✗ NOT a contraction")
    
    x0 = 5.0
    xstar, iters, history = find_fixed_point(a, c, x0)
    print(f"  Starting point: x0 = {x0}")
    print(f"  Fixed point: x* = {xstar:.15f}")
    print(f"  Iterations to convergence: {iters}")
    print(f"  Verification: f(x*) = {eml_fun(a, c, xstar):.15f}")
    print(f"  |f(x*) - x*| = {abs(eml_fun(a, c, xstar) - xstar):.2e}")
    print(f"  f'(x*) = {eml_deriv(a, c, xstar):.6f}")
    
    # Verify geometric convergence rate
    print(f"\n  Geometric convergence verification:")
    print(f"  {'n':>4}  {'|x_n - x*|':>20}  {'rho^n * |x0 - x*|':>20}  {'ratio':>12}")
    for n in range(min(15, len(history))):
        err = abs(history[n] - xstar)
        bound = rho**n * abs(x0 - xstar)
        ratio = err / bound if bound > 0 else 0
        print(f"  {n:4d}  {err:20.12e}  {bound:20.12e}  {ratio:12.6f}")
    
    # Case 2: a=0.3, c=2.0
    print("\n" + "-" * 70)
    a, c, L = 0.3, 2.0, 1.0
    rho = contraction_ratio(a, c, L)
    print(f"\nCase 2: a={a}, c={c}, L={L}")
    print(f"  Contraction ratio rho = {rho:.6f}")
    
    x0 = 2.0
    xstar, iters, history = find_fixed_point(a, c, x0)
    print(f"  Fixed point: x* = {xstar:.15f}")
    print(f"  Iterations: {iters}")
    print(f"  f'(x*) = {eml_deriv(a, c, xstar):.6f}")
    
    # Case 3: Near-critical contraction (rho close to 1)
    print("\n" + "-" * 70)
    a, c, L = 0.8, 1.0, 1.5
    rho = contraction_ratio(a, c, L)
    print(f"\nCase 3 (slow convergence): a={a}, c={c}, L={L}")
    print(f"  Contraction ratio rho = {rho:.6f}")
    
    x0 = 3.0
    xstar, iters, history = find_fixed_point(a, c, x0)
    print(f"  Fixed point: x* = {xstar:.15f}")
    print(f"  Iterations: {iters}")
    
    # Exponential form verification
    print("\n" + "=" * 70)
    print("Exponential Form Verification: exp(x*/exp(a)) = x* + c")
    print("=" * 70)
    for a, c in [(0.5, 1.0), (0.3, 2.0), (0.8, 1.0)]:
        xstar, _, _ = find_fixed_point(a, c, 5.0)
        lhs = math.exp(xstar / math.exp(a))
        rhs = xstar + c
        print(f"  a={a}, c={c}: exp(x*/e^a) = {lhs:.12f}, x*+c = {rhs:.12f}, "
              f"diff = {abs(lhs - rhs):.2e}")


def demo_composition():
    """Demonstrate composition contraction property."""
    print("\n" + "=" * 70)
    print("EML Composition: Product of Contraction Ratios")
    print("=" * 70)
    
    a1, c1, L1 = 0.3, 1.0, 1.0
    a2, c2, L2 = 0.4, 0.5, 0.5
    
    r1 = contraction_ratio(a1, c1, L1)
    r2 = contraction_ratio(a2, c2, L2)
    
    print(f"  Layer 1: a={a1}, c={c1}, rho1={r1:.6f}")
    print(f"  Layer 2: a={a2}, c={c2}, rho2={r2:.6f}")
    print(f"  Composed ratio bound: rho1*rho2 = {r1*r2:.6f}")
    
    # Verify empirically
    x, y = 2.0, 4.0
    fx = eml_fun(a2, c2, eml_fun(a1, c1, x))
    fy = eml_fun(a2, c2, eml_fun(a1, c1, y))
    actual_ratio = abs(fx - fy) / abs(x - y)
    print(f"  Empirical: |g(f(x))-g(f(y))|/|x-y| = {actual_ratio:.6f}")
    print(f"  Bound satisfied: {actual_ratio:.6f} ≤ {r1*r2:.6f} ✓"
          if actual_ratio <= r1 * r2 else "  ✗")


def demo_parameter_sensitivity():
    """Show how the fixed point varies with parameters."""
    print("\n" + "=" * 70)
    print("Parameter Sensitivity: Fixed Point as Function of a")
    print("=" * 70)
    
    c = 1.0
    print(f"  c = {c}, b = 1")
    header = "rho=f'(x*)"
    print(f"  {'a':>6}  {'x*':>15}  {header:>12}  {'iters':>6}")
    for a_val in [0.05, 0.1, 0.2, 0.3, 0.5, 0.7, 0.9, 1.0, 1.2]:
        try:
            xstar, iters, _ = find_fixed_point(a_val, c, 5.0)
            rho_at_fp = eml_deriv(a_val, c, xstar)
            print(f"  {a_val:6.2f}  {xstar:15.10f}  {rho_at_fp:12.6f}  {iters:6d}")
        except Exception:
            print(f"  {a_val:6.2f}  (diverges or undefined)")


if __name__ == "__main__":
    demo_convergence()
    demo_composition()
    demo_parameter_sensitivity()


#!/usr/bin/env python3
"""
Visualization: EML Iteration Convergence

Shows geometric convergence of x_{n+1} = exp(a)*log(x_n + c) to the
fixed point, with the theoretical bound ρ^n overlaid.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def eml_fun(a, c, x):
    return math.exp(a) * math.log(x + c)


def find_fixed_point(a, c, x0, max_iter=200):
    history = [x0]
    x = x0
    for _ in range(max_iter):
        x = eml_fun(a, c, x)
        history.append(x)
    return x, history


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('EML Fixed-Point Theorem: Convergence Analysis', fontsize=16, fontweight='bold')

    # Panel 1: Cobweb diagram
    ax = axes[0, 0]
    a, c = 0.5, 1.0
    xstar, history = find_fixed_point(a, c, 5.0, 30)
    
    xs = np.linspace(0.5, 6, 300)
    ys = [math.exp(a) * math.log(xi + c) for xi in xs]
    ax.plot(xs, ys, 'b-', linewidth=2, label=f'f(x) = e^{{{a}}}·ln(x+{c})')
    ax.plot(xs, xs, 'k--', linewidth=1, label='y = x')
    
    # Cobweb
    for i in range(min(15, len(history) - 1)):
        x_cur = history[i]
        x_next = history[i + 1]
        ax.plot([x_cur, x_cur], [x_cur, x_next], 'r-', alpha=0.6, linewidth=0.8)
        ax.plot([x_cur, x_next], [x_next, x_next], 'r-', alpha=0.6, linewidth=0.8)
    
    ax.plot(xstar, xstar, 'go', markersize=8, zorder=5, label=f'x* ≈ {xstar:.4f}')
    ax.set_xlabel('x')
    ax.set_ylabel('f(x)')
    ax.set_title('Cobweb Diagram')
    ax.legend(fontsize=9)
    ax.set_xlim(0.5, 6)
    ax.set_ylim(0, 4)
    ax.grid(True, alpha=0.3)

    # Panel 2: Geometric convergence rate
    ax = axes[0, 1]
    for a_val, c_val, color, marker in [(0.5, 1.0, 'blue', 'o'), (0.3, 1.0, 'green', 's'), (0.7, 0.5, 'red', '^')]:
        L = 1.0
        rho = math.exp(a_val) / (L + c_val)
        xstar, hist = find_fixed_point(a_val, c_val, 5.0, 50)
        errors = [abs(h - xstar) for h in hist]
        errors = [e for e in errors if e > 1e-16]
        ns = range(len(errors))
        ax.semilogy(list(ns), errors, f'{marker}-', color=color, markersize=4,
                    label=f'a={a_val}, c={c_val}, ρ={rho:.3f}')
        # Theoretical bound
        bound = [rho**n * abs(hist[0] - xstar) for n in ns]
        ax.semilogy(list(ns), bound, '--', color=color, alpha=0.5, linewidth=1)
    
    ax.set_xlabel('Iteration n')
    ax.set_ylabel('|x_n - x*|')
    ax.set_title('Geometric Convergence (dashed = ρⁿ bound)')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel 3: Contraction ratio as function of a
    ax = axes[1, 0]
    c_vals = [0.5, 1.0, 2.0]
    L = 1.0
    a_range = np.linspace(0.01, 2.0, 200)
    for c_val, color in zip(c_vals, ['blue', 'green', 'red']):
        rhos = [math.exp(a_val) / (L + c_val) for a_val in a_range]
        ax.plot(a_range, rhos, '-', color=color, linewidth=2, label=f'c={c_val}')
    
    ax.axhline(y=1, color='black', linestyle='--', linewidth=1, label='ρ = 1 (boundary)')
    ax.fill_between(a_range, 0, 1, alpha=0.1, color='green')
    ax.set_xlabel('Parameter a')
    ax.set_ylabel('Contraction ratio ρ')
    ax.set_title(f'Contraction Ratio ρ(a) = eᵃ/(L+c), L={L}')
    ax.legend(fontsize=9)
    ax.set_ylim(0, 3)
    ax.grid(True, alpha=0.3)
    ax.text(0.5, 0.5, 'Contraction\nRegion', fontsize=12, ha='center', color='darkgreen', alpha=0.7)

    # Panel 4: Fixed point as function of a
    ax = axes[1, 1]
    c_vals = [0.5, 1.0, 2.0]
    for c_val, color in zip(c_vals, ['blue', 'green', 'red']):
        a_vals_plot = []
        fp_vals = []
        for a_val in np.linspace(0.01, 1.5, 100):
            try:
                xstar, _ = find_fixed_point(a_val, c_val, 5.0, 500)
                if abs(eml_fun(a_val, c_val, xstar) - xstar) < 1e-6:
                    a_vals_plot.append(a_val)
                    fp_vals.append(xstar)
            except Exception:
                pass
        ax.plot(a_vals_plot, fp_vals, '-', color=color, linewidth=2, label=f'c={c_val}')
    
    ax.set_xlabel('Parameter a')
    ax.set_ylabel('Fixed point x*')
    ax.set_title('Fixed Point x*(a) for Various c')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('eml_convergence.png', dpi=150, bbox_inches='tight')
    print("Saved eml_convergence.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: EML Phase Portrait and Parameter Space

Shows the contraction region in (a, c) parameter space and
the phase portrait of the EML dynamical system.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def eml_fun(a, c, x):
    return math.exp(a) * math.log(x + c)


def find_fixed_point(a, c, x0=5.0, max_iter=500, tol=1e-12):
    x = x0
    for _ in range(max_iter):
        try:
            x_new = eml_fun(a, c, x)
            if abs(x_new - x) < tol:
                return x_new
            x = x_new
        except (ValueError, OverflowError):
            return None
    return x


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('EML Contraction: Parameter Space & Phase Portrait', fontsize=14, fontweight='bold')

    # Panel 1: Contraction region in (a, c) space for L = 1
    ax = axes[0]
    L = 1.0
    a_range = np.linspace(0.01, 3.0, 300)
    c_range = np.linspace(0.01, 5.0, 300)
    A, C = np.meshgrid(a_range, c_range)
    
    # Contraction condition: exp(a) < L + c, i.e., c > exp(a) - L
    rho = np.exp(A) / (L + C)
    
    contour = ax.contourf(A, C, rho, levels=[0, 0.2, 0.4, 0.6, 0.8, 1.0], 
                          cmap='RdYlGn_r', alpha=0.8)
    ax.contour(A, C, rho, levels=[1.0], colors='black', linewidths=2)
    plt.colorbar(contour, ax=ax, label='Contraction ratio ρ')
    
    # Mark the boundary curve c = exp(a) - L
    a_boundary = np.linspace(0.01, 3.0, 200)
    c_boundary = np.exp(a_boundary) - L
    c_boundary = np.clip(c_boundary, 0.01, 5.0)
    ax.plot(a_boundary, c_boundary, 'k-', linewidth=2, label='ρ = 1 boundary')
    ax.fill_between(a_boundary, c_boundary, 5.0, alpha=0.15, color='green')
    
    ax.set_xlabel('Parameter a', fontsize=12)
    ax.set_ylabel('Parameter c', fontsize=12)
    ax.set_title(f'Contraction Region (L={L})', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_xlim(0, 3)
    ax.set_ylim(0, 5)
    ax.text(0.5, 3.5, 'CONTRACTION\nρ < 1', fontsize=14, fontweight='bold', 
            color='darkgreen', ha='center')
    ax.text(2.2, 0.5, 'EXPANSION\nρ > 1', fontsize=12, color='darkred', ha='center')

    # Panel 2: Phase portrait — multiple trajectories
    ax = axes[1]
    a, c = 0.5, 1.0
    xstar = find_fixed_point(a, c)
    
    x_range = np.linspace(0.5, 8, 400)
    fx = [math.exp(a) * math.log(xi + c) for xi in x_range]
    
    ax.plot(x_range, fx, 'b-', linewidth=2, label=f'f(x) = e^{{{a}}}·ln(x+{c})')
    ax.plot(x_range, x_range, 'k--', linewidth=1, label='y = x')
    
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6', '#f39c12']
    x0_values = [0.8, 1.5, 3.0, 5.0, 7.0]
    
    for x0, color in zip(x0_values, colors):
        trajectory_x = [x0]
        trajectory_y = [0]
        x = x0
        for _ in range(20):
            try:
                fx_val = eml_fun(a, c, x)
                trajectory_x.extend([x, fx_val])
                trajectory_y.extend([fx_val, fx_val])
                x = fx_val
            except (ValueError, OverflowError):
                break
        ax.plot(trajectory_x, trajectory_y, '-', color=color, alpha=0.6, linewidth=1)
        ax.plot(x0, 0, 'o', color=color, markersize=6, label=f'x₀={x0}')
    
    if xstar is not None:
        ax.plot(xstar, xstar, 'k*', markersize=15, zorder=10, label=f'x*≈{xstar:.3f}')
    
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('f(x)', fontsize=12)
    ax.set_title('Phase Portrait: All Trajectories → x*', fontsize=13)
    ax.legend(fontsize=8, loc='upper left')
    ax.set_xlim(0, 8)
    ax.set_ylim(0, 5)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('eml_phase_portrait.png', dpi=150, bbox_inches='tight')
    print("Saved eml_phase_portrait.png")


if __name__ == "__main__":
    main()
