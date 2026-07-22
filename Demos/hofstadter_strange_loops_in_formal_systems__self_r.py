#!/usr/bin/env python3
"""Finite demonstrations of coded strange-loop theorems.

The script does not attempt to decide truth or provability. It displays the
finite combinatorial consequences of the stated hypotheses: rank separation,
the liar obstruction, and transport of incompleteness along interpretations.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Iterable, List, Sequence, Tuple


@dataclass(frozen=True)
class RankedWitness:
    """A symbolic rank-separated Gödel witness."""

    index: int
    name: str
    rank: int
    true: bool
    provable: bool
    negation_provable: bool


@dataclass(frozen=True)
class TransportedWitness:
    """A true-but-unprovable sentence placed at a system level."""

    system: str
    sentence: str
    origin: str
    true: bool = True
    provable: bool = False


def generate_ranked_witnesses(count: int) -> List[RankedWitness]:
    """Generate the first ``count`` theorem-certified symbolic witnesses.

    Each witness has prescribed rank n. Under the soundness and fixed-point
    hypotheses, it is true while it and its negation are unprovable.
    """
    if count < 0:
        raise ValueError("count must be nonnegative")
    return [
        RankedWitness(
            index=n,
            name=f"G_{n}",
            rank=n,
            true=True,
            provable=False,
            negation_provable=False,
        )
        for n in range(count)
    ]


def ranks_certify_distinctness(witnesses: Sequence[RankedWitness]) -> bool:
    """Check finite rank separation in linear expected time."""
    ranks = [w.rank for w in witnesses]
    return len(ranks) == len(set(ranks))


def liar_equivalence_table() -> List[Tuple[bool, bool, bool]]:
    """Return rows (T(L), not T(L), equivalence) for both truth values."""
    return [(value, not value, value == (not value)) for value in (False, True)]


def transport_two_level_tangle(lower: str = "Lower", upper: str = "Upper") -> List[TransportedWitness]:
    """Propagate native incompleteness witnesses around a two-level cycle."""
    return [
        TransportedWitness(lower, "G_lower", lower),
        TransportedWitness(upper, "I(G_lower)", lower),
        TransportedWitness(upper, "G_upper", upper),
        TransportedWitness(lower, "J(G_upper)", upper),
    ]


def adjacency_matrix(nodes: Sequence[str], edges: Iterable[Tuple[str, str]]) -> List[List[int]]:
    """Build a zero-one adjacency matrix for a finite interpretation graph."""
    positions: Dict[str, int] = {node: i for i, node in enumerate(nodes)}
    matrix = [[0 for _ in nodes] for _ in nodes]
    for source, target in edges:
        matrix[positions[source]][positions[target]] = 1
    return matrix


def print_rank_demo(count: int = 8) -> None:
    """Print a table for the finite prefix of the ranked family."""
    witnesses = generate_ranked_witnesses(count)
    print("RANK-SEPARATED STRANGE LOOPS")
    print("name  rank  true  provable  negation provable")
    for witness in witnesses:
        print(
            f"{witness.name:5} {witness.rank:4}  {str(witness.true):5} "
            f"{str(witness.provable):8}  {witness.negation_provable}"
        )
    print(f"Distinctness certified by ranks: {ranks_certify_distinctness(witnesses)}\n")


def print_tarski_demo() -> None:
    """Print the two-valued obstruction to T(L) iff not T(L)."""
    print("TARSKI/LIAR OBSTRUCTION")
    print("T(L)   not T(L)   T(L) iff not T(L)")
    for truth, untruth, equivalent in liar_equivalence_table():
        print(f"{str(truth):5}  {str(untruth):8}   {equivalent}")
    print("No truth value satisfies the demanded fixed-point equivalence.\n")


def print_tangle_demo() -> None:
    """Print native and transported witnesses in a two-level cycle."""
    print("TWO-LEVEL TANGLED HIERARCHY")
    for witness in transport_two_level_tangle():
        print(
            f"{witness.system:5}: {witness.sentence:12} "
            f"(origin={witness.origin}, true={witness.true}, provable={witness.provable})"
        )
    nodes = ["Lower", "Upper"]
    matrix = adjacency_matrix(nodes, [("Lower", "Upper"), ("Upper", "Lower")])
    print(f"Interpretation adjacency matrix: {matrix}")


def main() -> None:
    """Run all three demonstrations."""
    print_rank_demo()
    print_tarski_demo()
    print_tangle_demo()


if __name__ == "__main__":
    main()
