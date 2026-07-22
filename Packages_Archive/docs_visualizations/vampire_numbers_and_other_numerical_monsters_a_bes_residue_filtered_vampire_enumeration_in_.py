from collections import Counter
from typing import List, Tuple


def digits(b: int, n: int) -> List[int]:
    out: List[int] = []
    while n > 0:
        out.append(n % b)
        n //= b
    return out


def is_fang_pair(b: int, x: int, y: int) -> bool:
    return Counter(digits(b, x * y)) == Counter(digits(b, x)) + Counter(digits(b, y))


def enumerate_vampires(b: int, width: int) -> List[Tuple[int, int, int]]:
    """List all vampires with exactly `width` (even) base-b digits, applying the
    residue filter (x-1)(y-1) == 1 (mod b-1) from the unit law BEFORE the more
    expensive digit-multiset test. The filter is a necessary condition, so it is
    lossless while pruning a constant fraction of candidate pairs."""
    if width % 2 != 0:
        raise ValueError("width must be even")
    half = width // 2
    lo, hi = b ** (half - 1), b ** half
    m = b - 1
    out: List[Tuple[int, int, int]] = []
    for x in range(lo, hi):
        for y in range(x, hi):
            if ((x - 1) * (y - 1)) % m != 1 % m:      # lossless residue prune
                continue
            if x % b == 0 and y % b == 0:
                continue
            v = x * y
            if b ** (width - 1) <= v < b ** width and is_fang_pair(b, x, y):
                out.append((v, x, y))
    return sorted(out)
