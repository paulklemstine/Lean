#!/usr/bin/env python3
"""
Tropical AC Normalization — Algorithm Implementations

Complete implementation of the AC canonicalization procedure for tropical expressions,
with complexity analysis and testing infrastructure.
"""
from dataclasses import dataclass
from typing import Union, Callable, List, Tuple
import functools
import time

# ============================================================
# Core Types
# ============================================================

@dataclass(frozen=True)
class Const:
    """Constant tropical expression."""
    value: float

@dataclass(frozen=True)
class Var:
    """Variable tropical expression."""
    index: int

@dataclass(frozen=True)
class TMin:
    """Tropical minimum (binary)."""
    left: 'TropExpr'
    right: 'TropExpr'

@dataclass(frozen=True)
class Add:
    """Tropical addition (binary)."""
    left: 'TropExpr'
    right: 'TropExpr'

TropExpr = Union[Const, Var, TMin, Add]

# ============================================================
# Algorithm 1: Evaluation
# ============================================================

def eval_expr(sigma: Callable[[int], float], e: TropExpr) -> float:
    """Evaluate a tropical expression under environment sigma.
    
    Time: O(n) where n is the number of nodes.
    Space: O(d) where d is the depth (recursion stack).
    """
    if isinstance(e, Const): return e.value
    if isinstance(e, Var): return sigma(e.index)
    if isinstance(e, TMin): return min(eval_expr(sigma, e.left), eval_expr(sigma, e.right))
    if isinstance(e, Add): return eval_expr(sigma, e.left) + eval_expr(sigma, e.right)

# ============================================================
# Algorithm 2: Total Order Comparison
# ============================================================

def _tag(e: TropExpr) -> int:
    """Constructor tag for ordering: const=0 < var=1 < tmin=2 < add=3."""
    if isinstance(e, Const): return 0
    if isinstance(e, Var): return 1
    if isinstance(e, TMin): return 2
    return 3

def ble(a: TropExpr, b: TropExpr) -> bool:
    """Total order comparison on TropExpr.
    
    Lexicographic by constructor tag, then recursively by components.
    Satisfies: totality, antisymmetry, transitivity.
    
    Time: O(min(|a|, |b|)) in the worst case.
    """
    ta, tb = _tag(a), _tag(b)
    if ta != tb: return ta < tb
    if isinstance(a, Const): return a.value <= b.value
    if isinstance(a, Var): return a.index <= b.index
    # TMin or Add: lexicographic on children
    if a.left == b.left: return ble(a.right, b.right)
    return ble(a.left, b.left)

# ============================================================
# Algorithm 3: Flattening
# ============================================================

def flatten_min(e: TropExpr) -> List[TropExpr]:
    """Flatten a tmin-tree into a list of non-tmin children.
    
    Time: O(n).
    Invariant: output is nonempty; no element is TMin.
    """
    if isinstance(e, TMin):
        return flatten_min(e.left) + flatten_min(e.right)
    return [e]

def flatten_add(e: TropExpr) -> List[TropExpr]:
    """Flatten an add-tree into a list of non-add children.
    
    Time: O(n).
    Invariant: output is nonempty; no element is Add.
    """
    if isinstance(e, Add):
        return flatten_add(e.left) + flatten_add(e.right)
    return [e]

# ============================================================
# Algorithm 4: Rebuilding
# ============================================================

def rebuild_min(lst: List[TropExpr]) -> TropExpr:
    """Build a right-associated tmin tree from a nonempty list.
    
    Time: O(k) where k = len(lst).
    """
    assert lst, "rebuild_min requires nonempty list"
    if len(lst) == 1: return lst[0]
    return TMin(lst[0], rebuild_min(lst[1:]))

def rebuild_add(lst: List[TropExpr]) -> TropExpr:
    """Build a right-associated add tree from a nonempty list.
    
    Time: O(k) where k = len(lst).
    """
    assert lst, "rebuild_add requires nonempty list"
    if len(lst) == 1: return lst[0]
    return Add(lst[0], rebuild_add(lst[1:]))

# ============================================================
# Algorithm 5: Sorting
# ============================================================

def sort_exprs(lst: List[TropExpr]) -> List[TropExpr]:
    """Sort expressions by the total order ble.
    
    Time: O(k log k) where k = len(lst).
    Uses Python's Timsort via a comparison key.
    """
    return sorted(lst, key=functools.cmp_to_key(
        lambda a, b: -1 if (ble(a, b) and a != b) else (0 if a == b else 1)
    ))

# ============================================================
# Algorithm 6: AC Normalizer
# ============================================================

def normalize_ca(e: TropExpr) -> TropExpr:
    """Normalize a tropical expression w.r.t. associativity and commutativity.
    
    Flattens same-headed operation trees, sorts children by ble,
    and rebuilds right-associated canonical trees.
    
    Time: O(n log n) where n = |e|.
    Space: O(n).
    
    Certified properties (proved in Lean 4):
      1. Soundness:    eval(σ, normalize_ca(e)) = eval(σ, e)
      2. Completeness:  ACEquiv(e₁, e₂) → normalize_ca(e₁) = normalize_ca(e₂)
      3. Idempotence:   normalize_ca(normalize_ca(e)) = normalize_ca(e)
    """
    if isinstance(e, (Const, Var)):
        return e
    if isinstance(e, TMin):
        a = normalize_ca(e.left)
        b = normalize_ca(e.right)
        children = flatten_min(a) + flatten_min(b)
        return rebuild_min(sort_exprs(children))
    if isinstance(e, Add):
        a = normalize_ca(e.left)
        b = normalize_ca(e.right)
        children = flatten_add(a) + flatten_add(b)
        return rebuild_add(sort_exprs(children))

# ============================================================
# Algorithm 7: AC Equivalence Decision
# ============================================================

def ac_equiv(e1: TropExpr, e2: TropExpr) -> bool:
    """Decide whether two tropical expressions are AC-equivalent.
    
    Time: O((n₁ + n₂) log(n₁ + n₂)).
    Correct by the completeness theorem.
    """
    return normalize_ca(e1) == normalize_ca(e2)

# ============================================================
# Expression size and random generation for benchmarking
# ============================================================

def expr_size(e: TropExpr) -> int:
    """Count the number of nodes in an expression."""
    if isinstance(e, (Const, Var)): return 1
    return 1 + expr_size(e.left) + expr_size(e.right)

def random_expr(depth: int, num_vars: int = 5) -> TropExpr:
    """Generate a random tropical expression of given depth."""
    import random
    if depth <= 0:
        if random.random() < 0.5:
            return Const(random.randint(-10, 10))
        return Var(random.randint(0, num_vars - 1))
    op = random.choice([TMin, Add])
    return op(random_expr(depth - 1, num_vars), random_expr(depth - 1, num_vars))

# ============================================================
# Benchmarking
# ============================================================

def benchmark():
    """Benchmark normalization on random expressions of increasing size."""
    import random
    random.seed(42)
    
    print("Benchmarking normalize_ca:")
    print(f"{'Depth':>6} {'Size':>8} {'Time (ms)':>10} {'Norm Size':>10}")
    print("-" * 40)
    
    for depth in range(1, 12):
        e = random_expr(depth)
        sz = expr_size(e)
        
        start = time.perf_counter()
        n = normalize_ca(e)
        elapsed = (time.perf_counter() - start) * 1000
        
        nsz = expr_size(n)
        
        # Verify soundness
        sigma = lambda i: float(i + 1)
        assert abs(eval_expr(sigma, e) - eval_expr(sigma, n)) < 1e-10
        
        # Verify idempotence
        assert normalize_ca(n) == n
        
        print(f"{depth:>6} {sz:>8} {elapsed:>10.2f} {nsz:>10}")

if __name__ == "__main__":
    benchmark()
