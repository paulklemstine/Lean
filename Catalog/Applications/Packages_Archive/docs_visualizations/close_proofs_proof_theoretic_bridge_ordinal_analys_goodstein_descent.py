from __future__ import annotations
from typing import List, Tuple


def hereditary_base(m: int, b: int) -> List[Tuple[int, int]]:
    """Digits of m in base b as [(exponent, digit), ...] (descending)."""
    out: List[Tuple[int, int]] = []
    e = 0
    while m > 0:
        d = m % b
        if d:
            out.append((e, d))
        m //= b
        e += 1
    return list(reversed(out))


def goodstein_step(m: int, b: int) -> int:
    """One Goodstein step: rewrite m hereditarily in base b, bump b->b+1, -1."""
    if m == 0:
        return 0
    def rebase(x: int, base: int) -> int:
        if x < base:
            return x
        return sum(d * (base + 1) ** rebase(e, base)
                   for (e, d) in hereditary_base(x, base))
    bumped = sum(d * (b + 1) ** rebase(e, b)
                 for (e, d) in hereditary_base(m, b))
    return bumped - 1


def goodstein_sequence(start: int, steps: int) -> List[Tuple[int, int]]:
    """Return [(base, value)] for the first `steps` Goodstein states."""
    out: List[Tuple[int, int]] = []
    m, b = start, 2
    for _ in range(steps):
        out.append((b, m))
        if m == 0:
            break
        m = goodstein_step(m, b)
        b += 1
    return out
