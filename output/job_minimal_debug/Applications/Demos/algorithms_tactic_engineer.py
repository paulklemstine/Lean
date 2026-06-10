#!/usr/bin/env python3
"""
Algorithms for Tropical Expression Normalization

Implements the certified normalization algorithm with complexity analysis,
iterated rewriting, and semantic analysis utilities.

Algorithm Summary:
- normalize: O(n) time, O(n) space recursive normalizer
- is_normalized: O(n) time normal form checker
- iterated_rewrite: applies local rewrite steps until fixpoint
- semantic_equivalence_check: tests semantic equality by normalization
"""

from dataclasses import dataclass
from typing import Callable, List, Optional, Tuple, Union
import math
import time


# ============================================================
# Expression Types (self-contained)
# ============================================================

@dataclass(frozen=True)
class Const:
    value: float

@dataclass(frozen=True)
class Var:
    index: int

@dataclass(frozen=True)
class TMin:
    left: 'TropExpr'
    right: 'TropExpr'

@dataclass(frozen=True)
class Add:
    left: 'TropExpr'
    right: 'TropExpr'

TropExpr = Union[Const, Var, TMin, Add]


def pretty(e: TropExpr) -> str:
    if isinstance(e, Const): return f"{e.value:g}"
    if isinstance(e, Var): return f"x{e.index}"
    if isinstance(e, TMin): return f"min({pretty(e.left)}, {pretty(e.right)})"
    if isinstance(e, Add): return f"({pretty(e.left)} + {pretty(e.right)})"
    raise TypeError


def size(e: TropExpr) -> int:
    if isinstance(e, (Const, Var)): return 1
    return size(e.left) + size(e.right) + 1


def eval_expr(sigma: Callable[[int], float], e: TropExpr) -> float:
    if isinstance(e, Const): return e.value
    if isinstance(e, Var): return sigma(e.index)
    if isinstance(e, TMin): return min(eval_expr(sigma, e.left), eval_expr(sigma, e.right))
    if isinstance(e, Add): return eval_expr(sigma, e.left) + eval_expr(sigma, e.right)
    raise TypeError


# ============================================================
# Algorithm 1: Recursive Normalizer
# ============================================================

def normalize(e: TropExpr) -> TropExpr:
    """
    Certified recursive normalizer for tropical expressions.

    Algorithm:
        1. Recursively normalize children
        2. Constant-fold: add(const a, const b) → const(a+b)
                          tmin(const a, const b) → const(min(a,b))
        3. Idempotence: tmin(e, e) → e

    Complexity:
        Time:  O(n) where n = size(e)
        Space: O(d) stack depth where d = depth(e), O(n) for output

    Correctness (formally verified):
        - eval σ (normalize e) = eval σ e       (semantics preservation)
        - size(normalize e) ≤ size(e)            (size non-increase)
        - normalize(normalize e) = normalize e   (idempotence)
        - isNormalized(normalize e) = true       (output is in normal form)

    Args:
        e: A tropical expression

    Returns:
        The normalized form of e
    """
    if isinstance(e, (Const, Var)):
        return e
    elif isinstance(e, Add):
        a = normalize(e.left)
        b = normalize(e.right)
        if isinstance(a, Const) and isinstance(b, Const):
            return Const(a.value + b.value)
        return Add(a, b)
    elif isinstance(e, TMin):
        a = normalize(e.left)
        b = normalize(e.right)
        if a == b:
            return a  # Idempotence: min(x, x) = x
        if isinstance(a, Const) and isinstance(b, Const):
            return Const(min(a.value, b.value))
        return TMin(a, b)
    raise TypeError


# ============================================================
# Algorithm 2: Normal Form Checker
# ============================================================

def is_normalized(e: TropExpr) -> bool:
    """
    Check whether an expression is in normal form.

    An expression is in normal form iff:
    - Constants and variables are always normal
    - add(a, b) is normal if a, b are normal and not both constants
    - tmin(a, b) is normal if a ≠ b, not both constants, and both normal

    Complexity: O(n) time, O(d) stack space

    Args:
        e: A tropical expression

    Returns:
        True iff e is in normal form
    """
    if isinstance(e, (Const, Var)):
        return True
    elif isinstance(e, Add):
        if isinstance(e.left, Const) and isinstance(e.right, Const):
            return False
        return is_normalized(e.left) and is_normalized(e.right)
    elif isinstance(e, TMin):
        if e.left == e.right:
            return False
        if isinstance(e.left, Const) and isinstance(e.right, Const):
            return False
        return is_normalized(e.left) and is_normalized(e.right)
    return False


# ============================================================
# Algorithm 3: One-Step Rewriter
# ============================================================

def rewrite_step(e: TropExpr) -> TropExpr:
    """
    Apply a single top-level rewrite step.

    Rules (verified sound):
        tmin(const a, const b) → const(min(a, b))
        add(const a, const b) → const(a + b)
        tmin(a, a) → a

    Complexity: O(1) time for the top-level step

    Args:
        e: A tropical expression

    Returns:
        The rewritten expression (or e unchanged if no rule applies)
    """
    if isinstance(e, TMin):
        if isinstance(e.left, Const) and isinstance(e.right, Const):
            return Const(min(e.left.value, e.right.value))
        if e.left == e.right:
            return e.left
    elif isinstance(e, Add):
        if isinstance(e.left, Const) and isinstance(e.right, Const):
            return Const(e.left.value + e.right.value)
    return e


# ============================================================
# Algorithm 4: Iterated Rewriter
# ============================================================

def iterated_rewrite(e: TropExpr, max_steps: int = 1000) -> Tuple[TropExpr, int]:
    """
    Apply rewrite steps bottom-up until fixpoint.

    This implements a bottom-up rewriting strategy: normalize children first,
    then apply the top-level rewrite step. Iterates until the expression
    no longer changes.

    Complexity: O(n * k) where k = number of iterations (bounded by size reduction)

    Args:
        e: A tropical expression
        max_steps: Maximum number of rewrite iterations

    Returns:
        Tuple of (normalized expression, number of steps taken)
    """
    steps = 0
    while steps < max_steps:
        # Bottom-up: rewrite children first
        if isinstance(e, Add):
            new_left, s1 = iterated_rewrite(e.left, max_steps - steps)
            steps += s1
            new_right, s2 = iterated_rewrite(e.right, max_steps - steps)
            steps += s2
            e_new = rewrite_step(Add(new_left, new_right))
        elif isinstance(e, TMin):
            new_left, s1 = iterated_rewrite(e.left, max_steps - steps)
            steps += s1
            new_right, s2 = iterated_rewrite(e.right, max_steps - steps)
            steps += s2
            e_new = rewrite_step(TMin(new_left, new_right))
        else:
            e_new = rewrite_step(e)

        steps += 1
        if e_new == e:
            return e, steps
        e = e_new

    return e, steps


# ============================================================
# Algorithm 5: Semantic Equivalence Checker
# ============================================================

def semantic_equivalence_check(e1: TropExpr, e2: TropExpr) -> bool:
    """
    Check semantic equivalence by comparing normal forms.

    By the extensional uniqueness theorem:
        normalize(e1) = normalize(e2) → ∀ σ, eval σ e1 = eval σ e2

    Note: This is sound but not complete — two semantically equivalent
    expressions may have different normal forms if the normalization
    doesn't capture all identities (e.g., commutativity of min).

    Complexity: O(n + m) where n = size(e1), m = size(e2)

    Args:
        e1, e2: Tropical expressions

    Returns:
        True if proven equivalent (False means unknown)
    """
    return normalize(e1) == normalize(e2)


# ============================================================
# Algorithm 6: Bound Propagation
# ============================================================

def upper_bound(e: TropExpr, var_bounds: dict) -> float:
    """
    Compute an upper bound on eval(σ, e) given variable bounds.

    Uses the structure of min and + to propagate bounds:
        ub(const r) = r
        ub(var n) = var_bounds[n]
        ub(tmin a b) = min(ub(a), ub(b))
        ub(add a b) = ub(a) + ub(b)

    By normalize_preserves_upper_bound, this bound also applies
    to the normalized expression.

    Args:
        e: A tropical expression
        var_bounds: Dict mapping variable indices to upper bounds

    Returns:
        Upper bound on eval(σ, e) for any σ satisfying the bounds
    """
    if isinstance(e, Const):
        return e.value
    elif isinstance(e, Var):
        return var_bounds.get(e.index, float('inf'))
    elif isinstance(e, TMin):
        return min(upper_bound(e.left, var_bounds),
                   upper_bound(e.right, var_bounds))
    elif isinstance(e, Add):
        return upper_bound(e.left, var_bounds) + upper_bound(e.right, var_bounds)
    raise TypeError


# ============================================================
# Complexity Benchmarks
# ============================================================

def generate_random_expr(depth: int, num_vars: int = 5) -> TropExpr:
    """Generate a random tropical expression of given depth."""
    import random
    if depth <= 0:
        if random.random() < 0.5:
            return Const(random.uniform(-10, 10))
        else:
            return Var(random.randint(0, num_vars - 1))
    op = random.choice(['add', 'tmin', 'tmin_idem'])
    if op == 'tmin_idem':
        child = generate_random_expr(depth - 1, num_vars)
        return TMin(child, child)  # Guaranteed idempotent
    left = generate_random_expr(depth - 1, num_vars)
    right = generate_random_expr(depth - 1, num_vars)
    return TMin(left, right) if op == 'tmin' else Add(left, right)


def benchmark_normalization(depths: List[int] = [3, 5, 7, 9, 11]):
    """Benchmark normalization performance at various depths."""
    import random
    random.seed(42)

    print(f"\n{'Depth':<8} {'Size':<10} {'Norm Size':<12} {'Reduction':<12} {'Time (μs)':<12}")
    print("-" * 54)

    for d in depths:
        e = generate_random_expr(d)
        s_orig = size(e)

        t0 = time.perf_counter()
        ne = normalize(e)
        t1 = time.perf_counter()

        s_norm = size(ne)
        reduction = s_orig - s_norm
        elapsed_us = (t1 - t0) * 1e6

        print(f"{d:<8} {s_orig:<10} {s_norm:<12} {reduction:<12} {elapsed_us:<12.1f}")


if __name__ == "__main__":
    print("Tropical Expression Normalization — Algorithm Suite")
    print("=" * 54)

    # Demo: equivalence checking
    e1 = TMin(Add(Const(1), Const(2)), Add(Const(1), Const(2)))
    e2 = Const(3.0)
    print(f"\nEquivalence check:")
    print(f"  e1 = {pretty(e1)}")
    print(f"  e2 = {pretty(e2)}")
    print(f"  normalize(e1) = {pretty(normalize(e1))}")
    print(f"  normalize(e2) = {pretty(normalize(e2))}")
    print(f"  Equivalent: {semantic_equivalence_check(e1, e2)}")

    # Demo: bound propagation
    e3 = Add(TMin(Var(0), Var(1)), Const(5))
    bounds = {0: 10.0, 1: 8.0}
    print(f"\nBound propagation:")
    print(f"  Expression: {pretty(e3)}")
    print(f"  Variable bounds: x0 ≤ 10, x1 ≤ 8")
    print(f"  Upper bound: {upper_bound(e3, bounds)}")
    print(f"  Upper bound on normalized: {upper_bound(normalize(e3), bounds)}")

    # Benchmark
    print("\nNormalization Benchmarks:")
    benchmark_normalization()
