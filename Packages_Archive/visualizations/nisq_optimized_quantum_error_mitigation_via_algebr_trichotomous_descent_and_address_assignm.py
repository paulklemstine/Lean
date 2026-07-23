from math import gcd
from typing import List, Tuple

Pair = Tuple[int, int]


def parent(m: int, n: int) -> Tuple[str, Pair]:
    """Unique parent of a non-root valid pair via the m vs 2n, 3n trichotomy."""
    if (m, n) == (2, 1):
        raise ValueError("root (2, 1) has no parent")
    if m < 2 * n:                       # band n < m < 2n  -> branch A
        return "A", (n, 2 * n - m)
    if m < 3 * n:                       # band 2n < m < 3n -> branch B
        return "B", (n, m - 2 * n)
    return "C", (m - 2 * n, n)          # band m > 3n      -> branch C


def address(m: int, n: int) -> str:
    """Root-to-node word in {A, B, C}* obtained by repeated descent."""
    letters: List[str] = []
    while (m, n) != (2, 1):
        br, (m, n) = parent(m, n)
        letters.append(br)
    return "".join(reversed(letters))
