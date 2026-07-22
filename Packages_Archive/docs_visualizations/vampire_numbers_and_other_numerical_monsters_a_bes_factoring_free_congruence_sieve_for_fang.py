from __future__ import annotations


def num_digits(n: int) -> int:
    return len(str(n))


def survives_sieves(x: int, y: int) -> bool:
    """Cheap factoring-free rejection tests for a candidate fang pair.

    Returns False as soon as any structural obstruction is violated.
    """
    # Casting out nines and its corollary.
    if (x * y) % 9 != (x + y) % 9:
        return False
    if ((x - 1) * (y - 1)) % 9 != 1 % 9:
        return False
    # Mod-three fang sieve.
    if x % 3 == 1 or y % 3 == 1:
        return False
    # No carry shrinkage.
    if num_digits(x * y) != num_digits(x) + num_digits(y):
        return False
    return True
