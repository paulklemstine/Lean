#!/usr/bin/env python3
"""
Algorithms for Certified Intervention Sequencing

Implements the core algorithms from the research paper:
1. Keystone detection (O(k·n))
2. Disjointness verification (O(k²·n))
3. Incremental transversal enumeration
4. Brute-force minimal hitting set enumeration
5. Pareto frontier computation
"""

from __future__ import annotations
from itertools import combinations
from typing import Any
from collections import defaultdict


class BottleneckSystem:
    """
    A multi-objective bottleneck system.

    Attributes:
        objectives: list of objective names
        components: set of component identifiers
        bottlenecks: dict mapping objective -> set of bottleneck components
    """

    def __init__(self, bottlenecks: dict[Any, set[Any]]):
        """
        Initialize from a dict of objective -> bottleneck set.

        Args:
            bottlenecks: {objective_name: {component, ...}, ...}
        """
        self.bottlenecks = {k: set(v) for k, v in bottlenecks.items()}
        self.objectives = list(self.bottlenecks.keys())
        self.components = set().union(*self.bottlenecks.values())

    def gain(self, objective: Any, plan: set) -> int:
        """Binary gain: 1 if plan intersects the bottleneck set, else 0."""
        return 1 if plan & self.bottlenecks[objective] else 0

    def score_vector(self, plan: set) -> tuple[int, ...]:
        """Compute the full score vector for a plan."""
        return tuple(self.gain(obj, plan) for obj in self.objectives)

    def improves_all(self, plan: set) -> bool:
        """Check if plan achieves gain 1 for every objective."""
        return all(self.gain(obj, plan) == 1 for obj in self.objectives)

    def is_hitting_set(self, plan: set) -> bool:
        """Check if plan intersects every bottleneck set."""
        return all(plan & self.bottlenecks[obj] for obj in self.objectives)

    def is_minimal_hitting_set(self, plan: set) -> bool:
        """Check if plan is a minimal hitting set."""
        if not self.is_hitting_set(plan):
            return False
        for elem in plan:
            if self.is_hitting_set(plan - {elem}):
                return False
        return True

    def pareto_dominates(self, S: set, T: set) -> bool:
        """Check if S Pareto-dominates T (weakly better everywhere, strictly somewhere)."""
        scores_S = self.score_vector(S)
        scores_T = self.score_vector(T)
        weakly = all(s >= t for s, t in zip(scores_S, scores_T))
        strictly = any(s > t for s, t in zip(scores_S, scores_T))
        return weakly and strictly

    # =========================================================================
    # Algorithm 1: Keystone Detection — O(k·n)
    # =========================================================================
    def find_keystones(self) -> set:
        """
        Find all keystone elements (common intersection of all bottleneck sets).

        Returns:
            Set of elements in every bottleneck set.

        Complexity: O(k·n) where k = |objectives|, n = |components|
        """
        if not self.bottlenecks:
            return set()
        return set.intersection(*self.bottlenecks.values())

    # =========================================================================
    # Algorithm 2: Disjointness Verification — O(k²·n)
    # =========================================================================
    def check_pairwise_disjoint(self) -> tuple[bool, list[tuple]]:
        """
        Check if bottleneck sets are pairwise disjoint.

        Returns:
            (is_disjoint, list_of_overlapping_pairs)

        Complexity: O(k²·n)
        """
        overlaps = []
        for i, obj_i in enumerate(self.objectives):
            for j, obj_j in enumerate(self.objectives):
                if i < j:
                    overlap = self.bottlenecks[obj_i] & self.bottlenecks[obj_j]
                    if overlap:
                        overlaps.append((obj_i, obj_j, overlap))
        return (len(overlaps) == 0, overlaps)

    def disjointness_lower_bound(self) -> int:
        """
        Compute the disjointness-based lower bound on hitting set size.

        If pairwise disjoint, returns |objectives|.
        Otherwise, returns the size of the maximum pairwise-disjoint subfamily.

        Complexity: O(k²·n)
        """
        is_disj, _ = self.check_pairwise_disjoint()
        if is_disj:
            return len(self.objectives)
        # Greedy: find max independent set in overlap graph
        used_components = set()
        count = 0
        for obj in self.objectives:
            if not (self.bottlenecks[obj] & used_components):
                used_components |= self.bottlenecks[obj]
                count += 1
        return count

    # =========================================================================
    # Algorithm 3: Brute-Force Minimal Hitting Set Enumeration — O(2^n · k · n)
    # =========================================================================
    def enumerate_minimal_hitting_sets_brute(self) -> list[frozenset]:
        """
        Enumerate all minimal hitting sets by brute force.

        Complexity: O(2^n · k · n). Only practical for n ≤ 25.

        Returns:
            List of frozensets, each a minimal hitting set.
        """
        components = sorted(self.components)
        n = len(components)
        results = []
        found_sizes = set()

        for size in range(1, n + 1):
            for combo in combinations(components, size):
                S = set(combo)
                if self.is_hitting_set(S):
                    if self.is_minimal_hitting_set(S):
                        results.append(frozenset(S))
        return results

    # =========================================================================
    # Algorithm 4: Incremental Transversal Construction
    # =========================================================================
    def enumerate_minimal_hitting_sets_incremental(self) -> list[frozenset]:
        """
        Enumerate all minimal hitting sets by incremental construction.

        Adds one bottleneck set at a time and maintains the set of
        minimal transversals.

        Complexity: Output-sensitive. Efficient when output is small.

        Returns:
            List of frozensets, each a minimal hitting set.
        """
        if not self.objectives:
            return [frozenset()]

        # Start with transversals of first bottleneck set
        first_obj = self.objectives[0]
        current = [frozenset({b}) for b in self.bottlenecks[first_obj]]

        for obj in self.objectives[1:]:
            B_i = self.bottlenecks[obj]
            candidates = []

            for S in current:
                if S & B_i:
                    # S already hits B_i
                    candidates.append(S)
                else:
                    # Extend S with each element of B_i
                    for b in B_i:
                        candidates.append(S | {b})

            # Remove non-minimal sets
            current = self._minimize(candidates)

        return current

    @staticmethod
    def _minimize(sets: list[frozenset]) -> list[frozenset]:
        """Remove non-minimal sets from a collection."""
        sorted_sets = sorted(sets, key=len)
        minimal = []
        for s in sorted_sets:
            if not any(m < s for m in minimal):
                minimal.append(s)
        return minimal

    # =========================================================================
    # Algorithm 5: Full Pareto Frontier Computation
    # =========================================================================
    def compute_pareto_frontier(self) -> list[frozenset]:
        """
        Compute the Pareto frontier = minimal hitting sets.

        Uses the incremental algorithm.

        Returns:
            List of frozensets, each a Pareto-optimal plan.
        """
        return self.enumerate_minimal_hitting_sets_incremental()

    # =========================================================================
    # Analysis and Reporting
    # =========================================================================
    def analyze(self) -> dict:
        """
        Complete analysis of the bottleneck system.

        Returns dict with:
            - keystones: set of keystone elements
            - is_disjoint: bool
            - overlaps: list of overlapping pairs
            - lower_bound: minimum hitting set size
            - pareto_frontier: list of Pareto-optimal plans
            - min_plan_size: size of smallest Pareto-optimal plan
            - max_plan_size: size of largest Pareto-optimal plan
        """
        keystones = self.find_keystones()
        is_disj, overlaps = self.check_pairwise_disjoint()
        lb = self.disjointness_lower_bound()
        frontier = self.compute_pareto_frontier()

        return {
            'keystones': keystones,
            'is_disjoint': is_disj,
            'overlaps': overlaps,
            'lower_bound': lb,
            'pareto_frontier': frontier,
            'min_plan_size': min(len(s) for s in frontier) if frontier else 0,
            'max_plan_size': max(len(s) for s in frontier) if frontier else 0,
            'num_pareto_plans': len(frontier),
        }

    def report(self) -> str:
        """Generate a human-readable analysis report."""
        analysis = self.analyze()
        lines = []
        lines.append("=" * 60)
        lines.append("BOTTLENECK SYSTEM ANALYSIS REPORT")
        lines.append("=" * 60)
        lines.append(f"\nObjectives: {len(self.objectives)}")
        lines.append(f"Components: {len(self.components)}")

        lines.append("\nBottleneck Sets:")
        for obj in self.objectives:
            lines.append(f"  {obj}: {sorted(self.bottlenecks[obj])}")

        lines.append(f"\nKeystone Elements: {sorted(analysis['keystones']) or 'None'}")

        if analysis['is_disjoint']:
            lines.append(f"\nBottleneck sets are PAIRWISE DISJOINT")
            lines.append(f"  → Minimum plan size: {analysis['lower_bound']} (certified)")
            lines.append(f"  → No universal singleton exists (certified)")
        else:
            lines.append(f"\nOverlapping pairs:")
            for obj_i, obj_j, overlap in analysis['overlaps']:
                lines.append(f"  {obj_i} ∩ {obj_j} = {sorted(overlap)}")

        lines.append(f"\nPareto-Optimal Plans ({analysis['num_pareto_plans']} total):")
        for plan in sorted(analysis['pareto_frontier'], key=lambda x: (len(x), sorted(x))):
            lines.append(f"  {sorted(plan)} (size {len(plan)})")

        lines.append(f"\nPlan size range: [{analysis['min_plan_size']}, {analysis['max_plan_size']}]")
        lines.append("=" * 60)
        return "\n".join(lines)


# =============================================================================
# Weighted Extension
# =============================================================================
class WeightedBottleneckSystem(BottleneckSystem):
    """
    Bottleneck system with component costs.
    """

    def __init__(self, bottlenecks: dict[Any, set], weights: dict[Any, float]):
        super().__init__(bottlenecks)
        self.weights = weights

    def plan_cost(self, plan: set) -> float:
        """Total cost of a plan."""
        return sum(self.weights.get(c, 0) for c in plan)

    def min_cost_pareto_plans(self) -> list[tuple[frozenset, float]]:
        """
        Find minimum-cost Pareto-optimal plans.

        Returns list of (plan, cost) sorted by cost.
        """
        frontier = self.compute_pareto_frontier()
        costed = [(plan, self.plan_cost(plan)) for plan in frontier]
        costed.sort(key=lambda x: x[1])
        return costed


if __name__ == "__main__":
    # Example: Water network
    system = BottleneckSystem({
        'Pressure':      {'J3', 'P1', 'M7'},
        'Contamination': {'T2', 'J3', 'F4'},
        'Drought':       {'R1', 'J3', 'W2'},
    })
    print(system.report())

    # Example: Disjoint system
    print()
    system2 = BottleneckSystem({
        'Throughput':  {'A1', 'A2'},
        'Latency':     {'B1', 'B2'},
        'Reliability': {'C1', 'C2'},
    })
    print(system2.report())

    # Example: Weighted system
    print()
    wsystem = WeightedBottleneckSystem(
        bottlenecks={
            'Speed':   {'a', 'b', 'c'},
            'Quality': {'b', 'd'},
            'Cost':    {'c', 'e'},
        },
        weights={'a': 10, 'b': 5, 'c': 8, 'd': 12, 'e': 3}
    )
    print("\nWeighted System — Min-Cost Pareto Plans:")
    for plan, cost in wsystem.min_cost_pareto_plans():
        print(f"  {sorted(plan)}: cost = {cost}")
