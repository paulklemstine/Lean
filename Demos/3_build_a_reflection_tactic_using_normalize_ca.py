#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Tropical Normalization

Demonstrates how tropical (min-plus) algebra normalization applies to:
1. Shortest-path algorithms (Bellman-Ford style)
2. Dynamic programming optimization
3. Scheduling / critical path analysis
4. Piecewise-linear function canonicalization

Each application shows how ACI normalization simplifies verification
of correctness properties.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Union, List, Dict, Tuple
import itertools


# ============================================================
# Expression AST (shared with algorithms.py)
# ============================================================

@dataclass(frozen=True)
class Var:
    index: int

@dataclass(frozen=True)
class TMin:
    left: 'Expr'
    right: 'Expr'

@dataclass(frozen=True)
class TAdd:
    left: 'Expr'
    right: 'Expr'

Expr = Union[Var, TMin, TAdd]


def expr_sort_key(e):
    if isinstance(e, Var): return (0, e.index)
    elif isinstance(e, TMin): return (1, expr_sort_key(e.left), expr_sort_key(e.right))
    else: return (2, expr_sort_key(e.left), expr_sort_key(e.right))

def flatten_min(e):
    if isinstance(e, TMin): return flatten_min(e.left) + flatten_min(e.right)
    return [e]

def flatten_add(e):
    if isinstance(e, TAdd): return flatten_add(e.left) + flatten_add(e.right)
    return [e]

def dedup(lst):
    if not lst: return []
    result = [lst[0]]
    for x in lst[1:]:
        if x != result[-1]: result.append(x)
    return result

def build_min(lst):
    if len(lst) == 1: return lst[0]
    return TMin(lst[0], build_min(lst[1:]))

def build_add(lst):
    if len(lst) == 1: return lst[0]
    return TAdd(lst[0], build_add(lst[1:]))

def normalize(e):
    if isinstance(e, Var): return e
    elif isinstance(e, TMin):
        a, b = normalize(e.left), normalize(e.right)
        flat = flatten_min(TMin(a, b))
        flat.sort(key=expr_sort_key)
        flat = dedup(flat)
        return build_min(flat)
    elif isinstance(e, TAdd):
        a, b = normalize(e.left), normalize(e.right)
        flat = flatten_add(TAdd(a, b))
        flat.sort(key=expr_sort_key)
        return build_add(flat)

def evaluate(e, sigma):
    if isinstance(e, Var): return sigma.get(e.index, 0.0)
    elif isinstance(e, TMin): return min(evaluate(e.left, sigma), evaluate(e.right, sigma))
    elif isinstance(e, TAdd): return evaluate(e.left, sigma) + evaluate(e.right, sigma)

def pretty(e):
    if isinstance(e, Var):
        names = {0:'w_ab', 1:'w_bc', 2:'w_ac', 3:'w_bd', 4:'w_cd', 5:'w_ad'}
        return names.get(e.index, f"x{e.index}")
    elif isinstance(e, TMin): return f"min({pretty(e.left)}, {pretty(e.right)})"
    elif isinstance(e, TAdd): return f"({pretty(e.left)} + {pretty(e.right)})"


# ============================================================
# Application 1: Shortest Path Verification
# ============================================================

def shortest_path_demo():
    """
    In the min-plus semiring, shortest-path computation is just
    matrix multiplication with min replacing + and + replacing ×.

    The Bellman-Ford recurrence:
      d[v] = min over all edges (u,v) of (d[u] + w(u,v))

    is a tropical polynomial. Normalization proves that different
    ways of computing shortest paths give the same result.
    """
    print("=" * 60)
    print("APPLICATION 1: Shortest Path Verification")
    print("=" * 60)

    # Consider a 4-node graph: A, B, C, D
    # Edge weights as variables:
    # w_ab=x0, w_bc=x1, w_ac=x2, w_bd=x3, w_cd=x4, w_ad=x5
    w_ab, w_bc, w_ac, w_bd, w_cd, w_ad = [Var(i) for i in range(6)]

    # Two ways to compute shortest path A→D:
    # Method 1: enumerate paths directly
    path_abd = TAdd(w_ab, w_bd)  # A→B→D
    path_acd = TAdd(w_ac, w_cd)  # A→C→D
    path_ad = w_ad               # A→D direct
    path_abcd = TAdd(w_ab, TAdd(w_bc, w_cd))  # A→B→C→D

    method1 = TMin(path_abd, TMin(path_acd, TMin(path_ad, path_abcd)))

    # Method 2: Bellman-Ford style (different association)
    # First relax via B: min(d[D], d[B] + w_bd)
    # Then relax via C: min(d[D], d[C] + w_cd)
    method2 = TMin(path_ad,
                   TMin(TAdd(w_ab, w_bd),
                        TMin(TAdd(w_ac, w_cd),
                             TAdd(TAdd(w_ab, w_bc), w_cd))))

    # These should normalize to the same expression
    n1 = normalize(method1)
    n2 = normalize(method2)
    equal = n1 == n2

    print(f"\n  Path enumeration:  {pretty(method1)}")
    print(f"  Bellman-Ford:      {pretty(method2)}")
    print(f"  Normalized equal:  {'✓ YES' if equal else '✗ NO'}")

    # Numerical check
    sigma = {0: 3, 1: 2, 2: 8, 3: 1, 4: 4, 5: 10}
    v1 = evaluate(method1, sigma)
    v2 = evaluate(method2, sigma)
    print(f"  Numerical check:   method1={v1}, method2={v2}, equal={v1==v2}")
    print()


# ============================================================
# Application 2: Dynamic Programming
# ============================================================

def dynamic_programming_demo():
    """
    Many DP recurrences have the form:
      opt[i] = min_j (cost(j) + opt[j])

    Tropical normalization can verify that different decompositions
    of a DP problem yield the same optimal value.
    """
    print("=" * 60)
    print("APPLICATION 2: Dynamic Programming Verification")
    print("=" * 60)

    # Consider splitting a chain of 4 matrices A₁A₂A₃A₄
    # Cost of multiplying Aᵢ...Aⱼ as tropicalized symbolic costs
    c12, c23, c34, c13, c24, c14_split = [Var(i) for i in range(6)]

    # Split at position 1: (A₁)(A₂A₃A₄)
    split1 = TAdd(c12, TMin(TAdd(c23, c34), c24))

    # Split at position 2: (A₁A₂)(A₃A₄)
    split2 = TAdd(c12, c34)

    # The optimal cost is min of all split points
    opt_v1 = TMin(split1, TMin(split2, TAdd(c13, c34)))
    opt_v2 = TMin(TAdd(c13, c34), TMin(split2, split1))

    n1 = normalize(opt_v1)
    n2 = normalize(opt_v2)
    equal = n1 == n2

    print(f"\n  Formulation 1 normalized == Formulation 2 normalized: {'✓' if equal else '✗'}")
    print(f"  (Different orderings of min give same canonical form)")
    print()


# ============================================================
# Application 3: Scheduling / Critical Path
# ============================================================

def scheduling_demo():
    """
    In scheduling, the critical path (longest path) uses the max-plus
    semiring. By duality, shortest completion time uses min-plus.

    Tropical normalization verifies that different schedules with
    the same precedence constraints have the same minimum completion time.
    """
    print("=" * 60)
    print("APPLICATION 3: Scheduling / Critical Path")
    print("=" * 60)

    # Tasks with durations t_a, t_b, t_c, t_d
    # Precedence: A→C, B→C, A→D, C→D
    t_a, t_b, t_c, t_d = Var(0), Var(1), Var(2), Var(3)

    # Earliest completion of D via different paths:
    path_acd = TAdd(t_a, TAdd(t_c, t_d))  # A→C→D
    path_bcd = TAdd(t_b, TAdd(t_c, t_d))  # B→C→D
    path_ad  = TAdd(t_a, t_d)              # A→D

    # Two equivalent formulations of earliest D completion
    # (which path gives minimum time)
    form1 = TMin(path_acd, TMin(path_bcd, path_ad))
    form2 = TMin(path_ad, TMin(path_acd, path_bcd))

    n1 = normalize(form1)
    n2 = normalize(form2)
    equal = n1 == n2

    print(f"\n  Schedule 1: {pretty(form1)}")
    print(f"  Schedule 2: {pretty(form2)}")
    print(f"  Equivalent: {'✓' if equal else '✗'}")

    # A more complex example: redundant paths
    form3 = TMin(form1, TMin(TAdd(t_b, TAdd(t_c, t_d)),
                             TAdd(t_a, TAdd(t_c, t_d))))
    n3 = normalize(form3)
    print(f"\n  With redundant paths: {pretty(form3)}")
    print(f"  Simplifies to:       {pretty(n3)}")
    print(f"  Same as original:    {'✓' if n3 == n1 else '✗'}")
    print()


# ============================================================
# Application 4: Piecewise-Linear Functions
# ============================================================

def piecewise_linear_demo():
    """
    A tropical polynomial f(x) = min(a₁+b₁x, a₂+b₂x, ...) defines
    a piecewise-linear concave function. Two such polynomials define
    the same function iff their normalizations agree (up to the
    idempotent fragment).

    This is the foundation of tropical geometry: tropical hypersurfaces
    are the loci where the minimum is achieved by multiple terms.
    """
    print("=" * 60)
    print("APPLICATION 4: Piecewise-Linear Function Equality")
    print("=" * 60)

    # Tropical polynomial in one variable x (= Var(0)) with coefficients as vars
    a0, a1, a2 = Var(0), Var(1), Var(2)
    x = Var(3)

    # f(x) = min(a0 + x, a1 + x, a2 + x)  -- but with a0+x duplicated
    f1 = TMin(TAdd(a0, x), TMin(TAdd(a1, x), TMin(TAdd(a2, x), TAdd(a0, x))))

    # g(x) = min(a0 + x, a1 + x, a2 + x)  -- no duplicates
    g1 = TMin(TAdd(a0, x), TMin(TAdd(a1, x), TAdd(a2, x)))

    n_f1 = normalize(f1)
    n_g1 = normalize(g1)
    equal = n_f1 == n_g1

    print(f"\n  f(x) with duplicate:  {pretty(f1)}")
    print(f"  g(x) without:         {pretty(g1)}")
    print(f"  Same function:        {'✓' if equal else '✗'}")
    print(f"  Canonical form:       {pretty(n_f1)}")
    print()


if __name__ == "__main__":
    shortest_path_demo()
    dynamic_programming_demo()
    scheduling_demo()
    piecewise_linear_demo()


#!/usr/bin/env python3
"""
demo.py — Tropical Algebra Normalization Demo

Demonstrates the tropical (min-plus) normalizer with concrete numerical examples,
showing how expressions in the min-plus semiring are canonicalized.

The normalizer handles:
- Associativity and commutativity of min and +
- Idempotence of min (min(a, a) = a)
- Flattening nested operations
- Sorting sub-expressions into a canonical order
- Removing duplicate terms under min
"""

from dataclasses import dataclass
from typing import Union, Callable
import itertools


# ============================================================
# Tropical Expression AST
# ============================================================

@dataclass(frozen=True)
class Var:
    """A variable, indexed by a natural number."""
    index: int
    def __repr__(self): return f"x{self.index}"

@dataclass(frozen=True)
class TMin:
    """Tropical addition: min(a, b)."""
    left: 'TropExpr'
    right: 'TropExpr'
    def __repr__(self): return f"min({self.left}, {self.right})"

@dataclass(frozen=True)
class TAdd:
    """Tropical multiplication: a + b (classical addition)."""
    left: 'TropExpr'
    right: 'TropExpr'
    def __repr__(self): return f"({self.left} + {self.right})"

TropExpr = Union[Var, TMin, TAdd]


# ============================================================
# Evaluation
# ============================================================

def evaluate(expr: TropExpr, sigma: Callable[[int], float]) -> float:
    """Evaluate a tropical expression given a variable assignment."""
    if isinstance(expr, Var):
        return sigma(expr.index)
    elif isinstance(expr, TMin):
        return min(evaluate(expr.left, sigma), evaluate(expr.right, sigma))
    elif isinstance(expr, TAdd):
        return evaluate(expr.left, sigma) + evaluate(expr.right, sigma)
    raise TypeError(f"Unknown expression type: {type(expr)}")


# ============================================================
# Comparison (Total Order on Expressions)
# ============================================================

def expr_key(e: TropExpr):
    """Generate a sorting key for canonical ordering."""
    if isinstance(e, Var):
        return (0, e.index)
    elif isinstance(e, TMin):
        return (1, expr_key(e.left), expr_key(e.right))
    elif isinstance(e, TAdd):
        return (2, expr_key(e.left), expr_key(e.right))


# ============================================================
# Flatten, Sort, Dedup, Build
# ============================================================

def flatten_min(e: TropExpr) -> list:
    """Flatten nested min into a flat list."""
    if isinstance(e, TMin):
        return flatten_min(e.left) + flatten_min(e.right)
    return [e]

def flatten_add(e: TropExpr) -> list:
    """Flatten nested add into a flat list."""
    if isinstance(e, TAdd):
        return flatten_add(e.left) + flatten_add(e.right)
    return [e]

def dedup(lst: list) -> list:
    """Remove consecutive duplicates from a sorted list."""
    if not lst:
        return []
    result = [lst[0]]
    for x in lst[1:]:
        if x != result[-1]:
            result.append(x)
    return result

def build_min(lst: list) -> TropExpr:
    """Build a right-associated min chain."""
    if len(lst) == 1:
        return lst[0]
    return TMin(lst[0], build_min(lst[1:]))

def build_add(lst: list) -> TropExpr:
    """Build a right-associated add chain."""
    if len(lst) == 1:
        return lst[0]
    return TAdd(lst[0], build_add(lst[1:]))


# ============================================================
# The ACI Normalizer
# ============================================================

def normalize(e: TropExpr) -> TropExpr:
    """
    Normalize a tropical expression:
    - For min: flatten → sort → dedup → rebuild (ACI normalization)
    - For add: flatten → sort → rebuild (AC normalization)
    - Variables: already normal
    """
    if isinstance(e, Var):
        return e
    elif isinstance(e, TMin):
        a = normalize(e.left)
        b = normalize(e.right)
        combined = TMin(a, b)
        flat = flatten_min(combined)
        flat.sort(key=expr_key)
        flat = dedup(flat)
        return build_min(flat)
    elif isinstance(e, TAdd):
        a = normalize(e.left)
        b = normalize(e.right)
        combined = TAdd(a, b)
        flat = flatten_add(combined)
        flat.sort(key=expr_key)
        return build_add(flat)
    raise TypeError(f"Unknown: {type(e)}")


# ============================================================
# Pretty Printing
# ============================================================

def pretty(e: TropExpr) -> str:
    """Pretty-print a tropical expression."""
    if isinstance(e, Var):
        return chr(ord('a') + e.index) if e.index < 26 else f"x{e.index}"
    elif isinstance(e, TMin):
        return f"min({pretty(e.left)}, {pretty(e.right)})"
    elif isinstance(e, TAdd):
        return f"({pretty(e.left)} + {pretty(e.right)})"
    return str(e)


# ============================================================
# Demo
# ============================================================

def demo_normalization():
    """Demonstrate the normalizer on several examples."""
    a, b, c, d, e, f = Var(0), Var(1), Var(2), Var(3), Var(4), Var(5)

    examples = [
        ("Commutativity of +",
         TMin(TAdd(a, b), TAdd(b, a)),
         TAdd(a, b)),

        ("Idempotence of min",
         TMin(a, a),
         a),

        ("Flatten + sort",
         TMin(TMin(a, b), TMin(c, d)),
         TMin(a, TMin(b, TMin(c, d)))),

        ("AC collapse",
         TMin(TAdd(a, TAdd(b, c)), TAdd(TAdd(c, b), a)),
         TAdd(a, TAdd(b, c))),

        ("Duplicate elimination",
         TMin(TAdd(a, b), TMin(TAdd(a, b), c)),
         TMin(c, TAdd(a, b))),

        ("Triple redundancy",
         TMin(TAdd(a, b), TMin(TAdd(b, a), TAdd(a, b))),
         TAdd(a, b)),

        ("Six-variable dedup",
         TMin(TMin(TAdd(a, b), TMin(TAdd(c, d), TAdd(e, f))),
              TMin(TAdd(f, e), TMin(TAdd(d, c), TAdd(b, a)))),
         TMin(TAdd(a, b), TMin(TAdd(c, d), TAdd(e, f)))),
    ]

    print("=" * 70)
    print("TROPICAL EXPRESSION NORMALIZATION DEMO")
    print("=" * 70)

    for name, lhs, expected_rhs in examples:
        norm_lhs = normalize(lhs)
        norm_rhs = normalize(expected_rhs)
        match = norm_lhs == norm_rhs

        print(f"\n--- {name} ---")
        print(f"  LHS:        {pretty(lhs)}")
        print(f"  RHS:        {pretty(expected_rhs)}")
        print(f"  Norm(LHS):  {pretty(norm_lhs)}")
        print(f"  Norm(RHS):  {pretty(norm_rhs)}")
        print(f"  Match:      {'✓ EQUAL' if match else '✗ DIFFERENT'}")

        # Numerical verification with random values
        import random
        random.seed(42)
        sigma = lambda i, vals={j: random.uniform(-10, 10) for j in range(6)}: vals.get(i, 0)
        val_lhs = evaluate(lhs, sigma)
        val_rhs = evaluate(expected_rhs, sigma)
        print(f"  Numerical:  LHS={val_lhs:.4f}, RHS={val_rhs:.4f}, Equal={abs(val_lhs - val_rhs) < 1e-10}")


def demo_numerical_verification():
    """Exhaustively verify identities on a grid of values."""
    a, b, c, d = Var(0), Var(1), Var(2), Var(3)

    identity = (
        TMin(TMin(TAdd(a, b), TAdd(c, d)),
             TMin(TAdd(b, a), TAdd(d, c))),
        TMin(TAdd(a, b), TAdd(c, d))
    )

    print("\n" + "=" * 70)
    print("NUMERICAL VERIFICATION ON GRID")
    print("=" * 70)

    test_values = [-2.0, -1.0, 0.0, 1.0, 2.0]
    total = 0
    passed = 0

    for va, vb, vc, vd in itertools.product(test_values, repeat=4):
        sigma = lambda i, va=va, vb=vb, vc=vc, vd=vd: [va, vb, vc, vd][i] if i < 4 else 0
        lhs_val = evaluate(identity[0], sigma)
        rhs_val = evaluate(identity[1], sigma)
        total += 1
        if abs(lhs_val - rhs_val) < 1e-12:
            passed += 1

    print(f"  Identity: min(min(a+b, c+d), min(b+a, d+c)) = min(a+b, c+d)")
    print(f"  Tested {total} value combinations")
    print(f"  Passed: {passed}/{total}")
    assert passed == total, "Some tests failed!"
    print("  ✓ All tests passed!")


if __name__ == "__main__":
    demo_normalization()
    demo_numerical_verification()


#!/usr/bin/env python3
"""
visualizations.py — Visualizations for Tropical Normalization

Generates publication-quality figures showing:
1. Expression tree before/after normalization
2. Normalization performance scaling
3. Piecewise-linear tropical polynomial
4. Shortest-path comparison
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import base64
import io
import time
import random


# ============================================================
# Tropical Expression AST (minimal)
# ============================================================

class Var:
    def __init__(self, i): self.index = i
    def __eq__(self, o): return isinstance(o, Var) and self.index == o.index
    def __hash__(self): return hash(('Var', self.index))

class TMin:
    def __init__(self, l, r): self.left, self.right = l, r
    def __eq__(self, o): return isinstance(o, TMin) and self.left == o.left and self.right == o.right
    def __hash__(self): return hash(('TMin', self.left, self.right))

class TAdd:
    def __init__(self, l, r): self.left, self.right = l, r
    def __eq__(self, o): return isinstance(o, TAdd) and self.left == o.left and self.right == o.right
    def __hash__(self): return hash(('TAdd', self.left, self.right))

def expr_key(e):
    if isinstance(e, Var): return (0, e.index)
    elif isinstance(e, TMin): return (1, expr_key(e.left), expr_key(e.right))
    else: return (2, expr_key(e.left), expr_key(e.right))

def flatten_min(e):
    if isinstance(e, TMin): return flatten_min(e.left) + flatten_min(e.right)
    return [e]

def flatten_add(e):
    if isinstance(e, TAdd): return flatten_add(e.left) + flatten_add(e.right)
    return [e]

def dedup(lst):
    if not lst: return []
    result = [lst[0]]
    for x in lst[1:]:
        if x != result[-1]: result.append(x)
    return result

def build_min(lst):
    if len(lst) == 1: return lst[0]
    return TMin(lst[0], build_min(lst[1:]))

def build_add(lst):
    if len(lst) == 1: return lst[0]
    return TAdd(lst[0], build_add(lst[1:]))

def normalize(e):
    if isinstance(e, Var): return e
    elif isinstance(e, TMin):
        a, b = normalize(e.left), normalize(e.right)
        flat = flatten_min(TMin(a, b))
        flat.sort(key=expr_key); flat = dedup(flat)
        return build_min(flat)
    elif isinstance(e, TAdd):
        a, b = normalize(e.left), normalize(e.right)
        flat = flatten_add(TAdd(a, b))
        flat.sort(key=expr_key)
        return build_add(flat)

def size(e):
    if isinstance(e, Var): return 1
    return 1 + size(e.left) + size(e.right)

def evaluate(e, sigma):
    if isinstance(e, Var): return sigma.get(e.index, 0.0)
    elif isinstance(e, TMin): return min(evaluate(e.left, sigma), evaluate(e.right, sigma))
    elif isinstance(e, TAdd): return evaluate(e.left, sigma) + evaluate(e.right, sigma)

def fig_to_base64(fig):
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', facecolor='white')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


# ============================================================
# Figure 1: Normalization Performance Scaling
# ============================================================

def fig_performance():
    """Plot normalization time vs expression size."""
    random.seed(42)

    def rand_expr(depth, nv=4):
        if depth <= 0: return Var(random.randint(0, nv-1))
        op = random.choice([TMin, TAdd])
        return op(rand_expr(depth-1, nv), rand_expr(depth-1, nv))

    depths = list(range(1, 14))
    sizes = []
    times_ms = []
    norm_sizes = []

    for d in depths:
        e = rand_expr(d)
        s = size(e)
        t0 = time.perf_counter()
        for _ in range(3):
            n = normalize(e)
        t1 = time.perf_counter()
        elapsed = (t1 - t0) / 3 * 1000
        sizes.append(s)
        times_ms.append(elapsed)
        norm_sizes.append(size(n))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.plot(sizes, times_ms, 'o-', color='#2196F3', linewidth=2, markersize=6)
    ax1.set_xlabel('Expression Size (nodes)', fontsize=12)
    ax1.set_ylabel('Normalization Time (ms)', fontsize=12)
    ax1.set_title('Normalization Performance', fontsize=14, fontweight='bold')
    ax1.set_xscale('log')
    ax1.set_yscale('log')
    ax1.grid(True, alpha=0.3)

    ax2.plot(sizes, norm_sizes, 's-', color='#4CAF50', linewidth=2, markersize=6, label='Normalized')
    ax2.plot(sizes, sizes, '--', color='#9E9E9E', linewidth=1, label='Original (y=x)')
    ax2.set_xlabel('Original Size (nodes)', fontsize=12)
    ax2.set_ylabel('Normalized Size (nodes)', fontsize=12)
    ax2.set_title('Size Reduction by Normalization', fontsize=14, fontweight='bold')
    ax2.set_xscale('log')
    ax2.set_yscale('log')
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_performance.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ============================================================
# Figure 2: Tropical Polynomial (Piecewise-Linear Function)
# ============================================================

def fig_tropical_polynomial():
    """Plot a tropical polynomial as a piecewise-linear function."""
    x = np.linspace(-3, 5, 1000)

    # Tropical polynomial: f(x) = min(2+x, 5-x, 1+2x, 4)
    terms = [
        (2 + x, '2 + x', '#E53935'),
        (5 - x, '5 − x', '#1E88E5'),
        (1 + 2*x, '1 + 2x', '#43A047'),
        (np.full_like(x, 4.0), '4', '#FB8C00'),
    ]

    fig, ax = plt.subplots(figsize=(10, 6))

    for vals, label, color in terms:
        ax.plot(x, vals, '--', color=color, alpha=0.4, linewidth=1.5, label=label)

    # The tropical polynomial (min of all terms)
    f = np.minimum.reduce([t[0] for t in terms])
    ax.plot(x, f, 'k-', linewidth=3, label='min(...) = tropical polynomial', zorder=5)

    # Mark the "tropical roots" (kinks where min switches)
    # Find where adjacent terms swap dominance
    for i in range(len(terms)):
        for j in range(i+1, len(terms)):
            v1, v2 = terms[i][0], terms[j][0]
            diff = v1 - v2
            # Find sign changes
            for k in range(len(diff)-1):
                if diff[k] * diff[k+1] < 0:
                    # Linear interpolation for crossing point
                    t_cross = k + abs(diff[k]) / (abs(diff[k]) + abs(diff[k+1]))
                    x_cross = x[k] + (x[k+1] - x[k]) * (t_cross - k)
                    y_cross = np.interp(x_cross, x, f)
                    if abs(v1[k] - f[k]) < 0.1 or abs(v2[k] - f[k]) < 0.1:
                        ax.plot(x_cross, y_cross, 'ro', markersize=8, zorder=10)

    ax.set_xlabel('x', fontsize=14)
    ax.set_ylabel('f(x)', fontsize=14)
    ax.set_title('Tropical Polynomial: f(x) = min(2+x, 5−x, 1+2x, 4)', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11, loc='upper right')
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-2, 8)

    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_tropical_poly.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ============================================================
# Figure 3: Normalization Pipeline Diagram
# ============================================================

def fig_pipeline():
    """Visualize the normalization pipeline stages."""
    fig, axes = plt.subplots(1, 4, figsize=(16, 4))

    stages = [
        ("Input", "min(min(a+b, c+d),\n    min(b+a, d+c))", '#FFCDD2'),
        ("Flatten", "[a+b, c+d, b+a, d+c]", '#C8E6C9'),
        ("Sort + Dedup", "[a+b, c+d]", '#BBDEFB'),
        ("Rebuild", "min(a+b, c+d)", '#FFF9C4'),
    ]

    for ax, (title, content, color) in zip(axes, stages):
        ax.set_xlim(0, 1)
        ax.set_ylim(0, 1)
        rect = mpatches.FancyBboxPatch((0.05, 0.15), 0.9, 0.7,
                                        boxstyle="round,pad=0.05",
                                        facecolor=color, edgecolor='#424242', linewidth=2)
        ax.add_patch(rect)
        ax.text(0.5, 0.8, title, ha='center', va='center', fontsize=13,
                fontweight='bold', color='#212121')
        ax.text(0.5, 0.45, content, ha='center', va='center', fontsize=10,
                fontfamily='monospace', color='#37474F')
        ax.axis('off')

    # Add arrows between stages
    for i in range(3):
        fig.text(0.255 + i * 0.25, 0.5, '→', ha='center', va='center',
                fontsize=28, color='#616161', fontweight='bold')

    fig.suptitle('ACI Normalization Pipeline', fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_pipeline.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ============================================================
# Figure 4: Comparison with Brute Force
# ============================================================

def fig_correctness_grid():
    """
    Verify a tropical identity on a grid of values and visualize
    the absolute error (should be zero everywhere).
    """
    a_vals = np.linspace(-5, 5, 50)
    b_vals = np.linspace(-5, 5, 50)
    A, B = np.meshgrid(a_vals, b_vals)

    # Identity: min(a+b, b+a) = a+b
    LHS = np.minimum(A + B, B + A)
    RHS = A + B
    error = np.abs(LHS - RHS)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    im1 = ax1.imshow(LHS, extent=[-5, 5, -5, 5], origin='lower', cmap='viridis', aspect='auto')
    ax1.set_xlabel('a', fontsize=12)
    ax1.set_ylabel('b', fontsize=12)
    ax1.set_title('min(a+b, b+a)', fontsize=13, fontweight='bold')
    plt.colorbar(im1, ax=ax1, shrink=0.8)

    # More interesting: min(a+b, min(a+b, b)) vs min(b, a+b)
    LHS2 = np.minimum(A + B, np.minimum(A + B, B))
    RHS2 = np.minimum(B, A + B)
    error2 = np.abs(LHS2 - RHS2)

    im2 = ax2.imshow(error2, extent=[-5, 5, -5, 5], origin='lower', cmap='RdYlGn_r', aspect='auto',
                      vmin=0, vmax=0.001)
    ax2.set_xlabel('a', fontsize=12)
    ax2.set_ylabel('b', fontsize=12)
    ax2.set_title('|min(a+b, min(a+b, b)) − min(b, a+b)|', fontsize=13, fontweight='bold')
    plt.colorbar(im2, ax=ax2, shrink=0.8, label='Absolute Error')

    fig.suptitle('Numerical Verification of Tropical Identities', fontsize=14, fontweight='bold')
    fig.tight_layout()
    fig.savefig('/workspace/request-project/fig_verification.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# ============================================================
# Generate All Figures
# ============================================================

if __name__ == "__main__":
    print("Generating figures...")
    b64_perf = fig_performance()
    print("  ✓ Performance scaling")
    b64_poly = fig_tropical_polynomial()
    print("  ✓ Tropical polynomial")
    b64_pipe = fig_pipeline()
    print("  ✓ Pipeline diagram")
    b64_grid = fig_correctness_grid()
    print("  ✓ Correctness grid")
    print("Done! Figures saved as PNG files.")

    # Save base64 data for PACKAGE.json
    import json
    viz_data = {
        "performance": b64_perf,
        "tropical_polynomial": b64_poly,
        "pipeline": b64_pipe,
        "verification": b64_grid,
    }
    with open('/workspace/request-project/viz_data.json', 'w') as f:
        json.dump(viz_data, f)
    print("Base64 visualization data saved to viz_data.json")
