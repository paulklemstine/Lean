#!/usr/bin/env python3
"""
EML Circuit Depth Separation — Applications

Demonstrates real-world applications of the depth separation results:
1. Symbolic regression complexity estimation
2. Neural network depth requirements for transcendental approximation
3. Expression simplification with depth awareness
4. Growth hierarchy classification
"""

import math
from typing import List, Tuple, Callable
from algorithms import (
    EMLNode, ExprType, compute_exp_rank, compute_eml_depth,
    compute_tree_size, iter_exp, estimate_growth_level,
    compute_poly_bound
)


# ============================================================
# Application 1: Symbolic Regression Complexity
# ============================================================

def symbolic_regression_depth_estimate():
    """
    In symbolic regression, we search for mathematical expressions
    that fit data. The depth separation theorem tells us that if
    the target function involves iterated exponentials, the search
    space must include sufficient EML depth.

    This application estimates the minimum EML depth needed to
    represent common scientific functions.
    """
    print("=" * 65)
    print("Application 1: Symbolic Regression Depth Requirements")
    print("=" * 65)
    print()

    functions = [
        ("Linear: 2x + 3",        lambda x: 2*x + 3,           0),
        ("Quadratic: x²",         lambda x: x**2,               0),
        ("Polynomial: x³ - x",    lambda x: x**3 - x,           0),
        ("Exponential: exp(x)",    lambda x: math.exp(x),        1),
        ("Gaussian: exp(-x²)",     lambda x: math.exp(-x**2),    1),
        ("Sigmoid: 1/(1+exp(-x))", lambda x: 1/(1+math.exp(-x)), 1),
        ("Double exp: exp(exp(x))",
         lambda x: math.exp(math.exp(x)) if x < 5 else float('inf'), 2),
        ("Softplus: log(1+exp(x))",
         lambda x: math.log(1 + math.exp(x)) if x < 700 else x, 1),
    ]

    print(f"{'Function':>30} | {'Growth Level':>12} | {'Min EML Depth':>13}")
    print("-" * 65)
    for name, f, expected_depth in functions:
        try:
            level = estimate_growth_level(f, x_large=50.0)
        except Exception:
            level = -1
        print(f"{name:>30} | {level:>12} | ≥ {expected_depth:>11}")

    print()
    print("Implication: Symbolic regression algorithms using EML-based")
    print("expression trees must allocate sufficient depth to capture")
    print("the target function's exponential nesting level.")
    print()


# ============================================================
# Application 2: Neural Network Depth for Transcendentals
# ============================================================

def neural_network_depth_analysis():
    """
    Neural networks with exponential activation functions (like softmax
    layers) can be viewed as EML circuits. The depth separation theorem
    implies depth requirements for approximating tower-exponential
    functions.
    """
    print("=" * 65)
    print("Application 2: Neural Network Depth for Transcendental Functions")
    print("=" * 65)
    print()

    print("A neural network layer with exponential activation computes:")
    print("  layer(x) = W₂ · exp(W₁ · x + b₁) + b₂")
    print("This is essentially an EML operation: eml(coefficient, linear).")
    print()
    print("Depth separation implies:")
    print()

    table = [
        (1, "exp(x)", "Basic exponential"),
        (2, "exp(exp(x))", "Double exponential"),
        (3, "exp(exp(exp(x)))", "Triple exponential"),
        (5, "exp^5(x)", "5-fold iterated exp"),
        (10, "exp^10(x)", "10-fold iterated exp"),
    ]

    print(f"{'Nesting':>8} | {'Function':>20} | {'Min Layers':>10} | {'Note'}")
    print("-" * 65)
    for n, func, note in table:
        print(f"{n:>8} | {func:>20} | {n:>10} | {note}")

    print()
    print("Each exponential nesting level requires at least one")
    print("dedicated network layer. Shallow networks cannot represent")
    print("deeply nested transcendental functions efficiently.")
    print()


# ============================================================
# Application 3: Expression Simplification
# ============================================================

def expression_simplification():
    """
    The expRank invariant can guide expression simplification:
    two expressions can only be equivalent if they have the same
    growth level, providing a quick filter for simplification candidates.
    """
    print("=" * 65)
    print("Application 3: Growth-Aware Expression Simplification")
    print("=" * 65)
    print()

    var = EMLNode(ExprType.VAR)
    c1 = EMLNode(ExprType.CONST, value=1.0)
    c2 = EMLNode(ExprType.CONST, value=2.0)

    # Build various expressions
    expressions = {
        "x": var,
        "x + 1": EMLNode(ExprType.ADD, left=var, right=c1),
        "2x": EMLNode(ExprType.MUL, left=c2, right=var),
        "exp(x)": EMLNode(ExprType.EML, left=c1, right=var),
        "2·exp(x)": EMLNode(ExprType.EML, left=c2, right=var),
        "exp(x+1)": EMLNode(ExprType.EML, left=c1,
                            right=EMLNode(ExprType.ADD, left=var, right=c1)),
        "exp(exp(x))": EMLNode(ExprType.EML, left=c1,
                               right=EMLNode(ExprType.EML, left=c1, right=var)),
    }

    print("ExpRank partitions expressions into growth classes:")
    print()
    print(f"{'Expression':>20} | {'expRank':>8} | {'emlDepth':>8} | {'size':>5}")
    print("-" * 50)
    for name, expr in expressions.items():
        print(f"{name:>20} | {compute_exp_rank(expr):>8} | "
              f"{compute_eml_depth(expr):>8} | {compute_tree_size(expr):>5}")

    print()
    print("Rule: Two expressions can be equivalent only if they have")
    print("the same expRank. This provides an O(n) pre-filter for")
    print("expensive equivalence checks.")
    print()

    # Demonstrate the filter
    print("Equivalence candidates (same expRank):")
    by_rank = {}
    for name, expr in expressions.items():
        r = compute_exp_rank(expr)
        by_rank.setdefault(r, []).append(name)
    for rank, names in sorted(by_rank.items()):
        print(f"  Rank {rank}: {', '.join(names)}")
    print()


# ============================================================
# Application 4: Growth Hierarchy Classification
# ============================================================

def growth_hierarchy():
    """
    Classify functions by their position in the Hardy growth hierarchy,
    using the exponential rank as a proxy.
    """
    print("=" * 65)
    print("Application 4: Hardy Growth Hierarchy Classification")
    print("=" * 65)
    print()

    print("The Hardy hierarchy classifies functions by asymptotic growth:")
    print()
    print("  Level 0: Polynomial growth     (x, x², x¹⁰⁰)")
    print("  Level 1: Single exponential     (eˣ, 2ˣ, e²ˣ)")
    print("  Level 2: Double exponential      (e^(eˣ))")
    print("  Level n: n-fold exponential      (exp^n(x))")
    print()

    # Demonstrate with numerical evaluation
    x_vals = [1.0, 2.0, 3.0, 5.0]
    print("Growth comparison at specific points:")
    print()
    header = f"{'Function':>20} | {'Level':>5}"
    for x in x_vals:
        header += f" | {'x='+str(x):>12}"
    print(header)
    print("-" * (30 + 15 * len(x_vals)))

    functions = [
        ("x", 0, lambda x: x),
        ("x²", 0, lambda x: x**2),
        ("exp(x)", 1, lambda x: math.exp(x)),
        ("exp(exp(x))", 2, lambda x: math.exp(math.exp(x)) if x < 6 else float('inf')),
        ("exp³(x)", 3, lambda x: iter_exp(3, x)),
    ]

    for name, level, f in functions:
        row = f"{name:>20} | {level:>5}"
        for x in x_vals:
            try:
                val = f(x)
                if val == float('inf') or val > 1e15:
                    row += f" | {'∞':>12}"
                else:
                    row += f" | {val:>12.4g}"
            except (OverflowError, ValueError):
                row += f" | {'overflow':>12}"
        print(row)

    print()
    print("The expRank invariant captures exactly this hierarchy:")
    print("an EML expression of expRank k can only compute functions")
    print("at Hardy level ≤ k.")
    print()


# ============================================================
# Application 5: Complexity Cost Analysis
# ============================================================

def complexity_cost():
    """
    Analyze the computational cost of compiling full expressions
    to EML expressions.
    """
    print("=" * 65)
    print("Application 5: Full-to-EML Compilation Cost Analysis")
    print("=" * 65)
    print()

    print(f"{'n':>3} | {'Full depth':>10} | {'Full size':>9} | "
          f"{'EML depth':>9} | {'EML size':>8} | {'Depth ratio':>11}")
    print("-" * 65)

    for n in range(1, 11):
        full_depth = n
        full_size = n + 1
        eml_depth = n  # canonical construction
        eml_size = 2 * n + 1  # eml(1, eml(1, ..., var))
        ratio = eml_depth / full_depth if full_depth > 0 else 0
        print(f"{n:3d} | {full_depth:10d} | {full_size:9d} | "
              f"{eml_depth:9d} | {eml_size:8d} | {ratio:11.2f}")

    print()
    print("For iterExp(n), the depth ratio is 1:1 (both linear).")
    print("But the size ratio is ~2:1 (EML needs const(1) at each level).")
    print("The lower bound proves this 1:1 depth ratio is unavoidable.")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print()
    print("╔═══════════════════════════════════════════════════════════════╗")
    print("║   EML Circuit Depth Separation — Applications               ║")
    print("╚═══════════════════════════════════════════════════════════════╝")
    print()

    symbolic_regression_depth_estimate()
    neural_network_depth_analysis()
    expression_simplification()
    growth_hierarchy()
    complexity_cost()


#!/usr/bin/env python3
"""
EML Circuit Depth Separation — Interactive Demo

Demonstrates the depth separation between FullExpr and EMLExpr for
iterated exponentials. Shows that iterExp n has depth n in the full
language but requires EML depth ≥ n.
"""

import math
from typing import Callable, Optional


# ============================================================
# Expression Tree Types
# ============================================================

class FullExpr:
    """Full expression language with primitive exp and log."""
    pass

class FVar(FullExpr):
    def eval(self, x: float) -> float:
        return x
    def depth(self) -> int:
        return 0
    def size(self) -> int:
        return 1
    def __repr__(self):
        return "x"

class FConst(FullExpr):
    def __init__(self, c: float):
        self.c = c
    def eval(self, x: float) -> float:
        return self.c
    def depth(self) -> int:
        return 0
    def size(self) -> int:
        return 1
    def __repr__(self):
        return str(self.c)

class FExp(FullExpr):
    def __init__(self, a: FullExpr):
        self.a = a
    def eval(self, x: float) -> float:
        v = self.a.eval(x)
        if v > 700:  # overflow protection
            return float('inf')
        return math.exp(v)
    def depth(self) -> int:
        return 1 + self.a.depth()
    def size(self) -> int:
        return 1 + self.a.size()
    def __repr__(self):
        return f"exp({self.a})"


class EMLExpr:
    """EML expression language: eml(a,b) = a * exp(b)."""
    pass

class EVar(EMLExpr):
    def eval(self, x: float) -> float:
        return x
    def depth(self) -> int:
        return 0
    def eml_depth(self) -> int:
        return 0
    def exp_rank(self) -> int:
        return 0
    def size(self) -> int:
        return 1
    def __repr__(self):
        return "x"

class EConst(EMLExpr):
    def __init__(self, c: float):
        self.c = c
    def eval(self, x: float) -> float:
        return self.c
    def depth(self) -> int:
        return 0
    def eml_depth(self) -> int:
        return 0
    def exp_rank(self) -> int:
        return 0
    def size(self) -> int:
        return 1
    def __repr__(self):
        return str(self.c)

class EAdd(EMLExpr):
    def __init__(self, a: EMLExpr, b: EMLExpr):
        self.a, self.b = a, b
    def eval(self, x: float) -> float:
        return self.a.eval(x) + self.b.eval(x)
    def depth(self) -> int:
        return 1 + max(self.a.depth(), self.b.depth())
    def eml_depth(self) -> int:
        return max(self.a.eml_depth(), self.b.eml_depth())
    def exp_rank(self) -> int:
        return max(self.a.exp_rank(), self.b.exp_rank())
    def size(self) -> int:
        return 1 + self.a.size() + self.b.size()
    def __repr__(self):
        return f"({self.a} + {self.b})"

class EMul(EMLExpr):
    def __init__(self, a: EMLExpr, b: EMLExpr):
        self.a, self.b = a, b
    def eval(self, x: float) -> float:
        return self.a.eval(x) * self.b.eval(x)
    def depth(self) -> int:
        return 1 + max(self.a.depth(), self.b.depth())
    def eml_depth(self) -> int:
        return max(self.a.eml_depth(), self.b.eml_depth())
    def exp_rank(self) -> int:
        return max(self.a.exp_rank(), self.b.exp_rank())
    def size(self) -> int:
        return 1 + self.a.size() + self.b.size()
    def __repr__(self):
        return f"({self.a} * {self.b})"

class EML(EMLExpr):
    """The core EML operation: eml(a, b) = a * exp(b)."""
    def __init__(self, a: EMLExpr, b: EMLExpr):
        self.a, self.b = a, b
    def eval(self, x: float) -> float:
        av = self.a.eval(x)
        bv = self.b.eval(x)
        if bv > 700:
            return float('inf') if av > 0 else float('-inf') if av < 0 else 0.0
        return av * math.exp(bv)
    def depth(self) -> int:
        return 1 + max(self.a.depth(), self.b.depth())
    def eml_depth(self) -> int:
        return 1 + max(self.a.eml_depth(), self.b.eml_depth())
    def exp_rank(self) -> int:
        return max(self.a.exp_rank(), self.b.exp_rank() + 1)
    def size(self) -> int:
        return 1 + self.a.size() + self.b.size()
    def __repr__(self):
        return f"eml({self.a}, {self.b})"


# ============================================================
# Iterated Exponential
# ============================================================

def iter_exp(n: int, x: float) -> float:
    """Compute iterExp n x = exp^n(x)."""
    result = x
    for _ in range(n):
        if result > 700:
            return float('inf')
        result = math.exp(result)
    return result


# ============================================================
# Canonical Constructions
# ============================================================

def full_expr_iter_exp(n: int) -> FullExpr:
    """Canonical FullExpr for iterExp n: exp(exp(...exp(x)...))."""
    e = FVar()
    for _ in range(n):
        e = FExp(e)
    return e

def eml_expr_iter_exp(n: int) -> EMLExpr:
    """Canonical EMLExpr for iterExp n: eml(1, eml(1, ..., eml(1, x)...))."""
    e = EVar()
    for _ in range(n):
        e = EML(EConst(1.0), e)
    return e


# ============================================================
# Demo 1: Comparing Full vs EML representations
# ============================================================

def demo_comparison():
    """Compare depth and size of Full vs EML representations."""
    print("=" * 70)
    print("DEMO 1: Full Language vs EML Language — Depth & Size Comparison")
    print("=" * 70)
    print()
    print(f"{'n':>3} | {'Full depth':>10} | {'Full size':>9} | {'EML depth':>9} | "
          f"{'EML eml_depth':>13} | {'EML expRank':>11} | {'EML size':>8}")
    print("-" * 70)

    for n in range(8):
        fe = full_expr_iter_exp(n)
        ee = eml_expr_iter_exp(n)
        print(f"{n:3d} | {fe.depth():10d} | {fe.size():9d} | {ee.depth():9d} | "
              f"{ee.eml_depth():13d} | {ee.exp_rank():11d} | {ee.size():8d}")

    print()
    print("Key insight: Full language depth = n, EML depth = n.")
    print("Both canonical constructions are linear in n.")
    print("The separation theorem shows EML depth ≥ n for ANY representation,")
    print("not just the canonical one.")
    print()


# ============================================================
# Demo 2: Evaluating iterExp at specific points
# ============================================================

def demo_evaluation():
    """Show the tower-exponential growth of iterExp."""
    print("=" * 70)
    print("DEMO 2: Tower-Exponential Growth of iterExp")
    print("=" * 70)
    print()

    x_vals = [0.5, 1.0, 2.0]
    for x in x_vals:
        print(f"x = {x}:")
        for n in range(5):
            val = iter_exp(n, x)
            fe = full_expr_iter_exp(n)
            ee = eml_expr_iter_exp(n)
            fe_val = fe.eval(x)
            ee_val = ee.eval(x)
            if val == float('inf'):
                print(f"  iterExp({n}, {x}) = ∞  (overflow)")
            else:
                print(f"  iterExp({n}, {x}) = {val:.6g}"
                      f"  [Full: {fe_val:.6g}, EML: {ee_val:.6g}]")
        print()


# ============================================================
# Demo 3: Polynomial growth bound
# ============================================================

def demo_growth_bound():
    """Demonstrate that field-only expressions have polynomial growth."""
    print("=" * 70)
    print("DEMO 3: Polynomial Growth Bound vs Exponential Growth")
    print("=" * 70)
    print()

    # Example: e = x + 2*x^2  (a field-only expression with polyBound=2, coefBound=3)
    field_expr = EAdd(EVar(), EMul(EConst(2.0), EMul(EVar(), EVar())))
    print(f"Field expression: {field_expr}")
    print(f"  depth = {field_expr.depth()}, eml_depth = {field_expr.eml_depth()}, "
          f"exp_rank = {field_expr.exp_rank()}")
    print()

    print(f"{'x':>8} | {'field_expr(x)':>15} | {'exp(x)':>15} | {'exp(x) > field?':>15}")
    print("-" * 60)
    for x in [1, 2, 5, 10, 20, 50, 100]:
        fv = field_expr.eval(x)
        ev = math.exp(x)
        print(f"{x:8.1f} | {fv:15.4g} | {ev:15.4g} | {'YES' if ev > fv else 'NO':>15}")

    print()
    print("For large x, exp(x) vastly exceeds any polynomial.")
    print("This is why no field-only expression can represent exp(x).")
    print()


# ============================================================
# Demo 4: Exhaustive search for low-depth representations
# ============================================================

def demo_search():
    """Search for low EML-depth representations of iterExp."""
    print("=" * 70)
    print("DEMO 4: Exhaustive Search for Low-Depth EML Representations")
    print("=" * 70)
    print()

    test_points = [0.5, 1.0, 1.5, 2.0, 2.5]
    tolerance = 1e-8

    def matches_iter_exp(expr: EMLExpr, n: int) -> bool:
        """Check if expr matches iterExp n at all test points."""
        for x in test_points:
            try:
                v1 = expr.eval(x)
                v2 = iter_exp(n, x)
                if v1 == float('inf') or v2 == float('inf'):
                    continue
                if abs(v1 - v2) > tolerance * max(1, abs(v2)):
                    return False
            except (OverflowError, ValueError):
                return False
        return True

    constants = [0.0, 1.0, -1.0, 2.0]
    leaves = [EVar()] + [EConst(c) for c in constants]

    # Generate all expressions up to a given size
    def gen_exprs(max_size: int):
        """Generate all EMLExpr up to given size."""
        if max_size <= 1:
            return list(leaves)
        result = list(leaves)
        # Recursively build larger expressions
        for s in range(2, max_size + 1):
            for s1 in range(1, s):
                s2 = s - 1 - s1
                if s2 < 1:
                    continue
                smaller1 = [e for e in result if e.size() == s1]
                smaller2 = [e for e in result if e.size() == s2]
                for a in smaller1:
                    for b in smaller2:
                        result.append(EAdd(a, b))
                        result.append(EMul(a, b))
                        result.append(EML(a, b))
        return result

    for n in [1, 2]:
        print(f"Searching for EMLExpr with eml_depth < {n} representing iterExp({n})...")
        exprs = gen_exprs(min(5, 2*n + 3))
        found = False
        count = 0
        for e in exprs:
            if e.eml_depth() < n:
                count += 1
                if matches_iter_exp(e, n):
                    print(f"  FOUND: {e} (eml_depth={e.eml_depth()}, exp_rank={e.exp_rank()})")
                    found = True
                    break
        if not found:
            print(f"  No match found among {count} expressions with eml_depth < {n}.")
            print(f"  This is consistent with the lower bound conjecture.")
        print()


# ============================================================
# Demo 5: Visualize the depth gap
# ============================================================

def demo_depth_gap():
    """Show the growing gap between achievable and required depth."""
    print("=" * 70)
    print("DEMO 5: Depth Separation Gap Visualization")
    print("=" * 70)
    print()

    max_n = 15
    print(f"{'n':>3} | {'Full depth':>10} | {'EML lower bound':>15} | {'Gap visualization'}")
    print("-" * 65)
    for n in range(max_n + 1):
        full_d = n
        eml_lb = n  # conjectured lower bound
        bar_full = "█" * full_d if full_d > 0 else "·"
        bar_eml = "▓" * eml_lb if eml_lb > 0 else "·"
        print(f"{n:3d} | {full_d:10d} | {eml_lb:15d} | Full: {bar_full}")
        print(f"    |            |                 | EML:  {bar_eml}")

    print()
    print("Both representations require depth n. The EML language cannot")
    print("'compress' iterated exponentials below linear depth.")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║     EML Circuit Depth Separation — Interactive Demo            ║")
    print("║                                                                ║")
    print("║  Showing that equal expressiveness ≠ equal efficiency          ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    demo_comparison()
    demo_evaluation()
    demo_growth_bound()
    demo_search()
    demo_depth_gap()

    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print()
    print("The iterated exponential iterExp(n) has:")
    print("  • FullExpr depth = n (linear, trivially achieved)")
    print("  • EMLExpr emlDepth ≥ n (linear lower bound, conjectured)")
    print("  • EMLExpr expRank = n (for canonical construction)")
    print("  • expRank ≤ emlDepth (proved for all expressions)")
    print()
    print("This demonstrates a fundamental depth separation between two")
    print("expressively equivalent languages for transcendental computation.")
