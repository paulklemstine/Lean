from __future__ import annotations


def s2(n: int) -> int:
    return bin(n).count("1")


def s2_bound(x: int, y: int) -> int:
    """Return the certified submultiplicative bound on s2(x*y)."""
    return min(y * s2(x), x * s2(y))


def certify_binary_bound(x: int, y: int) -> tuple[int, int, bool]:
    """Return (actual s2, bound, holds) for the product x*y."""
    actual = s2(x * y)
    b = s2_bound(x, y)
    return actual, b, actual <= b
