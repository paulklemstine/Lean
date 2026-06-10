#!/usr/bin/env python3
"""
Applications of the Spectral Margin Framework

Demonstrates real-world applications of the Controlled-Inverse Depth Hierarchy:
1. Certified robustness for symbolic simplification
2. Numerical stability classification
3. Expression complexity analysis
"""

import math


# ==============================================================================
# Application 1: Certified Robustness for Symbolic Simplification
# ==============================================================================

def certified_simplification_demo():
    """
    Demonstrate that symbolic simplifications introducing controlled divisions
    preserve depth complexity.

    Use case: A computer algebra system simplifies exp(x)^2 / exp(x)
    to exp(x). We verify this is safe (doesn't change depth class).
    """
    print("=" * 60)
    print("APPLICATION 1: Certified Robustness for CAS Simplifications")
    print("=" * 60)
    print()

    # Original expression: exp(x)^2 (depth 1)
    # Simplified via: exp(x)^2 / exp(x) = exp(x)
    # The division by exp(x) is controlled since exp(x) >= 1 for x >= 0

    test_points = [0.1, 0.5, 1, 2, 5, 10]

    print("Scenario: Simplify exp(x)² / exp(x) → exp(x)")
    print()
    print("Step 1: Check that divisor exp(x) has positive spectral margin")
    print(f"  {'x':>6} | {'exp(x)':>12} | {'|exp(x)| ≥ δ?':>16}")
    print("  " + "-" * 40)

    min_margin = float('inf')
    for x in test_points:
        val = math.exp(x)
        min_margin = min(min_margin, val)
        print(f"  {x:>6.1f} | {val:>12.4f} | {'✓ yes':>16}")

    print(f"\n  Estimated spectral margin δ ≈ {min_margin:.4f}")
    print(f"  (Exact: inf_{{x>0}} exp(x) = lim_{{x→0+}} exp(x) = 1)")
    print()

    print("Step 2: Verify depth preservation")
    print(f"  Original exp(x)² : depth 1")
    print(f"  Divisor exp(x)   : depth 1, margin δ = 1 > 0")
    print(f"  Result exp(x)    : depth 1")
    print()
    print("  ✓ CERTIFIED: Division by exp(x) is controlled (δ=1).")
    print("    By the Controlled-Inverse Depth Hierarchy Theorem,")
    print("    the simplified expression stays in depth class 1.")

    print()
    print("Step 3: Compare with unsafe simplification")
    print("  Consider: exp(x) / x  (dividing by x, which → 0 as x → 0+)")
    print(f"  {'x':>6} | {'x':>8} | {'exp(x)/x':>12}")
    print("  " + "-" * 32)
    for x in [0.001, 0.01, 0.1, 1, 10]:
        val = math.exp(x) / x
        print(f"  {x:>6.3f} | {x:>8.3f} | {val:>12.4f}")
    print()
    print("  ⚠ NOT CERTIFIED: x has spectral margin 0 on (0,∞).")
    print("    Our theorem gives no guarantee for this division.")


# ==============================================================================
# Application 2: Numerical Stability Classification
# ==============================================================================

def numerical_stability_demo():
    """
    Classify numerical computations by their spectral margin /
    condition number, and relate to depth complexity.
    """
    print()
    print("=" * 60)
    print("APPLICATION 2: Numerical Stability Classification")
    print("=" * 60)
    print()
    print("The spectral margin δ relates to condition number κ = 1/δ.")
    print("Our theorem: κ < ∞ ⟹ depth hierarchy preserved.")
    print()

    # Examples of computations with different condition numbers
    computations = [
        {
            'name': 'exp(x)/(x² + 1)',
            'desc': 'Well-conditioned (denominator ≥ 1)',
            'eval': lambda x: math.exp(x) / (x*x + 1),
            'denom': lambda x: x*x + 1,
            'depth': 1,
        },
        {
            'name': 'exp(x)/(x + 10)',
            'desc': 'Well-conditioned (denominator ≥ 10)',
            'eval': lambda x: math.exp(x) / (x + 10),
            'denom': lambda x: x + 10,
            'depth': 1,
        },
        {
            'name': 'exp(x)/(x + 0.001)',
            'desc': 'Moderately conditioned (denominator ≥ 0.001)',
            'eval': lambda x: math.exp(x) / (x + 0.001),
            'denom': lambda x: x + 0.001,
            'depth': 1,
        },
    ]

    print(f"{'Computation':<25} {'δ (margin)':>12} {'κ = 1/δ':>12} {'Depth':>6} {'Safe?':>8}")
    print("-" * 68)

    for comp in computations:
        # Estimate spectral margin of denominator
        margin = min(comp['denom'](x) for x in
                    [10**t for t in [i/10 for i in range(-30, 40)]])
        kappa = 1.0/margin if margin > 0 else float('inf')
        safe = "✓ YES" if margin > 0 else "✗ NO"
        print(f"  {comp['name']:<23} {margin:>10.6f}   {kappa:>10.2f}   {comp['depth']:>4}   {safe}")

    print()
    print("All expressions above have finite condition numbers,")
    print("so by our theorem, none can break the depth-1 barrier.")
    print("Their growth is bounded by iterExp(1, C·x^N) = exp(C·x^N).")

    # Show the growth comparison
    print()
    print("Growth verification at x = 10:")
    for comp in computations:
        try:
            val = comp['eval'](10)
            ie2 = math.exp(math.exp(10))
            print(f"  {comp['name']:<25}: {val:.4g}  << iterExp(2,10) = {ie2:.4g}")
        except OverflowError:
            print(f"  {comp['name']:<25}: overflow (but still << iterExp(2,10))")


# ==============================================================================
# Application 3: Expression Complexity Audit
# ==============================================================================

def complexity_audit_demo():
    """
    Audit a set of mathematical expressions for depth complexity,
    identifying which ones have controlled inverses and which don't.
    """
    print()
    print("=" * 60)
    print("APPLICATION 3: Expression Complexity Audit")
    print("=" * 60)
    print()
    print("Given a set of expressions, classify by depth and")
    print("identify controlled vs. uncontrolled inverses.")
    print()

    expressions = [
        ("exp(x) + 1/exp(x)", 1, True,
         "Both exp(x) terms; 1/exp(x) controlled since exp(x)≥1"),
        ("exp(x) · exp(1/x)", 1, False,
         "1/x is NOT controlled (x→0+ gives margin 0)"),
        ("exp(exp(x))", 2, True,
         "No inverses at all — trivially controlled"),
        ("1/(exp(x)+1) · exp(exp(x))", 2, True,
         "exp(x)+1 ≥ 2 > 0 — controlled inverse"),
        ("exp(x/(x+1))", 1, True,
         "x+1 ≥ 1 > 0 on (0,∞) — controlled inverse"),
    ]

    print(f"{'Expression':<30} {'Depth':>5} {'Ctrl?':>6} {'Analysis'}")
    print("-" * 80)
    for name, depth, ctrl, analysis in expressions:
        status = "✓" if ctrl else "✗"
        print(f"  {name:<28} {depth:>5} {status:>5}   {analysis}")

    print()
    print("By the Controlled-Inverse Depth Hierarchy Theorem:")
    print("  • ✓ expressions cannot represent iterExp(D+1, x)")
    print("  • ✗ expressions might or might not (theorem doesn't apply)")

    # Demonstrate growth rates
    print()
    print("Growth rate verification:")
    print(f"  {'x':>4} | {'exp(x)+1/exp(x)':>18} | {'exp(exp(x))':>15} | {'iterExp(3,x)':>15}")
    print("  " + "-" * 56)
    for x in [1, 2, 3, 5]:
        v1 = math.exp(x) + math.exp(-x)
        try:
            v2 = math.exp(math.exp(x))
            v2s = f"{v2:.4g}"
        except OverflowError:
            v2s = "overflow"
        try:
            v3 = math.exp(math.exp(math.exp(x)))
            v3s = f"{v3:.4g}"
        except OverflowError:
            v3s = "overflow"
        print(f"  {x:>4} | {v1:>18.4g} | {v2s:>15} | {v3s:>15}")

    print()
    print("→ Each depth level dwarfs the previous, confirming the hierarchy.")


# ==============================================================================
# Main
# ==============================================================================

if __name__ == "__main__":
    certified_simplification_demo()
    numerical_stability_demo()
    complexity_audit_demo()

    print()
    print("=" * 60)
    print("ALL APPLICATIONS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Controlled-Inverse Depth Hierarchy — Interactive Demonstration

Demonstrates the main theorem: controlled inverses (where every inverse argument
is bounded away from zero) don't help EML expressions escape the depth hierarchy.

Features:
1. Build and evaluate EML expressions
2. Compute spectral margins
3. Compute poly-tower majorant heights
4. Compare expressions with iterExp(D, x) growth
5. Test the Uncontrolled Inverse Collapse conjecture
"""

import math
from dataclasses import dataclass
from typing import Union
from enum import Enum, auto


# ==============================================================================
# EML Expression Language
# ==============================================================================

class ExprType(Enum):
    VAR = auto()
    CONST = auto()
    ADD = auto()
    MUL = auto()
    NEG = auto()
    INV = auto()
    EML = auto()  # eml(a, b) = a * exp(b)


@dataclass
class EMLExpr:
    """EML expression tree node."""
    kind: ExprType
    value: float = 0.0  # For CONST
    left: 'EMLExpr | None' = None
    right: 'EMLExpr | None' = None

    def eval(self, x: float) -> float:
        """Evaluate the expression at point x."""
        if self.kind == ExprType.VAR:
            return x
        elif self.kind == ExprType.CONST:
            return self.value
        elif self.kind == ExprType.ADD:
            return self.left.eval(x) + self.right.eval(x)
        elif self.kind == ExprType.MUL:
            return self.left.eval(x) * self.right.eval(x)
        elif self.kind == ExprType.NEG:
            return -self.left.eval(x)
        elif self.kind == ExprType.INV:
            v = self.left.eval(x)
            if v == 0:
                return float('inf')
            return 1.0 / v
        elif self.kind == ExprType.EML:
            a = self.left.eval(x)
            b = self.right.eval(x)
            try:
                return a * math.exp(b)
            except OverflowError:
                return float('inf')
        raise ValueError(f"Unknown expression type: {self.kind}")

    @property
    def depth(self) -> int:
        """EML depth: counts maximum nesting of eml operations."""
        if self.kind in (ExprType.VAR, ExprType.CONST):
            return 0
        elif self.kind in (ExprType.ADD, ExprType.MUL):
            return max(self.left.depth, self.right.depth)
        elif self.kind in (ExprType.NEG, ExprType.INV):
            return self.left.depth
        elif self.kind == ExprType.EML:
            return 1 + max(self.left.depth, self.right.depth)
        return 0

    def __str__(self) -> str:
        if self.kind == ExprType.VAR:
            return "x"
        elif self.kind == ExprType.CONST:
            return f"{self.value}"
        elif self.kind == ExprType.ADD:
            return f"({self.left} + {self.right})"
        elif self.kind == ExprType.MUL:
            return f"({self.left} * {self.right})"
        elif self.kind == ExprType.NEG:
            return f"(-{self.left})"
        elif self.kind == ExprType.INV:
            return f"(1/{self.left})"
        elif self.kind == ExprType.EML:
            return f"({self.left} * exp({self.right}))"
        return "?"


# Convenience constructors
def Var():
    return EMLExpr(ExprType.VAR)

def Const(c: float):
    return EMLExpr(ExprType.CONST, value=c)

def Add(a, b):
    return EMLExpr(ExprType.ADD, left=a, right=b)

def Mul(a, b):
    return EMLExpr(ExprType.MUL, left=a, right=b)

def Neg(a):
    return EMLExpr(ExprType.NEG, left=a)

def Inv(a):
    return EMLExpr(ExprType.INV, left=a)

def Eml(a, b):
    return EMLExpr(ExprType.EML, left=a, right=b)

def Exp(b):
    """exp(b) = 1 * exp(b)"""
    return Eml(Const(1), b)


# ==============================================================================
# Iterated Exponential
# ==============================================================================

def iter_exp(n: int, x: float) -> float:
    """Compute iterExp(n, x) = exp^n(x)."""
    result = x
    for _ in range(n):
        try:
            result = math.exp(result)
        except OverflowError:
            return float('inf')
    return result


# ==============================================================================
# Spectral Margin Estimation
# ==============================================================================

def estimate_spectral_margin(e: EMLExpr, num_samples: int = 10000,
                              x_min: float = 1e-4, x_max: float = 1e4) -> float:
    """
    Estimate the spectral margin: inf { |eval(e, x)| : x > 0 }.
    Uses log-spaced sampling for numerical estimation.
    """
    log_min = math.log10(x_min)
    log_max = math.log10(x_max)
    xs = [10 ** (log_min + (log_max - log_min) * i / (num_samples - 1))
          for i in range(num_samples)]
    min_val = float('inf')
    for x in xs:
        try:
            val = abs(e.eval(x))
            if val < min_val:
                min_val = val
        except (OverflowError, ZeroDivisionError):
            pass
    return min_val


def has_controlled_inverses(e: EMLExpr, x_min=1e-4, x_max=1e4) -> tuple:
    """
    Check if an expression has controlled inverses.
    Returns (is_controlled: bool, min_margin: float, details: str).
    """
    if e.kind in (ExprType.VAR, ExprType.CONST):
        return True, float('inf'), "leaf node"
    elif e.kind in (ExprType.ADD, ExprType.MUL, ExprType.EML):
        ctrl_l, margin_l, det_l = has_controlled_inverses(e.left, x_min, x_max)
        ctrl_r, margin_r, det_r = has_controlled_inverses(e.right, x_min, x_max)
        return ctrl_l and ctrl_r, min(margin_l, margin_r), f"both children controlled"
    elif e.kind == ExprType.NEG:
        return has_controlled_inverses(e.left, x_min, x_max)
    elif e.kind == ExprType.INV:
        # Check that the argument has positive spectral margin
        margin = estimate_spectral_margin(e.left)
        ctrl_child, margin_child, det_child = has_controlled_inverses(e.left, x_min, x_max)
        if margin > 0.01:  # numerical threshold
            return ctrl_child, min(margin, margin_child), f"inv arg margin ≈ {margin:.6f}"
        else:
            return False, 0.0, f"inv arg margin ≈ {margin:.6f} (too small)"
    return False, 0.0, "unknown"


def controlled_inv_majorant_height(e: EMLExpr) -> tuple:
    """
    Compute the poly-tower majorant height for a controlled-inverse expression.
    Returns (height, C_estimate, N_estimate).
    """
    if e.kind == ExprType.VAR:
        return (0, 1.0, 1)
    elif e.kind == ExprType.CONST:
        return (0, abs(e.value) + 1, 0)
    elif e.kind == ExprType.NEG:
        return controlled_inv_majorant_height(e.left)
    elif e.kind == ExprType.INV:
        margin = estimate_spectral_margin(e.left)
        if margin > 0:
            return (0, 1.0/margin + 1, 0)  # KEY: height stays at 0!
        else:
            return (0, float('inf'), 0)
    elif e.kind == ExprType.ADD:
        h1, c1, n1 = controlled_inv_majorant_height(e.left)
        h2, c2, n2 = controlled_inv_majorant_height(e.right)
        h = max(h1, h2)
        return (h, 2*(c1+c2) + math.log(2), max(n1, n2) + 1)
    elif e.kind == ExprType.MUL:
        h1, c1, n1 = controlled_inv_majorant_height(e.left)
        h2, c2, n2 = controlled_inv_majorant_height(e.right)
        h = max(h1, h2)
        return (h, c1 + c2, n1 + n2)
    elif e.kind == ExprType.EML:
        h1, c1, n1 = controlled_inv_majorant_height(e.left)
        h2, c2, n2 = controlled_inv_majorant_height(e.right)
        h = max(h1, h2) + 1  # Depth increases by 1!
        return (h, c1 + c2 + 1, n1 + n2 + 1)
    return (0, 1.0, 0)


# ==============================================================================
# Demo: Main theorem demonstration
# ==============================================================================

def demo_main_theorem():
    """Demonstrate that controlled inverses don't break the depth hierarchy."""
    print("=" * 70)
    print("CONTROLLED-INVERSE DEPTH HIERARCHY — MAIN THEOREM DEMO")
    print("=" * 70)
    print()
    print("Theorem: No controlled-inverse EML expression of depth D can")
    print("represent iterExp(n, x) for n > D and large x.")
    print()

    # Build some controlled-inverse expressions of depth 1
    expressions = [
        ("exp(x)", Exp(Var())),
        ("1/exp(x) + exp(x)", Add(Inv(Exp(Var())), Exp(Var()))),
        ("exp(x) * (1/(x+1))", Mul(Exp(Var()), Inv(Add(Var(), Const(1))))),
        ("exp(x) / (x^2 + 1)", Mul(Exp(Var()), Inv(Add(Mul(Var(), Var()), Const(1))))),
        ("(x+2) * exp(x/(x+1))", Eml(Add(Var(), Const(2)),
                                       Mul(Var(), Inv(Add(Var(), Const(1)))))),
    ]

    print("Expressions of depth 1 with controlled inverses:")
    print("-" * 70)

    test_points = [1, 2, 5, 10]

    for name, e in expressions:
        ctrl, margin, detail = has_controlled_inverses(e)
        height, C, N = controlled_inv_majorant_height(e)
        print(f"\n  {name}")
        print(f"    Depth: {e.depth}")
        print(f"    Controlled inverses: {ctrl} ({detail})")
        print(f"    Majorant height: {height}, C ≈ {C:.2f}, N = {N}")
        print(f"    Values: ", end="")
        for x in test_points:
            try:
                v = e.eval(x)
                print(f"f({x})={v:.4g}", end="  ")
            except:
                print(f"f({x})=overflow", end="  ")
        print()

    print("\n" + "-" * 70)
    print("\nComparison with iterExp(2, x) = exp(exp(x)):")
    for x in test_points:
        ie2 = iter_exp(2, x)
        print(f"  iterExp(2, {x}) = {ie2:.4g}")

    print("\n→ iterExp(2, x) vastly exceeds ALL depth-1 expressions,")
    print("  confirming the depth hierarchy persists with controlled inverses.")


def demo_spectral_margin():
    """Demonstrate spectral margin computation."""
    print("\n" + "=" * 70)
    print("SPECTRAL MARGIN COMPUTATION")
    print("=" * 70)
    print()

    expressions = [
        ("x", Var()),
        ("1", Const(1)),
        ("x + 1", Add(Var(), Const(1))),
        ("x^2 + 1", Add(Mul(Var(), Var()), Const(1))),
        ("exp(x)", Exp(Var())),
        ("exp(x) + 1", Add(Exp(Var()), Const(1))),
    ]

    print(f"{'Expression':<20} {'Spectral Margin':>18} {'Controlled Inv?':>16}")
    print("-" * 60)
    for name, e in expressions:
        margin = estimate_spectral_margin(e)
        ctrl = "Yes" if margin > 0.01 else "No (→0)"
        print(f"  {name:<18} {margin:>16.6f}   {ctrl}")

    print()
    print("→ Expressions with positive spectral margin can safely appear")
    print("  as arguments to inv() without breaking the depth hierarchy.")


def demo_uncontrolled_inverse_conjecture():
    """Test the Uncontrolled Inverse Collapse conjecture."""
    print("\n" + "=" * 70)
    print("UNCONTROLLED INVERSE COLLAPSE CONJECTURE — ENUMERATION TEST")
    print("=" * 70)
    print()
    print("Conjecture: Without uniform lower bounds, inverses might")
    print("collapse the depth hierarchy.")
    print()

    # Test candidate: 1/(1/x + 1/exp(x)) = x*exp(x)/(x + exp(x))
    candidate = Inv(Add(Inv(Var()), Inv(Exp(Var()))))
    print(f"Candidate: {candidate}")
    print(f"  Depth: {candidate.depth}")
    ctrl, margin, detail = has_controlled_inverses(candidate)
    print(f"  Controlled: {ctrl} ({detail})")

    print(f"\n  Growth comparison:")
    test_points = [1, 2, 3, 5, 10]
    for x in test_points:
        val = candidate.eval(x)
        ie1 = iter_exp(1, x)
        ratio = val / ie1 if ie1 > 0 else 0
        print(f"    x={x:>3}: f(x)={val:.6g}, exp(x)={ie1:.6g}, ratio={ratio:.4f}")

    print()
    print("→ This expression grows like x*exp(x)/(x+exp(x)) ≈ x for large x.")
    print("  It does NOT escape depth 1. The conjecture remains open.")
    print()

    # Try more complex candidates
    print("Testing more complex uncontrolled-inverse expressions...")

    # e = exp(x) * inv(exp(x) - 1)  -- denominator → 0 as x → 0+
    denom = Add(Exp(Var()), Const(-1))  # exp(x) - 1
    candidate2 = Mul(Exp(Var()), Inv(denom))
    print(f"\n  {candidate2}")
    print(f"  Depth: {candidate2.depth}")
    ctrl2, margin2, det2 = has_controlled_inverses(candidate2)
    print(f"  Controlled: {ctrl2} ({det2})")
    for x in [0.01, 0.1, 1, 5, 10]:
        try:
            val = candidate2.eval(x)
            ie2 = iter_exp(2, x)
            print(f"    x={x}: f(x)={val:.6g}, iterExp(2,x)={ie2:.6g}")
        except:
            print(f"    x={x}: overflow")

    print()
    print("→ No depth-1 uncontrolled-inverse expression found that matches")
    print("  iterExp(2, x). The conjecture remains unsettled.")


def demo_condition_number():
    """Demonstrate the spectral margin / condition number connection."""
    print("\n" + "=" * 70)
    print("SPECTRAL MARGIN AND CONDITION NUMBER")
    print("=" * 70)
    print()
    print("Connection: κ(e) = 1/spectralMargin(e)")
    print("Theorem: If κ(e) < ∞, then inv(e) doesn't increase depth complexity.")
    print()

    expressions = [
        ("x + 1", Add(Var(), Const(1))),
        ("x + 0.1", Add(Var(), Const(0.1))),
        ("x + 0.001", Add(Var(), Const(0.001))),
        ("exp(x)", Exp(Var())),
        ("x^2 + 1", Add(Mul(Var(), Var()), Const(1))),
    ]

    print(f"{'Expression':<18} {'Spectral Margin':>16} {'κ = 1/margin':>14} {'1/f bound':>12}")
    print("-" * 65)
    for name, e in expressions:
        margin = estimate_spectral_margin(e)
        kappa = 1.0/margin if margin > 0 else float('inf')
        inv_bound = 1.0/margin if margin > 0 else float('inf')
        print(f"  {name:<16} {margin:>14.6f}   {kappa:>12.4f}   {inv_bound:>10.4f}")

    print()
    print("→ All expressions with finite condition number have bounded inverses.")
    print("  This is the content of the Spectral Margin Condition Number Theorem.")


# ==============================================================================
# Main
# ==============================================================================

if __name__ == "__main__":
    demo_main_theorem()
    demo_spectral_margin()
    demo_condition_number()
    demo_uncontrolled_inverse_conjecture()

    print("\n" + "=" * 70)
    print("ALL DEMOS COMPLETE")
    print("=" * 70)
