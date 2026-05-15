"""
Tropical AC Normalization — Algorithms

Complete implementation of the tropical expression canonicalization algorithm
with complexity analysis and benchmarking utilities.
"""
from dataclasses import dataclass
from typing import List, Tuple, Callable, Optional
import time
import random

# ─────────────────────────────────────────
# Data Structures
# ─────────────────────────────────────────

class TropExpr:
    """Abstract base for tropical expression AST nodes."""
    pass

@dataclass(frozen=True)
class Const(TropExpr):
    """Real constant."""
    value: float

@dataclass(frozen=True)
class Var(TropExpr):
    """Variable x_i."""
    index: int

@dataclass(frozen=True)
class TMin(TropExpr):
    """Tropical addition: min(left, right)."""
    left: TropExpr
    right: TropExpr

@dataclass(frozen=True)
class Add(TropExpr):
    """Tropical multiplication: left + right."""
    left: TropExpr
    right: TropExpr


# ─────────────────────────────────────────
# Core Algorithm
# ─────────────────────────────────────────

def expr_size(e: TropExpr) -> int:
    """Count the number of nodes in an expression tree.

    Time: O(n) where n is the tree size.
    Space: O(depth) for recursion stack.
    """
    if isinstance(e, (Const, Var)):
        return 1
    elif isinstance(e, (TMin, Add)):
        return 1 + expr_size(e.left) + expr_size(e.right)
    raise TypeError

def expr_key(e: TropExpr) -> tuple:
    """Compute a sortable canonical key for an expression.

    The key respects structural equality: two structurally identical
    expressions produce the same key.

    Time: O(n) where n is the tree size.
    Space: O(n) for the key tuple.
    """
    if isinstance(e, Const):
        return (0, e.value)
    elif isinstance(e, Var):
        return (1, e.index)
    elif isinstance(e, TMin):
        return (2, expr_key(e.left), expr_key(e.right))
    elif isinstance(e, Add):
        return (3, expr_key(e.left), expr_key(e.right))
    raise TypeError

def flatten_min(e: TropExpr) -> List[TropExpr]:
    """Flatten a tmin-tree into its leaves (non-tmin children).

    Invariants:
    - Output is always nonempty.
    - No element of the output is a TMin node.

    Time: O(n) where n = expr_size(e).
    Space: O(n) for the output list.

    Pseudocode:
        FLATTEN_MIN(e):
            if e is TMin(a, b):
                return FLATTEN_MIN(a) ++ FLATTEN_MIN(b)
            else:
                return [e]
    """
    if isinstance(e, TMin):
        return flatten_min(e.left) + flatten_min(e.right)
    return [e]

def flatten_add(e: TropExpr) -> List[TropExpr]:
    """Flatten an add-tree into its leaves (non-add children).

    Invariants:
    - Output is always nonempty.
    - No element of the output is an Add node.

    Time: O(n) where n = expr_size(e).
    Space: O(n) for the output list.
    """
    if isinstance(e, Add):
        return flatten_add(e.left) + flatten_add(e.right)
    return [e]

def rebuild_min(lst: List[TropExpr]) -> TropExpr:
    """Rebuild a right-associated tmin chain from a nonempty list.

    rebuild_min([a, b, c]) = TMin(a, TMin(b, c))

    Time: O(k) where k = len(lst).
    Space: O(k) for the output tree.
    """
    assert len(lst) >= 1, "Cannot rebuild from empty list"
    if len(lst) == 1:
        return lst[0]
    return TMin(lst[0], rebuild_min(lst[1:]))

def rebuild_add(lst: List[TropExpr]) -> TropExpr:
    """Rebuild a right-associated add chain from a nonempty list.

    rebuild_add([a, b, c]) = Add(a, Add(b, c))

    Time: O(k) where k = len(lst).
    Space: O(k) for the output tree.
    """
    assert len(lst) >= 1, "Cannot rebuild from empty list"
    if len(lst) == 1:
        return lst[0]
    return Add(lst[0], rebuild_add(lst[1:]))

def normalize_ca(e: TropExpr) -> TropExpr:
    """AC-canonicalize a tropical expression.

    Algorithm:
        NORMALIZE(e):
            case Const(r): return Const(r)
            case Var(n): return Var(n)
            case TMin(a, b):
                a' = NORMALIZE(a)
                b' = NORMALIZE(b)
                children = FLATTEN_MIN(a') ++ FLATTEN_MIN(b')
                SORT(children, by=expr_key)
                return REBUILD_MIN(children)
            case Add(a, b):
                a' = NORMALIZE(a)
                b' = NORMALIZE(b)
                children = FLATTEN_ADD(a') ++ FLATTEN_ADD(b')
                SORT(children, by=expr_key)
                return REBUILD_ADD(children)

    Complexity:
        Time: O(N log N) where N = expr_size(e)
              Each node is visited once (O(N)), and sorting at each level
              costs O(k log k) where k is the fan-out. Total sorting cost
              telescopes to O(N log N).
        Space: O(N) for the output tree and intermediate lists.

    Properties (proven in Lean 4):
        1. Soundness: eval(σ, normalize(e)) = eval(σ, e) for all σ
        2. Completeness: ACEquiv(e₁, e₂) → normalize(e₁) = normalize(e₂)
        3. Idempotence: normalize(normalize(e)) = normalize(e)
    """
    if isinstance(e, (Const, Var)):
        return e
    elif isinstance(e, TMin):
        a = normalize_ca(e.left)
        b = normalize_ca(e.right)
        children = flatten_min(a) + flatten_min(b)
        children.sort(key=expr_key)
        return rebuild_min(children)
    elif isinstance(e, Add):
        a = normalize_ca(e.left)
        b = normalize_ca(e.right)
        children = flatten_add(a) + flatten_add(b)
        children.sort(key=expr_key)
        return rebuild_add(children)
    raise TypeError

def eval_expr(sigma: Callable[[int], float], e: TropExpr) -> float:
    """Evaluate a tropical expression.

    Time: O(n) where n = expr_size(e).
    """
    if isinstance(e, Const):
        return e.value
    elif isinstance(e, Var):
        return sigma(e.index)
    elif isinstance(e, TMin):
        return min(eval_expr(sigma, e.left), eval_expr(sigma, e.right))
    elif isinstance(e, Add):
        return eval_expr(sigma, e.left) + eval_expr(sigma, e.right)
    raise TypeError


# ─────────────────────────────────────────
# AC Equivalence Checker
# ─────────────────────────────────────────

def are_ac_equivalent(e1: TropExpr, e2: TropExpr) -> bool:
    """Check if two expressions are AC-equivalent by comparing canonical forms.

    This is the decision procedure certified by the completeness theorem:
        ACEquiv(e₁, e₂) ↔ normalize(e₁) = normalize(e₂)

    Time: O(N log N) where N = max(expr_size(e1), expr_size(e2))
    """
    n1 = normalize_ca(e1)
    n2 = normalize_ca(e2)
    return expr_key(n1) == expr_key(n2)


# ─────────────────────────────────────────
# Benchmarking
# ─────────────────────────────────────────

def random_expr(depth: int, num_vars: int = 4) -> TropExpr:
    """Generate a random expression of given depth."""
    if depth <= 0:
        if random.random() < 0.5:
            return Var(random.randint(0, num_vars - 1))
        else:
            return Const(round(random.uniform(-5, 5), 1))
    op = random.choice([TMin, Add])
    return op(random_expr(depth - 1, num_vars),
              random_expr(depth - 1, num_vars))

def benchmark_normalization(depths: List[int] = None, trials: int = 20):
    """Benchmark normalization performance across expression sizes.

    Returns: list of (depth, avg_size, avg_time_ms) tuples.
    """
    if depths is None:
        depths = list(range(2, 12))

    results = []
    for d in depths:
        sizes = []
        times = []
        for _ in range(trials):
            e = random_expr(d)
            s = expr_size(e)
            t0 = time.perf_counter()
            normalize_ca(e)
            t1 = time.perf_counter()
            sizes.append(s)
            times.append((t1 - t0) * 1000)  # ms

        avg_size = sum(sizes) / len(sizes)
        avg_time = sum(times) / len(times)
        results.append((d, avg_size, avg_time))

    return results


def count_distinct_forms(exprs: List[TropExpr]) -> Tuple[int, int]:
    """Count distinct expression forms before and after normalization.

    Returns: (num_distinct_before, num_distinct_after)
    """
    keys_before = set()
    keys_after = set()
    for e in exprs:
        keys_before.add(expr_key(e))
        keys_after.add(expr_key(normalize_ca(e)))
    return len(keys_before), len(keys_after)


if __name__ == "__main__":
    print("Tropical AC Normalization — Benchmark Results")
    print("=" * 55)

    random.seed(2024)

    results = benchmark_normalization()
    print(f"{'Depth':>6} {'Avg Size':>10} {'Avg Time (ms)':>14}")
    print("-" * 35)
    for depth, size, time_ms in results:
        print(f"{depth:>6} {size:>10.0f} {time_ms:>14.3f}")

    print()
    print("Deduplication Power")
    print("-" * 35)
    for depth in [3, 5, 7]:
        exprs = [random_expr(depth) for _ in range(200)]
        before, after = count_distinct_forms(exprs)
        reduction = (1 - after / before) * 100 if before > 0 else 0
        print(f"Depth {depth}: {before} distinct → {after} after normalization "
              f"({reduction:.1f}% reduction)")
