from __future__ import annotations


def s2(n: int) -> int:
    """Binary sum-of-digits (popcount)."""
    return bin(n).count("1")


def base2_carries(n: int, t: int) -> int:
    """Number of carries when adding n and t in base 2 (single linear scan)."""
    carries: int = 0
    carry: int = 0
    while n > 0 or t > 0 or carry > 0:
        s: int = (n & 1) + (t & 1) + carry
        carry = s >> 1
        carries += carry
        n >>= 1
        t >>= 1
    return carries


def cusick_predicate(n: int, t: int) -> bool:
    """Decide s2(n) <= s2(n+t) via the carry criterion carries <= s2(t)."""
    return base2_carries(n, t) <= s2(t)
