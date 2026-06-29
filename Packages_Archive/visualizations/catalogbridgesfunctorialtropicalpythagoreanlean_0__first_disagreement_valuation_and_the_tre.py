from fractions import Fraction
from typing import Callable

Address = Callable[[int], int]


def first_diff(x: Address, y: Address, horizon: int = 256) -> int:
    """Least index n with x(n) != y(n); 0 if equal within `horizon`.

    Runs in O(firstDiff) coordinate comparisons. This is the min-plus
    valuation underlying the tree ultrametric."""
    for n in range(horizon):
        if x(n) != y(n):
            return n
    return 0


def ultra_distance(x: Address, y: Address, horizon: int = 256) -> Fraction:
    """Tree ultrametric d(x, y) = (1/2) ** firstDiff(x, y); exact via Fraction.

    Satisfies the strong triangle inequality d(x,z) <= max(d(x,y), d(y,z))."""
    n = first_diff(x, y, horizon)
    if n == 0 and all(x(i) == y(i) for i in range(horizon)):
        return Fraction(0)
    return Fraction(1, 2) ** n
