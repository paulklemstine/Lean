"""
Algorithms for Abstract Rewriting Systems: Bisimulation, Common-Reduct Search,
and Modal Equivalence Checking.

Implements the verified algorithms from the Lean 4 formalization in
Catalog/Pythagorean/ARSConfluenceBisimulation.lean.
"""

from __future__ import annotations
from typing import TypeVar, Callable, Optional, Set, Dict, List, Tuple, FrozenSet
from collections import deque
from dataclasses import dataclass

T = TypeVar('T')


@dataclass(frozen=True)
class ARS:
    """An Abstract Rewriting System: a set of states with a step relation.

    Represented computationally by a successor function that returns all
    one-step reducts of a given state.
    """
    states: FrozenSet
    successors: Dict  # state -> list of successor states

    def step(self, a, b) -> bool:
        """Check if a -> b in one step."""
        return b in self.successors.get(a, [])

    def multi_step_reachable(self, a, fuel: int = 100) -> Set:
        """BFS to find all states reachable from a within fuel steps."""
        visited = {a}
        frontier = {a}
        for _ in range(fuel):
            next_frontier = set()
            for s in frontier:
                for t in self.successors.get(s, []):
                    if t not in visited:
                        visited.add(t)
                        next_frontier.add(t)
            frontier = next_frontier
            if not frontier:
                break
        return visited


def search_common_reduct(successors: Callable, fuel: int, a, b) -> Optional:
    """Bounded BFS for common reducts.

    Given a successor function and two starting states, search for a state
    reachable from both within `fuel` BFS levels.

    Returns (common_reduct, path_from_a, path_from_b) or None.

    Time complexity: O(b^fuel) where b is branching factor.
    Space complexity: O(b^fuel).

    >>> # Simple example: K x y -> x
    >>> succ = {('K', 'a', 'b'): ['a'], 'a': [], 'b': []}
    >>> search_common_reduct(lambda s: succ.get(s, []), 5, ('K', 'a', 'b'), 'a')
    'a'
    """
    # BFS from a
    visited_a = {a}
    frontier_a = [a]
    parent_a: Dict = {a: None}

    for _ in range(fuel):
        next_frontier = []
        for s in frontier_a:
            for t in successors(s):
                if t not in visited_a:
                    visited_a.add(t)
                    parent_a[t] = s
                    next_frontier.append(t)
        frontier_a = next_frontier

    # BFS from b
    visited_b = {b}
    frontier_b = [b]

    for _ in range(fuel):
        next_frontier = []
        for s in frontier_b:
            for t in successors(s):
                if t not in visited_b:
                    visited_b.add(t)
                    next_frontier.append(t)
        frontier_b = next_frontier

    # Find intersection
    common = visited_a & visited_b
    if common:
        return next(iter(common))
    return None


def check_modal_equivalence(successors: Callable, depth: int, a, b,
                             fuel: int = 50) -> bool:
    """Check modal equivalence up to given depth.

    Two states are modal-equivalent at depth 0 (always True).
    At depth n+1, they are modal-equivalent if:
    - Every successor of a has a state reachable from b that is
      modal-equivalent at depth n
    - Every successor of b has a state reachable from a that is
      modal-equivalent at depth n

    This is a computational approximation: we use bounded BFS for
    reachability and recursive checking for modal equivalence.

    >>> succ = lambda x: []
    >>> check_modal_equivalence(succ, 5, 'a', 'b')
    True
    """
    if depth == 0:
        return True

    succs_a = successors(a)
    succs_b = successors(b)

    # Forward: for each successor of a, find a reachable state from b
    # that is modal-equivalent at depth-1
    reachable_b = _bfs_reachable(successors, b, fuel)
    for a_prime in succs_a:
        found = False
        for b_prime in reachable_b:
            if check_modal_equivalence(successors, depth - 1, a_prime, b_prime, fuel):
                found = True
                break
        if not found:
            return False

    # Backward: symmetric
    reachable_a = _bfs_reachable(successors, a, fuel)
    for b_prime in succs_b:
        found = False
        for a_prime in reachable_a:
            if check_modal_equivalence(successors, depth - 1, a_prime, b_prime, fuel):
                found = True
                break
        if not found:
            return False

    return True


def _bfs_reachable(successors: Callable, start, fuel: int) -> Set:
    """BFS to find all reachable states within fuel steps."""
    visited = {start}
    frontier = [start]
    for _ in range(fuel):
        next_frontier = []
        for s in frontier:
            for t in successors(s):
                if t not in visited:
                    visited.add(t)
                    next_frontier.append(t)
        frontier = next_frontier
    return visited


def compute_common_reduct_classes(states, successors: Callable,
                                    fuel: int = 50) -> List[Set]:
    """Compute equivalence classes under common-reduct equivalence.

    Two states are in the same class iff they have a common reduct
    (found within the fuel budget).

    Uses union-find for efficient class computation.
    """
    parent = {s: s for s in states}

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        rx, ry = find(x), find(y)
        if rx != ry:
            parent[rx] = ry

    # For each pair, check if they have a common reduct
    state_list = list(states)
    for i in range(len(state_list)):
        for j in range(i + 1, len(state_list)):
            a, b = state_list[i], state_list[j]
            if find(a) != find(b):
                cr = search_common_reduct(successors, fuel, a, b)
                if cr is not None:
                    union(a, b)

    # Build classes
    classes: Dict = {}
    for s in states:
        r = find(s)
        if r not in classes:
            classes[r] = set()
        classes[r].add(s)

    return list(classes.values())


def verify_bisimulation_transfer(successors: Callable, pairs: List[Tuple],
                                   fuel: int = 50) -> List[Dict]:
    """Verify the bisimulation transfer condition for given pairs.

    For each pair (x, y) with a common reduct, check that:
    - Every successor x' of x has a state y' reachable from y with
      common reduct (x', y')
    - Every successor y' of y has a state x' reachable from x with
      common reduct (x', y')

    Returns a list of verification results.
    """
    results = []
    for x, y in pairs:
        cr = search_common_reduct(successors, fuel, x, y)
        if cr is None:
            results.append({
                'pair': (x, y),
                'has_common_reduct': False,
                'forward_ok': None,
                'backward_ok': None,
            })
            continue

        # Forward check
        forward_ok = True
        forward_witnesses = {}
        for x_prime in successors(x):
            witness = search_common_reduct(successors, fuel, x_prime, y)
            if witness is not None:
                forward_witnesses[x_prime] = witness
            else:
                forward_ok = False

        # Backward check
        backward_ok = True
        backward_witnesses = {}
        for y_prime in successors(y):
            witness = search_common_reduct(successors, fuel, x, y_prime)
            if witness is not None:
                backward_witnesses[y_prime] = witness
            else:
                backward_ok = False

        results.append({
            'pair': (x, y),
            'has_common_reduct': True,
            'common_reduct': cr,
            'forward_ok': forward_ok,
            'forward_witnesses': forward_witnesses,
            'backward_ok': backward_ok,
            'backward_witnesses': backward_witnesses,
        })

    return results


if __name__ == '__main__':
    # Quick test with a simple ARS
    print("=== Algorithm Tests ===")

    # Diamond-shaped ARS: a -> b, a -> c, b -> d, c -> d
    succ = {'a': ['b', 'c'], 'b': ['d'], 'c': ['d'], 'd': []}

    print("\nDiamond ARS: a->b, a->c, b->d, c->d")
    cr = search_common_reduct(lambda s: succ.get(s, []), 5, 'b', 'c')
    print(f"Common reduct of b and c: {cr}")

    modal = check_modal_equivalence(lambda s: succ.get(s, []), 3, 'b', 'c')
    print(f"Modal equivalent up to depth 3: {modal}")

    classes = compute_common_reduct_classes(
        {'a', 'b', 'c', 'd'}, lambda s: succ.get(s, []))
    print(f"Common-reduct equivalence classes: {classes}")
