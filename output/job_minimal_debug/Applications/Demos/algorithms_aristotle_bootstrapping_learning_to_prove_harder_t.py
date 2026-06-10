"""
Curriculum Theory: Core Algorithms

Implements the mathematical framework for theorem curriculum complexity,
including dependency level computation, stage knowledge construction,
curriculum generation, and frontier depth analysis.
"""

from __future__ import annotations
from typing import TypeVar, Generic, Callable, Optional
from collections import defaultdict, deque
import heapq

T = TypeVar('T')


class DepSystem(Generic[T]):
    """A dependency system: a finite set of theorem labels with an acyclic dependency relation.
    
    Attributes:
        nodes: Set of theorem labels.
        deps: Dictionary mapping each node to its set of dependencies.
              deps[a] contains b means "theorem a depends on theorem b".
    
    Example:
        >>> ds = DepSystem({'A', 'B', 'C'}, {'A': set(), 'B': {'A'}, 'C': {'B'}})
        >>> ds.dep_level('C')
        2
    """
    
    def __init__(self, nodes: set[T], deps: dict[T, set[T]]):
        self.nodes = nodes
        self.deps = {n: deps.get(n, set()) for n in nodes}
        self._validate_acyclicity()
        self._level_cache: dict[T, int] = {}
    
    def _validate_acyclicity(self) -> None:
        """Verify the dependency relation is acyclic using DFS."""
        WHITE, GRAY, BLACK = 0, 1, 2
        color = {n: WHITE for n in self.nodes}
        
        def dfs(u: T) -> None:
            color[u] = GRAY
            for v in self.deps[u]:
                if color[v] == GRAY:
                    raise ValueError(f"Cycle detected involving {u} -> {v}")
                if color[v] == WHITE:
                    dfs(v)
            color[u] = BLACK
        
        for n in self.nodes:
            if color[n] == WHITE:
                dfs(n)
    
    def dep_level(self, t: T) -> int:
        """Compute the dependency level of theorem t.
        
        The dependency level is the length of the longest dependency chain
        ending at t. Equals 0 for dependency-free theorems.
        
        Time complexity: O(|V| + |E|) amortized over all calls (memoized).
        
        Args:
            t: A theorem label in the system.
            
        Returns:
            The dependency level (non-negative integer).
            
        Example:
            >>> ds = DepSystem({'A', 'B', 'C'}, {'A': set(), 'B': {'A'}, 'C': {'A', 'B'}})
            >>> ds.dep_level('A'), ds.dep_level('B'), ds.dep_level('C')
            (0, 1, 2)
        """
        if t in self._level_cache:
            return self._level_cache[t]
        
        if not self.deps[t]:
            self._level_cache[t] = 0
            return 0
        
        level = max(self.dep_level(s) + 1 for s in self.deps[t])
        self._level_cache[t] = level
        return level
    
    def all_levels(self) -> dict[T, int]:
        """Compute dependency levels for all theorems.
        
        Returns:
            Dictionary mapping each theorem to its dependency level.
        """
        return {t: self.dep_level(t) for t in self.nodes}
    
    def max_level(self) -> int:
        """The maximum dependency level across all theorems."""
        if not self.nodes:
            return 0
        return max(self.dep_level(t) for t in self.nodes)
    
    def stage_knowledge(self, n: int) -> set[T]:
        """Compute the set of theorems known at stage n.
        
        A theorem is known at stage n iff its dependency level is ≤ n.
        
        Args:
            n: The stage number (non-negative integer).
            
        Returns:
            Set of theorems known at stage n.
        """
        return {t for t in self.nodes if self.dep_level(t) <= n}
    
    def curriculum_ranking(self) -> list[tuple[T, int]]:
        """Generate an optimal curriculum ranking.
        
        Returns theorems sorted by dependency level (breaking ties alphabetically
        if labels are comparable), paired with their levels.
        
        Returns:
            List of (theorem, level) pairs in curriculum order.
        """
        levels = self.all_levels()
        return sorted(levels.items(), key=lambda x: (x[1], str(x[0])))
    
    def topological_sort(self) -> list[T]:
        """Produce a topological ordering (valid curriculum sequence).
        
        Uses Kahn's algorithm. Returns a list where dependencies always
        appear before the theorems that depend on them.
        
        Time complexity: O(|V| + |E|).
        
        Returns:
            List of theorem labels in valid curriculum order.
        """
        in_degree = {n: 0 for n in self.nodes}
        reverse_deps: dict[T, set[T]] = {n: set() for n in self.nodes}
        
        for n in self.nodes:
            for d in self.deps[n]:
                reverse_deps[d].add(n)
                in_degree[n] += 1
        
        queue = sorted([n for n in self.nodes if in_degree[n] == 0], key=str)
        result = []
        
        while queue:
            node = queue.pop(0)
            result.append(node)
            for dependent in sorted(reverse_deps[node], key=str):
                in_degree[dependent] -= 1
                if in_degree[dependent] == 0:
                    queue.append(dependent)
                    queue.sort(key=str)
        
        return result
    
    def frontier_depth(self, frontier: set[T]) -> int:
        """Compute the frontier depth: max(dep_level(t) + 1) over frontier theorems.
        
        This is the number of research cycles needed to prove all frontier theorems.
        
        Args:
            frontier: Set of target theorem labels.
            
        Returns:
            The frontier depth (positive integer if frontier is non-empty, 0 otherwise).
        """
        if not frontier:
            return 0
        return max(self.dep_level(t) + 1 for t in frontier)
    
    def level_decomposition(self) -> dict[int, set[T]]:
        """Decompose theorems by level.
        
        Returns:
            Dictionary mapping each level to the set of theorems at that level.
        """
        decomp: dict[int, set[T]] = defaultdict(set)
        for t in self.nodes:
            decomp[self.dep_level(t)].add(t)
        return dict(decomp)
    
    def critical_path(self, target: T) -> list[T]:
        """Find a longest dependency chain ending at target.
        
        This witnesses that dep_level(target) equals the chain length.
        
        Args:
            target: The target theorem.
            
        Returns:
            List of theorems forming the critical path, from leaf to target.
        """
        if not self.deps[target]:
            return [target]
        
        max_dep = max(self.deps[target], key=lambda s: self.dep_level(s))
        return self.critical_path(max_dep) + [target]
    
    def parallel_schedule(self) -> list[set[T]]:
        """Generate an optimal parallel research schedule.
        
        Each "round" contains theorems that can be proved simultaneously
        (all their dependencies were proved in earlier rounds).
        
        Returns:
            List of sets, where round[i] contains theorems proved at stage i.
        """
        decomp = self.level_decomposition()
        return [decomp.get(i, set()) for i in range(self.max_level() + 1)]
    
    def curriculum_count_lower_bound(self) -> int:
        """Lower bound on the number of valid curriculum orderings.
        
        By the level decomposition theorem, any permutation of theorems
        within the same level gives a valid curriculum. The count is
        at least prod(|A_k|!) over all levels k.
        
        Returns:
            Lower bound on valid curriculum count.
        """
        import math
        decomp = self.level_decomposition()
        result = 1
        for level_set in decomp.values():
            result *= math.factorial(len(level_set))
        return result


def merge_systems(sys1: DepSystem[T], sys2: DepSystem[T],
                  cross_deps: dict[T, set[T]]) -> DepSystem[T]:
    """Merge two dependency systems with cross-system dependencies.
    
    Args:
        sys1, sys2: Two dependency systems with disjoint node sets.
        cross_deps: Additional dependencies between the systems.
        
    Returns:
        The merged dependency system.
    """
    nodes = sys1.nodes | sys2.nodes
    deps = {}
    for n in sys1.nodes:
        deps[n] = sys1.deps[n] | cross_deps.get(n, set())
    for n in sys2.nodes:
        deps[n] = sys2.deps[n] | cross_deps.get(n, set())
    return DepSystem(nodes, deps)


if __name__ == "__main__":
    # Example: A small mathematical theory
    print("=== Example: Linear Algebra Curriculum ===\n")
    
    nodes = {
        'vector_space', 'linear_map', 'kernel', 'image',
        'dimension', 'rank_nullity', 'eigenvalue',
        'characteristic_poly', 'cayley_hamilton'
    }
    deps = {
        'vector_space': set(),
        'linear_map': {'vector_space'},
        'kernel': {'linear_map'},
        'image': {'linear_map'},
        'dimension': {'vector_space'},
        'rank_nullity': {'kernel', 'image', 'dimension'},
        'eigenvalue': {'linear_map', 'dimension'},
        'characteristic_poly': {'eigenvalue'},
        'cayley_hamilton': {'characteristic_poly', 'rank_nullity'},
    }
    
    ds = DepSystem(nodes, deps)
    
    print("Dependency Levels:")
    for t, level in ds.curriculum_ranking():
        print(f"  Level {level}: {t}")
    
    print(f"\nMaximum level: {ds.max_level()}")
    print(f"\nCritical path to cayley_hamilton: {' → '.join(ds.critical_path('cayley_hamilton'))}")
    
    print("\nParallel Schedule:")
    for i, round_set in enumerate(ds.parallel_schedule()):
        print(f"  Round {i}: {', '.join(sorted(round_set))}")
    
    print(f"\nTopological sort: {ds.topological_sort()}")
    print(f"\nLower bound on valid curricula: {ds.curriculum_count_lower_bound()}")
    
    frontier = {'cayley_hamilton', 'rank_nullity'}
    print(f"\nFrontier depth for {frontier}: {ds.frontier_depth(frontier)} cycles")
