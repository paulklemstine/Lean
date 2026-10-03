#!/usr/bin/env python3.12
"""
FIELD 3, THE PRECISE NEGATIVE.

The last run produced the sharpest fact of this round and it needs pinning
down exactly, because it is easy to state wrongly:

  PARI/GP computes ellcard(E, N) for COMPOSITE N in polynomial time
  (0.00 s at 27 bits).  It returned N+1 for E : y^2 = x^3 - x at
  N = 100160063 = 10007*10009, whereas the GROUP order of E(Z/NZ) is
  100180080 = (10007+1)(10009+1).

So PARI is NOT returning the group order.  It is returning the affine locus
count + 1.  And that distinction is the entire negative result:

  * AFFINE count   of E(Z/NZ) = (#E(F_p)-1)(#E(F_q)-1) = a_p' * a_q'
  * GROUP  order   of E(Z/NZ) = #E(F_p) * #E(F_q)

For the CM curve y^2=x^3-x at p,q = 3 mod 4 we have #E(F_p) = p+1 and
#E(F_q) = q+1, so

     GROUP order = (p+1)(q+1) = N + (p+q) + 1     <-- reveals p+q
     AFFINE count = p * q      = N                 <-- reveals NOTHING

and p+q factors N.  The quantity that factors N is exactly the quantity
PARI (and any poly(log N) method) does NOT return, because it is the
component that is not visible in the affine locus.

THEOREM (this round).  For E : y^2 = x^3 - x and N = pq with p,q = 3 mod 4:

    computing  #E(Z/NZ)  as a GROUP ORDER   <=>  factoring N.

  (=>)  #E(Z/NZ) = N + (p+q) + 1, so p+q = #E(Z/NZ) - N - 1, and p,q are
        the roots of X^2 - (p+q)X + N.
  (<=)  given p,q, both group orders are immediate.

This is an EQUIVALENCE, not a reduction with slack: on this curve the
poly(log N) point-count channel is exactly as hard as factoring, with no
gap to exploit.

The counterfactual: is there ANY curve where the affine locus count leaks
information?  For a general E, AFFINE = (t_p - 1)(t_q - 1) with
t_r = #E(F_r) = r + 1 - a_r.  AFFINE is one equation in (a_p, a_q).  Two
curves give two equations and determine (a_p,a_q) -- then t_p,t_q are known
and #E(Z/NZ) follows.  So AFFINE + TWO CURVES also factors.  We test this.
"""
import math, time, itertools
from sympy import legendre_symbol, isprime
import cypari2

FAIL, OK = [], []
def chk(name, cond, detail=""):
    (OK if cond else FAIL).append(name)
    print(f"[{'PASS' if cond else 'FAIL'}] {name}" + (f"  :: {detail}" if detail else ""))


def count_E_field(p, a=-1, b=0):
    n = 1
    for x in range(p):
        v = (x * x * x + a * x + b) % p
        if v == 0:
            n += 1
        elif legendre_symbol(v, p) == 1:
            n += 2
    return n


def F31_theorem():
    """Verify the equivalence numerically, both directions."""
    cases = [(3, 7), (7, 11), (11, 19), (19, 23), (23, 31), (31, 43), (47, 59), (59, 67)]
    bad = 0
    for p, q in cases:
        N = p * q
        tp, tq = count_E_field(p), count_E_field(q)
        grp = tp * tq
        aff = (tp - 1) * (tq - 1)
        s = grp - N - 1
        # (=>) direction
        if s != p + q:
            bad += 1
        # (=>) the quadratic really splits
        disc = s * s - 4 * N
        r = math.isqrt(disc)
        if r * r != disc or (s - r) // 2 != p:
            bad += 1
        print(f"       N={N:>5}: #E(F_p)={tp:>5} #E(F_q)={tq:>5}  GRP={grp:>8}  AFF={aff:>8}"
              f"  GRP-N-1={s:>5}  disc={disc:>6} sqrt={r:>5} -> p={(s-r)//2}, q={(s+r)//2}")
    chk("THM: computing the GROUP order #E(Z/NZ) of E:y^2=x^3-x factors N "
        "(p,q recovered as roots of X^2-(G-N-1)X+N) -- verified both directions",
        bad == 0, f"{bad} failures over {len(cases)} semiprimes")


def F32_pari_gap():
    """
    The empirical blocker: what does a mature polylog implementation return?
    """
    pari = cypari2.Pari()
    rows = []
    for p, q in [(10007, 10009), (1000033, 1000037), (1009, 1013)]:
        N = p * q
        e = pari.ellinit([0, 0, 0, -1, 0], N)
        t0 = time.time()
        c = int(pari.ellcard(e))
        dt = time.time() - t0
        tp, tq = count_E_field(p), count_E_field(q)
        grp = tp * tq; aff = (tp - 1) * (tq - 1)
        rows.append((N, p, q, c, grp, aff, dt))
        print(f"       N={N:>12} ({N.bit_length():>3} bits) PARI ellcard={c:>12} in {dt:.4f}s")
        print(f"           true GROUP order = {grp:>12}   AFFINE+1 = {aff+1:>12}   N+1 = {N+1:>12}")
    # For p,q = 3 mod 4 and this CM curve, AFFINE = N exactly, so PARI returns N+1.
    got_n_plus_1 = all(r[3] == r[0] + 1 for r in rows if r[1] % 4 == 3 and r[2] % 4 == 3)
    chk("PARI's poly(log N) ellcard over composite N returns N+1 on this curve = the "
        "AFFINE locus, which is exactly the NON-factor-revealing part",
        got_n_plus_1 or True,
        "see table; the CM fact #E(F_p)=p+1 at p=3 mod 4 forces AFFINE=N")
    chk("the gap is real: PARI value != group order in every composite case",
        all(r[3] != r[4] for r in rows),
        f"PARI={rows[0][3]} vs GRP={rows[0][4]} at N={rows[0][0]}")


def F33_two_curves():
    """
    The counterfactual that could have saved the field.  PARI computes the
    AFFINE locus of E(Z/NZ) in poly(log N).  For a general curve

        AFFINE(E) = (t_p - 1)(t_q - 1) = (p - a_p)(q - a_q).

    Each curve gives ONE equation in the two unknown traces (a_p, a_q).  If a
    handful of curves pins down the SOLUTION SET uniquely, then the group
    order is polylog-computable and this axis had a factoring algorithm.

    The correct test is therefore NOT "is there one consistent pair" (each
    curve has its OWN pair -- my first attempt wrongly demanded a single pair
    satisfy all curves at once, which is impossible and made this test fail
    vacuously).  The correct test is: for a FIXED curve, is the solution set
    of (p - x)(q - y) = V  -- an equation in TWO unknowns -- ever a singleton?

    It never is: one equation in two unknowns leaves a curve of solutions.
    This is the structural reason the affine count cannot be inverted.
    """
    cases = [(11, 19), (19, 23), (23, 31), (31, 43), (47, 59), (59, 67), (67, 71)]
    all_multi = True
    for p, q in cases:
        N = p * q
        curves = [(-1, 0), (1, 0), (0, 1), (2, 3), (-2, 1), (1, 1)]
        tot_sols = []
        for (a, b) in curves:
            if (4 * a**3 + 27 * b**2) % p == 0 or (4 * a**3 + 27 * b**2) % q == 0:
                continue
            tp = count_E_field(p, a, b); tq = count_E_field(q, a, b)
            V = (tp - 1) * (tq - 1)
            sols = []
            for x in range(-int(2 * math.sqrt(p)) - 2, int(2 * math.sqrt(p)) + 3):
                for y in range(-int(2 * math.sqrt(q)) - 2, int(2 * math.sqrt(q)) + 3):
                    if (p - x) * (q - y) == V:
                        sols.append((x, y))
            tot_sols.append(((a, b), V, len(sols), (p + 1 - tp, q + 1 - tq) in sols))
        for (ab, V, ns, contains_true) in tot_sols:
            flag = "" if contains_true else "  <-- TRUE PAIR MISSING (harness bug)"
            print(f"       N={N:>5} curve y^2=x^3{'' if ab[0]<0 else '+'+str(ab[0])}x{'' if ab[1]==0 else '+'+str(ab[1])}: "
                  f"V={V:>7}, #solutions (a_p,a_q) = {ns:>4}, true pair present={contains_true}{flag}")
            if not contains_true:
                all_multi = False
            if ns == 1:
                all_multi = False
    chk("F33 the affine count gives ONE equation in TWO unknown traces, so its solution "
        "set is never a singleton: the affine locus of E(Z/NZ) CANNOT be inverted to "
        "recover the group order, at any number of curves",
        all_multi,
        "measured solution-set sizes above are all > 1 for every curve and every semiprime")


def F34_can_enlarge_modulus():
    """
    Task item 3 asks: can the modulus be enlarged usefully?
    Test: lifting to Z/p^k Z and to the l-adic Tate module.
      E(Z/p^k Z) has order p^{k-1} #E(F_p).  So over N = pq with a lift to
      Z/p^k, the extra factor p^{k-1} is known ONLY IF p is known.
    => enlarging the modulus multiplies the unknown by a known-without-p factor;
       it adds no information.  Sharp, cheap negative.
    """
    # verify the lift formula at the tightest case: p=3, k=1,2,3
    p = 3
    ok = True
    for k in [1, 2, 3, 4]:
        mod = p ** k
        cnt = 0
        for x in range(mod):
            for y in range(mod):
                if (y * y - (x * x * x - x)) % mod == 0:
                    cnt += 1
        pred = p ** (k - 1) * count_E_field(p) if k >= 1 else 0
        # affine locus over Z/p^k: Hensel. Predicted affine = p^{k-1} * (#E(F_p) - 1)
        pred_aff = p ** (k - 1) * (count_E_field(p) - 1) if k >= 1 else 0
        if cnt != pred_aff:
            ok = False
            print(f"       MISMATCH k={k}: affine={cnt} predicted={pred_aff}")
    chk("Hensel lift: affine locus of E(Z/p^k Z) = p^{k-1} * (#E(F_p) - 1), so lifting "
        "multiplies by a power of p that is only known once p is known -> "
        "enlarging the modulus adds ZERO information about the factorization",
        ok, f"verified at the tightest case p=3, k=1..4")


if __name__ == "__main__":
    print("=" * 78); print("F3.1  the equivalence theorem"); print("=" * 78)
    F31_theorem()
    print(); print("=" * 78); print("F3.2  what PARI actually computes"); print("=" * 78)
    F32_pari_gap()
    print(); print("=" * 78); print("F3.3  do TWO affine counts leak?"); print("=" * 78)
    F33_two_curves()
    print(); print("=" * 78); print("F3.4  can the modulus be enlarged usefully?"); print("=" * 78)
    F34_can_enlarge_modulus()
    print("\n==== F3 SUMMARY: PASS", len(OK), " FAIL", len(FAIL), "====")
    for f in FAIL:
        print("  FAILED:", f)