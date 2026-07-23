from fractions import Fraction
from itertools import product
from typing import Callable

Word = tuple[int, ...]

def exact_probability(q: int, n: int, accepts: Callable[[Word], bool]) -> Fraction:
    if q < 1 or n < 0:
        raise ValueError("invalid dimensions")
    accepted = sum(1 for w in product(range(q), repeat=n) if accepts(w))
    return Fraction(accepted, q ** n)

if __name__ == "__main__":
    print(exact_probability(4, 6, lambda w: sum(w) % 3 == 0))
