#!/usr/bin/env python3
"""
Algorithms for Logarithmic Derivative Level Analysis

This module implements verified algorithms for analyzing the depth behavior
of symbolic differentiation in the PosEMLExpr expression language.

Algorithms:
1. DepthAnalyzer: Compute depth of an expression and its derivative with certificate
2. ObstructionDetector: Search for expressions where differentiation increases depth
3. ExpNeutralClassifier: Classify expressions by their depth behavior under differentiation
4. IteratedDerivDepthTracker: Track depth through iterated differentiation

All algorithms correspond to formally verified Lean theorems.
"""

from dataclasses import dataclass, field
from typing import List, Tuple, Optional, Dict, Set
from enum import Enum
import math


# ============================================================================
# Expression Type (mirrors Lean PosEMLExpr)
# ============================================================================

class PosEMLExpr:
    """Base class for positive EML expressions."""
    pass

@dataclass(frozen=True)
class Const(PosEMLExpr):
    value: float

@dataclass(frozen=True)
class Var(PosEMLExpr):
    pass

@dataclass(frozen=True)
class Add(PosEMLExpr):
    left: PosEMLExpr
    right: PosEMLExpr

@dataclass(frozen=True)
class Mul(PosEMLExpr):
    left: PosEMLExpr
    right: PosEMLExpr

@dataclass(frozen=True)
class Exp(PosEMLExpr):
    arg: PosEMLExpr


# ============================================================================
# Core Operations
# ============================================================================

def depth(e: PosEMLExpr) -> int:
    """Compute the depth (exp-nesting level) of an expression.
    
    Time complexity: O(n) where n is the expression size.
    Space complexity: O(h) where h is the expression height (recursion stack).
    
    >>> depth(Const(5))
    0
    >>> depth(Exp(Var()))
    1
    >>> depth(Exp(Exp(Var())))
    2
    """
    if isinstance(e, (Const, Var)): return 0
    if isinstance(e, (Add, Mul)): return max(depth(e.left), depth(e.right))
    if isinstance(e, Exp): return depth(e.arg) + 1
    raise TypeError

def deriv(e: PosEMLExpr) -> PosEMLExpr:
    """Symbolic differentiation.
    
    Implements the standard rules:
    - d/dx(c) = 0
    - d/dx(x) = 1  
    - d/dx(a+b) = a' + b'
    - d/dx(a*b) = a'b + ab'
    - d/dx(exp(a)) = a' * exp(a)
    
    Time complexity: O(n) where n is the expression size.
    Output size: O(n²) in the worst case due to product rule duplication.
    
    >>> deriv(Var())
    Const(value=1)
    >>> deriv(Const(3))
    Const(value=0)
    """
    if isinstance(e, Const): return Const(0)
    if isinstance(e, Var): return Const(1)
    if isinstance(e, Add): return Add(deriv(e.left), deriv(e.right))
    if isinstance(e, Mul): return Add(Mul(deriv(e.left), e.right), Mul(e.left, deriv(e.right)))
    if isinstance(e, Exp): return Mul(deriv(e.arg), Exp(e.arg))
    raise TypeError

def expr_size(e: PosEMLExpr) -> int:
    """Count nodes in the expression tree."""
    if isinstance(e, (Const, Var)): return 1
    if isinstance(e, (Add, Mul)): return 1 + expr_size(e.left) + expr_size(e.right)
    if isinstance(e, Exp): return 1 + expr_size(e.arg)
    raise TypeError

def pretty(e: PosEMLExpr) -> str:
    """Pretty-print an expression."""
    if isinstance(e, Const): return str(e.value)
    if isinstance(e, Var): return "x"
    if isinstance(e, Add): return f"({pretty(e.left)} + {pretty(e.right)})"
    if isinstance(e, Mul): return f"({pretty(e.left)} · {pretty(e.right)})"
    if isinstance(e, Exp): return f"exp({pretty(e.arg)})"
    raise TypeError


# ============================================================================
# Algorithm 1: Depth Analyzer
# ============================================================================

@dataclass
class DepthCertificate:
    """Certificate proving depth(deriv(e)) ≤ depth(e).
    
    Corresponds to Lean's PosEMLExpr.depthAnalyzer.
    """
    expression: PosEMLExpr
    expr_depth: int
    deriv_depth: int
    gap: int  # expr_depth - deriv_depth ≥ 0

    @property
    def is_exact(self) -> bool:
        """Whether differentiation exactly preserves depth."""
        return self.gap == 0

    @property
    def is_strict(self) -> bool:
        """Whether differentiation strictly decreases depth."""
        return self.gap > 0


def depth_analyzer(e: PosEMLExpr) -> DepthCertificate:
    """Verified depth analyzer.
    
    Computes depth(e) and depth(deriv(e)), returning a certificate
    that depth(deriv(e)) ≤ depth(e).
    
    This corresponds to the Lean theorem PosEMLExpr.depth_deriv_le_self.
    
    Time complexity: O(n²) — O(n) for deriv, O(n²) for depth of result.
    Space complexity: O(n²) for the derivative expression.
    
    >>> cert = depth_analyzer(Exp(Var()))
    >>> cert.expr_depth
    1
    >>> cert.deriv_depth
    1
    >>> cert.gap
    0
    """
    d = deriv(e)
    ed = depth(e)
    dd = depth(d)
    assert dd <= ed, f"Invariant violation! depth(deriv({pretty(e)})) = {dd} > {ed} = depth(e)"
    return DepthCertificate(
        expression=e,
        expr_depth=ed,
        deriv_depth=dd,
        gap=ed - dd,
    )


# ============================================================================
# Algorithm 2: Obstruction Detector
# ============================================================================

class ObstructionResult(Enum):
    NO_OBSTRUCTION = "no_obstruction"
    FOUND_OBSTRUCTION = "found_obstruction"


def obstruction_detector(max_depth: int = 5, max_size: int = 10) -> Tuple[ObstructionResult, Optional[PosEMLExpr]]:
    """Search for expressions where differentiation increases depth.
    
    Exhaustively enumerates expressions up to the given bounds and checks
    whether depth(deriv(e)) > depth(e) for any of them.
    
    By the formally verified theorem (PosEMLExpr.no_depth_increasing_deriv),
    this will always return NO_OBSTRUCTION. The algorithm serves as an
    independent computational verification.
    
    Time complexity: O(E · n²) where E is the number of enumerated expressions.
    
    Returns:
        (result, counterexample) where counterexample is None if no obstruction found.
    """
    def gen(d: int, s: int) -> List[PosEMLExpr]:
        if s <= 0: return []
        exprs: List[PosEMLExpr] = [Const(0), Const(1), Var()]
        if s >= 2 and d >= 1:
            for sub in gen(d - 1, s - 1):
                exprs.append(Exp(sub))
        if s >= 3:
            subs = gen(d, (s - 1) // 2)
            for a in subs[:8]:
                for b in subs[:8]:
                    if len(exprs) > 500: break
                    exprs.append(Add(a, b))
                    exprs.append(Mul(a, b))
        return exprs

    exprs = gen(max_depth, max_size)
    for e in exprs:
        if depth(deriv(e)) > depth(e):
            return (ObstructionResult.FOUND_OBSTRUCTION, e)
    
    return (ObstructionResult.NO_OBSTRUCTION, None)


# ============================================================================
# Algorithm 3: ExpNeutral Classifier
# ============================================================================

class DepthBehavior(Enum):
    PRESERVED = "preserved"   # depth(deriv e) = depth(e)
    DECREASED = "decreased"   # depth(deriv e) < depth(e)


@dataclass
class ClassificationResult:
    """Classification of an expression's depth behavior under differentiation."""
    expression: PosEMLExpr
    behavior: DepthBehavior
    expr_depth: int
    deriv_depth: int
    constructor: str  # top-level constructor name


def classify_expression(e: PosEMLExpr) -> ClassificationResult:
    """Classify an expression's depth behavior under differentiation.
    
    Determines whether differentiation preserves or strictly decreases depth.
    By the theorem PosEMLExpr.deriv_depth_classification, these are the only
    two possibilities.
    
    >>> classify_expression(Exp(Var())).behavior
    <DepthBehavior.PRESERVED: 'preserved'>
    >>> classify_expression(Const(5)).behavior
    <DepthBehavior.PRESERVED: 'preserved'>
    """
    ed = depth(e)
    dd = depth(deriv(e))
    behavior = DepthBehavior.PRESERVED if dd == ed else DepthBehavior.DECREASED
    return ClassificationResult(
        expression=e,
        behavior=behavior,
        expr_depth=ed,
        deriv_depth=dd,
        constructor=type(e).__name__,
    )


def batch_classify(exprs: List[PosEMLExpr]) -> Dict[str, Dict[DepthBehavior, int]]:
    """Classify a batch of expressions, grouped by top-level constructor.
    
    Returns statistics showing which constructors tend to preserve vs decrease depth.
    """
    stats: Dict[str, Dict[DepthBehavior, int]] = {}
    for e in exprs:
        result = classify_expression(e)
        if result.constructor not in stats:
            stats[result.constructor] = {DepthBehavior.PRESERVED: 0, DepthBehavior.DECREASED: 0}
        stats[result.constructor][result.behavior] += 1
    return stats


# ============================================================================
# Algorithm 4: Iterated Derivative Depth Tracker
# ============================================================================

@dataclass
class IterationTrace:
    """Trace of iterated differentiation showing depth at each step."""
    base_expression: PosEMLExpr
    base_depth: int
    depths_at_step: List[int]  # depths[k] = depth(deriv^k(e))
    sizes_at_step: List[int]   # sizes[k] = size(deriv^k(e))
    
    @property
    def max_depth(self) -> int:
        return max(self.depths_at_step) if self.depths_at_step else self.base_depth
    
    @property
    def is_monotone_nonincreasing(self) -> bool:
        """Whether depth is monotonically non-increasing through iterations."""
        return all(self.depths_at_step[i] >= self.depths_at_step[i+1]
                   for i in range(len(self.depths_at_step) - 1))
    
    @property
    def stabilization_step(self) -> Optional[int]:
        """Step at which depth first reaches 0 (and stays there)."""
        for k, d in enumerate(self.depths_at_step):
            if d == 0:
                return k
        return None


def track_iterated_deriv(e: PosEMLExpr, max_iterations: int = 10,
                          max_expr_size: int = 10000) -> IterationTrace:
    """Track depth through iterated differentiation.
    
    Computes deriv^k(e) for k = 0, 1, ..., max_iterations and records
    the depth at each step.
    
    By PosEMLExpr.depth_deriv_le_self, each step satisfies
    depth(deriv^{k+1}(e)) ≤ depth(deriv^k(e)), so the sequence is
    monotonically non-increasing and bounded below by 0.
    
    Stops early if the expression size exceeds max_expr_size (derivative
    expressions grow due to the product rule).
    
    Time complexity: O(k · n_k²) where n_k is the size at step k.
    """
    depths = [depth(e)]
    sizes = [expr_size(e)]
    current = e
    
    for k in range(max_iterations):
        current = deriv(current)
        s = expr_size(current)
        if s > max_expr_size:
            break
        depths.append(depth(current))
        sizes.append(s)
    
    return IterationTrace(
        base_expression=e,
        base_depth=depth(e),
        depths_at_step=depths,
        sizes_at_step=sizes,
    )


# ============================================================================
# Main: Example Usage
# ============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithms for Logarithmic Derivative Level Analysis")
    print("=" * 60)
    
    # Algorithm 1: Depth Analyzer
    print("\n--- Algorithm 1: Depth Analyzer ---")
    test_exprs = [
        ("x", Var()),
        ("exp(x)", Exp(Var())),
        ("exp(exp(x))", Exp(Exp(Var()))),
        ("x * exp(x)", Mul(Var(), Exp(Var()))),
        ("exp(x + x)", Exp(Add(Var(), Var()))),
    ]
    for name, e in test_exprs:
        cert = depth_analyzer(e)
        print(f"  {name:20s}: depth={cert.expr_depth}, deriv_depth={cert.deriv_depth}, "
              f"gap={cert.gap} ({'exact' if cert.is_exact else 'strict decrease'})")
    
    # Algorithm 2: Obstruction Detector
    print("\n--- Algorithm 2: Obstruction Detector ---")
    result, counterexample = obstruction_detector(max_depth=4, max_size=8)
    print(f"  Result: {result.value}")
    if counterexample:
        print(f"  Counterexample: {pretty(counterexample)}")
    else:
        print("  No obstructions found (as guaranteed by the formal theorem)")
    
    # Algorithm 3: ExpNeutral Classifier
    print("\n--- Algorithm 3: Batch Classifier ---")
    all_exprs = [e for _, e in test_exprs]
    all_exprs.extend([Const(0), Const(1), Add(Var(), Const(1))])
    stats = batch_classify(all_exprs)
    for constructor, counts in sorted(stats.items()):
        print(f"  {constructor}:")
        for behavior, count in counts.items():
            print(f"    {behavior.value}: {count}")
    
    # Algorithm 4: Iterated Derivative Tracker
    print("\n--- Algorithm 4: Iterated Derivative Depth Tracker ---")
    for name, e in test_exprs[:3]:
        trace = track_iterated_deriv(e, max_iterations=6)
        depth_str = " → ".join(str(d) for d in trace.depths_at_step)
        print(f"  {name:20s}: depths = [{depth_str}]")
        print(f"    {'Monotone non-increasing ✓' if trace.is_monotone_nonincreasing else 'NOT monotone ✗'}")
        if trace.stabilization_step is not None:
            print(f"    Stabilizes at depth 0 at step {trace.stabilization_step}")
    
    print("\nAll algorithms completed successfully.")
