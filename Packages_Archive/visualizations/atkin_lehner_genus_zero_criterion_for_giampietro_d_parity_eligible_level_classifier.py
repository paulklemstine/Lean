from typing import List

def is_squarefree(n: int) -> bool:
    m, d = n, 2
    while d * d <= m:
        if m % (d * d) == 0:
            return False
        while m % d == 0:
            m //= d
        d += 1
    return True

def omega(n: int) -> int:
    """Number of distinct prime factors of n."""
    count, m, d = 0, n, 2
    while d * d <= m:
        if m % d == 0:
            count += 1
            while m % d == 0:
                m //= d
        d += 1
    if m > 1:
        count += 1
    return count

def moebius(n: int) -> int:
    if n == 1:
        return 1
    if not is_squarefree(n):
        return 0
    return (-1) ** omega(n)

def eligible_levels(limit: int) -> List[int]:
    """Squarefree N <= limit with an even number of prime factors (mu(N) = 1).

    These are exactly the levels admitted by the Giampietro-Darmon parity
    hypothesis; the group AL(N) is (Z/2)^omega(N) with |AL(N)| = 2^omega(N).
    """
    return [N for N in range(2, limit + 1)
            if is_squarefree(N) and moebius(N) == 1]
