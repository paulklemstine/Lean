"""
Numerical demonstration of the asymmetric forcing frame separating S4.2 from S5.

The set-theoretic multiverse of forcing extensions is modeled combinatorially:

    * A *world* is a truth assignment  w : atoms -> {True, False}.
    * The accessibility relation is the pointwise DOMINATION order

          dom(w, v)  :<=>  for all atoms a,  w(a) == True  ==>  v(a) == True

      ("an extension may switch atoms on, never off").

We verify, over finite atom sets, that the domination frame:

    * is reflexive, transitive, and confluent  -> validates T, 4, .2  (so S4.2);
    * is NOT Euclidean and REFUTES axiom 5      -> does not validate S5.

Every routine is inlined and type-hinted; the file is self-contained
(standard library only) and runnable with `python3 demo.py`.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Iterable

# A world over n atoms is a tuple of booleans of length n.
World = tuple[bool, ...]
# A predicate is a map from worlds to bool.
Predicate = Callable[[World], bool]


# --------------------------------------------------------------------------- #
# Core combinatorics: worlds and the domination order
# --------------------------------------------------------------------------- #
def all_worlds(n: int) -> list[World]:
    """Enumerate all 2^n truth assignments over n atoms."""
    return [tuple(bits) for bits in product([False, True], repeat=n)]


def dom(w: World, v: World) -> bool:
    """Domination: v decides at least as many atoms positively as w."""
    return all((not w_a) or v_a for w_a, v_a in zip(w, v))


def join(y: World, z: World) -> World:
    """Pointwise OR (the confluence witness / amalgamation of y and z)."""
    return tuple(y_a or z_a for y_a, z_a in zip(y, z))


# --------------------------------------------------------------------------- #
# Modal operators on a finite frame
# --------------------------------------------------------------------------- #
def box(worlds: Iterable[World], p: Predicate, w: World) -> bool:
    """[]P at w: P holds in every dom-successor of w."""
    return all(p(v) for v in worlds if dom(w, v))


def dia(worlds: Iterable[World], p: Predicate, w: World) -> bool:
    """<>P at w: P holds in some dom-successor of w."""
    return any(p(v) for v in worlds if dom(w, v))


# --------------------------------------------------------------------------- #
# Frame-condition checks
# --------------------------------------------------------------------------- #
def is_reflexive(worlds: list[World]) -> bool:
    return all(dom(w, w) for w in worlds)


def is_transitive(worlds: list[World]) -> bool:
    return all(
        (not (dom(x, y) and dom(y, z))) or dom(x, z)
        for x in worlds
        for y in worlds
        for z in worlds
    )


def is_confluent(worlds: list[World]) -> bool:
    """For all x->y, x->z there is a common u; the join always works."""
    for x in worlds:
        for y in worlds:
            for z in worlds:
                if dom(x, y) and dom(x, z):
                    u = join(y, z)
                    if not (dom(y, u) and dom(z, u)):
                        return False
    return True


def is_euclidean(worlds: list[World]) -> bool:
    return all(
        (not (dom(x, y) and dom(x, z))) or dom(y, z)
        for x in worlds
        for y in worlds
        for z in worlds
    )


# --------------------------------------------------------------------------- #
# Axiom validity checks (over a sample of predicates = all subsets of worlds)
# --------------------------------------------------------------------------- #
def predicate_from_set(members: frozenset[World]) -> Predicate:
    return lambda w: w in members


def all_predicates(worlds: list[World]) -> list[Predicate]:
    """Every predicate on a finite world set (2^(2^n) of them)."""
    preds: list[Predicate] = []
    for mask in range(1 << len(worlds)):
        members = frozenset(w for i, w in enumerate(worlds) if (mask >> i) & 1)
        preds.append(predicate_from_set(members))
    return preds


def validates_T(worlds: list[World]) -> bool:
    return all(
        (not box(worlds, p, w)) or p(w)
        for p in all_predicates(worlds)
        for w in worlds
    )


def validates_4(worlds: list[World]) -> bool:
    return all(
        (not box(worlds, p, w)) or box(worlds, lambda v, p=p: box(worlds, p, v), w)
        for p in all_predicates(worlds)
        for w in worlds
    )


def validates_dot2(worlds: list[World]) -> bool:
    for p in all_predicates(worlds):
        boxp: Predicate = lambda v, p=p: box(worlds, p, v)
        for w in worlds:
            if dia(worlds, boxp, w):
                if not box(worlds, lambda v, p=p: dia(worlds, p, v), w):
                    return False
    return True


def find_axiom5_counterexample(
    worlds: list[World],
) -> tuple[Predicate, World, str] | None:
    """Return (P, w, description) with <>P(w) true but [] <>P (w) false, if any."""
    for p in all_predicates(worlds):
        diap: Predicate = lambda v, p=p: dia(worlds, p, v)
        for w in worlds:
            if dia(worlds, p, w) and not box(worlds, diap, w):
                members = tuple(v for v in worlds if p(v))
                return p, w, f"P = {{{members}}},  w = {w}"
    return None


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_frame_conditions(n: int = 3) -> None:
    print(f"=== Frame conditions on {n} atoms ({2 ** n} worlds) ===")
    worlds = all_worlds(n)
    print(f"  reflexive : {is_reflexive(worlds)}")
    print(f"  transitive: {is_transitive(worlds)}")
    print(f"  confluent : {is_confluent(worlds)}")
    print(f"  euclidean : {is_euclidean(worlds)}   <-- fails, as expected")
    print()


def demo_axioms(n: int = 2) -> None:
    print(f"=== Axiom validity on {n} atoms ({2 ** n} worlds) ===")
    worlds = all_worlds(n)
    print(f"  T  (box p -> p)                 : {validates_T(worlds)}")
    print(f"  4  (box p -> box box p)         : {validates_4(worlds)}")
    print(f"  .2 (dia box p -> box dia p)     : {validates_dot2(worlds)}")
    cex = find_axiom5_counterexample(worlds)
    if cex is None:
        print("  5  (dia p -> box dia p)         : holds (unexpected!)")
    else:
        _, _, desc = cex
        print("  5  (dia p -> box dia p)         : FAILS")
        print(f"       counterexample: {desc}")
    print()


def demo_separation_witness() -> None:
    """The explicit two-atom bot / top / m witness from the Separation Theorem."""
    print("=== Explicit separation witness (2 atoms) ===")
    bot: World = (False, False)   # every atom off
    m: World = (True, False)      # only the atom 'true' is on   (m(a) = a)
    top: World = (True, True)     # every atom on
    worlds = all_worlds(2)

    print(f"  dom(bot, m)   = {dom(bot, m)}   (bot reaches m)")
    print(f"  dom(bot, top) = {dom(bot, top)} (bot reaches top)")
    print(f"  dom(top, m)   = {dom(top, m)}  (top CANNOT reach m)")

    p_is_m: Predicate = lambda w: w == m
    print(f"  <>(= m) at bot        = {dia(worlds, p_is_m, bot)}  (possible)")
    diap: Predicate = lambda v: dia(worlds, p_is_m, v)
    print(f"  [] <>(= m) at bot     = {box(worlds, diap, bot)}  (NOT necessary)")
    print("  => axiom 5 refuted: <>P holds but [] <>P fails at bot.\n")


def demo_confluence_join() -> None:
    print("=== Confluence via the join (amalgamation) ===")
    x: World = (True, False, False)
    y: World = (True, True, False)
    z: World = (True, False, True)
    u = join(y, z)
    print(f"  x = {x}, y = {y}, z = {z}")
    print(f"  dom(x, y) = {dom(x, y)}, dom(x, z) = {dom(x, z)}")
    print(f"  join(y, z) = {u}")
    print(f"  dom(y, join) = {dom(y, u)}, dom(z, join) = {dom(z, u)}")
    print("  => any two extensions have a common upper bound.\n")


def main() -> None:
    print("Asymmetric forcing frame: S4.2 without S5\n")
    demo_frame_conditions(3)
    demo_confluence_join()
    demo_axioms(2)
    demo_separation_witness()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
