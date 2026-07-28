#!/usr/bin/env python3
"""Finite demonstrations for reflective types and modal box semantics.

The program uses no third-party packages.  It demonstrates:
1. de Bruijn scope checking, including the closed type mu X. box X;
2. mutually inverse translations between reflective and modal syntax;
3. the three-world witness for box P and not box box P;
4. exhaustive confirmation, on all relations over three worlds, that
   transitivity implies box(P) is a subset of box(box(P)) for every P.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import FrozenSet, Iterable, Sequence, Tuple, Union


@dataclass(frozen=True)
class Atom:
    name: str


@dataclass(frozen=True)
class Bound:
    index: int


@dataclass(frozen=True)
class Empty:
    pass


@dataclass(frozen=True)
class Unit:
    pass


@dataclass(frozen=True)
class Prod:
    left: "RType"
    right: "RType"


@dataclass(frozen=True)
class Arr:
    domain: "RType"
    codomain: "RType"


@dataclass(frozen=True)
class Box:
    body: "RType"


@dataclass(frozen=True)
class Fix:
    body: "RType"


RType = Union[Atom, Bound, Empty, Unit, Prod, Arr, Box, Fix]


@dataclass(frozen=True)
class MAtom:
    name: str


@dataclass(frozen=True)
class MVar:
    index: int


@dataclass(frozen=True)
class Bot:
    pass


@dataclass(frozen=True)
class Top:
    pass


@dataclass(frozen=True)
class And:
    left: "Formula"
    right: "Formula"


@dataclass(frozen=True)
class Imp:
    domain: "Formula"
    codomain: "Formula"


@dataclass(frozen=True)
class MBox:
    body: "Formula"


@dataclass(frozen=True)
class Mu:
    body: "Formula"


Formula = Union[MAtom, MVar, Bot, Top, And, Imp, MBox, Mu]
World = int
Edge = Tuple[World, World]
Relation = FrozenSet[Edge]
WorldSet = FrozenSet[World]


def well_scoped(term: RType, depth: int = 0) -> bool:
    """Decide whether every de Bruijn variable is bound at the given depth."""
    if isinstance(term, (Atom, Empty, Unit)):
        return True
    if isinstance(term, Bound):
        return 0 <= term.index < depth
    if isinstance(term, Prod):
        return well_scoped(term.left, depth) and well_scoped(term.right, depth)
    if isinstance(term, Arr):
        return well_scoped(term.domain, depth) and well_scoped(term.codomain, depth)
    if isinstance(term, Box):
        return well_scoped(term.body, depth)
    if isinstance(term, Fix):
        return well_scoped(term.body, depth + 1)
    raise TypeError(f"unknown reflective term: {term!r}")


def provable_not_iterated(term: RType) -> RType:
    """Construct box A times (box box A -> empty)."""
    return Prod(Box(term), Arr(Box(Box(term)), Empty()))


def to_modal(term: RType) -> Formula:
    """Translate a reflective type into a modal fixed-point formula."""
    if isinstance(term, Atom):
        return MAtom(term.name)
    if isinstance(term, Bound):
        return MVar(term.index)
    if isinstance(term, Empty):
        return Bot()
    if isinstance(term, Unit):
        return Top()
    if isinstance(term, Prod):
        return And(to_modal(term.left), to_modal(term.right))
    if isinstance(term, Arr):
        return Imp(to_modal(term.domain), to_modal(term.codomain))
    if isinstance(term, Box):
        return MBox(to_modal(term.body))
    if isinstance(term, Fix):
        return Mu(to_modal(term.body))
    raise TypeError(f"unknown reflective term: {term!r}")


def from_modal(formula: Formula) -> RType:
    """Translate a modal fixed-point formula into a reflective type."""
    if isinstance(formula, MAtom):
        return Atom(formula.name)
    if isinstance(formula, MVar):
        return Bound(formula.index)
    if isinstance(formula, Bot):
        return Empty()
    if isinstance(formula, Top):
        return Unit()
    if isinstance(formula, And):
        return Prod(from_modal(formula.left), from_modal(formula.right))
    if isinstance(formula, Imp):
        return Arr(from_modal(formula.domain), from_modal(formula.codomain))
    if isinstance(formula, MBox):
        return Box(from_modal(formula.body))
    if isinstance(formula, Mu):
        return Fix(from_modal(formula.body))
    raise TypeError(f"unknown modal formula: {formula!r}")


def box(worlds: Iterable[World], relation: Relation, proposition: WorldSet) -> WorldSet:
    """Return worlds all of whose accessible successors lie in proposition."""
    universe = frozenset(worlds)
    return frozenset(
        source
        for source in universe
        if all(target in proposition for (origin, target) in relation if origin == source)
    )


def is_transitive(worlds: Sequence[World], relation: Relation) -> bool:
    """Check transitivity of a finite relation."""
    return all(
        (x, z) in relation
        for x in worlds
        for y in worlds
        for z in worlds
        if (x, y) in relation and (y, z) in relation
    )


def powerset(worlds: Sequence[World]) -> Iterable[WorldSet]:
    """Enumerate all subsets of a finite world sequence."""
    for bits in product((False, True), repeat=len(worlds)):
        yield frozenset(w for w, included in zip(worlds, bits) if included)


def verify_transitivity_obstruction(worlds: Sequence[World]) -> Tuple[int, int]:
    """Exhaustively test all relations and valuations on the supplied worlds."""
    possible_edges = [(x, y) for x in worlds for y in worlds]
    transitive_count = 0
    checked_pairs = 0
    for edge_bits in product((False, True), repeat=len(possible_edges)):
        relation = frozenset(e for e, included in zip(possible_edges, edge_bits) if included)
        if not is_transitive(worlds, relation):
            continue
        transitive_count += 1
        for proposition in powerset(worlds):
            once = box(worlds, relation, proposition)
            twice = box(worlds, relation, once)
            checked_pairs += 1
            assert once <= twice
    return transitive_count, checked_pairs


def main() -> None:
    """Run and print all demonstrations."""
    atom = Atom("p")
    self_provability = Fix(Box(Bound(0)))
    separated = provable_not_iterated(atom)
    dangling = Box(Bound(0))

    print("SCOPING")
    print(f"  mu X. box X is closed: {well_scoped(self_provability)}")
    print(f"  box p and not box box p is closed: {well_scoped(separated)}")
    print(f"  an unbound index is rejected: {not well_scoped(dangling)}")

    examples = [atom, separated, self_provability, Arr(Unit(), Box(atom))]
    print("\nROUND-TRIP TRANSLATION")
    for example in examples:
        restored = from_modal(to_modal(example))
        print(f"  restored exactly: {restored == example}  {example!r}")
        assert restored == example

    worlds = (0, 1, 2)
    chain: Relation = frozenset({(2, 1), (1, 0)})
    proposition: WorldSet = frozenset({1})
    once = box(worlds, chain, proposition)
    twice = box(worlds, chain, once)
    witnesses = once - twice

    print("\nTHREE-WORLD NON-TRANSITIVE FRAME")
    print(f"  edges: {sorted(chain)}")
    print(f"  P: {sorted(proposition)}")
    print(f"  box(P): {sorted(once)}")
    print(f"  box(box(P)): {sorted(twice)}")
    print(f"  box(P) and not box(box(P)): {sorted(witnesses)}")
    assert 2 in witnesses
    assert not is_transitive(worlds, chain)

    transitive_count, checked_pairs = verify_transitivity_obstruction(worlds)
    print("\nEXHAUSTIVE THREE-WORLD CHECK")
    print(f"  transitive relations: {transitive_count}")
    print(f"  relation/valuation pairs checked: {checked_pairs}")
    print("  every transitive case satisfied box(P) subset box(box(P))")


if __name__ == "__main__":
    main()
