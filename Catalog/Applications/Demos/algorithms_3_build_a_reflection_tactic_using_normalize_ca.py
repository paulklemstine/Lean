#!/usr/bin/env python3
"""
Tropical ACI Normalization Algorithm
=====================================

Complete implementation of the ACI normalization algorithm for tropical
(min-plus) expressions, with complexity analysis and benchmarking.

Algorithm Overview:
    Input:  A tropical expression tree using min and +
    Output: A canonical normal form such that two expressions are
            ACI-equivalent if and only if their normal forms are identical.

Steps:
    1. Recursively normalize all sub-expressions (bottom-up).
    2. For min nodes: flatten the min-tree into a list, sort by a total
       order on expressions, deduplicate, and rebuild.
    3. For add nodes: flatten the add-tree into a list, sort, and rebuild.

Complexity:
    Let n = number of nodes in the expression tree.
    - Flattening: O(n) per level
    - Sorting: O(k log k) where k = number of leaves in the flattened list
    - Comparison of two expressions: O(m) where m = size of smaller expression
    - Total: O(n² log n) in the worst case (due to nested expression comparison)

    In practice, for expressions where all leaves are variables or small terms,
    the comparison cost is O(1) and the total cost is O(n log n).
"""

from dataclasses import dataclass
from typing import Union, List, Tuple, Dict, Optional
from functools import cmp_to_key
import time
import random


# --- Expression Types ---

@dataclass(frozen=True)
class Var:
    """Variable node."""
    index: int
    def size(self) -> int: return 1
    def depth(self) -> int: return 0
    def __repr__(self): return f"x{self.index}"

@dataclass(frozen=True)
class TMin:
    """Tropical addition (min)."""
    left: 'Expr'
    right: 'Expr'
    def size(self) -> int: return 1 + self.left.size() + self.right.size()
    def depth(self) -> int: return 1 + max(self.left.depth(), self.right.depth())
    def __repr__(self): return f"min({self.left}, {self.right})"

@dataclass(frozen=True)
class TAdd:
    """Tropical multiplication (ordinary addition)."""
    left: 'Expr'
    right: 'Expr'
    def size(self) -> int: return 1 + self.left.size() + self.right.size()
    def depth(self) -> int: return 1 + max(self.left.depth(), self.right.depth())
    def __repr__(self): return f"({self.left} + {self.right})"

Expr = Union[Var, TMin, TAdd]


# --- Core Algorithm ---

def tag(e: Expr) -> int:
    """Constructor tag for ordering: Var < TMin < TAdd."""
    if isinstance(e, Var): return 0
    if isinstance(e, TMin): return 1
    return 2

def cmp_expr(a: Expr, b: Expr) -> int:
    """
    Total order on expressions for canonical sorting.

    Ordering: Var(i) < Var(j) iff i < j
              Var < TMin < TAdd
              Within same constructor: lexicographic on children
    """
    ta, tb = tag(a), tag(b)
    if ta != tb: return -1 if ta < tb else 1
    if isinstance(a, Var):
        return (a.index > b.index) - (a.index < b.index)
    c = cmp_expr(a.left, b.left)
    return c if c != 0 else cmp_expr(a.right, b.right)

expr_key = cmp_to_key(cmp_expr)


def flatten_min(e: Expr) -> List[Expr]:
    """Flatten a min-tree into a list of operands."""
    if isinstance(e, TMin):
        return flatten_min(e.left) + flatten_min(e.right)
    return [e]

def flatten_add(e: Expr) -> List[Expr]:
    """Flatten an add-tree into a list of summands."""
    if isinstance(e, TAdd):
        return flatten_add(e.left) + flatten_add(e.right)
    return [e]

def dedup_sorted(lst: List[Expr]) -> List[Expr]:
    """Remove consecutive duplicates from a sorted list."""
    if not lst: return []
    result = [lst[0]]
    for x in lst[1:]:
        if x != result[-1]:
            result.append(x)
    return result

def build_right_assoc(cls, lst: List[Expr]) -> Expr:
    """Build a right-associated tree from a list."""
    assert lst
    result = lst[-1]
    for x in reversed(lst[:-1]):
        result = cls(x, result)
    return result


def normalize(e: Expr) -> Expr:
    """
    ACI normalization for tropical expressions.

    For min: applies Associativity + Commutativity + Idempotence
    For add: applies Associativity + Commutativity only

    Returns a canonical representative of the ACI equivalence class.

    Pseudocode:
        normalize(Var(n)) = Var(n)
        normalize(TMin(a, b)) =
            let a' = normalize(a), b' = normalize(b)
            let flat = flatten_min(TMin(a', b'))
            let sorted = sort(flat, cmp_expr)
            let deduped = dedup(sorted)
            build_min(deduped)
        normalize(TAdd(a, b)) =
            let a' = normalize(a), b' = normalize(b)
            let flat = flatten_add(TAdd(a', b'))
            let sorted = sort(flat, cmp_expr)
            build_add(sorted)
    """
    if isinstance(e, Var):
        return e
    if isinstance(e, TMin):
        a, b = normalize(e.left), normalize(e.right)
        flat = flatten_min(TMin(a, b))
        flat.sort(key=expr_key)
        flat = dedup_sorted(flat)
        return build_right_assoc(TMin, flat)
    if isinstance(e, TAdd):
        a, b = normalize(e.left), normalize(e.right)
        flat = flatten_add(TAdd(a, b))
        flat.sort(key=expr_key)
        return build_right_assoc(TAdd, flat)
    raise TypeError(f"Unknown expression type: {type(e)}")


def are_aci_equivalent(e1: Expr, e2: Expr) -> bool:
    """
    Decide ACI equivalence by comparing normal forms.

    This is the computational analogue of the certified decision procedure.
    """
    return normalize(e1) == normalize(e2)


# --- Evaluation ---

def evaluate(e: Expr, sigma: Dict[int, float]) -> float:
    """Evaluate expression under variable assignment."""
    if isinstance(e, Var): return sigma[e.index]
    if isinstance(e, TMin): return min(evaluate(e.left, sigma), evaluate(e.right, sigma))
    if isinstance(e, TAdd): return evaluate(e.left, sigma) + evaluate(e.right, sigma)
    raise TypeError


# --- Random Expression Generator ---

def random_expr(num_vars: int, depth: int, p_min: float = 0.5) -> Expr:
    """Generate a random tropical expression."""
    if depth == 0 or random.random() < 0.3:
        return Var(random.randint(0, num_vars - 1))
    if random.random() < p_min:
        return TMin(random_expr(num_vars, depth - 1, p_min),
                    random_expr(num_vars, depth - 1, p_min))
    return TAdd(random_expr(num_vars, depth - 1, p_min),
                random_expr(num_vars, depth - 1, p_min))


def random_aci_permutation(e: Expr) -> Expr:
    """Apply random AC transformations to create an ACI-equivalent expression."""
    if isinstance(e, Var):
        return e
    if isinstance(e, TMin):
        a = random_aci_permutation(e.left)
        b = random_aci_permutation(e.right)
        # Random commutativity
        if random.random() < 0.5:
            a, b = b, a
        # Random associativity reshuffling
        if isinstance(a, TMin) and random.random() < 0.3:
            return TMin(a.left, TMin(a.right, b))
        # Random idempotence (add duplicate)
        if random.random() < 0.2:
            return TMin(TMin(a, b), a)
        return TMin(a, b)
    if isinstance(e, TAdd):
        a = random_aci_permutation(e.left)
        b = random_aci_permutation(e.right)
        if random.random() < 0.5:
            a, b = b, a
        if isinstance(a, TAdd) and random.random() < 0.3:
            return TAdd(a.left, TAdd(a.right, b))
        return TAdd(a, b)
    raise TypeError


# --- Benchmarking ---

def benchmark_normalization(sizes: List[int], trials: int = 100) -> List[dict]:
    """Benchmark normalization performance across expression sizes."""
    results = []
    for depth in sizes:
        times = []
        for _ in range(trials):
            e = random_expr(5, depth)
            start = time.perf_counter()
            normalize(e)
            elapsed = time.perf_counter() - start
            times.append(elapsed)
        avg = sum(times) / len(times)
        results.append({
            'depth': depth,
            'avg_time_ms': avg * 1000,
            'max_time_ms': max(times) * 1000,
            'min_time_ms': min(times) * 1000,
        })
    return results


def verify_soundness(num_tests: int = 10000) -> Tuple[int, int]:
    """
    Verify soundness: if normalize(e1) == normalize(e2),
    then for all sigma, evaluate(e1, sigma) == evaluate(e2, sigma).
    """
    passed = 0
    tested = 0
    for _ in range(num_tests):
        e = random_expr(3, 4)
        e_perm = random_aci_permutation(e)
        tested += 1
        if are_aci_equivalent(e, e_perm):
            # Verify semantically
            sigma = {i: random.uniform(-10, 10) for i in range(5)}
            v1 = evaluate(e, sigma)
            v2 = evaluate(e_perm, sigma)
            if abs(v1 - v2) < 1e-10:
                passed += 1
    return passed, tested


if __name__ == "__main__":
    random.seed(42)

    print("=" * 60)
    print("Tropical ACI Normalization Algorithm")
    print("=" * 60)

    # --- Demo ---
    a, b, c = Var(0), Var(1), Var(2)

    e1 = TMin(TAdd(a, TAdd(b, c)), TAdd(TAdd(c, b), a))
    e2 = TAdd(a, TAdd(b, c))

    print(f"\nExample: min(a+(b+c), (c+b)+a) = a+(b+c)")
    print(f"  LHS normalized: {normalize(e1)}")
    print(f"  RHS normalized: {normalize(e2)}")
    print(f"  ACI equivalent: {are_aci_equivalent(e1, e2)}")

    # --- Soundness Verification ---
    print(f"\nSoundness verification (10000 random tests)...")
    passed, tested = verify_soundness(10000)
    print(f"  {passed}/{tested} tests passed")

    # --- Benchmarks ---
    print(f"\nPerformance benchmarks:")
    print(f"{'Depth':>6} {'Avg (ms)':>10} {'Min (ms)':>10} {'Max (ms)':>10}")
    results = benchmark_normalization([2, 4, 6, 8, 10], trials=200)
    for r in results:
        print(f"{r['depth']:>6} {r['avg_time_ms']:>10.3f} {r['min_time_ms']:>10.3f} {r['max_time_ms']:>10.3f}")
