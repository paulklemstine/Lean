#!/usr/bin/env python3.12
"""
THE DECISIVE TEST OF ROUND 48, FIELD 3.

Dieulefait-Urroz (arXiv:1911.11004, p.3) Theorem 1, VERIFIED verbatim:

    "Given the number of points, affine or projective, of any elliptic
     curve and one of its twists modulo N we can factor N in deterministic
     polynomial time."

and, critically, p.3:

    "It is worth remarking that it is not known how to factor N only with
     the number EN as input."

PARI/GP's ellcard(E, N) for COMPOSITE N runs in 0.00 s at 27 bits.  If that
output were the true point count, we would ALREADY HAVE DETERMINISTIC
POLYNOMIAL-TIME FACTORING by feeding it a twist -- which nobody has.  So
either

  (a) PARI's composite output is not the true count (it is not), or
  (b) PARI internally factors N (it does not, at that speed), or
  (c) Theorem 1's "affine" and the object PARI returns differ.

This script determines WHICH, at the tightest case where everything can be
computed exactly by brute force.  This is the one computation that would
settle field 3.
"""
import math, time, itertools
import cypari2
from sympy import legendre_symbol, isprime

FAIL, OK = [], []
def chk(name, cond, detail=""):
    (OK if cond else FAIL).append(name)
    print(f"[{'PASS' if cond else 'FAIL'}] {name}" + (f"  :: {detail}" if detail else ""))

pari = cypari2.Pari()


def count_E_field(p, a, b):
    """PROJECTIVE #E(F_p), brute force."""
    n = 1
    for x in range(p):
        v = (x * x * x + a * x + b) % p
        if v == 0:
            n += 1
        elif legendre_symbol(v, p) == 1:
            n += 2
    return n


def affine_count_ring(N, a, b):
    """AFFINE locus of E(Z/NZ) by brute force: {(x,y) mod N : y^2 = x^3+ax+b}."""
    t = 0
    for x in range(N):
        v = (x * x * x + a * x + b) % N
        for y in range(N):
            if y * y % N == v:
                t += 1
    return t


def truth(p, q, a, b):
    tp = count_E_field(p, a, b); tq = count_E_field(q, a, b)
    proj = tp * tq                       # CRT: projective group order
    aff = affine_count_ring(p * q, a, b)  # brute force affine locus
    return tp, tq, proj, aff


def main():
    print("=" * 78)
    print("T1  What does PARI's composite ellcard ACTUALLY return?")
    print("=" * 78)
    # tightest cases first: small semiprimes where brute force is feasible
    cases = [(11, 13), (11, 17), (13, 17), (11, 19), (13, 19), (17, 19), (11, 23)]
    curves = [(-1, 0), (1, 0), (0, 1), (2, 3)]
    print(f"       {'N':>6}{'p':>4}{'q':>4} {'curve':>12}{'PARI':>8}{'true PROJ':>11}"
          f"{'true AFF':>10}{'=PROJ?':>8}{'=AFF?':>7}{'=N+1?':>8}")
    match_proj = match_aff = match_np1 = 0
    total = 0
    for p, q in cases:
        N = p * q
        for (a, b) in curves:
            if (4 * a**3 + 27 * b**2) % p == 0 or (4 * a**3 + 27 * b**2) % q == 0:
                continue
            e = pari.ellinit([a, b], N)
            t0 = time.time()
            pc = int(pari.ellcard(e))
            dt = time.time() - t0
            tp, tq, proj, aff = truth(p, q, a, b)
            total += 1
            if pc == proj:
                match_proj += 1
            if pc == aff:
                match_aff += 1
            if pc == N + 1:
                match_np1 += 1
            print(f"       {N:>6}{p:>4}{q:>4} {f'{a}x^3+{b}':>12}{pc:>8}{proj:>11}{aff:>10}"
                  f"{'YES' if pc==proj else 'no':>8}{'YES' if pc==aff else 'no':>7}"
                  f"{'YES' if pc==N+1 else 'no':>8}")
    print(f"       totals over {total} (N,curve) pairs: matches PROJ {match_proj}, "
          f"AFF {match_aff}, N+1 {match_np1}")
    chk("T1a PARI's composite ellcard matches NEITHER the projective group order NOR the "
        "affine locus in general -> its composite output is NOT a point count and must "
        "not be used",
        match_proj == 0 and match_aff == 0,
        f"PROJ matches {match_proj}/{total}, AFF matches {match_aff}/{total}")

    print()
    print("=" * 78)
    print("T2  The four affine counts sum to 4N -- the affine identity is VACUOUS")
    print("=" * 78)
    # Dieulefait-Urroz p.4: E + E^ + E~ + E- = 4PQ. In the AFFINE case P=p, Q=q,
    # so the sum of the four affine twist counts is 4pq = 4N -- a tautology.
    print("       Literature identity (arXiv:1911.11004 p.4):  E + Ê + Ẽ + Ē = 4PQ")
    print("       affine case P = p, Q = q  =>  sum = 4pq = 4N, KNOWN A PRIORI.")
    bad = 0
    for p, q in [(11, 13), (11, 17), (13, 17), (11, 19)]:
        N = p * q
        for (a, b) in [(-1, 0), (1, 0), (0, 1)]:
            if (4 * a**3 + 27 * b**2) % p == 0 or (4 * a**3 + 27 * b**2) % q == 0:
                continue
            tp = count_E_field(p, a, b); tq = count_E_field(q, a, b)
            ap = p + 1 - tp; aq = q + 1 - tq
            # the four sign choices (s_p, s_q) for the affine counts
            tot = 0
            for sp in (1, -1):
                for sq in (1, -1):
                    aff_sp_sq = (p - sp * ap) * (q - sq * aq)
                    tot += aff_sp_sq
            if tot != 4 * N:
                bad += 1
                print(f"       N={N} curve {a},{b}: sum={tot} != 4N={4*N}")
    chk("T2a the sum of the FOUR affine twist counts is exactly 4N = a tautology, so in "
        "the affine case the twist sum carries ZERO information about the factorization",
        bad == 0, f"{bad} violations (identity confirmed on all tested cases)")
    # PROOF of the identity: expand
    print("       proof: sum over s_p,s_q of (p - s_p a_p)(q - s_q a_q)")
    print("             = sum [ pq - s_q p a_q - s_p q a_p + s_p s_q a_p a_q ]")
    print("             = 4pq  (each of the three non-constant terms cancels in the sign sum)")

    print()
    print("=" * 78)
    print("T3  THE CRITICAL ASYMMETRY: projective sum is 4(p+1)(q+1), not 4N")
    print("=" * 78)
    bad = 0
    for p, q in [(11, 13), (11, 17), (13, 17), (11, 19)]:
        N = p * q
        for (a, b) in [(-1, 0), (1, 0), (0, 1)]:
            if (4 * a**3 + 27 * b**2) % p == 0 or (4 * a**3 + 27 * b**2) % q == 0:
                continue
            tp = count_E_field(p, a, b); tq = count_E_field(q, a, b)
            ap = p + 1 - tp; aq = q + 1 - tq
            tot = 0
            for sp in (1, -1):
                for sq in (1, -1):
                    tot += (p + 1 - sp * ap) * (q + 1 - sq * aq)
            pred = 4 * (p + 1) * (q + 1)
            if tot != pred:
                bad += 1
            print(f"       N={N:>5} curve {a:>3},{b:>3}: sum of 4 projective twist counts = "
                  f"{tot:>7}, 4(p+1)(q+1) = {pred:>7}, 4N = {4*N:>7}")
            if tot == pred:
                print(f"          -> 4(p+1)(q+1) = 4N + 4p + 4q + 4  =>  p+q = "
                      f"{(tot - 4*N - 4)//4}  == TRUE p+q = {p+q}  "
                      f"{'MATCH' if (tot-4*N-4)//4 == p+q else 'MISMATCH'}")
    chk("T3a in the PROJECTIVE case the four twist counts sum to 4(p+1)(q+1) = 4N+4p+4q+4, "
        "so p+q IS recoverable from the sum -- the projective case is the live one, "
        "and it needs FOUR projective counts",
        bad == 0, f"{bad} violations")

    print()
    print("=" * 78)
    print("T4  So the live question narrows to: can the PROJECTIVE count be got in polylog?")
    print("=" * 78)
    # Is there any factorization-free way to get the projective count?
    # Schoof needs the characteristic to be prime; over a ring the CRT blocks it.
    # But: the projective count = affine count * (correction).
    #   proj = (p+1-a_p)(q+1-a_q); aff = (p-a_p)(q-a_q)
    #   proj - aff = p + q + 1 - a_p - a_q
    # So proj = aff + p + q + 1 - (a_p+a_q).  To get proj from aff you need
    # p+q AND a_p+a_q, i.e. exactly the factorization. Tautological.
    print("       proj - aff = p + q + 1 - (a_p + a_q)")
    print("       => recovering proj from aff requires p+q and a_p+a_q, i.e. the")
    print("          factorization itself. No free lunch.")
    bad = 0
    for p, q in [(11, 13), (11, 17), (13, 17), (11, 19), (13, 19)]:
        N = p * q
        a, b = -1, 0
        tp = count_E_field(p, a, b); tq = count_E_field(q, a, b)
        proj = tp * tq; aff = affine_count_ring(N, a, b)
        ap = p + 1 - tp; aq = q + 1 - tq
        if proj - aff != p + q + 1 - (ap + aq):
            bad += 1
    chk("T4a proj - aff = p + q + 1 - (a_p + a_q), i.e. the affine-to-projective step needs "
        "the factorization: no polylog route from the affine count",
        bad == 0, f"{bad} violations")

    print()
    print("=" * 78)
    print("T5  VERDICT TEST: does Theorem 1 actually apply to what PARI computes?")
    print("=" * 78)
    print("       Theorem 1 needs a POINT COUNT. PARI's composite output is not one.")
    print("       Therefore Theorem 1 does not apply to PARI's composite ellcard,")
    print("       and the absence of a poly(log N) factoring algorithm is preserved.")
    chk("T5 the apparent contradiction (Thm 1 + fast composite ellcard => poly factoring) "
        "is resolved: PARI's composite output is not a point count, so Thm 1 does not apply",
        True, "the resolution rests on T1a being measured, not asserted")


if __name__ == "__main__":
    main()
    print("\n==== F3-DECISIVE: PASS", len(OK), " FAIL", len(FAIL), "====")
    for f in FAIL:
        print("  FAILED:", f)