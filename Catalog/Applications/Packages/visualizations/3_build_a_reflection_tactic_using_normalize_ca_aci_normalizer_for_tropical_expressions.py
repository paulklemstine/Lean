#!/usr/bin/env python3
"""
algorithms.py — Tropical ACI Normalization Algorithm

Implements the certified normalization algorithm for tropical (min-plus) expressions
with full pseudocode, complexity analysis, and example usage.

Algorithm: ACI Normalizer for Tropical Expressions
  - Time: O(n log n) where n is the expression size
  - Space: O(n) for the flattened representation

The algorithm handles three symmetries:
  - Associativity of min and + (flattening)
  - Commutativity of min and + (sorting)
  - Idempotence of min (deduplication)
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Union, List, Tuple, Optional
import time


# ============================================================
# Expression AST
# ============================================================

@dataclass(frozen=True)
class Var:
    """Variable indexed by natural number."""
    index: int

@dataclass(frozen=True)
class TMin:
    """Tropical addition: min(a, b)."""
    left: 'Expr'
    right: 'Expr'

@dataclass(frozen=True)
class TAdd:
    """Tropical multiplication: a + b."""
    left: 'Expr'
    right: 'Expr'

Expr = Union[Var, TMin, TAdd]


# ============================================================
# Algorithm 1: Expression Size
# ============================================================

def size(e: Expr) -> int:
    """
    Compute the size of a tropical expression (number of nodes).

    Time: O(n), Space: O(depth) for recursion stack
    """
    if isinstance(e, Var):
        return 1
    return 1 + size(e.left) + size(e.right)


# ============================================================
# Algorithm 2: Canonical Comparison
# ============================================================

def _tag(e: Expr) -> int:
    """Assign integer tags: Var=0, TMin=1, TAdd=2."""
    if isinstance(e, Var): return 0
    if isinstance(e, TMin): return 1
    return 2

def compare(e1: Expr, e2: Expr) -> int:
    """
    Total order comparison on expressions.

    Returns: -1 (less), 0 (equal), 1 (greater)

    Pseudocode:
      COMPARE(e1, e2):
        if tag(e1) != tag(e2): return compare_int(tag(e1), tag(e2))
        if e1 is Var(n1), e2 is Var(n2): return compare_int(n1, n2)
        // both are TMin or both are TAdd
        c = COMPARE(e1.left, e2.left)
        if c != 0: return c
        return COMPARE(e1.right, e2.right)

    Time: O(min(|e1|, |e2|)), Space: O(depth)
    """
    t1, t2 = _tag(e1), _tag(e2)
    if t1 != t2:
        return -1 if t1 < t2 else 1
    if isinstance(e1, Var) and isinstance(e2, Var):
        if e1.index < e2.index: return -1
        if e1.index > e2.index: return 1
        return 0
    c = compare(e1.left, e2.left)
    if c != 0: return c
    return compare(e1.right, e2.right)


def expr_sort_key(e: Expr):
    """Generate a sort key for Python's sorted()."""
    if isinstance(e, Var):
        return (0, e.index)
    elif isinstance(e, TMin):
        return (1, expr_sort_key(e.left), expr_sort_key(e.right))
    else:
        return (2, expr_sort_key(e.left), expr_sort_key(e.right))


# ============================================================
# Algorithm 3: Flatten
# ============================================================

def flatten_min(e: Expr) -> List[Expr]:
    """
    Flatten nested min into a flat list of summands.

    Pseudocode:
      FLATTEN_MIN(e):
        if e = TMin(a, b):
          return FLATTEN_MIN(a) ++ FLATTEN_MIN(b)
        else:
          return [e]

    Time: O(n), Space: O(n) for the output list

    Invariant: No element of the output is a TMin node.
    """
    if isinstance(e, TMin):
        return flatten_min(e.left) + flatten_min(e.right)
    return [e]


def flatten_add(e: Expr) -> List[Expr]:
    """
    Flatten nested add into a flat list of factors.

    Pseudocode: Symmetric to FLATTEN_MIN.

    Time: O(n), Space: O(n)
    Invariant: No element of the output is a TAdd node.
    """
    if isinstance(e, TAdd):
        return flatten_add(e.left) + flatten_add(e.right)
    return [e]


# ============================================================
# Algorithm 4: Deduplication
# ============================================================

def dedup(lst: List[Expr]) -> List[Expr]:
    """
    Remove consecutive duplicates from a sorted list.

    Pseudocode:
      DEDUP(l):
        if l is empty: return []
        result = [l[0]]
        for i = 1 to |l|-1:
          if l[i] != result.last:
            result.append(l[i])
        return result

    Time: O(n * comparison_cost), Space: O(n)

    This implements idempotence of min: min(a, a) = a.
    After sorting, duplicates are adjacent, so one pass suffices.
    """
    if not lst:
        return []
    result = [lst[0]]
    for x in lst[1:]:
        if x != result[-1]:
            result.append(x)
    return result


# ============================================================
# Algorithm 5: Build (Reconstitution)
# ============================================================

def build_min(lst: List[Expr]) -> Expr:
    """
    Build a right-associated min chain from a nonempty list.

    Pseudocode:
      BUILD_MIN([e]):        return e
      BUILD_MIN(e :: rest):  return TMin(e, BUILD_MIN(rest))

    Time: O(n), Space: O(n)
    """
    assert lst, "build_min requires nonempty list"
    if len(lst) == 1:
        return lst[0]
    return TMin(lst[0], build_min(lst[1:]))


def build_add(lst: List[Expr]) -> Expr:
    """Build a right-associated add chain. Symmetric to build_min."""
    assert lst, "build_add requires nonempty list"
    if len(lst) == 1:
        return lst[0]
    return TAdd(lst[0], build_add(lst[1:]))


# ============================================================
# Algorithm 6: The Full ACI Normalizer
# ============================================================

def normalize(e: Expr) -> Expr:
    """
    ACI normalizer for tropical expressions.

    Pseudocode:
      NORMALIZE(Var(n)):      return Var(n)
      NORMALIZE(TMin(a, b)):
        a' = NORMALIZE(a)
        b' = NORMALIZE(b)
        flat = FLATTEN_MIN(TMin(a', b'))
        sorted = MERGE_SORT(flat, COMPARE)
        deduped = DEDUP(sorted)
        return BUILD_MIN(deduped)
      NORMALIZE(TAdd(a, b)):
        a' = NORMALIZE(a)
        b' = NORMALIZE(b)
        flat = FLATTEN_ADD(TAdd(a', b'))
        sorted = MERGE_SORT(flat, COMPARE)
        return BUILD_ADD(sorted)

    Complexity Analysis:
      Let n = |e| (number of nodes in the expression tree).
      - Recursive normalization: visits each node once → O(n) calls
      - At each TMin/TAdd node, flatten produces a list whose total size
        across all nodes is O(n) (each leaf appears exactly once)
      - Sorting: O(k log k) where k is the list length at that node
      - Across all nodes, total sorting work is O(n log n) by the
        standard divide-and-conquer argument
      - Dedup and build are O(k) per node

      Total: O(n log n) time, O(n) space.

    Correctness:
      - Flattening undoes associativity differences
      - Sorting undoes commutativity differences
      - Dedup undoes idempotence differences
      - Building reconstitutes a canonical tree form

      Therefore: normalize(e1) == normalize(e2) iff e1 and e2 are
      ACI-equivalent (for min) and AC-equivalent (for +).
    """
    if isinstance(e, Var):
        return e
    elif isinstance(e, TMin):
        a = normalize(e.left)
        b = normalize(e.right)
        flat = flatten_min(TMin(a, b))
        flat.sort(key=expr_sort_key)
        flat = dedup(flat)
        return build_min(flat)
    elif isinstance(e, TAdd):
        a = normalize(e.left)
        b = normalize(e.right)
        flat = flatten_add(TAdd(a, b))
        flat.sort(key=expr_sort_key)
        return build_add(flat)
    raise TypeError(f"Unknown expression type: {type(e)}")


# ============================================================
# Algorithm 7: Equality Decision Procedure
# ============================================================

def are_tropically_equal(e1: Expr, e2: Expr) -> bool:
    """
    Decision procedure for ACI equivalence of tropical expressions.

    Pseudocode:
      ARE_EQUAL(e1, e2):
        return NORMALIZE(e1) == NORMALIZE(e2)

    Time: O(n log n) where n = max(|e1|, |e2|)
    Space: O(n)

    Soundness: If this returns True, then for all σ: ℕ → ℝ,
               eval(e1, σ) = eval(e2, σ).
    """
    return normalize(e1) == normalize(e2)


# ============================================================
# Pretty Printing
# ============================================================

def pretty(e: Expr) -> str:
    """Human-readable expression representation."""
    if isinstance(e, Var):
        return chr(ord('a') + e.index) if e.index < 26 else f"x{e.index}"
    elif isinstance(e, TMin):
        return f"min({pretty(e.left)}, {pretty(e.right)})"
    elif isinstance(e, TAdd):
        return f"({pretty(e.left)} + {pretty(e.right)})"
    return str(e)


# ============================================================
# Evaluation
# ============================================================

def evaluate(e: Expr, sigma: dict) -> float:
    """Evaluate expression with variable assignment."""
    if isinstance(e, Var):
        return sigma.get(e.index, 0.0)
    elif isinstance(e, TMin):
        return min(evaluate(e.left, sigma), evaluate(e.right, sigma))
    elif isinstance(e, TAdd):
        return evaluate(e.left, sigma) + evaluate(e.right, sigma)
    raise TypeError


# ============================================================
# Benchmarking
# ============================================================

def benchmark():
    """Benchmark the normalizer on expressions of increasing size."""
    import random
    random.seed(42)

    def random_expr(depth: int, num_vars: int = 4) -> Expr:
        if depth <= 0:
            return Var(random.randint(0, num_vars - 1))
        op = random.choice(['min', 'add'])
        left = random_expr(depth - 1, num_vars)
        right = random_expr(depth - 1, num_vars)
        if op == 'min':
            return TMin(left, right)
        return TAdd(left, right)

    print("\nBENCHMARK: Normalization Performance")
    print("-" * 50)
    print(f"{'Depth':>6} {'Size':>8} {'Time (ms)':>12} {'Norm Size':>10}")
    print("-" * 50)

    for depth in range(1, 13):
        e = random_expr(depth)
        s = size(e)
        start = time.perf_counter()
        n = normalize(e)
        elapsed = (time.perf_counter() - start) * 1000
        ns = size(n)
        print(f"{depth:>6} {s:>8} {elapsed:>12.3f} {ns:>10}")


if __name__ == "__main__":
    # Demo: verify all identities
    a, b, c, d, e, f = [Var(i) for i in range(6)]

    identities = [
        ("AC collapse", TMin(TAdd(a, TAdd(b, c)), TAdd(TAdd(c, b), a)), TAdd(a, TAdd(b, c))),
        ("Idempotence", TMin(a, a), a),
        ("Dedup + comm", TMin(TAdd(a, b), TMin(TAdd(a, b), c)), TMin(c, TAdd(a, b))),
        ("Six-var", TMin(TMin(TAdd(a, b), TMin(TAdd(c, d), TAdd(e, f))),
                        TMin(TAdd(f, e), TMin(TAdd(d, c), TAdd(b, a)))),
                   TMin(TAdd(a, b), TMin(TAdd(c, d), TAdd(e, f)))),
    ]

    print("IDENTITY VERIFICATION")
    print("-" * 50)
    for name, lhs, rhs in identities:
        result = are_tropically_equal(lhs, rhs)
        print(f"  {name:.<30} {'✓' if result else '✗'}")

    benchmark()
