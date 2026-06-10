"""
Closure–Extractor Duality: Core Algorithms

Implements the key algorithms from the closure–extractor duality framework:
1. Closure operator construction and manipulation
2. Closed set enumeration
3. Deficiency and entropy surrogate computation
4. Closure-stable predicate synthesis
5. Extractor reconstruction from evaluation matrices
6. Separation verification
"""

from __future__ import annotations
from typing import Callable, FrozenSet, List, Set, Tuple, Dict
from itertools import combinations
import numpy as np


# --- Closure Operator Infrastructure ---

class ClosureOperator:
    """A closure operator on a finite ground set.

    Attributes:
        ground_set: The finite ground set X.
        cl: The closure function mapping frozensets to frozensets.
    """

    def __init__(self, ground_set: Set[int], cl: Callable[[FrozenSet[int]], FrozenSet[int]]):
        self.ground_set = frozenset(ground_set)
        self._cl = cl
        self._validate()

    def _validate(self):
        """Verify closure axioms on small subsets."""
        for x in self.ground_set:
            s = frozenset([x])
            assert s <= self.cl(s), f"Extensivity violated for {s}"

    def cl(self, A: FrozenSet[int]) -> FrozenSet[int]:
        """Compute the closure of a set."""
        return self._cl(A)

    def is_closed(self, C: FrozenSet[int]) -> bool:
        """Check if a set is closed (fixed point of cl)."""
        return self.cl(C) == C

    def deficiency(self, A: FrozenSet[int]) -> int:
        """Compute deficiency: |cl(A)| - |A|."""
        return len(self.cl(A)) - len(A)

    def entropy_surrogate(self, A: FrozenSet[int]) -> int:
        """Compute entropy surrogate: |X| - deficiency(A)."""
        return len(self.ground_set) - self.deficiency(A)

    def closed_sets(self) -> List[FrozenSet[int]]:
        """Enumerate all closed subsets of the ground set."""
        result = []
        n = len(self.ground_set)
        elements = sorted(self.ground_set)
        for r in range(n + 1):
            for subset in combinations(elements, r):
                s = frozenset(subset)
                if self.is_closed(s):
                    result.append(s)
        # Also check the empty set
        empty = frozenset()
        if self.is_closed(empty) and empty not in result:
            result.insert(0, empty)
        return result

    def large_closed_sets(self, k: int) -> List[FrozenSet[int]]:
        """Return all closed sets of size >= k."""
        return [C for C in self.closed_sets() if len(C) >= k]

    def closure_equiv(self, x: int, y: int) -> bool:
        """Check if x and y are closure-equivalent: cl({x}) == cl({y})."""
        return self.cl(frozenset([x])) == self.cl(frozenset([y]))


# --- Standard Closure Operator Constructors ---

def discrete_closure(ground_set: Set[int]) -> ClosureOperator:
    """The discrete closure: cl(A) = A for all A (identity)."""
    return ClosureOperator(ground_set, lambda A: A)


def partition_closure(ground_set: Set[int], partition: List[Set[int]]) -> ClosureOperator:
    """Partition closure: cl(A) = union of all blocks intersecting A."""
    blocks = [frozenset(b) for b in partition]

    def cl(A: FrozenSet[int]) -> FrozenSet[int]:
        result = set(A)
        for b in blocks:
            if A & b:
                result |= b
        return frozenset(result)

    return ClosureOperator(ground_set, cl)


def convex_closure_1d(ground_set: Set[int]) -> ClosureOperator:
    """1D convex closure: cl(A) = [min(A), max(A)] ∩ ground_set."""
    elements = sorted(ground_set)

    def cl(A: FrozenSet[int]) -> FrozenSet[int]:
        if not A:
            return frozenset()
        lo, hi = min(A), max(A)
        return frozenset(x for x in elements if lo <= x <= hi)

    return ClosureOperator(ground_set, cl)


def linear_closure_f2(n: int) -> ClosureOperator:
    """Linear closure over F_2^n: cl(A) = span(A) as vectors over F_2.

    Ground set is {0, 1, ..., 2^n - 1} representing binary vectors.
    """
    ground_set = set(range(2**n))

    def span_f2(A: FrozenSet[int]) -> FrozenSet[int]:
        """Compute the F_2-span of a set of integers (as binary vectors)."""
        if not A:
            return frozenset([0])  # span of empty set contains zero vector

        # Use Gaussian elimination
        basis = []
        for v in A:
            r = v
            for b in basis:
                r = min(r, r ^ b)
            if r > 0:
                basis.append(r)
                basis.sort(reverse=True)

        # Generate all linear combinations
        result = {0}
        for b in basis:
            result = result | {x ^ b for x in result}
        return frozenset(result) & frozenset(ground_set)

    return ClosureOperator(ground_set, span_f2)


# --- Closure-Stable Predicates ---

class ClosureStablePredicate:
    """A Boolean predicate on ground set elements that respects closure equivalence."""

    def __init__(self, test: Callable[[int], bool], name: str = ""):
        self.test = test
        self.name = name

    def __call__(self, x: int) -> bool:
        return self.test(x)

    def is_stable(self, op: ClosureOperator) -> bool:
        """Verify that the predicate is closure-stable."""
        elements = sorted(op.ground_set)
        for i, x in enumerate(elements):
            for y in elements[i+1:]:
                if op.closure_equiv(x, y) and self.test(x) != self.test(y):
                    return False
        return True


def synthesize_separating_predicates(
    op: ClosureOperator, k: int
) -> List[ClosureStablePredicate]:
    """Synthesize a minimal family of closure-stable predicates that k-separates.

    Uses a greedy approach: for each unseparated pair (x, y) in a large closed set,
    find a closure-stable predicate separating them.

    Args:
        op: The closure operator.
        k: The separation threshold.

    Returns:
        List of closure-stable predicates that k-separate.
    """
    large_sets = op.large_closed_sets(k)
    if not large_sets:
        return []

    # Collect all pairs that need separation
    pairs_to_separate = set()
    for C in large_sets:
        elements = sorted(C)
        for i, x in enumerate(elements):
            for y in elements[i+1:]:
                pairs_to_separate.add((x, y))

    # Compute closure equivalence classes
    elements = sorted(op.ground_set)
    equiv_classes: Dict[FrozenSet[int], List[int]] = {}
    for x in elements:
        key = op.cl(frozenset([x]))
        equiv_classes.setdefault(key, []).append(x)

    predicates = []
    separated = set()

    for x, y in sorted(pairs_to_separate):
        if (x, y) in separated:
            continue

        # Find a closure-stable predicate separating x and y
        # Use: assign True to x's equivalence class, False to y's
        cls_x = op.cl(frozenset([x]))
        cls_y = op.cl(frozenset([y]))

        if cls_x == cls_y:
            # Can't separate closure-equivalent elements with stable predicates
            continue

        def make_pred(target_cls):
            def test(z, _cls=target_cls):
                return op.cl(frozenset([z])) == _cls
            return test

        pred = ClosureStablePredicate(
            make_pred(cls_x),
            name=f"ind_cl({x})"
        )
        predicates.append(pred)

        # Mark all pairs separated by this predicate
        for a, b in list(pairs_to_separate - separated):
            if pred(a) != pred(b):
                separated.add((a, b))

    return predicates


# --- Evaluation Matrix ---

def build_evaluation_matrix(
    predicates: List[ClosureStablePredicate],
    elements: List[int]
) -> np.ndarray:
    """Build the Boolean evaluation matrix M[i, x] = predicates[i](elements[x]).

    Args:
        predicates: List of predicates (rows).
        elements: List of ground set elements (columns).

    Returns:
        Boolean numpy array of shape (len(predicates), len(elements)).
    """
    n = len(predicates)
    m = len(elements)
    M = np.zeros((n, m), dtype=bool)
    for i, pred in enumerate(predicates):
        for j, x in enumerate(elements):
            M[i, j] = pred(x)
    return M


def verify_separation(
    M: np.ndarray, op: ClosureOperator, elements: List[int], k: int
) -> bool:
    """Verify that a Boolean matrix k-separates all large closed sets.

    Args:
        M: Boolean matrix (rows = predicates, columns = elements).
        op: Closure operator.
        elements: List of ground set elements (column indices).
        k: Separation threshold.

    Returns:
        True if M k-separates all large closed sets.
    """
    elem_to_idx = {x: i for i, x in enumerate(elements)}
    large_sets = op.large_closed_sets(k)

    for C in large_sets:
        C_list = sorted(C)
        for i, x in enumerate(C_list):
            for y in C_list[i+1:]:
                ix, iy = elem_to_idx.get(x), elem_to_idx.get(y)
                if ix is None or iy is None:
                    continue
                if np.array_equal(M[:, ix], M[:, iy]):
                    return False
    return True


def compute_rank_defect(
    M: np.ndarray, op: ClosureOperator, elements: List[int], k: int
) -> int:
    """Compute the closure rank defect of an evaluation matrix.

    Rank defect = n (rows) - max distinct columns over large closed sets.

    Args:
        M: Boolean matrix (rows = predicates, columns = elements).
        op: Closure operator.
        elements: List of ground set elements.
        k: Separation threshold.

    Returns:
        The rank defect (non-negative integer).
    """
    n = M.shape[0]
    elem_to_idx = {x: i for i, x in enumerate(elements)}
    large_sets = op.large_closed_sets(k)

    max_distinct = 0
    for C in large_sets:
        cols = set()
        for x in C:
            idx = elem_to_idx.get(x)
            if idx is not None:
                cols.add(tuple(M[:, idx]))
        max_distinct = max(max_distinct, len(cols))

    return max(0, n - max_distinct) if max_distinct > 0 else n


def reconstruct_seed_family(
    M: np.ndarray, elements: List[int]
) -> Callable[[int], Tuple[bool, ...]]:
    """Reconstruct a seed family from an evaluation matrix.

    The reconstructed extractor maps each element to its column vector.

    Args:
        M: Boolean matrix.
        elements: List of ground set elements.

    Returns:
        Function mapping element -> column vector (tuple of bools).
    """
    elem_to_idx = {x: i for i, x in enumerate(elements)}

    def extractor(x: int) -> Tuple[bool, ...]:
        idx = elem_to_idx[x]
        return tuple(M[:, idx])

    return extractor


# --- Full Pipeline ---

def full_extractor_synthesis(
    op: ClosureOperator, k: int
) -> Tuple[List[ClosureStablePredicate], np.ndarray, Callable]:
    """Full extractor synthesis pipeline.

    1. Synthesize closure-stable predicates
    2. Build evaluation matrix
    3. Verify separation
    4. Reconstruct seed family

    Args:
        op: Closure operator.
        k: Separation threshold.

    Returns:
        Tuple of (predicates, evaluation_matrix, extractor_function).
    """
    elements = sorted(op.ground_set)

    # Step 1: Synthesize predicates
    predicates = synthesize_separating_predicates(op, k)

    # Step 2: Build evaluation matrix
    M = build_evaluation_matrix(predicates, elements)

    # Step 3: Verify
    is_valid = verify_separation(M, op, elements, k)

    # Step 4: Reconstruct
    extractor = reconstruct_seed_family(M, elements)

    print(f"Synthesis complete:")
    print(f"  Ground set size: {len(op.ground_set)}")
    print(f"  Threshold k: {k}")
    print(f"  # Predicates: {len(predicates)}")
    print(f"  Separation verified: {is_valid}")
    print(f"  Rank defect: {compute_rank_defect(M, op, elements, k)}")

    return predicates, M, extractor
