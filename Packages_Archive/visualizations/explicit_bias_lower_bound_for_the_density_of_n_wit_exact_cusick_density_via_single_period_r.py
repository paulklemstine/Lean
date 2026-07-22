from fractions import Fraction


def s2(n: int) -> int:
    """Binary sum-of-digits: number of 1-bits of n."""
    return bin(n).count("1")


def period(t: int) -> int:
    """Fundamental period P = 2^{L + s2(t)} of the Cusick predicate P_t."""
    L = max(1, t.bit_length())  # smallest L with t < 2^L
    return 2 ** (L + s2(t))


def cusick_count(t: int, N: int) -> int:
    """#{ n < N : s2(n) <= s2(n + t) }."""
    return sum(1 for n in range(N) if s2(n) <= s2(n + t))


def exact_cusick_density(t: int) -> Fraction:
    """Exact c_t as a dyadic rational = (count over one period) / period.

    Justified by pure periodicity (P_t depends only on n mod P) and the
    period-scaling identity cusickCount(t, P*m) = m * cusickCount(t, P).
    Complexity: O(P log P) with P = 2^{L + s2(t)}.
    """
    P = period(t)
    return Fraction(cusick_count(t, P), P)
