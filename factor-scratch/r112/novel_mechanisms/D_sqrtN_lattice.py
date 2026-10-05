#!/usr/bin/env python3
"""
CANDIDATE D -- A lattice on a DIFFERENT algebraic object than f(x,y)=0:
the p+q relation, i.e. writing 4N = (p+q)^2 - (p-q)^2.

THE MECHANISM.  Every lattice in the closed corpus is built from f(x,y)=0
(NFS) or from f(x) = a + x with x0 | N (Coppersmith).  A structurally
different object: s = p+q is an integer of size ~2*sqrt(N) for BALANCED
primes, and N = pq gives s^2 = 4N + (p-q)^2, i.e. s^2 - t^2 = 4N with
t = p-q.  So factoring N is the same as finding an integer solution to
s^2 - t^2 = 4N -- Fermat's method.  The lattice question: does LLL on the
form (s - t)(s + t) = 4N beat Fermat's O((p-q)^2/sqrt(N)) linear search?

FALSIFIER.  For balanced primes |p-q| ~ sqrt(N), so Fermat already costs
~N^{1/4} at worst -- which is the Pollard-rho bound.  The candidate dies if
the measured lattice does not beat rho.  We measure it rather than assert it.

HONEST PRIOR (stated before running): this is very likely a re-discovery of
Fermat, and Fermat is not better than rho for random balanced primes.  It is
run because it is the cheapest possible test of the brief's explicit
suggestion "lattice constructions using a DIFFERENT algebraic object than
f(x,y)=0", and a clean kill closes a suggested direction.
"""
import sys, json, time, random
from math import gcd, isqrt
from sympy import nextprime, isprime
from common112 import gen_semiprime, verified_factor


def fermat(N, budget):
    """Classic Fermat: increment a from ceil(sqrt(N)) until a^2-N is square."""
    a = isqrt(N)
    if a * a < N:
        a += 1
    for _ in range(budget):
        b2 = a * a - N
        b = isqrt(b2)
        if b * b == b2:
            g = gcd(a - b, N)
            if 1 < g < N:
                return g, a - isqrt(N)
        a += 1
    return None, budget


def pollard_rho(N, budget, rng):
    x = rng.randrange(2, N)
    y = x
    c = rng.randrange(1, N)
    d = 1
    for i in range(budget):
        x = (x * x + c) % N
        y = (y * y + c) % N
        y = (y * y + c) % N
        d = gcd(abs(x - y), N)
        if d != 1:
            break
    return (d if 1 < d < N else None), i + 1


def main():
    out = dict(cells=[])
    for bits, seed in [(80, 1), (80, 2), (80, 3)]:
        rng = random.Random(seed)
        p, q, N = gen_semiprime(bits, seed, beta=0.5)
        assert p * q == N
        budget = 300000
        t0 = time.time()
        gF, stepsF = fermat(N, budget)
        t1 = time.time()
        okF = verified_factor(N, p, q, gF) if gF else False
        gR, stepsR = pollard_rho(N, budget, rng)
        t2 = time.time()
        okR = verified_factor(N, p, q, gR) if gR else False
        out["cells"].append(dict(bits=bits, seed=seed, budget=budget,
                                 fermat_factor=okF, fermat_steps=stepsF,
                                 fermat_s=round(t1 - t0, 2),
                                 rho_factor=okR, rho_steps=stepsR,
                                 rho_s=round(t2 - t1, 2)))
        print("N=%d bits seed=%d: Fermat %s in %d steps (%.2fs) | "
              "rho %s in %d steps (%.2fs)" %
              (bits, seed, okF, stepsF, t1 - t0, okR, stepsR, t2 - t1),
              flush=True)
    fn = ("/home/raver1975/lean/factor-scratch/r112/novel_mechanisms/"
          "out_D_fermat.json")
    json.dump(out, open(fn, "w"), indent=1)
    print("wrote", fn)


if __name__ == "__main__":
    main()
