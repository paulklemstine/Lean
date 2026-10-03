"""Leakage models for the partial-information factoring axis.

Each model returns, for an RSA instance (p, q, N) and a "leak budget" in
bits of p, a polynomial f with f(x0) = 0 mod (a divisor of N) at the
unknown x0 = p - a, plus the bound X on x0.  A model that cannot represent
the budget returns None -- and saying so is a result, not a failure.
"""
from control import make_instance


# --------------------------------------------------------------- T1: MSB leak
def leak_top_bits(N_inst, nbits_leaked):
    """Known top bits of p.  p = a + x0 with 0 <= x0 < 2^(nb(p)-nbits_leaked)."""
    p, q, N = N_inst
    nb = p.bit_length()
    unk = nb - nbits_leaked
    if unk <= 0:
        return None
    a = (p >> unk) << unk
    assert 0 <= p - a < (1 << unk)
    return dict(f=[a, 1], X=1 << unk, unknown=unk, kind="msb",
                desc="top %d bits of p known" % nbits_leaked)


# --------------------------------------------------------- T1: LSB leak
def leak_low_bits(N_inst, nbits_leaked):
    """Known low bits of p: p = a + 2^t * x0 is not linear in x0 in the
    useful sense, so the natural polynomial is f(x) = a + 2^t x with x0 the
    unknown HIGH part.  Handled by rescaling: x0 = (p - a)/2^t."""
    p, q, N = N_inst
    if nbits_leaked >= p.bit_length():
        return None
    a = p & ((1 << nbits_leaked) - 1)          # known low bits
    t = nbits_leaked
    return dict(f=[a, 1 << t], X=1 << (p.bit_length() - t), kind="lsb",
                # x0 = (p - a) >> t is the unknown high part, and
                # f(x0) = a + 2^t x0 = p  ->  a factor of N
                shift=t, unknown=p.bit_length() - t,
                desc="low %d bits of p known" % nbits_leaked)


# --------------------------------------------------- T1: p bits mod small q
def leak_mod_prime(N_inst, ell, nbits_leaked):
    """p mod ell known (a few bits of p determined by a residue mod a small
    prime).  This leaks k bits of p but as a residue class, so the unknowns
    are still contiguous in effect: p = a + ell * x0."""
    p, q, N = N_inst
    a = p % ell
    x0 = (p - a) // ell
    return dict(f=[a, ell], X=1 << (p.bit_length() - a.bit_length() + 1),
                kind="mod_small_prime", ell=ell, unknown=x0.bit_length(),
                desc="p mod %d known (ell=%d)" % (ell, ell))


# ------------------------------------------------------- T1: p - q known
def leak_p_minus_q(N_inst, nbits_leaked):
    """Known p - q.  Then p and q are symmetric around N's sqrt: with
    d = p - q known, p = (sqrt(d^2 + 4N) + d)/2 -- an exact recovery, not a
    lattice problem.  Kept as a control on what "structured" can mean."""
    p, q, N = N_inst
    if p < q:
        p, q = q, p
    dd = p - q
    rec = (isqrt(dd * dd + 4 * N) + dd) // 2
    return dict(kind="pq_diff", closed_form=rec, recovered=(rec == p),
                desc="p-q known (closed form, not a lattice attack)")


def isqrt(n):
    import math
    return math.isqrt(n)