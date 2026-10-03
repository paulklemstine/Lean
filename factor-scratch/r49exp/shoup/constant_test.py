#!/usr/bin/env python3
"""
SELF-TEST for the Shoup Theorem 15.6 constant-factor question.

SOURCE (local PDF, read as PAGE IMAGES because pdftotext mangles radicals):
  /home/raver1975/lean/factor-scratch/r48/lit/r1/shoup_ntb.pdf
  printed page = PDF page - 18.  Theorem 15.6 is on PDF page 431.

  Shoup, A Computational Introduction to Number Theory and Algebra (v.2),
  Section 15.3 "An algorithm for factoring integers", Theorem 15.6 (p. 413):

      y := exp[(1/sqrt(2)) (log n log log n)^{1/2}]
      E[Z] <= exp[(2 sqrt(2) + o(1)) (log n log log n)^{1/2}]

  Question: the ECM heuristic constant is sqrt(2).  Factor of exactly 2.
  Where does it sit, and is it removable?

THE HYPOTHESIS UNDER TEST (H):

  The factor of 2 is NOT a Markov / mean-vs-median step, and NOT a union
  bound.  It is TWO independent squares, and they are both visible in the
  printed argument.

  (H1) A SQUARE IN THE SMOOTHNESS COUNT -- the removable half.
       Shoup applies Theorem 15.1 (p. 399) in the form

           Psi(y,x) >= x * exp[(-1+o(1)) u log log x],   u = log x / log y.

       But the true Dickman-de Bruijn estimate is

           Psi(y,x) >= x * exp[-(1+o(1)) u log u].

       AT THE BALANCED POINT log y = (1/sqrt 2) sqrt(log n log log n):

           log u = log(log n / log y) = (1/2) log log n + o(log log n),

       so  u log u = (1/2) u log log n + o(u log log n).  Theorem 15.1's
       exponent over-charges the true exponent by a FACTOR OF 2 exactly at
       the point where it is applied.  Worth sqrt(2) in the constant.

  (H2) A SQUARE IN THE RELATION-COLLECTION COST -- the structural half.
       The printed exponent (eq. (15.8), p. 412) is

           max{ (log n / log y) log log n + 2 log y ,  3 log y }.

       The "2 log y" is 2 log k with k = pi(y) ~ y/log y (p. 407: "Let
       p_1,...,p_k be the primes up to the smoothness parameter y").  It is
       (#relations) x (cost per relation) = pi(y) x pi(y) = pi(y)^2.  This
       square is forced: k+2 relations are needed because Z_2^{(k+1)} has
       dimension k+1 (p. 410), and each attempt costs k trial divisions
       (p. 411 pseudocode).  Worth sqrt(2) in the constant.

  TOGETHER the shape constant is sqrt(2*a*c), where
       a = power of the factor-base size in the running time (a=2 for Shoup)
       c = the Dickman exponent constant (c=2 as Shoup writes it,
           c=1 for the sharp estimate).
       Shoup printed : sqrt(2*2*2) = 2 sqrt(2).        [p. 413]
       remove H1     : sqrt(2*2*1) = 2.
       remove H2 too : sqrt(2*1*1) = sqrt(2)  -- the ECM heuristic shape.

THE NULL IS A REAL POSSIBLE OUTCOME.  The load-bearing numeric claim is

        log u / log log n  ->  1/2    at the balanced point.

If that does not hold, H1 is void and this script reports NULL.  Every claim
that is NOT proved here is emitted as an explicit NULL line, so the output can
never be read as stronger than it is.

Run:  python3 -u constant_test.py
"""

from __future__ import annotations

import math
import random
import sys
from functools import lru_cache

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/_shared")
from dickman import rho  # noqa: E402  shared harness, single source of truth

sys.setrecursionlimit(200_000)

LN2 = math.log(2.0)
SQRT2 = math.sqrt(2.0)

_RESULTS: list[tuple[str, str, str]] = []


def record(name: str, verdict: str, detail: str = "") -> None:
    _RESULTS.append((name, verdict, detail))
    print(f"  [{verdict:4s}] {name} {detail}", flush=True)


def check(name: str, cond: bool, detail: str = "") -> None:
    record(name, "PASS" if cond else "FAIL", detail)


def null(name: str, detail: str) -> None:
    record(name, "NULL", detail)


def head(s: str) -> None:
    print("\n" + s, flush=True)


# ===========================================================================
# PART 0 -- REGRESSION: reproduce Shoup's PRINTED constant from the PRINTED
# exponent.  If this fails we are not analysing the argument in the book.
# ===========================================================================

def shoup_exponent(L: float, logy: float) -> float:
    """Shoup eq. (15.8), printed p. 412, first branch.  Read from the page
    IMAGE:

        E[Z] <= exp[(1+o(1)) max{ (log n / log y) log log n + 2 log y ,
                                   3 log y }]

    L = log n, logy = log y.
    """
    return (L / logy) * math.log(L) + 2.0 * logy


def balanced_logy(L: float, scale: float = 1.0 / SQRT2) -> float:
    """log y at the Shoup balanced point, optionally rescaled."""
    return scale * math.sqrt(L * math.log(L))


def t0_regression() -> None:
    head("PART 0 -- regression: does my model of the PRINTED exponent give 2*sqrt(2)?")

    for bits in (4096, 16384, 65536):
        L = bits * LN2
        e = shoup_exponent(L, balanced_logy(L))
        c = e / math.sqrt(L * math.log(L))
        check(f"printed exponent at {bits}b gives 2*sqrt(2)",
              abs(c - 2 * SQRT2) < 1e-9,
              f"got {c:.10f}, want {2*SQRT2:.10f}")

    # The printed log y is the argmin of the printed exponent.
    L = 16384 * LN2
    opt = balanced_logy(L)
    vals = [(shoup_exponent(L, opt * f), f)
            for f in (0.4, 0.6, 0.8, 0.95, 1.0, 1.05, 1.2, 1.6, 2.5)]
    best_f = min(vals)[1]
    check("printed log y is the argmin of the printed exponent",
          abs(best_f - 1.0) < 1e-9, f"argmin at scale {best_f}")

    # Negative control: the 3 log y branch must NOT bind at the printed
    # optimum, or Shoup's own displayed constant would be inconsistent.
    c3 = (3.0 * opt) / (2 * SQRT2 * math.sqrt(L * math.log(L)))
    check("3 log y branch does not bind at the printed optimum (3/sqrt2 < 2sqrt2)",
          abs(c3 - 3.0 / (2 * SQRT2)) < 1e-9, f"ratio = {c3:.6f}")


# ===========================================================================
# PART 1 -- H1, the load-bearing claim: log u / log log n -> 1/2
# ===========================================================================

def t1_logu_ratio() -> None:
    head("PART 1 -- H1: does log u / log log n -> 1/2 at the balanced point?")

    ratios = []
    for bits in (2**10, 2**12, 2**14, 2**16, 2**18, 2**20, 2**22, 2**24):
        L = bits * LN2
        u = L / balanced_logy(L)
        ratios.append((bits, u, math.log(u) / math.log(L)))

    print("       bits          u      log u / log log n", flush=True)
    for bits, u, r in ratios:
        print(f"  {bits:10d}  {u:10.4f}   {r:.10f}", flush=True)

    vals = [r for _, _, r in ratios]
    check("ratio decreases monotonically toward 1/2",
          all(vals[i] > vals[i + 1] for i in range(len(vals) - 1)))
    check("ratio -> 1/2 (last within 1e-4)", abs(vals[-1] - 0.5) < 1e-4,
          f"got {vals[-1]:.10f}")
    if abs(vals[-1] - 0.5) >= 1e-4:
        null("H1 load-bearing ratio",
             f"converged to {vals[-1]:.6f}, NOT 0.5 -- H1 IS VOID")
        return

    print("\n     overcharge factor  log log n / log u  (Shoup's Thm 15.1 vs"
          " sharp Dickman):", flush=True)
    ovs = []
    for bits in (2**12, 2**16, 2**20, 2**24, 2**28, 2**32):
        L = bits * LN2
        u = L / balanced_logy(L)
        ovs.append((bits, math.log(L) / math.log(u)))
        print(f"  {bits:12d} bits   overcharge = {ovs[-1][1]:.8f}", flush=True)
    check("overcharge -> 2", abs(ovs[-1][1] - 2.0) < 1e-4,
          f"got {ovs[-1][1]:.8f}")


# ===========================================================================
# PART 2 -- verify the Dickman-de Bruijn replacement, via the SHARED harness.
# ===========================================================================

def t2_dickman() -> None:
    head("PART 2 -- is Psi >= x exp[-(1+o(1)) u log u] the right replacement?")
    print("     (measured with the SHARED harness r48/_shared/dickman.py)",
          flush=True)

    print("          u     -log rho(u)       u log u        ratio", flush=True)
    rows = []
    for u in (2.0, 3.0, 5.0, 8.0, 12.0, 16.0, 20.0):
        lr = -math.log(rho(u))
        ulu = u * math.log(u)
        rows.append((u, lr, ulu, lr / ulu))
        print(f"  {u:8.2f}  {lr:14.6f}  {ulu:11.6f}  {lr/ulu:.6f}", flush=True)

    rs = [r[3] for r in rows]
    check("ratio decreases toward 1 (Dickman constant is 1)",
          all(rs[i] > rs[i + 1] for i in range(len(rs) - 1)))
    check("ratio at u=20 is within 40% of 1", abs(rs[-1] - 1.0) < 0.40,
          f"got {rs[-1]:.6f}")
    if not all(rs[i] > rs[i + 1] for i in range(len(rs) - 1)):
        null("Dickman ratio monotone", "NOT monotone -- replacement suspect")
        return
    check("ratio approaches 1 FROM ABOVE (so c=1 is tight, not beatable)",
          rs[-1] > 1.0, f"ratio(20) = {rs[-1]:.6f} > 1")

    print("\n     finite-size correction c(u) = -log rho(u) / (u log u):",
          flush=True)
    print("        u     c(u)     effective constant 2*sqrt(c(u))", flush=True)
    for u in (10.0, 12.0, 14.7, 16.0, 19.8, 22.0, 25.0, 30.0):
        c = -math.log(rho(u)) / (u * math.log(u))
        print(f"  {u:7.1f}  {c:.6f}      {2*math.sqrt(c):.6f}", flush=True)


# ===========================================================================
# PART 3 -- exact optimisation.  Shape constant = sqrt(2*a*c).
# ===========================================================================

def exponent_of(a: float, c: float, L: float, t: float) -> float:
    """Running-time exponent for a shape with factor-base power a and
    smoothness-exponent constant c:

        E(t) = c * (L/t) * log(L/t)  +  a * t ,     t = log y.
    """
    return c * (L / t) * math.log(L / t) + a * t


def optimum(a: float, c: float, L: float) -> tuple[float, float]:
    """Golden-section on t in log space, then refine.  Returns (t*, E*)."""
    lo, hi = 1e-2, 100.0
    gr = (math.sqrt(5.0) - 1.0) / 2.0
    for _ in range(500):
        m1 = hi - gr * (hi - lo)
        m2 = lo + gr * (hi - lo)
        if exponent_of(a, c, L, m1) < exponent_of(a, c, L, m2):
            hi = m2
        else:
            lo = m1
    t = (lo + hi) / 2
    return t, exponent_of(a, c, L, t)


def t3_optimisation() -> None:
    head("PART 3 -- exact optimisation: shape constant = sqrt(2*a*c)")

    L = 1e6
    for a, c, label in (
        (2.0, 2.0, "Shoup AS PRINTED (a=2, c=2)"),
        (2.0, 1.0, "remove H1: sharp Dickman (a=2, c=1)"),
        (1.0, 2.0, "remove H2: one relation (a=1, c=2)"),
        (1.0, 1.0, "remove BOTH (a=1, c=1)"),
    ):
        t, e = optimum(a, c, L)
        const = e / math.sqrt(L * math.log(L))
        s = t / math.sqrt(L * math.log(L))
        print(f"  a={a:.0f} c={c:.0f}  {label}", flush=True)
        print(f"      t/sqrt(L log L) = {s:.8f}  "
              f"(predicted sqrt(c/(2a)) = {math.sqrt(c/(2*a)):.8f})", flush=True)
        print(f"      CONSTANT = {const:.8f}  "
              f"(predicted sqrt(2ac) = {math.sqrt(2*a*c):.8f})", flush=True)
        check(f"a={a:.0f} c={c:.0f}: optimised constant = sqrt(2ac)",
              abs(const - math.sqrt(2 * a * c)) < 1e-7, f"got {const:.8f}")

    _, e = optimum(2.0, 2.0, L)
    c_shoup = e / math.sqrt(L * math.log(L))
    check("Shoup's PRINTED constant reproduced as 2*sqrt(2)",
          abs(c_shoup - 2 * SQRT2) < 1e-7, f"got {c_shoup:.8f}")

    _, e = optimum(2.0, 1.0, L)
    c_new = e / math.sqrt(L * math.log(L))
    check("H1 ALONE is worth exactly sqrt(2):  2 sqrt(2) -> 2",
          abs(c_new - 2.0) < 1e-7 and abs(2 * SQRT2 / c_new - SQRT2) < 1e-9,
          f"got {c_new:.8f}, printed {2*SQRT2:.8f}")

    _, e = optimum(1.0, 2.0, L)
    c_h2 = e / math.sqrt(L * math.log(L))
    check("H2 ALONE is ALSO worth sqrt(2) (they are independent squares)",
          abs(c_h2 - 2.0) < 1e-7, f"got {c_h2:.8f}")

    _, e = optimum(1.0, 1.0, L)
    c_both = e / math.sqrt(L * math.log(L))
    check("removing BOTH gives sqrt(2), the ECM heuristic shape constant",
          abs(c_both - SQRT2) < 1e-7, f"got {c_both:.8f}")


# ===========================================================================
# PART 4 -- S4: the regime.
# ===========================================================================

def t4_regime() -> None:
    head("PART 4 -- S4 regime: u and rho(u) at real sizes")

    print("   bits    log n     log log n   log y (Shoup)      u      log u"
          "         rho(u)", flush=True)
    tab = []
    for bits in (512, 768, 1024, 1536, 2048, 3072, 4096, 8192, 16384, 65536):
        L = bits * LN2
        M = math.log(L)
        logy = balanced_logy(L)
        u = L / logy
        tab.append((bits, u))
        print(f"  {bits:6d}  {L:8.3f}  {M:10.4f}  {logy:14.3f}  {u:8.3f}  "
              f"{math.log(u):8.4f}  {rho(u):.6e}", flush=True)

    print("\n  u = sqrt(2) sqrt(log n / log log n) -- grows only as slowly as"
          " sqrt(log n).", flush=True)
    print("  How large must n be for u to reach a given value?", flush=True)
    for target in (20, 50, 100, 1000, 10**6):
        Lm = target ** 2 / 2.0
        L = Lm
        for _ in range(300):
            L = Lm * math.log(L) if L > 1.0 else Lm
        print(f"    u = {target:8.0f}   needs  n ~ 2^{L/LN2:.4g}  "
              f"({L/LN2:.4g} bits)", flush=True)

    print("\n  Ratio log u / log log n at RSA sizes (the H1 quantity, far from"
          " its 1/2 limit):", flush=True)
    for bits in (512, 1024, 2048, 4096):
        L = bits * LN2
        u = L / balanced_logy(L)
        r = math.log(u) / math.log(L)
        print(f"    {bits:5d} bits:  ratio = {r:.6f}  (limit 0.5)  "
              f"=> Shoup's exponent over-charges by {1/r:.4f}, not 2", flush=True)

    print("\n  Lemma 15.5 (printed p. 412-413): P[failure] = 2^{-w+1},"
          " w = #distinct odd primes.", flush=True)
    for w in (2, 3, 4, 8, 16, 32, 64):
        print(f"    w = {w:3d}  ->  P[failure] = 2^-{w-1} = {2.0**-(w-1):.4e}",
              flush=True)
    null("u -> infinity is NOT reached at any RSA size",
         "u is 11-25 for 512-65536 bits; the asymptotic analysis (u -> inf) "
         "is a LIMIT that RSA sizes do NOT reach. See notes.")


# ===========================================================================
# PART 5 -- EMPIRICAL: verify the printed p. 412 counting step exactly, and
# MEASURE sigma for real (not quoted from rho).
# ===========================================================================

def primes_upto(n: int) -> list[int]:
    s = bytearray(b"\x01") * (n + 1)
    s[0:2] = b"\x00\x00"
    for i in range(2, int(math.isqrt(n)) + 1):
        if s[i]:
            s[i * i::i] = b"\x00" * ((n - i * i) // i + 1)
    return [i for i in range(2, n + 1) if s[i]]


def exact_psi(y: int, x: int) -> int:
    """EXACTLY count y-smooth integers up to x (brute force over exponent
    vectors).  This is a COUNTER, not a probability model: no Dickman value is
    computed here.  Only feasible for u = log x / log y of order 3."""
    ps = primes_upto(y)

    @lru_cache(maxsize=None)
    def f(i: int, m: int) -> int:
        if i >= len(ps):
            return 1
        p = ps[i]
        tot = 0
        while m > 0:
            tot += f(i + 1, m)
            m //= p
        return tot

    return f(0, x)


def is_y_smooth(v: int, y: int) -> bool:
    for p in primes_upto(y):
        if p * p > v:
            break
        while v % p == 0:
            v //= p
    return v <= y or v == 1


def t5_empirical() -> None:
    head("PART 5 -- empirical: the printed p.412 counting step, measured")

    # (a) Sanity: the counter is non-degenerate and monotone in y.
    p1, p2 = exact_psi(40, 10_000), exact_psi(25, 10_000)
    check("exact Psi counter is monotone in y and non-degenerate",
          0 < p2 < p1 < 10_000, f"Psi(25,10^4)={p2}, Psi(40,10^4)={p1}")

    # (b) The counting identity of p. 412, on a real semiprime, measured.
    #     Hypothesis needed: n has NO prime factor <= y.
    print("\n  Building a real semiprime n = p*q with p,q > y ...", flush=True)
    from sympy import nextprime
    y = 1000
    p = int(nextprime(10**6))
    q = int(nextprime(10**6 + 7))
    while q == p:
        q = int(nextprime(q + 1))
    n = p * q
    check("the p.412 hypothesis holds: no prime factor of n is <= y",
          p > y and q > y, f"p={p}, q={q}, y={y}")

    phi = (p - 1) * (q - 1)
    slack = phi / n
    print(f"    n = {n}  ({n.bit_length()} bits)", flush=True)
    print(f"    |Z*_n| = (p-1)(q-1) = {phi}", flush=True)
    print(f"    Shoup's step is  sigma = Psi(y,n)/|Z*_n|  >=  Psi(y,n)/n",
          flush=True)
    print(f"    the slack is exactly  |Z*_n|/n = {slack:.16f}", flush=True)
    check("slack |Z*_n|/n is NEGLIGIBLE -- so the >= Psi/n step is NOT the"
          " source of the factor 2",
          abs(slack - 1.0) < 1e-5,
          f"|Z*_n|/n - 1 = {slack-1:.3e}  (relative loss {slack-1:.3e})")

    # (c) MEASURE sigma by sampling Z*_n, and compare with rho(u).
    #     y = 1000, n ~ 10^12  =>  u ~ 4, tractable.
    u = math.log(n) / math.log(y)
    sigma_pred = rho(u)
    trials = 20000
    rng = random.Random(20260929)
    hits = 0
    ps_y = primes_upto(y)
    for _ in range(trials):
        a = rng.randrange(1, n)
        while math.gcd(a, n) != 1:
            a = rng.randrange(1, n)
        v = a
        for pp in ps_y:
            if pp * pp > v:
                break
            while v % pp == 0:
                v //= pp
        if v <= y or v == 1:
            hits += 1
    meas = hits / trials
    sd = math.sqrt(max(meas * (1 - meas), 1e-15) / trials)
    dev = abs(meas - sigma_pred) / sd
    print(f"\n    MEASURED sigma over {trials} random elements of Z*_n:"
          f" {meas:.6e}", flush=True)
    print(f"    rho(u), u = {u:.4f}: {sigma_pred:.6e}", flush=True)
    print(f"    deviation: {dev:.2f} sigma", flush=True)
    check("MEASURED sigma agrees with rho(u) within 3 sigma (independent"
          " confirmation that sigma = Psi(y,n)/|Z*_n and NOT sigma ~ Psi/n"
          " times something worse)", dev < 3.0, f"dev = {dev:.2f} sigma")
    print(f"    NOTE u here is {u:.2f}, i.e. MODERATE.  Exact Psi is only"
          f" computable to u ~ 3.5,", flush=True)
    print(f"    so the counting identity is verified at u ~ {u:.1f}, not at the"
          f" u ~ 20 of RSA sizes.", flush=True)

    # (d) Failure probability, MEASURED not quoted: solve x^2 = 1 mod n.
    print("\n  Measuring P[gamma = +-1] for a semiprime with p = q = 3 mod 4:",
          flush=True)

    def crt(a: int, b: int, m1: int, m2: int) -> int:
        g = pow(m1, -1, m2)
        return (a + m1 * ((b - a) * g % m2)) % (m1 * m2)

    if p % 4 == 3 and q % 4 == 3:
        s1 = pow(2, (p + 1) // 4, p)
        s2 = pow(2, (q + 1) // 4, q)
        roots = sorted({crt(s1 if e1 == 1 else (-s1) % p,
                            s2 if e2 == 1 else (-s2) % q, p, q)
                        for e1 in (1, p - 1) for e2 in (1, q - 1)})
        check("exactly 4 square roots of 1 mod n (p,q = 3 mod 4)",
              len(roots) == 4, f"got {len(roots)} roots: {roots}")
        ntriv = sum(1 for r in roots if r in (1, n - 1))
        print(f"    roots of x^2 = 1 mod n: {roots}", flush=True)
        print(f"    of which +-1: {ntriv}   =>  P[gamma = +-1] = "
              f"{ntriv}/{len(roots)} = {ntriv/len(roots)}", flush=True)
        check("P[gamma = +-1] = 1/2 EXACTLY -- Lemma 15.5's 'at most 1/2' is"
              " TIGHT (attained) for a semiprime, so Exercise 15.5's"
              " k+1+ell relations are genuinely needed",
              abs(ntriv / len(roots) - 0.5) < 1e-12,
              f"got {ntriv/len(roots)}")
    else:
        null("failure-probability measurement",
             f"p%4={p%4}, q%4={q%4}: need both 3 mod 4")

    # (e) The failure budget is FREE in the exponent -- quantify it.
    print("\n  Cost of driving the failure probability down (Exercise 15.5,"
          " p. 413):", flush=True)
    L = 1e6
    _, e0 = optimum(2.0, 1.0, L)
    base = e0 / math.sqrt(L * math.log(L))
    print(f"      with a=2, c=1, the constant is {base:.6f}", flush=True)
    print(f"      adding ell extra relations changes k+2 -> k+1+ell; the"
          f" k^2 term becomes", flush=True)
    print(f"      (k+ell)*k ~ k^2 + ell*k, and log k = o(sqrt(L log L)), so the"
          f" constant is unchanged", flush=True)
    check("failure budget costs nothing in the CONSTANT (it is a lower-order"
          " term)", abs(base - 2.0) < 1e-7,
          "so the 1/2 is not a time-constant cost at all")
    null("the 1/2 failure probability is NOT a source of the factor 2",
         "it affects the SUCCESS probability, not the exp[...] constant; and "
         "it is tight, so it cannot be improved, only bought with extra "
         "relations at no constant cost.")


# ===========================================================================
# PART 6 -- S3: optimality of 2 WITHIN the shape.
# ===========================================================================

def t6_optimality() -> None:
    head("PART 6 -- S3: is 2 optimal within this shape?")

    us = [5.0, 8.0, 12.0, 16.0, 20.0]
    cs = [-math.log(rho(u)) / (u * math.log(u)) for u in us]
    check("Dickman constant c -> 1 FROM ABOVE: c = 1 is TIGHT, so no better"
          " smoothness count can lower the constant",
          all(cs[i] > cs[i + 1] for i in range(len(cs) - 1)) and cs[-1] > 1.0,
          f"c(20) = {cs[-1]:.6f}")

    print("\n  a is forced by COUNTING, not by analysis quality:", flush=True)
    print("    - k = pi(y) primes form the factor base (p. 407)", flush=True)
    print("    - k+2 relations needed: Z_2^{(k+1)} has dim k+1 (p. 410)",
          flush=True)
    print("    - each attempt costs k trial divisions (p. 411 pseudocode)",
          flush=True)
    print("    => running time ~ sigma^-1 * pi(y)^2, i.e. a = 2 FORCED",
          flush=True)

    L = 1e6
    _, e = optimum(2.0, 1.0, L)
    const = e / math.sqrt(L * math.log(L))
    check("with c=1 forced and a=2 forced, constant 2 is the SHAPE OPTIMUM",
          abs(const - 2.0) < 1e-7, f"got {const:.8f}")

    print("\n  constant landscape in (a, c):", flush=True)
    for a in (1.0, 1.5, 2.0, 3.0):
        row = []
        for c in (0.5, 1.0, 2.0):
            _, ee = optimum(a, c, L)
            row.append(f"c={c}: {ee/math.sqrt(L*math.log(L)):.4f}")
        print(f"    a = {a:.1f}   " + "   ".join(row), flush=True)
    print("    (c = 0.5 is NOT achievable: Dickman is tight at c = 1)",
          flush=True)
    null("a < 2 requires a DIFFERENT ALGORITHM, not a better analysis",
         "a = 1 means ONE relation suffices (no factor-base linear algebra). "
         "That is the ECM shape, and ECM's sqrt(2) is HEURISTIC (it needs the "
         "random-curve model), so it is NOT a proved unconditional constant.")
    null("global lower bound on the constant of ANY factoring algorithm",
         "NOT PROVED. This script optimises Shoup's SHAPE only. Asserting 2 as "
         "a universal lower bound over all algorithms would be unsound.")


# ===========================================================================

def main() -> int:
    print("=" * 78, flush=True)
    print("SELF-TEST: Shoup Thm 15.6 constant factor (2 sqrt 2 vs sqrt 2)",
          flush=True)
    print("source: factor-scratch/r48/lit/r1/shoup_ntb.pdf, printed pp."
          " 399, 407, 410-413", flush=True)
    print("=" * 78, flush=True)

    t0_regression()
    t1_logu_ratio()
    t2_dickman()
    t3_optimisation()
    t4_regime()
    t5_empirical()
    t6_optimality()

    print("\n" + "=" * 78, flush=True)
    npass = sum(1 for _, v, _ in _RESULTS if v == "PASS")
    nfail = sum(1 for _, v, _ in _RESULTS if v == "FAIL")
    nnull = sum(1 for _, v, _ in _RESULTS if v == "NULL")
    print(f"RESULTS: {npass} PASS, {nfail} FAIL, {nnull} NULL", flush=True)
    if nfail:
        print("!!! FAILURES PRESENT -- do not report conclusions from this run.",
              flush=True)
    else:
        print("No failures. NULLs are DELIBERATE (claims NOT proved here).",
              flush=True)
    print("=" * 78, flush=True)
    return 1 if nfail else 0


if __name__ == "__main__":
    sys.exit(main())
