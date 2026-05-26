"""
Overlap Class Algorithms for Support Families

Implements the core algorithms for computing overlap graphs, overlap classes,
and overlap complexity measures for finite families of sets.

These algorithms directly correspond to the formalized definitions in
Pythagorean/TropicalBridge/OverlapClassRigidity.lean.
"""

from typing import List, Set, Dict, Tuple, FrozenSet
from collections import defaultdict


def supports_overlap(a: FrozenSet[int], b: FrozenSet[int]) -> bool:
    """Check if two supports overlap (nonempty intersection).

    Corresponds to OverlapClass.SupportsOverlap in the Lean formalization.

    Args:
        a: First support (finite set of vertices)
        b: Second support (finite set of vertices)

    Returns:
        True if a ∩ b is nonempty

    Examples:
        >>> supports_overlap(frozenset({1,2,3}), frozenset({3,4,5}))
        True
        >>> supports_overlap(frozenset({1,2}), frozenset({3,4}))
        False
    """
    return len(a & b) > 0


def build_overlap_graph(family: List[FrozenSet[int]]) -> Dict[int, Set[int]]:
    """Build the support overlap graph.

    Corresponds to OverlapClass.SupportOverlapGraph.

    Args:
        family: List of supports (finite sets of vertices)

    Returns:
        Adjacency list representation of the overlap graph.
        Keys are indices into the family, values are sets of adjacent indices.

    Examples:
        >>> g = build_overlap_graph([frozenset({1,2}), frozenset({2,3}), frozenset({4,5})])
        >>> g[0]
        {1}
        >>> g[2]
        set()
    """
    n = len(family)
    adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
    for i in range(n):
        for j in range(i + 1, n):
            if supports_overlap(family[i], family[j]):
                adj[i].add(j)
                adj[j].add(i)
    return adj


def find_overlap_classes(family: List[FrozenSet[int]]) -> List[List[int]]:
    """Find the overlap classes (connected components of the overlap graph).

    Corresponds to OverlapClass.overlapClassCount (returns the classes themselves).

    Uses union-find for O(n² · m · α(n)) time complexity.

    Args:
        family: List of supports

    Returns:
        List of overlap classes, where each class is a list of indices.

    Examples:
        >>> find_overlap_classes([frozenset({1,2}), frozenset({2,3}), frozenset({4,5})])
        [[0, 1], [2]]
    """
    n = len(family)
    if n == 0:
        return []

    # Union-Find
    parent = list(range(n))
    rank = [0] * n

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x: int, y: int) -> None:
        rx, ry = find(x), find(y)
        if rx == ry:
            return
        if rank[rx] < rank[ry]:
            rx, ry = ry, rx
        parent[ry] = rx
        if rank[rx] == rank[ry]:
            rank[rx] += 1

    for i in range(n):
        for j in range(i + 1, n):
            if supports_overlap(family[i], family[j]):
                union(i, j)

    classes: Dict[int, List[int]] = defaultdict(list)
    for i in range(n):
        classes[find(i)].append(i)
    return list(classes.values())


def overlap_class_count(family: List[FrozenSet[int]]) -> int:
    """Count the number of overlap classes.

    Corresponds to OverlapClass.overlapClassCount.

    Args:
        family: List of supports

    Returns:
        Number of connected components of the overlap graph.
    """
    return len(find_overlap_classes(family))


def max_intersection_size(family: List[FrozenSet[int]]) -> int:
    """Compute the maximum pairwise intersection cardinality.

    Corresponds to OverlapClass.maxIntersectionSize.

    Args:
        family: List of supports

    Returns:
        Maximum |F(i) ∩ F(j)| over all i ≠ j, or 0 if |family| ≤ 1.
    """
    n = len(family)
    result = 0
    for i in range(n):
        for j in range(i + 1, n):
            result = max(result, len(family[i] & family[j]))
    return result


def total_overlap_complexity(family: List[FrozenSet[int]]) -> int:
    """Compute the total overlap complexity.

    Corresponds to OverlapClass.totalOverlapComplexity.

    Args:
        family: List of supports

    Returns:
        Sum of |F(i) ∩ F(j)| over all i < j.
    """
    n = len(family)
    total = 0
    for i in range(n):
        for j in range(i + 1, n):
            total += len(family[i] & family[j])
    return total


def overlap_pair_count(family: List[FrozenSet[int]]) -> int:
    """Count the number of overlapping pairs.

    Corresponds to OverlapClass.overlapPairCount.

    Args:
        family: List of supports

    Returns:
        Number of unordered pairs {i, j} with F(i) ∩ F(j) ≠ ∅.
    """
    n = len(family)
    count = 0
    for i in range(n):
        for j in range(i + 1, n):
            if supports_overlap(family[i], family[j]):
                count += 1
    return count


def element_nerve(family: List[FrozenSet[int]]) -> Dict[int, Set[int]]:
    """Compute the element nerve.

    Corresponds to OverlapClass.elementNerve.

    For each element x in the ground set, returns the set of indices
    whose support contains x.

    Args:
        family: List of supports

    Returns:
        Dictionary mapping each element to the set of indices containing it.
    """
    nerve: Dict[int, Set[int]] = defaultdict(set)
    for i, s in enumerate(family):
        for x in s:
            nerve[x].add(i)
    return dict(nerve)


def pairwise_disjoint(family: List[FrozenSet[int]]) -> bool:
    """Check if a family has pairwise disjoint supports.

    Corresponds to OverlapClass.PairwiseDisjointSupports.

    Args:
        family: List of supports

    Returns:
        True if all pairs are disjoint.
    """
    n = len(family)
    for i in range(n):
        for j in range(i + 1, n):
            if supports_overlap(family[i], family[j]):
                return False
    return True


def overlap_class_support(family: List[FrozenSet[int]], index: int) -> FrozenSet[int]:
    """Compute the union of supports within the overlap class of a given index.

    Corresponds to OverlapClass.overlapClassSupport.

    Args:
        family: List of supports
        index: Index whose class support to compute

    Returns:
        Union of all supports in the same overlap class as family[index].
    """
    classes = find_overlap_classes(family)
    for cls in classes:
        if index in cls:
            result: Set[int] = set()
            for i in cls:
                result |= family[i]
            return frozenset(result)
    return frozenset()


def overlap_signature(family: List[FrozenSet[int]]) -> Tuple:
    """Compute the overlap signature of a family.

    The signature consists of:
    - Number of overlap classes
    - Sorted list of class sizes
    - Sorted multiset of pairwise intersection sizes (for overlapping pairs)
    - Max intersection size
    - Total overlap complexity

    This is a candidate invariant for tropical projective class count.

    Args:
        family: List of supports

    Returns:
        Tuple encoding the overlap signature.
    """
    classes = find_overlap_classes(family)
    class_sizes = sorted(len(c) for c in classes)
    intersection_sizes = sorted(
        len(family[i] & family[j])
        for i in range(len(family))
        for j in range(i + 1, len(family))
        if supports_overlap(family[i], family[j])
    )
    return (
        len(classes),
        tuple(class_sizes),
        tuple(intersection_sizes),
        max_intersection_size(family),
        total_overlap_complexity(family),
    )


# ---- Example usage ----
if __name__ == "__main__":
    print("=" * 60)
    print("Overlap Class Algorithms — Examples")
    print("=" * 60)

    # Example 1: Pairwise disjoint family
    f1 = [frozenset({1, 2}), frozenset({3, 4}), frozenset({5, 6})]
    print("\nFamily 1 (pairwise disjoint):", [set(s) for s in f1])
    print(f"  Pairwise disjoint: {pairwise_disjoint(f1)}")
    print(f"  Overlap classes: {find_overlap_classes(f1)}")
    print(f"  Class count: {overlap_class_count(f1)}")
    print(f"  Max intersection size: {max_intersection_size(f1)}")
    print(f"  Total overlap complexity: {total_overlap_complexity(f1)}")

    # Example 2: Two overlapping, one disjoint
    f2 = [frozenset({1, 2, 3}), frozenset({3, 4, 5}), frozenset({7, 8})]
    print("\nFamily 2 (partial overlap):", [set(s) for s in f2])
    print(f"  Pairwise disjoint: {pairwise_disjoint(f2)}")
    print(f"  Overlap classes: {find_overlap_classes(f2)}")
    print(f"  Class count: {overlap_class_count(f2)}")
    print(f"  Max intersection size: {max_intersection_size(f2)}")
    print(f"  Total overlap complexity: {total_overlap_complexity(f2)}")
    print(f"  Element nerve: {element_nerve(f2)}")

    # Example 3: Chain of overlaps
    f3 = [frozenset({1, 2}), frozenset({2, 3}), frozenset({3, 4}), frozenset({5, 6})]
    print("\nFamily 3 (chain + isolated):", [set(s) for s in f3])
    print(f"  Pairwise disjoint: {pairwise_disjoint(f3)}")
    print(f"  Overlap classes: {find_overlap_classes(f3)}")
    print(f"  Class count: {overlap_class_count(f3)}")
    print(f"  Overlap signature: {overlap_signature(f3)}")

    # Example 4: Complete overlap
    f4 = [frozenset({1, 2, 3}), frozenset({2, 3, 4}), frozenset({3, 4, 5})]
    print("\nFamily 4 (dense overlap):", [set(s) for s in f4])
    print(f"  Pairwise disjoint: {pairwise_disjoint(f4)}")
    print(f"  Overlap classes: {find_overlap_classes(f4)}")
    print(f"  Class count: {overlap_class_count(f4)}")
    print(f"  Max intersection size: {max_intersection_size(f4)}")
    print(f"  Total overlap complexity: {total_overlap_complexity(f4)}")
    print(f"  Overlap signature: {overlap_signature(f4)}")
