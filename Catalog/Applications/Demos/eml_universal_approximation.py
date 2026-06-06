#!/usr/bin/env python3
"""
EML Filtered Approximation Algebra — Interactive Demo

Demonstrates the key results of the EML depth filtration:
1. EML expression evaluation
2. Depth filtration hierarchy visualization
3. Approximation chain convergence
4. Information decay through layers
"""

import math
from typing import Callable


# --- EML Expression Tree ---

class EMLExpr:
    """EML expression tree node."""
    pass

class Var(EMLExpr):
    def eval(self, x: float) -> float:
        return x
    def size(self) -> int:
        return 1
    def eml_depth(self) -> int:
        return 0
    def __repr__(self):
        return "x"

class Const(EMLExpr):
    def __init__(self, c: float):
        self.c = c
    def eval(self, x: float) -> float:
        return self.c
    def size(self) -> int:
        return 1
    def eml_depth(self) -> int:
        return 0
    def __repr__(self):
        return f"{self.c:.4g}"

class Add(EMLExpr):
    def __init__(self, a: EMLExpr, b: EMLExpr):
        self.a, self.b = a, b
    def eval(self, x: float) -> float:
        return self.a.eval(x) + self.b.eval(x)
    def size(self) -> int:
        return 1 + self.a.size() + self.b.size()
    def eml_depth(self) -> int:
        return max(self.a.eml_depth(), self.b.eml_depth())
    def __repr__(self):
        return f"({self.a} + {self.b})"

class Mul(EMLExpr):
    def __init__(self, a: EMLExpr, b: EMLExpr):
        self.a, self.b = a, b
    def eval(self, x: float) -> float:
        return self.a.eval(x) * self.b.eval(x)
    def size(self) -> int:
        return 1 + self.a.size() + self.b.size()
    def eml_depth(self) -> int:
        return max(self.a.eml_depth(), self.b.eml_depth())
    def __repr__(self):
        return f"({self.a} * {self.b})"

class EML(EMLExpr):
    """eml(a, b) = a * exp(b)"""
    def __init__(self, a: EMLExpr, b: EMLExpr):
        self.a, self.b = a, b
    def eval(self, x: float) -> float:
        bv = self.b.eval(x)
        if bv > 500:  # overflow protection
            return float('inf')
        return self.a.eval(x) * math.exp(bv)
    def size(self) -> int:
        return 1 + self.a.size() + self.b.size()
    def eml_depth(self) -> int:
        return 1 + max(self.a.eml_depth(), self.b.eml_depth())
    def __repr__(self):
        return f"eml({self.a}, {self.b})"


def iter_exp(n: int, x: float) -> float:
    """Iterated exponential: exp^n(x)."""
    result = x
    for _ in range(n):
        if result > 500:
            return float('inf')
        result = math.exp(result)
    return result


def eml_expr_iter_exp(n: int) -> EMLExpr:
    """Canonical EML expression for exp^n(x)."""
    if n == 0:
        return Var()
    return EML(Const(1.0), eml_expr_iter_exp(n - 1))


def demo_filtration_hierarchy():
    """Demonstrate the strict depth hierarchy."""
    print("=" * 60)
    print("EML DEPTH FILTRATION HIERARCHY")
    print("=" * 60)
    
    for n in range(5):
        expr = eml_expr_iter_exp(n)
        print(f"\nLevel {n}: iterExp({n})")
        print(f"  Expression: {expr}")
        print(f"  Size: {expr.size()} (expected: {2*n + 1})")
        print(f"  EML Depth: {expr.eml_depth()} (expected: {n})")
        print(f"  Depth × Size = {expr.eml_depth() * expr.size()}")
        
        # Evaluate at test points
        test_x = 0.5
        val = expr.eval(test_x)
        ref = iter_exp(n, test_x)
        print(f"  eval(0.5) = {val:.6f} (reference: {ref:.6f})")


def demo_filtration_closure():
    """Demonstrate closure properties of the filtration."""
    print("\n" + "=" * 60)
    print("FILTRATION CLOSURE PROPERTIES")
    print("=" * 60)
    
    # Level 0: purely algebraic
    f = Add(Var(), Const(1.0))  # x + 1
    g = Mul(Var(), Var())        # x^2
    fg_add = Add(f, g)           # x + 1 + x^2
    fg_mul = Mul(f, g)           # (x+1) * x^2
    
    print(f"\nLevel 0 examples:")
    print(f"  f = {f}, depth = {f.eml_depth()}")
    print(f"  g = {g}, depth = {g.eml_depth()}")
    print(f"  f + g = {fg_add}, depth = {fg_add.eml_depth()}")
    print(f"  f * g = {fg_mul}, depth = {fg_mul.eml_depth()}")
    
    # Level 1: one layer of transcendence
    h = EML(Const(1.0), Var())  # exp(x)
    fh = Add(f, h)              # (x+1) + exp(x)
    
    print(f"\nLevel 1 examples:")
    print(f"  h = {h}, depth = {h.eml_depth()}")
    print(f"  f + h = {fh}, depth = {fh.eml_depth()}")
    
    # Composition: depth adds
    comp = EML(Const(1.0), EML(Const(1.0), Var()))  # exp(exp(x))
    print(f"\nComposition (depth adds):")
    print(f"  exp(exp(x)) = {comp}, depth = {comp.eml_depth()}")


def demo_approximation_chain():
    """Demonstrate approximation chain convergence."""
    print("\n" + "=" * 60)
    print("APPROXIMATION CHAIN CONVERGENCE")
    print("=" * 60)
    
    # Approximate exp(x) on [0, 1] with Taylor polynomials
    # Taylor: exp(x) ≈ 1 + x + x²/2 + ... + xⁿ/n!
    
    target = lambda x: math.exp(x)
    
    print(f"\nTarget: exp(x) on [0, 1]")
    print(f"{'Terms':>6} {'Size':>6} {'Max Error':>12} {'Error Ratio':>12}")
    
    prev_error = None
    for n_terms in range(1, 9):
        # Build Horner-form polynomial
        coeffs = [1.0 / math.factorial(i) for i in range(n_terms)]
        
        # Build EML expression (Horner's method)
        expr: EMLExpr = Const(coeffs[-1])
        for i in range(len(coeffs) - 2, -1, -1):
            expr = Add(Const(coeffs[i]), Mul(Var(), expr))
        
        # Measure error
        max_error = 0.0
        for j in range(101):
            x = j / 100.0
            error = abs(target(x) - expr.eval(x))
            max_error = max(max_error, error)
        
        ratio = f"{prev_error / max_error:.2f}x" if prev_error and max_error > 0 else "—"
        print(f"{n_terms:>6} {expr.size():>6} {max_error:>12.2e} {ratio:>12}")
        prev_error = max_error


def demo_information_decay():
    """Demonstrate information decay through layers."""
    print("\n" + "=" * 60)
    print("INFORMATION DECAY THROUGH LAYERS")
    print("=" * 60)
    
    K = 100  # initial information
    
    for alpha in [0.9, 0.5, 0.1]:
        print(f"\nContraction factor α = {alpha}:")
        print(f"  {'Layers':>8} {'Retained Info':>15} {'Fraction':>10}")
        for l in range(8):
            retained = alpha ** l * K
            print(f"  {l:>8} {retained:>15.4f} {retained/K:>10.4f}")


def demo_depth_size_tradeoff():
    """Demonstrate the depth-size product bound."""
    print("\n" + "=" * 60)
    print("DEPTH × SIZE PRODUCT FOR EXPONENTIAL TOWERS")
    print("=" * 60)
    
    print(f"\n{'n':>4} {'Depth':>8} {'Size':>8} {'D×S':>10} {'n(2n+1)':>10}")
    for n in range(1, 8):
        expr = eml_expr_iter_exp(n)
        d = expr.eml_depth()
        s = expr.size()
        print(f"{n:>4} {d:>8} {s:>8} {d*s:>10} {n*(2*n+1):>10}")


if __name__ == "__main__":
    demo_filtration_hierarchy()
    demo_filtration_closure()
    demo_approximation_chain()
    demo_information_decay()
    demo_depth_size_tradeoff()


#!/usr/bin/env python3
"""
Visualization: EML Approximation Spectrum

Shows how approximation quality improves with expression size,
and the subadditivity of description complexity.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def horner_eval(coeffs: list, x: float) -> float:
    """Evaluate polynomial via Horner's method."""
    result = coeffs[-1]
    for i in range(len(coeffs) - 2, -1, -1):
        result = coeffs[i] + x * result
    return result


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Panel 1: Approximation chain convergence for exp(x) on [0, 2]
    ax = axes[0]
    target = math.exp
    a, b = 0, 2
    
    n_terms_list = list(range(2, 15))
    errors = []
    sizes = []
    
    for n_terms in n_terms_list:
        coeffs = [1.0 / math.factorial(i) for i in range(n_terms)]
        size = 2 * n_terms - 1  # Horner size
        
        max_error = 0
        for j in range(201):
            x = a + (b - a) * j / 200
            error = abs(target(x) - horner_eval(coeffs, x))
            max_error = max(max_error, error)
        
        errors.append(max_error)
        sizes.append(size)
    
    ax.semilogy(sizes, errors, 'b-o', linewidth=2, markersize=5)
    ax.set_xlabel('EML Expression Size', fontsize=12)
    ax.set_ylabel('Max Error on [0, 2]', fontsize=12)
    ax.set_title('Approximation Spectrum of $e^x$', fontsize=13, fontweight='bold')
    ax.grid(True, alpha=0.3)
    
    # Panel 2: Comparison of different functions
    ax = axes[1]
    
    functions = {
        '$e^x$': (math.exp, lambda n: [1/math.factorial(i) for i in range(n)]),
        '$\\sin(x)$': (math.sin, lambda n: [(-1)**((i-1)//2)/math.factorial(i) if i % 2 == 1 else 0 for i in range(n)]),
        '$\\cos(x)$': (math.cos, lambda n: [(-1)**(i//2)/math.factorial(i) if i % 2 == 0 else 0 for i in range(n)]),
    }
    
    colors_fn = {'$e^x$': '#2196F3', '$\\sin(x)$': '#4CAF50', '$\\cos(x)$': '#FF9800'}
    
    for name, (f, coeff_fn) in functions.items():
        errs = []
        szs = []
        for n in range(3, 18):
            coeffs = coeff_fn(n)
            max_err = 0
            for j in range(201):
                x = j / 100 - 1  # [-1, 1]
                err = abs(f(x) - horner_eval(coeffs, x))
                max_err = max(max_err, err)
            if max_err > 0:
                errs.append(max_err)
                szs.append(2 * n - 1)
        
        ax.semilogy(szs, errs, '-o', color=colors_fn[name], linewidth=2,
                    markersize=4, label=name)
    
    ax.set_xlabel('EML Expression Size', fontsize=12)
    ax.set_ylabel('Max Error on [-1, 1]', fontsize=12)
    ax.set_title('Complexity Spectra Comparison', fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    # Panel 3: Subadditivity illustration
    ax = axes[2]
    
    f1 = math.exp
    f2 = math.sin
    f_sum = lambda x: math.exp(x) + math.sin(x)
    
    n_range = list(range(3, 15))
    err_f1 = []
    err_f2 = []
    err_sum_direct = []
    err_sum_bound = []
    
    for n in n_range:
        # f1 approximation
        c1 = [1/math.factorial(i) for i in range(n)]
        # f2 approximation
        c2 = [(-1)**((i-1)//2)/math.factorial(i) if i % 2 == 1 else 0 for i in range(n)]
        
        # Combined approximation
        c_sum = [c1[i] + c2[i] for i in range(n)]
        
        e1 = max(abs(f1(x/100) - horner_eval(c1, x/100)) for x in range(-100, 101))
        e2 = max(abs(f2(x/100) - horner_eval(c2, x/100)) for x in range(-100, 101))
        e_sum = max(abs(f_sum(x/100) - horner_eval(c_sum, x/100)) for x in range(-100, 101))
        
        err_f1.append(e1)
        err_f2.append(e2)
        err_sum_direct.append(e_sum)
        err_sum_bound.append(e1 + e2)
    
    ax.semilogy(n_range, err_f1, 'b--', linewidth=1.5, label='err($e^x$)')
    ax.semilogy(n_range, err_f2, 'g--', linewidth=1.5, label='err($\\sin x$)')
    ax.semilogy(n_range, err_sum_direct, 'r-o', linewidth=2, markersize=4,
                label='err($e^x + \\sin x$) actual')
    ax.semilogy(n_range, err_sum_bound, 'k:', linewidth=2,
                label='err($e^x$) + err($\\sin x$) bound')
    
    ax.set_xlabel('Taylor Terms', fontsize=12)
    ax.set_ylabel('Max Error on [-1, 1]', fontsize=12)
    ax.set_title('Subadditivity: err(f+g) ≤ err(f) + err(g)',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('eml_approx_spectrum.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved eml_approx_spectrum.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: EML Depth Hierarchy

Shows the strict depth hierarchy of iterated exponential towers,
demonstrating how each level of EML depth accesses genuinely
new function territory.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def iter_exp(n: int, x: float) -> float:
    """Compute exp^n(x) with overflow protection."""
    result = x
    for _ in range(n):
        if result > 500:
            return float('inf')
        result = math.exp(result)
    return result


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Panel 1: Iterated exponentials on [0, 1.5]
    ax = axes[0]
    x_vals = np.linspace(0.01, 1.5, 300)
    colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336', '#9C27B0']
    
    for n in range(5):
        y_vals = []
        for x in x_vals:
            y = iter_exp(n, x)
            y_vals.append(min(y, 50))  # clip for visualization
        ax.plot(x_vals, y_vals, color=colors[n], linewidth=2,
                label=f'$\\exp^{{{n}}}(x)$ [depth {n}]')
    
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('f(x)', fontsize=12)
    ax.set_title('EML Depth Filtration Hierarchy', fontsize=13, fontweight='bold')
    ax.set_ylim(0, 50)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    
    # Panel 2: Size vs Depth for canonical towers
    ax = axes[1]
    ns = list(range(1, 11))
    sizes = [2 * n + 1 for n in ns]
    depths = ns
    products = [n * (2*n + 1) for n in ns]
    
    ax.bar([n - 0.15 for n in ns], sizes, width=0.3, color='#2196F3',
           label='Size (2n+1)', alpha=0.8)
    ax.bar([n + 0.15 for n in ns], depths, width=0.3, color='#4CAF50',
           label='Depth (n)', alpha=0.8)
    
    ax2 = ax.twinx()
    ax2.plot(ns, products, 'r-o', linewidth=2, markersize=4,
             label='Depth × Size', alpha=0.8)
    ax2.set_ylabel('Depth × Size', color='red', fontsize=11)
    ax2.tick_params(axis='y', labelcolor='red')
    
    ax.set_xlabel('Tower Level n', fontsize=12)
    ax.set_ylabel('Nodes', fontsize=12)
    ax.set_title('Size-Depth Tradeoff for $\\exp^n$', fontsize=13, fontweight='bold')
    ax.legend(loc='upper left', fontsize=9)
    ax2.legend(loc='center right', fontsize=9)
    ax.grid(True, alpha=0.3)
    
    # Panel 3: Information decay
    ax = axes[2]
    layers = np.arange(0, 15)
    K = 100
    
    for alpha, color, ls in [(0.9, '#2196F3', '-'), (0.7, '#4CAF50', '--'),
                              (0.5, '#FF9800', '-.'), (0.3, '#F44336', ':')]:
        retained = [alpha ** l * K for l in layers]
        ax.plot(layers, retained, color=color, linewidth=2, linestyle=ls,
                label=f'α = {alpha}')
    
    ax.axhline(y=10, color='gray', linestyle='--', alpha=0.5, linewidth=1)
    ax.text(12, 12, 'threshold = 10', fontsize=9, color='gray')
    
    ax.set_xlabel('Depth (layers)', fontsize=12)
    ax.set_ylabel('Retained Information', fontsize=12)
    ax.set_title('Information Decay: $I(l) = \\alpha^l \\cdot K$',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('eml_depth_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved eml_depth_hierarchy.png")


if __name__ == "__main__":
    main()
