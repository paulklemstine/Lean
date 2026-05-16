#!/usr/bin/env python3
"""
Algorithms for Parallel Closure Canonicalization of Boolean Conjunction.

Implements the core algorithms from the research paper with full
type hints and documentation.
"""

from typing import Callable, List, Set, Tuple, Dict, Any
import math


# ============================================================
# Core Data Structures
# ============================================================

BoolOp = Callable[[bool], bool]
Predicate = Callable[[int], bool]
PredOp = Callable[[Predicate], Predicate]


# ============================================================
# Algorithm 1: Sequential Conjunction (foldAnd)
# ============================================================

def fold_and(xs: List[bool]) -> bool:
    """
    Sequential left-fold conjunction.

    Computes x₁ ∧ x₂ ∧ ... ∧ xₙ by processing elements left to right.

    Time:  O(n)
    Depth: O(n) (sequential, no parallelism)
    Space: O(1)

    Args:
        xs: List of Boolean values.

    Returns:
        Conjunction of all elements (True if empty).

    Examples:
        >>> fold_and([True, True, True])
        True
        >>> fold_and([True, False, True])
        False
        >>> fold_and([])
        True
    """
    result = True
    for x in xs:
        result = result and x
        if not result:  # Early termination optimization
            return False
    return result


# ============================================================
# Algorithm 2: Balanced Conjunction (balancedAnd)
# ============================================================

def balanced_and(xs: List[bool]) -> bool:
    """
    Balanced (tree-shaped) conjunction with logarithmic depth.

    Recursively splits the list in half and combines results.
    Models a parallel reduction tree.

    Time:  O(n) total work
    Depth: O(log n) parallel time
    Space: O(log n) stack depth

    Args:
        xs: List of Boolean values.

    Returns:
        Conjunction of all elements (True if empty).

    Examples:
        >>> balanced_and([True, True, True])
        True
        >>> balanced_and([True, False, True])
        False
        >>> balanced_and([])
        True
    """
    n = len(xs)
    if n == 0:
        return True
    if n == 1:
        return xs[0]
    mid = n // 2
    left = balanced_and(xs[:mid])
    right = balanced_and(xs[mid:])
    return left and right


# ============================================================
# Algorithm 3: Canonical Conjunction Under Closure
# ============================================================

def canonical_and(op: BoolOp, xs: List[bool], method: str = "balanced") -> bool:
    """
    Compute the canonical closed conjunction O(∧ xs).

    By Theorems A and B, the result is independent of:
    - Evaluation method (sequential vs balanced)
    - Duplicate elements
    - Element ordering

    Args:
        op: Idempotent closure operator on Bool.
        xs: List of Boolean values.
        method: "sequential", "balanced", or "dedup".

    Returns:
        O(foldAnd(xs)) = O(balancedAnd(xs)) = O(foldAnd(dedup(xs)))

    Examples:
        >>> canonical_and(lambda b: b, [True, False, True])
        False
        >>> canonical_and(lambda b: True, [True, False, True])
        True
    """
    if method == "sequential":
        return op(fold_and(xs))
    elif method == "balanced":
        return op(balanced_and(xs))
    elif method == "dedup":
        deduped = list(set(xs))
        return op(fold_and(deduped))
    else:
        raise ValueError(f"Unknown method: {method}")


# ============================================================
# Algorithm 4: Kernel Fixed-Point Finder
# ============================================================

def find_fixed_point(op: BoolOp, b: bool) -> bool:
    """
    Find the unique fixed point in the kernel class of b.

    By Theorem C, O(b) is the unique q such that O(b) = q and O(q) = q.

    Time: O(1) — just one application of O.

    Args:
        op: Idempotent operator.
        b: Input Boolean value.

    Returns:
        The unique fixed point q = O(b).

    Examples:
        >>> find_fixed_point(lambda b: b, True)
        True
        >>> find_fixed_point(lambda b: True, False)
        True
    """
    return op(b)


def find_all_fixed_points(op: BoolOp) -> List[bool]:
    """
    Find all fixed points of a Boolean operator.

    Args:
        op: Operator on Bool.

    Returns:
        List of all b such that O(b) = b.

    Examples:
        >>> find_all_fixed_points(lambda b: b)
        [True, False]
        >>> find_all_fixed_points(lambda b: True)
        [True]
    """
    return [b for b in [True, False] if op(b) == b]


# ============================================================
# Algorithm 5: Predicate Operations
# ============================================================

def pred_meet(p: Predicate, q: Predicate, domain: List[int]) -> Predicate:
    """
    Pointwise meet (conjunction) of two predicates.

    Args:
        p, q: Predicates on the domain.
        domain: Finite domain.

    Returns:
        Predicate r where r(x) = p(x) ∧ q(x).
    """
    values = {x: p(x) and q(x) for x in domain}
    return lambda x: values.get(x, False)


def pred_from_values(values: Dict[int, bool]) -> Predicate:
    """Create a predicate from a dictionary of values."""
    return lambda x: values.get(x, False)


def pred_to_tuple(p: Predicate, domain: List[int]) -> Tuple[bool, ...]:
    """Convert a predicate to a tuple of values over a domain."""
    return tuple(p(x) for x in domain)


# ============================================================
# Algorithm 6: Fixed-Point Semilattice Analysis
# ============================================================

def analyze_fixed_point_semilattice(
    op: PredOp,
    domain: List[int]
) -> Dict[str, Any]:
    """
    Analyze the semilattice structure of fixed points.

    Enumerates all predicates on a finite domain, identifies fixed points,
    and checks closure under meet.

    Args:
        op: Idempotent predicate operator.
        domain: Finite domain.

    Returns:
        Dictionary with analysis results.
    """
    n = len(domain)

    # Enumerate all predicates
    all_preds = []
    for mask in range(2 ** n):
        values = {domain[i]: bool((mask >> i) & 1) for i in range(n)}
        all_preds.append(pred_from_values(values))

    # Find fixed points
    fixed_points = []
    for p in all_preds:
        op_p = op(p)
        if all(p(x) == op_p(x) for x in domain):
            fixed_points.append(p)

    # Check closure under meet
    meet_closed = True
    meet_results = []
    for fp1 in fixed_points:
        for fp2 in fixed_points:
            meet = pred_meet(fp1, fp2, domain)
            closed_meet = op(meet)
            is_fixed = all(closed_meet(x) == op(closed_meet)(x) for x in domain)
            meet_results.append({
                "p": pred_to_tuple(fp1, domain),
                "q": pred_to_tuple(fp2, domain),
                "meet": pred_to_tuple(meet, domain),
                "closed_meet": pred_to_tuple(closed_meet, domain),
                "is_fixed": is_fixed,
            })
            if not is_fixed:
                meet_closed = False

    # Verify Theorem C: unique representatives
    kernel_classes: Dict[Tuple[bool, ...], List[Tuple[bool, ...]]] = {}
    for p in all_preds:
        key = pred_to_tuple(op(p), domain)
        val = pred_to_tuple(p, domain)
        kernel_classes.setdefault(key, []).append(val)

    unique_reps = all(
        sum(1 for v in members
            if pred_to_tuple(op(pred_from_values({domain[i]: v[i] for i in range(n)})), domain) == v)
        == 1
        for members in kernel_classes.values()
    )

    return {
        "domain_size": n,
        "total_predicates": len(all_preds),
        "num_fixed_points": len(fixed_points),
        "fixed_points": [pred_to_tuple(fp, domain) for fp in fixed_points],
        "meet_closed": meet_closed,
        "meet_results": meet_results,
        "num_kernel_classes": len(kernel_classes),
        "unique_representatives": unique_reps,
    }


# ============================================================
# Algorithm 7: Depth Analysis
# ============================================================

def compute_depths(max_n: int = 20) -> List[Dict[str, Any]]:
    """
    Compare sequential vs balanced conjunction depths.

    Args:
        max_n: Maximum list size to analyze.

    Returns:
        List of depth comparison records.
    """
    results = []
    for n in range(1, max_n + 1):
        seq_depth = n
        bal_depth = math.ceil(math.log2(n)) if n > 1 else (0 if n == 0 else 0)
        # More precise: actual recursion depth
        bal_depth_actual = _balanced_depth(n)
        results.append({
            "n": n,
            "sequential_depth": seq_depth,
            "balanced_depth": bal_depth_actual,
            "speedup": seq_depth / bal_depth_actual if bal_depth_actual > 0 else float('inf'),
        })
    return results


def _balanced_depth(n: int) -> int:
    """Compute exact recursion depth of balanced_and."""
    if n <= 1:
        return 0
    mid = n // 2
    return 1 + max(_balanced_depth(mid), _balanced_depth(n - mid))


if __name__ == "__main__":
    # Quick self-test
    print("Testing algorithms...")

    # Test fold_and and balanced_and agree
    import random
    random.seed(42)
    for _ in range(1000):
        xs = [random.choice([True, False]) for _ in range(random.randint(0, 100))]
        assert fold_and(xs) == balanced_and(xs), f"Mismatch on {xs}"

    # Test canonical_and methods agree
    ops = [lambda b: b, lambda b: True, lambda b: False]
    for op in ops:
        for _ in range(100):
            xs = [random.choice([True, False]) for _ in range(random.randint(0, 50))]
            results = [canonical_and(op, xs, m) for m in ["sequential", "balanced", "dedup"]]
            assert len(set(results)) == 1, f"Method disagreement: {results}"

    # Test fixed point analysis
    domain = [0, 1]
    identity_op = lambda p: p
    result = analyze_fixed_point_semilattice(identity_op, domain)
    assert result["num_fixed_points"] == result["total_predicates"]  # all fixed under id

    print("All tests passed ✓")

    # Show depth comparison
    print("\nDepth comparison:")
    for r in compute_depths(15):
        print(f"  n={r['n']:>3}: seq={r['sequential_depth']:>3}, "
              f"bal={r['balanced_depth']:>2}, speedup={r['speedup']:.1f}x")
