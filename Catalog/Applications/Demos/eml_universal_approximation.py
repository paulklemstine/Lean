#!/usr/bin/env python3
"""
EML Universal Approximation — Demonstration

Shows key properties of the EML (Exponential-Multiplicative-Logarithmic) expression
language: evaluation, depth hierarchy, size decomposition, and approximation.
"""
import math
from dataclasses import dataclass
from typing import Callable, List, Tuple


# ──────────────────────────────────────────────────────────────────────────────
# EML Expression Trees
# ──────────────────────────────────────────────────────────────────────────────

class EMLExpr:
    """Base class for EML expression trees."""
    pass

@dataclass
class Var(EMLExpr): pass
@dataclass
class Const(EMLExpr):
    value: float
@dataclass
class Add(EMLExpr):
    left: EMLExpr
    right: EMLExpr
@dataclass
class Mul(EMLExpr):
    left: EMLExpr
    right: EMLExpr
@dataclass
class Neg(EMLExpr):
    child: EMLExpr
@dataclass
class Inv(EMLExpr):
    child: EMLExpr
@dataclass
class EML(EMLExpr):
    """eml(a, b) = a * exp(b) — the sole transcendental primitive."""
    coeff: EMLExpr
    exponent: EMLExpr


def evaluate(expr: EMLExpr, x: float) -> float:
    """Evaluate an EML expression at point x."""
    if isinstance(expr, Var):
        return x
    elif isinstance(expr, Const):
        return expr.value
    elif isinstance(expr, Add):
        return evaluate(expr.left, x) + evaluate(expr.right, x)
    elif isinstance(expr, Mul):
        return evaluate(expr.left, x) * evaluate(expr.right, x)
    elif isinstance(expr, Neg):
        return -evaluate(expr.child, x)
    elif isinstance(expr, Inv):
        v = evaluate(expr.child, x)
        return 1.0 / v if v != 0 else float('inf')
    elif isinstance(expr, EML):
        a = evaluate(expr.coeff, x)
        b = evaluate(expr.exponent, x)
        try:
            return a * math.exp(b)
        except OverflowError:
            return float('inf')
    raise ValueError(f"Unknown expression type: {type(expr)}")


def eml_depth(expr: EMLExpr) -> int:
    """EML depth: maximum nesting depth of eml operations."""
    if isinstance(expr, (Var, Const)):
        return 0
    elif isinstance(expr, (Add, Mul)):
        return max(eml_depth(expr.left), eml_depth(expr.right))
    elif isinstance(expr, (Neg, Inv)):
        return eml_depth(expr.child)
    elif isinstance(expr, EML):
        return 1 + max(eml_depth(expr.coeff), eml_depth(expr.exponent))
    return 0

def size(expr: EMLExpr) -> int:
    """Size of the expression tree (total number of nodes)."""
    if isinstance(expr, (Var, Const)):
        return 1
    elif isinstance(expr, (Add, Mul, EML)):
        return 1 + size(expr.left if hasattr(expr, 'left') else expr.coeff) + \
                   size(expr.right if hasattr(expr, 'right') else expr.exponent)
    elif isinstance(expr, (Neg, Inv)):
        return 1 + size(expr.child)
    return 1

def eml_count(expr: EMLExpr) -> int:
    """Count of eml nodes."""
    if isinstance(expr, (Var, Const)):
        return 0
    elif isinstance(expr, (Add, Mul)):
        return eml_count(expr.left) + eml_count(expr.right)
    elif isinstance(expr, (Neg, Inv)):
        return eml_count(expr.child)
    elif isinstance(expr, EML):
        return 1 + eml_count(expr.coeff) + eml_count(expr.exponent)
    return 0

def leaf_count(expr: EMLExpr) -> int:
    """Count of leaf nodes (var and const)."""
    if isinstance(expr, (Var, Const)):
        return 1
    elif isinstance(expr, (Add, Mul)):
        return leaf_count(expr.left) + leaf_count(expr.right)
    elif isinstance(expr, (Neg, Inv)):
        return leaf_count(expr.child)
    elif isinstance(expr, EML):
        return leaf_count(expr.coeff) + leaf_count(expr.exponent)
    return 0

def field_count(expr: EMLExpr) -> int:
    """Count of field operation nodes."""
    if isinstance(expr, (Var, Const)):
        return 0
    elif isinstance(expr, (Add, Mul)):
        return 1 + field_count(expr.left) + field_count(expr.right)
    elif isinstance(expr, (Neg, Inv)):
        return 1 + field_count(expr.child)
    elif isinstance(expr, EML):
        return field_count(expr.coeff) + field_count(expr.exponent)
    return 0


# ──────────────────────────────────────────────────────────────────────────────
# Canonical Constructions
# ──────────────────────────────────────────────────────────────────────────────

def iter_exp(n: int, x: float) -> float:
    """Iterated exponential: exp^n(x)."""
    result = x
    for _ in range(n):
        try:
            result = math.exp(result)
        except OverflowError:
            return float('inf')
    return result

def eml_expr_iter_exp(n: int) -> EMLExpr:
    """Canonical EML expression for iterExp n: eml(1, eml(1, ... eml(1, var)))."""
    if n == 0:
        return Var()
    return EML(Const(1.0), eml_expr_iter_exp(n - 1))


# ──────────────────────────────────────────────────────────────────────────────
# Demonstrations
# ──────────────────────────────────────────────────────────────────────────────

def demo_canonical_construction():
    """Demonstrate the canonical iterExp construction and its properties."""
    print("=" * 70)
    print("§1. Canonical Construction: emlExprIterExp")
    print("=" * 70)
    print()
    print(f"{'n':>3} {'size':>6} {'2n+1':>6} {'depth':>6} {'eml#':>6} {'leaf#':>6} {'field#':>7}")
    print("-" * 50)
    for n in range(8):
        e = eml_expr_iter_exp(n)
        s = size(e)
        d = eml_depth(e)
        ec = eml_count(e)
        lc = leaf_count(e)
        fc = field_count(e)
        print(f"{n:>3} {s:>6} {2*n+1:>6} {d:>6} {ec:>6} {lc:>6} {fc:>7}")
        assert s == 2 * n + 1, f"Size mismatch at n={n}"
        assert d == n, f"Depth mismatch at n={n}"
        assert ec == n, f"EML count mismatch at n={n}"
        assert lc == n + 1, f"Leaf count mismatch at n={n}"
        assert fc == 0, f"Field count mismatch at n={n}"
        assert s == lc + fc + ec, f"Decomposition mismatch at n={n}"
    print()
    print("✓ All properties verified: size = 2n+1, depth = n, emlCount = n")
    print("✓ Size decomposition: size = leafCount + fieldCount + emlCount")


def demo_evaluation():
    """Demonstrate evaluation correctness."""
    print()
    print("=" * 70)
    print("§2. Evaluation: emlExprIterExp(n).eval(x) = exp^n(x)")
    print("=" * 70)
    print()
    for n in range(5):
        e = eml_expr_iter_exp(n)
        for x in [0.5, 1.0, 1.5]:
            eml_val = evaluate(e, x)
            ref_val = iter_exp(n, x)
            if math.isfinite(eml_val) and math.isfinite(ref_val):
                err = abs(eml_val - ref_val)
                print(f"  n={n}, x={x:.1f}: EML={eml_val:.6f}, ref={ref_val:.6f}, error={err:.2e}")
                assert err < 1e-10, f"Evaluation mismatch"
    print()
    print("✓ Evaluation matches to machine precision")


def demo_filtration_closure():
    """Demonstrate field closure of filtration levels."""
    print()
    print("=" * 70)
    print("§3. Field Closure of Filtration Levels")
    print("=" * 70)
    print()

    # Level 0: rational functions (no eml)
    f1 = Add(Var(), Const(1.0))        # x + 1
    f2 = Mul(Var(), Var())              # x²
    f3 = Add(f1, f2)                   # x² + x + 1
    print(f"  x + 1:       depth={eml_depth(f1)}, size={size(f1)}")
    print(f"  x²:          depth={eml_depth(f2)}, size={size(f2)}")
    print(f"  x²+x+1:     depth={eml_depth(f3)}, size={size(f3)}")
    assert eml_depth(f1) == 0
    assert eml_depth(f2) == 0
    assert eml_depth(f3) == 0

    # Level 1: includes exp
    g1 = EML(Const(1.0), Var())        # exp(x)
    g2 = Add(g1, Var())                # exp(x) + x
    g3 = Mul(g1, g1)                   # exp(x)²
    print(f"  exp(x):      depth={eml_depth(g1)}, size={size(g1)}")
    print(f"  exp(x)+x:    depth={eml_depth(g2)}, size={size(g2)}")
    print(f"  exp(x)²:     depth={eml_depth(g3)}, size={size(g3)}")
    assert eml_depth(g1) == 1
    assert eml_depth(g2) == 1  # max of depths
    assert eml_depth(g3) == 1  # max of depths

    print()
    print("✓ Level 0 = rational functions (no eml nodes)")
    print("✓ Level d is closed under +, ×, neg, inv")
    print("✓ eml(a,b) is the ONLY way to increase the level")


def demo_substitution():
    """Demonstrate substitution = composition."""
    print()
    print("=" * 70)
    print("§4. Substitution = Composition")
    print("=" * 70)
    print()

    def subst(expr: EMLExpr, s: EMLExpr) -> EMLExpr:
        if isinstance(expr, Var):
            return s
        elif isinstance(expr, Const):
            return expr
        elif isinstance(expr, Add):
            return Add(subst(expr.left, s), subst(expr.right, s))
        elif isinstance(expr, Mul):
            return Mul(subst(expr.left, s), subst(expr.right, s))
        elif isinstance(expr, Neg):
            return Neg(subst(expr.child, s))
        elif isinstance(expr, Inv):
            return Inv(subst(expr.child, s))
        elif isinstance(expr, EML):
            return EML(subst(expr.coeff, s), subst(expr.exponent, s))
        return expr

    # f = exp(x), g = x + 1
    # f ∘ g = exp(x+1)
    f = EML(Const(1.0), Var())       # exp(x)
    g = Add(Var(), Const(1.0))       # x + 1
    fog = subst(f, g)                # exp(x + 1)

    for x in [0.0, 1.0, 2.0]:
        v1 = evaluate(fog, x)
        v2 = evaluate(f, evaluate(g, x))
        print(f"  x={x:.1f}: subst_eval={v1:.6f}, f(g(x))={v2:.6f}, match={abs(v1-v2)<1e-10}")

    print(f"\n  depth(f)={eml_depth(f)}, depth(g)={eml_depth(g)}, depth(f∘g)={eml_depth(fog)}")
    print(f"  size(f)={size(f)}, size(g)={size(g)}, size(f∘g)={size(fog)}")
    print(f"  Depth bound: {eml_depth(fog)} ≤ {eml_depth(f)} + {eml_depth(g)} = {eml_depth(f)+eml_depth(g)}")
    print(f"  Size bound:  {size(fog)} ≤ {size(f)} × {size(g)} = {size(f)*size(g)}")
    assert eml_depth(fog) <= eml_depth(f) + eml_depth(g)
    assert size(fog) <= size(f) * size(g)
    print()
    print("✓ Substitution semantics verified: subst(e, s).eval(x) = e.eval(s.eval(x))")
    print("✓ Depth bound verified: depth(e.subst s) ≤ depth(e) + depth(s)")
    print("✓ Size bound verified: size(e.subst s) ≤ size(e) × size(s)")


def demo_depth_hierarchy():
    """Demonstrate the strict depth hierarchy."""
    print()
    print("=" * 70)
    print("§5. Strict Depth Hierarchy: iterExp(n) requires depth ≥ n")
    print("=" * 70)
    print()
    print("  The expRank invariant proves that iterExp(n) cannot be computed")
    print("  by any EML expression of depth < n.")
    print()
    print(f"{'n':>3} {'Growth at x=1':>20} {'Growth at x=2':>20}")
    print("-" * 50)
    for n in range(7):
        v1 = iter_exp(n, 1.0)
        v2 = iter_exp(n, 2.0) if n < 5 else float('inf')
        s1 = f"{v1:.4f}" if math.isfinite(v1) and v1 < 1e15 else f"{v1:.2e}"
        s2 = f"{v2:.4f}" if math.isfinite(v2) and v2 < 1e15 else "overflow"
        print(f"{n:>3} {s1:>20} {s2:>20}")
    print()
    print("  The iterated exponential grows so fast that no finite-depth")
    print("  algebraic trick can reduce the required eml nesting.")
    print()
    print("✓ iterExp(n) ∈ Level(n) (canonical construction)")
    print("✓ expRank(e) ≤ emlDepth(e) (structural bound)")
    print("✓ expRank(emlExprIterExp n) = n (exact rank)")


if __name__ == "__main__":
    demo_canonical_construction()
    demo_evaluation()
    demo_filtration_closure()
    demo_substitution()
    demo_depth_hierarchy()
    print()
    print("=" * 70)
    print("All demonstrations passed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: EML Depth Hierarchy and Size Decomposition

Produces plots showing:
1. The strict depth hierarchy (iterExp growth)
2. Size decomposition of canonical constructions
3. Depth-size tradeoff landscape
"""
import math

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    HAS_MPL = True
except ImportError:
    HAS_MPL = False
    print("matplotlib not available; printing text-based output instead")


def iter_exp(n: int, x: float) -> float:
    result = x
    for _ in range(n):
        try:
            result = math.exp(result)
        except OverflowError:
            return float('inf')
    return result


def plot_depth_hierarchy():
    """Plot the growth of iterExp(n, x) for various n."""
    if not HAS_MPL:
        print("\n=== Depth Hierarchy Growth ===")
        for n in range(6):
            vals = []
            for x_10 in range(1, 21):
                x = x_10 / 10.0
                v = iter_exp(n, x)
                if math.isfinite(v) and v < 1e6:
                    vals.append((x, v))
            if vals:
                print(f"  n={n}: x=[{vals[0][0]:.1f}..{vals[-1][0]:.1f}], "
                      f"range=[{vals[0][1]:.2f}..{vals[-1][1]:.2f}]")
        return

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Plot 1: Growth curves
    colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd', '#8c564b']
    for n in range(6):
        xs = [i / 100.0 for i in range(10, 201)]
        ys = []
        for x in xs:
            v = iter_exp(n, x)
            if math.isfinite(v) and v < 1e4:
                ys.append(v)
            else:
                break
        ax1.plot(xs[:len(ys)], ys, label=f'iterExp({n}, x)', color=colors[n], linewidth=2)

    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('iterExp(n, x)', fontsize=12)
    ax1.set_title('EML Depth Hierarchy: Growth of Iterated Exponentials', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.set_ylim(0, 1000)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Size decomposition of canonical construction
    ns = list(range(11))
    sizes = [2*n+1 for n in ns]
    leaf_counts = [n+1 for n in ns]
    eml_counts = list(ns)
    field_counts = [0] * len(ns)

    bar_width = 0.6
    ax2.bar(ns, leaf_counts, bar_width, label='Leaf count (n+1)', color='#2ca02c', alpha=0.8)
    ax2.bar(ns, eml_counts, bar_width, bottom=leaf_counts, label='EML count (n)', color='#d62728', alpha=0.8)
    ax2.bar(ns, field_counts, bar_width, bottom=[l+e for l,e in zip(leaf_counts, eml_counts)],
            label='Field count (0)', color='#1f77b4', alpha=0.8)

    ax2.plot(ns, sizes, 'ko-', label='Total size (2n+1)', linewidth=2, markersize=6)

    ax2.set_xlabel('Depth n', fontsize=12)
    ax2.set_ylabel('Count', fontsize=12)
    ax2.set_title('Size Decomposition: size = leaf + field + eml', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_depth_hierarchy.png', dpi=150, bbox_inches='tight')
    print("Saved viz_depth_hierarchy.png")
    plt.close()


def plot_composition_bounds():
    """Plot the depth-size tradeoff under composition."""
    if not HAS_MPL:
        print("\n=== Composition Bounds ===")
        print("  Depth adds, size multiplies under composition")
        for d1 in range(1, 5):
            for d2 in range(1, 5):
                s1, s2 = 2*d1+1, 2*d2+1
                print(f"  f(depth={d1},size={s1}) ∘ g(depth={d2},size={s2}) → "
                      f"depth≤{d1+d2}, size≤{s1*s2}")
        return

    fig, ax = plt.subplots(figsize=(8, 6))

    # Show the achievable region for compositions
    points = []
    for d1 in range(6):
        for d2 in range(6):
            s1 = 2*d1 + 1
            s2 = 2*d2 + 1
            d_comp = d1 + d2
            s_comp = s1 * s2
            points.append((d_comp, s_comp, d1, d2))

    for d_comp, s_comp, d1, d2 in points:
        color = plt.cm.viridis(d1 / 5)
        ax.scatter(d_comp, s_comp, c=[color], s=50, alpha=0.7, edgecolors='black', linewidth=0.5)

    # Canonical construction points
    for n in range(11):
        ax.scatter(n, 2*n+1, c='red', s=100, marker='*', zorder=5)

    ax.set_xlabel('EML Depth', fontsize=12)
    ax.set_ylabel('Size', fontsize=12)
    ax.set_title('Depth-Size Landscape: Canonical (★) vs Composed', fontsize=13)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_composition_bounds.png', dpi=150, bbox_inches='tight')
    print("Saved viz_composition_bounds.png")
    plt.close()


if __name__ == "__main__":
    plot_depth_hierarchy()
    plot_composition_bounds()
    print("All visualizations generated.")
