#!/usr/bin/env python3
"""
Overlap Class Algorithms
========================
Implements the core algorithms from the overlap class theory.
All algorithms are self-contained with docstrings and type hints.

Key algorithms:
1. Overlap graph construction  - O(n² · k) where k = max support size
2. Overlap class computation   - O(n² · k) using BFS
3. Overlap complexity          - O(n² · k)
4. Peeling algorithm           - O(n² · k) per step
5. Support interaction matrix  - O(n² · k)
6. Overlap spectrum            - O(n² · k + n² log n²)
"""

from typing import List, Set, Dict, Tuple, Optional
from itertools import combinations
from collections import defaultdict, deque


def build_overlap_graph(supports: List[Set[int]]) -> Dict[int, Set[int]]:
    """
    Build the overlap graph from a family of supports.
    
    The overlap graph has vertices = indices {0, ..., n-1} and
    edges connecting pairs whose supports have nonempty intersection.
    
    Time complexity: O(n² · k) where k is the maximum support size.
    Space complexity: O(n²) for the adjacency list.
    
    Args:
        supports: List of sets representing the support family.
    
    Returns:
        Adjacency list representation of the overlap graph.
    
    Example:
        >>> build_overlap_graph([{1,2}, {2,3}, {4,5}])
        {0: {1}, 1: {0}, 2: set()}
    """
    n = len(supports)
    adj: Dict[int, Set[int]] = defaultdict(set)
    for i in range(n):
        adj[i]  # ensure all vertices appear
    for i, j in combinations(range(n), 2):
        if supports[i] & supports[j]:
            adj[i].add(j)
            adj[j].add(i)
    return dict(adj)


def compute_overlap_classes(supports: List[Set[int]]) -> List[Set[int]]:
    """
    Compute the overlap equivalence classes via BFS on the overlap graph.
    
    Returns the connected components of the overlap graph, which are
    the overlap classes (equivalence classes of the reflexive-transitive
    closure of the overlap relation).
    
    Time complexity: O(n² · k) for graph construction + O(n) for BFS.
    Space complexity: O(n²) for the graph + O(n) for BFS state.
    
    Args:
        supports: List of sets representing the support family.
    
    Returns:
        List of sets, each set containing the indices in one overlap class.
    
    Example:
        >>> compute_overlap_classes([{1,2}, {2,3}, {4,5}])
        [{0, 1}, {2}]
    """
    n = len(supports)
    if n == 0:
        return []
    
    adj = build_overlap_graph(supports)
    visited = set()
    classes = []
    
    for start in range(n):
        if start in visited:
            continue
        component: Set[int] = set()
        queue = deque([start])
        while queue:
            node = queue.popleft()
            if node in visited:
                continue
            visited.add(node)
            component.add(node)
            for neighbor in adj.get(node, set()):
                if neighbor not in visited:
                    queue.append(neighbor)
        classes.append(component)
    
    return classes


def overlap_class_count(supports: List[Set[int]]) -> int:
    """
    Count the number of overlap classes.
    
    Args:
        supports: List of sets representing the support family.
    
    Returns:
        Number of overlap equivalence classes.
    """
    return len(compute_overlap_classes(supports))


def compute_overlap_complexity(supports: List[Set[int]]) -> int:
    """
    Compute the overlap complexity: sum of |F(i) ∩ F(j)| over all i < j.
    
    This is a finer invariant than the overlap degree (which just counts
    the number of overlapping pairs). Overlap complexity measures the
    total intensity of overlap in the family.
    
    Time complexity: O(n² · k).
    
    Properties (proved in Lean):
    - Complexity = 0 ⟺ pairwise disjoint
    - Monotone under support inclusion
    - Strictly decreases under peeling
    
    Args:
        supports: List of sets representing the support family.
    
    Returns:
        Total pairwise intersection size.
    """
    total = 0
    for i, j in combinations(range(len(supports)), 2):
        total += len(supports[i] & supports[j])
    return total


def peel_element(supports: List[Set[int]], index: int, element: int) -> List[Set[int]]:
    """
    Remove an element from a specific support (peeling operation).
    
    The peeling lemma (proved in Lean) guarantees that if the element
    is shared with another support, the overlap complexity strictly
    decreases. This is the key inductive step for the overlap class
    conjecture.
    
    Time complexity: O(k) for the set operation.
    
    Args:
        supports: List of sets representing the support family.
        index: Index of the support to modify.
        element: Element to remove.
    
    Returns:
        New support family with the element removed from the specified support.
    """
    result = [s.copy() for s in supports]
    result[index].discard(element)
    return result


def iterative_peeling(supports: List[Set[int]]) -> Tuple[List[Set[int]], int]:
    """
    Iteratively peel shared elements until the family is pairwise disjoint.
    
    By the peeling lemma, each step strictly reduces overlap complexity,
    so this terminates in at most O(overlap_complexity) steps. The result
    is a pairwise disjoint family where each overlap class has been reduced
    to a disjoint representative.
    
    Time complexity: O(C · n · k) where C is the initial overlap complexity.
    
    Args:
        supports: List of sets representing the support family.
    
    Returns:
        Tuple of (peeled family, number of peeling steps).
    """
    current = [s.copy() for s in supports]
    steps = 0
    
    while True:
        # Find a shared element
        found = False
        for i, j in combinations(range(len(current)), 2):
            shared = current[i] & current[j]
            if shared:
                element = min(shared)  # deterministic choice
                current = peel_element(current, i, element)
                steps += 1
                found = True
                break
        if not found:
            break
    
    return current, steps


def compute_support_interaction_matrix(supports: List[Set[int]]) -> List[List[int]]:
    """
    Build the support interaction matrix.
    
    M[i][j] = |F(i) ∩ F(j)| for i ≠ j, and M[i][i] = |F(i)|.
    
    Properties (proved in Lean):
    - Symmetric
    - Diagonal for pairwise disjoint families
    - Off-diagonal entries give cross-overlap counts
    
    Time complexity: O(n² · k).
    
    Args:
        supports: List of sets representing the support family.
    
    Returns:
        n × n matrix as list of lists.
    """
    n = len(supports)
    M = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            if i == j:
                M[i][j] = len(supports[i])
            else:
                M[i][j] = len(supports[i] & supports[j])
    return M


def compute_overlap_spectrum(supports: List[Set[int]]) -> List[int]:
    """
    Compute the overlap spectrum: sorted list of pairwise intersection sizes.
    
    This is a finer invariant than overlap complexity (which is just the sum).
    Two families can have the same complexity but different spectra.
    
    Time complexity: O(n² · k + n² log n²).
    
    Properties (proved in Lean):
    - All entries are zero for pairwise disjoint families
    
    Args:
        supports: List of sets representing the support family.
    
    Returns:
        Sorted list of intersection sizes for all pairs i < j.
    """
    spectrum = []
    for i, j in combinations(range(len(supports)), 2):
        spectrum.append(len(supports[i] & supports[j]))
    return sorted(spectrum)


def compute_support_distance(supports: List[Set[int]], i: int, j: int) -> int:
    """
    Compute the Hamming distance between two supports.
    
    The support distance is the size of the symmetric difference,
    which equals the Hamming distance when supports are viewed as
    characteristic vectors.
    
    Properties (proved in Lean):
    - Symmetric
    - Equals sum of sizes for disjoint supports
    
    Args:
        supports: The support family.
        i, j: Indices of the two supports.
    
    Returns:
        |F(i) △ F(j)| = |F(i) \ F(j)| + |F(j) \ F(i)|
    """
    return len(supports[i] - supports[j]) + len(supports[j] - supports[i])


def compute_overlap_rank(supports: List[Set[int]]) -> int:
    """
    Compute the overlap rank: n - (number of overlap classes).
    
    Analogous to the rank of a matroid. Measures the total interaction
    intensity. Zero for pairwise disjoint families.
    
    Args:
        supports: List of sets representing the support family.
    
    Returns:
        Overlap rank.
    """
    return len(supports) - overlap_class_count(supports)


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    print("Overlap Class Algorithms — Example Usage")
    print("=" * 50)
    
    # Example: cycle supports from K4
    supports = [
        {0, 1, 3},  # cycle 1-2-4 edges
        {1, 2, 4},  # cycle 2-3-5 edges
        {0, 2, 5},  # cycle 1-3-6 edges
    ]
    
    print(f"\nSupports (K4 fundamental cycles): {supports}")
    print(f"Overlap graph: {build_overlap_graph(supports)}")
    print(f"Overlap classes: {compute_overlap_classes(supports)}")
    print(f"Class count: {overlap_class_count(supports)}")
    print(f"Overlap complexity: {compute_overlap_complexity(supports)}")
    print(f"Overlap spectrum: {compute_overlap_spectrum(supports)}")
    print(f"Overlap rank: {compute_overlap_rank(supports)}")
    
    print(f"\nInteraction matrix:")
    M = compute_support_interaction_matrix(supports)
    for row in M:
        print(f"  {row}")
    
    print(f"\nPeeling to disjoint:")
    peeled, steps = iterative_peeling(supports)
    print(f"  Peeled family: {peeled}")
    print(f"  Steps: {steps}")
    print(f"  Final complexity: {compute_overlap_complexity(peeled)}")
