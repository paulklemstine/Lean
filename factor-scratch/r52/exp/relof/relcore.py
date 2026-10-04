#!/usr/bin/env python3
"""
relcore.py -- NFS relation-finding: measurement + exact nulls.
NO Dickman anywhere as a null. Exact Psi by Buchstab recursion. Exact integer roots.
"""
import math, time, sys
sys.setrecursionlimit(100000)
from sympy import prevprime as _prevprime, integer_nthroot, primerange, isprime
import functools

# ------------------------------------------------------------------ exact Psi
def psi_exact(x, B, _mem=None):
    """EXACT #B-smooth integers in [1,x].  psi(x,B)=psi(x,B-)+psi(x//B,B).
    NO Dickman, NO asymptotics."""
    if x < 1: return 0
    if B < 2: return 1
    if B >= x: return int(x)          # every integer <= x is B-smooth
    if _mem is None: _mem = {}
    key = (x, B); r = _mem.get(key)
    if r is not None: return r
    # BUG CAUGHT BY SELFTEST: psi(x,B)=psi(x,B-)+psi(x//B,B) is ONLY valid for
    # PRIME B.  For composite B it double counts: 10-smooth == 7-smooth (both are
    # {2,3,5,7}) but the recursion returned 46 + psi(10,10)=46+10 = 56.
    # Reduce composite B to its predecessor prime first.
    if not isprime(B):
        r = psi_exact(x, int(_prevprime(B)), _mem)
        _mem[key] = r
        return r
    Bm = int(_prevprime(B)) if B > 2 else 1
    if Bm < 2:
        r = int(math.log(x, 2)) + 1
    else:
        r = psi_exact(x, Bm, _mem) + psi_exact(x // B, B, _mem)
    _mem[key] = r
    return r

def psi_ratio(x, B):
    """EXACT B-smooth density Psi(x,B)/x."""
    return psi_exact(x, B) / float(x)

# ------------------------------------------------- the Q2 lemma (EXACT, k>=1)
# #{(a,b) in [0,p^k)^2 : p^k | a^2 - b^3} / p^k  ==  2 - 1/p   (all odd p, all k>=1)
# DECOMPOSITION, proved algebraically:
#   (i)  b with p _|_ b : #a solutions = 1 + legendre(b^3 mod p) = 1 + (b|p),
#        in {0,2}.  Summing over the (p-1)*p^(k-1) units b, exactly half are QR,
#        so SUM = 2 * (p-1)p^(k-1)/2 = (p-1)p^(k-1) = #units.
#        ==> on the p_nmid_b stratum the rate is EXACTLY uniform, 1/p^k.
#   (ii) ALL the excess sits on p | b.
def solcount_a2b3(p, k):
    """(total, nb_pdivb, nb_unit, c0, c1) -- exact, by enumeration mod p^k."""
    m = p ** k
    nb0 = nb1 = c0 = 0
    for b in range(m):
        t = pow(b, 3, m)
        c = sum(1 for a in range(m) if (a * a - t) % m == 0)
        if b % p == 0: nb0 += c; c0 += 1
        else:          nb1 += c
    c1 = m - c0
    return nb0 + nb1, nb0, nb1, c0, c1

# ------------------------------------------------------------------- NFS form
def mont_form(N, d=None, a=None):
    """Montgomery quadratic: N = d^2 + k -> f(x,y) = (d x + y)^2 + k.
    Returns (d,k). Chooses d = ceil(sqrt(N)) by default."""
    if d is None:
        d = integer_nthroot(N, 2)[0] + 1
    return d, N - d * d

def nfs_values(d, k, x, y):
    """F(x,y) = (d x + y)^2 + k  -- the Montgomery relation value."""
    return (d * x + y) ** 2 + k

# --------------------------------------------------------------- sieve+collect
def sieve_and_collect(N, BB, xlo=0, xhi=None, ylo=0, yhi=None, do_sieve=True,
                      collect=True, d=None, k=None, counter=None):
    """Sieve the (x,y) box for BB-smooth Montgomery values F=(d x+y)^2+k.
    COUNTS OPERATIONS.  Returns (n_relations, stats)."""
    if d is None: d, k = mont_form(N)
    if xhi is None: xhi = d
    if yhi is None: yhi = d
    fb = list(primerange(2, BB + 1))
    st = dict(cells=0, sieve_marks=0, trial_divs=0, smooth=0, pairs=0, fb=len(fb))
    rels = []
    if not do_sieve:
        for x in range(xlo, xhi):
            for y in range(ylo, yhi):
                st['cells'] += 1
                v = nfs_values(d, k, x, y)
                r, ex = _trial(v, fb)
                st['trial_divs'] += r
                if ex:
                    st['smooth'] += 1; rels.append((x, y, v, ex))
        return rels, st
    # sieve: for each p in FB with roots, mark cells
    for p in fb:
        t = (-k) % p
        r = math.isqrt(t)
        roots = []
        if (r * r) % p == t: roots.append(r)
        if p > 2:
            r2 = p - r
            if (r2 * r2) % p == t and r2 not in roots: roots.append(r2)
        for R in roots:
            # d x + y = R  =>  y = R - d x
            x = xlo
            y = (R - d * x) % p
            while y < yhi:
                if y >= ylo: st['sieve_marks'] += 1
                y += p
            # this is the un-hoisted form; the loop below does the real marking
    # real marking, iterating x and stepping the arithmetic progression in y
    for p in fb:
        t = (-k) % p
        r = math.isqrt(t); roots = []
        if (r*r) % p == t: roots.append(r)
        if p > 2:
            r2 = p - r
            if (r2*r2) % p == t and r2 != r: roots.append(r2)
        for R in roots:
            for x in range(xlo, xhi):
                y = (R - d * x) % p
                y0 = ylo + ((y - ylo) % p) if yhi > ylo else y
                # count marks in [ylo, yhi)
                st['sieve_marks'] += max(0, (yhi - y0 + p - 1)//p)
    st['cells'] = (xhi-xlo)*(yhi-ylo)
    if not collect: return rels, st
    for x in range(xlo, xhi):
        for y in range(ylo, yhi):
            v = nfs_values(d, k, x, y)
            rr, ex = _trial(v, fb)
            st['trial_divs'] += rr
            if ex:
                st['smooth'] += 1; rels.append((x, y, v, ex))
    return rels, st

def _trial(v, fb):
    """Trial-divide v by every FB prime. Returns (#primes tried, exponent vector or None).
    Counts one 'trial division' per prime attempted -- the standard NFS cost model."""
    tried = 0; ex = []
    for i, p in enumerate(fb):
        tried += 1
        if v % p == 0:
            e = 0
            while v % p == 0: v //= p; e += 1
            ex.append(e)
        if v == 1:
            break
    return tried, (ex if v == 1 else None)
