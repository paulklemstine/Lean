from fractions import Fraction

def s2(n: int) -> int:
    return bin(n).count("1")

def binary_reverse(t: int) -> int:
    """Reverse the L-bit binary string of t, L = t.bit_length()."""
    L: int = t.bit_length()
    out: int = 0
    for i in range(L):
        out |= ((t >> i) & 1) << (L - 1 - i)
    return out

def cusick_period(t: int) -> int:
    return 2 ** (t.bit_length() + s2(t))

def cusick_count(t: int, N: int) -> int:
    return sum(1 for n in range(N) if s2(n) <= s2(n + t))

def exact_cusick_density(t: int) -> Fraction:
    P: int = cusick_period(t)
    return Fraction(cusick_count(t, P), P)

def certify_reversal_invariance(t: int) -> dict:
    """Check c_t = c_rev(t) for the binary-reversal partner of t."""
    r: int = binary_reverse(t)
    ct, cr = exact_cusick_density(t), exact_cusick_density(r)
    return {
        "t": t, "rev": r,
        "s2_equal": s2(t) == s2(r),
        "period_equal": cusick_period(t) == cusick_period(r),
        "c_t": ct, "c_rev": cr,
        "invariant": ct == cr,
    }
