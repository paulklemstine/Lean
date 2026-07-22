from fractions import Fraction

def s2(n: int) -> int:
    """Binary digit sum (popcount) of n."""
    return bin(n).count("1")

def cusick_period(t: int) -> int:
    """Fundamental period 2^{L + s2(t)} where L = t.bit_length()."""
    return 2 ** (t.bit_length() + s2(t))

def cusick_count(t: int, N: int) -> int:
    """#{0 <= n < N : s2(n) <= s2(n+t)}."""
    return sum(1 for n in range(N) if s2(n) <= s2(n + t))

def exact_cusick_density(t: int) -> Fraction:
    """Exact c_t as a dyadic rational, via a single fundamental period."""
    P: int = cusick_period(t)
    return Fraction(cusick_count(t, P), P)
