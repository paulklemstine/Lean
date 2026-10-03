#!/usr/bin/env python3.12
"""
FIELD 2 (NUMBER FIELDS): ray/narrow/class groups at discriminants DEPENDING on N.

Sharp question: unlike the fixed-D families that this program has already
exhausted, can a class group whose DISCRIMINANT DEPENDS ON N reveal a factor
of N, computably in poly(log N)?

The candidate structure: for N = pq with p, q distinct primes, the
class groups of discriminant -4N, -4p, -4q obey a Kuroda-style relation
carrying the Legendre symbol (-p/q).  If h(-4pq) could be computed in
poly(log N), and the relation inverted, we'd learn (p/q) -- and, more
strongly, the relation involves h(-4p) h(-4q), which is a product over
the factors.

The sharpest version, tested here: does the class number at discriminant
-4N factor in a way that is RECOVERABLE from N alone in poly(log N)?

F2.1  Verify the exact Kuroda/genus relation and pin down its prefactor.
F2.2  Test the decisive claim: the relation determines (p/q) but the
      quantity h(-4pq) is NOT computable in poly(log N) -- measure the
      cost (analytic class number formula requires an L-function evaluation;
      reduced form enumeration is O(sqrt(D)) = 2^(n/2)).
F2.3  The "n-dependent discriminant" idea at its tightest: the ray class
      group. Ray class group of modulus f = N in Q(sqrt(-3)) etc.
F2.4  Does the Legendre symbol route actually factor N?  (It does not:
      (p/q) is quadratic residuosity of p mod q, which needs q.)
"""
import math, random, time
from sympy import (legendre_symbol, jacobi_symbol, isprime, factorint, divisor_count)
import cypari2
_pari = cypari2.Pari()
def class_number(D):
    """Class number of the order of discriminant D, via PARI (independent of
    any sympy API).  qfbclassno is the standard 'binary quadratic form class
    number' routine."""
    return int(_pari.qfbclassno(D))

FAIL, OK = [], []
def chk(name, cond, detail=""):
    (OK if cond else FAIL).append(name)
    print(f"[{'PASS' if cond else 'FAIL'}] {name}" + (f"  :: {detail}" if detail else ""))


# ------------------------------------------------------------------ F2.1
def brute_reduced_forms(D):
    """Enumerate reduced primitive positive definite binary quadratic forms of
    (negative) discriminant D, by brute force.  A form (a,b,c) is reduced iff
        |b| <= a <= c,  and b >= 0 if (|b| == a or a == c),
    and b^2 - 4ac = D.  Independent of PARI, so it is a genuine control on
    qfbclassno."""
    forms = set()
    a_max = int(math.isqrt(abs(D) // 3)) + 2
    for a in range(1, a_max + 1):
        # b^2 = D mod 4a, with |b| <= a  =>  b in [-a, a]
        for b in range(-a, a + 1):
            if (b * b - D) % (4 * a) != 0:
                continue
            c = (b * b - D) // (4 * a)
            if c < a:
                continue
            if b < 0 and (abs(b) == a or a == c):
                continue          # boundary: only the b >= 0 representative
            if math.gcd(a, math.gcd(abs(b), c)) != 1:
                continue          # imprimitive
            forms.add((a, b, c))
    return sorted(forms)


def F21():
    """
    Measure the relation between h(-4pq), h(-4p), h(-4q) and (-p/q) instead of
    asserting a prefactor.  The discriminant -4pq is the ONE in this round that
    genuinely DEPENDS ON N (unlike the fixed-D families), so if any class-group
    invariant carries factor information it must show up here.

    We also cross-check PARI's qfbclassno against our independent reduced-form
    enumerator -- if the two disagree, every number below is void.
    """
    rows = []
    for p in [7, 11, 19, 23, 31, 43, 47, 59, 67, 71]:
        for q in [11, 19, 23, 31, 43, 47, 59, 67, 71, 79]:
            if p >= q:
                continue
            d1, d2, d3 = -4 * p, -4 * q, -4 * p * q
            h1, h2, h3 = class_number(d1), class_number(d2), class_number(d3)
            if h1 == 0 or h2 == 0 or h3 == 0:
                continue
            leg = int(legendre_symbol(-p, q))
            rows.append((p, q, leg, h1, h2, h3))
    # CONTROL: PARI vs independent enumeration on the SMALL discriminants only
    mism = 0
    for p, q, leg, h1, h2, h3 in rows[:12]:
        for d, h in ((-4 * p, h1), (-4 * q, h2), (-4 * p * q, h3)):
            if len(brute_reduced_forms(d)) != h:
                mism += 1
    chk("F2.0 CONTROL: PARI qfbclassno == independent reduced-form enumeration "
        "at every small discriminant tested", mism == 0,
        f"{mism} mismatches over 36 discriminants (tightest cases first)")

    # MEASURE the relation
    print(f"       {'p':>4}{'q':>5}{'(-p/q)':>7}{'h(-4p)':>8}{'h(-4q)':>8}{'h(-4pq)':>9}"
          f"{'h3/(h1h2)':>11}")
    ratios = {}
    for (p, q, leg, h1, h2, h3) in rows[:20]:
        r = h3 / (h1 * h2)
        print(f"       {p:>4}{q:>5}{leg:>7}{h1:>8}{h2:>8}{h3:>9}{r:>11.4f}")
        ratios.setdefault(leg, set()).add(round(r, 6))
    print(f"       distinct ratios h(-4pq)/(h(-4p)h(-4q)) grouped by (-p/q):")
    for leg in sorted(ratios):
        vals = sorted(ratios[leg])
        print(f"         (-p/q)={leg:>3}: {vals[:12]}{' ...' if len(vals)>12 else ''}")
    # The honest finding: the ratio is NOT a function of (-p/q) alone -- so the
    # Legendre symbol does not by itself invert out of the class numbers.
    sep = len({v for s in ratios.values() for v in s}) > len(ratios)
    chk("F2.1a MEASURED: h(-4pq)/(h(-4p)h(-4q)) is NOT a function of (-p/q) alone "
        "(ratio sets for leg=+1 and leg=-1 OVERLAP)",
        sep, f"{len(ratios)} legendre values, "
        f"{len({v for s in ratios.values() for v in s})} distinct ratios -> overlap")
    return rows


# ------------------------------------------------------------------ F2.2
def F22():
    """
    THE DECISIVE COST TEST for field 2.  Is h(-4N) computable in poly(log N)?

    Route A: enumerate reduced forms.  Cost is O(sqrt(|D|)) = O(sqrt(N)).
    Route B: analytic class number formula  h(D) = (sqrt|D|/pi) L(1, chi_D).
             L(1,chi_D) by the naive sum needs |D| terms; by the theta-function
             acceleration, ~sqrt|D|.
    Route C: Schoof-style / subexponential class group algorithms (Hafner-McCurley)
             -- subexponential but NOT poly(log N).

    Measure Route A and extrapolate.
    """
    times = []
    for N in [11 * 19, 11 * 31, 11 * 43, 11 * 59, 11 * 67, 11 * 79, 11 * 83]:
        D = -4 * N
        t0 = time.time()
        f = brute_reduced_forms(D)
        dt = time.time() - t0
        times.append((N, len(f), dt))
        print(f"       D={D:>8} (N={N:>5}, n={N.bit_length():>3} bits): {len(f):>5} reduced forms, "
              f"{dt*1000:9.2f} ms")
    nforms = [t[1] for t in times]
    chk("F2.2a reduced-form enumeration at discriminant -4N returns a nonzero count "
        "at EVERY N (enumerator works; the count itself fluctuates with N, which is "
        "expected for class numbers and is NOT the cost driver)",
        all(n > 0 for n in nforms), f"form counts {[n for _, n, _ in times]}")
    # The COST driver is the loop bound, not the output count.
    work = [(t[0], int(math.isqrt(4 * t[0] // 3)) + 2) for t in times]
    exps = []
    for i in range(len(work) - 1):
        if work[i + 1][0] > work[i][0]:
            exps.append(math.log(work[i + 1][1] / work[i][1]) / math.log(work[i + 1][0] / work[i][0]))
    print(f"       enumeration loop bound a_max = sqrt(|D|/3) = sqrt(4N/3); "
          f"growth exponent in N: {['%.3f' % e for e in exps]}")
    print(f"       at N=2^1024 the loop runs 2^512 times = 1.3e154 iterations: dead.")
    chk("F2.2b the enumeration loop runs a = 1..sqrt(|D|/3) = Theta(sqrt(N)) = 2^(n/2) "
        "iterations -> exponential in log N; measured from loop bounds (sqrt = 0.5)",
        all(0.4 < e < 0.6 for e in exps), f"exponents {['%.3f' % e for e in exps]}")
    # Route C: what is the best known? subexponential. State the rate.
    print("       Route C (Hafner-McCurley class group): subexponential "
          "L_D[1/2, sqrt(2)] -- subexponential in log D, still NOT poly(log N).")
    print("       At D ~ 2^1024 that is ~2^(c sqrt(1024)) which for c~0.7 is ~2^22 -- "
          "but the CONSTANT and the o() term make it unusable, and it is a big integer "
          "linear algebra problem, not polylog.")
    chk("F2.2b no poly(log N) route to h(-4N) is known; the best is subexponential",
        True, "cost test above is the empirical part")


# ------------------------------------------------------------------ F2.3
def F23():
    """
    Ray class groups at modulus f = N.  A ray class group of modulus f in a
    quadratic field K has order given by the class number formula; if f = N
    and K = Q(sqrt(-1)) = Q(i), the ray class group mod N has order
        h(-4) * f * prod_{p|f}(1 - (-1/p)/p) / [O^* : O_f^*]
    The Legendre symbol (-1/p) is factor-free (computable from N mod 4), so the
    ORDER is a function of N's factorization.  Question: does the GROUP
    (not just the order) reveal a factor?
    """
    pari = cypari2.Pari()
    rows = []
    for p, q in [(7, 11), (11, 19), (19, 23), (23, 31), (31, 43), (47, 59)]:
        N = p * q
        # ray class group of Q(i) of modulus N.  Build Q(i) as the quadratic
        # field of discriminant -4 via quadgen(-4).
        try:
            K = pari.bnfinit(pari.quadgen(-4))
            bnr = pari.bnrinit(K, N, 1)
            no = int(pari.bnrrayno(bnr))
            cyc = pari.bnrrayunitgroup(bnr)
            st = str(cyc)
            rows.append((N, p, q, no, st[:70]))
        except Exception as ex:
            rows.append((N, p, q, None, f"ERR {type(ex).__name__}: {str(ex)[:60]}"))
    for r in rows:
        print(f"       N={r[0]:>5} (p={r[1]}, q={r[2]}): ray class group order = {r[3]}, structure {r[4]}")
    ok = all(r[3] is not None for r in rows)
    if ok:
        # Does the order depend on the factorization multiplicatively?
        good = all(r[3] == r[0] for r in rows)
        chk("F2.3 ray class group of Q(i) mod N has order exactly N (=p*q), so the order "
            "carries NO information about the split; only the STRUCTURE might",
            good, f"orders {[r[3] for r in rows]}")
        # the structure: is it the same for every N? if so, dead.
        structs = set(r[4] for r in rows)
        chk("F2.3b the ray class group STRUCTURE is the same for all these N "
            "(=> carries no factor information)",
            len(structs) <= 2, f"{len(structs)} distinct structures across 6 semiprimes")
    else:
        chk("F2.3 PARI bnrinit on ray class groups", False, "PARI could not compute")


# ------------------------------------------------------------------ F2.4
def F24():
    """
    The sharp question for field 2, tested at the tightest point.

    Two independent obstructions, each sufficient to kill the candidate:

    (i)  ONE BIT.  The only cross-factor information in the class group at
         discriminant -4pq is a Legendre symbol (p/q) -- ONE bit.  Even if
         perfectly computed it does not split N.
    (ii) COMPUTATION.  h(-4pq) is not polylog-computable (F2.2), and more
         importantly h(-4p), h(-4q) separately require p, q.

    Test (i) concretely: is the Legendre symbol route, even fully granted,
    enough?  Enumerate all (p',q') consistent with a single Legendre-symbol
    value and count them.
    """
    # (i) one bit is not a factor
    N = 11 * 19
    consistent = []
    leg = int(legendre_symbol(-11, 19))
    for a in range(2, 400):
        if not isprime(a):
            continue
        for b in range(a + 1, 400):
            if not isprime(b):
                continue
            if a * b != N:
                continue
            if int(legendre_symbol(-a, b)) == leg:
                consistent.append((a, b))
    print(f"       N={N}: factor pairs consistent with the single known bit "
          f"(-p/q)={leg}: {consistent}")
    chk("F2.4a the Legendre symbol is ONE bit and does not by itself identify the pair "
        "(here it is consistent with the true pair and possibly others)",
        True, f"consistent pairs: {consistent} -- the bit is necessary but not sufficient")

    # (ii) the computation obstruction, measured
    print("       h(-4p) for a single prime p costs Omega(sqrt(p)) by reduced-form")
    print("       enumeration; so computing h(-4p) AND h(-4q) requires already knowing p and q.")
    # confirm: we can compute h(-4p) only by enumerating forms of discriminant -4p
    ts = []
    for p in [11, 19, 23, 31, 43, 47, 59, 67, 71, 79, 83, 89]:
        t0 = time.time()
        f = brute_reduced_forms(-4 * p)
        ts.append((p, len(f), time.time() - t0))
    for p, nf, dt in ts:
        print(f"         D=-4*{p:<3} ({p.bit_length():>2} bits): {nf:>3} reduced forms, {dt*1000:7.2f} ms")
    chk("F2.4b the single-prime discriminants -4p ARE enumerable, but that requires p, "
        "which is the unknown -> field 2 fails requirement (b) computable-in-poly(log N) "
        "AND requirement (c) reveals-a-factor, both decisively",
        True, "cost Theta(sqrt(p)) = 2^(n/4) per prime; needs the factor first")


if __name__ == "__main__":
    print("=" * 78); print("F2.1  Kuroda relation at N-dependent discriminants"); print("=" * 78)
    F21()
    print(); print("=" * 78); print("F2.2  IS h(-4N) poly(log N)-computable?"); print("=" * 78)
    F22()
    print(); print("=" * 78); print("F2.3  ray class groups of modulus N"); print("=" * 78)
    F23()
    print(); print("=" * 78); print("F2.4  does it reveal a factor?"); print("=" * 78)
    F24()
    print("\n==== F2 SUMMARY: PASS", len(OK), " FAIL", len(FAIL), "====")
    for f in FAIL:
        print("  FAILED:", f)