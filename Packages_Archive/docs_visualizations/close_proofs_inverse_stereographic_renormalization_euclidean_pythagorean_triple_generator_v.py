from math import gcd
from typing import List, Tuple

def pythagorean_triples(limit: int) -> List[Tuple[int, int, int]]:
    """Primitive Pythagorean triples from sigma(n/m), m up to `limit`."""
    out: List[Tuple[int, int, int]] = []
    for m in range(2, limit + 1):
        for n in range(1, m):
            if gcd(m, n) == 1 and (m - n) % 2 == 1:
                a, b, c = 2 * m * n, m * m - n * n, m * m + n * n
                out.append((min(a, b), max(a, b), c))
    return out

if __name__ == "__main__":
    for tr in pythagorean_triples(6):
        a, b, c = tr
        print(tr, "check:", a * a + b * b - c * c)
