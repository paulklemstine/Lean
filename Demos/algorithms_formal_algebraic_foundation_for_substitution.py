#!/usr/bin/env python3
"""
Hamming Fiber Algebra — Core Algorithms

Type-hinted implementations of the key algorithms arising from the
Hamming fiber algebra theory.
"""

from typing import List, Tuple, Dict, Set, Optional, Callable
from itertools import product
from collections import defaultdict


Word = Tuple[int, ...]
SlotFlavors = Dict[int, Dict[int, int]]


def hamming_distance(u: Word, v: Word) -> int:
    """Compute the Hamming distance between two words."""
    return sum(1 for a, b in zip(u, v) if a != b)


def hamming_ball(w: Word, r: int, n: int, m: int) -> List[Word]:
    """
    Compute all words within Hamming distance r of w in H(n,m).
    
    Time: O(sum_{k=0}^r C(n,k) * (m-1)^k)
    The ball of radius 1 has exactly 1 + n*(m-1) elements (proved in Lean).
    """
    result = []
    for v in product(range(m), repeat=n):
        if hamming_distance(w, v) <= r:
            result.append(v)
    return result


def additive_optimize(slot_flavors: SlotFlavors, n: int, m: int) -> Tuple[Word, int]:
    """
    Find the word maximizing an additive flavor map.
    
    The slot independence theorem (proved in Lean) guarantees this greedy
    per-slot optimization finds the global optimum.
    
    Time: O(n * m), vs O(m^n) for brute force.
    """
    optimal_word = []
    total_score = 0
    for i in range(n):
        best_val = max(range(m), key=lambda a: slot_flavors[i][a])
        optimal_word.append(best_val)
        total_score += slot_flavors[i][best_val]
    return tuple(optimal_word), total_score


def compute_fibers(slot_flavors: SlotFlavors, n: int, m: int) -> Dict[int, List[Word]]:
    """
    Partition H(n,m) into fibers of an additive flavor map.
    
    Returns a dictionary mapping target values to lists of words.
    """
    fibers: Dict[int, List[Word]] = defaultdict(list)
    for w in product(range(m), repeat=n):
        score = sum(slot_flavors[i][w[i]] for i in range(n))
        fibers[score].append(w)
    return dict(fibers)


def find_fiber_bridges(
    slot_flavors: SlotFlavors,
    u: Word, v: Word, n: int
) -> List[Word]:
    """
    Find all bridge words between u and v in their fiber.
    
    A bridge w satisfies:
    - d(u, w) = 1
    - d(w, v) = 1  
    - f(w) = f(u)
    
    By the Bridge Duality Theorem (proved in Lean), bridges exist iff
    the slot flavors at the first differing position are equal for u and v.
    When bridges exist, exactly 2 exist (one per differing position).
    """
    if hamming_distance(u, v) != 2:
        return []
    
    diffs = [i for i in range(n) if u[i] != v[i]]
    i0, i1 = diffs
    
    target = sum(slot_flavors[i][u[i]] for i in range(n))
    bridges = []
    
    # Bridge via position i0: update u at i0 to v[i0]
    w0 = list(u)
    w0[i0] = v[i0]
    w0 = tuple(w0)
    score_w0 = sum(slot_flavors[i][w0[i]] for i in range(n))
    if score_w0 == target:
        bridges.append(w0)
    
    # Bridge via position i1: update u at i1 to v[i1]  
    w1 = list(u)
    w1[i1] = v[i1]
    w1 = tuple(w1)
    score_w1 = sum(slot_flavors[i][w1[i]] for i in range(n))
    if score_w1 == target:
        bridges.append(w1)
    
    return bridges


def singleton_bound(n: int, m: int, d: int) -> int:
    """
    Compute the Singleton bound for a code in H(n,m) with minimum distance d.
    Proved in Lean: |C| ≤ m^(n - d + 1).
    """
    if d > n:
        return 1
    return m ** (n - d + 1)


def plotkin_bound(n: int, d: int) -> Optional[int]:
    """
    Compute the Plotkin bound for binary codes.
    Valid when d > n/2. Returns the maximum code size.
    Proved in Lean: |C| * (2d - n) ≤ 2d.
    """
    if 2 * d <= n:
        return None  # Plotkin bound not applicable
    return (2 * d) // (2 * d - n)


def fiber_connectivity_check(
    slot_flavors: SlotFlavors, n: int, m: int, target: int
) -> Tuple[bool, Optional[Tuple[Word, Word]]]:
    """
    Check if a fiber is connected in the Hamming graph.
    
    Returns (is_connected, disconnected_pair_if_any).
    Uses BFS from an arbitrary fiber element.
    """
    fiber = [w for w in product(range(m), repeat=n)
             if sum(slot_flavors[i][w[i]] for i in range(n)) == target]
    
    if len(fiber) <= 1:
        return True, None
    
    fiber_set = set(fiber)
    visited: Set[Word] = {fiber[0]}
    queue = [fiber[0]]
    
    while queue:
        current = queue.pop(0)
        for i in range(n):
            for a in range(m):
                if a != current[i]:
                    neighbor = list(current)
                    neighbor[i] = a
                    neighbor = tuple(neighbor)
                    if neighbor in fiber_set and neighbor not in visited:
                        visited.add(neighbor)
                        queue.append(neighbor)
    
    if len(visited) == len(fiber):
        return True, None
    else:
        unvisited = fiber_set - visited
        return False, (fiber[0], next(iter(unvisited)))


def fiber_expansion_ratio(
    slot_flavors: SlotFlavors, w: Word, n: int, m: int, target: int
) -> float:
    """
    Compute the expansion ratio of a word within its fiber.
    
    expansion = external_neighbors / internal_neighbors
    
    The conjecture states this is ≥ (m-2) for injective slot flavors.
    """
    fiber_set = set(
        v for v in product(range(m), repeat=n)
        if sum(slot_flavors[i][v[i]] for i in range(n)) == target
    )
    
    internal = 0
    external = 0
    for i in range(n):
        for a in range(m):
            if a != w[i]:
                neighbor = list(w)
                neighbor[i] = a
                neighbor = tuple(neighbor)
                if neighbor in fiber_set:
                    internal += 1
                else:
                    external += 1
    
    return external / internal if internal > 0 else float('inf')


if __name__ == "__main__":
    # Example: optimize a 5-slot, 4-option recipe
    flavors: SlotFlavors = {
        0: {0: 1, 1: 5, 2: 3, 3: 2},
        1: {0: 4, 1: 1, 2: 6, 3: 3},
        2: {0: 2, 1: 7, 2: 1, 3: 4},
        3: {0: 3, 1: 2, 2: 5, 3: 8},
        4: {0: 6, 1: 3, 2: 4, 3: 1},
    }
    
    opt_word, opt_score = additive_optimize(flavors, 5, 4)
    print(f"Optimal recipe: {opt_word}")
    print(f"Optimal score: {opt_score}")
    print(f"Singleton bound (d=3): {singleton_bound(5, 4, 3)}")
    print(f"Plotkin bound (n=7, d=5): {plotkin_bound(7, 5)}")
