#!/usr/bin/env python3
"""Finite demonstrations of diagonalization, oracle ambiguity, and memory quotients."""
from __future__ import annotations

from collections import defaultdict
from itertools import product
from typing import Callable, Dict, Hashable, Iterable, List, Sequence, Set, Tuple, TypeVar

Symbol = TypeVar("Symbol", bound=Hashable)
Word = Tuple[Symbol, ...]


def anti_diagonal(table: Sequence[Sequence[int]]) -> List[int]:
    """Return the complemented diagonal of a square Boolean table."""
    n = len(table)
    if any(len(row) != n for row in table):
        raise ValueError("table must be square")
    if any(bit not in (0, 1) for row in table for bit in row):
        raise ValueError("entries must be 0 or 1")
    return [1 - table[i][i] for i in range(n)]


def diagonal_witnesses(table: Sequence[Sequence[int]]) -> List[Tuple[int, int, int]]:
    """For each row, report its diagonal value and the opposing anti-diagonal bit."""
    diagonal = anti_diagonal(table)
    return [(i, table[i][i], diagonal[i]) for i in range(len(table))]


def transcript_rival(oracle: Sequence[int], queries: Set[int]) -> Tuple[List[int], int]:
    """Flip the least unqueried coordinate, preserving every queried answer."""
    if any(bit not in (0, 1) for bit in oracle):
        raise ValueError("oracle entries must be 0 or 1")
    if any(q < 0 or q >= len(oracle) for q in queries):
        raise ValueError("query outside the represented prefix")
    unqueried = next((i for i in range(len(oracle)) if i not in queries), None)
    if unqueried is None:
        raise ValueError("the finite prefix has no unqueried coordinate")
    rival = list(oracle)
    rival[unqueried] = 1 - rival[unqueried]
    return rival, unqueried


def targeted_forgetting(word: Sequence[Symbol], retain: Callable[[Symbol], bool]) -> Word[Symbol]:
    """Delete unretained symbols while preserving the order of retained symbols."""
    return tuple(symbol for symbol in word if retain(symbol))


def quotient_classes(
    alphabet: Sequence[Symbol], max_length: int, retain: Callable[[Symbol], bool]
) -> Dict[Word[Symbol], List[Word[Symbol]]]:
    """Group all words up to max_length by their observable retained subsequence."""
    classes: Dict[Word[Symbol], List[Word[Symbol]]] = defaultdict(list)
    for length in range(max_length + 1):
        for word in product(alphabet, repeat=length):
            classes[targeted_forgetting(word, retain)].append(word)
    return dict(classes)


def finite_loader_capacity(bits: int) -> Tuple[int, int]:
    """Count length-b bitstreams and the minimum states required by exact loading."""
    if bits < 0:
        raise ValueError("bits must be nonnegative")
    oracle_count = 2**bits
    return oracle_count, oracle_count


def run_demo() -> None:
    table = [
        [0, 0, 1, 1, 0, 1],
        [1, 1, 1, 0, 0, 0],
        [0, 1, 0, 1, 0, 1],
        [1, 0, 0, 1, 1, 0],
        [1, 1, 0, 0, 1, 0],
        [0, 1, 1, 0, 1, 1],
    ]
    diagonal = anti_diagonal(table)
    print("ANTI-DIAGONAL DEMONSTRATION")
    print("anti-diagonal:", diagonal)
    for row, own_bit, diagonal_bit in diagonal_witnesses(table):
        print(f"row {row}: T[{row},{row}]={own_bit}, D[{row}]={diagonal_bit}, differ=True")
    assert all(table[i][i] != diagonal[i] for i in range(len(table)))

    oracle = [1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 0, 1]
    queries = {0, 2, 3, 6, 8}
    rival, flipped = transcript_rival(oracle, queries)
    print("\nFINITE-TRANSCRIPT AMBIGUITY")
    print("queried indices:", sorted(queries))
    print("original answers:", [oracle[q] for q in sorted(queries)])
    print("rival answers:   ", [rival[q] for q in sorted(queries)])
    print(f"rival differs at unqueried index {flipped}")
    assert all(oracle[q] == rival[q] for q in queries) and oracle != rival

    print("\nFINITE LOADER CAPACITY")
    for bits in range(1, 13):
        streams, states = finite_loader_capacity(bits)
        print(f"{bits:2d} bits: {streams:5d} possible oracles, at least {states:5d} exact states")

    alphabet = ("a", "b", "x")
    retain = lambda symbol: symbol != "x"
    classes = quotient_classes(alphabet, 3, retain)
    sample = ("a", "x", "b", "x")
    print("\nTARGETED FORGETTING AND QUOTIENT CLASSES")
    print(sample, "maps to", targeted_forgetting(sample, retain))
    print("words of length at most 3:", sum(map(len, classes.values())))
    print("observable quotient classes:", len(classes))
    key = ("a", "b")
    print("sample class with observable word", key, ":", classes[key])
    x, y = ("a", "x"), ("x", "b")
    assert targeted_forgetting(x + y, retain) == (
        targeted_forgetting(x, retain) + targeted_forgetting(y, retain)
    )
    print("concatenation law checked on", x, "and", y)


if __name__ == "__main__":
    run_demo()
