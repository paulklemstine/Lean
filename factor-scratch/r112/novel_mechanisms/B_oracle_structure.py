#!/usr/bin/env python3
"""
CANDIDATE B -- Decision-oracle structure: does knowing the LEGENDRE symbol
mod the SMALL factor beat birthday, because Z_p* is cyclic of KNOWN size?

THE MECHANISM (distinct from Coppersmith / NFS / Williams / ECM).
Classic factoring-with-a-decision-oracle does: query whether a is a QR mod p
for random a until two land in the same coset, then gcd(a-b, N).  That is
birthday on a coset of the square subgroup, i.e. ~ |Q_p|^{1/2} = p^{1/2}
operations, so it buys NOTHING over plain Pollard rho (which is also p^{1/2}).
The tempting structural claim is that an oracle plus the fact that Z_p* is
CYCLIC OF KNOWN ORDER lets you do better than birthday -- e.g. index calculus
in a group of known order, or Pohlig-Hellman on the known factorization
shape of p-1.

CLAIM (falsifiable): for p ~ 2^64 with a full Legendre-symbol oracle on
Z_p*, the expected number of ORACLE QUERIES needed to produce a non-trivial
factor of N is o(p^{1/2}) -- specifically at or below the index-calculus /
smoothness cost L_p[1/2], beating birthday.

WHAT WOULD KILL IT: if the query count is ~p^{1/2} regardless of structure,
the oracle adds zero and the direction is closed.  That is what we measure.

HONEST SCOPE.  This is a THEORETICAL-BOUND study, not a factoring result: the
oracle is assumed, not obtained.  Its value is deciding whether the whole
"oracle structure" direction is worth pursuing.  We therefore ALSO measure
the oracle-free baseline (Pollard rho) in the same harness so the comparison
is like-for-like.
"""
import json, math, time, random
from math import gcd
import sympy
from sympy import isprime
from common112 import gen_semiprime, verified_factor


def legendre_oracle_factor(N, p, q, budget_q, rng):
    """Birthday-with-2-cosets using a Legendre(p) oracle.

    Standard: split Z_p* into the 2 cosets of Q_p by the Legendre symbol.
    Collect a_i by oracle bit; within a coset, gcd(a_i - a_j, N) splits N
    with prob ~1/2.  This is the textbook use and costs ~p^{1/2} QUERIES.
    Returns (queries_used, factor_or_None, mode).
    """
    seen = {1: [], -1: []}
    queries = 0
    for _ in range(budget_q):
        a = rng.randrange(2, p)
        chi = int(sympy.legendre_symbol(a, p))       # THE ORACLE
        queries += 1
        bucket = seen[chi]
        for b in bucket:
            g = gcd(a - b, N)
            if 1 < g < N and verified_factor(N, p, q, g):
                return queries, g, "oracle-birthday"
        bucket.append(a)
    return queries, None, "oracle-birthday-exhausted"


def pollard_rho_baseline(N, p, q, budget_q, rng, seed=0):
    """Oracle-FREE baseline: Pollard rho, same query budget accounting."""
    x = y = rng.randrange(2, N)
    c = rng.randrange(1, N)
    d = 1
    steps = 0
    f = lambda v: (v * v + c) % N
    while d == 1 and steps < budget_q:
        x = f(x); y = f(f(y))
        d = gcd(abs(x - y), N)
        steps += 1
    if 1 < d < N and verified_factor(N, p, q, d):
        return steps, d, "pollard-rho"
    return steps, None, "pollard-rho-exhausted"


def main():
    out = dict(cells=[])
    # p=40 bits makes rho cost ~40*2^20 = 4e7 pure-Python gcd steps, which
    # overran the wall clock.  p<=32 keeps rho at ~1e5 steps (well inside
    # budget) while still giving sqrt(p) >> the old 20000 cap, so the
    # control genuinely factors.
    for bits_p, seed in [(28, 1), (28, 2), (30, 1), (30, 2), (32, 1), (32, 2)]:
        rng = random.Random(seed)
        p, q, N = gen_semiprime(2 * bits_p, seed, beta=0.5)
        assert p * q == N
        # BUDGET DEFECT FIX: the first run used budget=20000 while
        # sqrt(p) ~ 2^20 for a 40-bit p, so BOTH arms exhausted without
        # factoring -- a void run, not a null.  That is the "a parameter I
        # chose manufactured the result I was hunting" failure.  The budget
        # is now derived from p so rho MUST succeed: that success is the
        # mandatory negative control proving the harness can factor at all.
        budget = 12 * math.isqrt(p)
        t0 = time.time()
        qo, fo, mo = legendre_oracle_factor(N, p, q, budget, rng)
        t1 = time.time()
        qr, fr, mr = pollard_rho_baseline(N, p, q, budget, rng)
        t2 = time.time()
        sq = math.isqrt(p)
        out["cells"].append(dict(
            bits_p=bits_p, seed=seed, p=bits_p and p.bit_length(),
            qbits=q.bit_length(), budget=budget,
            oracle_queries=qo, oracle_factor=(fo is not None),
            oracle_mode=mo, oracle_s=round(t1 - t0, 2),
            rho_steps=qr, rho_factor=(fr is not None), rho_mode=mr,
            rho_s=round(t2 - t1, 2),
            sqrt_p=sq, ratio_oracle_to_sqrtp=round(qo / sq, 3),
            ratio_rho_to_sqrtp=round(qr / sq, 3)))
        print("p=%d bits seed=%d: oracle %d q (%.2f*sqrt p) -> %s | "
              "rho %d steps (%.2f*sqrt p) -> %s" %
              (bits_p, seed, qo, qo / sq, mo, qr, qr / sq, mr), flush=True)
    fn = "/home/raver1975/lean/factor-scratch/r112/novel_mechanisms/out_B_oracle.json"
    json.dump(out, open(fn, "w"), indent=1)
    print("wrote", fn)


if __name__ == "__main__":
    main()
