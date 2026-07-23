from typing import Iterator, Tuple

def enumerate_triples(bound: int) -> Iterator[Tuple[int, int, int]]:
    """Generate Pythagorean triples via Euclid's parametrization.
    For each m > n > 0 emit (m^2 - n^2, 2mn, m^2 + n^2); scaling reaches
    non-primitive triples."""
    for m in range(2, bound + 1):
        for n in range(1, m):
            a, b, c = m * m - n * n, 2 * m * n, m * m + n * n
            yield (a, b, c)
