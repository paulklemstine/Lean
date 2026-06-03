#!/usr/bin/env python3
"""
Dream Logic: Algorithms for Paraconsistent Reasoning

Type-hinted implementations of:
1. Belnap valuation propagation
2. Dream state management with retraction
3. Pre-topology construction and validation
"""

from enum import Enum
from typing import Dict, Set, FrozenSet, List, Tuple, Optional, Callable
from dataclasses import dataclass, field


class BelnapVal(Enum):
    """Four-valued Belnap truth value."""
    VERUM = "T"
    FALSUM = "F"
    BOTH = "B"
    NEITHER = "N"

    def is_designated(self) -> bool:
        return self in (BelnapVal.VERUM, BelnapVal.BOTH)

    def neg(self) -> 'BelnapVal':
        return _NEG_TABLE[self]

    def conj(self, other: 'BelnapVal') -> 'BelnapVal':
        return _CONJ_TABLE[(self, other)]

    def disj(self, other: 'BelnapVal') -> 'BelnapVal':
        return _DISJ_TABLE[(self, other)]

    def impl(self, other: 'BelnapVal') -> 'BelnapVal':
        return self.neg().disj(other)

    def info_le(self, other: 'BelnapVal') -> bool:
        """Information ordering."""
        if self == BelnapVal.NEITHER:
            return True
        if other == BelnapVal.BOTH:
            return True
        return self == other

    def truth_le(self, other: 'BelnapVal') -> bool:
        """Truth ordering."""
        if self == BelnapVal.FALSUM:
            return True
        if other == BelnapVal.VERUM:
            return True
        return self == other


# Lookup tables for efficiency
_NEG_TABLE = {
    BelnapVal.VERUM: BelnapVal.FALSUM,
    BelnapVal.FALSUM: BelnapVal.VERUM,
    BelnapVal.BOTH: BelnapVal.BOTH,
    BelnapVal.NEITHER: BelnapVal.NEITHER,
}

_CONJ_TABLE = {
    (a, b): (
        b if a == BelnapVal.VERUM else
        a if b == BelnapVal.VERUM else
        BelnapVal.FALSUM if a == BelnapVal.FALSUM or b == BelnapVal.FALSUM else
        BelnapVal.BOTH if a == BelnapVal.BOTH and b == BelnapVal.BOTH else
        BelnapVal.FALSUM if {a, b} == {BelnapVal.BOTH, BelnapVal.NEITHER} else
        BelnapVal.NEITHER
    )
    for a in BelnapVal for b in BelnapVal
}

_DISJ_TABLE = {
    (a, b): (
        b if a == BelnapVal.FALSUM else
        a if b == BelnapVal.FALSUM else
        BelnapVal.VERUM if a == BelnapVal.VERUM or b == BelnapVal.VERUM else
        BelnapVal.BOTH if a == BelnapVal.BOTH and b == BelnapVal.BOTH else
        BelnapVal.VERUM if {a, b} == {BelnapVal.BOTH, BelnapVal.NEITHER} else
        BelnapVal.NEITHER
    )
    for a in BelnapVal for b in BelnapVal
}


@dataclass
class DreamState:
    """
    A dream belief state with Belnap-valued beliefs and awareness tracking.

    Algorithm: Belief Retraction
    - Input: dream state s, proposition p
    - If s.belief[p] == BOTH, set to NEITHER
    - Preserves consistent fragment (proven in Lean)
    - Guaranteed to remove the targeted contradiction
    """
    beliefs: Dict[str, BelnapVal] = field(default_factory=dict)
    awareness: Set[str] = field(default_factory=set)

    def contradictions(self) -> Set[str]:
        """Return the set of contradictory propositions."""
        return {p for p, v in self.beliefs.items() if v == BelnapVal.BOTH}

    def consistent_fragment(self) -> Set[str]:
        """Return the set of classically-valued propositions."""
        return {p for p, v in self.beliefs.items()
                if v in (BelnapVal.VERUM, BelnapVal.FALSUM)}

    def designated_beliefs(self) -> Set[str]:
        """Return propositions that are at-least-true."""
        return {p for p, v in self.beliefs.items() if v.is_designated()}

    def retract(self, prop: str) -> 'DreamState':
        """
        Retract a contradictory belief, changing BOTH to NEITHER.

        Properties (formally verified):
        - Preserves the consistent fragment
        - Removes the targeted contradiction
        - Is non-monotone (can reduce designated beliefs)
        """
        new_beliefs = dict(self.beliefs)
        if new_beliefs.get(prop) == BelnapVal.BOTH:
            new_beliefs[prop] = BelnapVal.NEITHER
        return DreamState(beliefs=new_beliefs, awareness=set(self.awareness))

    def retract_all(self) -> 'DreamState':
        """
        Retract ALL contradictions simultaneously.
        Converges in one step (each retraction is independent).
        """
        new_beliefs = {
            p: (BelnapVal.NEITHER if v == BelnapVal.BOTH else v)
            for p, v in self.beliefs.items()
        }
        return DreamState(beliefs=new_beliefs, awareness=set(self.awareness))


@dataclass
class PreTopology:
    """
    A pre-topological space: open sets closed under finite intersection
    but not necessarily under arbitrary union.

    Algorithm: Pre-Topology Validation
    - Check empty and full sets are open
    - Check all pairwise intersections
    - Check union closure (expected to fail for dream pre-topologies)
    """
    universe: FrozenSet[int]
    open_sets: List[FrozenSet[int]]

    def is_valid_pretopology(self) -> Tuple[bool, str]:
        """Verify pre-topology axioms."""
        # Empty set must be open
        if frozenset() not in self.open_sets:
            return False, "Empty set is not open"

        # Universe must be open
        if self.universe not in self.open_sets:
            return False, "Universe is not open"

        # Finite intersection closure
        for i, u in enumerate(self.open_sets):
            for j, v in enumerate(self.open_sets):
                if i <= j:
                    inter = u & v
                    if inter not in self.open_sets:
                        return False, f"Intersection {set(u)} ∩ {set(v)} = {set(inter)} is not open"

        return True, "Valid pre-topology"

    def is_topology(self) -> Tuple[bool, Optional[Tuple[FrozenSet[int], FrozenSet[int]]]]:
        """
        Check if this pre-topology is a genuine topology.
        Returns (True, None) if it is, or (False, (U, V)) where U ∪ V is not open.
        """
        for i, u in enumerate(self.open_sets):
            for j, v in enumerate(self.open_sets):
                if i < j:
                    union = u | v
                    if union not in self.open_sets:
                        return False, (u, v)
        return True, None

    def contradictory_opens(self) -> List[Tuple[FrozenSet[int], FrozenSet[int]]]:
        """Find all pairs of open sets whose union is not open."""
        result = []
        for i, u in enumerate(self.open_sets):
            for j, v in enumerate(self.open_sets):
                if i < j:
                    if (u | v) not in self.open_sets:
                        result.append((u, v))
        return result


def build_dream_pretopology() -> PreTopology:
    """
    Construct the canonical dream pre-topology on {0, 1, 2}.

    Open sets: ∅, {0}, {1}, {0,1,2}
    This is NOT a topology because {0} ∪ {1} = {0,1} is not open.
    """
    universe = frozenset({0, 1, 2})
    open_sets = [
        frozenset(),
        frozenset({0}),
        frozenset({1}),
        universe,
    ]
    return PreTopology(universe=universe, open_sets=open_sets)


def belnap_propagate(
    constraints: Dict[str, BelnapVal],
    rules: List[Tuple[str, str, str]],  # (antecedent, consequent, connective)
    max_iterations: int = 100
) -> Dict[str, BelnapVal]:
    """
    Propagate Belnap values through a dependency graph.

    Algorithm:
    1. Initialize all propositions with given constraints
    2. For each rule (A, B, connective):
       - Compute connective(val(A), val(B))
       - Update B's value using information-join
    3. Repeat until fixpoint or max iterations

    Time complexity: O(n * k) where n = |rules|, k = max iterations
    """
    values = dict(constraints)

    for _ in range(max_iterations):
        changed = False
        for ant, con, conn_type in rules:
            if ant not in values or con not in values:
                continue

            if conn_type == "impl":
                new_val = values[ant].impl(values[con])
            elif conn_type == "conj":
                new_val = values[ant].conj(values[con])
            elif conn_type == "disj":
                new_val = values[ant].disj(values[con])
            else:
                continue

            # Information-join: take the more informative value
            old_val = values.get(con, BelnapVal.NEITHER)
            if new_val != old_val and new_val.info_le(old_val) is False:
                values[con] = new_val
                changed = True

        if not changed:
            break

    return values


def find_explosion_countermodel(
    props: List[str],
    target: str
) -> Optional[Dict[str, BelnapVal]]:
    """
    Find a Belnap valuation where some prop and its negation are designated
    but the target is not.

    Algorithm: exhaustive search over 4^n valuations.
    """
    from itertools import product as iprod

    for vals in iprod(BelnapVal, repeat=len(props)):
        valuation = dict(zip(props, vals))
        # Check: exists p such that p and ¬p are both designated
        has_contradiction = any(
            v.is_designated() and v.neg().is_designated()
            for v in valuation.values()
        )
        # Check: target is not designated
        target_not_designated = not valuation[target].is_designated()

        if has_contradiction and target_not_designated:
            return valuation

    return None


if __name__ == "__main__":
    # Quick self-test
    pt = build_dream_pretopology()
    valid, msg = pt.is_valid_pretopology()
    print(f"Pre-topology valid: {valid} ({msg})")

    is_topo, witness = pt.is_topology()
    print(f"Is topology: {is_topo}")
    if witness:
        u, v = witness
        print(f"  Counterexample: {set(u)} ∪ {set(v)} = {set(u | v)} is not open")

    # Dream state demo
    ds = DreamState(
        beliefs={"cat_alive": BelnapVal.BOTH, "sky_blue": BelnapVal.VERUM},
        awareness={"cat_alive", "sky_blue"}
    )
    print(f"\nContradictions: {ds.contradictions()}")
    ds2 = ds.retract("cat_alive")
    print(f"After retraction: {ds2.contradictions()}")

    # Explosion countermodel
    cm = find_explosion_countermodel(["P", "Q"], "Q")
    print(f"\nExplosion countermodel: {cm}")
