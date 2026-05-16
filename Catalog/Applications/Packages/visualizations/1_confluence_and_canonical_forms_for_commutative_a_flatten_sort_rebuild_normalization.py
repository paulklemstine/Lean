#!/usr/bin/env python3
"""
Tropical AC Canonical Forms: Algorithms

Implements the core normalization algorithm with detailed pseudocode
and complexity analysis.
"""

from typing import List, Tuple, Optional, Callable
from dataclasses import dataclass
from enum import Enum, auto
import time


# ============================================================
# Algorithm 1: Tropical Expression Comparison (Total Order)
# ============================================================
# 
# PSEUDOCODE:
#   function CMP(e1, e2):
#     if tag(e1) < tag(e2): return LT
#     if tag(e1) > tag(e2): return GT
#     -- same constructor:
#     case (Const r1, Const r2): return compare(r1, r2)
#     case (Var n1, Var n2): return compare(n1, n2)
#     case (Op a1 b1, Op a2 b2):  -- tmin or add
#       c = CMP(a1, a2)
#       if c ≠ EQ: return c
#       return CMP(b1, b2)
#
# TIME COMPLEXITY: O(min(|e1|, |e2|)) worst case
# SPACE COMPLEXITY: O(depth) for recursion stack


# ============================================================
# Algorithm 2: Flatten-Sort-Rebuild Normalization
# ============================================================
#
# PSEUDOCODE:
#   function NORMALIZE(e):
#     case Const(r): return Const(r)
#     case Var(n): return Var(n)
#     case TMin(a, b):
#       a' = NORMALIZE(a)
#       b' = NORMALIZE(b)
#       children = FLATTEN_MIN(TMin(a', b'))
#       sorted = MERGE_SORT(children, CMP)
#       return BUILD_MIN(sorted)
#     case Add(a, b):
#       a' = NORMALIZE(a)
#       b' = NORMALIZE(b)
#       children = FLATTEN_ADD(Add(a', b'))
#       sorted = MERGE_SORT(children, CMP)
#       return BUILD_ADD(sorted)
#
#   function FLATTEN_MIN(e):
#     case TMin(a, b): return FLATTEN_MIN(a) ++ FLATTEN_MIN(b)
#     otherwise: return [e]
#
#   function BUILD_MIN([e]): return e
#   function BUILD_MIN(e :: rest): return TMin(e, BUILD_MIN(rest))
#
# TIME COMPLEXITY: O(n log²n) where n = |e|
#   - Each level does O(k log k) for sorting k children
#   - Total across all levels: O(n log n) for flattening,
#     O(n log n) for each comparison during sort × O(log n) levels
#
# SPACE COMPLEXITY: O(n) for the flattened lists


# --- Implementation ---

class Tag(Enum):
    CONST = 0
    VAR = 1
    TMIN = 2
    ADD = 3


@dataclass(frozen=True)
class Expr:
    """Base class for tropical expressions."""
    pass


@dataclass(frozen=True) 
class Const(Expr):
    value: float
    def __repr__(self): return f"{self.value}"


@dataclass(frozen=True)
class Var(Expr):
    index: int
    def __repr__(self): return f"x{self.index}"


@dataclass(frozen=True)
class TMin(Expr):
    left: Expr
    right: Expr
    def __repr__(self): return f"min({self.left}, {self.right})"


@dataclass(frozen=True)
class Add(Expr):
    left: Expr
    right: Expr
    def __repr__(self): return f"({self.left} + {self.right})"


def expr_tag(e: Expr) -> int:
    if isinstance(e, Const): return 0
    if isinstance(e, Var): return 1
    if isinstance(e, TMin): return 2
    if isinstance(e, Add): return 3
    return -1


def expr_cmp(e1: Expr, e2: Expr) -> int:
    """Compare two expressions. Returns -1, 0, or 1."""
    t1, t2 = expr_tag(e1), expr_tag(e2)
    if t1 != t2:
        return -1 if t1 < t2 else 1
    if isinstance(e1, Const):
        return -1 if e1.value < e2.value else (0 if e1.value == e2.value else 1)
    if isinstance(e1, Var):
        return -1 if e1.index < e2.index else (0 if e1.index == e2.index else 1)
    if isinstance(e1, (TMin, Add)):
        c = expr_cmp(e1.left, e2.left)
        return c if c != 0 else expr_cmp(e1.right, e2.right)
    return 0


def flatten_min(e: Expr) -> List[Expr]:
    """Flatten a tmin tree into a list of non-tmin children."""
    if isinstance(e, TMin):
        return flatten_min(e.left) + flatten_min(e.right)
    return [e]


def flatten_add(e: Expr) -> List[Expr]:
    """Flatten an add tree into a list of non-add children."""
    if isinstance(e, Add):
        return flatten_add(e.left) + flatten_add(e.right)
    return [e]


def build_min(exprs: List[Expr]) -> Expr:
    """Build a right-associated min chain from a nonempty list."""
    if len(exprs) == 1:
        return exprs[0]
    return TMin(exprs[0], build_min(exprs[1:]))


def build_add(exprs: List[Expr]) -> Expr:
    """Build a right-associated add chain from a nonempty list."""
    if len(exprs) == 1:
        return exprs[0]
    return Add(exprs[0], build_add(exprs[1:]))


from functools import cmp_to_key
_sort_key = cmp_to_key(expr_cmp)


def normalize_ca(e: Expr) -> Expr:
    """
    Normalize a tropical expression for AC equivalence.
    
    Algorithm: Flatten-Sort-Rebuild
    1. Recursively normalize children
    2. Flatten same-head operator trees into lists
    3. Sort lists using the total order
    4. Rebuild right-associated trees
    
    Returns the canonical representative of the AC equivalence class of e.
    """
    if isinstance(e, (Const, Var)):
        return e
    if isinstance(e, TMin):
        a = normalize_ca(e.left)
        b = normalize_ca(e.right)
        children = flatten_min(TMin(a, b))
        children.sort(key=_sort_key)
        return build_min(children)
    if isinstance(e, Add):
        a = normalize_ca(e.left)
        b = normalize_ca(e.right)
        children = flatten_add(Add(a, b))
        children.sort(key=_sort_key)
        return build_add(children)
    raise ValueError(f"Unknown expression type: {type(e)}")


def expr_size(e: Expr) -> int:
    """Count the number of nodes in an expression."""
    if isinstance(e, (Const, Var)):
        return 1
    if isinstance(e, (TMin, Add)):
        return 1 + expr_size(e.left) + expr_size(e.right)
    return 0


def evaluate(e: Expr, env: Callable[[int], float]) -> float:
    """Evaluate a tropical expression."""
    if isinstance(e, Const): return e.value
    if isinstance(e, Var): return env(e.index)
    if isinstance(e, TMin): return min(evaluate(e.left, env), evaluate(e.right, env))
    if isinstance(e, Add): return evaluate(e.left, env) + evaluate(e.right, env)
    raise ValueError


# --- Benchmarking ---

import random

def random_expr(depth: int, num_vars: int = 5) -> Expr:
    """Generate a random tropical expression of given depth."""
    if depth <= 0:
        if random.random() < 0.3:
            return Const(random.uniform(-10, 10))
        return Var(random.randint(0, num_vars - 1))
    op = random.choice([TMin, Add])
    return op(random_expr(depth - 1, num_vars), random_expr(depth - 1, num_vars))


def benchmark():
    """Benchmark normalization on random expressions."""
    print("Benchmarking normalization...")
    print(f"{'Depth':>6} {'Size':>8} {'Time (ms)':>12} {'Norm Size':>10}")
    print("-" * 40)
    
    random.seed(42)
    for depth in range(1, 10):
        e = random_expr(depth)
        size = expr_size(e)
        
        start = time.perf_counter()
        n = normalize_ca(e)
        elapsed = (time.perf_counter() - start) * 1000
        
        norm_size = expr_size(n)
        print(f"{depth:>6} {size:>8} {elapsed:>12.3f} {norm_size:>10}")
    
    print()


if __name__ == "__main__":
    benchmark()
    
    # Verify soundness on random examples
    print("Verifying soundness on 1000 random expressions...")
    random.seed(123)
    all_ok = True
    for _ in range(1000):
        e = random_expr(random.randint(1, 6))
        n = normalize_ca(e)
        env = lambda i, v=[random.uniform(-10, 10) for _ in range(10)]: v[i] if i < len(v) else 0
        if abs(evaluate(e, env) - evaluate(n, env)) > 1e-10:
            all_ok = False
            break
    print(f"  Result: {'PASS' if all_ok else 'FAIL'}")
    
    # Verify idempotence
    print("Verifying idempotence on 1000 random expressions...")
    random.seed(456)
    all_ok = True
    for _ in range(1000):
        e = random_expr(random.randint(1, 6))
        n1 = normalize_ca(e)
        n2 = normalize_ca(n1)
        if n1 != n2:
            all_ok = False
            break
    print(f"  Result: {'PASS' if all_ok else 'FAIL'}")
