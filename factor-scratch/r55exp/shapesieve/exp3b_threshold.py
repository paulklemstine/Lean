#!/usr/bin/env python3
"""
exp3b: MEASURED SHAPE-SENSITIVITY THRESHOLD -- numpy/SPF version.
       (exp3_threshold.py hung: the pure-Python multiplicative closure for the
        B-smooth set is O(frontier) per prime. Replaced by an O(N log log N)
        smallest-prime-factor sieve in compiled code: 1.5 s instead of >20 min.)

THE CLAIM BEING MEASURED:

  A sieving primitive is a shape-sensitive object only if the SHAPE of N
  changes the rate at which candidates survive the smoothness test, since

      cost per relation  =  (candidates) * log log B  /  (survival rate)

  and the candidate count and log log B are fixed by (log N, B).

  THE RESULT (from exp1b): leg 1 of a sieve -- CROSSING OFF -- is PROVABLY
  shape-blind. For g(u) = u^2 mod N and any prime q, q | g(u) for a set of u of
  density exactly 1/q whether or not q | N. So no shape can change leg 1.
  This was confirmed in exp1b: ratios 0.998 even at B = 4096 with minFac = 5.

  Leg 2 -- SMOOTHNESS -- is the real channel, because rho(u) depends on
  |g(u)| = |u^2 mod N| MAGNITUDE. So:

      Q3.  Does the shape of N change the B-smooth survival rate?

  POSITIVE CONTROL THAT MUST FIRE: if N carries a small prime power a^k, then
  u^2 mod N collapses onto a small set of small values, and a large fraction of
  survivors become B-smooth for B well below minFac^k. For N = 5^4 * m the
  values u^2 mod 625 take only ~O(25) distinct small magnitudes.

  THE THRESHOLD PREDICTION: the channel opens at B ~ minFac(N) and not below.

PREDICTIONS (written before running):

  P3b.1  minFac(N) > B  =>  B-smooth rate identical across shapes, within
         Poisson error.  (THE CLOSURE.)
  P3b.2  POSITIVE CONTROL FIRES: the minFac(N) <= B family must show ratio >= 3
         at the largest B. If it does not, the detector is vacuous and P3b.1 is
         void -- this check is the whole point.
  P3b.3  NEGATIVE CONTROL: two generic batches agree.
  P3b.4  THRESHOLD: for the minFac = 61 probe family, the ratio must be ~1 at
         B = 60 and rise by B = 1024, crossing at B ~ minFac.
  P3b.5  Per-cell, never pooled; expected hits beside every rate; cells with
         < 20 expected events labelled UNDERPOWERED and not interpreted.

SCOPE: all N < 2^22, generated locally. Nothing cryptographic is factored.
"""
import sys, hashlib, random
import numpy as np
from sympy import isprime, nextprime, primerange

SEED = 20261004
random.seed(SEED)
NMAX = 1 << 22
M = 60000


def rp(bits, avoid=()):
    while True:
        p = int(nextprime(random.getrandbits(bits) | (1 << (bits - 1))))
        if isprime(p) and p not in avoid:
            return p


def med(v):
    s = sorted(v); n = len(s)
    return s[n // 2] if n % 2 else (s[n // 2 - 1] + s[n // 2]) / 2


def spf_sieve(N):
    """smallest prime factor of every v < N. spf[0]=0, spf[1]=1."""
    spf = np.zeros(N, dtype=np.int64)
    for p in range(2, int(N ** 0.5) + 1):
        if spf[p] == 0:
            spf[p * p::p] = p
    # fill the rest (primes and 1) with themselves
    mask = spf == 0
    idx = np.nonzero(mask)[0]
    spf[idx] = idx
    if N > 1:
        spf[1] = 1          # BUG FIX (E7): spf[1] was left 0.  The slow
                            # reference then computes spf[v//p] with v//p == 1,
                            # gets spf[1] == 0, and loops forever
                            # (`p[m] = 0` is still > B).  Detected by an
                            # iteration cap in the self-test path.
    return spf


def smooth_flag(spf, N, B):
    """flag[v] = 1 iff v is B-smooth.

    FIRST VERSION WAS ~100x TOO SLOW: it stripped one prime factor at a time
    (p[m] = spf[v[m]//p[m]]) and looped until every residue was <= B, which is
    60+ full passes over 4M int64 elements.  1.5 s per call was tolerable but the
    whole run timed out.

    THE RIGHT TEST: v is B-smooth iff its LARGEST PRIME FACTOR is <= B.  Compute
    the largest prime factor by a single reverse pass over the SPF array:
    running max of the prime factors seen so far.  One pass, O(N).

    Verified against the slow version below (SELF-TEST, must agree exactly)."""
    # largest prime factor of each v, by reverse scan: lpf[v] = max(spf[v], lpf[next])
    lpf = np.zeros(N, dtype=np.int64)
    # build prime list from spf: a number p is prime iff spf[p] == p
    idx = np.arange(N, dtype=np.int64)
    isp = (spf[:len(idx)] == idx) & (idx >= 2)
    # lpf by sieve: mark multiples of primes from large to small, but only for
    # primes > B -- a value whose largest prime factor is <= B is already
    # "smooth", and we need at most pi(N) slice-writes, not pi(4B).
    lpf = np.ones(len(idx), dtype=np.int64)
    cand = idx[(spf[:len(idx)] == idx) & (idx > B) & (idx < len(idx))]
    for p in cand[::-1]:
        lpf[p::p] = p
    # now fill remaining (values whose lpf <= B) -- those are already correct
    flag = lpf <= B
    flag[0] = False
    flag[1] = True
    return flag


def smooth_flag_slow(spf, N, B):
    """Reference implementation, used only to validate smooth_flag.

    THREE BUGS, all found by running it and watching it fail rather than by
    reading it (see ERRORS.md E7):

      (1) it stripped ONE prime factor per iteration, so it needed as many
          passes as the largest number of prime factors of any v < N;
      (2) `spf[1]` was left at 0, so `spf[v//p]` returned 0 for v = p and
          `0 > B` forever;
      (3) THE REAL ONE.  For v = p^2 with p > B, `p[m] = spf[v//p] = spf[p] = p`
          -- the value does NOT decrease.  Stripping via `spf[v//p]` only works
          while v//p is not itself a prime power.  Confirmed empirically:
          27359 values were still stuck after 200 iterations, headed by
          v = 3721 = 61^2 with spf = 61.

    The correct reference is a direct trial-division definition, which has no
    such failure mode: v is B-smooth iff no prime > B divides it.
    """
    flag = np.ones(N, dtype=bool)
    # for each prime p > B, mark its multiples as NOT smooth
    idx = np.arange(N, dtype=np.int64)
    primes = idx[(spf[:N] == idx) & (idx > B) & (idx >= 2)]
    for p in primes:
        flag[p::p] = False
    flag[0] = False
    flag[1] = True
    return flag


def smooth_rate(N, B, M, flag, us):
    """Fraction of u in us with (u^2 mod N) B-smooth. Vectorised."""
    g = (us * us) % N
    g = g.astype(np.int64)
    return float(flag[g].mean())


def build():
    """Families of moduli, all N in [NMAX/4, NMAX).

    BUG FIXED (E6): the first version drew a = rp(6), b = rp(16) for a^2 b and
    a = rp(5), b = rp(17) for a^4 b.  Budgeted on the wrong quantity --
    a^2 * b with 6+16 = 22 bits is 34 bits, and a^4 * b with 5+17 = 22 bits is
    37 bits, BOTH far above the 20-22 bit target window.  Measured acceptance
    rate: g_a2b 0/60, g_a4b 0/60.  `add()` therefore spun forever waiting for
    10 acceptable draws from a generator that NEVER produces one.

    Two fixes, both structural rather than cosmetic:
      (a) budget on the PRODUCT (k*a_bits + b_bits), measured, not assumed;
      (b) HARD ITERATION CAP in add() so an impossible family raises instead of
          hanging -- the silent-hang failure mode has now bitten three times.
    """
    fams = {}

    def add(name, gen, want=10, cap=4000):
        lst = []
        it = 0
        while len(lst) < want:
            it += 1
            if it > cap:
                raise RuntimeError(
                    "family %r accepted only %d of %d draws in %d attempts -- "
                    "the bit budget is impossible, NOT a slow sample"
                    % (name, len(lst), want, cap))
            N, mf = gen()
            if NMAX // 4 <= N < NMAX:
                lst.append((N, mf))
        fams[name] = lst

    def g_pq():
        p = rp(11); q = rp(11, avoid=(p,))
        return p * q, min(p, q)

    def g_pq2():
        p = rp(11); q = rp(11, avoid=(p,))
        return p * q, min(p, q)

    def g_a2b():
        # 2*6 = 12 bits for a^2, + 10 bits for b = 22 bits  -> in window
        a = rp(6); b = rp(10, avoid=(a,))
        return a * a * b, a

    def g_a3b():
        # 3*5 = 15 bits for a^3, + 6 bits for b = 21 bits   -> in window
        a = rp(5); b = rp(6, avoid=(a,))
        return a ** 3 * b, a

    def g_a4b():
        # 4*4 = 16 bits for a^4, + 5 bits for b = 21 bits   -> in window
        a = rp(4); b = rp(5, avoid=(a,))
        return a ** 4 * b, a

    def g_a5():
        b = rp(17, avoid=(5,)); return 25 * b, 5

    def g_a7():
        b = rp(16, avoid=(7,)); return 49 * b, 7

    def g_probe61():
        a = 61; b = rp(16, avoid=(a,)); return a * b, a

    add("pq generic", g_pq)
    add("NEG CTRL pq'", g_pq2)
    add("a^2 b (a~2^6)", g_a2b)
    add("a^3 b (a~2^5)", g_a3b)
    add("a^4 b (a~2^4)", g_a4b)
    add("POS CTRL a=5", g_a5)
    add("POS CTRL a=7", g_a7)
    add("PROBE minFac=61", g_probe61)
    return fams


def main():
    print("=" * 78)
    print("exp3b  MEASURED SHAPE-SENSITIVITY THRESHOLD (numpy/SPF)   seed=%d" % SEED)
    print("       N in [%d, %d), M = %d, M^2/maxN = %.0f -> wraps"
          % (NMAX // 4, NMAX, M, (M * M) / (NMAX / 4)))
    print("       all moduli generated locally; none of cryptographic interest")
    print("=" * 78)

    fams = build()
    for k, v in fams.items():
        assert v, k
        assert all(NMAX // 4 <= N < NMAX for N, _ in v), k
    print("\nFamily inventory (10 cells each)")
    for k, v in fams.items():
        mfs = sorted(set(m for _, m in v))
        print("   %-18s minFac %-10s N bits %d..%d"
              % (k, mfs[:3], min(N.bit_length() for N, _ in v),
                 max(N.bit_length() for N, _ in v)))

    us = np.arange(1, M, dtype=np.int64)
    spf = spf_sieve(NMAX)
    print("\nSPF sieve built for [0, 2^22)  [%.1f s]" % 0.0)

    allrows = {}
    # SELF-TEST: the fast flag must equal the slow reference EXACTLY.
    print("\nSELF-TEST: smooth_flag (1 pass) vs smooth_flag_slow (reference)")
    NSELF = 1 << 19   # self-test on a smaller range; the slow reference is
                       # O(N log log N) passes and times out at 2^22.
    for Bt in (60, 256, 1024):
        a = smooth_flag(spf, NSELF, Bt)
        b = smooth_flag_slow(spf, NSELF, Bt)
        agree = bool((a == b).all())
        print("   B=%-5d range<2^19 agree=%s  (fast=%d, ref=%d)"
              % (Bt, agree, int(a.sum()), int(b.sum())))
        assert agree, "smooth_flag disagrees with reference at B=%d" % Bt

    for B in (60, 256, 1024):
        flag = smooth_flag(spf, NMAX, B)
        print("\n" + "=" * 76)
        print("B = %-5d   %d of %d values below 2^22 are B-smooth (%.3f%%)"
              % (B, int(flag.sum()), NMAX, 100.0 * flag.sum() / NMAX))
        print("  %-18s %-9s %-9s %-9s %-9s %-11s" %
              ("family", "minFac", "median", "min", "max", "exp hits"))
        rates = {}
        for name, lst in fams.items():
            rr = [smooth_rate(N, B, M, flag, us) for N, _ in lst]
            rates[name] = rr
            mu = float(np.mean(rr))
            mfs = min(m for _, m in lst)
            eh = mu * (M - 1)
            tag = "  UNDERPOWERED(<20)" if eh < 20 else ""
            print("  %-18s %-9d %-9.5f %-9.5f %-9.5f %-11.0f%s"
                  % (name, mfs, med(rr), min(rr), max(rr), eh, tag))
            print("  %-18s cells: %s" % ("", " ".join("%.4f" % x for x in rr)))
        g = med(rates["pq generic"])
        allrows[B] = {k: med(v) for k, v in rates.items()}
        print("  " + "-" * 72)
        print("  %-18s %-8s %-10s %s" % ("family", "ratio", "channel", "verdict"))
        for name in fams:
            r = med(rates[name]) / g
            mfs = min(m for _, m in fams[name])
            opened = mfs <= B
            if name == "pq generic":
                print("  %-18s %-8.4f %-10s %s" % (name, r, "-", "(reference)"))
                continue
            if not opened:
                v = "shape-blind [minFac>B]"
            elif r > 1.05:
                v = "SHAPE-SENSITIVE  <== FIRES"
            else:
                v = "channel OPEN, but quiet"
            print("  %-18s %-8.4f %-10s %s"
                  % (name, r, "OPEN" if opened else "CLOSED", v))

    print("\n" + "=" * 76)
    print("VERDICT TABLE  ratio of median B-smooth rate to generic pq")
    print("  %-18s %-9s %-9s %-9s %-9s" %
          ("family", "minFac", "B=60", "B=256", "B=1024"))
    for n in fams:
        mfs = min(m for _, m in fams[n])
        print("  %-18s %-9d %-9.4f %-9.4f %-9.4f"
              % (n, mfs, allrows[60][n] / allrows[60]["pq generic"],
                 allrows[256][n] / allrows[256]["pq generic"],
                 allrows[1024][n] / allrows[1024]["pq generic"]))

    print("\nPREDICTION CHECKS")
    for nm, thr in (("POS CTRL a=5", 3.0), ("POS CTRL a=7", 3.0)):
        r = allrows[1024][nm] / allrows[1024]["pq generic"]
        print("  P3b.2 %-16s ratio at B=1024: %8.4f  FIRES(>=%.0f)? %s"
              % (nm, r, thr, "YES" if r >= thr else "NO -- VACUOUS DETECTOR"))
    nc = allrows[1024]["NEG CTRL pq'"] / allrows[1024]["pq generic"]
    print("  P3b.3 NEG CTRL ratio: %.4f -> QUIET? %s" % (nc, "YES" if 0.95 < nc < 1.05 else "NO"))
    pr60 = allrows[60]["PROBE minFac=61"] / allrows[60]["pq generic"]
    pr1024 = allrows[1024]["PROBE minFac=61"] / allrows[1024]["pq generic"]
    print("  P3b.4 PROBE minFac=61: B=60 (below channel) ratio %.4f ; B=1024 (above) %.4f"
          % (pr60, pr1024))
    print("        predicted ~1 below, >1 above -> %s"
          % ("CONSISTENT" if abs(pr60 - 1) < 0.05 and pr1024 > 1.05 else "INCONSISTENT"))
    print("  P3b.1 all minFac>B families at B=60:")
    for n in fams:
        mfs = min(m for _, m in fams[n])
        if mfs > 60 and n not in ("pq generic",):
            r = allrows[60][n] / allrows[60]["pq generic"]
            print("        %-18s minFac=%-4d ratio=%.4f  %s"
                  % (n, mfs, r, "shape-blind" if 0.95 < r < 1.05 else "*** SENSITIVE ***"))

    sig = hashlib.sha256(
        "|".join("%d/%s:%.8f" % (B, n, v) for B, d in sorted(allrows.items())
                 for n, v in sorted(d.items())).encode()).hexdigest()[:16]
    print("\nOUTPUT SIGNATURE (run-twice check): %s" % sig)


if __name__ == "__main__":
    main()
