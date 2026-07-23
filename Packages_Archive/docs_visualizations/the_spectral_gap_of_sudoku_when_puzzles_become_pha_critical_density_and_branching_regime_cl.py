from fractions import Fraction
from typing import Tuple

def classify_regime(n: int, d: Fraction) -> Tuple[str, Fraction, Fraction, Fraction]:
    """Classify clue density d for order-n Sudoku via the branching factor."""
    d_c: Fraction = Fraction(1) - Fraction(1, n ** 2)
    branching: Fraction = Fraction(n ** 2) * (Fraction(1) - d)
    free: Fraction = Fraction(n ** 4) * (Fraction(1) - d)
    if branching > 1:
        regime = 'subcritical'
    elif branching == 1:
        regime = 'critical'
    else:
        regime = 'supercritical'
    return regime, d_c, branching, free