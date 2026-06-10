#!/usr/bin/env python3
"""
Algorithms for Argumentation Framework Analysis

Type-hinted implementations of the core algorithms for computing
conflict-free sets, extensions, and topological invariants of
the independence complex.
"""

from __future__ import annotations
from itertools import combinations
from typing import FrozenSet, List, Set, Tuple, Dict, Optional
from dataclasses import dataclass, field


@dataclass(frozen=True)
class ArgFramework:
    """An argumentation framework (A, R)."""
    arguments: FrozenSet[int]
    attacks: FrozenSet[Tuple[int, int]]
    
    def attackers_of(self, x: int) -> Set[int]:
        """Return the set of arguments that attack x."""
        return {a for (a, b) in self.attacks if b == x}
    
    def attacked_by(self, s: FrozenSet[int]) -> Set[int]:
        """Return the set of arguments attacked by members of s."""
        return {b for a in s for (c, b) in self.attacks if c == a}
    
    def is_irreflexive(self) -> bool:
        """Check if no argument attacks itself."""
        return all((a, a) not in self.attacks for a in self.arguments)


@dataclass
class IndependenceComplex:
    """The independence complex of an argumentation framework."""
    af: ArgFramework
    faces: List[FrozenSet[int]] = field(default_factory=list)
    
    def compute(self) -> None:
        """Compute all faces (conflict-free sets)."""
        self.faces = conflict_free_sets(self.af)
    
    def f_vector(self) -> Dict[int, int]:
        """Compute the f-vector: f_i = number of i-dimensional faces."""
        if not self.faces:
            self.compute()
        result: Dict[int, int] = {}
        for s in self.faces:
            d = len(s)
            result[d] = result.get(d, 0) + 1
        return result
    
    def euler_characteristic(self) -> int:
        """Compute the reduced Euler characteristic."""
        fv = self.f_vector()
        return sum((-1)**d * count for d, count in fv.items())
    
    def dimension(self) -> int:
        """Maximum dimension of any face."""
        if not self.faces:
            self.compute()
        return max((len(s) - 1 for s in self.faces), default=-1)
    
    def facets(self) -> List[FrozenSet[int]]:
        """Maximal faces of the complex."""
        if not self.faces:
            self.compute()
        result = []
        for s in self.faces:
            if not any(s < t for t in self.faces):
                result.append(s)
        return result


def is_conflict_free(s: FrozenSet[int], af: ArgFramework) -> bool:
    """Check if a set is conflict-free in the given framework.
    
    Time complexity: O(|s|^2) worst case.
    """
    for a in s:
        for b in s:
            if (a, b) in af.attacks:
                return False
    return True


def conflict_free_sets(af: ArgFramework) -> List[FrozenSet[int]]:
    """Compute all conflict-free sets using backtracking.
    
    Uses the downward-closure property for pruning:
    if S is not conflict-free, no superset of S is either.
    
    Time complexity: O(n * |CF|) where |CF| is the output size.
    """
    result: List[FrozenSet[int]] = [frozenset()]
    args_sorted = sorted(af.arguments)
    
    for a in args_sorted:
        new_sets: List[FrozenSet[int]] = []
        for s in result:
            candidate = s | {a}
            if is_conflict_free(candidate, af):
                new_sets.append(candidate)
        result.extend(new_sets)
    
    return result


def is_defended(x: int, s: FrozenSet[int], af: ArgFramework) -> bool:
    """Check if x is defended by s.
    
    x is defended by s if every attacker of x is counter-attacked by s.
    """
    for b in af.arguments:
        if (b, x) in af.attacks:
            if not any((c, b) in af.attacks for c in s):
                return False
    return True


def defense_operator(s: FrozenSet[int], af: ArgFramework) -> FrozenSet[int]:
    """Compute F(s) = {x ∈ A : x is defended by s}.
    
    This is the characteristic function of the framework.
    """
    return frozenset(x for x in af.arguments if is_defended(x, s, af))


def is_admissible(s: FrozenSet[int], af: ArgFramework) -> bool:
    """Check if s is an admissible set."""
    if not is_conflict_free(s, af):
        return False
    return all(is_defended(a, s, af) for a in s)


def is_complete_extension(s: FrozenSet[int], af: ArgFramework) -> bool:
    """Check if s is a complete extension."""
    if not is_admissible(s, af):
        return False
    return all(x in s for x in af.arguments if is_defended(x, s, af))


def is_stable_extension(s: FrozenSet[int], af: ArgFramework) -> bool:
    """Check if s is a stable extension."""
    if not is_conflict_free(s, af):
        return False
    return all(
        any((a, x) in af.attacks for a in s)
        for x in af.arguments if x not in s
    )


def grounded_extension(af: ArgFramework) -> FrozenSet[int]:
    """Compute the grounded extension by iterating the defense operator.
    
    Starts from ∅ and iterates F until fixed point.
    Guaranteed to terminate in at most |A| steps by monotonicity.
    """
    g: FrozenSet[int] = frozenset()
    for _ in range(len(af.arguments) + 1):
        new_g = defense_operator(g, af)
        if new_g == g:
            return g
        g = new_g
    return g  # Should not reach here


def preferred_extensions(af: ArgFramework) -> List[FrozenSet[int]]:
    """Compute all preferred extensions (maximal admissible sets)."""
    cf = conflict_free_sets(af)
    admissible = [s for s in cf if is_admissible(s, af)]
    return [s for s in admissible 
            if not any(s < t for t in admissible)]


def stable_extensions(af: ArgFramework) -> List[FrozenSet[int]]:
    """Compute all stable extensions."""
    cf = conflict_free_sets(af)
    return [s for s in cf if is_stable_extension(s, af)]


def complete_extensions(af: ArgFramework) -> List[FrozenSet[int]]:
    """Compute all complete extensions."""
    cf = conflict_free_sets(af)
    return [s for s in cf if is_complete_extension(s, af)]


def verify_hierarchy(af: ArgFramework) -> Dict[str, List[FrozenSet[int]]]:
    """Compute and verify the full extension hierarchy.
    
    Returns a dict with keys: conflict_free, admissible, complete,
    preferred, stable, grounded.
    
    Verifies: stable ⊆ complete ⊆ admissible ⊆ conflict_free.
    """
    cf = conflict_free_sets(af)
    adm = [s for s in cf if is_admissible(s, af)]
    comp = [s for s in cf if is_complete_extension(s, af)]
    stab = [s for s in cf if is_stable_extension(s, af)]
    pref = [s for s in adm if not any(s < t for t in adm)]
    gr = grounded_extension(af)
    
    # Verify hierarchy
    stab_set = set(stab)
    comp_set = set(comp)
    adm_set = set(adm)
    cf_set = set(cf)
    
    assert stab_set <= comp_set, "Stable ⊄ Complete!"
    assert comp_set <= adm_set, "Complete ⊄ Admissible!"
    assert adm_set <= cf_set, "Admissible ⊄ Conflict-free!"
    assert gr in comp_set, "Grounded ∉ Complete!"
    
    return {
        "conflict_free": cf,
        "admissible": adm,
        "complete": comp,
        "preferred": pref,
        "stable": stab,
        "grounded": [gr],
    }


if __name__ == "__main__":
    # Example: the Euler characteristic counterexample
    af = ArgFramework(
        arguments=frozenset({0, 1, 2}),
        attacks=frozenset({(0, 1), (1, 2)})
    )
    
    hierarchy = verify_hierarchy(af)
    for name, exts in hierarchy.items():
        print(f"{name}: {[set(s) if s else '∅' for s in exts]}")
    
    ic = IndependenceComplex(af)
    ic.compute()
    print(f"\nf-vector: {ic.f_vector()}")
    print(f"Euler characteristic: {ic.euler_characteristic()}")
    print(f"Facets: {[set(s) if s else '∅' for s in ic.facets()]}")
