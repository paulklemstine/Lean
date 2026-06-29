from math import gcd
from typing import Iterator, Tuple


def pythagorean_triples(limit: int) -> Iterator[Tuple[int, int, int]]:
    """Generate primitive Pythagorean triples via the stereographic chart.

    For a rational address p/q in lowest terms the chart sigma(p/q) clears
    denominators to the integer triple (2pq, q^2 - p^2, p^2 + q^2), which is
    Euclid's formula. A triple is primitive when gcd(p, q) = 1 and p, q have
    opposite parity. Complexity: O(limit^2) candidate pairs, O(1) work each.
    """
    for q in range(2, limit + 1):
        for p in range(1, q):
            if gcd(p, q) != 1:
                continue
            if (q - p) % 2 == 0:  # need opposite parity for a primitive triple
                continue
            a = 2 * p * q
            b = q * q - p * p
            c = p * p + q * q
            yield (min(a, b), max(a, b), c)
