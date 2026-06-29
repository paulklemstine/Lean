#!/usr/bin/env python3
"""
Applications of Differential Closure in the Hardy Hierarchy

This module demonstrates real-world applications of the formally verified
differential closure principle:
  - WKB approximation analysis
  - Logarithmic derivative decomposition
  - Growth rate classification
  - Asymptotic complexity certification
"""

from __future__ import annotations
import math
from algorithms import Expr, Tag, evaluate, depth, symbolic_deriv, pretty, log_deriv, classify_hardy_level


# ═══════════════════════════════════════════════════════════════════════
# Application 1: WKB Approximation Analysis
# ═══════════════════════════════════════════════════════════════════════

def wkb_analysis():
    """Demonstrate the connection between differential closure and WKB.

    In the WKB approximation, solutions to y'' + Q(x)y = 0 are approximated by:
        y ≈ Q(x)^(-1/4) * exp(± ∫ Q(x)^(1/2) dx)

    The key structure is f(x) = a(x) * exp(b(x)), where:
    - a(x) is the slowly varying amplitude
    - b(x) is the phase

    The logarithmic derivative decomposes as:
        (log f)' = (log a)' + b'

    Our theorem certifies that this decomposition respects Hardy levels.
    """
    print("=" * 60)
    print("  APPLICATION 1: WKB APPROXIMATION STRUCTURE")
    print("=" * 60)

    x = Expr.var()

    # Example: f(x) = x * exp(x^2) (Gaussian-type)
    # In WKB terms: amplitude = x, phase = x^2
    amplitude = x
    phase = Expr.mul(x, x)
    f = Expr.mul(amplitude, Expr.exp(phase))

    print(f"\n  WKB function: f(x) = {pretty(f)}")
    print(f"  Amplitude a(x) = {pretty(amplitude)}")
    print(f"  Phase b(x) = {pretty(phase)}")

    da = symbolic_deriv(amplitude)
    db = symbolic_deriv(phase)
    df = symbolic_deriv(f)

    print(f"\n  a'(x) = {pretty(da)}")
    print(f"  b'(x) = {pretty(db)}")
    print(f"  f'(x) = {pretty(df)}")

    print(f"\n  Depth analysis:")
    print(f"    depth(a) = {depth(amplitude)}")
    print(f"    depth(b) = {depth(phase)}")
    print(f"    depth(f) = {depth(f)}")
    print(f"    depth(f') = {depth(df)}")
    print(f"    Hardy level of f' ≤ {depth(f) + 1}")

    # Verify logarithmic derivative decomposition numerically
    print(f"\n  Logarithmic derivative verification at x = 2.0:")
    x_val = 2.0
    ld_f = log_deriv(f, x_val)
    ld_a = log_deriv(amplitude, x_val)
    db_val = evaluate(db, x_val)
    print(f"    (log f)' = {ld_f:.6f}")
    print(f"    (log a)' + b' = {ld_a:.6f} + {db_val:.6f} = {ld_a + db_val:.6f}")
    print(f"    Match: {'✓' if abs(ld_f - (ld_a + db_val)) < 1e-6 else '✗'}")
    print("=" * 60)


# ═══════════════════════════════════════════════════════════════════════
# Application 2: Growth Rate Classification
# ═══════════════════════════════════════════════════════════════════════

def growth_classification():
    """Classify functions by their asymptotic growth rate using Hardy levels.

    Hardy level 0: polynomial growth (bounded by C * x^d)
    Hardy level 1: single-exponential growth (bounded by exp(poly))
    Hardy level 2: double-exponential growth (bounded by exp(exp(poly)))
    ...

    The differential closure theorem shows that differentiation is
    complexity-controlled: it cannot push a function more than one
    level up in the hierarchy.
    """
    print("=" * 60)
    print("  APPLICATION 2: GROWTH RATE CLASSIFICATION")
    print("=" * 60)

    x = Expr.var()
    one = Expr.const(1)
    two = Expr.const(2)

    functions = [
        ("Polynomial: x + 2", Expr.add(x, two)),
        ("Polynomial: x * x", Expr.mul(x, x)),
        ("Single exp: exp(x)", Expr.exp(x)),
        ("Product: x * exp(x)", Expr.mul(x, Expr.exp(x))),
        ("Double exp: exp(exp(x))", Expr.exp(Expr.exp(x))),
        ("Mixed: (x*x+1)*exp(exp(x))",
         Expr.mul(Expr.add(Expr.mul(x, x), one), Expr.exp(Expr.exp(x)))),
        ("Triple exp: exp(exp(exp(x)))",
         Expr.exp(Expr.exp(Expr.exp(x)))),
    ]

    level_names = {
        0: "polynomial",
        1: "single-exponential",
        2: "double-exponential",
        3: "triple-exponential",
    }

    print(f"\n  {'Function':<35} {'Level':>6} {'Deriv Level':>12} {'Category':<25}")
    print("  " + "-" * 78)

    for name, e in functions:
        info = classify_hardy_level(e)
        level = info['depth']
        dlevel = info['deriv_depth']
        cat = level_names.get(level, f"level-{level}")
        print(f"  {name:<35} {level:>6} {dlevel:>12} {cat:<25}")

    print(f"\n  Key insight: derivative never exceeds level + 1")
    print("=" * 60)


# ═══════════════════════════════════════════════════════════════════════
# Application 3: Asymptotic Comparison
# ═══════════════════════════════════════════════════════════════════════

def asymptotic_comparison():
    """Compare growth rates of functions and their derivatives.

    Demonstrates that the Hardy hierarchy provides a natural scale
    for comparing asymptotic behavior.
    """
    print("=" * 60)
    print("  APPLICATION 3: ASYMPTOTIC COMPARISON")
    print("=" * 60)

    x = Expr.var()

    functions = [
        Expr.mul(x, x),                          # x^2
        Expr.exp(x),                              # exp(x)
        Expr.mul(x, Expr.exp(x)),                 # x*exp(x)
        Expr.exp(Expr.mul(x, x)),                 # exp(x^2)
        Expr.exp(Expr.exp(x)),                    # exp(exp(x))
    ]

    test_points = [1.0, 2.0, 5.0, 10.0]

    print(f"\n  {'Expression':<25}", end="")
    for xv in test_points:
        print(f"  {'x='+str(xv):>12}", end="")
    print(f"  {'Depth':>6}")
    print("  " + "-" * 75)

    for e in functions:
        name = pretty(e)
        print(f"  {name:<25}", end="")
        for xv in test_points:
            try:
                val = evaluate(e, xv)
                if val == float('inf'):
                    print(f"  {'∞':>12}", end="")
                elif abs(val) > 1e15:
                    print(f"  {val:>12.2e}", end="")
                else:
                    print(f"  {val:>12.4f}", end="")
            except OverflowError:
                print(f"  {'overflow':>12}", end="")
        print(f"  {depth(e):>6}")

    print("\n  Derivatives:")
    print(f"\n  {'Expression':<25}", end="")
    for xv in test_points:
        print(f"  {'x='+str(xv):>12}", end="")
    print(f"  {'Depth':>6}")
    print("  " + "-" * 75)

    for e in functions:
        de = symbolic_deriv(e)
        name = pretty(e) + "'"
        print(f"  {name:<25}", end="")
        for xv in test_points:
            try:
                val = evaluate(de, xv)
                if val == float('inf'):
                    print(f"  {'∞':>12}", end="")
                elif abs(val) > 1e15:
                    print(f"  {val:>12.2e}", end="")
                else:
                    print(f"  {val:>12.4f}", end="")
            except OverflowError:
                print(f"  {'overflow':>12}", end="")
        print(f"  {depth(de):>6}")

    print("=" * 60)


# ═══════════════════════════════════════════════════════════════════════
# Application 4: Logarithmic Derivative for Physics
# ═══════════════════════════════════════════════════════════════════════

def physics_log_deriv():
    """Demonstrate logarithmic derivatives in a physics context.

    In physics, logarithmic derivatives appear as:
    - Beta functions in renormalization group flow
    - Phase velocities in wave mechanics
    - Decay rates normalized by population
    """
    print("=" * 60)
    print("  APPLICATION 4: LOGARITHMIC DERIVATIVES IN PHYSICS")
    print("=" * 60)

    x = Expr.var()

    # Exponential decay: f(x) = exp(-x) → logDeriv = -1 (constant rate)
    # We approximate with exp((-1)*x)
    neg_x = Expr.mul(Expr.const(-1), x)
    exp_decay = Expr.exp(neg_x)

    # Gaussian: f(x) = exp(-x^2) → logDeriv = -2x (linear rate)
    neg_x2 = Expr.mul(Expr.const(-1), Expr.mul(x, x))
    gaussian = Expr.exp(neg_x2)

    # Double exponential growth: f(x) = exp(exp(x))
    double_exp = Expr.exp(Expr.exp(x))

    examples = [
        ("Exponential decay: exp(-x)", exp_decay,
         "Constant log-derivative → uniform decay rate"),
        ("Gaussian: exp(-x²)", gaussian,
         "Linear log-derivative → accelerating decay"),
        ("Double exp: exp(exp(x))", double_exp,
         "Exponential log-derivative → super-exponential growth"),
    ]

    test_x = [0.5, 1.0, 2.0, 3.0]

    for name, e, interpretation in examples:
        print(f"\n  {name}")
        print(f"  Interpretation: {interpretation}")
        print(f"  Hardy depth: {depth(e)}")
        print(f"  Derivative depth: {depth(symbolic_deriv(e))}")
        print(f"  Values of log-derivative f'/f:")
        for xv in test_x:
            ld = log_deriv(e, xv)
            if math.isnan(ld) or math.isinf(ld):
                print(f"    x = {xv}: undefined")
            else:
                print(f"    x = {xv}: {ld:.6f}")

    print("\n" + "=" * 60)


# ═══════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    wkb_analysis()
    print()
    growth_classification()
    print()
    asymptotic_comparison()
    print()
    physics_log_deriv()


#!/usr/bin/env python3
"""
Differential Closure and Transseries Fragments — Interactive Demo

Demonstrates symbolic differentiation of EML expressions with Hardy level tracking.
Generates expressions up to a given depth, differentiates them, and checks the
depth/Hardy level bounds predicted by the formal theorems.

Usage:
    python demo.py                    # Run with defaults
    python demo.py --max-depth 4      # Generate expressions up to depth 4
    python demo.py --examples         # Show representative examples only
    python demo.py --search           # Search for counterexamples to +1 bound
"""

import argparse
import math
from dataclasses import dataclass
from typing import Callable
from enum import Enum, auto


# ─────────────────────────────────────────────────────────────────────
# PosEMLExpr — mirrors the Lean inductive type
# ─────────────────────────────────────────────────────────────────────

class ExprTag(Enum):
    CONST = auto()
    VAR = auto()
    ADD = auto()
    MUL = auto()
    EXP = auto()


@dataclass(frozen=True)
class PosEMLExpr:
    tag: ExprTag
    value: float = 0.0
    left: 'PosEMLExpr | None' = None
    right: 'PosEMLExpr | None' = None

    @staticmethod
    def const(c: float) -> 'PosEMLExpr':
        return PosEMLExpr(ExprTag.CONST, value=c)

    @staticmethod
    def var() -> 'PosEMLExpr':
        return PosEMLExpr(ExprTag.VAR)

    @staticmethod
    def add(a: 'PosEMLExpr', b: 'PosEMLExpr') -> 'PosEMLExpr':
        return PosEMLExpr(ExprTag.ADD, left=a, right=b)

    @staticmethod
    def mul(a: 'PosEMLExpr', b: 'PosEMLExpr') -> 'PosEMLExpr':
        return PosEMLExpr(ExprTag.MUL, left=a, right=b)

    @staticmethod
    def exp(a: 'PosEMLExpr') -> 'PosEMLExpr':
        return PosEMLExpr(ExprTag.EXP, left=a)


# ─────────────────────────────────────────────────────────────────────
# Evaluation
# ─────────────────────────────────────────────────────────────────────

def evaluate(e: PosEMLExpr, x: float) -> float:
    """Evaluate a PosEMLExpr at a real number x."""
    if e.tag == ExprTag.CONST:
        return e.value
    elif e.tag == ExprTag.VAR:
        return x
    elif e.tag == ExprTag.ADD:
        return evaluate(e.left, x) + evaluate(e.right, x)
    elif e.tag == ExprTag.MUL:
        return evaluate(e.left, x) * evaluate(e.right, x)
    elif e.tag == ExprTag.EXP:
        v = evaluate(e.left, x)
        try:
            return math.exp(v)
        except OverflowError:
            return float('inf')
    raise ValueError(f"Unknown tag: {e.tag}")


# ─────────────────────────────────────────────────────────────────────
# Depth
# ─────────────────────────────────────────────────────────────────────

def depth(e: PosEMLExpr) -> int:
    """Compute the depth (Hardy level) of a PosEMLExpr."""
    if e.tag == ExprTag.CONST:
        return 0
    elif e.tag == ExprTag.VAR:
        return 0
    elif e.tag == ExprTag.ADD:
        return max(depth(e.left), depth(e.right))
    elif e.tag == ExprTag.MUL:
        return max(depth(e.left), depth(e.right))
    elif e.tag == ExprTag.EXP:
        return depth(e.left) + 1
    raise ValueError(f"Unknown tag: {e.tag}")


# ─────────────────────────────────────────────────────────────────────
# Symbolic Differentiation (verified algorithm)
# ─────────────────────────────────────────────────────────────────────

def symbolic_deriv(e: PosEMLExpr) -> PosEMLExpr:
    """Symbolically differentiate a PosEMLExpr.

    This implements the exact same algorithm as the Lean definition
    PosEMLExpr.deriv, which has been formally verified to:
    1. Match the analytic derivative (eval_deriv_eq)
    2. Raise depth by at most 1 (depth_deriv_le)
    """
    if e.tag == ExprTag.CONST:
        return PosEMLExpr.const(0)
    elif e.tag == ExprTag.VAR:
        return PosEMLExpr.const(1)
    elif e.tag == ExprTag.ADD:
        return PosEMLExpr.add(symbolic_deriv(e.left), symbolic_deriv(e.right))
    elif e.tag == ExprTag.MUL:
        return PosEMLExpr.add(
            PosEMLExpr.mul(symbolic_deriv(e.left), e.right),
            PosEMLExpr.mul(e.left, symbolic_deriv(e.right))
        )
    elif e.tag == ExprTag.EXP:
        return PosEMLExpr.mul(symbolic_deriv(e.left), PosEMLExpr.exp(e.left))
    raise ValueError(f"Unknown tag: {e.tag}")


# ─────────────────────────────────────────────────────────────────────
# Pretty Printing
# ─────────────────────────────────────────────────────────────────────

def pretty(e: PosEMLExpr) -> str:
    """Pretty-print a PosEMLExpr."""
    if e.tag == ExprTag.CONST:
        v = e.value
        if v == int(v):
            return str(int(v))
        return str(v)
    elif e.tag == ExprTag.VAR:
        return "x"
    elif e.tag == ExprTag.ADD:
        return f"({pretty(e.left)} + {pretty(e.right)})"
    elif e.tag == ExprTag.MUL:
        return f"({pretty(e.left)} * {pretty(e.right)})"
    elif e.tag == ExprTag.EXP:
        return f"exp({pretty(e.left)})"
    return "?"


# ─────────────────────────────────────────────────────────────────────
# Expression Generation
# ─────────────────────────────────────────────────────────────────────

def generate_exprs(max_depth: int) -> list[PosEMLExpr]:
    """Generate representative PosEMLExpr up to a given depth."""
    atoms = [PosEMLExpr.const(1), PosEMLExpr.const(2), PosEMLExpr.var()]
    results = list(atoms)

    if max_depth >= 1:
        # Depth 1: exp of atoms
        for a in atoms:
            results.append(PosEMLExpr.exp(a))

        # Combinations at depth 0
        for a in atoms:
            for b in atoms:
                results.append(PosEMLExpr.add(a, b))
                results.append(PosEMLExpr.mul(a, b))

    if max_depth >= 2:
        depth1_exps = [PosEMLExpr.exp(a) for a in atoms]
        for e in depth1_exps:
            results.append(PosEMLExpr.exp(e.left))  # already have these
        # exp(exp(x)), exp(exp(1)), etc.
        for a in atoms:
            results.append(PosEMLExpr.exp(PosEMLExpr.exp(a)))
        # mul/add with exp
        for a in atoms:
            for b in depth1_exps:
                results.append(PosEMLExpr.mul(a, b))
                results.append(PosEMLExpr.add(a, b))

    if max_depth >= 3:
        for a in atoms:
            results.append(PosEMLExpr.exp(PosEMLExpr.exp(PosEMLExpr.exp(a))))
        # exp(x + exp(x))
        results.append(PosEMLExpr.exp(
            PosEMLExpr.add(PosEMLExpr.var(), PosEMLExpr.exp(PosEMLExpr.var()))
        ))
        # (x^2 + 1) * exp(exp(x))
        results.append(PosEMLExpr.mul(
            PosEMLExpr.add(PosEMLExpr.mul(PosEMLExpr.var(), PosEMLExpr.var()),
                           PosEMLExpr.const(1)),
            PosEMLExpr.exp(PosEMLExpr.exp(PosEMLExpr.var()))
        ))

    return results


# ─────────────────────────────────────────────────────────────────────
# Representative Examples
# ─────────────────────────────────────────────────────────────────────

def representative_examples() -> list[tuple[str, PosEMLExpr]]:
    """Return a list of representative examples with names."""
    x = PosEMLExpr.var()
    one = PosEMLExpr.const(1)
    two = PosEMLExpr.const(2)

    return [
        ("exp(x)", PosEMLExpr.exp(x)),
        ("exp(exp(x))", PosEMLExpr.exp(PosEMLExpr.exp(x))),
        ("x * exp(x)", PosEMLExpr.mul(x, PosEMLExpr.exp(x))),
        ("exp(x + exp(x))", PosEMLExpr.exp(PosEMLExpr.add(x, PosEMLExpr.exp(x)))),
        ("(x*x + 1) * exp(exp(x))",
         PosEMLExpr.mul(
             PosEMLExpr.add(PosEMLExpr.mul(x, x), one),
             PosEMLExpr.exp(PosEMLExpr.exp(x))
         )),
        ("exp(exp(exp(x)))",
         PosEMLExpr.exp(PosEMLExpr.exp(PosEMLExpr.exp(x)))),
        ("x * x", PosEMLExpr.mul(x, x)),
        ("x + 2", PosEMLExpr.add(x, two)),
    ]


# ─────────────────────────────────────────────────────────────────────
# Main Demo Functions
# ─────────────────────────────────────────────────────────────────────

def demo_examples():
    """Show representative examples with derivatives and depth analysis."""
    print("=" * 72)
    print("  DIFFERENTIAL CLOSURE — REPRESENTATIVE EXAMPLES")
    print("  Each entry shows: expression, its derivative, depth analysis")
    print("=" * 72)

    for name, e in representative_examples():
        de = symbolic_deriv(e)
        d_orig = depth(e)
        d_deriv = depth(de)
        gap = d_deriv - d_orig

        print(f"\n  Expression:  {name}")
        print(f"  Derivative:  {pretty(de)}")
        print(f"  Depth(e):    {d_orig}")
        print(f"  Depth(e'):   {d_deriv}")
        print(f"  Gap:         {gap:+d}  (theorem guarantees ≤ +1)")

        # Evaluate at a test point
        try:
            val = evaluate(e, 2.0)
            dval = evaluate(de, 2.0)
            if val != float('inf') and dval != float('inf'):
                print(f"  e(2) = {val:.6g},  e'(2) = {dval:.6g}")
        except (OverflowError, ValueError):
            print(f"  (overflow at x=2)")

    print("\n" + "=" * 72)


def demo_search(max_depth: int):
    """Search for counterexamples to the +1 depth bound."""
    print("=" * 72)
    print(f"  SEARCHING FOR COUNTEREXAMPLES TO DEPTH BOUND (max_depth={max_depth})")
    print("  Theorem: depth(deriv(e)) ≤ depth(e) + 1")
    print("=" * 72)

    exprs = generate_exprs(max_depth)
    counterexamples = 0
    max_gap = -999
    total = len(exprs)

    for e in exprs:
        de = symbolic_deriv(e)
        d_orig = depth(e)
        d_deriv = depth(de)
        gap = d_deriv - d_orig

        if gap > max_gap:
            max_gap = gap

        if gap > 1:
            counterexamples += 1
            print(f"  COUNTEREXAMPLE: {pretty(e)}")
            print(f"    depth(e) = {d_orig}, depth(e') = {d_deriv}, gap = {gap}")

    print(f"\n  Tested {total} expressions up to depth {max_depth}")
    print(f"  Maximum gap observed: {max_gap}")
    print(f"  Counterexamples found: {counterexamples}")
    if counterexamples == 0:
        print("  ✓ Bound depth(e') ≤ depth(e) + 1 holds for all tested expressions")
    print("=" * 72)


def demo_hardy_levels(max_depth: int):
    """Display Hardy levels and derivative depth analysis."""
    print("=" * 72)
    print(f"  HARDY LEVEL ANALYSIS (max_depth={max_depth})")
    print("=" * 72)
    print(f"  {'Expression':<40} {'Depth':>6} {'D.Depth':>8} {'Gap':>5} {'Hardy ≤':>8}")
    print("  " + "-" * 67)

    exprs = generate_exprs(max_depth)
    seen = set()

    for e in exprs:
        s = pretty(e)
        if s in seen:
            continue
        seen.add(s)

        de = symbolic_deriv(e)
        d_orig = depth(e)
        d_deriv = depth(de)
        gap = d_deriv - d_orig
        hardy_bound = d_orig + 1

        print(f"  {s:<40} {d_orig:>6} {d_deriv:>8} {gap:>+5} {hardy_bound:>8}")

    print("=" * 72)


def main():
    parser = argparse.ArgumentParser(
        description="Differential Closure & Transseries Fragments Demo"
    )
    parser.add_argument("--max-depth", type=int, default=3,
                        help="Maximum depth for expression generation (default: 3)")
    parser.add_argument("--examples", action="store_true",
                        help="Show representative examples only")
    parser.add_argument("--search", action="store_true",
                        help="Search for counterexamples to +1 bound")
    parser.add_argument("--levels", action="store_true",
                        help="Display Hardy level analysis table")
    args = parser.parse_args()

    if args.examples:
        demo_examples()
    elif args.search:
        demo_search(args.max_depth)
    elif args.levels:
        demo_hardy_levels(args.max_depth)
    else:
        # Run all demos
        demo_examples()
        print()
        demo_search(args.max_depth)
        print()
        demo_hardy_levels(args.max_depth)


if __name__ == "__main__":
    main()
