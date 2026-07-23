from fractions import Fraction
from itertools import product
from typing import Callable

Book = tuple[int, ...]

def acceptance(q: int, n: int, checker: Callable[[Book], bool]) -> tuple[int, Fraction]:
    if q <= 0 or n < 0:
        raise ValueError("nonempty library required")
    count = sum(checker(tuple(w)) for w in product(range(q), repeat=n))
    return count, Fraction(count, q ** n)

if __name__ == "__main__":
    print(acceptance(2, 8, lambda w: sum(w) == 4))
