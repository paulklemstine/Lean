#!/usr/bin/env python3
"""Numerical demonstrations of diagonal omission and reflective rank.

The program uses only the Python standard library.  It constructs an omitted
Boolean predicate from any square inspection table, generates alternating
reflective towers, and checks that syntactic duality preserves rank.
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from random import Random
from typing import Iterable, Sequence, TypeAlias


BoolTable: TypeAlias = list[list[bool]]


class Polarity(Enum):
    """Universal and existential quantifier polarity."""

    UNIVERSAL = "forall"
    EXISTENTIAL = "exists"

    def dual(self) -> "Polarity":
        return (
            Polarity.EXISTENTIAL
            if self is Polarity.UNIVERSAL
            else Polarity.UNIVERSAL
        )


@dataclass(frozen=True)
class Code:
    """A small immutable syntax tree for reflective codes."""

    kind: str
    label: str = ""
    polarity: Polarity | None = None
    children: tuple["Code", ...] = ()


def atom(label: str) -> Code:
    return Code("atom", label=label)


def truth() -> Code:
    return Code("truth")


def falsity() -> Code:
    return Code("falsity")


def neg(code: Code) -> Code:
    return Code("neg", children=(code,))


def conj(left: Code, right: Code) -> Code:
    return Code("conj", children=(left, right))


def quant(polarity: Polarity, code: Code) -> Code:
    return Code("quant", polarity=polarity, children=(code,))


def self_bind(code: Code) -> Code:
    return Code("self", children=(code,))


def reflective_rank(code: Code) -> int:
    """Compute reflective rank in time linear in the syntax-tree size."""

    if code.kind in {"atom", "truth", "falsity"}:
        return 0
    if code.kind == "conj":
        return max(reflective_rank(code.children[0]), reflective_rank(code.children[1]))
    if code.kind == "neg":
        return reflective_rank(code.children[0])
    if code.kind in {"quant", "self"}:
        return reflective_rank(code.children[0]) + 1
    raise ValueError(f"unknown code kind: {code.kind}")


def dual(code: Code) -> Code:
    """Apply the rank-preserving dual operation."""

    if code.kind == "atom":
        return neg(code)
    if code.kind == "truth":
        return falsity()
    if code.kind == "falsity":
        return truth()
    if code.kind == "conj":
        return neg(conj(dual(code.children[0]), dual(code.children[1])))
    if code.kind == "neg":
        return code.children[0]
    if code.kind == "quant":
        if code.polarity is None:
            raise ValueError("quantified code lacks a polarity")
        return quant(code.polarity.dual(), dual(code.children[0]))
    if code.kind == "self":
        return self_bind(dual(code.children[0]))
    raise ValueError(f"unknown code kind: {code.kind}")


def alternating_tower(label: str, level: int) -> Code:
    """Construct the canonical alternating tower of exact rank ``level``."""

    if level < 0:
        raise ValueError("level must be nonnegative")
    code = atom(label)
    for n in range(level):
        polarity = Polarity.UNIVERSAL if n % 2 == 0 else Polarity.EXISTENTIAL
        code = quant(polarity, code)
    return code


def render(code: Code) -> str:
    """Render a reflective code as compact mathematical text."""

    if code.kind == "atom":
        return code.label
    if code.kind == "truth":
        return "⊤"
    if code.kind == "falsity":
        return "⊥"
    if code.kind == "neg":
        return f"¬({render(code.children[0])})"
    if code.kind == "conj":
        return f"({render(code.children[0])} ∧ {render(code.children[1])})"
    if code.kind == "quant":
        symbol = "∀" if code.polarity is Polarity.UNIVERSAL else "∃"
        return f"{symbol}({render(code.children[0])})"
    if code.kind == "self":
        return f"self({render(code.children[0])})"
    raise ValueError(f"unknown code kind: {code.kind}")


def diagonal_predicate(table: Sequence[Sequence[bool]]) -> list[bool]:
    """Complement the diagonal of a square Boolean inspection table."""

    size = len(table)
    if any(len(row) != size for row in table):
        raise ValueError("inspection table must be square")
    return [not table[i][i] for i in range(size)]


def diagonal_witnesses(table: Sequence[Sequence[bool]]) -> list[int]:
    """Return the coordinate witnessing disagreement with each table row."""

    diagonal = diagonal_predicate(table)
    witnesses: list[int] = []
    for i, row in enumerate(table):
        if row[i] == diagonal[i]:
            raise AssertionError("diagonal construction failed")
        witnesses.append(i)
    return witnesses


def random_boolean_table(size: int, seed: int = 20260720) -> BoolTable:
    """Generate a reproducible square Boolean table."""

    if size < 0:
        raise ValueError("size must be nonnegative")
    rng = Random(seed)
    return [[bool(rng.getrandbits(1)) for _ in range(size)] for _ in range(size)]


def bits(values: Iterable[bool]) -> str:
    return "".join("1" if value else "0" for value in values)


def demonstrate_diagonal_omission(size: int = 8) -> None:
    """Print a finite inspection table and its provably omitted row."""

    table = random_boolean_table(size)
    omitted = diagonal_predicate(table)
    witnesses = diagonal_witnesses(table)
    print("DIAGONAL OMISSION")
    for i, row in enumerate(table):
        print(f"  row {i}: {bits(row)}")
    print(f"  omitted: {bits(omitted)}")
    print(f"  witness coordinates: {witnesses}")
    assert all(list(row) != omitted for row in table)


def demonstrate_alternating_hierarchy(max_level: int = 8) -> None:
    """Generate canonical towers and verify their exact, distinct ranks."""

    print("\nALTERNATING REFLECTIVE HIERARCHY")
    rendered: set[str] = set()
    for level in range(max_level + 1):
        code = alternating_tower("a", level)
        rank = reflective_rank(code)
        text = render(code)
        print(f"  level {level}: rank={rank}, code={text}")
        assert rank == level
        assert text not in rendered
        rendered.add(text)


def demonstrate_rank_preserving_duality() -> None:
    """Check duality on a code mixing conjunction, quantifiers, and self-binding."""

    code = self_bind(
        conj(
            quant(Polarity.UNIVERSAL, atom("p")),
            neg(quant(Polarity.EXISTENTIAL, self_bind(atom("q")))),
        )
    )
    code_dual = dual(code)
    print("\nRANK-PRESERVING DUALITY")
    print(f"  original: {render(code)}")
    print(f"  dual:     {render(code_dual)}")
    print(f"  ranks:    {reflective_rank(code)} = {reflective_rank(code_dual)}")
    assert reflective_rank(code) == reflective_rank(code_dual)
    assert Polarity.UNIVERSAL.dual().dual() is Polarity.UNIVERSAL
    assert Polarity.EXISTENTIAL.dual().dual() is Polarity.EXISTENTIAL


def demonstrate_singleton_counterexample() -> None:
    """Display the one-element recursive presentation with decidable equality."""

    carrier = ("★",)
    dependent_product = ("the unique proof assignment",)
    comparison = [[x == y for y in carrier] for x in carrier]
    print("\nSINGLETON RECURSIVE PRESENTATION")
    print(f"  carrier size: {len(carrier)}")
    print(f"  dependent-product size: {len(dependent_product)}")
    print(f"  equality table: {comparison}")
    assert len(carrier) == len(dependent_product) == 1
    assert comparison == [[True]]


def main() -> None:
    demonstrate_singleton_counterexample()
    demonstrate_diagonal_omission()
    demonstrate_alternating_hierarchy()
    demonstrate_rank_preserving_duality()
    print("\nAll demonstrations completed successfully.")


if __name__ == "__main__":
    main()
