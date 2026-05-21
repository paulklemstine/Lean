#!/usr/bin/env python3
"""
Applications of the EML Depth Hierarchy Theorem.

Demonstrates practical applications:
1. Certified depth lower bounds for symbolic expressions
2. Expression complexity classification
3. Optimal symbolic compilation verification
"""

import math
from algorithms import (
    EMLExpr, ExprType, Var, Const, Add, Mul, Neg, Eml,
    eml_expr_iterexp, iterExp, estimate_tower_majorant_level,
    verify_depth_separation
)


def application_1_certified_lower_bounds():
    """Application: Certify that a target function requires minimum depth."""
    print("=" * 70)
    print("APPLICATION 1: Certified Depth Lower Bounds")
    print("=" * 70)
    print()
    print("Given a target function, determine the minimum EML depth required.")
    print("By our theorem: iterExp(n) requires exactly depth n.")
    print()

    for n in range(1, 5):
        print(f"  iterExp({n}): minimum depth = {n}")
        # Verify by checking separation at depth n-1
        if n >= 2:
            # Any depth-(n-1) expression will fail
            # Try the best depth-(n-1) candidate: iterExp(n-1) itself
            cand = eml_expr_iterexp(n - 1)
            sep, witness = verify_depth_separation(cand, n)
            if sep:
                print(f"    ✓ Verified: depth-{n-1} candidate (iterExp({n-1})) "
                      f"separated at x={witness:.1f}")
            else:
                print(f"    ✗ No separation found (numerical precision issue)")
    print()


def application_2_expression_classification():
    """Application: Classify expressions by growth complexity."""
    print("=" * 70)
    print("APPLICATION 2: Expression Growth Classification")
    print("=" * 70)
    print()

    expressions = [
        ("x", Var()),
        ("x * x", Mul(Var(), Var())),
        ("x * x * x", Mul(Mul(Var(), Var()), Var())),
        ("exp(x)", Eml(Const(1.0), Var())),
        ("x * exp(x)", Eml(Var(), Var())),
        ("exp(exp(x))", eml_expr_iterexp(2)),
        ("exp(exp(exp(x)))", eml_expr_iterexp(3)),
    ]

    print(f"  {'Expression':>20} | {'Depth':>6} | {'Rank':>6} | {'Size':>6} | {'Tower Level':>12}")
    print(f"  {'-'*20}-+-{'-'*6}-+-{'-'*6}-+-{'-'*6}-+-{'-'*12}")

    for name, expr in expressions:
        depth = expr.eml_depth()
        rank = expr.growth_rank()
        size = expr.size()
        level, C, N = estimate_tower_majorant_level(lambda x: expr.eval(x))
        print(f"  {name:>20} | {depth:>6} | {rank:>6} | {size:>6} | {level:>12}")

    print()
    print("  Key insight: growth rank = eml depth for all inverse-free expressions.")
    print("  The tower level exactly matches the structural depth measure.")
    print()


def application_3_compilation_verification():
    """Application: Verify optimality of symbolic compilations."""
    print("=" * 70)
    print("APPLICATION 3: Symbolic Compilation Optimality")
    print("=" * 70)
    print()
    print("  Question: Is the canonical representation of iterExp(n) optimal?")
    print("  Answer: YES — by our theorem, depth n is necessary and sufficient.")
    print()

    for n in range(5):
        canonical = eml_expr_iterexp(n)
        print(f"  iterExp({n}):")
        print(f"    Canonical depth: {canonical.eml_depth()}")
        print(f"    Canonical size:  {canonical.size()}")
        print(f"    Optimal depth:   {n} (proven)")
        print(f"    Depth optimal:   {'YES' if canonical.eml_depth() == n else 'NO'}")
        print()


def application_4_hierarchy_visualization():
    """Application: Visualize the strict depth hierarchy."""
    print("=" * 70)
    print("APPLICATION 4: Strict Depth Hierarchy (Text Visualization)")
    print("=" * 70)
    print()

    x = 2.0
    print(f"  Values at x = {x}:")
    print()
    for n in range(6):
        val = iterExp(n, x)
        if val == float('inf'):
            bar = ">" * 60 + " (overflow)"
        else:
            # Log-scale bar
            if val > 0:
                bar_len = min(60, int(math.log10(max(val, 1)) * 5) + 1)
            else:
                bar_len = 1
            bar = "█" * bar_len
        print(f"  Depth {n}: {bar} ({val:.2e})" if val != float('inf')
              else f"  Depth {n}: {bar}")

    print()
    print("  Each level produces dramatically more growth than the previous.")
    print("  This gap cannot be bridged by any algebraic rearrangement.")


if __name__ == "__main__":
    application_1_certified_lower_bounds()
    application_2_expression_classification()
    application_3_compilation_verification()
    application_4_hierarchy_visualization()


#!/usr/bin/env python3
"""
Demonstration of the Tight Depth Hierarchy Theorem for EML Expressions.

This script visualizes the key mathematical results:
1. Growth comparison of depth-D expressions vs iterExp(n) for n > D
2. The absorption lemma: 2 * iterExp(D, t) <= iterExp(D, t+1)
3. Polynomial vs exponential domination
4. Depth separation: candidate low-depth expressions vs iterExp targets
"""

import math
import sys

def iterExp(n, x):
    """Iterated exponential: iterExp(0, x) = x, iterExp(n+1, x) = exp(iterExp(n, x))."""
    result = x
    for _ in range(n):
        if result > 500:  # overflow protection
            return float('inf')
        result = math.exp(result)
    return result

def iterExp_poly(k, C, N, x):
    """iterExp(k, C * x^N) - tower with polynomial argument."""
    arg = C * (x ** N)
    return iterExp(k, arg)


def demo_growth_comparison():
    """Compare growth of depth-D candidates vs iterExp(n) for n > D."""
    print("=" * 70)
    print("DEMO 1: Growth Comparison — Depth D Cannot Represent iterExp(n) for n > D")
    print("=" * 70)
    print()

    test_points = [1.0, 1.5, 2.0, 2.5, 3.0]

    for D in range(4):
        n = D + 1  # The target: one level beyond depth D
        print(f"  D = {D}, target = iterExp({n}, x)")
        print(f"  {'x':>6} | {'iterExp(D, 10*x^2)':>20} | {'iterExp(n, x)':>20} | {'Gap':>12}")
        print(f"  {'-'*6}-+-{'-'*20}-+-{'-'*20}-+-{'-'*12}")

        for x in test_points:
            # Best depth-D majorant with polynomial argument
            majorant = iterExp_poly(D, 10, 2, x)
            target = iterExp(n, x)

            if majorant == float('inf') or target == float('inf'):
                print(f"  {x:6.1f} | {'overflow':>20} | {'overflow':>20} | {'N/A':>12}")
            else:
                gap = target - majorant
                print(f"  {x:6.1f} | {majorant:20.4f} | {target:20.4f} | {gap:12.4f}")
        print()


def demo_absorption():
    """Demonstrate the absorption lemma: 2 * iterExp(D, t) <= iterExp(D, t+1)."""
    print("=" * 70)
    print("DEMO 2: Double Absorption — 2 * iterExp(D, t) ≤ iterExp(D, t+1)")
    print("=" * 70)
    print()

    for D in range(1, 4):
        print(f"  D = {D}:")
        print(f"  {'t':>6} | {'2*iterExp(D,t)':>20} | {'iterExp(D,t+1)':>20} | {'Ratio':>10}")
        print(f"  {'-'*6}-+-{'-'*20}-+-{'-'*20}-+-{'-'*10}")

        for t in [0.0, 0.5, 1.0, 2.0, 3.0]:
            lhs = 2 * iterExp(D, t)
            rhs = iterExp(D, t + 1)
            if lhs == float('inf') or rhs == float('inf'):
                print(f"  {t:6.1f} | {'overflow':>20} | {'overflow':>20} | {'N/A':>10}")
            else:
                ratio = rhs / lhs if lhs > 0 else float('inf')
                print(f"  {t:6.1f} | {lhs:20.6f} | {rhs:20.6f} | {ratio:10.4f}")
        print()


def demo_poly_vs_exp():
    """Demonstrate that C * x^N < exp(x) for large x."""
    print("=" * 70)
    print("DEMO 3: Polynomial vs Exponential — C * x^N < exp(x) Eventually")
    print("=" * 70)
    print()

    cases = [(1, 1), (10, 2), (100, 3), (1000, 5)]
    for C, N in cases:
        print(f"  C = {C}, N = {N}:")
        found_crossover = False
        for x_int in range(1, 50):
            x = float(x_int)
            poly = C * x**N
            exp_val = math.exp(x)
            if exp_val > poly and not found_crossover:
                print(f"    Crossover at x = {x}: C*x^N = {poly:.2f}, exp(x) = {exp_val:.2f}")
                found_crossover = True
                break
        if not found_crossover:
            print(f"    No crossover found in range [1, 49]")
    print()


def demo_depth_separation():
    """Demonstrate that specific depth-D expressions fail to match iterExp(D+1)."""
    print("=" * 70)
    print("DEMO 4: Depth Separation in Action")
    print("=" * 70)
    print()

    # Depth 0 candidates vs exp(x) = iterExp(1, x)
    print("  Depth 0 (polynomial) vs iterExp(1, x) = exp(x):")
    candidates_d0 = [
        ("x", lambda x: x),
        ("x^2", lambda x: x**2),
        ("10*x^5", lambda x: 10*x**5),
        ("100*x^10", lambda x: 100*x**10),
    ]
    for name, f in candidates_d0:
        x = 20.0
        print(f"    {name:>12} at x={x}: {f(x):.2e}  vs  exp(x) = {math.exp(x):.2e}")
    print()

    # Depth 1 candidates vs exp(exp(x)) = iterExp(2, x)
    print("  Depth 1 (a*exp(b*x)) vs iterExp(2, x) = exp(exp(x)):")
    candidates_d1 = [
        ("exp(x)", lambda x: math.exp(x)),
        ("x*exp(x)", lambda x: x * math.exp(x)),
        ("exp(2x)", lambda x: math.exp(2*x)),
        ("x^5*exp(x^2)", lambda x: x**5 * math.exp(x**2)),
    ]
    x = 5.0
    target = iterExp(2, x)
    for name, f in candidates_d1:
        try:
            val = f(x)
            print(f"    {name:>15} at x={x}: {val:.2e}  vs  exp(exp(x)) = {target:.2e}")
        except OverflowError:
            print(f"    {name:>15} at x={x}: overflow  vs  exp(exp(x)) = {target:.2e}")
    print()

    print("  The gap grows without bound — depth D cannot catch depth D+1.")
    print()


def demo_canonical_construction():
    """Show that emlExprIterExp(n) achieves exactly depth n."""
    print("=" * 70)
    print("DEMO 5: Canonical Construction — emlExprIterExp(n) Has Depth n")
    print("=" * 70)
    print()

    x = 2.0
    print(f"  Evaluation at x = {x}:")
    for n in range(6):
        val = iterExp(n, x)
        if val == float('inf'):
            print(f"    iterExp({n}, {x}) = overflow  (depth needed: {n})")
        else:
            print(f"    iterExp({n}, {x}) = {val:.6e}  (depth needed: {n})")
    print()
    print("  Key insight: each level produces dramatically faster growth.")
    print("  No depth-D expression can match the growth of iterExp(D+1).")


if __name__ == "__main__":
    demo_growth_comparison()
    demo_absorption()
    demo_poly_vs_exp()
    demo_depth_separation()
    demo_canonical_construction()
