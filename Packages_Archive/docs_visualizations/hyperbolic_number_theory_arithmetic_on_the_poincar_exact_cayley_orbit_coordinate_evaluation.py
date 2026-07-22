from __future__ import annotations
from fractions import Fraction

def orbit_data(n: int) -> tuple[complex, Fraction, Fraction]:
    point = n / complex(n, 2)
    radius_squared = Fraction(n*n, n*n + 4)
    defect = Fraction(4, n*n + 4)
    return point, radius_squared, defect

for n in range(-5, 6):
    point, radius_squared, defect = orbit_data(n)
    print(n, point, radius_squared, defect)
