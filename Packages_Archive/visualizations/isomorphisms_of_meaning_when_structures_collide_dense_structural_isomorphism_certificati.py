#!/usr/bin/env python3
"""Numerical demonstrations of structural truth invariance and meaning collision."""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from itertools import product
from typing import Callable, Dict, Iterable, Mapping, Sequence, Tuple


class Kind(Enum):
    ATOM = "atom"
    BOTTOM = "bottom"
    IMP = "imp"
    BOX = "box"


@dataclass(frozen=True)
class Formula:
    kind: Kind
    atom: str | None = None
    left: "Formula | None" = None
    right: "Formula | None" = None

    @staticmethod
    def var(name: str) -> "Formula":
        return Formula(Kind.ATOM, atom=name)

    @staticmethod
    def bottom() -> "Formula":
        return Formula(Kind.BOTTOM)

    def implies(self, other: "Formula") -> "Formula":
        return Formula(Kind.IMP, left=self, right=other)

    def box(self) -> "Formula":
        return Formula(Kind.BOX, left=self)

    def __str__(self) -> str:
        if self.kind is Kind.ATOM:
            return str(self.atom)
        if self.kind is Kind.BOTTOM:
            return "⊥"
        if self.kind is Kind.BOX:
            return f"□({self.left})"
        return f"({self.left} → {self.right})"


@dataclass(frozen=True)
class Model:
    worlds: Tuple[str, ...]
    atoms: Tuple[str, ...]
    edges: frozenset[Tuple[str, str]]
    true_at: frozenset[Tuple[str, str]]

    def successors(self, world: str) -> Iterable[str]:
        return (target for source, target in self.edges if source == world)


def satisfies(model: Model, world: str, formula: Formula) -> bool:
    """Evaluate a modal formula at one world."""
    if formula.kind is Kind.ATOM:
        assert formula.atom is not None
        return (world, formula.atom) in model.true_at
    if formula.kind is Kind.BOTTOM:
        return False
    if formula.kind is Kind.IMP:
        assert formula.left is not None and formula.right is not None
        return (not satisfies(model, world, formula.left)) or satisfies(
            model, world, formula.right
        )
    assert formula.left is not None
    return all(satisfies(model, nxt, formula.left) for nxt in model.successors(world))


def rename_formula(formula: Formula, atom_map: Mapping[str, str]) -> Formula:
    """Transport all atomic names through a bijection."""
    if formula.kind is Kind.ATOM:
        assert formula.atom is not None
        return Formula.var(atom_map[formula.atom])
    if formula.kind is Kind.BOTTOM:
        return formula
    if formula.kind is Kind.BOX:
        assert formula.left is not None
        return rename_formula(formula.left, atom_map).box()
    assert formula.left is not None and formula.right is not None
    return rename_formula(formula.left, atom_map).implies(
        rename_formula(formula.right, atom_map)
    )


def check_isomorphism(
    source: Model,
    target: Model,
    world_map: Mapping[str, str],
    atom_map: Mapping[str, str],
) -> bool:
    """Check bijectivity plus preservation and reflection of all model data."""
    if set(world_map) != set(source.worlds) or set(world_map.values()) != set(target.worlds):
        return False
    if set(atom_map) != set(source.atoms) or set(atom_map.values()) != set(target.atoms):
        return False
    edges_match = all(
        (((w, x) in source.edges) == ((world_map[w], world_map[x]) in target.edges))
        for w, x in product(source.worlds, repeat=2)
    )
    values_match = all(
        (((w, a) in source.true_at) == ((world_map[w], atom_map[a]) in target.true_at))
        for w, a in product(source.worlds, source.atoms)
    )
    return edges_match and values_match


def formulas(atoms: Sequence[str], depth: int) -> Tuple[Formula, ...]:
    """Generate a finite test family containing all constructors through a depth bound."""
    current = tuple(Formula.var(a) for a in atoms) + (Formula.bottom(),)
    all_forms = list(current)
    for _ in range(depth):
        previous = tuple(all_forms)
        new_forms = [p.box() for p in previous]
        new_forms += [p.implies(q) for p in previous for q in previous]
        for item in new_forms:
            if item not in all_forms:
                all_forms.append(item)
    return tuple(all_forms)


def demo_structural_invariance() -> None:
    """Compare all generated formulas on two nontrivially renamed models."""
    source = Model(
        ("start", "safe", "risk"),
        ("ok", "alarm"),
        frozenset({("start", "safe"), ("start", "risk"), ("safe", "safe"), ("risk", "risk")}),
        frozenset({("start", "ok"), ("safe", "ok"), ("risk", "alarm")}),
    )
    world_map = {"start": "q2", "safe": "q0", "risk": "q1"}
    atom_map = {"ok": "green", "alarm": "red"}
    target = Model(
        ("q0", "q1", "q2"),
        ("green", "red"),
        frozenset((world_map[w], world_map[x]) for w, x in source.edges),
        frozenset((world_map[w], atom_map[a]) for w, a in source.true_at),
    )
    tests = formulas(source.atoms, 1)
    assert check_isomorphism(source, target, world_map, atom_map)
    agreements = sum(
        satisfies(source, w, p)
        == satisfies(target, world_map[w], rename_formula(p, atom_map))
        for w, p in product(source.worlds, tests)
    )
    total = len(source.worlds) * len(tests)
    print(f"Structural invariance: {agreements}/{total} transported evaluations agree.")
    assert agreements == total


def demo_composition() -> None:
    """Show that two renamings and their composite carry identical truth values."""
    p = Formula.var("ready")
    safety = p.box().implies(p)
    first = {"ready": "enabled"}
    second = {"enabled": "active"}
    composite = {key: second[value] for key, value in first.items()}
    sequential = rename_formula(rename_formula(safety, first), second)
    direct = rename_formula(safety, composite)
    print(f"Composition: sequential formula {sequential}; direct formula {direct}.")
    assert sequential == direct


def demo_meaning_collision() -> None:
    """Exhaust many formulas while opposite external labels remain invisible."""
    singleton = Model(
        ("only",),
        ("observed",),
        frozenset({("only", "only")}),
        frozenset({("only", "observed")}),
    )
    external_meaning_a = False
    external_meaning_b = True
    tests = formulas(singleton.atoms, 2)
    agreements = sum(
        satisfies(singleton, "only", formula) == satisfies(singleton, "only", formula)
        for formula in tests
    )
    print(
        f"Meaning collision: {agreements}/{len(tests)} formulas agree, "
        f"but labels are {external_meaning_a} and {external_meaning_b}."
    )
    assert agreements == len(tests)
    assert external_meaning_a != external_meaning_b


def main() -> None:
    demo_structural_invariance()
    demo_composition()
    demo_meaning_collision()


if __name__ == "__main__":
    main()
