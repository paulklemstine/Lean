from math import gcd
from typing import List, Sequence, Tuple

Perm = Tuple[int, ...]

def compose(p: Perm, q: Perm) -> Perm:
    """Group product (p * q): apply q first, then p."""
    return tuple(p[q[i]] for i in range(len(p)))

def order(p: Perm) -> int:
    """Order of a permutation = lcm of its cycle lengths."""
    n = len(p)
    seen = [False] * n
    result = 1
    for start in range(n):
        if seen[start]:
            continue
        length, j = 0, start
        while not seen[j]:
            seen[j] = True
            j = p[j]
            length += 1
        result = result * length // gcd(result, length)
    return result

def period_matrix(gens: Sequence[Perm]) -> List[List[int]]:
    """period(i, j) = order(gens[i] * gens[j])."""
    r = len(gens)
    return [[order(compose(gens[i], gens[j])) for j in range(r)] for i in range(r)]

def schlafli(gens: Sequence[Perm]) -> List[int]:
    """First sub-diagonal: order(gens[k] * gens[k+1])."""
    r = len(gens)
    return [order(compose(gens[k], gens[k + 1])) for k in range(r - 1)]

def schlafli_is_palindrome(gens: Sequence[Perm]) -> bool:
    """True iff the Schlafli symbol reads the same forwards and backwards.
    A self-dual representation always returns True (palindrome theorem);
    a False result certifies that the representation is NOT self-dual."""
    s = schlafli(gens)
    return s == s[::-1]
