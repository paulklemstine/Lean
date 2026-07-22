import itertools
from typing import Sequence

def discrepancy_profile(code: Sequence[tuple[int, ...]], n: int, q: int, r: int) -> dict[int, int]:
    """Empirical distribution of N_C(z) = |C n B_r(z)| over all centres.

    Brute-force certification of the averaging identity and study of concentration.
    Returns a histogram {count_value: number_of_centres}. Complexity Theta(q^n * |C|).
    """
    cs = set(code)
    histogram: dict[int, int] = {}
    for z in itertools.product(range(q), repeat=n):
        nc: int = sum(1 for x in cs if sum(a != b for a, b in zip(x, z)) <= r)
        histogram[nc] = histogram.get(nc, 0) + 1
    return histogram
