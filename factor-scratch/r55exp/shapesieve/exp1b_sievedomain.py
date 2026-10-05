#!/usr/bin/env python3
"""
exp1b: DOES THE SHAPE OF N CHANGE THE SIEVING DOMAIN?  (CORRECTED -- see ERRORS.md E1)

exp1 was VACUOUS: M=20000 gave M^2 = 4e8 < N ~ 9e11, so u^2 mod N = u^2
identically and N never entered.  Fixed here by taking N ~ 2^24 and
M = 200000, so M / sqrt(N) ~ 50 and the reduction genuinely wraps.

The statistic, per modulus N and per candidate u in [0,M):

    g(u) = u^2 mod N                       (the Dixon / QS sieved quantity)
    survives iff no prime q <= B divides g(u)

This is the exact sieving survival test. A sieve's cost is

    (#candidates) x (marking cost ~ sum_{q<=B} 1/q)  /  (survival rate)

so the survival rate IS the shape-sensitivity channel, if one exists.

PREDICTIONS (written before running):

  P1b.1  SURVIVAL RATE IS SHAPE-BLIND.  For every family with all prime
         factors > B, the survival rate equals the Mertens-like baseline for a
         "random" residue. Specifically surv/M should equal
         prod_{q<=B} (1 - rho_q) where rho_q = #roots of N mod q in [0,q) / q
         averaged over N -- and since the shape families are equidistributed
         mod q, this is the SAME constant for all of them.
         -> per-cell medians agree to within Poisson error.

  P1b.2  POSITIVE CONTROL (MUST FIRE): if N has a prime factor p <= B, the
         sieve MUST see it. Take N = p * m with p = 3, 5, 7 <= B. Then
         g(u) = u^2 mod N is divisible by p for a *specific* set of u -- those
         with u^2 = pm i.e. u divisible by p, giving density 1/p extra...
         Actually: for u not divisible by p, u^2 mod N is not divisible by p
         unless u^2 mod p = 0, i.e. p | u. So the p-mark REMOVES 1/p of
         candidates -- exactly as for a generic N where p is just a sieve
         prime. Hmm.

         THE REAL POSITIVE CONTROL: take N = p^2 * m with p <= B. Then
         g(u) = u^2 mod N is divisible by p^2 whenever p | u, and -- crucially
         -- the survivors are BIASED: for p | u, u^2 mod N has a forced p^2.
         But more decisively: take N = 2^t * m with t >= 2 and B = 2. Then
         g(u) = u^2 mod N is even iff u is even, so survivors are all odd
         u... that's shape-blind too.

         CLEANEST POSITIVE CONTROL: compare against a NON-SIEVE-VISIBLE
         baseline. Set N = 2^t * m with t LARGE (t = 20) and M large. Then for
         u < M = 2^17.5, u^2 < 2^35 < N, so u^2 mod N = u^2 and the sieve
         sees u^2 whose 2-adic valuation is 2*v2(u) >= 2t... no.

         USE THIS ONE, IT IS UNAMBIGUOUS: the positive control is a change in
         the SIEVED QUANTITY, not in N. Compare
            (A) g_A(u) = u^2 mod N          (shape-aware sieve)
            (B) g_B(u) = u^2 mod N * k      with k chosen so that
         the BASis of the smooth part differs. Too complicated.

         SIMPLEST HONEST POSITIVE CONTROL: vary B. As B -> 2^24 (past sqrt(N)),
         the sieve must become shape-sensitive, because then a <= B and the
         shape factor a IS in the factor base. So:
            at B=60 (a >> B): survival is shape-blind
            at B=2^12 (a <= B): survival MUST become shape-sensitive
         That is a real, sharp, positive control. Run both.

  P1b.3  NEGATIVE CONTROL: two independent generic batches, same size,
         must agree.

  P1b.4  If P1b.2's high-B arm fires and the low-B arm does not, we have
         MEASURED the channel through which shape could enter a sieve, and
         shown that channel is closed for any B < minFac(N). That is the
         result.

SCOPE: all N < 2^24, generated locally. Not cryptographic.
"""
import sys, hashlib, random
from sympy import isprime, nextprime, primerange

SEED = 20261004
random.seed(SEED)
B_small = 60


def rp(bits, avoid=()):
    while True:
        p = int(nextprime(random.getrandbits(bits) | (1 << (bits - 1))))
        if isprime(p) and p not in avoid:
            return p


def med(v):
    s = sorted(v); n = len(s)
    return s[n // 2] if n % 2 else (s[n // 2 - 1] + s[n // 2]) / 2


def surv(N, B, M):
    """#{u<M : no prime q<=B divides u^2 mod N}.  N genuinely enters here
    because M^2 >> N."""
    small = list(primerange(2, B + 1))
    c = 0
    for u in range(M):
        g = (u * u) % N
        if g == 0:
            continue
        for q in small:
            if g % q == 0:
                break
        else:
            c += 1
    return c


def mertens_baseline(B):
    P = 1.0
    for q in primerange(2, B + 1):
        P *= (1 - 1.0 / q)
    return P


def main():
    print("=" * 78)
    print("exp1b  SIEVING DOMAIN, CORRECTED   seed=%d" % SEED)
    print("       N ~ 2^24, M = 200000 so M^2 >> N: the modulus IS in the room")
    print("=" * 78)
    M = 200000
    print("\nSanity gate (the bug that killed exp1):")
    print("   M^2 = %d , typical N ~ 2^24 = %d , M^2/N ~ %.1f  -> wraps: %s"
          % (M * M, 2 ** 24, (M * M) / 2 ** 24, (M * M) / 2 ** 24 > 4))

    fams = {}
    fams["pq generic"] = []
    while len(fams["pq generic"]) < 10:
        p = rp(12); q = rp(12, avoid=(p,))
        if (p * q).bit_length() <= 25:
            fams["pq generic"].append(p * q)
    fams["a^2 b"] = []
    while len(fams["a^2 b"]) < 10:
        a = rp(8); b = rp(8, avoid=(a,))
        if (a * a * b).bit_length() <= 25:
            fams["a^2 b"].append(a * a * b)
    fams["a^3 b"] = []
    while True:
        a = rp(5); b = rp(10, avoid=(a,))
        if (a ** 3 * b).bit_length() <= 25:
            fams["a^3 b"].append(a ** 3 * b)
            if len(fams["a^3 b"]) >= 10:
                break
    fams["NEG CTRL pq'"] = []
    while len(fams["NEG CTRL pq'"]) < 10:
        p = rp(12); q = rp(12, avoid=(p,))
        if (p * q).bit_length() <= 25:
            fams["NEG CTRL pq'"].append(p * q)
    # POSITIVE CONTROL: a <= B, so the shape factor is IN the factor base
    fams["POS CTRL a=5<=B"] = []
    for _ in range(10):
        a = 5; b = rp(19, avoid=(a,))
        while (a * a * b).bit_length() > 25:
            b = rp(19, avoid=(a,))
        fams["POS CTRL a=5<=B"].append(a * a * b)

    for name, lst in fams.items():
        assert all(N.bit_length() <= 25 for N in lst), (name, [N.bit_length() for N in lst])

    print("\n--- P1b.1  SURVIVAL RATE, B = %d (all factors > B) ---" % B_small)
    print("     %-16s %-5s %-9s %-9s %-9s %-9s %-11s" %
          ("family", "cells", "median", "min", "max", "sd", "exp hits/cell"))
    base_rate = mertens_baseline(B_small)
    print("     Mertens baseline prod(1-1/q), q<=%d = %.5f   [REFERENCE]" % (B_small, base_rate))
    rates = {}
    for name, lst in fams.items():
        rr = [surv(N, B_small, M) / M for N in lst]
        rates[name] = rr
        mu = sum(rr) / len(rr)
        sd = (sum((x - mu) ** 2 for x in rr) / max(1, len(rr) - 1)) ** 0.5
        exp_hits = mu * M
        flag = ""
        if exp_hits < 20:
            flag = "  *** UNDERPOWERED"
        print("     %-16s %-5d %-9.5f %-9.5f %-9.5f %-9.5f %.0f%s"
              % (name, len(rr), med(rr), min(rr), max(rr), sd, exp_hits, flag))
        print("       %-14s cells: %s" % ("", " ".join("%.4f" % x for x in rr)))

    print("\n--- P1b.2  POSITIVE CONTROL: raise B past the shape factor ---")
    print("     Now B = 4096 > a = 5 for the POS CTRL family. The shape factor is")
    print("     INSIDE the factor base, so the sieve MUST become shape-sensitive.")
    for B in (60, 512, 4096):
        print("     B = %-5d" % B)
        for name in ("pq generic", "POS CTRL a=5<=B"):
            lst = fams[name][:6]
            rr = [surv(N, B, M) / M for N in lst]
            print("       %-18s median=%.5f  cells: %s"
                  % (name, med(rr), " ".join("%.4f" % x for x in rr)))
        pr = [surv(N, B, M) / M for N in fams["pq generic"][:6]]
        pc = [surv(N, B, M) / M for N in fams["POS CTRL a=5<=B"][:6]]
        ratio = med(pc) / med(pr)
        print("       -> shape/generic ratio = %.4f   detector FIRES? %s"
              % (ratio, "YES" if not (0.97 < ratio < 1.03) else "NO"))

    print("\n--- P1b.3  CONCLUSION CELL TABLE ---")
    print("     %-16s %-10s %-12s %-14s" % ("family", "ratio/pq", "verdict", "B regime"))
    b = med(rates["pq generic"])
    for name, rr in rates.items():
        r = med(rr) / b
        v = "shape-BLIND" if 0.97 < r < 1.03 else "SHAPE-SENSITIVE"
        print("     %-16s %-10.4f %-12s %-14s" % (name, r, v, "B<a (a>B)"))
    # positive control cell at low B
    r_pc = med(rates["POS CTRL a=5<=B"]) / b
    print("     %-16s %-10.4f %-12s %-14s" % ("POS CTRL a=5", r_pc,
          "shape-BLIND" if 0.97 < r_pc < 1.03 else "SHAPE-SENSITIVE", "a=5>B=60"))

    sig = hashlib.sha256(("|".join("%s:%.8f" % (k, med(v)) for k, v in rates.items())).encode()).hexdigest()[:16]
    print("\nOUTPUT SIGNATURE (run-twice check): %s" % sig)


if __name__ == "__main__":
    main()
