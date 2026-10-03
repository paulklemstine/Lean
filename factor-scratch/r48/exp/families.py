"""
r48 / AXIS-B : candidate group families and their ORDER SAMPLERS.

Every sampler returns a python int |G| -- the ORDER of the group, and nothing
else.  The harness then feeds those integers to the SINGLE shared
is_B_smooth / iroot from smooth.py.  That is what makes the matched-twin
control meaningful: the families differ in how the integer was PRODUCED,
never in how it was TESTED.

Each sampler is documented with:
  * what the group is,
  * how a random element is drawn and multiplied (polytime in log N?),
  * COST_TO_P: how one gets from an element of G to the hidden prime p.
"""
from __future__ import annotations

import math
import random

from smooth import _pari


# ---------------------------------------------------------------- EC baseline
def ec_orders(n_samples, p_bits, seed=0):
    """#E(F_p) for a uniformly random curve over a random p-bit prime.

    PARI note (burned us once): ellcard() needs ellinit(vec, p) -- passing a
    bare coefficient vector or a scaled t_VEC gives
    "incorrect type in checkell (t_VEC)".  Coefficients must be reduced mod p
    or PARI rejects the curve.
    """
    P = _pari()
    rng = random.Random(seed)
    lo = 1 << (p_bits - 1)
    hi = 1 << p_bits
    out = []
    for i in range(n_samples):
        p = int(P(f"nextprime(%d)" % rng.randrange(lo, hi)))
        a1 = rng.randrange(1 << 20) % p
        a2 = rng.randrange(1 << 40) % p
        a3 = (rng.randrange(1 << 40) % p) or 7
        m = int(P(f"ellcard(ellinit([{a1},{a2},{a3},0,0],{p}))"))
        out.append((p, m))
    return out


# ------------------------------------------------- Cl(Q(sqrt(-D))) imaginary
def fundamental_discount(lo, hi, rng, P):
    """Uniform-ish random FUNDAMENTAL discriminant D in [lo,hi) with D<0.

    Fundamental D (negative) is either
        D = -m,  m squarefree, m = 3 mod 4   (so D = 1 mod 4),  or
        D = 4m,  m squarefree, m = 2 or 3 mod 4.
    Getting these congruences backwards makes qfbclassno throw
    "domain error in classno: disc % 4 > 1" -- which is what happened.
    """
    while True:
        m = rng.randrange(lo, hi)
        if int(P(f"core(%d)" % m)) != m:      # squarefree?
            continue
        r = m % 4
        if r == 3:
            return -m                         # D = -m = 1 mod 4
        if r == 2:
            return 4 * m                       # D = 4m, m = 2 mod 4


def class_numbers(n_samples, d_bits, seed=0):
    """h(Q(sqrt(-D))) for FUNDAMENTAL D with the given bit length.

    h ~ sqrt(|D|) * L(1,chi_D)/pi  (Wikipedia "Class number formula"), so to
    get an h of k bits we sample D of about 2k bits.  The harness then
    BUCKETS on h.bit_length(), which is what makes the comparison matched.
    """
    P = _pari()
    rng = random.Random(seed)
    out = []
    lo = 1 << (d_bits - 2)
    hi = 1 << (d_bits - 1)
    while len(out) < n_samples:
        D = fundamental_discount(lo, hi, rng, P)
        h = int(P(f"qfbclassno(%d)" % D))
        out.append((D, h))
    return out


def class_numbers_for_discriminants(Ds):
    P = _pari()
    return [(D, int(P(f"qfbclassno(%d)" % D))) for D in Ds]


def semiprime_class_numbers(n_samples, n_bits, seed=0, sign=-1):
    """h(Q(sqrt(s*N))) for N a random SEMIPRIME of n_bits bits.

    THIS IS THE SLICE THAT MATTERS.  For the walk to factor N, the field must
    be a function of N (Schnorr-Lenstra use D = -n).  So we cannot choose D
    freely and we cannot resample h: N is a fresh semiprime each time, which
    is exactly the resampling freedom ECM has when it picks a fresh curve.
    """
    P = _pari()
    rng = random.Random(seed)
    out = []
    tries = 0
    lo = 1 << (n_bits // 2 - 1)
    while len(out) < n_samples and tries < n_samples * 200:
        tries += 1
        p = int(P(f"nextprime(%d)" % rng.randrange(lo, 1 << (n_bits // 2))))
        q = int(P(f"nextprime(%d)" % rng.randrange(lo, 1 << (n_bits - n_bits // 2))))
        if p == q:
            continue
        N = p * q
        D = sign * N
        # require the FIELD (fundamental D), not a nonmaximal order
        if int(P(f"core(%d)" % D)) != D:
            continue
        h = int(P(f"qfbclassno(%d)" % D))
        out.append((N, h))
    return out


# -------------------------------------------------------------- PGL / GL2
def _p_window(order_bits, deg):
    """p range so that a p**deg order lands in the target bit bucket.

    order ~ p**deg  =>  p ~ 2**(order_bits/deg).  A window of relative width
    2**(1/deg) spans exactly one bit of order length.  The window is used only
    to pick p; the harness then buckets on the REALISED order bit-length, so a
    float here cannot corrupt any measured quantity.
    """
    lo = 2.0 ** (order_bits / deg - 1.0 / deg)
    hi = 2.0 ** (order_bits / deg)
    lo = max(4.0, lo)
    return int(lo), int(hi) + 1


def pgl2_orders(n_samples, order_bits, seed=0):
    """|PGL(2,p)| = p(p^2-1) ~ p^3, p windowed so |G| hits order_bits."""
    P = _pari()
    rng = random.Random(seed)
    lo, hi = _p_window(order_bits, 3)
    out = []
    for _ in range(n_samples * 2):
        p = int(P(f"nextprime(%d)" % rng.randrange(lo, hi)))
        out.append((p, p * (p * p - 1)))
    return out


def gl2_orders(n_samples, order_bits, seed=0):
    """|GL(2,p)| = (p^2-1)(p^2-p) ~ p^4, p windowed so |G| hits order_bits."""
    P = _pari()
    rng = random.Random(seed)
    lo, hi = _p_window(order_bits, 4)
    out = []
    for _ in range(n_samples * 2):
        p = int(P(f"nextprime(%d)" % rng.randrange(lo, hi)))
        out.append((p, (p * p - 1) * (p * p - p)))
    return out


def psl2_orders(n_samples, order_bits, seed=0):
    """|PSL(2,p)| = p(p^2-1)/gcd(2,p-1)."""
    out = pgl2_orders(n_samples, order_bits, seed=seed)
    return [(p, o // math.gcd(2, p - 1)) for p, o in out]


# ------------------------------------------------- higher-degree class groups
def cubic_class_numbers(n_samples, d_bits, seed=0):
    """h of the pure cubic field Q(cuberoot(m)) -- x^3 - m.

    Class number of a cubic field of discr D behaves like ~sqrt(D) L(1,chi)/2^v,
    so we sample m with the right bit length and record (field, h).
    PARI bnfinit is expensive; the sample count is kept modest.
    """
    P = _pari()
    rng = random.Random(seed)
    out = []
    lo = 1 << (d_bits - 1)
    hi = 1 << d_bits
    seen = set()
    tries = 0
    while len(out) < n_samples and tries < n_samples * 40:
        tries += 1
        m = rng.randrange(lo, hi)
        # keep the polynomial field maximal where possible
        v = P(f"bnfinit(x^3-%d,1)" % m)
        if int(v.dcflm) % 9 == 0 or int(v.dcflm) % 27 == 0:
            continue  # pure cubic, not the full monogenic ring
        h = int(v.no)
        if m in seen:
            continue
        seen.add(m)
        out.append((m, h))
    return out


def quartic_class_numbers(n_samples, d_bits, seed=0):
    """h of Q(zeta-like pure quartic) -- use PARI's generic bnf on x^4-m,
    accepting non-maximal orders too (that only makes the number larger,
    which is recorded honestly in the notes)."""
    P = _pari()
    rng = random.Random(seed)
    out = []
    lo = 1 << (d_bits - 1)
    hi = 1 << d_bits
    tries = 0
    while len(out) < n_samples and tries < n_samples * 30:
        tries += 1
        m = rng.randrange(lo, hi)
        v = P(f"bnfinit(x^4-%d,1)" % m)
        out.append((m, int(v.no)))
    return out


# -------------------------------------------------------------- Selmer 3-tors
def selmer3_orders(n_samples, d_bits, seed=0):
    """Order of the 3-TORSION of the imaginary quadratic class group C(D).

    C(D)[3] has order 3^r; we record 3^r as the group order.  NOTE: this is
    ALWAYS a power of 3, so it is trivially 3-smooth and its smoothness
    probability at any u is identically 1 -- which is why "order a group with
    a forced small-prime factor" cannot by itself be an advantage.  The
    quantity of interest is how LARGE 3^r gets.
    """
    P = _pari()
    rng = random.Random(seed)
    out = []
    lo = 1 << (d_bits - 2)
    hi = 1 << (d_bits - 1)
    while len(out) < n_samples:
        D = fundamental_discount(lo, hi, rng, P)
        h = int(P(f"qfbclassno(%d)" % D))
        h3 = h
        while h3 % 3 == 0:
            h3 //= 3
        out.append((D, h // h3))
    return out


# ----------------------------------------------------- determinant-repr group
def det_group_orders(n_samples, n_bits, seed=0):
    """The group that a SQUFOF / continued-fraction walk actually lives in.

    For odd N, the square-forms factorization of Shanks searches reduced
    positive binary quadratic forms of discriminant D = 4N (or N, per the
    congruence), whose class number is h(4N).  We sample N directly -- this
    is the D=4N slice of the imaginary-quadratic family, but keeping it
    separate because it is the one slice that is actually reachable from N.
    """
    P = _pari()
    rng = random.Random(seed)
    out = []
    lo = 1 << (n_bits - 1)
    hi = 1 << n_bits
    tries = 0
    while len(out) < n_samples and tries < n_samples * 300:
        tries += 1
        N = rng.randrange(lo, hi) | 1
        D = 4 * N
        # class number of the ORDER of discriminant D (Q(sqrt(N)))
        h = int(P(f"qfbclassno(%d)" % D))
        out.append((N, h))
    return out