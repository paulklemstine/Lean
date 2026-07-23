from itertools import product
from typing import Callable

Op = Callable[[int, int], int]

def is_eh_data(n: int, m1: Op, m2: Op, unit: int) -> bool:
    """Decide whether (m1, m2, unit) is Eckmann-Hilton data on {0..n-1}."""
    for x in range(n):
        if m1(unit, x) != x or m1(x, unit) != x:
            return False
        if m2(unit, x) != x or m2(x, unit) != x:
            return False
    for a, b, c, d in product(range(n), repeat=4):
        if m1(m2(a, b), m2(c, d)) != m2(m1(a, c), m1(b, d)):
            return False
    return True
