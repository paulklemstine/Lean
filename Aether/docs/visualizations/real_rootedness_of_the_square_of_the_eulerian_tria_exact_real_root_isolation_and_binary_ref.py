from fractions import Fraction
from typing import List, Tuple

def isolate_and_refine(coeffs: List[int], sign_changes_fn, precision_bits: int = 60) -> List[float]:
    """Isolate real roots by recursive bisection on the Sturm sign-change count,
    then refine each isolating interval to precision_bits binary digits.
    `sign_changes_fn(x: Fraction) -> int` returns V(x) from the Sturm chain of `coeffs`."""
    lo, hi = Fraction(-1 << 40), Fraction(1 << 40)
    stack: List[Tuple[Fraction, Fraction]] = [(lo, hi)]
    roots: List[float] = []
    while stack:
        a, b = stack.pop()
        c = sign_changes_fn(a) - sign_changes_fn(b)
        if c == 0:
            continue
        if c == 1:
            for _ in range(precision_bits):
                m = (a + b) / 2
                if sign_changes_fn(a) - sign_changes_fn(m) >= 1:
                    b = m
                else:
                    a = m
            roots.append(float((a + b) / 2))
        else:
            m = (a + b) / 2
            stack.append((a, m)); stack.append((m, b))
    return sorted(roots)
