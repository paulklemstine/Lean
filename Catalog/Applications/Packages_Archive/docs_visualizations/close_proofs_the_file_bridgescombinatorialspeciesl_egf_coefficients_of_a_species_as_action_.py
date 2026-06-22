from fractions import Fraction
from itertools import permutations
from typing import Callable, List, Sequence

def species_egf_coeffs(
    structure_set: Callable[[int], Sequence[object]],
    action: Callable[[int], Callable[[tuple, object], object]],
    N: int,
) -> List[Fraction]:
    """[X^n] EGF(F) = |F[n] // S_n| for n = 0..N (exact rationals)."""
    coeffs: List[Fraction] = []
    for n in range(N + 1):
        group = list(permutations(range(n)))   # S_n
        points = list(structure_set(n))        # F[n]
        act = action(n)
        seen: set = set()
        total = Fraction(0)
        for x in points:
            if x in seen:
                continue
            orbit = {act(g, x) for g in group}
            seen |= orbit
            stab = sum(1 for g in group if act(g, x) == x)
            total += Fraction(1, stab)
        coeffs.append(total)
    return coeffs
