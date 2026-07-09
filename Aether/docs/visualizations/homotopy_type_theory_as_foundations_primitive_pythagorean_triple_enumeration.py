from math import gcd
from typing import Iterator

def enumerate_primitive(C: int) -> Iterator[tuple[int, int, int]]:
    """Yield each primitive triple with odd first leg, hyp <= C, once."""
    m = 2
    while m * m + 1 <= C:
        for n in range(1, m):
            if gcd(m, n) == 1 and (m - n) % 2 == 1 and m * m + n * n <= C:
                yield (abs(m*m - n*n), 2 * m * n, m*m + n*n)
        m += 1
