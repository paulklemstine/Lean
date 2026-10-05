#!/usr/bin/env python3
"""
exp3: THE MEASURED SHAPE-SENSITIVITY THRESHOLD.
      A sieving primitive IS shape-sensitive -- but IFF minFac(N) <= B,
      and in exactly that regime trial division / rho already wins by more.

FIXED after the first version hung: N < 2^22, M = 60000, B in {60,256,1024}.
M^2 = 3.6e9 >> 2^22 so u^2 mod N genuinely wraps.

THE CHAIN OF REASONING (exp1 -> exp1b -> exp3):

  exp1  was vacuous (M^2 < N, so N never entered). Caught by its own control.
  exp1b fixed that. It found leg-1 (crossing off) shape-blindness is EXACT:
        q | (u^2 mod N)  <=>  q | u   whenever q | N; density ~1/q otherwise.
        So the crossing-off density is 1/q for every prime, every shape.
  exp1b's positive control MISFIRED at B=4096 even for N = 25*m. That was not a
  bug: leg 1 is provably shape-blind, so no control on leg 1 can fire.
  exp3 therefore measures LEG 2 -- SMOOTHNESS, which is the leg that actually
  sets cost per relation, because rho(u) depends on |g(u)| MAGNITUDE.

  THE POSITIVE CONTROL THAT FIRES:
  If N carries a small prime power, u^2 mod N collapses onto a tiny set of
  small values and the B-smooth rate EXPLODES. For N = 5^4 * m = 625*m the
  values u^2 mod 625 take only ~O(625^{1/2}) distinct small magnitudes, most
  of them << 2^22 and hence B-smooth for B = 1024. Ratio vs generic: > 10.

  THE THRESHOLD PREDICTION: firing begins at B ~ minFac(N) and not before.

  WHY THIS CLOSES THE LEAD. A sieve is shape-sensitive exactly when
  minFac(N) <= B. But that is the regime where B >= minFac(N), and the cost of
  the sieve is at least the cost of marking M candidates against pi(B) primes
  with B >= minFac(N) -- while Pollard rho costs sqrt(minFac(N)) < B. So the
  shape-aware sieve is strictly more expensive than the shape-aware method
  that already exists. The shape channel is real AND already occupied.

PREDICTIONS (written before running):

  P3.1  minFac(N) > B  =>  B-smooth rate identical across all shapes, to
        within Poisson error.  (THE CLOSURE.)
  P3.2  POSITIVE CONTROL FIRES: minFac(N)=5 family must show ratio >= 3 at
        B = 1024. If it does not, the detector is vacuous and P3.1 is void.
  P3.3  NEGATIVE CONTROL: two generic batches agree.
  P3.4  THRESHOLD: for a family with minFac(N) = 61, the ratio must be ~1 at
        B = 60 and rise by B = 1024. Measures where the channel opens.
  P3.5  Per-cell, never pooled; expected hits reported; < 20 => UNDERPOWERED.

SCOPE: all N < 2^22, generated locally. Not cryptographic.
"""
import sys, hashlib, random
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


def smooth_flags(N, B):
    """bytearray flag[v]=1 iff v is B-smooth, for v < N.  Enumerated by
    multiplicative closure over primes <= B.  Bounded by a hard cap so the
    first version's hang cannot recur."""
    primes = [q for q in primerange(2, B + 1) if q < N]
    flag = bytearray(N)
    flag[1] = 1
    frontier = [1]
    for q in primes:
        new = []
        for v in frontier:
            w = v
            while w < N:
                w *= q
                if w >= N:
                    break
                if not flag[w]:
                    flag[w] = 1
                    new.append(w)
        frontier.extend(new)
        if len(frontier) > 3_000_000:
            raise RuntimeError("smooth set too large: N=%d B=%d" % (N, B))
    return flag


def smooth_rate(N, B, flag):
    """Fraction of u in [0,M) with (u^2 mod N) B-smooth.  u=0 gives g=0; treat
    0 as smooth-by-convention (it is never a relation) -- EXCLUDED explicitly so
    the statistic is honest."""
    c = 0
    for u in range(1, M):
        if flag[(u * u) % N]:
            c += 1
    return c / (M - 1)


def build():
    fams = {}
    fams["pq generic"] = []
    while len(fams["pq generic"]) < 10:
        p = rp(11); q = rp(11, avoid=(p,))
        N = p * q
        if NMAX // 4 <= N < NMAX:
            fams["pq generic"].append((N, min(p, q)))
    fams["NEG CTRL pq'"] = []
    while len(fams["NEG CTRL pq'"]) < 10:
        p = rp(11); q = rp(11, avoid=(p,))
        N = p * q
        if NMAX // 4 <= N < NMAX:
            fams["NEG CTRL pq'"].append((N, min(p, q)))
    fams["a^2 b (a~2^5)"] = []
    while len(fams["a^2 b (a~2^5)"]) < 10:
        a = rp(6); b = rp(16, avoid=(a,))
        N = a * a * b
        if NMAX // 4 <= N < NMAX:
            fams["a^2 b (a~2^5)"].append((N, a))
    fams["a^4 b (a~2^4)"] = []
    while len(fams["a^4 b (a~2^4)"]) < 10:
        a = rp(5); b = rp(17, avoid=(a,))
        N = a ** 4 * b
        if NMAX // 4 <= N < NMAX:
            fams["a^4 b (a~2^4)"].append((N, a))
    # POSITIVE CONTROLS: minFac(N) small
    fams["POS CTRL a=5"] = []
    while len(fams["POS CTRL a=5"]) < 10:
        b = rp(17, avoid=(5,)); N = 25 * b
        if NMAX // 4 <= N < NMAX:
            fams["POS CTRL a=5"].append((N, 5))
    fams["POS CTRL a=7"] = []
    while len(fams["POS CTRL a=7"]) < 10:
        b = rp(16, avoid=(7,)); N = 49 * b
        if NMAX // 4 <= N < NMAX:
            fams["POS CTRL a=7"].append((N, 7))
    # P3.4 threshold probe: minFac = 61, so B=60 is JUST BELOW and B=1024 above
    fams["PROBE minFac=61"] = []
    while len(fams["PROBE minFac=61"]) < 10:
        a = 61; b = rp(16, avoid=(a,)); N = a * b
        if NMAX // 4 <= N < NMAX:
            fams["PROBE minFac=61"].append((N, a))
    for k, v in fams.items():
        assert v, k
        assert all(NMAX // 4 <= N < NMAX for N, _ in v), k
    return fams


def main():
    print("=" * 78)
    print("exp3  MEASURED SHAPE-SENSITIVITY THRESHOLD   seed=%d" % SEED)
    print("       N in [%d, %d), M = %d, M^2/N = %.0f -> wraps"
          % (NMAX // 4, NMAX, M, (M * M) / (NMAX / 4)))
    print("       all moduli generated locally; none is of cryptographic interest")
    print("=" * 78)

    fams = build()
    print("\nFamily inventory (per family: 10 moduli, minFac recorded)")
    for k, v in fams.items():
        mfs = sorted(set(m for _, m in v))
        print("   %-18s minFac in %s   N bits %d..%d"
              % (k, mfs[:4], min(N.bit_length() for N, _ in v),
                 max(N.bit_length() for N, _ in v)))

    allrows = {}
    for B in (60, 256, 1024):
        flag = smooth_flags(NMAX, B)
        print("\n" + "=" * 74)
        print("B = %-5d   %d of %d values below 2^22 are B-smooth (%.2f%%)"
              % (B, sum(flag), NMAX, 100.0 * sum(flag) / NMAX))
        print("  %-18s %-8s %-9s %-9s %-9s %-10s" %
              ("family", "minFac", "median", "min", "max", "exp hits"))
        rates = {}
        for name, lst in fams.items():
            rr = [smooth_rate(N, B, flag) for N, _ in lst]
            rates[name] = rr
            mu = sum(rr) / len(rr)
            mfs = min(m for _, m in lst)
            eh = mu * (M - 1)
            tag = "  UNDERPOWERED(<20)" if eh < 20 else ""
            print("  %-18s %-8d %-9.5f %-9.5f %-9.5f %-10.0f%s"
                  % (name, mfs, med(rr), min(rr), max(rr), eh, tag))
            print("  %-18s cells: %s" % ("", " ".join("%.4f" % x for x in rr)))
        g = med(rates["pq generic"])
        allrows[B] = {k: med(v) for k, v in rates.items()}
        print("  " + "-" * 70)
        print("  %-18s %-8s %-9s %-22s" % ("family", "ratio", "channel", "verdict"))
        for name in fams:
            r = med(rates[name]) / g
            mfs = min(m for _, m in fams[name])
            opened = mfs <= B
            if name == "pq generic":
                print("  %-18s %-8.4f %-9s %-22s" % (name, r, "-", "(reference)"))
                continue
            if not opened:
                v = "shape-blind [minFac>B]"
            elif r > 1.05:
                v = "SHAPE-SENSITIVE [minFac<=B]"
            else:
                v = "channel OPEN but quiet"
            print("  %-18s %-8.4f %-9s %-22s%s"
                  % (name, r, "OPEN" if opened else "CLOSED", v,
                     "   <== FIRES" if r > 1.05 else ""))

    print("\n" + "=" * 74)
    print("VERDICT TABLE  (ratio of median B-smooth rate to generic pq)")
    names = list(fams)
    print("  %-18s %-10s %-10s %-10s %-12s" %
          ("family", "minFac", "B=60", "B=256", "B=1024"))
    for n in names:
        mfs = min(m for _, m in fams[n])
        print("  %-18s %-10d %-10.4f %-10.4f %-12.4f"
              % (n, mfs, allrows[60][n] / allrows[60]["pq generic"],
                 allrows[256][n] / allrows[256]["pq generic"],
                 allrows[1024][n] / allrows[1024]["pq generic"]))

    print("\nPREDICTION CHECKS")
    pc5 = allrows[1024]["POS CTRL a=5"] / allrows[1024]["pq generic"]
    pc7 = allrows[1024]["POS CTRL a=7"] / allrows[1024]["pq generic"]
    print("  P3.2 POS CTRL a=5 ratio at B=1024: %.4f  -> FIRES(>=3)? %s"
          % (pc5, "YES" if pc5 >= 3 else "NO -- VACUOUS DETECTOR"))
    print("       POS CTRL a=7 ratio at B=1024: %.4f" % pc7)
    nc = allrows[1024]["NEG CTRL pq'"] / allrows[1024]["pq generic"]
    print("  P3.3 NEG CTRL ratio: %.4f -> QUIET? %s" % (nc, "YES" if 0.95 < nc < 1.05 else "NO"))
    pr60 = allrows[60]["PROBE minFac=61"] / allrows[60]["pq generic"]
    pr1024 = allrows[1024]["PROBE minFac=61"] / allrows[1024]["pq generic"]
    print("  P3.4 PROBE minFac=61: ratio at B=60 (below) = %.4f ; at B=1024 (above) = %.4f"
          % (pr60, pr1024))
    print("       predicted: ~1 below, >1 above. Observed: %s"
          % ("CONSISTENT" if abs(pr60 - 1) < 0.05 and pr1024 > 1.05 else "INCONSISTENT"))

    sig = hashlib.sha256(
        "|".join("%s:%.8f" % (k, v) for k, v in sorted(
            (str(B) + "/" + n, v) for B, d in allrows.items() for n, v in d.items())
        ).encode()).hexdigest()[:16]
    print("\nOUTPUT SIGNATURE (run-twice check): %s" % sig)


if __name__ == "__main__":
    main()
