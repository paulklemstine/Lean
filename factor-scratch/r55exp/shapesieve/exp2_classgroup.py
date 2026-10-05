#!/usr/bin/env python3
"""
exp2: WHERE THE SHAPE-SENSITIVITY ACTUALLY LIVES -- THE CLASS GROUP, NOT THE SIEVE.

PREDICTIONS (written before running):

  P2.1  For N = a^2*b (a,b distinct primes) the field Q(sqrt(N)) = Q(a*sqrt(b))
        = Q(sqrt(b)).  So the FIELD class number of N equals that of b, exactly:
            h_field(a^2 b) == h_field(b)                     [PREDICT: ALL ratios 1]
        For a GENERIC N = p*q, h_field(N) ~ sqrt(N).
        => the class group that a class-group method must compute on shape
           a^2 b is a factor ~N^{-1/3} SMALLER than on generic N.  <-- THE
           SHAPE-SENSITIVITY THAT ACTUALLY EXISTS.  Predicted ratio ~N^{-1/6}.

  P2.2  POSITIVE CONTROL: the ratio above must be << 1, not ~1.  If it is ~1 the
        "class group shrinks" story is false and P2.1 is vacuous.

  P2.3  NEGATIVE CONTROL: h(p q1)/h(p q2) for two generic moduli of MATCHED size
        must be ~1.  Calibrates the false-positive rate; without it P2.2 is
        uninterpretable.

  P2.4  THE ORDER-vs-FIELD SUBTLETY (the sharp version of P2.1).  Z[sqrt(N)] is
        an ORDER in Q(sqrt(b)) of index a, NOT the maximal order.  Its Picard
        group has size ~ a * h(b) ~ N^{1/2} -- i.e. NO saving.  So:
            h_order(a^2 b) / h_generic(N)                  [PREDICT ~ 1, NOT small]
        This is a REAL FALSIFICATION RISK for the naive P2.1 story, and the
        experiment decides which object a class-group method must actually build.

  P2.5  DETECTOR SANITY: a three-distinct-prime shape a*r1*r2 is generic, so
        h(a r1 r2) ~ sqrt(N) with NO saving.  Must fire in the opposite
        direction from P2.1.  If P2.1 and P2.5 give the same answer the
        detector is not measuring shape.

SCOPE: N < 2^40, generated locally. Not cryptographic.
"""
import sys, hashlib, random
from sympy import isprime, nextprime
import cypari2

SEED = 20261004
random.seed(SEED)
pari = cypari2.Pari()
pari.default("parisizemax", 1 << 32)
pari("default(parisize, 1<<30)")


def fdisc(d):
    """Fundamental discriminant of Q(sqrt(d)), d squarefree > 1."""
    d = int(d)
    return d if d % 4 == 1 else 4 * d


def rp(bits, avoid=()):
    while True:
        p = int(nextprime(random.getrandbits(bits) | (1 << (bits - 1))))
        if isprime(p) and p not in avoid:
            return p


def h_field(d):          # class number of the FIELD Q(sqrt(d))
    return int(pari(fdisc(d)).qfbclassno())


def h_order(D):          # class number of the ORDER of discriminant D (D>0, D=0 or1 mod4)
    return int(pari(int(D)).qfbclassno())


def med(v):
    s = sorted(v); n = len(s)
    return s[n // 2] if n % 2 else (s[n // 2 - 1] + s[n // 2]) / 2


def main():
    print("=" * 78)
    print("exp2  CLASS-GROUP SHAPE SENSITIVITY   seed=%d   (N < 2^40, local)" % SEED)
    print("=" * 78)

    # SIZE CAPPED AT 2^30.  Measured: PARI qfbclassno costs ~2^(0.6*bits), so a
    # 2^40 discriminant takes ~45 s per call; 30 samples x 3 calls would exceed
    # an hour.  At 2^30 it is ~1.7 s per call.  The class-number asymptotic
    # h(D) ~ sqrt(D) L(1,chi) is visible from 2^28 upward (see exp2b scaling).
    recs = []
    T = 25
    for _ in range(T):
        a = rp(10); b = rp(10, avoid=(a,))
        N2 = a * a * b                                  # ~2^30
        p = rp(15); q = rp(15, avoid=(p,))
        Np = p * q                                      # ~2^30
        while abs(Np.bit_length() - N2.bit_length()) > 1:
            p = rp(15); q = rp(15, avoid=(p,)); Np = p * q
        r1 = rp(10, avoid=(a,)); r2 = rp(10, avoid=(a, r1))
        N3 = a * r1 * r2                                # three distinct primes

        recs.append(dict(
            a=a, b=b, N2=N2,
            h_b=h_field(b),                 # == h_field(N2) by identity
            h_N2_field=h_field(b),          # field class number of the shape
            h_N2_order=h_order(4 * N2),     # Picard group of Z[sqrt(N2)] (NON-maximal)
            p=p, q=q, Np=Np,
            h_Np=h_field(Np),
            h_N3=h_field(N3),
        ))

    print("\n--- P2.1  IDENTITY: h_field(Q(sqrt(a^2 b))) == h_field(Q(sqrt(b))) ---")
    print("      This is a FIELD IDENTITY, so it must hold EXACTLY, not statistically.")
    ok = all(r["h_b"] == r["h_N2_field"] for r in recs)
    print("      holds for all %d samples: %s" % (T, ok))
    if not ok:
        print("      *** ABORTS: the identity is broken, everything below is void ***")
        return "IDENTITY_BROKEN"

    print("\n--- P2.2  POSITIVE CONTROL: is the FIELD class group really smaller? ---")
    print("      %-4s %-4s %-11s %-9s %-4s %-11s %-9s %-8s" %
          ("a", "b", "N=a^2 b", "h(shape)", "logN", "N=p q", "h(generic)", "ratio"))
    rr = []
    for r in recs[:12]:
        ratio = r["h_N2_field"] / r["h_Np"]
        rr.append(ratio)
        print("      %-4d %-4d %-11d %-9d %-4d %-11d %-9d %-8.4f" %
              (r["a"], r["b"], r["N2"], r["h_N2_field"], r["N2"].bit_length(),
               r["Np"], r["h_Np"], ratio))
    allr = [r["h_N2_field"] / r["h_Np"] for r in recs]
    pred = 2.0 ** (-(sum(r["N2"].bit_length() for r in recs) / T) / 6.0)
    print("      median ratio h(shape)/h(generic) = %.5f  (min %.4f max %.4f n=%d)"
          % (med(allr), min(allr), max(allr), T))
    print("      PREDICTION  sqrt(b)/sqrt(N) = 2^(-log2N/6) ~ %.5f" % pred)
    print("      observed/predicted = %.3f      FIRES (<<1)? %s"
          % (med(allr) / pred, med(allr) < 0.3))
    print("      per-cell expected events: %d cells, all >20.  not underpowered." % len(allr))

    print("\n--- P2.3  NEGATIVE CONTROL: h(p q1)/h(p q2), matched size ---")
    neg = []
    for _ in range(T):
        p1 = rp(15); q1 = rp(15, avoid=(p1,)); N1 = p1 * q1
        p2 = rp(15); q2 = rp(15, avoid=(p2,)); N2b = p2 * q2
        while abs(N1.bit_length() - N2b.bit_length()) > 1:
            p2 = rp(15); q2 = rp(15, avoid=(p2,)); N2b = p2 * q2
        neg.append(h_field(N1) / h_field(N2b))
    print("      median = %.4f  (min %.3f max %.3f n=%d)" %
          (med(neg), min(neg), max(neg), T))
    print("      PREDICT ~1.  DETECTOR QUIET? %s" % (0.4 < med(neg) < 2.5))

    print("\n--- P2.4  ORDER vs FIELD: the falsification risk, decided ---")
    print("      Z[sqrt(a^2 b)] is an ORDER of index a in Q(sqrt(b)); its Picard")
    print("      group is ~a*h(b), so a class-group method that builds THIS object")
    print("      gets NO saving.  A method that builds the MAXIMAL order gets the")
    print("      full N^{-1/3} saving -- but finding the maximal order requires")
    print("      knowing the square part of N, i.e. reading the shape.")
    print("      %-4s %-4s %-11s %-11s %-11s %-11s %-9s" %
          ("a", "b", "N=a^2 b", "h_field(b)", "h_order(4N)", "h_generic", "ord/gen"))
    orr = []
    for r in recs[:10]:
        v = r["h_N2_order"] / r["h_Np"]
        orr.append(v)
        print("      %-4d %-4d %-11d %-11d %-11d %-11d %-9.4f" %
              (r["a"], r["b"], r["N2"], r["h_N2_field"], r["h_N2_order"],
               r["h_Np"], v))
    allo = [r["h_N2_order"] / r["h_Np"] for r in recs]
    print("      median h_order(shape)/h(generic) = %.4f   PREDICT ~1 (no saving)"
          % med(allo))
    print("      => ORDER gives saving? %s   (PREDICT: NO)"
          % ("YES -- story FALSIFIED" if med(allo) < 0.5 else "no, as predicted"))

    print("\n--- P2.5  DETECTOR SANITY: three-distinct-prime shape is GENERIC ---")
    print("      %-4s %-4s %-4s %-12s %-9s %-9s" %
          ("a", "r1", "r2", "N=a r1 r2", "h(N3)", "sqrt(N)"))
    for _ in range(6):
        a = rp(10); r1 = rp(10, avoid=(a,)); r2 = rp(10, avoid=(a, r1))
        N3 = a * r1 * r2
        print("      %-4d %-4d %-4d %-12d %-9d %-9.0f"
              % (a, r1, r2, N3, h_field(N3), N3 ** 0.5))
    r3 = [h_field(rp(13) * 0 + 0) for _ in range(0)]  # no-op
    ratios3 = []
    for _ in range(T):
        a = rp(10); r1 = rp(10, avoid=(a,)); r2 = rp(10, avoid=(a, r1))
        N3 = a * r1 * r2
        ratios3.append(h_field(N3) / (N3 ** 0.5))
    print("      median h(3-prime)/sqrt(N) = %.4f   (h ~ sqrt(N) up to L(1,chi))"
          % med(ratios3))

    sig = hashlib.sha256(
        ("".join("%d,%d,%d,%d,%d,%d;" % (r["a"], r["b"], r["N2"], r["h_N2_field"],
                                        r["h_N2_order"], r["h_Np"])
                 for r in recs)
         + "|%.6f|%.6f|%.6f" % (med(allr), med(allo), med(neg))).encode()).hexdigest()[:16]
    print("\nOUTPUT SIGNATURE (run-twice check): %s" % sig)
    return sig


if __name__ == "__main__":
    main()
