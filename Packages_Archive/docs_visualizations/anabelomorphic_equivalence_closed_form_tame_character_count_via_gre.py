from __future__ import annotations
from math import gcd


def tame_character_count(p: int, f: int, n: int) -> int:
    """Number of characters of the residue torus of (p, f) whose order
    divides n.

    The residue torus is cyclic of order m = p^f - 1; a cyclic group of
    order m has exactly gcd(n, m) elements (hence characters) of order
    dividing n. This closed form is the arithmetic fingerprint driving the
    L-factor reconstruction program. Complexity O(log min(n, m)) via the
    Euclidean algorithm.
    """
    m = p ** f - 1
    return gcd(n, m)


def character_signature(p: int, f: int, bound: int) -> list[int]:
    """The signature (gcd(n, p^f - 1))_{n=1..bound}, a fingerprint of the
    residue-field size p^f."""
    return [tame_character_count(p, f, n) for n in range(1, bound + 1)]
