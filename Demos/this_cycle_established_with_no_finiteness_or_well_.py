"""
Numerical demonstrations for:

    The Complete Extensions of an Argumentation Framework Form a Meet-Semilattice

An abstract argumentation framework is a pair (A, R) where A is a finite set of
arguments and R is an attack relation (a set of ordered pairs).  We work with
finite frameworks here so that everything is directly computable, but the
underlying theorems require no finiteness at all.

Core notions (all inlined below):
  * conflict-free:  no argument in S attacks another in S
  * defends(S, a):  every attacker of a is counterattacked from S
  * admissible:     conflict-free and defends each of its members
  * F(S):           the characteristic / defense operator = {a : S defends a}
  * complete:       admissible and F(S) ⊆ S  (equivalently: conflict-free with F(S) = S)

The demos verify, on concrete frameworks:
  1. Enumeration of complete extensions.
  2. The decisive lemma  F(⋂ 𝒮) ⊆ ⋂ 𝒮  for families of complete extensions.
  3. The meet construction  M(𝒮) = ⋃{ S ⊆ ⋂𝒮 : S ⊆ F(S) }  and that it is
     complete and the greatest lower bound.
  4. Recovery of the grounded extension as the least complete extension (the
     bottom of the meet-semilattice).
"""

from __future__ import annotations

from itertools import combinations
from typing import FrozenSet, Iterable, List, Set, Tuple

Argument = str
Attack = Tuple[Argument, Argument]
ArgSet = FrozenSet[Argument]


# --------------------------------------------------------------------------- #
# Core Dung semantics                                                         #
# --------------------------------------------------------------------------- #
def attackers(arg: Argument, attacks: Set[Attack]) -> Set[Argument]:
    """All b with b -> arg."""
    return {b for (b, a) in attacks if a == arg}


def is_conflict_free(s: ArgSet, attacks: Set[Attack]) -> bool:
    """No member of s attacks another member of s."""
    return not any((a, b) in attacks for a in s for b in s)


def defends(s: ArgSet, arg: Argument, attacks: Set[Attack]) -> bool:
    """Every attacker b of arg is counterattacked by some c in s."""
    for b in attackers(arg, attacks):
        if not any((c, b) in attacks for c in s):
            return False
    return True


def char_F(s: ArgSet, universe: FrozenSet[Argument], attacks: Set[Attack]) -> ArgSet:
    """Characteristic (defense) operator: the set of arguments defended by s."""
    return frozenset(a for a in universe if defends(s, a, attacks))


def is_admissible(s: ArgSet, attacks: Set[Attack]) -> bool:
    """Conflict-free and defends each of its members."""
    return is_conflict_free(s, attacks) and all(defends(s, a, attacks) for a in s)


def is_complete(
    s: ArgSet, universe: FrozenSet[Argument], attacks: Set[Attack]
) -> bool:
    """Admissible and closed under defense (F(s) ⊆ s)."""
    return is_admissible(s, attacks) and char_F(s, universe, attacks) <= s


def all_subsets(universe: FrozenSet[Argument]) -> Iterable[ArgSet]:
    elems = sorted(universe)
    for r in range(len(elems) + 1):
        for combo in combinations(elems, r):
            yield frozenset(combo)


def complete_extensions(
    universe: FrozenSet[Argument], attacks: Set[Attack]
) -> List[ArgSet]:
    """Brute-force enumeration of all complete extensions."""
    return [s for s in all_subsets(universe) if is_complete(s, universe, attacks)]


# --------------------------------------------------------------------------- #
# The meet construction                                                       #
# --------------------------------------------------------------------------- #
def intersection(family: List[ArgSet], universe: FrozenSet[Argument]) -> ArgSet:
    if not family:
        return universe
    out = family[0]
    for s in family[1:]:
        out = out & s
    return out


def family_meet(
    family: List[ArgSet], universe: FrozenSet[Argument], attacks: Set[Attack]
) -> ArgSet:
    """
    M(𝒮) = ⋃ { S ⊆ ⋂𝒮 : S ⊆ F(S) }.

    The union of all post-fixed points of the defense operator contained in the
    intersection.  By the theory this equals the greatest lower bound of the
    family among complete extensions.
    """
    inter = intersection(family, universe)
    result: Set[Argument] = set()
    for s in all_subsets(inter):
        if s <= char_F(s, universe, attacks):  # S ⊆ F(S)
            result |= s
    return frozenset(result)


def grounded_extension(
    universe: FrozenSet[Argument], attacks: Set[Attack]
) -> ArgSet:
    """
    Least complete extension = meet of the family of ALL complete extensions.
    (Also equals the least fixed point of F reached from the empty set.)
    """
    cs = complete_extensions(universe, attacks)
    return family_meet(cs, universe, attacks)


def fmt(s: ArgSet) -> str:
    return "{" + ", ".join(sorted(s)) + "}" if s else "{}"


# --------------------------------------------------------------------------- #
# Demo 1: a rock-paper-scissors cycle plus an isolated argument               #
# --------------------------------------------------------------------------- #
def demo_cycle() -> None:
    print("=" * 70)
    print("DEMO 1: 3-cycle a->b->c->a, with isolated argument d")
    print("=" * 70)
    universe = frozenset({"a", "b", "c", "d"})
    attacks: Set[Attack] = {("a", "b"), ("b", "c"), ("c", "a")}
    cs = complete_extensions(universe, attacks)
    print("Complete extensions:")
    for s in cs:
        print("   ", fmt(s))
    g = grounded_extension(universe, attacks)
    print("Grounded (least complete) extension:", fmt(g))
    # d is unattacked, so it belongs to every complete extension.
    assert all("d" in s for s in cs), "d should be universally accepted"
    print("=> d is unattacked and lies in every complete extension. OK")


# --------------------------------------------------------------------------- #
# Demo 2: verify the decisive lemma  F(⋂𝒮) ⊆ ⋂𝒮                              #
# --------------------------------------------------------------------------- #
def demo_decisive_lemma() -> None:
    print("=" * 70)
    print("DEMO 2: decisive lemma  F(intersection) ⊆ intersection")
    print("=" * 70)
    # Two mutually attacking pairs, giving multiple complete extensions.
    universe = frozenset({"a", "b", "c", "d"})
    attacks: Set[Attack] = {("a", "b"), ("b", "a"), ("c", "d"), ("d", "c")}
    cs = complete_extensions(universe, attacks)
    print("Complete extensions:")
    for s in cs:
        print("   ", fmt(s))
    inter = intersection(cs, universe)
    fi = char_F(inter, universe, attacks)
    print("Intersection of all complete extensions:", fmt(inter))
    print("F(intersection):", fmt(fi))
    assert fi <= inter, "decisive lemma failed!"
    print("=> F(intersection) ⊆ intersection holds. OK")


# --------------------------------------------------------------------------- #
# Demo 3: the meet is the greatest lower bound                                #
# --------------------------------------------------------------------------- #
def demo_meet_is_glb() -> None:
    print("=" * 70)
    print("DEMO 3: the meet M(𝒮) is complete and is the greatest lower bound")
    print("=" * 70)
    universe = frozenset({"a", "b", "c", "d", "e"})
    # a<->b, c<->d, plus e defended by nobody special (isolated defender chain).
    attacks: Set[Attack] = {("a", "b"), ("b", "a"), ("c", "d"), ("d", "c")}
    cs = complete_extensions(universe, attacks)
    # Pick two specific complete extensions and take their binary meet.
    S = frozenset({"a", "c", "e"})
    T = frozenset({"a", "d", "e"})
    assert is_complete(S, universe, attacks) and is_complete(T, universe, attacks)
    meet = family_meet([S, T], universe, attacks)
    print("S =", fmt(S), "  T =", fmt(T))
    print("meet(S, T) =", fmt(meet))
    assert is_complete(meet, universe, attacks), "meet not complete!"
    assert meet <= S and meet <= T, "meet not a lower bound!"
    # greatest lower bound: any complete L ⊆ S,T is ⊆ meet.
    for L in cs:
        if L <= S and L <= T:
            assert L <= meet, "meet is not the greatest lower bound!"
    print("=> meet is complete, a lower bound, and dominates every complete")
    print("   lower bound. OK")


# --------------------------------------------------------------------------- #
# Demo 4: grounded extension as the bottom of the semilattice                 #
# --------------------------------------------------------------------------- #
def demo_grounded_bottom() -> None:
    print("=" * 70)
    print("DEMO 4: grounded extension = bottom of the complete-extension lattice")
    print("=" * 70)
    # A defense chain: a unattacked, a->b, b->c, so a accepted, c defended.
    universe = frozenset({"a", "b", "c"})
    attacks: Set[Attack] = {("a", "b"), ("b", "c")}
    cs = complete_extensions(universe, attacks)
    g = grounded_extension(universe, attacks)
    print("Complete extensions:", [fmt(s) for s in cs])
    print("Grounded extension  :", fmt(g))
    for s in cs:
        assert g <= s, "grounded not contained in some complete extension!"
    print("=> grounded extension is contained in every complete extension. OK")
    print("   (Here a is unattacked, hence accepted; it defends c, so grounded")
    print("    =", fmt(g), ")")


if __name__ == "__main__":
    demo_cycle()
    print()
    demo_decisive_lemma()
    print()
    demo_meet_is_glb()
    print()
    demo_grounded_bottom()
    print()
    print("All demonstrations passed.")
