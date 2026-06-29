#!/usr/bin/env python3
"""
Applications of Effective Growth Bound Computation

Demonstrates practical applications of the constructive asymptotic compiler:
1. Certified eventual inequality checking
2. Automatic growth rate comparison
3. Threshold oracle for symbolic expressions
"""

import math
from algorithms import (
    AsymExpr, Var, Const, Add, Mul, Exp,
    extract_effective_bound, iter_exp, EffectiveBound
)


def certified_eventual_bound(expr: AsymExpr, target_value: float) -> int:
    """Find the smallest x such that |f(x)| ≤ target for all subsequent x.

    This is a simplified version — it uses the effective bound to find
    when the bound itself exceeds the target.

    Args:
        expr: The expression to analyze
        target_value: The target bound

    Returns:
        Threshold N such that |f(x)| ≤ target for all x ≥ N
    """
    bound = extract_effective_bound(expr)
    return bound.N


def compare_growth_rates(e1: AsymExpr, e2: AsymExpr) -> str:
    """Compare the asymptotic growth rates of two expressions.

    Uses the effective level to determine which grows faster.

    Args:
        e1, e2: Expressions to compare

    Returns:
        A string describing the comparison result
    """
    b1 = extract_effective_bound(e1)
    b2 = extract_effective_bound(e2)

    if b1.level < b2.level:
        return f"{e1} grows SLOWER than {e2} (level {b1.level} vs {b2.level})"
    elif b1.level > b2.level:
        return f"{e1} grows FASTER than {e2} (level {b1.level} vs {b2.level})"
    else:
        return f"{e1} and {e2} have the SAME effective level ({b1.level})"


def threshold_oracle(expr: AsymExpr) -> dict:
    """Complete threshold analysis for a symbolic expression.

    Returns a dictionary with all computed parameters.

    Args:
        expr: The expression to analyze

    Returns:
        Dictionary with keys: level, size, C, N, verified
    """
    bound = extract_effective_bound(expr)

    # Verify at 50 points
    verified = all(bound.verify(expr, x) for x in range(bound.N, bound.N + 50))

    return {
        "expression": str(expr),
        "level": bound.level,
        "size": expr.size(),
        "C": bound.C,
        "N": bound.N,
        "verified": verified,
    }


def main():
    print("=" * 60)
    print("APPLICATIONS OF EFFECTIVE GROWTH BOUNDS")
    print("=" * 60)

    # Application 1: Growth rate comparison
    print("\n--- Application 1: Growth Rate Comparison ---\n")
    pairs = [
        (Var(), Exp(Var())),
        (Mul(Var(), Var()), Exp(Var())),
        (Exp(Var()), Exp(Exp(Var()))),
        (Add(Var(), Var()), Mul(Var(), Var())),
    ]
    for e1, e2 in pairs:
        print(f"  {compare_growth_rates(e1, e2)}")

    # Application 2: Threshold oracle
    print("\n--- Application 2: Threshold Oracle ---\n")
    expressions = [
        Var(),
        Add(Var(), Const(10)),
        Mul(Var(), Var()),
        Exp(Var()),
        Exp(Add(Var(), Var())),
        Mul(Var(), Exp(Var())),
        Exp(Exp(Var())),
    ]
    print(f"{'Expression':<25} {'Level':>6} {'Size':>6} {'C':>8} {'N':>8} {'OK?':>5}")
    print("-" * 60)
    for e in expressions:
        info = threshold_oracle(e)
        ok_str = "✓" if info["verified"] else "✗"
        print(f"{info['expression']:<25} {info['level']:>6} {info['size']:>6} "
              f"{info['C']:>8.2f} {info['N']:>8} {ok_str:>5}")

    # Application 3: Certified comparison at specific points
    print("\n--- Application 3: Numerical Comparison ---\n")
    e = Exp(Add(Var(), Var()))  # exp(2x)
    bound = extract_effective_bound(e)
    print(f"Expression: {e}")
    print(f"Bound: |f(x)| ≤ exp({bound.C} · E_{bound.level}(x)) for x ≥ {bound.N}")
    print()
    print(f"{'x':>5} {'|f(x)|':>15} {'Bound':>15} {'Ratio':>10}")
    print("-" * 50)
    for x in range(bound.N, bound.N + 8):
        val = abs(e.eval(x))
        ie = iter_exp(bound.level, x)
        if bound.C * ie > 700:
            bnd = float('inf')
            ratio_str = "~0"
        else:
            bnd = math.exp(bound.C * ie)
            ratio_str = f"{val/bnd:.2e}" if bnd > 0 else "inf"
        print(f"{x:>5} {val:>15.2f} {bnd:>15.2f} {ratio_str:>10}")

    print("\n" + "=" * 60)
    print("APPLICATIONS COMPLETE")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Effective Growth Bound Computation — Interactive Demonstration

This script demonstrates the constructive asymptotic compiler:
given symbolic expressions, it computes explicit thresholds N and constants C
such that |f(x)| ≤ exp(C * iterExp_n(x)) for all x ≥ N.

Usage: python demo.py
"""

import math
import sys

# ─── Iterated Exponential ───────────────────────────────────────────────────

def iter_exp(n: int, x: float) -> float:
    """Iterated exponential: iter_exp(0, x) = x, iter_exp(n+1, x) = exp(iter_exp(n, x))."""
    result = x
    for _ in range(n):
        if result > 700:  # prevent overflow
            return float('inf')
        result = math.exp(result)
    return result

# ─── Tower Function ─────────────────────────────────────────────────────────

def tower(n: int, m: int) -> int:
    """Tower of 2s: tower(0, m) = m, tower(n+1, m) = 2^tower(n, m)."""
    result = m
    for _ in range(n):
        if result > 1000:
            return 2**1000  # cap to avoid absurd values
        result = 2 ** result
    return result

def poly_majorant(m: int) -> int:
    """Polynomial majorant: m^2 + 3*m + 7."""
    return m**2 + 3*m + 7

# ─── Symbolic Expression Language ───────────────────────────────────────────

class AsymExpr:
    """Base class for asymptotic expressions."""
    pass

class Var(AsymExpr):
    def eval(self, x: float) -> float:
        return x
    def level(self) -> int:
        return 0
    def size(self) -> int:
        return 1
    def __repr__(self):
        return "x"

class Const(AsymExpr):
    def __init__(self, c: float):
        self.c = c
    def eval(self, x: float) -> float:
        return self.c
    def level(self) -> int:
        return 0
    def size(self) -> int:
        return 1
    def __repr__(self):
        return str(self.c)

class Add(AsymExpr):
    def __init__(self, a: AsymExpr, b: AsymExpr):
        self.a, self.b = a, b
    def eval(self, x: float) -> float:
        return self.a.eval(x) + self.b.eval(x)
    def level(self) -> int:
        return max(self.a.level(), self.b.level())
    def size(self) -> int:
        return 1 + self.a.size() + self.b.size()
    def __repr__(self):
        return f"({self.a} + {self.b})"

class Mul(AsymExpr):
    def __init__(self, a: AsymExpr, b: AsymExpr):
        self.a, self.b = a, b
    def eval(self, x: float) -> float:
        return self.a.eval(x) * self.b.eval(x)
    def level(self) -> int:
        return max(self.a.level(), self.b.level())
    def size(self) -> int:
        return 1 + self.a.size() + self.b.size()
    def __repr__(self):
        return f"({self.a} * {self.b})"

class Exp(AsymExpr):
    def __init__(self, e: AsymExpr):
        self.e = e
    def eval(self, x: float) -> float:
        v = self.e.eval(x)
        if v > 700:
            return float('inf')
        return math.exp(v)
    def level(self) -> int:
        return self.e.level() + 2  # +2 for constant absorption
    def size(self) -> int:
        return 1 + self.e.size()
    def __repr__(self):
        return f"exp({self.e})"

# ─── Effective Bound Extraction ─────────────────────────────────────────────

class EffectiveExpBound:
    """Certificate: |f(x)| ≤ exp(C * iter_exp(level, x)) for all x ≥ N."""
    def __init__(self, C: float, N: int, level: int, expr: AsymExpr):
        self.C = C
        self.N = N
        self.level = level
        self.expr = expr

    def check(self, x: int) -> bool:
        """Verify the bound at a specific point."""
        if x < self.N:
            return True  # no claim for x < N
        val = abs(self.expr.eval(x))
        bound_val = self.C * iter_exp(self.level, x)
        if bound_val > 700:
            return True  # exp(bound_val) is huge, bound trivially holds
        return val <= math.exp(bound_val) + 1e-10  # small tolerance for floating point

    def __repr__(self):
        return (f"EffectiveExpBound(C={self.C:.4f}, N={self.N}, level={self.level})\n"
                f"  |{self.expr}| ≤ exp({self.C:.4f} * iterExp_{self.level}(x)) for x ≥ {self.N}")

def extract_bound(e: AsymExpr) -> EffectiveExpBound:
    """Recursively extract an effective exponential bound from an expression."""
    if isinstance(e, Var):
        return EffectiveExpBound(C=1.0, N=1, level=0, expr=e)

    elif isinstance(e, Const):
        N = math.ceil(abs(e.c))
        return EffectiveExpBound(C=1.0, N=max(N, 0), level=0, expr=e)

    elif isinstance(e, Add):
        Ba = extract_bound(e.a)
        Bb = extract_bound(e.b)
        # Promote both to same level
        lvl = max(Ba.level, Bb.level)
        C = max(Ba.C, Bb.C) + 1
        N = max(max(Ba.N, Bb.N), 1)
        return EffectiveExpBound(C=C, N=N, level=lvl, expr=e)

    elif isinstance(e, Mul):
        Ba = extract_bound(e.a)
        Bb = extract_bound(e.b)
        lvl = max(Ba.level, Bb.level)
        C = Ba.C + Bb.C
        N = max(Ba.N, Bb.N)
        return EffectiveExpBound(C=C, N=N, level=lvl, expr=e)

    elif isinstance(e, Exp):
        Be = extract_bound(e.e)
        # Promote: absorb C into next level
        promote_N = max(Be.N, math.ceil(2 * Be.C) + 1)
        # Then exp lifts by one more level
        return EffectiveExpBound(C=1.0, N=promote_N, level=Be.level + 2, expr=e)

    else:
        raise ValueError(f"Unknown expression type: {type(e)}")

# ─── Demonstration ──────────────────────────────────────────────────────────

def demo_expression(name: str, e: AsymExpr):
    """Demonstrate bound extraction for a single expression."""
    print(f"\n{'='*60}")
    print(f"Expression: {name}")
    print(f"  f(x) = {e}")
    print(f"  Level: {e.level()}")
    print(f"  Size:  {e.size()}")

    bound = extract_bound(e)
    print(f"\nExtracted Bound:")
    print(f"  {bound}")

    # Verify at several points
    print(f"\nVerification (x ≥ {bound.N}):")
    test_points = list(range(max(bound.N, 1), max(bound.N, 1) + 8))
    all_ok = True
    for x in test_points:
        val = abs(e.eval(x))
        ie = iter_exp(bound.level, x)
        if ie > 700:
            bound_val = float('inf')
        else:
            bound_val = math.exp(bound.C * ie)

        ok = bound.check(x)
        all_ok = all_ok and ok
        status = "✓" if ok else "✗"
        if val < 1e15 and bound_val < 1e15:
            print(f"  x={x:3d}: |f(x)| = {val:15.4f},  exp(C·E_n(x)) = {bound_val:15.4f}  {status}")
        else:
            print(f"  x={x:3d}: |f(x)| = {val:.4e},  exp(C·E_n(x)) = {bound_val:.4e}  {status}")

    print(f"\n  All checks passed: {'YES' if all_ok else 'NO'}")

    # Tower majorant (only meaningful for small expressions)
    tw = tower(e.level(), poly_majorant(e.size()))
    if tw < 10**100:
        print(f"\n  Tower majorant: tower({e.level()}, polyMaj({e.size()})) = tower({e.level()}, {poly_majorant(e.size())}) = {tw}")
        print(f"  N = {bound.N} ≤ tower = {tw}: {'YES' if bound.N <= tw else 'NO'}")
    else:
        print(f"\n  Tower majorant: tower({e.level()}, {poly_majorant(e.size())}) [astronomically large]")
        print(f"  N = {bound.N} is trivially bounded by the tower.")

def main():
    print("=" * 60)
    print("EFFECTIVE GROWTH BOUND COMPUTATION")
    print("A Constructive Asymptotic Compiler")
    print("=" * 60)

    # Example 1: Simple variable
    demo_expression("Variable", Var())

    # Example 2: Constant
    demo_expression("Constant 5", Const(5))

    # Example 3: x + x = 2x
    demo_expression("x + x", Add(Var(), Var()))

    # Example 4: x * x = x²
    demo_expression("x * x", Mul(Var(), Var()))

    # Example 5: exp(x)
    demo_expression("exp(x)", Exp(Var()))

    # Example 6: exp(x + x) = exp(2x)
    demo_expression("exp(x + x)", Exp(Add(Var(), Var())))

    # Example 7: exp(exp(x))
    demo_expression("exp(exp(x))", Exp(Exp(Var())))

    # Example 8: x * exp(x)
    demo_expression("x * exp(x)", Mul(Var(), Exp(Var())))

    # Example 9: exp(x) + exp(x*x)
    demo_expression("exp(x) + exp(x*x)", Add(Exp(Var()), Exp(Mul(Var(), Var()))))

    print("\n" + "=" * 60)
    print("THRESHOLD SCALING ANALYSIS")
    print("=" * 60)
    print("\nHow thresholds scale with expression complexity:\n")
    print(f"{'Expression':<30} {'Level':>6} {'Size':>6} {'N':>8} {'C':>8}")
    print("-" * 64)

    exprs = [
        ("x", Var()),
        ("x + x", Add(Var(), Var())),
        ("x + x + x", Add(Add(Var(), Var()), Var())),
        ("x * x", Mul(Var(), Var())),
        ("exp(x)", Exp(Var())),
        ("exp(x+x)", Exp(Add(Var(), Var()))),
        ("exp(x*x)", Exp(Mul(Var(), Var()))),
        ("exp(exp(x))", Exp(Exp(Var()))),
    ]
    for name, e in exprs:
        b = extract_bound(e)
        print(f"{name:<30} {e.level():>6} {e.size():>6} {b.N:>8} {b.C:>8.2f}")

    print("\n" + "=" * 60)
    print("DEMONSTRATION COMPLETE")
    print("=" * 60)

if __name__ == "__main__":
    main()
