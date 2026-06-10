#!/usr/bin/env python3
"""
EML Universal Approximation — Demonstration

Demonstrates the key concepts of the EML Approximation Filtration:
1. EML expression evaluation and complexity measures
2. Iterated exponential depth separation
3. Information-theoretic decay under contraction
4. Polynomial approximation via Horner's method
"""

import math
from typing import Callable, List, Tuple


# ============================================================
# EML Expression Tree
# ============================================================

class EMLExpr:
    """Base class for EML expression trees."""
    def eval(self, x: float) -> float:
        raise NotImplementedError
    def size(self) -> int:
        raise NotImplementedError
    def depth(self) -> int:
        raise NotImplementedError
    def trans_depth(self) -> int:
        raise NotImplementedError
    def is_algebraic(self) -> bool:
        raise NotImplementedError

class Const(EMLExpr):
    def __init__(self, c: float): self.c = c
    def eval(self, x: float) -> float: return self.c
    def size(self) -> int: return 1
    def depth(self) -> int: return 0
    def trans_depth(self) -> int: return 0
    def is_algebraic(self) -> bool: return True
    def __repr__(self): return f"{self.c}"

class Var(EMLExpr):
    def eval(self, x: float) -> float: return x
    def size(self) -> int: return 1
    def depth(self) -> int: return 0
    def trans_depth(self) -> int: return 0
    def is_algebraic(self) -> bool: return True
    def __repr__(self): return "x"

class Add(EMLExpr):
    def __init__(self, a: EMLExpr, b: EMLExpr): self.a, self.b = a, b
    def eval(self, x: float) -> float: return self.a.eval(x) + self.b.eval(x)
    def size(self) -> int: return 1 + self.a.size() + self.b.size()
    def depth(self) -> int: return 1 + max(self.a.depth(), self.b.depth())
    def trans_depth(self) -> int: return max(self.a.trans_depth(), self.b.trans_depth())
    def is_algebraic(self) -> bool: return self.a.is_algebraic() and self.b.is_algebraic()
    def __repr__(self): return f"({self.a} + {self.b})"

class Mul(EMLExpr):
    def __init__(self, a: EMLExpr, b: EMLExpr): self.a, self.b = a, b
    def eval(self, x: float) -> float: return self.a.eval(x) * self.b.eval(x)
    def size(self) -> int: return 1 + self.a.size() + self.b.size()
    def depth(self) -> int: return 1 + max(self.a.depth(), self.b.depth())
    def trans_depth(self) -> int: return max(self.a.trans_depth(), self.b.trans_depth())
    def is_algebraic(self) -> bool: return self.a.is_algebraic() and self.b.is_algebraic()
    def __repr__(self): return f"({self.a} * {self.b})"

class Exp(EMLExpr):
    def __init__(self, a: EMLExpr): self.a = a
    def eval(self, x: float) -> float: return math.exp(self.a.eval(x))
    def size(self) -> int: return 1 + self.a.size()
    def depth(self) -> int: return 1 + self.a.depth()
    def trans_depth(self) -> int: return 1 + self.a.trans_depth()
    def is_algebraic(self) -> bool: return False
    def __repr__(self): return f"exp({self.a})"

class Log(EMLExpr):
    def __init__(self, a: EMLExpr): self.a = a
    def eval(self, x: float) -> float:
        v = self.a.eval(x)
        return math.log(v) if v > 0 else 0.0
    def size(self) -> int: return 1 + self.a.size()
    def depth(self) -> int: return 1 + self.a.depth()
    def trans_depth(self) -> int: return 1 + self.a.trans_depth()
    def is_algebraic(self) -> bool: return False
    def __repr__(self): return f"log({self.a})"


# ============================================================
# Constructors
# ============================================================

def eml_iter_exp(n: int) -> EMLExpr:
    """Canonical EML expression for n-fold iterated exponential."""
    if n == 0:
        return Var()
    return Exp(eml_iter_exp(n - 1))

def iter_exp(n: int, x: float) -> float:
    """Iterated exponential: E_0(x) = x, E_{n+1}(x) = exp(E_n(x))."""
    result = x
    for _ in range(n):
        result = math.exp(result)
    return result

def eml_horner(coeffs: List[float]) -> EMLExpr:
    """Polynomial via Horner's method: c_0 + x*(c_1 + x*(c_2 + ...))."""
    if not coeffs:
        return Const(0.0)
    if len(coeffs) == 1:
        return Const(coeffs[0])
    return Add(Const(coeffs[0]), Mul(Var(), eml_horner(coeffs[1:])))


# ============================================================
# Approximation
# ============================================================

def uniform_approx_error(f: Callable, e: EMLExpr, a: float, b: float,
                          num_points: int = 1000) -> float:
    """Compute max |f(x) - e.eval(x)| over [a,b]."""
    xs = [a + (b - a) * i / num_points for i in range(num_points + 1)]
    return max(abs(f(xi) - e.eval(xi)) for xi in xs)


def retained_info(alpha: float, l: int, K: int) -> float:
    """Retained symbolic information after l layers with contraction alpha."""
    return alpha**l * K


# ============================================================
# Demo 1: Expression Properties
# ============================================================

def demo_expression_properties():
    print("=" * 60)
    print("Demo 1: EML Expression Properties")
    print("=" * 60)

    # Build some expressions
    exprs = [
        ("x", Var()),
        ("3.14", Const(3.14)),
        ("x + 1", Add(Var(), Const(1))),
        ("x * x", Mul(Var(), Var())),
        ("exp(x)", Exp(Var())),
        ("exp(exp(x))", Exp(Exp(Var()))),
        ("exp(exp(exp(x)))", Exp(Exp(Exp(Var())))),
        ("log(exp(x))", Log(Exp(Var()))),
    ]

    print(f"\n{'Expression':<25} {'Size':>5} {'Depth':>6} {'TransD':>7} {'Alg?':>5} {'eval(1)':>12}")
    print("-" * 65)
    for name, e in exprs:
        try:
            val = e.eval(1.0)
            val_str = f"{val:.4f}"
        except (OverflowError, ValueError):
            val_str = "overflow"
        print(f"{name:<25} {e.size():>5} {e.depth():>6} {e.trans_depth():>7} "
              f"{'yes' if e.is_algebraic() else 'no':>5} {val_str:>12}")


# ============================================================
# Demo 2: Iterated Exponential Tower
# ============================================================

def demo_iter_exp():
    print("\n" + "=" * 60)
    print("Demo 2: Iterated Exponential Depth Separation")
    print("=" * 60)

    print(f"\n{'n':>3} {'Size':>6} {'Depth':>6} {'TransD':>7} {'E_n(0.5)':>15}")
    print("-" * 42)
    for n in range(7):
        e = eml_iter_exp(n)
        try:
            val = iter_exp(n, 0.5)
            val_str = f"{val:.6f}"
        except OverflowError:
            val_str = "overflow"
        print(f"{n:>3} {e.size():>6} {e.depth():>6} {e.trans_depth():>7} {val_str:>15}")

    print("\nKey insight: transDepth = n for E_n, matching our theorem")
    print("iterExp_transDepth_separation.")


# ============================================================
# Demo 3: Information Decay
# ============================================================

def demo_info_decay():
    print("\n" + "=" * 60)
    print("Demo 3: Information-Theoretic Decay")
    print("=" * 60)

    K = 100  # initial complexity
    alphas = [0.9, 0.7, 0.5, 0.3]

    print(f"\nRetained information I(α, l) = α^l × K, K = {K}")
    print(f"\n{'Layers':>7}", end="")
    for a in alphas:
        print(f"  α={a:.1f}", end="")
    print()
    print("-" * 45)

    for l in range(11):
        print(f"{l:>7}", end="")
        for a in alphas:
            info = retained_info(a, l, K)
            print(f"  {info:>6.2f}", end="")
        print()

    print("\nKey insight: geometric decay, matching retainedInfo_geometric_decay.")


# ============================================================
# Demo 4: Polynomial Approximation
# ============================================================

def demo_polynomial_approx():
    print("\n" + "=" * 60)
    print("Demo 4: Polynomial Approximation of exp(x) on [0,1]")
    print("=" * 60)

    # Taylor coefficients of exp(x)
    for degree in [1, 2, 3, 5, 8, 12]:
        coeffs = [1.0 / math.factorial(i) for i in range(degree + 1)]
        poly = eml_horner(coeffs)
        error = uniform_approx_error(math.exp, poly, 0, 1)
        print(f"  Degree {degree:>2}: size={poly.size():>3}, "
              f"depth={poly.depth():>2}, "
              f"transD={poly.trans_depth()}, "
              f"max error={error:.2e}")

    print("\nAlgebraic approximants have transDepth = 0.")
    print("Adding a single exp() node jumps transDepth to 1.")


# ============================================================
# Demo 5: Compositional Closure
# ============================================================

def demo_compositional():
    print("\n" + "=" * 60)
    print("Demo 5: Compositional Size Bounds")
    print("=" * 60)

    e1 = eml_horner([1, 2, 1])  # 1 + 2x + x²
    e2 = Exp(Var())              # exp(x)

    e_sum = Add(e1, e2)
    print(f"\n  f = {e1}, size={e1.size()}, depth={e1.depth()}")
    print(f"  g = {e2}, size={e2.size()}, depth={e2.depth()}")
    print(f"  f+g = {e_sum}")
    print(f"    size={e_sum.size()} ≤ {e1.size()} + {e2.size()} + 1 = {e1.size() + e2.size() + 1}")
    print(f"    depth={e_sum.depth()}")
    print(f"    transD={e_sum.trans_depth()}")
    print(f"\n  Verified: EMLApprox_add gives size bound n + m + 1.")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    demo_expression_properties()
    demo_iter_exp()
    demo_info_decay()
    demo_polynomial_approx()
    demo_compositional()

    print("\n" + "=" * 60)
    print("Summary of Formally Verified Results (Lean 4)")
    print("=" * 60)
    print("""
  1. EMLApprox_add: Additive closure with size bound n + m + 1
  2. emlMinDepth_le_emlDescComplexity: Depth ≤ description complexity
  3. iterExp_exact_complexity: iterExp n uses exactly depth n, size n+1
  4. retainedInfo_geometric_decay: Information contracts as α^l
  5. depth_information_tradeoff: K ≥ threshold / α^l
  6. EMLExpr.transDepth_zero_isAlgebraic: transDepth 0 ⟺ algebraic
  7. EMLExpr.eval_iterSubst: k-fold composition = function iteration
  8. EMLExpr.depth_iterSubst_le: Composition depth ≤ k × depth
    """)


#!/usr/bin/env python3
"""
Visualization: EML Depth Spectrum and Information Decay

Produces two plots:
1. Iterated exponential growth with depth annotations
2. Information-theoretic decay under different contraction rates
"""

import math

def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available, skipping visualization")
        return

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # ---- Plot 1: Iterated exponential values ----
    ax1 = axes[0]
    xs = [i * 0.05 for i in range(21)]  # [0, 1] in steps of 0.05
    for n in range(5):
        ys = []
        for x in xs:
            try:
                val = x
                for _ in range(n):
                    val = math.exp(val)
                if val > 1e6:
                    val = float('nan')
            except OverflowError:
                val = float('nan')
            ys.append(val)
        label = f'E_{n}(x)' if n > 0 else 'E₀(x) = x'
        ax1.plot(xs, ys, label=label, linewidth=2)

    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('E_n(x)', fontsize=12)
    ax1.set_title('Iterated Exponentials: transDepth = n', fontsize=13)
    ax1.set_ylim(0, 50)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Add annotations
    ax1.annotate('Each exp() layer\nadds transDepth +1',
                xy=(0.6, 15), fontsize=9,
                bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    # ---- Plot 2: Information decay ----
    ax2 = axes[1]
    K = 100
    depths = list(range(21))
    alphas = [0.95, 0.8, 0.6, 0.4, 0.2]
    colors = ['#e41a1c', '#ff7f00', '#4daf4a', '#377eb8', '#984ea3']

    for alpha, color in zip(alphas, colors):
        infos = [alpha**l * K for l in depths]
        ax2.plot(depths, infos, 'o-', color=color, label=f'α = {alpha}',
                markersize=3, linewidth=1.5)

    ax2.set_xlabel('Depth (layers)', fontsize=12)
    ax2.set_ylabel('Retained Information', fontsize=12)
    ax2.set_title(f'Information Decay: I(α,l) = α^l × K,  K={K}', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, 105)

    # Add theorem reference
    ax2.annotate('retainedInfo_geometric_decay:\nI(α,l) ≤ α·K for l ≥ 1',
                xy=(10, 70), fontsize=9,
                bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    plt.tight_layout()
    plt.savefig('eml_depth_spectrum.png', dpi=150, bbox_inches='tight')
    print("Saved: eml_depth_spectrum.png")
    plt.close()


if __name__ == "__main__":
    main()
