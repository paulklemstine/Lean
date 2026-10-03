"""
C1: lattice reduction past LLL, measured on the ACTUAL NFS relation lattice.

Pipeline: pick N, build a GNFS polynomial f of degree d, sieve a box of (a,b)
pairs for smooth relations, assemble Montgomery's relation lattice, then reduce
it with LLL and with our BKZ at several block sizes.

Everything reported here is produced by this file on this host.
"""
import math
import numpy as np
from sympy import Poly, Symbol, factor_list
from sympy.abc import x as _sx

from lll_self_test import lll_reduce, bkz_reduce, is_lll_reduced

X = Symbol('X')


# ---------------------------------------------------------------- polynomial

def optimal_m(N, d):
    """m with m^d < N <= (m+1)^d, as close to N^(1/d) as integers allow."""
    m = int(round(N ** (1.0 / d)))
    while m ** d >= N:
        m -= 1
    while (m + 1) ** d < N:
        m += 1
    return m


def base_m_from(N, m):
    """c_0 = N mod m, c_i random-ish but fixed by a seeded rule."""
    return N % m


def base_m_digits(N, m, d):
    """Base-m digits n_0..n_d of N with m as the base; n_d must be 1."""
    n = N
    digs = []
    for _ in range(d + 1):
        digs.append(n % m)
        n //= m
    return digs


def make_poly(N, d, m):
    """f(x) = x^d - sum_{i<d} n_i x^i with N = f(m) exactly.

    Writing N in base m guarantees f(m) = N, so m is an exact root of f mod N
    and the coefficients are the base-m digits -- automatically < m, which is
    the condition that makes an NFS polynomial usable.  The naive choice
    c_0 = N mod m with arbitrary other coefficients produces degenerate
    polynomials (measured: c_0 = 1, c_1 ~ 2.1e19).
    """
    digs = base_m_digits(N, m, d)
    assert digs[d] == 1, 'm is too small: base-m expansion needs d+1 digits'
    coeffs = [0] * (d + 1)
    coeffs[0] = 1                      # coeffs[i] multiplies X^(d-i)
    for i in range(d):
        coeffs[d - i] = -digs[i]       # -n_i multiplies x^i
    return Poly(sum(coeffs[i] * X ** (d - i) for i in range(d + 1)), X)


def poly_cost(f_coeffs):
    """A crude quality score: the sum of |coefficients| (excluding the
    leading 1).  Smaller is better for the lattice conditioning."""
    return sum(abs(c) for c in f_coeffs[:-1])


def best_m(N, d, rel_span=0.06):
    """Search m near N^(1/d) for the polynomial with the smallest coefficient
    mass.  A WIDE search: restricting m to a few units around N^(1/d) gave
    mass ~4.3e5 and no smooth relations at all; the mass is what decides
    whether the sieving produces anything."""
    best = None
    centre = N ** (1.0 / d)
    span = max(64, int(centre * rel_span))
    lo = max(2, int(centre) - span)
    hi = int(centre) + span + 1
    for m in range(lo, hi):
        digs = base_m_digits(N, m, d)
        if digs[d] != 1:
            continue
        cost = sum(abs(x) for x in digs[:d])
        if best is None or cost < best[0]:
            best = (cost, m, digs)
    return best


def poly_is_irreducible_over_Z(P):
    """True iff f is irreducible over Q (no rational factor)."""
    _, factors = factor_list(P.as_expr(), X)
    return len(factors) == 1 and factors[0][1] == 1


# ---------------------------------------------------------------- sieving

def split_primes(f_coeffs, ymax):
    """Primes p <= ymax for which f has a root mod p (p splits in Q(theta)),
    mapped to the LIST OF ALL ROOTS.  All roots are needed: the sieve condition
    is a = b*alpha (mod p) for SOME root, and using one root under-selects."""
    sieve = np.ones(ymax + 1, dtype=bool)
    sieve[:2] = False
    for i in range(2, int(ymax ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i::i] = False
    out = {}
    for p in range(2, ymax + 1):
        if not sieve[p]:
            continue
        roots = []
        for r in range(p):
            v, x = 0, 1
            for c in f_coeffs:
                v = (v + c * x) % p
                x = (x * r) % p
            if v == 0:
                roots.append(r)
        if roots:
            out[p] = roots
    return out


def norm_of(a, b, f_coeffs):
    """N(a - b*theta) = prod_i (a - b theta_i) = b^d f(a/b), an integer."""
    d = len(f_coeffs) - 1
    tot = 0
    for i, c in enumerate(f_coeffs):
        tot += c * (a ** (d - i)) * (b ** i)
    return tot


def relation_exponents(norm, primes):
    """Trial-divide norm by the splitting primes.  Returns exponents dict and
    the leftover cofactor (must be 1 for a y-smooth relation)."""
    e = {}
    r = norm
    for p in sorted(primes):
        while r % p == 0:
            e[p] = e.get(p, 0) + 1
            r //= p
    return e, r


# ---------------------------------------------------------------- lattice

def montgomery_lattice(relations, f_coeffs, N, d, m):
    """Montgomery relation lattice.

    For a relation  a_i - b_i*theta = prod_p p^{e_ip}  (as an ideal) we form
        G_i(x) = prod_p (x - alpha_p)^{e_ip} - N * F(x)^{k_i}
    where alpha_p is a root of f mod p and F is the integer polynomial with
    F = f mod m, deg < d.  The coefficients of G_i are divisible by m; we
    divide by m and use the d+1 coefficient vector as a lattice row.
    """
    rows = []
    F = f_coeffs[:]                      # f itself is congruent to F mod m
    for (a, b, exps) in relations:
        # build prod (x - alpha_p)^{e_p} mod the degree bound
        poly = [1]
        for p, e in sorted(exps.items()):
            ap = split_primes(f_coeffs, p + 1)[p]
            for _ in range(e):
                # multiply poly by (x - ap)
                new = [0] * (len(poly) + 1)
                for i, c in enumerate(poly):
                    new[i + 1] += c
                    new[i] -= c * ap
                poly = new
        # reduce mod f (so that we stay in degree < d after the reduction)
        poly = reduce_mod_f(poly, f_coeffs, d)
        # choose k so degrees match: we need prod part degree == deg(N*F^k)
        # Montgomery: subtract N*F(x)^k with k = floor(deg(prod)/d)
        k = (len(poly) - 1) // d
        term = poly_pow(F, k)
        term = [N * c for c in term]
        G = [0] * max(len(poly), len(term))
        for i, c in enumerate(poly):
            G[i] = G[i] + c
        for i, c in enumerate(term):
            G[i] = G[i] - c
        G = [int(c) for c in G]
        if any(c % m for c in G):
            return None                  # relation not usable as constructed
        rows.append([c // m for c in G[:d + 1]])
    return np.array(rows, dtype=float)


def reduce_mod_f(poly, f_coeffs, d):
    """Reduce a polynomial (low-to-high coeffs) modulo the monic f."""
    p = list(poly)
    dd = len(f_coeffs) - 1
    while len(p) - 1 >= dd:
        lead = p[-1]
        if lead:
            for i in range(dd + 1):
                p[len(p) - dd - 1 + i] -= lead * f_coeffs[i]
        p = p[:-1]
    return p


def poly_pow(c, k):
    """c(x)^k for low-to-high coefficient list c, exact integer coefficients."""
    res = [1]
    for _ in range(k):
        new = [0] * (len(res) + len(c) - 1)
        for i, x in enumerate(res):
            for j, y in enumerate(c):
                new[i + j] += x * y
        res = new
    return res
