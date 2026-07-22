from fractions import Fraction
from typing import Iterator
def birthday_spectrum(N: int) -> Iterator[tuple[Fraction,int,int]]:
    if N < 0: raise ValueError("nonnegative cutoff required")
    for n in range(N): yield Fraction(1,2**n), n+1, n+1
