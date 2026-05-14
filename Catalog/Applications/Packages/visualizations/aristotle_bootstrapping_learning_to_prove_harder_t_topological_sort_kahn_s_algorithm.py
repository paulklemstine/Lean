#!/usr/bin/env python3
"""
Curriculum Complexity — Core Algorithms

Implements the algorithms described in the research paper on curriculum
complexity of mathematical theories.

All algorithms operate on dependency systems represented as DAGs.
"""

from typing import Dict, List, Set, Tuple, Optional
from collections import defaultdict, deque
import heapq


class DependencySystem:
    """
    A finite acyclic dependency system (T, DependsOn).

    Represents a collection of theorems with prerequisite relationships.
    DependsOn(a, b) means theorem a requires theorem b.

    Attributes:
        theorems: Set of theorem labels
        deps: Dict mapping each theorem to its list of dependencies
        reverse_deps: Dict mapping each theorem to theorems that depend on it

    Example:
        >>> ds = DependencySystem({"C": ["A", "B"], "B": ["A"], "A": []})
        >>> ds.is_acyclic()
        True
        >>> ds.level("C")
        2
    """

    def __init__(self, deps: Dict[str, List[str]]):
        """
        Initialize from a dependency dictionary.

        Args:
            deps: Maps theorem name to list of its prerequisites.
                  Theorems with no prerequisites map to [].

        Raises:
            ValueError: If the dependency graph contains a cycle.
        """
        self.deps = {}
        self.theorems: Set[str] = set()
        self.reverse_deps: Dict[str, List[str]] = defaultdict(list)

        # Collect all theorems
        for t, dep_list in deps.items():
            self.theorems.add(t)
            for d in dep_list:
                self.theorems.add(d)

        # Initialize deps for all theorems
        for t in self.theorems:
            self.deps[t] = list(deps.get(t, []))

        # Build reverse dependency graph
        for t, dep_list in self.deps.items():
            for d in dep_list:
                self.reverse_deps[d].append(t)

        if not self.is_acyclic():
            raise ValueError("Dependency system contains a cycle")

        self._levels: Optional[Dict[str, int]] = None
        self._stages: Optional[Dict[int, Set[str]]] = None

    def is_acyclic(self) -> bool:
        """
        Check if the dependency graph is acyclic using DFS.

        Time complexity: O(|T| + |E|) where E is the number of dependency edges.

        Returns:
            True if the graph is a DAG, False otherwise.
        """
        WHITE, GRAY, BLACK = 0, 1, 2
        color = {t: WHITE for t in self.theorems}

        def dfs(t: str) -> bool:
            color[t] = GRAY
            for d in self.deps[t]:
                if color[d] == GRAY:
                    return False  # Back edge = cycle
                if color[d] == WHITE and not dfs(d):
                    return False
            color[t] = BLACK
            return True

        return all(dfs(t) for t in self.theorems if color[t] == WHITE)

    def level(self, t: str) -> int:
        """
        Compute the dependency depth (level) of theorem t.

        The level is the length of the longest dependency chain ending at t.
        Equivalent to the minimum stage at which t becomes provable.

        Time complexity: O(|T| + |E|) for first call (cached thereafter).

        Args:
            t: Theorem label

        Returns:
            Non-negative integer depth

        >>> ds = DependencySystem({"C": ["A", "B"], "B": ["A"], "A": []})
        >>> ds.level("A"), ds.level("B"), ds.level("C")
        (0, 1, 2)
        """
        if self._levels is None:
            self._compute_all_levels()
        return self._levels[t]

    def _compute_all_levels(self):
        """Compute levels for all theorems via memoized recursion."""
        self._levels = {}

        def _compute(t: str) -> int:
            if t in self._levels:
                return self._levels[t]
            if not self.deps[t]:
                self._levels[t] = 0
            else:
                self._levels[t] = max(_compute(d) for d in self.deps[t]) + 1
            return self._levels[t]

        for t in self.theorems:
            _compute(t)

    def stage_knowledge(self, n: int) -> Set[str]:
        """
        Compute the set of theorems provable at stage n.

        Stage 0: theorems with no dependencies
        Stage n+1: theorems whose dependencies are all provable at stage n

        This is monotone: stage_knowledge(n) ⊆ stage_knowledge(n+1).

        Time complexity: O(n * |T| * max_degree)

        Args:
            n: Stage number (non-negative integer)

        Returns:
            Set of theorem labels provable at stage n
        """
        if self._stages is None:
            self._stages = {}

        for k in range(n + 1):
            if k not in self._stages:
                if k == 0:
                    self._stages[k] = {t for t in self.theorems if not self.deps[t]}
                else:
                    prev = self.stage_knowledge(k - 1)
                    self._stages[k] = {t for t in self.theorems
                                       if all(d in prev for d in self.deps[t])}
        return self._stages[n]

    def curriculum(self) -> List[str]:
        """
        Compute a valid curriculum (topological sort respecting dependencies).

        The curriculum orders theorems so that every theorem appears after
        all its prerequisites. This is guaranteed to exist by the
        Curriculum Existence Theorem.

        Time complexity: O(|T| log |T| + |E|)

        Returns:
            List of theorem labels in curriculum order

        >>> ds = DependencySystem({"C": ["A", "B"], "B": ["A"], "A": []})
        >>> c = ds.curriculum()
        >>> c.index("A") < c.index("B") < c.index("C")
        True
        """
        return sorted(self.theorems, key=lambda t: (self.level(t), t))

    def max_level(self) -> int:
        """
        Maximum level across all theorems.

        This equals the stabilization stage minus one: knowledge stabilizes
        at stage max_level, and max_level + 1 sequential research cycles
        suffice to prove everything.

        Returns:
            Non-negative integer
        """
        return max(self.level(t) for t in self.theorems)

    def frontier_depth(self, frontier: Set[str]) -> int:
        """
        Compute the frontier depth: minimum stages to cover all frontier theorems.

        By the Frontier Optimality Theorem, this equals max(level(t) for t in frontier).
        No curriculum can do better, and this bound is achieved.

        Args:
            frontier: Set of target theorem labels

        Returns:
            Non-negative integer

        >>> ds = DependencySystem({"C": ["A", "B"], "B": ["A"], "A": [], "D": []})
        >>> ds.frontier_depth({"C", "D"})
        2
        """
        if not frontier:
            return 0
        return max(self.level(t) for t in frontier)

    def stabilization_stage(self) -> int:
        """
        Find the stage at which knowledge stabilizes to the full set.

        By the Stabilization Theorem, this is at most |T|.
        In practice, it equals max_level.

        Returns:
            Stage number N such that stage_knowledge(n) = theorems for all n >= N
        """
        return self.max_level()

    def strict_growth_stages(self) -> List[int]:
        """
        Find all stages where knowledge strictly increases.

        By the Bootstrapping Strictness Theorem, stage n+1 strictly extends
        stage n whenever there exists a theorem at level n+1.

        Returns:
            List of stage numbers where new theorems are added
        """
        levels_set = set(self.level(t) for t in self.theorems)
        return sorted(levels_set)

    def dependency_chain(self, t: str) -> List[str]:
        """
        Find a maximal dependency chain ending at t.

        The length of this chain equals level(t).

        Args:
            t: Theorem label

        Returns:
            List from deepest dependency to t
        """
        chain = [t]
        current = t
        while self.deps[current]:
            # Pick the dependency with maximum level
            next_dep = max(self.deps[current], key=lambda d: self.level(d))
            chain.append(next_dep)
            current = next_dep
        return list(reversed(chain))

    def parallel_schedule(self) -> Dict[int, Set[str]]:
        """
        Compute the optimal parallel research schedule.

        Groups theorems by level. All theorems at the same level can be
        proved in parallel once the previous level is complete.

        This achieves the theoretical minimum number of sequential cycles.

        Returns:
            Dict mapping stage number to set of theorems provable at that stage
            (but not earlier)
        """
        schedule: Dict[int, Set[str]] = defaultdict(set)
        for t in self.theorems:
            schedule[self.level(t)].add(t)
        return dict(schedule)

    def summary(self) -> str:
        """Generate a summary of the dependency system's curriculum complexity."""
        lines = [
            f"Dependency System Summary",
            f"  Theorems: {len(self.theorems)}",
            f"  Dependencies: {sum(len(d) for d in self.deps.values())}",
            f"  Max level: {self.max_level()}",
            f"  Stabilization stage: {self.stabilization_stage()}",
            f"  Strict growth stages: {self.strict_growth_stages()}",
        ]

        schedule = self.parallel_schedule()
        lines.append(f"\n  Parallel schedule ({len(schedule)} rounds):")
        for stage in sorted(schedule):
            lines.append(f"    Round {stage}: {sorted(schedule[stage])}")

        return "\n".join(lines)


# ============================================================================
# Kahn's Algorithm for Topological Sort
# ============================================================================

def kahns_topological_sort(deps: Dict[str, List[str]]) -> Optional[List[str]]:
    """
    Kahn's algorithm for topological sorting.

    Classical BFS-based topological sort that simultaneously verifies acyclicity.

    Time complexity: O(|T| + |E|)
    Space complexity: O(|T| + |E|)

    Pseudocode:
        1. Compute in-degrees for all nodes
        2. Initialize queue with all nodes of in-degree 0
        3. While queue is non-empty:
           a. Dequeue node u
           b. Add u to result
           c. For each successor v of u:
              - Decrement in-degree of v
              - If in-degree becomes 0, enqueue v
        4. If result contains all nodes, return it; else cycle exists

    Args:
        deps: Dependency dictionary (theorem -> list of prerequisites)

    Returns:
        Topological ordering if acyclic, None if cyclic

    >>> kahns_topological_sort({"C": ["A", "B"], "B": ["A"], "A": []})
    ['A', 'B', 'C']
    """
    # Collect all nodes
    all_nodes = set(deps.keys())
    for dep_list in deps.values():
        all_nodes.update(dep_list)
    for n in all_nodes:
        if n not in deps:
            deps[n] = []

    # Compute in-degrees (number of prerequisites)
    in_degree = {n: 0 for n in all_nodes}
    reverse = defaultdict(list)
    for t, dep_list in deps.items():
        in_degree[t] = len(dep_list)
        for d in dep_list:
            reverse[d].append(t)

    # Initialize with nodes having no prerequisites
    queue = deque(sorted(n for n in all_nodes if in_degree[n] == 0))
    result = []

    while queue:
        node = queue.popleft()
        result.append(node)

        for successor in sorted(reverse[node]):
            in_degree[successor] -= 1
            if in_degree[successor] == 0:
                queue.append(successor)

    if len(result) != len(all_nodes):
        return None  # Cycle detected

    return result


# ============================================================================
# Longest Path Algorithm for Level Computation
# ============================================================================

def longest_path_levels(deps: Dict[str, List[str]]) -> Dict[str, int]:
    """
    Compute theorem levels via longest path in the dependency DAG.

    Uses topological sort followed by dynamic programming.

    Time complexity: O(|T| + |E|)
    Space complexity: O(|T|)

    Pseudocode:
        1. Topologically sort the theorems
        2. Initialize all levels to 0
        3. Process theorems in topological order:
           For each dependency d of theorem t:
             level[t] = max(level[t], level[d] + 1)

    Args:
        deps: Dependency dictionary

    Returns:
        Dict mapping theorem to its level

    >>> longest_path_levels({"C": ["A", "B"], "B": ["A"], "A": []})
    {'A': 0, 'B': 1, 'C': 2}
    """
    order = kahns_topological_sort(deps)
    if order is None:
        raise ValueError("Cyclic dependency graph")

    levels = {t: 0 for t in order}
    for t in order:
        for d in deps.get(t, []):
            levels[t] = max(levels[t], levels[d] + 1)

    return levels


if __name__ == "__main__":
    # Example: A research program in algebraic topology
    research_program = {
        "Point-Set Topology": [],
        "Group Theory": [],
        "Homotopy": ["Point-Set Topology"],
        "Homological Algebra": ["Group Theory"],
        "Fundamental Group": ["Homotopy", "Group Theory"],
        "Singular Homology": ["Homological Algebra", "Point-Set Topology"],
        "Covering Spaces": ["Fundamental Group"],
        "Excision": ["Singular Homology"],
        "Mayer-Vietoris": ["Singular Homology", "Excision"],
        "Hurewicz Theorem": ["Fundamental Group", "Singular Homology"],
        "Eilenberg-Steenrod": ["Mayer-Vietoris", "Excision"],
    }

    ds = DependencySystem(research_program)
    print(ds.summary())

    print("\nCurriculum (valid learning order):")
    for i, t in enumerate(ds.curriculum()):
        print(f"  {i+1}. {t} (level {ds.level(t)})")

    frontier = {"Eilenberg-Steenrod", "Hurewicz Theorem"}
    print(f"\nFrontier: {frontier}")
    print(f"Frontier depth: {ds.frontier_depth(frontier)}")
    print(f"Required research cycles: {ds.frontier_depth(frontier) + 1}")

    print("\nMaximal dependency chain to Eilenberg-Steenrod:")
    chain = ds.dependency_chain("Eilenberg-Steenrod")
    print(f"  {' → '.join(chain)} (length {len(chain) - 1})")
