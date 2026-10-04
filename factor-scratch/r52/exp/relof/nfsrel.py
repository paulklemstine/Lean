#!/usr/bin/env python3
"""
nfsrel.py -- real cubic Montgomery NFS relation finder + yield measurement.
N = d^3 + c,  F(x,y) = (d x + y)^3 + c,   F(1,0) = N.
Sieve a box by FB primes (cube roots of -c mod p), trial-divide survivors,
collect FB-smooth values as relations.  Counts ops AND wall clock.
NO Dickman as a null: the null is EXACT Psi.
"""
import math, time, sys
import numpy as np
from sympy import integer_nthroot, primerange

def mont_cubic(N):
    d = integer_nthroot(N, 3)[0] + 1
    c = N - d ** 3
    return d, c

def cube_roots_mod(p, a):
    """roots of X^3 = a mod p, p prime. Returns list."""
    a %= p
    if a == 0: return [0]
    if p == 2: return [1]
    if p % 3 == 1:
        # x^3 map is a bijection iff gcd(3,p-1)=1 i.e. p=2 mod 3
        pass
    # brute over p is fine only for small p; use sympy for correctness
    from sympy import solve, Poly, symbols, I, S
    xs = [x for x in range(p) if pow(x, 3, p) == a]
    return xs

def sieve_collect(N, BB, X, Y, x0=1, y0=0, collect=True, d=None, c=None):
    """Returns dict with counts + wall clock + list of relations (optional)."""
    if d is None: d, c = mont_cubic(N)
    fb = list(primerange(2, BB + 1))
    npr = len(fb)
    cells = (X - x0) * (Y - y0)
    t0 = time.perf_counter()
    surv = np.ones((X - x0, Y - y0), dtype=bool)
    sieve_marks = 0
    for p in fb:
        roots = cube_roots_mod(p, (-c) % p)
        if not roots:
            continue
        for r in roots:
            step = p
            NX = X - x0
            # iterate over residues of x modulo p, in LOCAL row coordinates
            for xv in range(0, min(p, NX)):
                first_abs = x0 + xv
                rows = np.arange((first_abs - x0), NX, step)
                if len(rows) == 0: continue
                ystart = (r - d * first_abs) % p
                cols = np.arange(ystart, Y - y0, step)
                if len(cols) == 0: continue
                surv[np.ix_(rows, cols)] = False
                sieve_marks += len(rows) * len(cols)
    t_sieve = time.perf_counter() - t0
    idx = np.argwhere(surv)
    n_surv = len(idx)
    t1 = time.perf_counter()
    n_rel = 0; trial_ops = 0
    rels = []
    fbl = fb
    if collect:
        fbarray = np.array(fbl, dtype=object)
        for (i, j) in idx:
            Xv = x0 + int(i); Yv = y0 + int(j)
            v = (d * Xv + Yv) ** 3 + c
            rem = v; ok = True
            for p in fbl:
                trial_ops += 1
                if rem % p == 0:
                    while rem % p == 0: rem //= p
                if rem == 1: break
            if rem == 1:
                n_rel += 1
                if len(rels) < 50: rels.append((Xv, Yv, v))
    t_trial = time.perf_counter() - t1
    return dict(N=N, d=d, c=c, BB=BB, X=X, Y=Y, x0=x0, y0=y0,
                cells=cells, n_primes=npr, n_surv=n_surv, n_rel=n_rel,
                sieve_marks=int(sieve_marks), trial_ops=int(trial_ops),
                total_ops=int(sieve_marks + trial_ops),
                t_sieve=t_sieve, t_trial=t_trial, t_total=t_sieve + t_trial,
                rels_sample=rels[:10])
