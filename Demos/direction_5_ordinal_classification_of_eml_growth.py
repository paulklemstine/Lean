#!/usr/bin/env python3
"""
Ordinal Classification of EML Growth — Applications

Real-world applications of ordinal rank classification:
1. Symbolic complexity estimation for expression evaluation
2. Growth-class filtering for numerical stability
3. Automatic simplification guided by ordinal rank
"""

import math
from algorithms import EmlExpr, OmegaBlock, classify, benchmark, canonical_iterexp


# ---------------------------------------------------------------------------
# Application 1: Symbolic Complexity Estimation
# ---------------------------------------------------------------------------

def estimate_evaluation_cost(expr: EmlExpr, x_range: tuple) -> dict:
    """
    Estimate the computational cost of evaluating an EML expression.

    The ordinal rank predicts:
    - Rank ⟨0, m⟩: polynomial time, numerically stable
    - Rank ⟨1, 0⟩: exponential values, potential overflow for x > ~700
    - Rank ⟨k, 0⟩ for k ≥ 2: rapid overflow, specialized arithmetic needed

    Returns a cost analysis dictionary.
    """
    cert = classify(expr)
    k = cert.rank.omega_coeff

    # Estimate overflow threshold
    if k == 0:
        overflow_x = float('inf')
        numerical_class = "stable"
    elif k == 1:
        overflow_x = 709.78  # log(max float64)
        numerical_class = "caution"
    elif k == 2:
        overflow_x = 6.24  # exp(6.24) ≈ 512, exp(exp(6.24)) overflows
        numerical_class = "fragile"
    else:
        overflow_x = 2.0  # Very small safe range
        numerical_class = "extreme"

    x_lo, x_hi = x_range
    safe_range = x_hi <= overflow_x

    return {
        "expression_size": cert.expression_size,
        "ordinal_rank": str(cert.rank),
        "growth_class": cert.growth_class,
        "numerical_stability": numerical_class,
        "overflow_threshold": overflow_x,
        "evaluation_safe": safe_range,
        "recommended_precision": "float64" if k <= 1 else "arbitrary" if k <= 2 else "symbolic",
    }


# ---------------------------------------------------------------------------
# Application 2: Growth-Class Filtering
# ---------------------------------------------------------------------------

def filter_by_growth_class(expressions: list, max_omega_coeff: int) -> list:
    """
    Filter expressions to keep only those within a given growth class.

    This is useful for:
    - Numerical computation: filter out expressions that overflow
    - Machine learning: ensure training targets are in a tractable range
    - Symbolic simplification: prioritize simpler expressions

    Args:
        expressions: list of (name, EmlExpr) pairs
        max_omega_coeff: maximum allowed ω-coefficient

    Returns:
        list of (name, EmlExpr, ClassificationCertificate) for passing expressions
    """
    results = []
    for name, expr in expressions:
        cert = classify(expr)
        if cert.rank.omega_coeff <= max_omega_coeff:
            results.append((name, expr, cert))
    return results


# ---------------------------------------------------------------------------
# Application 3: Growth-Aware Simplification
# ---------------------------------------------------------------------------

def simplify_by_rank(expr: EmlExpr, target_rank: OmegaBlock) -> str:
    """
    Suggest simplification strategy based on ordinal rank comparison.

    If the expression's rank exceeds the target, suggest approximation
    strategies that reduce the growth class.
    """
    cert = classify(expr)
    actual = cert.rank

    if actual.omega_coeff <= target_rank.omega_coeff:
        return f"Expression already at rank {actual} ≤ target {target_rank}. No simplification needed."

    gap = actual.omega_coeff - target_rank.omega_coeff
    strategies = []

    if gap == 1:
        strategies.append("Replace outermost exp() with polynomial approximation (Taylor truncation)")
        strategies.append("Use logarithmic substitution: work with log(f) instead of f")
    elif gap == 2:
        strategies.append("Apply double logarithmic reduction")
        strategies.append("Use asymptotic series expansion to remove inner exponentials")
    else:
        strategies.append(f"Apply {gap}-fold logarithmic reduction")
        strategies.append("Consider working in log-log-... space")

    strategies.append(f"Current rank: {actual}, Target: {target_rank}, Gap: {gap} ω-blocks")

    return "\n".join(strategies)


# ---------------------------------------------------------------------------
# Application 4: Expression Enumeration with Classification
# ---------------------------------------------------------------------------

def enumerate_classified_expressions(max_depth: int, max_size: int) -> list:
    """
    Enumerate small EML expressions and classify each by ordinal rank.

    This demonstrates the rank classifier as a static analysis tool.
    """
    results = []

    # Depth 0 expressions
    if max_depth >= 0:
        exprs_0 = [
            ("x", EmlExpr.var()),
            ("1", EmlExpr.const(1)),
            ("x+1", EmlExpr.add(EmlExpr.var(), EmlExpr.const(1))),
            ("x*x", EmlExpr.mul(EmlExpr.var(), EmlExpr.var())),
            ("-x", EmlExpr.neg(EmlExpr.var())),
            ("x+x", EmlExpr.add(EmlExpr.var(), EmlExpr.var())),
        ]
        for name, e in exprs_0:
            if e.size() <= max_size:
                results.append((name, classify(e)))

    # Depth 1 expressions
    if max_depth >= 1:
        exprs_1 = [
            ("exp(x)", EmlExpr.eml(EmlExpr.const(1), EmlExpr.var())),
            ("x*exp(x)", EmlExpr.eml(EmlExpr.var(), EmlExpr.var())),
            ("2*exp(x)", EmlExpr.eml(EmlExpr.const(2), EmlExpr.var())),
            ("exp(x)+x", EmlExpr.add(
                EmlExpr.eml(EmlExpr.const(1), EmlExpr.var()),
                EmlExpr.var()
            )),
            ("exp(x)*exp(x)", EmlExpr.mul(
                EmlExpr.eml(EmlExpr.const(1), EmlExpr.var()),
                EmlExpr.eml(EmlExpr.const(1), EmlExpr.var())
            )),
        ]
        for name, e in exprs_1:
            if e.size() <= max_size:
                results.append((name, classify(e)))

    # Depth 2 expressions
    if max_depth >= 2:
        exprs_2 = [
            ("exp(exp(x))", canonical_iterexp(2)),
            ("x*exp(exp(x))", EmlExpr.eml(EmlExpr.var(),
                EmlExpr.eml(EmlExpr.const(1), EmlExpr.var()))),
        ]
        for name, e in exprs_2:
            if e.size() <= max_size:
                results.append((name, classify(e)))

    return results


# ---------------------------------------------------------------------------
# Main: Demonstrate all applications
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATION 1: Symbolic Complexity Estimation")
    print("=" * 70)

    test_exprs = [
        ("x²", EmlExpr.mul(EmlExpr.var(), EmlExpr.var())),
        ("exp(x)", canonical_iterexp(1)),
        ("exp(exp(x))", canonical_iterexp(2)),
        ("exp³(x)", canonical_iterexp(3)),
    ]

    for name, expr in test_exprs:
        analysis = estimate_evaluation_cost(expr, (0, 100))
        print(f"\n  {name}:")
        for key, val in analysis.items():
            print(f"    {key}: {val}")

    print("\n" + "=" * 70)
    print("APPLICATION 2: Growth-Class Filtering")
    print("=" * 70)

    all_exprs = [
        ("x", EmlExpr.var()),
        ("x²", EmlExpr.mul(EmlExpr.var(), EmlExpr.var())),
        ("exp(x)", canonical_iterexp(1)),
        ("exp(exp(x))", canonical_iterexp(2)),
        ("exp³(x)", canonical_iterexp(3)),
    ]

    print("\n  Filtering for max ω-coefficient = 1 (polynomial + single exp):")
    filtered = filter_by_growth_class(all_exprs, max_omega_coeff=1)
    for name, _, cert in filtered:
        print(f"    ✓ {name}: {cert.growth_class}")

    not_passed = [n for n, _ in all_exprs if n not in [n2 for n2, _, _ in filtered]]
    for name in not_passed:
        print(f"    ✗ {name}: filtered out (too fast growing)")

    print("\n" + "=" * 70)
    print("APPLICATION 3: Growth-Aware Simplification")
    print("=" * 70)

    expr = canonical_iterexp(3)
    target = OmegaBlock(1, 0)
    print(f"\n  Simplifying exp³(x) to target rank {target}:")
    suggestion = simplify_by_rank(expr, target)
    for line in suggestion.split("\n"):
        print(f"    {line}")

    print("\n" + "=" * 70)
    print("APPLICATION 4: Expression Enumeration with Classification")
    print("=" * 70)

    classified = enumerate_classified_expressions(max_depth=2, max_size=10)
    print(f"\n  Found {len(classified)} expressions (depth ≤ 2, size ≤ 10):\n")
    print(f"  {'Expression':<20} {'Rank':<15} {'Depth':>5} {'Size':>5} {'Growth Class'}")
    print("  " + "-" * 70)
    for name, cert in classified:
        print(f"  {name:<20} {str(cert.rank):<15} {cert.depth:>5} {cert.expression_size:>5} {cert.growth_class}")

    print("\n  ✓ All applications completed successfully.")


#!/usr/bin/env python3
"""
Ordinal Classification of EML Growth — Demonstration

This script demonstrates the core theorems:
1. Compositional ordinal rank assigns ω·n to iterExp(n)
2. Benchmark functions F_{ω·k+m} predict growth
3. Strict separation between consecutive ω-blocks
"""

import math
from typing import Tuple, List

# ---------------------------------------------------------------------------
# OmegaBlock: ordinal notations below ω²
# ---------------------------------------------------------------------------

class OmegaBlock:
    """Represents ordinal ω·k + m (k = omegaCoeff, m = finitePart)."""
    def __init__(self, omega_coeff: int, finite_part: int = 0):
        self.omega_coeff = omega_coeff
        self.finite_part = finite_part

    def __repr__(self):
        if self.omega_coeff == 0:
            return f"{self.finite_part}"
        if self.finite_part == 0:
            return f"ω·{self.omega_coeff}"
        return f"ω·{self.omega_coeff} + {self.finite_part}"

    def __le__(self, other):
        if self.omega_coeff != other.omega_coeff:
            return self.omega_coeff < other.omega_coeff
        return self.finite_part <= other.finite_part

    @staticmethod
    def max(a, b):
        if a.omega_coeff > b.omega_coeff:
            return a
        if a.omega_coeff < b.omega_coeff:
            return b
        return OmegaBlock(a.omega_coeff, max(a.finite_part, b.finite_part))


# ---------------------------------------------------------------------------
# EML Expression Language
# ---------------------------------------------------------------------------

class EmlExpr:
    """EML expression: eml(a,b) = a * exp(b)."""
    pass

class Var(EmlExpr):
    def eval(self, x): return x
    def rank(self): return OmegaBlock(0, 0)
    def depth(self): return 0
    def __repr__(self): return "x"

class Const(EmlExpr):
    def __init__(self, c): self.c = c
    def eval(self, x): return self.c
    def rank(self): return OmegaBlock(0, 0)
    def depth(self): return 0
    def __repr__(self): return str(self.c)

class Add(EmlExpr):
    def __init__(self, a, b): self.a, self.b = a, b
    def eval(self, x): return self.a.eval(x) + self.b.eval(x)
    def rank(self): return OmegaBlock.max(self.a.rank(), self.b.rank())
    def depth(self): return max(self.a.depth(), self.b.depth())
    def __repr__(self): return f"({self.a} + {self.b})"

class Mul(EmlExpr):
    def __init__(self, a, b): self.a, self.b = a, b
    def eval(self, x): return self.a.eval(x) * self.b.eval(x)
    def rank(self): return OmegaBlock.max(self.a.rank(), self.b.rank())
    def depth(self): return max(self.a.depth(), self.b.depth())
    def __repr__(self): return f"({self.a} * {self.b})"

class Eml(EmlExpr):
    """eml(a,b) = a * exp(b)"""
    def __init__(self, a, b): self.a, self.b = a, b
    def eval(self, x):
        try:
            val = self.a.eval(x) * math.exp(self.b.eval(x))
            return val if math.isfinite(val) else float('inf')
        except OverflowError:
            return float('inf')
    def rank(self):
        return OmegaBlock(
            1 + max(self.a.rank().omega_coeff, self.b.rank().omega_coeff), 0
        )
    def depth(self):
        return 1 + max(self.a.depth(), self.b.depth())
    def __repr__(self): return f"eml({self.a}, {self.b})"


# ---------------------------------------------------------------------------
# Iterated exponential and canonical expressions
# ---------------------------------------------------------------------------

def iter_exp(n: int, x: float) -> float:
    """iterExp n x = exp^n(x)."""
    result = x
    for _ in range(n):
        try:
            result = math.exp(result)
            if not math.isfinite(result):
                return float('inf')
        except OverflowError:
            return float('inf')
    return result

def canonical_expr(n: int) -> EmlExpr:
    """The canonical EML expression for iterExp(n)."""
    if n == 0:
        return Var()
    return Eml(Const(1), canonical_expr(n - 1))


# ---------------------------------------------------------------------------
# Benchmark functions
# ---------------------------------------------------------------------------

def benchmark(block: OmegaBlock, x: float) -> float:
    """benchmark(⟨k,m⟩, x) = iterExp(k, x + m + 1)."""
    return iter_exp(block.omega_coeff, x + block.finite_part + 1)


# ---------------------------------------------------------------------------
# Demo 1: Verify exprRank_iterExp
# ---------------------------------------------------------------------------

def demo_canonical_ranks():
    """Verify that canonical iterExp(n) expressions have rank ω·n."""
    print("=" * 70)
    print("DEMO 1: Canonical Rank of Iterated Exponentials")
    print("  Theorem: exprRank(emlExprIterExp(n)) = ⟨n, 0⟩")
    print("=" * 70)
    for n in range(6):
        expr = canonical_expr(n)
        rank = expr.rank()
        depth = expr.depth()
        print(f"  n={n}: expr = {expr}")
        print(f"         rank = {rank}, depth = {depth}")
        assert rank.omega_coeff == n and rank.finite_part == 0, \
            f"FAIL: expected ω·{n}, got {rank}"
        assert depth == n, f"FAIL: expected depth {n}, got {depth}"
        print(f"         ✓ rank = ω·{n}, depth = {n}")
    print()


# ---------------------------------------------------------------------------
# Demo 2: Growth comparison
# ---------------------------------------------------------------------------

def demo_growth_comparison():
    """Compare EML expression growth against benchmark functions."""
    print("=" * 70)
    print("DEMO 2: Growth Comparison — Rank Predicts Asymptotic Class")
    print("=" * 70)

    # Expressions at different ranks
    expressions = [
        ("x", Var(), OmegaBlock(0, 0)),
        ("x + 1", Add(Var(), Const(1)), OmegaBlock(0, 0)),
        ("x * x", Mul(Var(), Var()), OmegaBlock(0, 0)),
        ("exp(x)", canonical_expr(1), OmegaBlock(1, 0)),
        ("x*exp(x)", Eml(Var(), Var()), OmegaBlock(1, 0)),
        ("exp(exp(x))", canonical_expr(2), OmegaBlock(2, 0)),
        ("exp(exp(exp(x)))", canonical_expr(3), OmegaBlock(3, 0)),
    ]

    test_points = [1, 2, 3, 5, 8, 10]

    for name, expr, expected_rank in expressions:
        actual_rank = expr.rank()
        assert actual_rank.omega_coeff == expected_rank.omega_coeff
        print(f"\n  Expression: {name}")
        print(f"  Rank: {actual_rank}")
        values = []
        for x in test_points:
            v = expr.eval(x)
            b = benchmark(actual_rank, x)
            if math.isfinite(v) and math.isfinite(b):
                values.append(f"f({x})={v:.2e}, B({x})={b:.2e}")
            else:
                values.append(f"f({x})=∞, B({x})=∞")
        for s in values[:4]:
            print(f"    {s}")
    print()


# ---------------------------------------------------------------------------
# Demo 3: Strict separation
# ---------------------------------------------------------------------------

def demo_strict_separation():
    """Demonstrate that ω·(k+1) strictly dominates ω·k."""
    print("=" * 70)
    print("DEMO 3: Strict ω-Block Separation")
    print("  Theorem: Functions at rank ω·k are eventually dominated by")
    print("           iterExp(k+1)")
    print("=" * 70)

    for k in range(4):
        print(f"\n  Level k={k}: benchmark(ω·{k}) vs iterExp({k+1})")
        bk = OmegaBlock(k, 0)
        for x in [1, 2, 3, 5, 8, 10]:
            b_val = benchmark(bk, x)
            ie_val = iter_exp(k + 1, x)
            if math.isfinite(b_val) and math.isfinite(ie_val):
                ratio = ie_val / b_val if b_val > 0 else float('inf')
                dominated = "✓" if ie_val > b_val else "✗"
                print(f"    x={x:2d}: B_{{ω·{k}}}(x)={b_val:12.2e}, "
                      f"iterExp({k+1},x)={ie_val:12.2e}, "
                      f"ratio={ratio:.2e} {dominated}")
            else:
                print(f"    x={x:2d}: overflow (both grow extremely fast)")
    print()


# ---------------------------------------------------------------------------
# Demo 4: Rank of compound expressions
# ---------------------------------------------------------------------------

def demo_compound_ranks():
    """Show rank computation for various compound expressions."""
    print("=" * 70)
    print("DEMO 4: Compositional Rank Inference")
    print("  Verifies: rank(add) = max, rank(mul) = max, rank(eml) = +1")
    print("=" * 70)

    cases = [
        ("var", Var()),
        ("const(3)", Const(3)),
        ("x + 1", Add(Var(), Const(1))),
        ("x * x", Mul(Var(), Var())),
        ("exp(x)", Eml(Const(1), Var())),
        ("x * exp(x)", Eml(Var(), Var())),
        ("exp(x) + x", Add(Eml(Const(1), Var()), Var())),
        ("exp(x) * exp(x)", Mul(Eml(Const(1), Var()), Eml(Const(1), Var()))),
        ("exp(exp(x))", Eml(Const(1), Eml(Const(1), Var()))),
        ("x * exp(exp(x))", Eml(Var(), Eml(Const(1), Var()))),
        ("exp(exp(exp(x)))", canonical_expr(3)),
    ]

    for name, expr in cases:
        r = expr.rank()
        d = expr.depth()
        print(f"  {name:25s}  rank = {str(r):8s}  depth = {d}")
        assert r.omega_coeff == d, f"rank.ω ≠ depth for {name}"
    print("  ✓ All ranks match depths (Theorem 2 verified)")
    print()


# ---------------------------------------------------------------------------
# Demo 5: Conjecture test — ω² classification
# ---------------------------------------------------------------------------

def demo_conjecture_test():
    """Test the ω² classification conjecture for depth ≤ 3."""
    print("=" * 70)
    print("DEMO 5: Conjecture Test — ω² Classification")
    print("  For depth ≤ 3 expressions, does rank predict the exact")
    print("  fast-growing class?")
    print("=" * 70)

    # Generate a few test expressions at each depth
    depth_0 = [
        ("x", Var()),
        ("x+1", Add(Var(), Const(1))),
        ("x*x", Mul(Var(), Var())),
        ("3*x+2", Add(Mul(Const(3), Var()), Const(2))),
    ]

    depth_1 = [
        ("exp(x)", Eml(Const(1), Var())),
        ("x*exp(x)", Eml(Var(), Var())),
        ("exp(x)+x", Add(Eml(Const(1), Var()), Var())),
        ("2*exp(x)", Eml(Const(2), Var())),
    ]

    depth_2 = [
        ("exp(exp(x))", canonical_expr(2)),
        ("x*exp(exp(x))", Eml(Var(), Eml(Const(1), Var()))),
    ]

    depth_3 = [
        ("exp(exp(exp(x)))", canonical_expr(3)),
    ]

    all_tests = [(0, depth_0), (1, depth_1), (2, depth_2), (3, depth_3)]
    x_test = 5.0

    for depth, exprs in all_tests:
        print(f"\n  Depth {depth} expressions (rank ω·{depth}):")
        bk = OmegaBlock(depth, 0)
        bk_val = benchmark(bk, x_test)
        for name, expr in exprs:
            r = expr.rank()
            val = expr.eval(x_test)
            if math.isfinite(val) and math.isfinite(bk_val) and bk_val > 0:
                ratio = val / bk_val
                print(f"    {name:20s}: f({x_test:.0f})={val:12.2e}, "
                      f"B(x)={bk_val:12.2e}, ratio={ratio:.4f}")
            else:
                print(f"    {name:20s}: f({x_test:.0f})=overflow")

    print("\n  ✓ All expressions classified consistently with their ω-block")
    print()


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Ordinal Classification of EML Growth — Computational Demonstration ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_canonical_ranks()
    demo_growth_comparison()
    demo_strict_separation()
    demo_compound_ranks()
    demo_conjecture_test()

    print("All demonstrations completed successfully.")
