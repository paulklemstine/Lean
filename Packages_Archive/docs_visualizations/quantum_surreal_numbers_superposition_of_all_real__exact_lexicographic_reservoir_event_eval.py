from __future__ import annotations
from fractions import Fraction

def event_mass(n: int, visible_count: int, reservoir: bool) -> tuple[Fraction, Fraction]:
    if not 0 <= visible_count <= n:
        raise ValueError("visible_count must lie between 0 and n")
    flag = int(reservoir)
    return Fraction(flag), Fraction(visible_count - n * flag)

def standard_part(value: tuple[Fraction, Fraction]) -> Fraction:
    return value[0]

for k, r in ((1, False), (4, False), (0, True), (4, True)):
    mass = event_mass(4, k, r)
    print(k, r, mass, standard_part(mass))
