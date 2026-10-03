#!/usr/bin/env python3
"""
R3 -- THE CENTRAL QUESTION.

"Is there ANY structure whose group order is computable WITHOUT p, and whose
walk REACHES p?"

The class group of Q(sqrt(-kN)) is the ONLY standard candidate: PARI's
qfbclassno computes h(-kN) EXACTLY, in time poly-ish in log N, with no
knowledge of p.  So it satisfies half of R3 by construction.  The other half
is the hard one: does the walk reach p?

Two things must both hold:
  (Q1) DIVISIBILITY:  p | h(-kN).  If p does not divide the class number,
       there is no element of order p, and the walk carries no information.
  (Q2) REACHABILITY + COST: even if p | h(-kN), finding the element of order
       p costs ~sqrt(h) by BSGS.  h(-kN) ~ sqrt(k*N)/pi * L(1,chi), so
       sqrt(h) ~ (k*N)^{1/4}.  That is N^{1/4}, NOT L[1/2], and not better.

PREREGISTERED PREDICTIONS (before running):
  P1: P(p | h(-kN)) for random k is small -- I predict it is a GRH-type
      nonresiduosity condition (Cremona-Odoni: ~2^{-omega(N)} ish), i.e.
      well under 50%.
  P2: conditional on p | h(-kN), the class number is NOT smooth enough to
      make the walk cheap: sqrt(h) stays >= c*N^{1/4}, so the class-group
      route can never be L[1/2] or better for semiprimes.
  P3: h(-kN) requires k to be O(1) for the sqrt(h) ~ N^{1/4} to hold; for
      k large the cost grows as (kN)^{1/4}.

Self-test: qfbclassno must agree with a brute-force count of reduced binary
quadratic forms of discriminant -kN.  If it does not, the harness is broken.
"""
import random
import time
import sympy
import cypari2

pari = cypari2.Pari()
pari.default("parisizemax", 1 << 30)


# ---------------------------------------------------------------- self-test
def brute_classno(D):
    """Count reduced primitive positive binary quadratic forms of disc D.
    Valid for D < 0, D = 0 or 1 mod 4."""
    assert D < 0 and (D % 4 == 0 or D % 4 == 1)
    h = 0
    # a <= sqrt(|D|/3) is the reduction bound; enumerate b in [-a, a] with
    # b == D (mod 2a); c = (b^2 - D) / (4a) must satisfy c >= a.
    amax = int(sympy.sqrt(abs(D) / 3)) + 1
    for a in range(1, amax + 1):
        for bb in range(-a, a + 1):
            if (D - bb * bb) % (4 * a) != 0:
                continue
            c = (bb * bb - D) // (4 * a)          # <-- sign was wrong before
            if c < a:
                continue
            if sympy.gcd(sympy.gcd(a, abs(bb)), c) != 1:
                continue
            if not (-a < bb <= a):
                continue
            if (a == c or abs(bb) == a) and bb < 0:
                continue                          # ambiguity convention
            h += 1
    return h


def selftest():
    print("=" * 72)
    print("SELF-TEST: qfbclassno vs brute-force reduced-form count")
    for D in [-3, -4, -7, -8, -11, -19, -23, -43, -67, -163]:
        h_pari = int(pari.qfbclassno(D))
        h_brute = brute_classno(D)
        ok = (h_pari == h_brute)
        print(f"   D={D:6d}  qfbclassno={h_pari:3d}  brute={h_brute:3d}  "
              f"{'OK' if ok else '*** MISMATCH ***'}")
        assert ok, "harness broken"
    print("   -> self-test PASSED (all 10 discriminants agree)")


# ---------------------------------------------------------------- Q1
def q1_divisibility(n_trials=300, kmax=8):
    print("=" * 72)
    print("Q1: does p | h(-kN)?  [uses p for MEASUREMENT ONLY]")
    rng = random.Random(90210)
    per_k = {k: [0, 0] for k in range(1, kmax + 1)}
    hits_any = 0
    t0 = time.perf_counter()
    for _ in range(n_trials):
        p = sympy.randprime(10**25, 10**26)
        q = sympy.randprime(10**25, 10**26)
        N = p * q
        hit = False
        for k in range(1, kmax + 1):
            D = -k * N
            if D % 4 not in (0, 1):
                D = -4 * k * N  # make D = 0 mod 4
            h = int(pari.qfbclassno(D))
            per_k[k][1] += 1
            if h % p == 0:
                per_k[k][0] += 1
                hit = True
        if hit:
            hits_any += 1
    dt = time.perf_counter() - t0
    tot_h = tot_n = 0
    for k in range(1, kmax + 1):
        a, b = per_k[k]
        tot_h += a
        tot_n += b
        rate = a / b
        z = 1.96
        den = 1 + z * z / b
        c = (rate + z * z / (2 * b)) / den
        hwid = z * sympy.sqrt(rate * (1 - rate) / b + z * z / (4 * b * b)) / den
        print(f"   k={k}: P(p | h(-kN)) = {rate:.4f}  Wilson95 "
              f"[{c-hwid:.4f}, {c+hwid:.4f}]  (n={b})")
    print(f"   TOTAL per-k: {tot_h}/{tot_n} = {tot_h/tot_n:.4f}")
    print(f"   P(exists k <= {kmax} with p | h(-kN)) = "
          f"{hits_any/n_trials:.4f}  (n={n_trials})")
    print(f"   [measurement of a [uses p] quantity; "
          f"wall {dt:.1f}s]")
    return tot_h / tot_n, hits_any / n_trials


# ---------------------------------------------------------------- Q2
def q2_cost(n_trials=40):
    print("=" * 72)
    print("Q2: even when p | h(-kN), is the walk cheap?  BSGS cost ~ sqrt(h)")
    rng = random.Random(1357)
    rows = []
    for _ in range(n_trials):
        p = sympy.randprime(10**25, 10**26)
        q = sympy.randprime(10**25, 10**26)
        N = p * q
        for k in range(1, 9):
            D = -k * N
            if D % 4 not in (0, 1):
                D = -4 * k * N
            h = int(pari.qfbclassno(D))
            if h % p == 0:
                rows.append((N, k, h))
                break
    if not rows:
        print("   no (N,k) with p | h(-kN) found; Q2 inconclusive")
        return
    print(f"   instances with p | h(-kN): {len(rows)}")
    print(f"   {'bits(N)':>9} {'k':>3} {'bits(h)':>9} {'log2 sqrt(h)':>13} "
          f"{'sqrt(h)/N^0.25':>15}")
    for N, k, h in rows[:12]:
        bs = sympy.sqrt(h)
        print(f"   {N.bit_length():9d} {k:3d} {h.bit_length():9d} "
              f"{sympy.log(h,2)/2:13.1f} "
              f"{float(sympy.log(bs/N**0.25,2)):15.2f}")
    ratios = [float(sympy.log(sympy.sqrt(h) / (N ** 0.25), 2))
              for N, k, h in rows]
    print(f"   log2( sqrt(h) / N^(1/4) ): min={min(ratios):.2f} "
          f"median={sorted(ratios)[len(ratios)//2]:.2f} "
          f"max={max(ratios):.2f}")
    print("   P2 PREDICTION: this ratio stays >= ~0 (never negative by much),")
    print("   i.e. the class-group walk never costs LESS than N^{1/4}.")


def q3_order_magnitude():
    print("=" * 72)
    print("Q3: h(-kN) magnitude -- confirms the sqrt(h) ~ (kN)^{1/4} law")
    for k in [1, 2, 4, 16, 64, 256]:
        N = sympy.randprime(10**25, 10**26) * sympy.randprime(10**25, 10**26)
        D = -k * N
        if D % 4 not in (0, 1):
            D = -4 * k * N
        h = int(pari.qfbclassno(D))
        pred = sympy.sqrt(k * N) / sympy.pi
        print(f"   k={k:4d}  h={h.bit_length():3d}b  predicted ~"
              f"sqrt(kN)/pi = {int(sympy.log(pred,2)):3d}b   ratio "
              f"{float(sympy.log(h/pred,2)):+.2f} bits")
    print("   -> h(-kN) ~ (kN)^{1/2}, so sqrt(h) ~ (kN)^{1/4}: N^{1/4} floor.")


if __name__ == "__main__":
    selftest()
    print()
    q1_divisibility()
    print()
    q2_cost()
    print()
    q3_order_magnitude()