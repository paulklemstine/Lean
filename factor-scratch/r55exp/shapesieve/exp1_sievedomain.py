#!/usr/bin/env python3
"""
exp1: THE SIEVED DOMAIN. Does the shape of N change the *sieving domain*?

A sieving primitive for factoring does exactly this: it enumerates integers
u in a range, computes g(u) (a rational function of u and N), and tests
g(u) for B-smoothness.  Its cost is

    cost = (#candidates) x (cost of the smoothness test)
         = (M) x (marking cost for primes <= B)

and #candidates that survive to give a relation is governed by
Dickman's rho(u), u = log(max value)/log B.

THE QUESTION: rho, and the marking cost, are functions of the SIZE of g(u)
and of B.  Both are determined by log N.  Does the SHAPE of N (which primes
divide it, with what multiplicity) change either?

The answer the whole project needs: measure it.

PREDICTIONS (written before running):

  P1.1  For N = a^k b, the sieved values g(u) = u^2 mod N live in the SAME
        size range as for N = p q of the same bit-length.  So the survival
        rate rho(u) is the SAME.  -> survival rate identical across shapes
        to within Poisson error.

  P1.2  POSITIVE CONTROL -- a shape that MUST change the survival rate:
        N = 2^t * m with t large.  Then for half the u, g(u) = u^2 mod N is
        forced to be divisible by 2^t, i.e. the sieved value is
        automatically "more smooth" in the 2-part.  This detector MUST fire.
        If it does not, exp1 measures nothing (vacuous test).

  P1.3  NEGATIVE CONTROL: two independent generic pq moduli of matched size
        must NOT fire.

  P1.4  The shape-invisible claim: |{u : gcd(u^2 mod N, P_B)=1}| / M has
        mean and variance independent of the shape family. Report per-cell.

  P1.5  The multiplicity channel: for N = a^2 b, a is a PRIME SQUARE divisor.
        A classical sieve cannot see a^2 | N because a > B.  But the
        SIEVING of u^2 mod N against q <= B: does the residue structure
        differ?  Prediction: no, because u^2 mod q for q < minFac(N) is
        determined by N mod q, and N mod q is equidistributed regardless of
        shape.  -> the multiset {N mod q : q <= B} carries NO shape info.
        MEASURE: chi-square of the residue distribution vs a generic modulus.

All moduli local, N < 2^40.
"""
import sys, math, hashlib, random
from sympy import isprime, nextprime, primerange, factorint

SEED = 20261004
random.seed(SEED)


def rp(bits, avoid=()):
    while True:
        p = int(nextprime(random.getrandbits(bits) | (1 << (bits - 1))))
        if isprime(p) and p not in avoid:
            return p


def med(v):
    s = sorted(v); n = len(s)
    return s[n // 2] if n % 2 else (s[n // 2 - 1] + s[n // 2]) / 2


def survival(N, B, M):
    """Fraction of u in [0,M) with gcd(u^2 mod N, P_B) = 1 -- i.e. u^2 mod N
    has no prime factor <= B.  This is EXACTLY the QS/Dixon sieving survival
    statistic.  Returns (count, M)."""
    small = list(primerange(2, B + 1))
    cnt = 0
    for u in range(M):
        g = (u * u) % N
        if g == 0:
            continue
        ok = True
        for q in small:
            if g % q == 0:
                ok = False
                break
        if ok:
            cnt += 1
    return cnt


def survival_fast(N, B, M):
    """Marking-based survival: identical semantics, O(M log log B + M sum 1/q)."""
    small = list(primerange(2, B + 1))
    surv = bytearray(b"\x01") * M
    for q in small:
        # u with q | u^2 mod N  <=>  u^2 = q t  ... use residue roots of N mod q
        r = N % q
        # roots of x^2 = r mod q
        roots = sqrts_mod(r, q)
        if not roots:
            continue
        for u in range(M):
            if u % q in roots:
                surv[u] = 0
    return sum(surv)


def sqrts_mod(a, p):
    """square roots of a mod odd prime p, or [] if none."""
    a %= p
    if a == 0:
        return [0]
    if pow(a, (p - 1) // 2, p) != 1:
        return []
    r = pow(a, (p + 1) // 4, p) if p % 4 == 3 else _tonelli(a, p)
    if r * r % p != a:
        return []
    return sorted({r, (-r) % p})


def _tonelli(a, p):
    for c in [x for x in range(1, p) if pow(x, (p - 1) // 2, p) == p - 1][:50]:
        v, e, m = a, p - 1, 0
        while v % 2 == 0:
            v //= 2; m += 1
        t = pow(c, e, p); r = pow(v, (m + 1) // 2, p)
        while t != 1:
            i, t2 = 0, pow(t, 2, p)
            while t2 != 1:
                t2 = t2 * t2 % p; i += 1
            b = pow(c, 1 << (m - i - 1), p)
            r = r * b % p; t = t * b % p % p; m = i
        return r
    return None


def residue_chi2(N, B):
    """Do the residues N mod q (q <= B) carry shape information?
    Compare their distribution to the distribution for a random N.
    Statistic: sum over q of the number of distinct residues, and a
    chi-square-style dispersion of N mod q normalized."""
    small = list(primerange(2, B + 1))
    vals = [N % q for q in small]
    mean = sum(vals) / len(vals)
    var = sum((v - mean) ** 2 for v in vals) / len(vals)
    return mean, var, vals


def main():
    print("=" * 78)
    print("exp1  DOES THE SHAPE OF N CHANGE THE SIEVING DOMAIN?  seed=%d" % SEED)
    print("     all N < 2^40, generated locally, nothing cryptographic")
    print("=" * 78)

    B, M = 60, 20000
    print("\nSetup: B=%d (primes 2..%d), M=%d candidates u in [0,M)."
          % (B, B, M))

    fams = {}
    # --- generic pq
    fams["pq (generic)"] = []
    for _ in range(12):
        p = rp(20); q = rp(20, avoid=(p,))
        fams["pq (generic)"].append(p * q)
    # --- a^2 b  (a,b ~ 13 bits)
    fams["a^2 b"] = []
    for _ in range(12):
        a = rp(13); b = rp(13, avoid=(a,))
        fams["a^2 b"].append(a * a * b)
    # --- a^3 b
    fams["a^3 b"] = []
    for _ in range(12):
        a = rp(10); b = rp(13, avoid=(a,))
        fams["a^3 b"].append(a ** 3 * b)
    # --- a^k b with a ~ 20 bits  (a is LARGE, comparable to sqrt N)
    fams["a^2 b (a~20b)"] = []
    for _ in range(12):
        a = rp(13); b = rp(13, avoid=(a,))
        fams["a^2 b (a~20b)"].append(a * a * b)

    # --- POSITIVE CONTROL family: N = 2^t * m, t = 12.  The sieve MUST see it.
    fams["POS CTRL 2^12*m"] = []
    for _ in range(12):
        m = rp(27)
        fams["POS CTRL 2^12*m"].append(2 ** 12 * m)

    # --- NEGATIVE CONTROL: second generic batch
    fams["NEG CTRL pq'"] = []
    for _ in range(12):
        p = rp(20); q = rp(20, avoid=(p,))
        fams["NEG CTRL pq'"].append(p * q)

    print("\n--- P1.4  SURVIVAL RATE per cell (per-cell, never pooled) ---")
    print("     surv = #{u<M : gcd(u^2 mod N, P_B)=1}; rate = surv/M")
    print("     %-18s %-4s %-9s %-9s %-9s %-9s %s" %
          ("family", "cells", "median", "min", "max", "sd", "expected hits/cell"))
    rates = {}
    for name, lst in fams.items():
        rr = [survival(N, B, M) / M for N in lst]
        rates[name] = rr
        sd = (sum((x - sum(rr) / len(rr)) ** 2 for x in rr) / max(1, len(rr) - 1)) ** 0.5
        exp_hits = sum(rr) * M / len(rr)
        print("     %-18s %-4d %-9.5f %-9.5f %-9.5f %-9.5f %.0f" %
              (name, len(rr), med(rr), min(rr), max(rr), sd, exp_hits))
        if exp_hits < 20:
            print("     *** UNDERPOWERED (expected hits %.1f < 20) -- DO NOT INTERPRET" % exp_hits)

    base = rates["pq (generic)"]
    print("\n--- P1.1  IS THE SURVIVAL RATE SHAPE-DEPENDENT? ---")
    print("     %-18s %-12s %-12s %-10s" %
          ("family", "median rate", "ratio to pq", "verdict"))
    for name, rr in rates.items():
        r = med(rr) / med(base)
        v = "SAME (shape-blind)" if 0.9 < r < 1.11 else "DIFFERENT"
        print("     %-18s %-12.5f %-12.4f %-10s" % (name, med(rr), r, v))

    print("\n--- P1.2  POSITIVE CONTROL: does the detector EVER fire? ---")
    pc = med(rates["POS CTRL 2^12*m"]) / med(base)
    print("     POS CTRL 2^12*m ratio to pq = %.4f  -> detector FIRES? %s"
          % (pc, "YES" if not (0.9 < pc < 1.11) else "NO -- EXP1 IS VACUOUS"))
    print("     %-8s %-11s %-9s %-9s" % ("cell", "N", "surv", "rate"))
    for N in fams["POS CTRL 2^12*m"][:6]:
        c = survival(N, B, M)
        print("     %-8s %-11d %-9d %-9.5f" % ("2^12*m", N, c, c / M))

    print("\n--- P1.3  NEGATIVE CONTROL: two generic batches must agree ---")
    nc = med(rates["NEG CTRL pq'"]) / med(base)
    print("     NEG CTRL pq' ratio to pq = %.4f  -> detector QUIET? %s"
          % (nc, "YES" if 0.9 < nc < 1.11 else "NO -- false positive rate too high"))
    print("     %-8s %-11s %-9s %-9s" % ("cell", "N", "surv", "rate"))
    for N in fams["NEG CTRL pq'"][:6]:
        c = survival(N, B, M)
        print("     %-8s %-11d %-9d %-9.5f" % ("pq'", N, c, c / M))

    print("\n--- P1.5  Do the residues N mod q (q<=B) carry shape information? ---")
    print("     %-18s %-10s %-10s %-10s" % ("family", "mean(N mod q)", "var", "med var"))
    for name, lst in fams.items():
        vs = [residue_chi2(N, B)[1] for N in lst]
        ms = [residue_chi2(N, B)[0] for N in lst]
        print("     %-18s %-10.3f %-10.3f %-10.3f" % (name, med(ms), med(vs), med(vs)))

    sig = hashlib.sha256(
        ("|".join("%s:%.8f" % (k, med(v)) for k, v in rates.items())).encode()).hexdigest()[:16]
    print("\nOUTPUT SIGNATURE (run-twice check): %s" % sig)
    return sig


if __name__ == "__main__":
    main()
