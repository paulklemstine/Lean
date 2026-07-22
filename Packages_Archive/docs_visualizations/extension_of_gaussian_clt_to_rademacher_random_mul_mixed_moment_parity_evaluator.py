from typing import List, Sequence


def prime_factors(n: int) -> List[int]:
    factors: List[int] = []
    d, m = 2, n
    while d * d <= m:
        if m % d == 0:
            factors.append(d)
            while m % d == 0:
                m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        factors.append(m)
    return factors


def is_squarefree(n: int) -> bool:
    m, d = n, 2
    while d * d <= m:
        if m % (d * d) == 0:
            return False
        if m % d == 0:
            m //= d
        else:
            d += 1 if d == 2 else 2
    return n >= 1


def mixed_moment(indices: Sequence[int]) -> int:
    """E[f(n_1) ... f(n_k)] for the Rademacher model, computed by parity.

    The moment is 1 iff every n_i is squarefree and every prime divides an even
    number of the indices; otherwise it is 0. Complexity O(sum omega(n_i)).
    """
    exponent: dict[int, int] = {}
    for n in indices:
        if not is_squarefree(n):
            return 0
        for p in prime_factors(n):
            exponent[p] = exponent.get(p, 0) + 1
    return 1 if all(e % 2 == 0 for e in exponent.values()) else 0
