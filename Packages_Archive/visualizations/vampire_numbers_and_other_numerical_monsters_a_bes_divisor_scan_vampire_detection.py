from __future__ import annotations


def num_digits(n: int) -> int:
    return len(str(n))


def digit_multiset(n: int) -> list[int]:
    return sorted(int(c) for c in str(n))


def vampire_pairs(v: int) -> list[tuple[int, int]]:
    """Return all vampire fang pairs (x, y), x <= y, of v via divisor scan."""
    if num_digits(v) % 2:
        return []
    k = num_digits(v) // 2
    pairs: list[tuple[int, int]] = []
    x = 1
    while x * x <= v:
        if v % x == 0:
            y = v // x
            if (num_digits(x) == k and num_digits(y) == k
                    and not (x % 10 == 0 and y % 10 == 0)
                    and sorted(digit_multiset(x) + digit_multiset(y))
                    == digit_multiset(v)):
                pairs.append((x, y))
        x += 1
    return pairs
