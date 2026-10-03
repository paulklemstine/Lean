"""
core.py -- correct NFS relation measurement for the polynomial-selection axis (EE).

WHY THIS FILE EXISTS AT ALL
---------------------------
The round-48 C3 table ("largest coefficient mass -> most relations") was produced
by `r48/exp/find_relations`.  That counter is wrong in a way that is decisive for
this axis, and the bug is in the sieve, not in the arithmetic:

    `f_coeffs_of` returns coefficients LEADING-first, `fc = [c_d,...,c_0]`.
    `find_relations` builds   norm(a,b) = sum_i fc[i] * a^(d-i) * b^i,
    which equals b^d * h(a/b) for  h(x) = sum_i fc[i] * x^i.
    But `split_primes` looks for roots of exactly h, while the value being
    sieved is built from the REVERSED polynomial.  So the mask selects
    a = beta*b (mod p) for roots beta of h, which is precisely the set of
    cells where p does NOT divide norm(a,b).

Concretely (measured, `selftest.py` S6): for p=7 the returned root is 2, and
h(2) = -1334 = 3 (mod 7) != 0, so no masked cell has 7 | norm.  The sieve is
inverted.  `find_relations` therefore reports 8.9e-4 "relations" where the true
y-smooth rate over the same cells is 1.61e-2 -- an under-count of 13x, and the
surviving subset is defined by the wrong polynomial's splitting primes, so any
correlation with the coefficients is a correlation with the wrong object.

Everything below is measured with the CORRECT object:

    f is monic of degree d with f(m) = N exactly (so m is a root of f mod N,
    which is what makes the polynomial a usable NFS polynomial);
    the sieved algebraic integer is a - b*theta with theta a root of f;
    p | N(a - b*theta)  <=>  a = b*beta (mod p) for a root beta of f mod p;
    a cell is a relation iff |f(a,b)| is y-smooth, decided by EXACT trial
    division over every prime <= y (no float, no log accumulation, no sieve
    pruning, no early exit, no degenerate cells skipped).
"""
from __future__ import annotations

import math
import random
from bisect import bisect_left, bisect_right

import numpy as np

# ---------------------------------------------------------------------------
# primes
# ---------------------------------------------------------------------------

_PRIME_CACHE: dict[int, list[int]] = {}


def primes_upto(n: int) -> list[int]:
    """All primes <= n.  Cached; the sieve of Eratosthenes, exact."""
    if n <= 2:
        return []
    got = _PRIME_CACHE.get(n)
    if got is not None:
        return got
    base = _PRIME_CACHE.get(0)
    if base is None:
        base = [2]
    sieve = bytearray([1]) * (n + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i::i] = bytearray(len(sieve[i * i::i]))
    out = [i for i in range(2, n + 1) if sieve[i]]
    _PRIME_CACHE[0] = out
    return out


# ---------------------------------------------------------------------------
# NFS polynomial family
# ---------------------------------------------------------------------------
#
# f(x) = x^d + sum_{i<d} c_i x^i   with   sum_{i<d} c_i m^i = N - m^d.
#
# Taking the c_i to be the base-m digits of N - m^d gives 0 <= c_i < m, is
# defined for EVERY m with m^d < N (not only m with (N/2)^(1/d) <= m), and
# gives f(m) = N exactly, hence m is a root of f mod N.
#
# A second family holds m FIXED and moves the coefficients off the digit
# lattice: for any (j, c2) the triple
#     c0 = R + j*m,  c2 = c2,  c1 = (R - c0 - c2*m^2)//m,   R = N - m^d
# still satisfies sum c_i m^i = R.  This is what breaks the mass/m confound
# that the round-48 table could not break.


def poly_from_m(N: int, m: int, d: int) -> list[int]:
    """Coefficients ASCENDING (c[0] = constant, c[d] = 1).  f(m) = N exactly."""
    if m ** d >= N:
        raise ValueError("need m^d < N")
    R = N - m ** d
    c = [0] * (d + 1)
    c[d] = 1
    rest = R
    for i in range(d):
        c[i] = rest % m
        rest //= m
    if rest:
        raise ValueError("R does not fit in d base-m digits")
    return c


def poly_offset(N: int, m: int, d: int, j: int = 0, dc2: int = 0) -> list[int]:
    """Same f(m)=N constraint, same m, coefficients moved OFF the digit lattice.

    (j, dc2) = (0, 0) reproduces poly_from_m exactly.  Moving c0 by j*m and c2
    by dc2, compensated in c1, keeps sum_i c_i m^i = N - m^d.

    NOTE: the first version took c0 = R + j*m with R = N - m^d.  Since
    R = N - m^3 is up to 3m^2 for m = floor(N^(1/3)), that can never reach the
    digit polynomial's c0 = R mod m, so the family could not be centred on the
    standard choice at all -- it only ever produced huge coefficients.  This is
    the second version and j=0 IS the digit polynomial.
    """
    R = N - m ** d
    if d != 3:
        raise ValueError("offset family defined for d == 3")
    dig = poly_from_m(N, m, d)
    c0 = dig[0] + j * m
    c2 = dig[2] + dc2
    c1 = dig[1] - j - dc2 * m
    return [c0, c1, c2, 1]


def mass(c: list[int]) -> int:
    """Round-48's 'coefficient mass': sum |c_i| over i < d, leading 1 excluded."""
    return sum(abs(v) for v in c[:-1])


def mass_full(c: list[int]) -> int:
    return sum(abs(v) for v in c)


def eval_poly(c: list[int], x: int) -> int:
    """c ascending; Horner from the leading end."""
    acc = 0
    for v in reversed(c):
        acc = acc * x + v
    return acc


def f_at_m(c: list[int], m: int) -> int:
    return eval_poly(c, m)


def is_irreducible_cubic(c: list[int]) -> bool:
    """A cubic over Q is reducible iff it has a rational root.  Exact.

    The first version enumerated divisors of c[0] by trial division to
    sqrt(c[0]); with c[0] ~ 10^13 that is ~3e6 Python iterations per call and
    the S7 search (400 calls) never finished.  factorint is exact and instant.
    """
    from sympy import factorint
    a0, a1, a2 = c[0], c[1], c[2]
    if a0 == 0:
        return False
    fac = factorint(abs(a0))
    divs = [1]
    for p, e in fac.items():
        divs = [d * p ** k for d in divs for k in range(e + 1)]
    for p in divs:
        for s in (1, -1):
            if a2 * s * p ** 2 + a1 * s * p + a0 == 0:
                return False
    return True


def roots_mod(c: list[int], p: int) -> list[int]:
    """All roots of c in F_p, by direct enumeration (p <= ~5000 only)."""
    out = []
    for r in range(p):
        if eval_poly(c, r) % p == 0:
            out.append(r)
    return out


# ---------------------------------------------------------------------------
# the box
# ---------------------------------------------------------------------------


def sample_box(m: int, eta: float, n_cells: int, seed: int):
    """n_cells uniform random (a,b) from [-B,B]^2 with B = floor(eta*m).

    Uniform sampling of the SAME cells for every polynomial is what makes the
    comparison paired; an unpaired comparison of two independent boxes has a
    noise floor sqrt(2/N) on a rate of ~1e-3 and would need ~10^7 cells per
    configuration to see a factor-2 effect.
    """
    B = max(2, int(eta * m))
    rng = random.Random(seed)
    a = np.fromiter((rng.randint(-B, B) for _ in range(n_cells)), dtype=np.int64,
                    count=n_cells)
    b = np.fromiter((rng.randint(-B, B) for _ in range(n_cells)), dtype=np.int64,
                    count=n_cells)
    return a, b, B


# ---------------------------------------------------------------------------
# norms
# ---------------------------------------------------------------------------


def _norm_int64(c: list[int], a: np.ndarray, b: np.ndarray) -> np.ndarray:
    d = len(c) - 1
    out = np.zeros(a.shape, dtype=np.int64)
    am1 = a.astype(np.int64)
    bm1 = b.astype(np.int64)
    for i, ci in enumerate(c):
        if ci == 0:
            continue
        out += ci * (am1 ** (d - i)) * (bm1 ** i)
    return out


def _norm_object(c: list[int], a: np.ndarray, b: np.ndarray) -> np.ndarray:
    d = len(c) - 1
    co = [int(v) for v in c]
    aa = a.tolist()
    bb = b.tolist()
    vals = []
    for ai, bi in zip(aa, bb):
        acc = 0
        for i in range(d + 1):
            acc += co[i] * (ai ** (d - i)) * (bi ** i)
        vals.append(acc)
    return np.array(vals, dtype=object)


def norm_values(c: list[int], a: np.ndarray, b: np.ndarray):
    """Exact N(a - b*theta).  int64 when it provably fits, else Python ints."""
    d = len(c) - 1
    hi = max(int(np.abs(a).max()), int(np.abs(b).max()))
    bound = mass_full(c) * (hi ** d)
    if bound < (1 << 62):
        return _norm_int64(c, a, b)
    return _norm_object(c, a, b)


def fits_int64(c: list[int], a: np.ndarray, b: np.ndarray) -> bool:
    d = len(c) - 1
    hi = max(int(np.abs(a).max()), int(np.abs(b).max()))
    return mass_full(c) * (hi ** d) < (1 << 62)


# ---------------------------------------------------------------------------
# the relation counter  (exact, no sieve, no pruning)
# ---------------------------------------------------------------------------


def count_relations(c: list[int], a: np.ndarray, b: np.ndarray, y: int,
                    return_norms: bool = False):
    """Exact count of y-smooth cells among the supplied (a,b).

    EXACT trial division by every prime <= y, applied to EVERY cell -- no early
    exit, no log accumulation, no cells dropped for being degenerate.  The
    only cells excluded are those with f(a,b) == 0 (the algebraic integer is
    zero, which is not a relation); the count of those is returned too so the
    caller can see it rather than have it silently removed.
    """
    nv = norm_values(c, a, b)
    pl = primes_upto(y)
    if nv.dtype == object:
        rem = [abs(int(v)) for v in nv]
    else:
        rem = np.abs(nv).astype(np.int64)
    zero = np.array([int(v) == 0 for v in nv]) if nv.dtype == object else (nv == 0)
    n_zero = int(zero.sum())
    if nv.dtype != object:
        # The zero cells MUST be masked out of the division passes.  They were
        # not, and `0 % p == 0` is true forever, so the `while` loop never
        # broke: the first self-test run hung for 10 minutes on the single
        # degenerate cell (a,b)=(0,0).  This is precisely the degenerate-case
        # class that voided two earlier measurements in this program.
        active = ~zero
        for p in pl:
            if p == 1:
                continue
            while True:
                m = active & (rem % p == 0)
                if not m.any():
                    break
                rem[m] //= p
        smooth = (rem == 1) & (~zero)
    else:
        smooth = np.zeros(len(rem), dtype=bool)
        for i, v in enumerate(rem):
            if v == 0:
                continue
            r = v
            for p in pl:
                while r % p == 0:
                    r //= p
            if r == 1:
                smooth[i] = True
    n_smooth = int(smooth.sum())
    out = {"n_smooth": n_smooth, "n_cells": int(len(a)), "n_zero": n_zero,
           "y": y, "c": list(c), "mass": mass(c), "mass_full": mass_full(c)}
    if return_norms:
        out["norms"] = nv
        out["smooth"] = smooth
    return out


# ---------------------------------------------------------------------------
# the explanatory variable
# ---------------------------------------------------------------------------


def log_abs_norms(c: list[int], a: np.ndarray, b: np.ndarray) -> np.ndarray:
    nv = norm_values(c, a, b)
    if nv.dtype == object:
        return np.array([math.log(abs(int(v))) if v != 0 else float("-inf")
                         for v in nv], dtype=np.float64)
    out = np.full(nv.shape, -np.inf)
    nz = nv != 0
    out[nz] = np.log(np.abs(nv[nz].astype(np.float64)))
    return out


def mean_log_norm(c, a, b) -> float:
    """log of the geometric mean of |f(a,b)| over the box.

    This is the quantity the relation rate must actually depend on: a cell is
    a relation iff |f(a,b)| is y-smooth, and the smooth rate of an integer of
    size X is Psi(X,y)/X, which decreases in X.  So the rate of a polynomial
    is a DECREASING function of this number, through the smooth numbers, and
    coefficient mass enters only insofar as it moves it.
    """
    l = log_abs_norms(c, a, b)
    l = l[np.isfinite(l)]
    if l.size == 0:
        return float("nan")
    return float(l.mean())


def geom_mean_abs_norm(c, a, b) -> float:
    return math.exp(mean_log_norm(c, a, b))


# ---------------------------------------------------------------------------
# smoothness null
# ---------------------------------------------------------------------------


def smooth_rate_random_uniform(bits: int, y: int, trials: int, seed: int) -> float:
    """Empirical y-smooth rate of a uniform random integer of `bits` bits.

    This is the matched-scale null for the algebraic side.  Measured here, not
    quoted: the multiplicative gap between Psi and rho at u ~ 3-5 is one of the
    numbers this axis needs and it is not something to recall from a table.
    """
    rng = random.Random(seed)
    pl = primes_upto(y)
    hit = 0
    for _ in range(trials):
        v = rng.getrandbits(bits) | (1 << (bits - 1))
        for p in pl:
            while v % p == 0:
                v //= p
        if v == 1:
            hit += 1
    return hit / trials