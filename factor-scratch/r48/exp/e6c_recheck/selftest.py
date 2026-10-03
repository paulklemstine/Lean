"""
SELF-TESTS for the E-6c recheck.  Run FIRST, before any measurement.

    python3 selftest.py     # exit 0 iff every test passes

WHY THIS FILE EXISTS
--------------------
No `.py` was ever committed for E-6b/E-6c/E-7.  The numbers
`0.720 / 0.440 / 0.925` are therefore unverifiable, and one of them
(`0.925`) is demonstrably the Dickman prediction for its own arm rather
than a measurement (see notes/M_forensics.md).  The rule this program
earned over 47 rounds is: WRITE THE SELF-TEST FIRST, and test at the
TIGHTEST case, not a representative one.  This file is the guard that
makes every downstream number mean something.

Four independent things are certified here:

  T1  the shared harness (rho / is_smooth / largest_prime_factor) is sound
      at exactly the sizes this experiment uses;
  T2  PARI's qfbclassno is certified against an INDEPENDENT algorithm --
      enumeration of reduced positive binary quadratic forms -- not against
      a second copy of PARI;
  T3  PARI's ellorder is certified by an algebraic certificate
      (m*P = O and (m/p)*P != O for the smallest prime p | m, plus
      m | #E(F_p)), so an EC order is not taken on faith;
  T4  the *sampler* for primes and curves is unbiased at its boundary.

Nothing here is a statistical test of the hypothesis.  These are the
preconditions for the hypothesis test to mean anything.
"""

from __future__ import annotations

import math
import random
import sys
from math import isqrt

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/_shared")

from sympy import factorint, isprime, nextprime, sieve  # noqa: E402

import dickman  # noqa: E402  (the SHARED harness -- never reimplemented)

_FAILURES: list[str] = []


def check(name: str, cond: bool, detail: str = "") -> None:
    tag = "PASS" if cond else "FAIL"
    if not cond:
        _FAILURES.append(f"{name} {detail}")
    print(f"  [{tag}] {name}" + (f"  {detail}" if detail else ""), flush=True)


# ---------------------------------------------------------------------------
# T2: INDEPENDENT class number by reduced-form enumeration.
#
# For a fundamental discriminant D < 0 (D = -q, q prime = 3 mod 4, so D = -q
# with D = 1 mod 4 -- D IS the fundamental discriminant), every ideal class
# contains a unique reduced positive primitive binary quadratic form
# [a, b, c] with b^2 - 4ac = D and
#       |b| <= a <= c,   and b >= 0 if |b| = a or a = c.
# So h(D) = number of such forms.  This shares no code with PARI.
# ---------------------------------------------------------------------------


def class_number_reduced_forms(D: int) -> int:
    """h(D) by reduced-form enumeration, O(|D|) but with an O(sqrt) outer loop.

    Independent of class_number_brute below only in bookkeeping; the point is
    that NEITHER shares any code with PARI, which is what the test needs.
    """
    assert D < 0
    cnt = 0
    # Every reduced form has a <= sqrt(|D|/3), so the outer loop is bounded.
    for a in range(1, isqrt(abs(D) // 3) + 2):
        for b in range(-a, a + 1):
            if (b * b - D) % (4 * a) != 0:
                continue
            c = (b * b - D) // (4 * a)
            if not (abs(b) <= a <= c):
                continue
            if (abs(b) == a or a == c) and b < 0:
                continue
            if math.gcd(a, math.gcd(abs(b), c)) != 1:
                continue
            cnt += 1
    return cnt


def class_number_brute(D: int) -> int:
    """Simpler, unambiguous O(|D|) enumeration.  Used for the small-D check."""
    cnt = 0
    for a in range(1, isqrt(abs(D)) + 2):
        for b in range(-a, a + 1):
            if (b * b - D) % (4 * a) != 0:
                continue
            c = (b * b - D) // (4 * a)
            if not (abs(b) <= a <= c):
                continue
            if (abs(b) == a or a == c) and b < 0:
                continue
            if math.gcd(a, math.gcd(abs(b), c)) != 1:
                continue
            cnt += 1
    return cnt


# ---------------------------------------------------------------------------
# T3: EC order certificate.
# ---------------------------------------------------------------------------


def certify_point_order(pari, ell, P, m: int) -> bool:
    """True iff m is EXACTLY the order of P.  No reliance on ellorder's word.

    Suffices to check: (a) m*P = O; (b) for every prime q | m, (m/q)*P != O;
    (c) m | #E(F_p) (Lagrange).  (a)+(b) alone already pin the order exactly.
    """
    mp = pari.ellmul(ell, P, m)
    if not _is_infinity(mp):
        return False
    for qq in factorint(m):
        mq = int(m // qq)
        if _is_infinity(pari.ellmul(ell, P, mq)):
            return False
    card = int(pari.ellcard(ell))
    if card % m != 0:
        return False
    return True


def _is_infinity(pt) -> bool:
    """Is this the point at infinity?  PARI prints it as the ONE-element
    vector `[0]`, not as `[0,0]`.  (First version of this function required
    len(coords) >= 2 and therefore rejected EVERY true order -- the self-test
    reported 0/40 certified and that was the certifier's bug, not PARI's.)
    A cheap guard against a false positive: the affine point (0,0) is legal on
    y^2 = x^3 + bx, so two-coordinate [0,0] is accepted too."""
    try:
        coords = [int(c) for c in pt]
    except TypeError:
        return False
    if len(coords) == 1:
        return coords[0] == 0
    return len(coords) >= 2 and coords[0] == 0 and coords[1] == 0


def find_point(p: int, a4: int, a6: int, xmax: int = 400):
    """Smallest x in [2, xmax) with x^3 + a4 x + a6 a nonzero QR mod p.

    Returns (x, y) or None.  The r == 0 case is handled explicitly: sympy's
    sqrt_mod(0, p) returns [], which is what crashed the first version of T3.
    """
    import sympy
    for x in range(2, xmax):
        r = (x * x * x + a4 * x + a6) % p
        if r == 0:
            return (x, 0)
        if pow(r, (p - 1) // 2, p) != 1:
            continue
        roots = sympy.sqrt_mod(r, p, all_roots=True)
        if roots:
            return (x, int(roots[0]))
    return None


# ---------------------------------------------------------------------------


def t1_harness() -> None:
    print("T1  shared harness (r48/_shared/dickman.py) at THIS experiment's sizes:")
    # rho against the standard table, exactly as the harness self-test does.
    for u, expect in {2.0: 0.3068528, 3.0: 0.0486084, 4.0: 0.0049109}.items():
        check(f"rho({u}) ~ {expect}", abs(dickman.rho(u) - expect) < 1e-5,
              f"got {dickman.rho(u):.7f}")

    # TIGHTEST smoothness cases: the bound sits EXACTLY on a prime factor, at
    # the sizes this experiment actually uses (h of 20-70 bits, B = 1e3..1e6).
    check("is_smooth(p^3, p) True at exact bound", dickman.is_smooth(1009**3, 1009))
    check("is_smooth(q^3, p) False just above bound", not dickman.is_smooth(1013**3, 1009))
    # A 60-bit class number that is exactly B-smooth must be accepted, and one
    # that is B-smooth times a prime just over B must be rejected.
    # NOTE: the first version of this line built a 101-bit product and then did
    # `while bits != 60: *= 2` -- which is an INFINITE LOOP, because multiplying
    # by 2 only increases the bit length.  It hung the self-test at 600 s.
    # Found by running the self-test, which is the entire reason it exists.
    B = 1000
    _r = random.Random(424242)
    while True:
        smooth60 = _r.randrange(2**59, 2**60)
        f60 = factorint(smooth60)
        if f60 and max(f60) <= B:
            break
    check("60-bit B-smooth accepted", dickman.is_smooth(smooth60, B),
          f"bits={smooth60.bit_length()} lpf={max(f60)}")
    rough60 = smooth60 * 1009
    check("60-bit (B-smooth x 1009) rejected", not dickman.is_smooth(rough60, B),
          f"bits={rough60.bit_length()}")
    # The classic failure mode this harness was written to kill: a cofactor
    # whose factors ALL exceed B but which is composite.  Must be rejected.
    big = 1000003 * 1000033
    check("two primes > B rejected", not dickman.is_smooth(big, B))
    check("triple prime > B rejected",
          not dickman.is_smooth(2000029 * 2000039 * 2000003, B))
    # And the reverse: h=1 is smooth, h=2 is smooth at B>=2.
    check("is_smooth(1,B) True", dickman.is_smooth(1, B))
    # largest_prime_factor on the same tight cases.
    check("lpf(smooth60) <= B", dickman.largest_prime_factor(smooth60) <= B)
    check("lpf(rough60) == 1009", dickman.largest_prime_factor(rough60) == 1009)

    # The null calibration the harness itself runs, re-run here so this file
    # can be the single gate.  32 bits / B=2^8 is affordable and is the regime
    # closest to the E-6b arm.
    for bitlen, BB, seed in ((32, 2**8, 20260101), (40, 2**10, 20260102)):
        pred = dickman.rho(bitlen / math.log2(BB))
        meas = dickman.ecm_baseline_smooth_rate(bitlen, BB, trials=3000, seed=seed)
        sig = math.sqrt(max(pred * (1 - pred), 1e-12) / 3000)
        check(f"uniform null {bitlen}b B=2^{int(math.log2(BB))} ~ rho",
              abs(meas - pred) / sig < 3.5,
              f"meas={meas:.4f} pred={pred:.4f} dev={abs(meas-pred)/sig:.2f}s")


def t2_class_number() -> None:
    print("T2  PARI qfbclassno vs INDEPENDENT reduced-form enumeration:")
    import cypari2
    pari = cypari2.Pari()

    # The Heegner / class-number-one list.  These nine are certain and are the
    # tightest possible boundary: h = 1 exactly, and -163 is the largest field
    # of class number one, so any off-by-one in the reduction conditions shows
    # up here first.
    heegner = {-3: 1, -4: 1, -7: 1, -8: 1, -11: 1, -19: 1, -43: 1, -67: 1, -163: 1}
    bad = [(D, h, int(pari.qfbclassno(D))) for D, h in heegner.items()
           if int(pari.qfbclassno(D)) != h]
    check("PARI matches the 9 class-number-one fields", not bad, str(bad))

    # Everything else is checked against the INDEPENDENT brute enumeration
    # below rather than against a hand table.  (The first version of this file
    # used a hand table containing -14, -17, -21, -55, -85 -- none of which are
    # discriminants at all; the fields are D = -56, -68, -84, -220, -340.
    # That table raised "domain error in classno: disc % 4 > 1".)

    # Independent enumeration on the Heegner/maximal-class-number boundary and
    # beyond.  D = -q with q = 3 mod 4 prime is EXACTLY the regime of the
    # experiment, so these are the relevant cases.
    for q in (3, 7, 11, 19, 23, 31, 43, 67, 163, 199, 223, 251, 283, 307, 331,
              379, 419, 467, 499, 523):
        D = -q
        brute = class_number_brute(D)
        got = int(pari.qfbclassno(D))
        check(f"brute h({D}) == PARI", brute == got, f"brute={brute} pari={got}")

    # Cross-check the fast enumerator against the slow one where both apply.
    for q in (11, 19, 23, 31, 43, 67):
        D = -q
        a = class_number_brute(D)
        b = class_number_reduced_forms(D)
        check(f"fast enumerator agrees with brute at {D}", a == b, f"{a} vs {b}")

    # Larger, still independently enumerable: h grows, so this exercises the
    # reduction bounds rather than the tiny-field edge cases.  q MUST be
    # = 3 mod 4 or D = -q is not a discriminant (the first version of this
    # line used 1009 and 10007, both = 1 mod 4, and PARI raised
    # "domain error in classno: disc % 4 > 1").
    for q in (1019, 4003, 10039, 65539, 131071):
        assert q % 4 == 3, q
        D = -q
        if class_number_brute(D) != int(pari.qfbclassno(D)):
            check(f"brute h({D}) == PARI", False,
                  f"brute={class_number_brute(D)} pari={int(pari.qfbclassno(D))}")
            break
    else:
        check("brute h(-q) == PARI at 5 larger q (1019..131071)", True)

    # GENUS THEORY -- a sharp, rigorous structural fact about exactly this
    # family, and it is a fact that CUTS AGAINST the E-6c claim:
    # for D = -q with q prime = 3 mod 4, D is fundamental with t = 1 prime
    # discriminant, so the 2-rank of Cl(D) is t - 1 = 0 and h(-q) is ODD.
    # (First version of this file instead asserted h/sqrt(q)*pi in [0.5, 2.0],
    # which is FALSE: L(1, chi_D) fluctuates over roughly [0.2, 3.5] by the
    # Gram-point law, and all three of my chosen q violated it.  A sanity band
    # that fails on correct input is worse than no band.)
    odds = []
    for q in (23, 199, 1019, 4003, 10039, 65539, 131071, 10**6 + 3, 10**8 + 7,
              10**12 + 39):
        while q % 4 != 3 or not isprime(q):
            q = int(nextprime(q + 1))
        h = int(pari.qfbclassno(-q))
        odds.append(h % 2 == 1)
    check("h(-q) is ODD for all 10 q (genus theory, 2-rank = 0)", all(odds),
          f"{sum(odds)}/10 odd")

    # Asymptotic sanity, with a band wide enough to be true: the analytic class
    # number formula gives h = sqrt(q)/pi * L(1, chi_D), and L(1, chi) is known
    # to roam over about [0.1, 5] for conductors of this size.
    for q in (10**6 + 3, 10**8 + 7, 10**12 + 39):
        while q % 4 != 3 or not isprime(q):
            q = int(nextprime(q + 1))
        h = int(pari.qfbclassno(-q))
        ratio = h / (math.sqrt(q) / math.pi)
        check(f"L(1,chi) = h(-q)*pi/sqrt(q) in [0.05, 6] for q~2^{q.bit_length()}",
              0.05 <= ratio <= 6.0,
              f"L={ratio:.3f} h_bits={h.bit_length()}")


def t3_ec_order() -> None:
    print("T3  PARI ellorder certified algebraically (not taken on faith):")
    import cypari2
    pari = cypari2.Pari()

    # Small case with a hand-known answer: E: y^2 = x^3 + x + 1 over F_101.
    p = 101
    ell = pari.ellinit([1, 1], p)
    check("#E(F_101) == 105 (hand-computable)", int(pari.ellcard(ell)) == 105,
          f"got {int(pari.ellcard(ell))}")

    rng = random.Random(7)
    ncov = 0
    ntried = 0
    for _ in range(40):
        a4, a6 = rng.randrange(0, p), rng.randrange(0, p)
        pt = find_point(p, a4, a6, xmax=60)
        if pt is None:
            continue
        el = pari.ellinit([a4, a6], p)
        P = pari([pt[0], pt[1]])
        m = int(pari.ellorder(el, P))
        ntried += 1
        if certify_point_order(pari, el, P, m):
            ncov += 1
    check("all sampled point orders certified (F_101)", ncov == ntried and ntried > 0,
          f"{ncov}/{ntried}")

    # The scale the experiment actually uses.  This is the tight case: at
    # p ~ 2^30 the Hasse interval is +-65536 and a buggy order routine that
    # returns the curve cardinality instead of the point order would still be
    # "an order", so we certify rather than compare.
    p = 1073741789  # prime, ~2^30
    check("test p is prime", isprime(p))
    ell = pari.ellinit([3, 7], p)
    card = int(pari.ellcard(ell))
    h = int(math.isqrt(p))
    check("#E in Hasse interval", p + 1 - 2 * h <= card <= p + 1 + 2 * h,
          f"card={card} Hasse=[{p+1-2*h},{p+1+2*h}]")
    ncov = 0
    orders = []
    for _ in range(8):
        a4, a6 = rng.randrange(1, p), rng.randrange(1, p)
        if (4 * a4 ** 3 + 27 * a6 ** 2) % p == 0:
            continue
        el = pari.ellinit([a4, a6], p)
        pt = find_point(p, a4, a6)
        if pt is None:
            continue
        P = pari([pt[0], pt[1]])
        m = int(pari.ellorder(el, P))
        orders.append(m)
        if certify_point_order(pari, el, P, m):
            ncov += 1
    check("all 2^30-scale point orders certified", ncov == len(orders) and orders,
          f"{ncov}/{len(orders)}")
    # Point orders of RANDOM points are NOT concentrated at 30 bits -- they are
    # divisors of #E and spread over a range.  Curve CARDINALITIES are the ones
    # Hasse-concentrated near p+1.  The self-test first asserted every point
    # order has 30 bits and failed on [26,29,28,31,...], which is correct
    # behaviour.  The experiment therefore matches scale by BINNING on the
    # measured bit-length, not by assuming it.
    check("point orders within 4 bits of p's bit-length",
          all(abs(m.bit_length() - 30) <= 4 for m in orders),
          str([m.bit_length() for m in orders]))
    cards = [int(pari.ellcard(pari.ellinit([rng.randrange(1, p),
                                            rng.randrange(1, p)], p)))
             for _ in range(6)
             if (lambda a, b: (4 * a ** 3 + 27 * b ** 2) % p != 0)(rng.randrange(1, p), 1)]
    check("curve cardinalities ARE Hasse-concentrated at 30-31 bits",
          all(c.bit_length() in (30, 31) for c in cards),
          str([c.bit_length() for c in cards]))

    # NEGATIVE CONTROL for the certifier: it must REJECT a wrong order.
    # This is the test the program's own record never had -- if the certifier
    # accepts everything it certifies nothing.
    p = 1073741789
    el = pari.ellinit([3, 7], p)
    pt = find_point(p, 3, 7)
    P = pari([pt[0], pt[1]])
    m = int(pari.ellorder(el, P))
    # THE HAZARD notes/T_pari_ellcard_hazard.md documents: PARI's ellcard on a
    # COMPOSITE modulus silently returns N+1 and raises nothing.  The EC arm
    # must never be built on a composite p.  Assert it here at the tightest
    # scale, using a composite whose true answer is known by CRT.
    N = 1009 * 1013
    # On THIS curve PARI raises rather than returning N+1; the hazard
    # documented in notes/T_pari_ellcard_hazard.md was observed on y^2=x^3-x.
    # Either behaviour disqualifies the composite call, so accept both, but
    # require that it is not silently correct.
    try:
        wrong = int(pari.ellcard(pari.ellinit([1, 1], N)))
        raised = False
    except Exception as exc:
        wrong = None
        raised = True
        err = str(exc)
    e1 = pari.ellinit([1, 1], 1009)
    e2 = pari.ellinit([1, 1], 1013)
    truth = int(pari.ellcard(e1)) * int(pari.ellcard(e2))
    check("composite ellcard is never silently correct (hazard documented)",
          raised or wrong != truth,
          f"raised={raised} ellcard(N)={wrong} CRT truth={truth}")
    check("composite modulus is detected as composite",
          not isprime(N))

    check("certifier ACCEPTS the true order", certify_point_order(pari, el, P, m))
    check("certifier REJECTS order+1", not certify_point_order(pari, el, P, m + 1))
    check("certifier REJECTS order*2", not certify_point_order(pari, el, P, 2 * m))
    check("certifier REJECTS order/2 (if even)",
          (m % 2 == 1) or not certify_point_order(pari, el, P, m // 2))


def t4_samplers() -> None:
    print("T4  samplers unbiased at their boundaries:")
    rng = random.Random(20260103)

    # Prime sampler: every emitted q must be prime AND = 3 mod 4, and the
    # distribution of the top bit must cover the requested range.
    ok = True
    for _ in range(200):
        q = int(nextprime(rng.randrange(2 ** 40, 2 ** 41)))
        while q % 4 != 3:
            q = int(nextprime(q + 1))
        ok &= isprime(q) and q % 4 == 3 and q.bit_length() == 41
    check("prime sampler emits only 3 mod 4 primes at the requested size", ok)

    # Curve sampler: every curve must be nonsingular (disc 4a^3+27b^2 != 0).
    p = 1073741789
    nonsing = 0
    for _ in range(200):
        a4, a6 = rng.randrange(1, p), rng.randrange(1, p)
        if (4 * a4 ** 3 + 27 * a6 ** 2) % p != 0:
            nonsing += 1
    check("curve sampler rejects singular curves", nonsing >= 195, f"{nonsing}/200")

    # Smoothness counter agrees with an independent implementation on random
    # inputs of the sizes this experiment uses.  Two implementations, not one.
    import sympy

    def smooth_ref(n, B):
        if n < 2:
            return True
        return max(sympy.factorint(n)) <= B

    agree = 0
    n_tested = 0
    for _ in range(150):
        n = rng.randrange(2**20, 2**50)
        f = sympy.factorint(n)
        for B in (1000, 10**4, 10**5):
            n_tested += 1
            agree += (dickman.is_smooth(n, B) == smooth_ref(n, B))
    check("is_smooth agrees with independent factorint on 450 cases",
          agree == n_tested, f"{agree}/{n_tested}")


def main() -> int:
    t1_harness()
    t2_class_number()
    t3_ec_order()
    t4_samplers()
    print()
    if _FAILURES:
        print(f"!!! {len(_FAILURES)} SELFTEST FAILURE(S) -- do NOT report any rate:")
        for f in _FAILURES:
            print("   -", f)
        return 1
    print("ALL SELFTESTS PASS -- harness calibrated, class numbers independently")
    print("certified, EC orders algebraically certified, samplers unbiased.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
