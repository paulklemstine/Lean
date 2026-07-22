from __future__ import annotations
from typing import Iterator, List, Tuple


def enumerate_statements(num_symbols: int) -> Iterator[Tuple[int, ...]]:
    """Lazily enumerate every finite string over an alphabet with `num_symbols`
    symbols, ordered by length then lexicographically. An explicit bijection
    N -> Sigma* witnessing countability."""
    if num_symbols < 1:
        raise ValueError("alphabet must have at least one symbol")
    length: int = 0
    while True:
        for code in range(num_symbols ** length):
            digits: List[int] = []
            x = code
            for _ in range(length):
                digits.append(x % num_symbols)
                x //= num_symbols
            yield tuple(reversed(digits))
        length += 1


def statement_index(num_symbols: int, word: Tuple[int, ...]) -> int:
    """Inverse map Sigma* -> N: recover the enumeration index of a word."""
    n = len(word)
    if num_symbols == 1:
        offset = n
    else:
        offset = (num_symbols ** n - 1) // (num_symbols - 1)
    rank = 0
    for d in word:
        if not (0 <= d < num_symbols):
            raise ValueError("symbol out of range")
        rank = rank * num_symbols + d
    return offset + rank
