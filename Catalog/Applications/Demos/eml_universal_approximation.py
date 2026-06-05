#!/usr/bin/env python3
"""
EML Universal Approximation Demo

Demonstrates key results from the EML (Exponential-Multiplicative-Logarithmic)
closure theory:
1. Universal approximation via polynomial fragment
2. Depth advantage of exp-log over pure polynomial circuits
3. Derivative computation in EML circuits
"""

import math
from typing import Callable, List, Tuple


# ── EML Expression Tree ──────────────────────────────────────────────────────

class EMLExpr:
    """EML expression node."""
    pass

class Const(EMLExpr):
    def __init__(self, c: float):
        self.c = c
    def eval(self, x: float) -> float:
        return self.c
    def depth(self) -> int:
        return 0
    def size(self) -> int:
        return 1
    def __repr__(self):
        return f"{self.c}"

class Var(EMLExpr):
    def eval(self, x: float) -> float:
        return x
    def depth(self) -> int:
        return 0
    def size(self) -> int:
        return 1
    def __repr__(self):
        return "x"

class Add(EMLExpr):
    def __init__(self, e1: EMLExpr, e2: EMLExpr):
        self.e1, self.e2 = e1, e2
    def eval(self, x: float) -> float:
        return self.e1.eval(x) + self.e2.eval(x)
    def depth(self) -> int:
        return max(self.e1.depth(), self.e2.depth()) + 1
    def size(self) -> int:
        return self.e1.size() + self.e2.size() + 1
    def __repr__(self):
        return f"({self.e1} + {self.e2})"

class Mul(EMLExpr):
    def __init__(self, e1: EMLExpr, e2: EMLExpr):
        self.e1, self.e2 = e1, e2
    def eval(self, x: float) -> float:
        return self.e1.eval(x) * self.e2.eval(x)
    def depth(self) -> int:
        return max(self.e1.depth(), self.e2.depth()) + 1
    def size(self) -> int:
        return self.e1.size() + self.e2.size() + 1
    def __repr__(self):
        return f"({self.e1} * {self.e2})"

class Exp(EMLExpr):
    def __init__(self, e: EMLExpr):
        self.e = e
    def eval(self, x: float) -> float:
        v = self.e.eval(x)
        return math.exp(min(v, 700))  # prevent overflow
    def depth(self) -> int:
        return self.e.depth() + 1
    def size(self) -> int:
        return self.e.size() + 1
    def __repr__(self):
        return f"exp({self.e})"

class Log(EMLExpr):
    def __init__(self, e: EMLExpr):
        self.e = e
    def eval(self, x: float) -> float:
        v = self.e.eval(x)
        return math.log(v) if v > 0 else 0.0
    def depth(self) -> int:
        return self.e.depth() + 1
    def size(self) -> int:
        return self.e.size() + 1
    def __repr__(self):
        return f"log({self.e})"


# ── Key constructions ────────────────────────────────────────────────────────

def repeated_square(n: int) -> EMLExpr:
    """x^(2^n) via repeated squaring (polynomial fragment, depth n)."""
    if n == 0:
        return Var()
    sub = repeated_square(n - 1)
    return Mul(sub, sub)

def exp_log_power(n: int) -> EMLExpr:
    """x^(2^n) via exp-log: exp(2^n * log(x)), constant depth 3."""
    return Exp(Mul(Const(2**n), Log(Var())))

def iter_exp(n: int) -> EMLExpr:
    """exp^n(x) = exp(exp(...(exp(x))...)), depth n."""
    if n == 0:
        return Var()
    return Exp(iter_exp(n - 1))


# ── Symbolic differentiation ─────────────────────────────────────────────────

def deriv(e: EMLExpr) -> EMLExpr:
    """Symbolic derivative d/dx of an EML expression."""
    if isinstance(e, Const):
        return Const(0)
    elif isinstance(e, Var):
        return Const(1)
    elif isinstance(e, Add):
        return Add(deriv(e.e1), deriv(e.e2))
    elif isinstance(e, Mul):
        return Add(Mul(deriv(e.e1), e.e2), Mul(e.e1, deriv(e.e2)))
    elif isinstance(e, Exp):
        return Mul(Exp(e.e), deriv(e.e))
    elif isinstance(e, Log):
        # d/dx[log(f)] = f'/f, represented as f' * exp(-log(f))
        return Mul(deriv(e.e), Exp(Mul(Const(-1), Log(e.e))))
    raise ValueError(f"Unknown expression type: {type(e)}")


# ── Demo ──────────────────────────────────────────────────────────────────────

def demo_depth_gap():
    """Demonstrate the exponential depth gap between polynomial and EML."""
    print("=" * 60)
    print("DEPTH GAP: Polynomial Squaring vs Exp-Log Power")
    print("=" * 60)
    print(f"{'n':>4} {'poly depth':>12} {'poly size':>12} {'EML depth':>12} {'EML size':>12}")
    print("-" * 60)
    for n in range(1, 11):
        rs = repeated_square(n)
        el = exp_log_power(n)
        print(f"{n:>4} {rs.depth():>12} {rs.size():>12} {el.depth():>12} {el.size():>12}")
    print()
    print("Key insight: Polynomial depth grows linearly, EML stays constant!")
    print(f"At n=10: poly needs depth 10, size {2**11-1}, but EML needs depth 3, size 5.")

def demo_universal_approximation():
    """Demonstrate polynomial approximation of sin(x) on [0, π]."""
    print("\n" + "=" * 60)
    print("UNIVERSAL APPROXIMATION: Taylor polynomial for sin(x)")
    print("=" * 60)

    # Build Taylor polynomial for sin(x) as EML expression
    # sin(x) ≈ x - x³/6 + x⁵/120 - x⁷/5040
    def build_taylor_sin(terms: int) -> EMLExpr:
        result = Const(0)
        for k in range(terms):
            coeff = (-1)**k / math.factorial(2*k + 1)
            # x^(2k+1) via repeated multiplication
            power = Var()
            for _ in range(2*k):
                power = Mul(power, Var())
            term = Mul(Const(coeff), power)
            result = Add(result, term)
        return result

    for terms in [1, 2, 3, 4, 5]:
        taylor = build_taylor_sin(terms)
        max_err = max(abs(taylor.eval(x) - math.sin(x))
                      for x in [i * math.pi / 100 for i in range(101)])
        print(f"  {2*terms-1}-term Taylor: depth={taylor.depth():>3}, "
              f"size={taylor.size():>5}, max error={max_err:.6e}")

def demo_derivative():
    """Demonstrate derivative computation."""
    print("\n" + "=" * 60)
    print("DERIVATIVE COMPUTATION in EML")
    print("=" * 60)

    for n in range(1, 6):
        ie = iter_exp(n)
        d = deriv(ie)
        print(f"  d/dx[exp^{n}(x)]: depth={ie.depth()}->{d.depth()}, "
              f"size={ie.size()}->{d.size()}")

    # Verify derivative of exp(x) is exp(x)
    print("\n  Verification: d/dx[exp(x)] at x=1:")
    e = Exp(Var())
    de = deriv(e)
    print(f"    exp(1) = {math.exp(1):.6f}")
    print(f"    d/dx[exp(x)](1) = {de.eval(1):.6f}")
    print(f"    Match: {abs(de.eval(1) - math.exp(1)) < 1e-10}")

    # Derivative product formula
    print("\n  Product formula for d/dx[exp^n(x)]:")
    for n in range(1, 5):
        ie = iter_exp(n)
        d = deriv(ie)
        x = 0.5
        # Product of exp(iteratedExp(k, x)) for k = 0..n-1
        product = 1.0
        val = x
        for k in range(n):
            product *= math.exp(val)
            val = math.exp(val)
        print(f"    n={n}: deriv={d.eval(x):.6e}, product={product:.6e}, "
              f"match={abs(d.eval(x) - product) < 1e-6}")

def demo_kolmogorov_connection():
    """Demonstrate the connection to descriptive complexity."""
    print("\n" + "=" * 60)
    print("DESCRIPTIVE COMPLEXITY: Size as Kolmogorov proxy")
    print("=" * 60)

    # Show that depth < size always
    print("\n  Verifying depth < size for all constructions:")
    constructions = [
        ("const(3.14)", Const(3.14)),
        ("var", Var()),
        ("exp(var)", Exp(Var())),
        ("exp(exp(var))", Exp(Exp(Var()))),
        ("var * var", Mul(Var(), Var())),
        ("repeated_square(5)", repeated_square(5)),
        ("exp_log_power(5)", exp_log_power(5)),
        ("iter_exp(5)", iter_exp(5)),
    ]
    for name, expr in constructions:
        d, s = expr.depth(), expr.size()
        print(f"    {name:>25}: depth={d:>3}, size={s:>5}, depth < size: {d < s}")

if __name__ == "__main__":
    demo_depth_gap()
    demo_universal_approximation()
    demo_derivative()
    demo_kolmogorov_connection()


#!/usr/bin/env python3
"""
Visualization: EML Depth Gap Theorem

Shows the exponential depth advantage of EML (exp-log) over polynomial
circuits for computing x^(2^n).
"""

import matplotlib.pyplot as plt
import numpy as np

def main():
    ns = list(range(1, 16))
    poly_depths = ns  # depth = n
    poly_sizes = [2**(n+1) - 1 for n in ns]
    eml_depths = [3] * len(ns)  # constant depth 3
    eml_sizes = [5] * len(ns)   # constant size 5

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Depth comparison
    ax = axes[0]
    ax.plot(ns, poly_depths, 'ro-', linewidth=2, markersize=8, label='Polynomial (repeated squaring)')
    ax.plot(ns, eml_depths, 'bs-', linewidth=2, markersize=8, label='EML (exp-log)')
    ax.fill_between(ns, eml_depths, poly_depths, alpha=0.2, color='green', label='Depth gap')
    ax.set_xlabel('n (computing x^(2^n))', fontsize=14)
    ax.set_ylabel('Circuit Depth', fontsize=14)
    ax.set_title('Depth Gap Theorem', fontsize=16)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(ns[::2])

    # Size comparison (log scale)
    ax = axes[1]
    ax.semilogy(ns, poly_sizes, 'ro-', linewidth=2, markersize=8, label='Polynomial (repeated squaring)')
    ax.semilogy(ns, eml_sizes, 'bs-', linewidth=2, markersize=8, label='EML (exp-log)')
    ax.fill_between(ns, eml_sizes, poly_sizes, alpha=0.2, color='green', label='Size gap')
    ax.set_xlabel('n (computing x^(2^n))', fontsize=14)
    ax.set_ylabel('Circuit Size (log scale)', fontsize=14)
    ax.set_title('Size Gap Theorem', fontsize=16)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(ns[::2])

    plt.tight_layout()
    plt.savefig('depth_gap_theorem.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved depth_gap_theorem.png")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: EML Derivative Growth and Product Formula

Shows how the derivative of iterated exponentials grows according to
the product formula: d/dx[exp^n(x)] = prod_{k=0}^{n-1} exp(exp^k(x))
"""

import matplotlib.pyplot as plt
import numpy as np
import math

def iterated_exp(n, x):
    """Compute exp^n(x) = exp(exp(...(exp(x))...))."""
    val = x
    for _ in range(n):
        val = min(val, 700)  # prevent overflow
        val = math.exp(val)
    return val

def deriv_iterated_exp(n, x):
    """Product formula: d/dx[exp^n(x)] = prod_{k=0}^{n-1} exp(exp^k(x))."""
    product = 1.0
    val = x
    for k in range(n):
        product *= math.exp(val)
        val = math.exp(min(val, 700))
    return product

def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Iterated exp values at small x
    ax = axes[0]
    xs = np.linspace(-2, 1, 200)
    for n in range(1, 5):
        ys = [iterated_exp(n, x) for x in xs]
        ax.plot(xs, ys, linewidth=2, label=f'exp^{n}(x)')
    ax.set_xlabel('x', fontsize=14)
    ax.set_ylabel('exp^n(x)', fontsize=14)
    ax.set_title('Iterated Exponentials', fontsize=16)
    ax.set_ylim(-1, 50)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)

    # Plot 2: Derivative product formula factors
    ax = axes[1]
    x_val = 0.0
    max_n = 8
    depths = list(range(1, max_n + 1))
    sizes = [n + 1 for n in depths]
    deriv_sizes_at_zero = []
    for n in depths:
        # Size of derivative expression for iterExp(n)
        # deriv(iterExp(n)) has recursive structure
        # size grows roughly as n*(n+3)/2
        s = 0
        for k in range(n):
            s += (n - k) + 2  # approximate
        deriv_sizes_at_zero.append(s)

    # Theoretical bound: 2 * size = 2 * (n + 1)
    theoretical_bound = [2 * (n + 1) for n in depths]

    ax.bar([d - 0.2 for d in depths], sizes, width=0.35, color='steelblue',
           label='Original size', alpha=0.8)
    ax.bar([d + 0.2 for d in depths], deriv_sizes_at_zero, width=0.35,
           color='coral', label='Derivative size (approx)', alpha=0.8)
    ax.plot(depths, theoretical_bound, 'k--', linewidth=2,
            label='Depth bound: 2·size', marker='o')
    ax.set_xlabel('Number of exp layers (n)', fontsize=14)
    ax.set_ylabel('Size / Depth bound', fontsize=14)
    ax.set_title('Derivative Depth vs Size Bound', fontsize=16)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, axis='y')
    ax.set_xticks(depths)

    plt.tight_layout()
    plt.savefig('derivative_growth.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved derivative_growth.png")

if __name__ == "__main__":
    main()
