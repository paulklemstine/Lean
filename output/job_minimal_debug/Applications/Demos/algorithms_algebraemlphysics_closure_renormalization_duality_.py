#!/usr/bin/env python3
"""
Algorithms for Closure Renormalization Duality

Implements the core algorithms from the research paper:
1. Profile axiom verification  — O(N² · 2^|α| · |α|)
2. Canonical semimodule construction
3. RG-flow DAG construction
4. Fixed-point extraction — O(|V|²)
5. C-theorem functional computation
"""

from itertools import combinations
from typing import Dict, List, Set, Tuple, Optional, Callable
from dataclasses import dataclass


def powerset(elements: list) -> List[frozenset]:
    """All subsets of a list, as frozensets, sorted by size."""
    result = []
    for r in range(len(elements) + 1):
        for combo in combinations(elements, r):
            result.append(frozenset(combo))
    return result


@dataclass
class ProfileAxiomResult:
    """Result of checking profile axioms."""
    scale_monotone: bool
    obs_monotone: bool
    subadditive: bool
    normalized: bool
    exchange: bool
    violations: List[str]

    @property
    def all_satisfied(self) -> bool:
        return (self.scale_monotone and self.obs_monotone and
                self.subadditive and self.normalized and self.exchange)


def verify_profile_axioms(
    N: int,
    elements: list,
    P: Callable[[int, frozenset], int]
) -> ProfileAxiomResult:
    """
    Verify all five profile axioms.

    Algorithm 1 from the research paper.
    Time complexity: O(N² · 2^|α| · |α|)

    Args:
        N: Number of scales
        elements: List of elements in the base set
        P: Profile function P(scale, observable_set) -> weight

    Returns:
        ProfileAxiomResult with detailed status
    """
    subsets = powerset(elements)
    violations = []

    # 1. Scale monotonicity
    scale_mono = True
    for s in subsets:
        for m in range(N):
            for n in range(m, N):
                if P(m, s) > P(n, s):
                    scale_mono = False
                    violations.append(f"ScaleMono: P({m},{set(s)})={P(m,s)} > P({n},{set(s)})={P(n,s)}")

    # 2. Observable monotonicity
    obs_mono = True
    for n in range(N):
        for i, s in enumerate(subsets):
            for t in subsets[i:]:
                if s <= t and P(n, s) > P(n, t):
                    obs_mono = False
                    violations.append(f"ObsMono: P({n},{set(s)})={P(n,s)} > P({n},{set(t)})={P(n,t)}")

    # 3. Subadditivity
    subadditive = True
    for n in range(N):
        for s in subsets:
            for t in subsets:
                if P(n, s | t) > P(n, s) + P(n, t):
                    subadditive = False
                    violations.append(f"Subadd: P({n},{set(s|t)})={P(n,s|t)} > {P(n,s)}+{P(n,t)}")

    # 4. Normalization
    normalized = True
    empty = frozenset()
    for n in range(N):
        if P(n, empty) != 0:
            normalized = False
            violations.append(f"Norm: P({n},∅)={P(n,empty)} ≠ 0")

    # 5. Exchange
    exchange = True
    for m in range(N):
        for n in range(m, N):
            for s in subsets:
                for a in elements:
                    s_a = s | frozenset([a])
                    a_set = frozenset([a])
                    if P(m, s_a) > P(m, s) + P(n, a_set):
                        exchange = False
                        violations.append(
                            f"Exchange: P({m},{set(s_a)})={P(m,s_a)} > "
                            f"P({m},{set(s)})={P(m,s)} + P({n},{{{a}}})={P(n,a_set)}")

    return ProfileAxiomResult(
        scale_monotone=scale_mono,
        obs_monotone=obs_mono,
        subadditive=subadditive,
        normalized=normalized,
        exchange=exchange,
        violations=violations[:10]  # Limit to first 10 violations
    )


@dataclass
class IdempotentScaleSemimodule:
    """
    Canonical idempotent scale semimodule constructed from a valid profile.

    This is the constructive witness from Theorem A (sufficiency):
    when all axioms hold, the profile itself serves as the semimodule weight.
    """
    N: int
    elements: list
    weight: Callable[[int, frozenset], int]

    @classmethod
    def from_profile(cls, N: int, elements: list, P: Callable[[int, frozenset], int]):
        """Construct the canonical semimodule (Theorem A sufficiency)."""
        return cls(N=N, elements=elements, weight=P)

    def realizes(self, P: Callable[[int, frozenset], int]) -> bool:
        """Check if this semimodule realizes a profile."""
        subsets = powerset(self.elements)
        return all(self.weight(n, s) == P(n, s) for n in range(self.N) for s in subsets)


@dataclass
class RGFlowDAG:
    """
    RG-flow directed acyclic graph.

    Vertices represent effective states at different scales.
    Edges represent coarse-graining transitions with transfer costs.
    """
    num_verts: int
    scales: List[int]
    edge_weights: List[List[int]]

    def vertex_cost(self, v: int) -> int:
        """Φ(v) = sum of outgoing edge weights. O(|V|)."""
        return sum(self.edge_weights[v])

    def all_vertex_costs(self) -> List[int]:
        """Compute all vertex costs. O(|V|²)."""
        return [self.vertex_cost(v) for v in range(self.num_verts)]

    def extract_fixed_points(self) -> List[int]:
        """
        Algorithm 2: Extract fixed-point strata.
        Time complexity: O(|V|²).
        Returns list of sink vertex indices.
        """
        return [v for v in range(self.num_verts)
                if all(self.edge_weights[v][u] == 0 for u in range(self.num_verts))]

    def is_acyclic(self) -> bool:
        """Verify DAG acyclicity via scale ordering."""
        for u in range(self.num_verts):
            for v in range(self.num_verts):
                if self.edge_weights[u][v] > 0 and self.scales[u] >= self.scales[v]:
                    return False
        return True

    def is_transfer_bounded(self) -> bool:
        """Check transfer bound: Φ(v) + w(u,v) ≤ Φ(u) for all edges."""
        costs = self.all_vertex_costs()
        for u in range(self.num_verts):
            for v in range(self.num_verts):
                w = self.edge_weights[u][v]
                if w > 0 and costs[v] + w > costs[u]:
                    return False
        return True

    def verify_c_theorem(self) -> Dict:
        """
        Verify the discrete c-theorem.

        Returns dict with:
        - monotone: True if Φ strictly decreases along all edges
        - fixed_point_characterization: True if sinks ↔ zero cost
        """
        costs = self.all_vertex_costs()
        sinks = self.extract_fixed_points()

        monotone = all(
            costs[v] < costs[u]
            for u in range(self.num_verts)
            for v in range(self.num_verts)
            if self.edge_weights[u][v] > 0
        )

        sink_set = set(sinks)
        zero_set = {v for v in range(self.num_verts) if costs[v] == 0}
        fp_char = sink_set == zero_set

        return {
            "costs": costs,
            "monotone": monotone,
            "fixed_points": sinks,
            "fixed_point_characterization": fp_char,
            "transfer_bounded": self.is_transfer_bounded(),
        }


def build_canonical_dag(
    N: int,
    elements: list,
    P: Callable[[int, frozenset], int]
) -> RGFlowDAG:
    """
    Algorithm 3: Construct canonical minimal RG-flow DAG from profile.

    Creates one vertex per scale with transfer edges between consecutive scales.
    Edge weights encode the maximum capacity transfer.

    Time complexity: O(N · 2^|α|).
    """
    subsets = powerset(elements)

    # One vertex per scale
    scales = list(range(N))
    edge_weights = [[0] * N for _ in range(N)]

    # Add edges between consecutive scales
    for i in range(N - 1):
        max_transfer = 0
        for s in subsets:
            transfer = P(i + 1, s) - P(i, s)
            max_transfer = max(max_transfer, transfer)
        edge_weights[i][i + 1] = max(1, max_transfer)

    return RGFlowDAG(num_verts=N, scales=scales, edge_weights=edge_weights)


def build_closure_induced_profile(
    N: int,
    elements: list,
    closures: List[Callable[[frozenset], frozenset]],
    base_cap: Callable[[frozenset], int]
) -> Callable[[int, frozenset], int]:
    """
    Build a scale profile induced by a closure system and base capacity.

    P(n, s) = baseCap(cl_n(s))

    Time complexity: O(1) per query (closure evaluation).
    """
    def profile(n: int, s: frozenset) -> int:
        return base_cap(closures[n](s))
    return profile


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    elements = ['a', 'b', 'c']
    N = 3

    # Define a valid profile: cardinality * (scale + 1)
    def P(n, s):
        return len(s) * (n + 1)

    # 1. Verify axioms
    print("1. Profile Axiom Verification")
    result = verify_profile_axioms(N, elements, P)
    print(f"   All axioms satisfied: {result.all_satisfied}")
    for attr in ['scale_monotone', 'obs_monotone', 'subadditive', 'normalized', 'exchange']:
        print(f"   {attr}: {getattr(result, attr)}")

    # 2. Construct canonical semimodule
    print("\n2. Canonical Semimodule Construction")
    M = IdempotentScaleSemimodule.from_profile(N, elements, P)
    print(f"   Realizes profile: {M.realizes(P)}")

    # 3. Build canonical DAG
    print("\n3. Canonical RG-Flow DAG")
    dag = build_canonical_dag(N, elements, P)
    print(f"   Vertices: {dag.num_verts}")
    print(f"   Scales: {dag.scales}")
    print(f"   Edge weights: {dag.edge_weights}")

    # 4. Verify c-theorem
    print("\n4. C-Theorem Verification")
    c_result = dag.verify_c_theorem()
    print(f"   Vertex costs: {c_result['costs']}")
    print(f"   Monotone: {c_result['monotone']}")
    print(f"   Fixed points: {c_result['fixed_points']}")
    print(f"   FP characterization: {c_result['fixed_point_characterization']}")

    # 5. Closure-induced profile
    print("\n5. Closure-Induced Profile")
    closures = [
        lambda s: s,  # identity
        lambda s: s | (frozenset(['a', 'b']) if 'a' in s or 'b' in s else frozenset()),
        lambda s: frozenset(elements) if len(s) > 0 else frozenset(),
    ]
    base_cap = lambda s: len(s)
    P_induced = build_closure_induced_profile(N, elements, closures, base_cap)
    result2 = verify_profile_axioms(N, elements, P_induced)
    print(f"   All axioms satisfied: {result2.all_satisfied}")
    if result2.violations:
        print(f"   First violation: {result2.violations[0]}")
