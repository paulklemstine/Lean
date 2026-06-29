from fractions import Fraction
from typing import Callable, Sequence, List, Tuple

def homotopy_cardinality(
    group: Sequence[object],
    points: Sequence[object],
    action: Callable[[object, object], object],
) -> Fraction:
    """|X // G| = sum over orbits of 1/|Stab(rep)| (exact rational)."""
    seen: set = set()
    total = Fraction(0)
    for x in points:
        if x in seen:
            continue
        orbit = {action(g, x) for g in group}
        seen |= orbit
        stab_order = sum(1 for g in group if action(g, x) == x)
        total += Fraction(1, stab_order)
    return total  # == Fraction(len(points), len(group))
