from typing import Tuple

Triple = Tuple[int, int, int]


def gaussian_triple(m: int, n: int) -> Triple:
    """Encode (m + n i)^2 as the triple (m^2 - n^2, 2mn, m^2 + n^2).

    For coprime m > n > 0 of opposite parity this yields every primitive
    Pythagorean triple exactly once. O(1) integer arithmetic."""
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def gaussian_norm(m: int, n: int) -> int:
    """N(m + n i) = m^2 + n^2, which equals the hypotenuse of the triple
    and is multiplicative: N(z w) = N(z) N(w)."""
    return m * m + n * n
