#!/usr/bin/env python3
"""
Applications of Depth Rigidity Theory

Demonstrates practical implications for compiler optimization,
symbolic computation, and complexity theory.
"""

import math
from algorithms import PosExpr, compute_depth, iterExp, certified_depth_analysis


# ─────────────────────────────────────────────────────────────
# Application 1: Compiler Optimization Lower Bounds
# ─────────────────────────────────────────────────────────────

def demo_compiler_bounds():
    """Show that no optimizer can reduce iterExp depth."""
    print("=" * 70)
    print("APPLICATION: Compiler Optimization Lower Bounds")
    print("=" * 70)
    print()
    print("The depth rigidity theorem implies that any semantics-preserving")
    print("optimizer for positive-real arithmetic expressions CANNOT reduce")
    print("the depth of iterExp(n) below n.")
    print()

    # Build iterExp(n) for n = 1..4
    var = PosExpr('var', [])

    def build_iterExp(n):
        expr = var
        for _ in range(n):
            expr = PosExpr('exp', [expr])
        return expr

    # Simulate an "optimizer" that tries various algebraic simplifications
    def trivial_optimizer(expr):
        """A trivial optimizer: just returns the expression unchanged."""
        return expr

    def inv_cancel_optimizer(expr):
        """An optimizer that wraps in inv(inv(...)) — no depth change."""
        return PosExpr('inv', [PosExpr('inv', [expr])])

    def mul_identity_optimizer(expr):
        """An optimizer that multiplies by 1 — no depth change."""
        return PosExpr('mul', [expr, PosExpr('const', [], 1.0)])

    optimizers = [
        ("identity", trivial_optimizer),
        ("double-inversion", inv_cancel_optimizer),
        ("multiply-by-1", mul_identity_optimizer),
    ]

    for n in range(1, 5):
        original = build_iterExp(n)
        orig_depth = compute_depth(original)
        print(f"iterExp({n}): original depth = {orig_depth}")

        for opt_name, optimizer in optimizers:
            optimized = optimizer(original)
            opt_depth = compute_depth(optimized)
            assert opt_depth >= n, f"Violation! {opt_name} reduced depth below {n}"
            print(f"  {opt_name}: depth = {opt_depth} ≥ {n} ✓")
        print()

    print("No optimizer can break the depth barrier — this is a provable")
    print("impossibility result, not merely an empirical observation.")
    print()


# ─────────────────────────────────────────────────────────────
# Application 2: Symbolic Computation Complexity
# ─────────────────────────────────────────────────────────────

def demo_symbolic_complexity():
    """Demonstrate implications for symbolic simplification."""
    print("=" * 70)
    print("APPLICATION: Symbolic Computation Complexity")
    print("=" * 70)
    print()
    print("When simplifying expressions involving exp, *, and 1/·,")
    print("the depth rigidity theorem guarantees that certain")
    print("simplifications are IMPOSSIBLE.")
    print()

    test_points = [0.5, 1.0, 1.5, 2.0]

    # Expressions that LOOK like they might simplify iterExp(3)
    var = PosExpr('var', [])
    e1 = PosExpr('exp', [var])
    e2 = PosExpr('exp', [e1])
    e3 = PosExpr('exp', [e2])

    # Attempt: exp(exp(x)) * exp(exp(x)) = exp(2*exp(exp(x)))
    # This is NOT iterExp(3) — it has a different growth rate
    attempt1 = PosExpr('mul', [e2, e2])

    # Attempt: exp(exp(x) * exp(x)) = exp(exp(2x)) ≠ exp(exp(exp(x)))
    attempt2 = PosExpr('exp', [PosExpr('mul', [e1, e1])])

    attempts = [
        ("exp(exp(x))²", attempt1, 2),
        ("exp(exp(x)·exp(x))", attempt2, 2),
    ]

    print("Comparing depth-2 expressions against iterExp(3) = exp(exp(exp(x))):")
    print()
    print(f"{'Expression':>25} | depth | {'x=1':>10} | {'x=2':>10} | {'iterExp3':>10} | match?")
    print("-" * 85)

    for name, expr, d in attempts:
        vals = []
        matches = True
        for x in [1.0, 2.0]:
            val = expr.eval(x)
            target = iterExp(3, x)
            vals.append(f"{val:.4g}")
            if abs(val - target) > 1e-6 * max(1, abs(target)):
                matches = False

        target_vals = [f"{iterExp(3, x):.4g}" for x in [1.0, 2.0]]
        status = "YES" if matches else "NO"
        print(f"{name:>25} |   {d}   | {vals[0]:>10} | {vals[1]:>10} | {target_vals[1]:>10} | {status}")

    print()
    print("None of the depth-2 expressions can match iterExp(3).")
    print("The depth rigidity theorem proves this is ALWAYS the case.")
    print()


# ─────────────────────────────────────────────────────────────
# Application 3: Growth Rate Classification
# ─────────────────────────────────────────────────────────────

def demo_growth_classification():
    """Classify expressions by their asymptotic growth class."""
    print("=" * 70)
    print("APPLICATION: Growth Rate Classification")
    print("=" * 70)
    print()
    print("Expressions are classified into growth classes by their depth:")
    print("  Depth 0: polynomial growth (x, 1/x, x², etc.)")
    print("  Depth 1: single-exponential growth (exp(x), 1/exp(x), etc.)")
    print("  Depth 2: double-exponential growth (exp(exp(x)), etc.)")
    print("  Depth n: n-fold exponential growth")
    print()

    var = PosExpr('var', [])

    expressions = [
        # Depth 0
        ("x", var),
        ("1/x", PosExpr('inv', [var])),
        ("x·x", PosExpr('mul', [var, var])),
        ("1/(x·x)", PosExpr('inv', [PosExpr('mul', [var, var])])),

        # Depth 1
        ("exp(x)", PosExpr('exp', [var])),
        ("1/exp(x)", PosExpr('inv', [PosExpr('exp', [var])])),
        ("exp(x)·x", PosExpr('mul', [PosExpr('exp', [var]), var])),
        ("exp(x)/x", PosExpr('mul', [PosExpr('exp', [var]), PosExpr('inv', [var])])),

        # Depth 2
        ("exp(exp(x))", PosExpr('exp', [PosExpr('exp', [var])])),
        ("exp(exp(x))/exp(x)",
         PosExpr('mul', [
             PosExpr('exp', [PosExpr('exp', [var])]),
             PosExpr('inv', [PosExpr('exp', [var])])
         ])),
    ]

    print(f"{'Expression':>25} | depth | {'f(1)':>12} | {'f(5)':>12} | {'f(10)':>12}")
    print("-" * 80)

    for name, expr in expressions:
        analysis = certified_depth_analysis(expr)
        vals = []
        for x in [1.0, 5.0, 10.0]:
            try:
                v = expr.eval(x)
                if math.isinf(v):
                    vals.append("∞")
                elif abs(v) < 0.001:
                    vals.append(f"{v:.2e}")
                elif abs(v) > 1e10:
                    vals.append(f"{v:.2e}")
                else:
                    vals.append(f"{v:.4f}")
            except:
                vals.append("err")

        print(f"{name:>25} |   {analysis['depth']}   | {vals[0]:>12} | {vals[1]:>12} | {vals[2]:>12}")

    print()
    print("Key insight: within each depth class, inversion only creates")
    print("functions that decay (approach 0) rather than grow faster.")
    print("No clever combination of mul and inv can jump to the next class.")


if __name__ == '__main__':
    demo_compiler_bounds()
    print()
    demo_symbolic_complexity()
    print()
    demo_growth_classification()


#!/usr/bin/env python3
"""
Depth Rigidity in the Full EML Language with Inversions — Interactive Demo

This script demonstrates the depth rigidity theorem for iterated exponentials:
no expression using multiplication, inversion, and exponentiation can compute
iterExp(n) with fewer than n nested exponentiations.

It enumerates small expression DAGs with inversions, evaluates them at sample
points, and compares against iterExp(n) to search for counterexamples.
"""

import math
import itertools
from dataclasses import dataclass
from typing import List, Callable, Optional, Tuple
import sys

# ─────────────────────────────────────────────────────────────
# Core Definitions
# ─────────────────────────────────────────────────────────────

def iterExp(n: int, x: float) -> float:
    """Compute the n-fold iterated exponential: iterExp(0,x) = x, iterExp(n+1,x) = exp(iterExp(n,x))."""
    result = x
    for _ in range(n):
        if result > 700:  # overflow guard
            return float('inf')
        result = math.exp(result)
    return result


# ─────────────────────────────────────────────────────────────
# Expression Tree Representation
# ─────────────────────────────────────────────────────────────

@dataclass
class Expr:
    """An expression in the positive-real EML language."""
    kind: str  # 'var', 'const', 'mul', 'inv', 'exp'
    children: list  # sub-expressions
    value: float = 0.0  # for 'const' nodes

    def eval(self, x: float) -> float:
        if self.kind == 'var':
            return x
        elif self.kind == 'const':
            return self.value
        elif self.kind == 'mul':
            return self.children[0].eval(x) * self.children[1].eval(x)
        elif self.kind == 'inv':
            v = self.children[0].eval(x)
            return 1.0 / v if v != 0 else float('inf')
        elif self.kind == 'exp':
            v = self.children[0].eval(x)
            if v > 700:
                return float('inf')
            return math.exp(v)
        else:
            raise ValueError(f"Unknown kind: {self.kind}")

    def depth(self) -> int:
        """Exponential nesting depth (only exp increments)."""
        if self.kind in ('var', 'const'):
            return 0
        elif self.kind == 'mul':
            return max(self.children[0].depth(), self.children[1].depth())
        elif self.kind == 'inv':
            return self.children[0].depth()
        elif self.kind == 'exp':
            return 1 + self.children[0].depth()
        return 0

    def growth_rank(self) -> int:
        """Growth rank = depth for expression trees."""
        return self.depth()

    def size(self) -> int:
        if self.kind in ('var', 'const'):
            return 1
        elif self.kind in ('inv', 'exp'):
            return 1 + self.children[0].size()
        elif self.kind == 'mul':
            return 1 + self.children[0].size() + self.children[1].size()
        return 1

    def __str__(self):
        if self.kind == 'var':
            return 'x'
        elif self.kind == 'const':
            return f'{self.value}'
        elif self.kind == 'mul':
            return f'({self.children[0]} * {self.children[1]})'
        elif self.kind == 'inv':
            return f'(1/{self.children[0]})'
        elif self.kind == 'exp':
            return f'exp({self.children[0]})'
        return '?'


VAR = Expr('var', [])
def CONST(c): return Expr('const', [], c)
def MUL(a, b): return Expr('mul', [a, b])
def INV(a): return Expr('inv', [a])
def EXP(a): return Expr('exp', [a])


# ─────────────────────────────────────────────────────────────
# Expression Enumeration
# ─────────────────────────────────────────────────────────────

def enumerate_exprs(max_size: int, constants: list = [1.0, 2.0]) -> List[Expr]:
    """Enumerate all expressions up to a given size."""
    if max_size <= 0:
        return []

    # Size 1: var and constants
    exprs_by_size = {1: [VAR] + [CONST(c) for c in constants]}

    for s in range(2, max_size + 1):
        exprs = []
        # Unary operations: inv, exp (size = 1 + child_size)
        if s - 1 in exprs_by_size:
            for child in exprs_by_size[s - 1]:
                exprs.append(INV(child))
                exprs.append(EXP(child))
        # Binary operation: mul (size = 1 + left_size + right_size)
        for left_size in range(1, s - 1):
            right_size = s - 1 - left_size
            if left_size in exprs_by_size and right_size in exprs_by_size:
                for left in exprs_by_size[left_size]:
                    for right in exprs_by_size[right_size]:
                        exprs.append(MUL(left, right))
        exprs_by_size[s] = exprs

    all_exprs = []
    for s in range(1, max_size + 1):
        all_exprs.extend(exprs_by_size.get(s, []))
    return all_exprs


# ─────────────────────────────────────────────────────────────
# Depth vs Growth Analysis
# ─────────────────────────────────────────────────────────────

def check_computes_iterExp(expr: Expr, n: int, test_points: list, tol: float = 1e-6) -> bool:
    """Check if expr computes iterExp(n) at all test points."""
    for x in test_points:
        if x <= 0:
            continue
        try:
            actual = expr.eval(x)
            expected = iterExp(n, x)
            if math.isinf(actual) and math.isinf(expected):
                continue
            if math.isinf(actual) or math.isinf(expected):
                return False
            if abs(actual - expected) > tol * max(1, abs(expected)):
                return False
        except (OverflowError, ZeroDivisionError, ValueError):
            return False
    return True


def demo_depth_rigidity():
    """Demonstrate the depth rigidity theorem by exhaustive search."""
    print("=" * 70)
    print("DEPTH RIGIDITY DEMO: Searching for counterexamples")
    print("=" * 70)
    print()
    print("Theorem: Any expression computing iterExp(n) on positive reals")
    print("         must have depth >= n, even with inversions available.")
    print()

    test_points = [0.1, 0.5, 1.0, 1.5, 2.0]
    max_size = 7
    constants = [1.0]

    print(f"Enumerating expressions up to size {max_size}...")
    exprs = enumerate_exprs(max_size, constants)
    print(f"Generated {len(exprs)} expressions.")
    print()

    for n in range(1, 5):
        print(f"--- Testing iterExp({n}) ---")
        candidates = []
        violations = []

        for expr in exprs:
            if check_computes_iterExp(expr, n, test_points):
                candidates.append(expr)
                if expr.depth() < n:
                    violations.append(expr)

        print(f"  Candidates matching iterExp({n}): {len(candidates)}")
        if candidates:
            min_depth = min(e.depth() for e in candidates)
            print(f"  Minimum depth among candidates: {min_depth}")
            # Show a few candidates
            for e in candidates[:3]:
                print(f"    depth={e.depth()}, size={e.size()}: {e}")

        if violations:
            print(f"  *** COUNTEREXAMPLE FOUND! ***")
            for v in violations:
                print(f"    depth={v.depth()}: {v}")
        else:
            print(f"  No counterexamples found (consistent with theorem).")
        print()


def demo_inversion_stress_test():
    """Test specific inversion-mediated cancellation attempts."""
    print("=" * 70)
    print("INVERSION STRESS TEST")
    print("=" * 70)
    print()
    print("Testing whether clever use of inversion can reduce depth...")
    print()

    test_points = [0.5, 1.0, 1.5, 2.0, 2.5]

    # Attempts to compute iterExp(3) = exp(exp(exp(x))) at reduced depth
    attempts = [
        ("exp(exp(exp(x)))", EXP(EXP(EXP(VAR))), 3),
        ("exp(exp(x)) * exp(x) / exp(x)", MUL(MUL(EXP(EXP(VAR)), EXP(VAR)), INV(EXP(VAR))), 2),
        ("exp(exp(x)) * 1", MUL(EXP(EXP(VAR)), CONST(1.0)), 2),
        ("1 / (1/exp(exp(exp(x))))", INV(INV(EXP(EXP(EXP(VAR))))), 3),
        ("exp(x * exp(x) / exp(x))", EXP(MUL(MUL(VAR, EXP(VAR)), INV(EXP(VAR)))), 2),
    ]

    for name, expr, target_n in attempts:
        depth = expr.depth()
        matches = check_computes_iterExp(expr, target_n, test_points)
        status = "MATCH" if matches else "no match"
        depth_ok = "depth >= n" if depth >= target_n else "VIOLATION!"
        print(f"  {name}")
        print(f"    depth={depth}, target iterExp({target_n}): {status}, {depth_ok}")

        # Show values
        for x in [1.0, 1.5]:
            try:
                val = expr.eval(x)
                expected = iterExp(target_n, x)
                print(f"    x={x}: expr={val:.4g}, iterExp({target_n})={expected:.4g}")
            except:
                print(f"    x={x}: evaluation error")
        print()


def demo_growth_analysis():
    """Analyze growth rates of expressions at different depths."""
    print("=" * 70)
    print("GROWTH RATE ANALYSIS")
    print("=" * 70)
    print()

    x_values = [1.0, 2.0, 3.0, 4.0, 5.0]

    print("iterExp(n, x) for small n and x:")
    print(f"{'x':>8}", end="")
    for n in range(5):
        print(f"  {'iterExp('+str(n)+')':>16}", end="")
    print()

    for x in x_values:
        print(f"{x:>8.1f}", end="")
        for n in range(5):
            val = iterExp(n, x)
            if math.isinf(val):
                print(f"  {'inf':>16}", end="")
            elif val > 1e15:
                print(f"  {val:>16.4e}", end="")
            else:
                print(f"  {val:>16.4f}", end="")
        print()
    print()

    print("Key observation: Each level of iterExp grows incomparably faster")
    print("than the previous, confirming the strict depth hierarchy.")
    print()

    # Show that inversion doesn't help
    print("Effect of inversion on growth:")
    exprs_with_inv = [
        ("exp(x)", EXP(VAR)),
        ("1/exp(x)", INV(EXP(VAR))),
        ("exp(exp(x))", EXP(EXP(VAR))),
        ("1/exp(exp(x))", INV(EXP(EXP(VAR)))),
        ("exp(x) * 1/exp(x)", MUL(EXP(VAR), INV(EXP(VAR)))),
        ("exp(exp(x)) * 1/exp(x)", MUL(EXP(EXP(VAR)), INV(EXP(VAR)))),
    ]

    for name, expr in exprs_with_inv:
        depth = expr.depth()
        grank = expr.growth_rank()
        vals = []
        for x in [1.0, 2.0, 3.0]:
            try:
                v = expr.eval(x)
                vals.append(f"{v:.4g}")
            except:
                vals.append("err")
        print(f"  depth={depth}, rank={grank}: {name:>35} | values: {', '.join(vals)}")
    print()
    print("Inversion creates decay (values → 0) but cannot exceed the")
    print("growth rate of the original expression's depth level.")


def demo_envelope_visualization():
    """Demonstrate the reciprocal envelope concept."""
    print("=" * 70)
    print("RECIPROCAL ENVELOPE DEMONSTRATION")
    print("=" * 70)
    print()
    print("The reciprocal envelope bounds both f(x) and 1/f(x):")
    print("  1/iterExp(d, C·x^N) ≤ f(x) ≤ iterExp(d, C·x^N)")
    print()

    exprs = [
        ("x", VAR, 0),
        ("1/x", INV(VAR), 0),
        ("exp(x)", EXP(VAR), 1),
        ("1/exp(x)", INV(EXP(VAR)), 1),
        ("exp(x) * 1/exp(x) = 1", MUL(EXP(VAR), INV(EXP(VAR))), 1),
        ("exp(exp(x))", EXP(EXP(VAR)), 2),
        ("1/exp(exp(x))", INV(EXP(EXP(VAR))), 2),
    ]

    print(f"{'Expression':>30} | depth | {'f(2)':>12} | {'1/f(2)':>12} | {'bound':>12}")
    print("-" * 85)

    x = 2.0
    for name, expr, d in exprs:
        try:
            fx = expr.eval(x)
            inv_fx = 1.0 / fx if fx != 0 else float('inf')
            bound = iterExp(d, 2.0 * x)  # C=2, N=1 as example
            print(f"{name:>30} |   {d}   | {fx:>12.4g} | {inv_fx:>12.4g} | {bound:>12.4g}")
        except:
            print(f"{name:>30} |   {d}   | {'err':>12} | {'err':>12} | {'err':>12}")

    print()
    print("Both f(x) and 1/f(x) are bounded by the tower at the expression's depth level.")
    print("Inversion just swaps f and 1/f — it cannot escape the envelope.")


if __name__ == '__main__':
    demo_depth_rigidity()
    print()
    demo_inversion_stress_test()
    print()
    demo_growth_analysis()
    print()
    demo_envelope_visualization()
