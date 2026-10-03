#!/usr/bin/env python3
"""
V1b: THE PARITY CONTROL -- isolating whether E-7's advantage is arithmetic or structure.

The decisive observation: for q = 3 mod 4 PRIME, h(-q) is ALWAYS ODD
(Selmer: class group of Q(sqrt(-q)) has odd order for prime discriminant).
Verified in selftest: 20/20.

An EC order #E(F_p) is EVEN with probability ~1/2 (Deuring; measured 71% in the
tight test above).

So the E-7 comparison "P(class number is B-smooth) vs P(EC order is B-smooth)"
is not comparing two like objects: one arm is a sample from the ODD integers
and the other is a sample from ALL integers. An odd integer of L bits has no
factor of 2, so at the same B it is strictly more likely to be smooth. That is
arithmetic bookkeeping, not a distributional property of class groups.

This script measures:
  A  uniform integers at L bits          (the NULL: no algebraic structure)
  B  uniform ODD integers at L bits     (the PARITY baseline)
  C  h(-q), q = 3 mod 4 prime           (E-7's actual arm)
  D  #E(F_p)                            (E-7's EC arm)

If C ~ B, the "advantage" is PARITY and there is no class-group magic.
If C >> B, there is genuine structure beyond parity and E-7's direction lives.
"""
import math, random, time
from e7_audit import P, is_smooth, oddpart, fisher_two_sided, wilson

def rand_in_band(L, rng):
    return rng.randrange(1 << L, 1 << (L + 1))

def rand_odd_in_band(L, rng):
    v = rand_in_band(L, rng) | 1
    if v < (1 << L):
        v += 1 << L
    return v

def main(L=29, N=4000, seed=99):
    rng = random.Random(seed)
    us = [1.5, 2.0, 2.5, 3.0]
    A = [rand_in_band(L, rng) for _ in range(N)]
    B = [rand_odd_in_band(L, rng) for _ in range(N)]
    # EC orders: sample real curves at L-bit p
    D = []
    t0 = time.time()
    while len(D) < N and time.time() - t0 < 240:
        p = rng.randrange(1 << L, 1 << (L + 1)) | 1
        if p < 3 or not P.isprime(p):
            continue
        a = rng.randrange(0, p); b = rng.randrange(0, p)
        if (4 * a * a * a + 27 * b * b) % p == 0:
            continue
        D.append(int(P.ellcard(P.ellinit([0, 0, 0, a, b], p))))
    # class numbers (slow: ~1.4/s). Use a smaller n for this arm.
    NC = max(30, N // 12)
    C = []
    t0 = time.time()
    while len(C) < NC and time.time() - t0 < 240:
        qlo = int(4 * (1 << L) ** 2) + 11
        qhi = int(4 * (1 << (L + 1)) ** 2) + 11
        q = rng.randrange(qlo, qhi) | 1
        if q % 4 != 3:
            q += 2
        if not P.isprime(q):
            continue
        h = int(P.qfbclassno(-q))
        if (1 << L) <= h < (1 << (L + 1)):
            C.append(h)

    print(f"L={L} bits | A(uniform)={len(A)} B(odd)={len(B)} "
          f"D(EC)={len(D)} C(class)={len(C)}")
    print(f"  parity: EC even {sum(1 for x in D if x%2==0)}/{len(D)}, "
          f"class odd {sum(1 for x in C if x%2==1)}/{len(C)}")
    print()
    hdr = f"{'u':>5} | {'A unif':>9} {'B odd':>9} {'D EC':>9} {'C class':>9} | {'C/B':>6} {'C/D':>6}"
    print(hdr); print("-" * len(hdr))
    for u in us:
        def rate(xs):
            k = 0
            for x in xs:
                Bb = max(2, int(round(math.pow(x, 1.0 / u))))
                k += is_smooth(x, Bb)
            return k, len(xs), k / len(xs) if xs else 0.0
        ka, na, ra = rate(A)
        kb, nb, rb = rate(B)
        kd, nd, rd = rate(D)
        kc, nc, rc = rate(C)
        print(f"{u:>5} | {ra:>9.3f} {rb:>9.3f} {rd:>9.3f} {rc:>9.3f} | "
              f"{rc/rb if rb else 0:>6.2f} {rc/rd if rd else 0:>6.2f}")
    print()
    print(f"  Fisher C vs B (class vs ODD baseline): p = {fisher_two_sided(kc, nc, kb, nb):.4f}")
    print(f"  Wilson C: {tuple(round(x,4) for x in wilson(kc, nc))}")
    print(f"  Wilson B: {tuple(round(x,4) for x in wilson(kb, nb))}")
    print(f"  Wilson D: {tuple(round(x,4) for x in wilson(kd, nd))}")

if __name__ == "__main__":
    import sys
    L = int(sys.argv[1]) if len(sys.argv) > 1 else 29
    main(L)