"""
Argumentation Framework Algorithms
===================================

Type-hinted implementations of core argumentation semantics algorithms,
including conflict-free set enumeration, admissibility checking, preferred
extension computation, and argumentation complex construction.
"""

from typing import Set, FrozenSet, List, Dict, Tuple, Optional
from itertools import combinations


class ArgFramework:
    """An argumentation framework AF = (A, R) with arguments A and attack relation R."""

    def __init__(self, arguments: Set[str], attacks: Set[Tuple[str, str]]):
        self.arguments = arguments
        self.attacks = attacks
        self._attack_dict: Dict[str, Set[str]] = {a: set() for a in arguments}
        for src, tgt in attacks:
            self._attack_dict.setdefault(src, set()).add(tgt)

    def attackers_of(self, arg: str) -> Set[str]:
        """Return all arguments that attack `arg`."""
        return {a for a, t in self.attacks if t == arg}

    def attacks_from(self, arg: str) -> Set[str]:
        """Return all arguments attacked by `arg`."""
        return self._attack_dict.get(arg, set())

    def is_conflict_free(self, s: FrozenSet[str]) -> bool:
        """Check if a set S is conflict-free (no internal attacks)."""
        for a in s:
            for b in s:
                if (a, b) in self.attacks:
                    return False
        return True

    def is_acceptable(self, arg: str, s: FrozenSet[str]) -> bool:
        """Check if `arg` is acceptable (defended) w.r.t. S."""
        for attacker in self.attackers_of(arg):
            defended = any((c, attacker) in self.attacks for c in s)
            if not defended:
                return False
        return True

    def is_admissible(self, s: FrozenSet[str]) -> bool:
        """Check if S is admissible: conflict-free and self-defending."""
        if not self.is_conflict_free(s):
            return False
        return all(self.is_acceptable(a, s) for a in s)

    def is_preferred(self, s: FrozenSet[str]) -> bool:
        """Check if S is a preferred extension (maximally admissible)."""
        if not self.is_admissible(s):
            return False
        for a in self.arguments - s:
            extended = s | frozenset({a})
            if self.is_admissible(extended):
                return False
        return True

    def is_stable(self, s: FrozenSet[str]) -> bool:
        """Check if S is a stable extension: conflict-free and attacks all outsiders."""
        if not self.is_conflict_free(s):
            return False
        for a in self.arguments - s:
            if not any((b, a) in self.attacks for b in s):
                return False
        return True

    def all_conflict_free_sets(self) -> List[FrozenSet[str]]:
        """Enumerate all conflict-free sets (faces of the argumentation complex)."""
        result = [frozenset()]
        args = list(self.arguments)
        for r in range(1, len(args) + 1):
            for combo in combinations(args, r):
                s = frozenset(combo)
                if self.is_conflict_free(s):
                    result.append(s)
        return result

    def preferred_extensions(self) -> List[FrozenSet[str]]:
        """Compute all preferred extensions by finding maximal admissible sets."""
        admissible_sets = [s for s in self.all_conflict_free_sets()
                          if self.is_admissible(s)]
        preferred = []
        for s in admissible_sets:
            is_maximal = not any(
                s < t for t in admissible_sets
            )
            if is_maximal:
                preferred.append(s)
        return preferred

    def stable_extensions(self) -> List[FrozenSet[str]]:
        """Compute all stable extensions."""
        return [s for s in self.all_conflict_free_sets() if self.is_stable(s)]

    def f_vector(self) -> List[int]:
        """Compute the f-vector of the argumentation complex.
        f[k] = number of conflict-free sets of cardinality k+1."""
        cf_sets = self.all_conflict_free_sets()
        max_card = max((len(s) for s in cf_sets), default=0)
        fvec = [0] * max_card
        for s in cf_sets:
            if len(s) > 0:
                fvec[len(s) - 1] += 1
        return fvec

    def euler_characteristic(self) -> int:
        """Compute the Euler characteristic of the argumentation complex.
        χ = Σ (-1)^k * f_k"""
        fvec = self.f_vector()
        return sum((-1)**k * f for k, f in enumerate(fvec))

    def is_symmetric(self) -> bool:
        """Check if the attack relation is symmetric."""
        return all((b, a) in self.attacks for a, b in self.attacks)

    def characteristic_function(self, s: FrozenSet[str]) -> FrozenSet[str]:
        """The characteristic function F(S) = {a | a is acceptable w.r.t. S}."""
        return frozenset(a for a in self.arguments if self.is_acceptable(a, s))

    def grounded_extension(self) -> FrozenSet[str]:
        """Compute the grounded extension as the least fixed point of F."""
        s = frozenset()
        while True:
            new_s = self.characteristic_function(s)
            if new_s == s:
                return s
            s = new_s


def verify_semantic_hierarchy(af: ArgFramework) -> Dict[str, bool]:
    """Verify the semantic hierarchy: stable ⊂ preferred for a given AF."""
    stable = set(map(frozenset, af.stable_extensions()))
    preferred = set(map(frozenset, af.preferred_extensions()))

    return {
        "stable_subset_preferred": stable.issubset(preferred),
        "num_stable": len(stable),
        "num_preferred": len(preferred),
        "strict_containment": stable != preferred if stable else None,
    }


def verify_symmetric_bridge(af: ArgFramework) -> Dict[str, bool]:
    """Verify the symmetric bridge theorem: in symmetric AFs,
    conflict-free = admissible, so preferred = maximal independent sets."""
    if not af.is_symmetric():
        return {"is_symmetric": False}

    cf_sets = [s for s in af.all_conflict_free_sets() if len(s) > 0]
    all_cf_admissible = all(af.is_admissible(s) for s in cf_sets)

    maximal_cf = []
    for s in cf_sets:
        if not any(s < t and af.is_conflict_free(t) for t in cf_sets):
            maximal_cf.append(s)

    preferred = af.preferred_extensions()

    return {
        "is_symmetric": True,
        "all_cf_are_admissible": all_cf_admissible,
        "maximal_cf_equals_preferred": set(map(frozenset, maximal_cf)) == set(map(frozenset, preferred)),
    }
