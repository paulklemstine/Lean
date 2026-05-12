"""
Algorithms for Filtered Closure Reconstruction and Renormalization DAG Extraction.

This module implements the core algorithms from the formal framework:
- FilteredClosureSystem: scale-indexed closure operators
- ScaleDefect: defect computation between scales
- ReconstructRenormDAG: certified DAG reconstruction from observations
- ScaleSemimodule: idempotent interaction mode algebra

All algorithms match the formalized Lean 4 definitions exactly.
"""

from typing import FrozenSet, Callable, Dict, List, Tuple, Set, Optional
from dataclasses import dataclass, field
from itertools import combinations
import random


# Type aliases
Element = int
Scale = int
FSet = frozenset  # Finite set


@dataclass
class FilteredClosureSystem:
    """A filtered closure system on a finite observable space.

    Attributes:
        elements: The finite type α of observables.
        scales: The finite totally ordered type σ of scales.
        scale_closure: Function (scale, set) -> closed set.
    """
    elements: FrozenSet[Element]
    scales: List[Scale]  # sorted ascending
    _closure_fn: Callable[[Scale, FrozenSet[Element]], FrozenSet[Element]]

    def scale_closure(self, r: Scale, A: FrozenSet[Element]) -> FrozenSet[Element]:
        """Closure of A at scale r."""
        return self._closure_fn(r, A)

    def verify_axioms(self, test_sets: Optional[List[FrozenSet[Element]]] = None) -> Dict[str, bool]:
        """Verify the closure system axioms on test sets."""
        if test_sets is None:
            test_sets = [frozenset(s) for s in _powerset(self.elements)]

        results = {}

        # Extensivity
        results['extensive'] = all(
            A <= self.scale_closure(r, A)
            for r in self.scales for A in test_sets
        )

        # Idempotency
        results['idempotent'] = all(
            self.scale_closure(r, self.scale_closure(r, A)) == self.scale_closure(r, A)
            for r in self.scales for A in test_sets
        )

        # Set-monotonicity (check A ⊆ B → cl(A) ⊆ cl(B))
        results['set_monotone'] = all(
            A <= B and self.scale_closure(r, A) <= self.scale_closure(r, B)
            or not (A <= B)
            for r in self.scales for A in test_sets for B in test_sets
        )

        # Scale-monotonicity
        results['scale_monotone'] = all(
            self.scale_closure(r, A) <= self.scale_closure(s, A)
            for i, r in enumerate(self.scales)
            for s in self.scales[i:]
            for A in test_sets
        )

        # Absorption
        results['absorption'] = all(
            self.scale_closure(s, self.scale_closure(r, A)) == self.scale_closure(s, A)
            for i, r in enumerate(self.scales)
            for s in self.scales[i:]
            for A in test_sets
        )

        return results


def scale_defect(F: FilteredClosureSystem, A: FrozenSet[Element],
                 r: Scale, s: Scale) -> FrozenSet[Element]:
    """Compute the defect D(A, r, s) = cl_s(A) \\ cl_r(A)."""
    return F.scale_closure(s, A) - F.scale_closure(r, A)


def defect_profile(F: FilteredClosureSystem, A: FrozenSet[Element]) -> Dict[Scale, FrozenSet[Element]]:
    """Compute the full defect profile: scale -> closure at that scale."""
    return {r: F.scale_closure(r, A) for r in F.scales}


def verify_defect_decomposition(F: FilteredClosureSystem, A: FrozenSet[Element],
                                 r: Scale, s: Scale, t: Scale) -> bool:
    """Verify D(A,r,t) = D(A,r,s) ∪ D(A,s,t) for r ≤ s ≤ t."""
    d_rt = scale_defect(F, A, r, t)
    d_rs = scale_defect(F, A, r, s)
    d_st = scale_defect(F, A, s, t)
    return d_rt == d_rs | d_st


def verify_reconstruction(F: FilteredClosureSystem, A: FrozenSet[Element],
                           r: Scale, s: Scale) -> bool:
    """Verify cl_s(A) = cl_r(A) ∪ D(A,r,s) for r ≤ s."""
    return F.scale_closure(s, A) == F.scale_closure(r, A) | scale_defect(F, A, r, s)


@dataclass
class RenormDAGEdge:
    """An edge in the renormalization DAG."""
    source: Scale
    target: Scale
    label: FrozenSet[Element]
    test_set: FrozenSet[Element]  # the test set that witnessed this defect


@dataclass
class RenormDAG:
    """A renormalization DAG: certified minimal interaction graph."""
    edges: List[RenormDAGEdge]
    scales: List[Scale]

    def edge_count(self) -> int:
        return len(self.edges)

    def active_scales(self) -> Set[Scale]:
        """Scales involved in at least one nontrivial transition."""
        s = set()
        for e in self.edges:
            s.add(e.source)
            s.add(e.target)
        return s

    def is_sound(self, observed: Callable) -> bool:
        """Verify soundness: every edge has a genuine defect."""
        for e in self.edges:
            if e.source >= e.target:
                return False
            d = observed(e.test_set, e.target) - observed(e.test_set, e.source)
            if d != e.label or len(d) == 0:
                return False
        return True


@dataclass
class FiniteScaleObservations:
    """Finite scale observations for DAG reconstruction."""
    test_sets: List[FrozenSet[Element]]
    observed: Callable[[FrozenSet[Element], Scale], FrozenSet[Element]]
    scales: List[Scale]


def reconstruct_renorm_dag(obs: FiniteScaleObservations) -> RenormDAG:
    """Reconstruct the renormalization DAG from finite observations.

    Algorithm:
    1. For each pair of scales (r, s) with r < s:
    2.   For each test set A:
    3.     Compute defect d = observed(A, s) \\ observed(A, r)
    4.     If d ≠ ∅, add edge (r → s, label=d)

    Complexity: O(|σ|² · |testSets| · |α|)
    """
    edges = []
    for i, r in enumerate(obs.scales):
        for s in obs.scales[i+1:]:
            for A in obs.test_sets:
                d = obs.observed(A, s) - obs.observed(A, r)
                if d:
                    edges.append(RenormDAGEdge(
                        source=r, target=s, label=d, test_set=A
                    ))
    return RenormDAG(edges=edges, scales=obs.scales)


def verify_flow_recovery(obs: FiniteScaleObservations) -> bool:
    """Verify exact flow recovery: obs(A,s) = obs(A,r) ∪ (obs(A,s)\\obs(A,r))."""
    for A in obs.test_sets:
        for i, r in enumerate(obs.scales):
            for s in obs.scales[i:]:
                lhs = obs.observed(A, s)
                rhs = obs.observed(A, r) | (obs.observed(A, s) - obs.observed(A, r))
                if lhs != rhs:
                    return False
    return True


# ============================================================
# Example Constructions
# ============================================================

def identity_closure(elements: FrozenSet[Element],
                     scales: List[Scale]) -> FilteredClosureSystem:
    """The identity (constant) closure system: cl_r(A) = A for all r."""
    return FilteredClosureSystem(
        elements=elements, scales=scales,
        _closure_fn=lambda r, A: A
    )


def full_closure(elements: FrozenSet[Element],
                 scales: List[Scale]) -> FilteredClosureSystem:
    """The full closure system: cl_r(A) = elements for all r, A."""
    return FilteredClosureSystem(
        elements=elements, scales=scales,
        _closure_fn=lambda r, A: elements
    )


def threshold_closure(elements: FrozenSet[Element],
                      scales: List[Scale],
                      thresholds: Dict[Element, Scale]) -> FilteredClosureSystem:
    """Threshold closure: element x is in cl_r(A) if x ∈ A or threshold[x] ≤ r.

    Models: each element "activates" at a specific scale threshold.
    """
    def cl(r: Scale, A: FrozenSet[Element]) -> FrozenSet[Element]:
        return A | frozenset(x for x in elements if x in thresholds and thresholds[x] <= r)

    return FilteredClosureSystem(elements=elements, scales=scales, _closure_fn=cl)


def transitive_closure_system(elements: FrozenSet[Element],
                              scales: List[Scale],
                              implications: Dict[Scale, List[Tuple[Element, Element]]]) -> FilteredClosureSystem:
    """Closure by scale-dependent implications.

    At scale r, if x → y is an implication at scale ≤ r, then y ∈ cl_r({x}).
    """
    def cl(r: Scale, A: FrozenSet[Element]) -> FrozenSet[Element]:
        result = set(A)
        changed = True
        while changed:
            changed = False
            for s in scales:
                if s <= r and s in implications:
                    for (x, y) in implications[s]:
                        if x in result and y not in result:
                            result.add(y)
                            changed = True
        return frozenset(result)

    return FilteredClosureSystem(elements=elements, scales=scales, _closure_fn=cl)


def random_filtered_closure(n_elements: int, n_scales: int,
                            seed: Optional[int] = None) -> FilteredClosureSystem:
    """Generate a random filtered closure system.

    Strategy: build by threshold activation with random thresholds,
    then add random scale-dependent implications for non-trivial structure.
    """
    if seed is not None:
        random.seed(seed)

    elements = frozenset(range(n_elements))
    scales = list(range(n_scales))

    # Random thresholds
    thresholds = {x: random.choice(scales) for x in elements}

    # Random implications (sparse)
    implications: Dict[Scale, List[Tuple[Element, Element]]] = {}
    n_implications = random.randint(1, n_elements)
    for _ in range(n_implications):
        s = random.choice(scales)
        x = random.choice(list(elements))
        y = random.choice(list(elements))
        if s not in implications:
            implications[s] = []
        implications[s].append((x, y))

    def cl(r: Scale, A: FrozenSet[Element]) -> FrozenSet[Element]:
        result = set(A)
        # Add threshold-activated elements
        for x in elements:
            if thresholds[x] <= r:
                result.add(x)
        # Apply implications transitively
        changed = True
        while changed:
            changed = False
            for s in scales:
                if s <= r and s in implications:
                    for (x, y) in implications[s]:
                        if x in result and y not in result:
                            result.add(y)
                            changed = True
        return frozenset(result)

    return FilteredClosureSystem(elements=elements, scales=scales, _closure_fn=cl)


# ============================================================
# Helpers
# ============================================================

def _powerset(s: FrozenSet) -> List[FrozenSet]:
    """Generate all subsets of s."""
    s_list = list(s)
    result = []
    for i in range(2**len(s_list)):
        subset = frozenset(s_list[j] for j in range(len(s_list)) if i & (1 << j))
        result.append(subset)
    return result


if __name__ == '__main__':
    # Quick demo
    elements = frozenset(range(4))
    scales = [0, 1, 2]

    print("=== Threshold Closure System ===")
    F = threshold_closure(elements, scales, {0: 0, 1: 0, 2: 1, 3: 2})
    A = frozenset([0])
    for r in scales:
        print(f"  cl_{r}({set(A)}) = {set(F.scale_closure(r, A))}")

    print("\n=== Axiom Verification ===")
    axioms = F.verify_axioms([frozenset(), frozenset([0]), frozenset([0,1]), elements])
    for k, v in axioms.items():
        print(f"  {k}: {'✓' if v else '✗'}")

    print("\n=== Defect Decomposition ===")
    for r, s, t in [(0,1,2)]:
        ok = verify_defect_decomposition(F, A, r, s, t)
        d_rt = scale_defect(F, A, r, t)
        d_rs = scale_defect(F, A, r, s)
        d_st = scale_defect(F, A, s, t)
        print(f"  D({set(A)},{r},{t}) = {set(d_rt)}")
        print(f"  D({set(A)},{r},{s}) ∪ D({set(A)},{s},{t}) = {set(d_rs | d_st)}")
        print(f"  Decomposition holds: {ok}")

    print("\n=== DAG Reconstruction ===")
    obs = FiniteScaleObservations(
        test_sets=[frozenset(), frozenset([0]), frozenset([0,1]), elements],
        observed=lambda A, r: F.scale_closure(r, A),
        scales=scales
    )
    dag = reconstruct_renorm_dag(obs)
    print(f"  Edges: {dag.edge_count()}")
    for e in dag.edges:
        print(f"    {e.source} → {e.target}: {set(e.label)} (witness: {set(e.test_set)})")
    print(f"  Sound: {dag.is_sound(lambda A, r: F.scale_closure(r, A))}")
    print(f"  Flow recovery: {verify_flow_recovery(obs)}")
