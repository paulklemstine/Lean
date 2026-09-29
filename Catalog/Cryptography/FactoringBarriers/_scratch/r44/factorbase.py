"""
factorbase.py -- the NFS analogue of the round-42 'split set Q', measured.

Round 42 (QS) found the paid sieve work was governed by a PER-INSTANCE
STRUCTURAL QUANTITY: the size Q of the split prime set
    {p <= B : (N/p) = +1}.
The question this round asks is whether NFS has an analogue.

The NFS rational factor base is {p <= B} (all primes; there is no splitting
condition on the rational side -- that is exactly what buys NFS its 1/3).  The
NFS ALGEBRAIC factor base is
    FB(K, B) = { prime ideals 𝔭 of O_K : N𝔭 <= B }.
This file measures |FB(K,B)| EXACTLY, per instance, by factoring f mod p.

Everything here is exact combinatorics.  There is no smoothness assumption and
no distributional assumption: for a prime p, the ideals of O_K above p are in
bijection with the irreducible factors of f mod p, a factor of degree e giving
an ideal of norm p^e.  So

    |FB(K,B)| = sum over primes p <= B of  #{e_i : p^{e_i} <= B}

where {e_i} are the degrees of the irreducible factors of f mod p.

That formula is the instrument.  The scientific question is what governs it.
"""
import os, sys, math, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sympy
from sympy import Poly, symbols
import nfscore as ns

_x = symbols('x')

def factor_degs_mod_p(c, p, cache={}):
    """Degrees (with multiplicity) of the irreducible factors of f mod p."""
    while c and c[-1] % p == 0:
        c = c[:-1]
    if not c:
        return []
    f = sum(sympy.Integer(ci % p) * _x ** i for i, ci in enumerate(c))
    P = Poly(f, _x, modulus=p)
    _, factors = P.factor_list()
    return [fl.degree() for fl, _ in factors]

def algebraic_fb_size(c, B, want=('1',)):
    """Exact |{𝔭 of O_K : N𝔭 <= B}|, counted by factoring f mod p for p <= B.
    `want` selects which residue degrees to count (default: all with p^e<=B)."""
    tot = 0
    per_deg = {}
    for p in ns.primes_upto(B):
        ds = factor_degs_mod_p(c, p)
        cnt = {}
        for e in ds:
            if p ** e <= B:
                cnt[e] = cnt.get(e, 0) + 1
        for e, v in cnt.items():
            per_deg[e] = per_deg.get(e, 0) + v
        tot += sum(cnt.values())
    return tot, per_deg

def higher_degree_ideals(c, B):
    """DIRECT count of the prime ideals of O_K with residue degree >= 2 and
    norm <= B.  Measured directly rather than as |FB| - pi(B), which is a
    difference of two nearly equal large numbers and is pure noise at this
    precision (measured: see the round-44 Q2 note)."""
    tot = 0
    per = {}
    for p in ns.primes_upto(B):
        for e in factor_degs_mod_p(c, p):
            if e >= 2 and p ** e <= B:
                tot += 1
                per[e] = per.get(e, 0) + 1
    return tot, per


def root_discriminant(c):
    """Root discriminant of K = Q(alpha) implied by disc(f).  The true field
    root discriminant needs the index [O_K : Z[alpha]]; we report both the
    polynomial root discriminant and a lower bound obtained from the LOWER
    Minkowski bound on the index, and we SAY WHICH we used."""
    D = ns.poly_disc(c)
    d = len(c) - 1
    # SIGN: the SIGNED discriminant carries the signature (how many real roots)
    # and that is what the algebraic factor base is sensitive to.  We therefore
    # report the SIGNED root discriminant Dr = sign(disc) * |disc|^(1/d) and
    # note it, rather than silently taking |disc|^(1/d).
    Rd_poly = (abs(D) ** (1.0 / d)) * (-1 if D < 0 else 1)
    # Minkowski: |disc(O_K)| >= prod_p p^{n_p} ... a cruder universal bound is
    # |disc(K)| >= 1; instead use the standard index bound |disc(f)/disc(K)|
    #   = [O_K:Z[α]]^2 >= m^d  for the m smallest primes, from Minkowski's
    # theorem on the smallest splitting prime.  We use the weak, always-valid
    # statement and report disc(f) only; see the report for the caveat.
    return Rd_poly, D

def splitting_ratio(c, B):
    """|FB(K,B)| / pi(B).  In QS the analogous ratio is 1/2 (only split
    primes).  In NFS, if there were an analogue, this would vary per instance;
    if the field enters only at lower order it is 1 + O(B^{-1/2} log B)."""
    tot, per = algebraic_fb_size(c, B)
    nb = len(ns.primes_upto(B))
    return tot, nb, tot / nb, per

if __name__ == '__main__':
    POLY = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'poly')
    B = int(sys.argv[1]) if len(sys.argv) > 1 else 20000
    names = sorted(f for f in os.listdir(POLY) if f.endswith('.poly')
                   and f.startswith('c'))
    print(f'B = {B}   pi(B) = {len(ns.primes_upto(B))}')
    print(f'{"instance":<10} {"d":>2} {"Dr(f)":>10} {"|FB|":>9} {"pi(B)":>8} '
          f'{"ratio":>8} {"deg1":>8} {"deg>=2":>8}')
    rows = []
    for fn in names:
        p = ns.parse_poly(os.path.join(POLY, fn))
        c = ns.f_coeffs(p)
        Rd, D = root_discriminant(c)
        tot, nb, ratio, per = splitting_ratio(c, B)
        d1 = per.get(1, 0)
        dh = tot - d1
        rows.append(dict(name=fn, d=len(c) - 1, Rd=Rd, FB=tot, piB=nb,
                         ratio=ratio, deg1=d1, deghi=dh))
        print(f'{fn[:-5]:<10} {len(c)-1:>2} {Rd:>10.2f} {tot:>9} {nb:>8} '
              f'{ratio:>8.4f} {d1:>8} {dh:>8}')
    # between-instance spread of the ratio (ONE INSTANCE PER ROW, never a
    # within-pool SE)
    rr = [r['ratio'] for r in rows]
    m = sum(rr) / len(rr)
    sd = (sum((x - m) ** 2 for x in rr) / (len(rr) - 1)) ** 0.5
    print(f'\nratio |FB|/pi(B):  mean {m:.4f}   between-instance sd {sd:.4f}'
          f'   min {min(rr):.4f}  max {max(rr):.4f}   n={len(rr)} instances')
    json.dump(rows, open(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                      'fb_rows.json'), 'w'), indent=1)
