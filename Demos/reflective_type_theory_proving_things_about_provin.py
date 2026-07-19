#!/usr/bin/env python3
"""Numerical demonstrations for reflective provability and modal fixed points.

The script uses only Python's standard library.  It evaluates boxed propositions
on finite Kripke frames, checks transitivity, demonstrates the three-state
countermodel, translates reflective syntax to modal syntax and back, and
compares monotone fixed-point convergence with a negative oscillating operator.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, FrozenSet, Iterable, Mapping, Sequence, Tuple

World = int
Proposition = FrozenSet[World]
Edges = FrozenSet[Tuple[World, World]]


@dataclass(frozen=True)
class Frame:
    """A finite Kripke frame with integer-labelled worlds."""

    worlds: FrozenSet[World]
    edges: Edges

    def successors(self, world: World) -> FrozenSet[World]:
        return frozenset(v for u, v in self.edges if u == world)

    def box(self, proposition: Proposition) -> Proposition:
        """Return worlds all of whose immediate successors satisfy proposition."""
        return frozenset(
            w for w in self.worlds if self.successors(w) <= proposition
        )

    def transitivity_defects(self) -> Edges:
        """Return missing shortcuts (a,c) from paths a->b->c."""
        return frozenset(
            (a, c)
            for a, b in self.edges
            for b2, c in self.edges
            if b == b2 and (a, c) not in self.edges
        )

    def is_transitive(self) -> bool:
        return not self.transitivity_defects()


def powerset(items: FrozenSet[World]) -> Iterable[Proposition]:
    """Enumerate all subsets of a small finite set."""
    ordered = sorted(items)
    for mask in range(1 << len(ordered)):
        yield frozenset(
            value for index, value in enumerate(ordered) if mask & (1 << index)
        )


def axiom_four_counterexamples(frame: Frame) -> list[tuple[Proposition, World]]:
    """List valuations and worlds where box(P) holds but box(box(P)) fails."""
    failures: list[tuple[Proposition, World]] = []
    for proposition in powerset(frame.worlds):
        once = frame.box(proposition)
        twice = frame.box(once)
        failures.extend((proposition, w) for w in sorted(once - twice))
    return failures


ReflectiveTree = tuple
ModalTree = tuple


def reflective_to_modal(tree: ReflectiveTree) -> ModalTree:
    """Translate a reflective syntax tree by the constructor isomorphism."""
    tag, *children = tree
    rename: Mapping[str, str] = {
        "atom": "atom", "bound": "var", "empty": "falsum", "unit": "verum",
        "prod": "conj", "arr": "impl", "proof": "box", "fix": "mu",
    }
    if tag in {"atom", "bound"}:
        return (rename[tag], children[0])
    if tag in {"empty", "unit"}:
        return (rename[tag],)
    return (rename[tag], *(reflective_to_modal(child) for child in children))


def modal_to_reflective(tree: ModalTree) -> ReflectiveTree:
    """Apply the inverse constructor translation."""
    tag, *children = tree
    rename: Mapping[str, str] = {
        "atom": "atom", "var": "bound", "falsum": "empty", "verum": "unit",
        "conj": "prod", "impl": "arr", "box": "proof", "mu": "fix",
    }
    if tag in {"atom", "var"}:
        return (rename[tag], children[0])
    if tag in {"falsum", "verum"}:
        return (rename[tag],)
    return (rename[tag], *(modal_to_reflective(child) for child in children))


def least_fixed_point(
    worlds: FrozenSet[World],
    operator: Callable[[Proposition], Proposition],
) -> tuple[Proposition, Sequence[Proposition]]:
    """Iterate a monotone powerset operator from the empty set to stability."""
    current: Proposition = frozenset()
    history: list[Proposition] = [current]
    for _ in range(len(worlds) + 1):
        following = operator(current)
        if not current <= following:
            raise ValueError("operator is not inflationary along this iteration")
        history.append(following)
        if following == current:
            return following, history
        current = following
    raise RuntimeError("a monotone finite-lattice iteration should have stabilized")


def format_set(values: Proposition) -> str:
    return "{" + ", ".join(map(str, sorted(values))) + "}"


def main() -> None:
    chain = Frame(
        worlds=frozenset({0, 1, 2}),
        edges=frozenset({(2, 1), (1, 0)}),
    )
    middle = frozenset({1})
    once = chain.box(middle)
    twice = chain.box(once)

    print("THREE-STATE REFLECTIVE WITNESS")
    print(f"worlds: {format_set(chain.worlds)}; edges: {sorted(chain.edges)}")
    print(f"P = {format_set(middle)}")
    print(f"box(P) = {format_set(once)}")
    print(f"box(box(P)) = {format_set(twice)}")
    print(f"At world 2: box(P)={2 in once}, box(box(P))={2 in twice}")
    print(f"Transitive: {chain.is_transitive()}")
    print(f"Missing composite edges: {sorted(chain.transitivity_defects())}\n")

    closure = Frame(chain.worlds, chain.edges | frozenset({(2, 0)}))
    failures = axiom_four_counterexamples(closure)
    print("TRANSITIVE CLOSURE EXHAUSTIVE CHECK")
    print(f"edges: {sorted(closure.edges)}; transitive: {closure.is_transitive()}")
    print(f"valuations checked: {2 ** len(closure.worlds)}")
    print(f"counterexamples to box(P) -> box(box(P)): {len(failures)}\n")

    reflective = (
        "fix",
        ("proof", ("arr", ("atom", "request"), ("bound", 0))),
    )
    modal = reflective_to_modal(reflective)
    round_trip = modal_to_reflective(modal)
    print("CONSTRUCTOR-BY-CONSTRUCTOR TRANSLATION")
    print(f"reflective tree: {reflective}")
    print(f"modal tree:      {modal}")
    print(f"round trip exact: {round_trip == reflective}\n")

    # Reachability to target 0: Phi(X) = {0} union predecessors of X.
    def reach_zero(states: Proposition) -> Proposition:
        predecessors = frozenset(u for u, v in chain.edges if v in states)
        return frozenset({0}) | predecessors

    fixed, history = least_fixed_point(chain.worlds, reach_zero)
    print("POSITIVE LEAST FIXED POINT")
    for index, state in enumerate(history):
        print(f"X_{index} = {format_set(state)}")
    print(f"least fixed point: {format_set(fixed)}\n")

    print("NEGATIVE OCCURRENCE: OSCILLATION")
    state: Proposition = frozenset()
    for index in range(5):
        print(f"Y_{index} = {format_set(state)}")
        state = chain.worlds - state


if __name__ == "__main__":
    main()
