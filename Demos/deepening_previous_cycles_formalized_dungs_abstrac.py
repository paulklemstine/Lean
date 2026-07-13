"""
Numerical demonstrations for the order theory of abstract argumentation.

This self-contained module implements finite Dung-style argumentation
frameworks and verifies, on concrete examples, the theorems developed in
the accompanying paper:

  * The Fundamental Lemma: an admissible set stays admissible when an
    argument it defends is added.
  * Every preferred (maximal admissible) extension is complete.
  * Every stable extension is complete and preferred.
  * Preferred extensions coincide with maximal complete extensions.
  * The complete extensions form a pointed poset: least element is the
    grounded extension, maximal elements are the preferred extensions.

An argumentation framework (A, R) is represented as a finite set of
arguments together with an attack relation given as a set of ordered
pairs (a, b) meaning "a attacks b".
"""

from __future__ import annotations

from itertools import chain, combinations
from typing import FrozenSet, Iterable, List, Set, Tuple

Argument = str
Attack = Tuple[Argument, Argument]
ArgSet = FrozenSet[Argument]


class Framework:
    """A finite abstract argumentation framework (A, R)."""

    def __init__(self, arguments: Iterable[Argument],
                 attacks: Iterable[Attack]) -> None:
        self.arguments: FrozenSet[Argument] = frozenset(arguments)
        self.attacks: FrozenSet[Attack] = frozenset(attacks)

    # --- basic relations -------------------------------------------------

    def attacks_arg(self, a: Argument, b: Argument) -> bool:
        """Return True iff argument a attacks argument b."""
        return (a, b) in self.attacks

    def defends(self, s: ArgSet, a: Argument) -> bool:
        """S defends a: every attacker of a is counterattacked from S."""
        for b in self.arguments:
            if self.attacks_arg(b, a):
                if not any(self.attacks_arg(c, b) for c in s):
                    return False
        return True

    def characteristic(self, s: ArgSet) -> ArgSet:
        """The defense operator F(S) = {a : S defends a}."""
        return frozenset(a for a in self.arguments if self.defends(s, a))

    # --- semantic predicates --------------------------------------------

    def conflict_free(self, s: ArgSet) -> bool:
        """No member of S attacks another member of S."""
        return not any(self.attacks_arg(a, b) for a in s for b in s)

    def admissible(self, s: ArgSet) -> bool:
        """Conflict-free and defends each of its members (S subset F(S))."""
        return self.conflict_free(s) and all(self.defends(s, a) for a in s)

    def complete(self, s: ArgSet) -> bool:
        """Admissible and closed under defense (F(S) subset S)."""
        return self.admissible(s) and self.characteristic(s) <= s

    def stable(self, s: ArgSet) -> bool:
        """Conflict-free and attacks every argument outside S."""
        if not self.conflict_free(s):
            return False
        outside = self.arguments - s
        return all(any(self.attacks_arg(b, a) for b in s) for a in outside)

    def preferred(self, s: ArgSet) -> bool:
        """A maximal admissible set."""
        if not self.admissible(s):
            return False
        adm = self.all_admissible()
        return not any(s < t for t in adm)

    # --- enumerations (finite brute force) ------------------------------

    def _powerset(self) -> List[ArgSet]:
        args = list(self.arguments)
        return [frozenset(c) for c in chain.from_iterable(
            combinations(args, k) for k in range(len(args) + 1))]

    def all_admissible(self) -> List[ArgSet]:
        return [s for s in self._powerset() if self.admissible(s)]

    def all_complete(self) -> List[ArgSet]:
        return [s for s in self._powerset() if self.complete(s)]

    def all_preferred(self) -> List[ArgSet]:
        return [s for s in self._powerset() if self.preferred(s)]

    def all_stable(self) -> List[ArgSet]:
        return [s for s in self._powerset() if self.stable(s)]

    def grounded(self) -> ArgSet:
        """Least complete extension via least-fixed-point iteration of F."""
        s: ArgSet = frozenset()
        while True:
            nxt = self.characteristic(s)
            if nxt == s:
                return s
            s = nxt


def _fmt(s: ArgSet) -> str:
    return "{" + ", ".join(sorted(s)) + "}" if s else "{}"


def check_fundamental_lemma(fw: Framework) -> bool:
    """Verify the Fundamental Lemma on every admissible set of fw."""
    for s in fw.all_admissible():
        for a in fw.characteristic(s):      # arguments S defends
            grown = s | {a}
            if not fw.admissible(grown):
                return False
    return True


def demo(name: str, fw: Framework) -> None:
    print(f"=== {name} ===")
    print(f"  arguments : {_fmt(fw.arguments)}")
    print(f"  attacks   : {sorted(fw.attacks)}")
    adm = fw.all_admissible()
    comp = fw.all_complete()
    pref = fw.all_preferred()
    stab = fw.all_stable()
    print(f"  admissible: {[_fmt(s) for s in adm]}")
    print(f"  complete  : {[_fmt(s) for s in comp]}")
    print(f"  grounded  : {_fmt(fw.grounded())}   (least complete)")
    print(f"  preferred : {[_fmt(s) for s in pref]}")
    print(f"  stable    : {[_fmt(s) for s in stab]}")

    # Theorem checks
    fund = check_fundamental_lemma(fw)
    pref_complete = all(fw.complete(s) for s in pref)
    stable_pref = all(fw.preferred(s) for s in stab)
    # preferred == maximal complete
    comp_set: Set[ArgSet] = set(comp)
    maximal_complete = {s for s in comp_set
                        if not any(s < t for t in comp_set)}
    pref_eq_maxcomp = set(pref) == maximal_complete
    grounded_least = all(fw.grounded() <= s for s in comp)

    print(f"  [check] Fundamental Lemma holds        : {fund}")
    print(f"  [check] preferred => complete          : {pref_complete}")
    print(f"  [check] stable => preferred            : {stable_pref}")
    print(f"  [check] preferred == maximal complete  : {pref_eq_maxcomp}")
    print(f"  [check] grounded is least complete     : {grounded_least}")
    print()


def main() -> None:
    # Example 1: two-cycle a <-> b. Two preferred extensions, both stable.
    two_cycle = Framework(["a", "b"], [("a", "b"), ("b", "a")])
    demo("Two-cycle (a <-> b)", two_cycle)

    # Example 2: three-cycle a->b->c->a. Only admissible set is empty; no
    # stable extension.
    three_cycle = Framework(
        ["a", "b", "c"], [("a", "b"), ("b", "c"), ("c", "a")])
    demo("Three-cycle (a->b->c->a)", three_cycle)

    # Example 3: defense chain c->b->a. Unique complete = preferred =
    # stable = grounded = {a, c}.
    chain_fw = Framework(["a", "b", "c"], [("b", "a"), ("c", "b")])
    demo("Defense chain (c->b->a)", chain_fw)

    # Example 4: a richer framework with a self-attacker.
    rich = Framework(
        ["a", "b", "c", "d"],
        [("a", "b"), ("b", "a"), ("b", "c"), ("c", "d"), ("d", "d")])
    demo("Mixed framework with self-attacker", rich)


if __name__ == "__main__":
    main()
