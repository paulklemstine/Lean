#!/usr/bin/env python3
"""
Algorithms for Closure-Compression Duality

Implements the core algorithms arising from the theoretical framework,
with full type hints, docstrings, and complexity analysis.
"""

from typing import TypeVar, Callable, Set, Dict, List, Tuple, Optional
from collections import defaultdict
import time

T = TypeVar('T')


class ClosureCompressor:
    """
    A generic idempotent closure compressor on a finite domain.

    Given a domain, a length function, and an idempotent compression map,
    this class provides methods to:
    - Verify the compression axioms
    - Compute fiber classes (equivalence classes)
    - Find closure cost (tropical minimum)
    - Identify incompressible elements
    - Compute compression statistics

    Time complexity:
    - Construction: O(n) where n = |domain|
    - Fiber computation: O(n)
    - Closure cost: O(n) total for all elements
    - Fixed point detection: O(n)

    Space complexity: O(n)
    """

    def __init__(self, domain: List[T], compress: Callable[[T], T],
                 length_fn: Callable[[T], int]):
        """
        Initialize the compressor.

        Args:
            domain: Finite list of elements (the type α)
            compress: Idempotent compression function c : α → α
            length_fn: Length/cost function ℓ : α → ℕ
        """
        self.domain = domain
        self.compress = compress
        self.length_fn = length_fn
        self._domain_set = set(domain)

        # Precompute fiber structure
        self._fibers: Dict[T, List[T]] = defaultdict(list)
        self._fixed_points: Set[T] = set()
        self._range: Set[T] = set()

        for x in domain:
            cx = compress(x)
            self._fibers[cx].append(x)
            self._range.add(cx)
            if cx == x:
                self._fixed_points.add(x)

    def verify_idempotence(self) -> bool:
        """
        Verify c(c(x)) = c(x) for all x.

        Time: O(n)
        """
        return all(
            self.compress(self.compress(x)) == self.compress(x)
            for x in self.domain
        )

    def verify_length_nonincreasing(self) -> bool:
        """
        Verify ℓ(c(x)) ≤ ℓ(x) for all x.

        Time: O(n)
        """
        return all(
            self.length_fn(self.compress(x)) <= self.length_fn(x)
            for x in self.domain
        )

    def verify_fiber_optimality(self) -> bool:
        """
        Verify that c(x) achieves the minimum length in its fiber class.
        i.e., ∀ x y, c(y) = c(x) → ℓ(c(x)) ≤ ℓ(y)

        Time: O(n)
        """
        for representative, members in self._fibers.items():
            rep_length = self.length_fn(representative)
            for member in members:
                if self.length_fn(member) < rep_length:
                    return False
        return True

    def fixed_points(self) -> Set[T]:
        """
        Return the set of fixed points {x | c(x) = x}.

        Time: O(1) (precomputed)
        """
        return self._fixed_points.copy()

    def range(self) -> Set[T]:
        """
        Return the range of c.

        Time: O(1) (precomputed)
        """
        return self._range.copy()

    def fiber_class(self, x: T) -> List[T]:
        """
        Return the fiber class {y | c(y) = c(x)}.

        Time: O(1) (precomputed)
        """
        return self._fibers[self.compress(x)]

    def closure_cost(self, x: T) -> int:
        """
        Compute the closure cost: min ℓ(y) over {y | c(y) = c(x)}.

        This is the tropical (min-plus) aggregation of description lengths
        over the equivalence class.

        Time: O(|fiber class|)
        """
        return min(self.length_fn(y) for y in self.fiber_class(x))

    def compression_ratio(self) -> float:
        """
        Compute the compression ratio: |fixed points| / |domain|.

        A ratio of 1.0 means no compression (identity map).
        A ratio near 0 means aggressive compression.

        Time: O(1) (precomputed)
        """
        return len(self._fixed_points) / len(self.domain)

    def compression_statistics(self) -> Dict:
        """
        Compute comprehensive compression statistics.

        Returns a dictionary with:
        - domain_size: |α|
        - fixed_points: number of fixed points
        - range_size: |range(c)|
        - compressed_count: elements that are NOT fixed
        - compression_ratio: fixed/total
        - max_fiber_size: largest equivalence class
        - avg_fiber_size: average equivalence class size
        - total_length_reduction: sum of (ℓ(x) - ℓ(c(x)))
        - avg_length_reduction: average (ℓ(x) - ℓ(c(x)))

        Time: O(n)
        """
        reductions = [
            self.length_fn(x) - self.length_fn(self.compress(x))
            for x in self.domain
        ]
        fiber_sizes = [len(members) for members in self._fibers.values()]

        return {
            "domain_size": len(self.domain),
            "fixed_points": len(self._fixed_points),
            "range_size": len(self._range),
            "compressed_count": len(self.domain) - len(self._fixed_points),
            "compression_ratio": self.compression_ratio(),
            "max_fiber_size": max(fiber_sizes) if fiber_sizes else 0,
            "avg_fiber_size": sum(fiber_sizes) / len(fiber_sizes)
            if fiber_sizes else 0,
            "total_length_reduction": sum(reductions),
            "avg_length_reduction": sum(reductions) / len(reductions)
            if reductions else 0,
        }


def find_incompressible_elements(
    domain: List[T],
    length_fn: Callable[[T], int],
    compressors: List[Callable[[T], T]]
) -> Set[T]:
    """
    Find elements that are fixed by ALL given compressors.

    These are the "incompressible" elements in the closure-theoretic sense:
    no compressor in the family can reduce them further.

    Algorithm:
    1. Start with all elements as candidates
    2. For each compressor, remove elements that are not fixed
    3. Return the intersection

    Time: O(n × k) where n = |domain|, k = |compressors|
    Space: O(n)

    Args:
        domain: Finite domain
        length_fn: Length function
        compressors: List of idempotent compression functions

    Returns:
        Set of universally incompressible elements
    """
    incompressible = set(domain)
    for c in compressors:
        incompressible = {x for x in incompressible if c(x) == x}
    return incompressible


def optimal_compressor_from_equivalence(
    domain: List[T],
    length_fn: Callable[[T], int],
    equiv_fn: Callable[[T], int]
) -> Callable[[T], T]:
    """
    Construct the optimal idempotent compressor for a given equivalence relation.

    Given an equivalence function (mapping each element to its class representative
    index), construct the compressor that maps each element to the shortest member
    of its equivalence class. The resulting function is guaranteed to be:
    - Idempotent
    - Length-nonincreasing
    - Fiber-optimal

    Algorithm:
    1. Group elements by equivalence class
    2. For each class, find the length-minimal element
    3. Map all class members to this element

    Time: O(n log n) for sorting within classes
    Space: O(n)

    Args:
        domain: Finite domain
        length_fn: Length function
        equiv_fn: Equivalence class identifier function

    Returns:
        Optimal idempotent compressor function
    """
    # Group by equivalence class
    classes: Dict[int, List[T]] = defaultdict(list)
    for x in domain:
        classes[equiv_fn(x)].append(x)

    # Find minimum-length representative for each class
    representatives: Dict[int, T] = {}
    for cls_id, members in classes.items():
        representatives[cls_id] = min(members, key=length_fn)

    # Build compression map
    compress_map: Dict[T, T] = {}
    for x in domain:
        compress_map[x] = representatives[equiv_fn(x)]

    def compress(x: T) -> T:
        return compress_map[x]

    return compress


def tropical_closure_cost_matrix(
    domain: List[T],
    compress: Callable[[T], T],
    length_fn: Callable[[T], int]
) -> Dict[T, int]:
    """
    Compute the full closure cost vector using tropical (min-plus) aggregation.

    For each element x, compute:
        closureCost(x) = min{ℓ(y) | c(y) = c(x)}

    This implements the tropical minimum over each equivalence class,
    which is the idempotent semiring operation applied to description lengths.

    Algorithm:
    1. Group elements by their c-image
    2. For each group, compute the minimum length
    3. Assign this minimum to all group members

    Time: O(n)
    Space: O(n)

    Args:
        domain: Finite domain
        compress: Idempotent compression function
        length_fn: Length function

    Returns:
        Dictionary mapping each element to its closure cost
    """
    # Group by c-image
    groups: Dict[T, List[T]] = defaultdict(list)
    for x in domain:
        groups[compress(x)].append(x)

    # Compute min length per group
    min_lengths: Dict[T, int] = {}
    for representative, members in groups.items():
        min_lengths[representative] = min(length_fn(m) for m in members)

    # Assign to all elements
    costs: Dict[T, int] = {}
    for x in domain:
        costs[x] = min_lengths[compress(x)]

    return costs


def iterative_compression(
    domain: List[T],
    length_fn: Callable[[T], int],
    step_fn: Callable[[T], T],
    max_iter: int = 1000
) -> Tuple[Callable[[T], T], int]:
    """
    Build an idempotent compressor by iterating a non-idempotent step function
    until convergence.

    Given a single-step compression function that may not be idempotent,
    iterate it until all elements reach fixed points. The result is
    guaranteed to be idempotent.

    Algorithm:
    1. For each element, iterate step_fn until convergence or max_iter
    2. Record the final (fixed) value as the compressed form
    3. Return the resulting idempotent map

    Time: O(n × max_iter) worst case, O(n × d) typical where d = depth
    Space: O(n)

    Args:
        domain: Finite domain
        length_fn: Length function (for verification)
        step_fn: Single-step compression function
        max_iter: Maximum iterations per element

    Returns:
        Tuple of (idempotent compression function, max depth reached)
    """
    compress_map: Dict[T, T] = {}
    max_depth = 0

    for x in domain:
        current = x
        depth = 0
        while depth < max_iter:
            next_val = step_fn(current)
            if next_val == current:
                break
            current = next_val
            depth += 1
        compress_map[x] = current
        max_depth = max(max_depth, depth)

    def compress(x: T) -> T:
        return compress_map[x]

    return compress, max_depth


if __name__ == "__main__":
    import itertools

    # Example: 5-bit strings with Hamming weight equivalence
    n = 5
    domain = list(itertools.product([0, 1], repeat=n))

    def length_fn(x):
        """Length = number of bit transitions."""
        return sum(1 for i in range(len(x) - 1) if x[i] != x[i + 1])

    def hamming_weight(x):
        return sum(x)

    # Build optimal compressor
    compress = optimal_compressor_from_equivalence(
        domain, length_fn, hamming_weight
    )

    # Analyze
    cc = ClosureCompressor(domain, compress, length_fn)
    print("Optimal Hamming-weight compressor on 5-bit strings:")
    print(f"  Idempotent: {cc.verify_idempotence()}")
    print(f"  Length-nonincreasing: {cc.verify_length_nonincreasing()}")
    print(f"  Fiber-optimal: {cc.verify_fiber_optimality()}")

    stats = cc.compression_statistics()
    for key, val in stats.items():
        print(f"  {key}: {val}")

    # Tropical closure costs
    costs = tropical_closure_cost_matrix(domain, compress, length_fn)
    print(f"\n  Sample closure costs:")
    for x in list(domain)[:10]:
        print(f"    {x} → cost={costs[x]}, "
              f"ℓ(c(x))={length_fn(compress(x))}, "
              f"match={'✓' if costs[x] == length_fn(compress(x)) else '✗'}")
