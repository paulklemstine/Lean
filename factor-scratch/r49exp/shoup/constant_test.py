#!/usr/bin/env python3
"""
SELF-TEST for the Shoup Theorem 15.6 constant-factor question.

SOURCE (local PDF, read as PAGE IMAGES -- pdftotext mangles the radicals):
  /home/raver1975/lean/factor-scratch/r48/lit/r1/shoup_ntb.pdf
  printed page = PDF page - 18.

  Shoup, A Computational Introduction to Number Theory and Algebra (v.2),
  Section 15.3 "An algorithm for factoring integers", Theorem 15.6 (p. 413):

      y := exp[(1/sqrt(2)) (log n log log n)^{1/2}]
      E[Z] <= exp[(2 sqrt(2) + o(1)) (log n log log n)^{1/2}]

  The ECM heuristic constant is sqrt(2).  Factor of exactly 2.
  Where does it sit, and is it removable?

THE HYPOTHESIS UNDER TEST (H)
-----------------------------
Not a Markov / mean-vs-median step.  Not a union bound.  TWO independent
squares, both visible in the printed argument.

  (H1) A SQUARE IN THE SMOOTHNESS COUNT -- the removable half.
       Shoup applies Theorem 15.1 (p. 399) in the form

           Psi(y,x) >= x * exp[(-1+o(1)) u log log x],   u = log x / log y.

       The true Dickman-de Bruijn estimate is

           Psi(y,x) >= x * exp[-(1+o(1)) u log u].

       AT THE BALANCED POINT log y = (1/sqrt 2) sqrt(log n log log n):

           log u = log(log n / log y) = (1/2) log log n + o(log log n),

       so u log u = (1/2) u log log n + o(u log log n).  Theorem 15.1's
       exponent over-charges the true exponent by a FACTOR OF 2 exactly at
       the point where it is applied.  Worth sqrt(2) in the constant.

  (H2) A SQUARE IN THE RELATION-COLLECTION COST -- the structural half.
       The printed exponent, eq. (15.8) on p. 412, is

           max{ (log n / log y) log log n + 2 log y ,  3 log y }.

       The "2 log y" is 2 log k with k = pi(y) ~ y/log y (p. 407: "Let
       p_1,...,p_k be the primes up to the smoothness parameter y").  It is
       (#relations) x (cost per relation) = pi(y) x pi(y) = pi(y)^2.  This
       square is forced: k+2 relations are needed because Z_2^{(k+1)} has
       dimension k+1 (p. 410), and each attempt costs k trial divisions
       (p. 411 pseudocode).  Worth sqrt(2) in the constant.

  TOGETHER the shape constant is sqrt(2*a*c), with
       a = power of the factor-base size in the running time (a = 2 here),
       c = the Dickman exponent constant (c = 2 as Shoup writes it,
           c = 1 for the sharp estimate).
       Shoup printed : sqrt(2*2*2) = 2 sqrt(2).            [p. 413]
       remove H1     : sqrt(2*2*1) = 2.
       remove H2 too : sqrt(2*1*1) = sqrt(2)   -- the ECM heuristic shape.

HOW THE CONSTANT IS EXTRACTED (this matters; getting it wrong is the first
version of this script's bug)
----------------------------------------------------------------------------
The constant is an ASYMPTOTIC quantity: it is the limit of
E(log y)/sqrt(log n log log n) as n -> infinity.  Evaluating that ratio at
a concrete n does NOT give the constant -- at log n = 1e6 it is 7% low, and
it only converges as log n -> infinity.  So the optimiser below works with
L = log n, sets log y = s*sqrt(L log L), and reports

    R_L(s) = E / sqrt(L log L)
           = (c/s) * [ 1/2 - (log log L)/(2 log L) - (log s)/(log L) ] + a*s
    ->  c/(2s) + a*s   as L -> infinity,

minimised at s = sqrt(c/(2a)) with value sqrt(2*a*c).  The test verifies
BOTH that the minimum converges to sqrt(2ac) AND that it reproduces Shoup's
printed 2*sqrt(2).

THE NULL IS A REAL POSSIBLE OUTCOME.  The load-bearing numeric claim is
        log u / log log n  ->  1/2   at the balanced point.
If that does not hold, H1 is void and this script reports NULL.  Claims that
are not proved here are emitted as explicit NULL lines, so the output can
never be read as stronger than it is.

Run:  python3 -u constant_test.py
"""

from __future__ import annotations

import math
import random
import sys
from functools import lru_cache

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/_shared")
from dickman import rho  # noqa: E402  shared harness, designated source of truth

sys.setrecursionlimit(300_000)

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
    """Shoup eq. (15.8), printed p. 412, first branch, read from the page
    IMAGE (pdftotext renders the radicals as "1/ 2" and "2 2"):

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

    L = 16384 * LN2
    opt = balanced_logy(L)
    vals = [(shoup_exponent(L, opt * f), f)
            for f in (0.4, 0.6, 0.8, 0.95, 1.0, 1.05, 1.2, 1.6, 2.5)]
    check("printed log y is the argmin of the printed exponent",
          abs(min(vals)[1] - 1.0) < 1e-9, f"argmin at scale {min(vals)[1]}")

    c3 = (3.0 * opt) / (2 * SQRT2 * math.sqrt(L * math.log(L)))
    check("3 log y branch does not bind at the printed optimum (ratio 3/4 < 1)",
          abs(c3 - 0.75) < 1e-9 and c3 < 1.0,
          f"3 log y = {c3:.6f} x the displayed constant")


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
    check("ratio INCREASES monotonically toward 1/2",
          all(vals[i] < vals[i + 1] for i in range(len(vals) - 1)),
          f"{vals[0]:.6f} -> {vals[-1]:.6f}")

    # Closed form.  u = sqrt(2 L / log L) at the balanced point, so
    #   log u / log L = 1/2 - (1/2)(log log L)/(log L) + (1/2)(log 2)/(log L),
    # i.e. the ratio approaches 1/2 from BELOW at rate (log log L)/(2 log L).
    # Adding the first correction term back must give 1/2 to high precision.
    print("\n     asymptote: ratio = 1/2 - (1/2)(log log L)/(log L)"
          " + (1/2)(ln2)/(log L)", flush=True)
    resid = []
    for bits, u, r in ratios:
        L = bits * LN2
        corr = 0.5 - 0.5 * math.log(math.log(L)) / math.log(L) \
            + 0.5 * math.log(2.0) / math.log(L)
        resid.append(abs(corr - r))
        print(f"  {bits:10d} bits   measured {r:.10f}   formula {corr:.10f}"
              f"   |diff| {abs(corr-r):.2e}", flush=True)
    check("measured ratio matches the closed form to 1e-9 at every size",
          max(resid) < 1e-9, f"worst |diff| = {max(resid):.3e}")

    # And the limit really is 1/2: push L far out and watch it approach.
    print("\n     pushing log n to absurd sizes:", flush=True)
    # Work with e = log L (= log log n) directly; L = exp(e) overflows for
    # e > 709, and only e is needed.
    # The gap is exactly (log e - log 2)/(2e), so it closes like (log e)/e:
    # e = 1e4 leaves 4.6e-4, e = 1e6 leaves 6.9e-6.  Use e = 1e6 so a 1e-5
    # tolerance is meaningful rather than a tolerance-failure.
    for e in (10, 30, 100, 300, 1000, 3000, 10000, 10**6):
        r = (0.5 * e - 0.5 * math.log(e) + 0.5 * math.log(2.0)) / e
        print(f"  log log n = {e:6.0f}   ratio = {r:.10f}"
              f"   gap = {0.5-r:.2e}", flush=True)
    e = 10**6
    r_last = (0.5 * e - 0.5 * math.log(e) + 0.5 * math.log(2.0)) / e
    check("ratio -> 1/2 (within 1e-5 at log log n = 10^6)",
          abs(r_last - 0.5) < 1e-5, f"got {r_last:.10f}")
    if abs(r_last - 0.5) >= 1e-4:
        null("H1 load-bearing ratio",
             f"converged to {r_last:.6f}, NOT 0.5 -- H1 IS VOID")
        return

    print("\n     overcharge factor  log log n / log u  (Shoup's Thm 15.1"
          " vs sharp Dickman):", flush=True)
    # overcharge = 1/ratio, so it closes like 2 + (log e)/e on e = log log n.
    for e in (10, 30, 100, 300, 1000, 10**4, 10**6, 10**8):
        r = (0.5 * e - 0.5 * math.log(e) + 0.5 * math.log(2.0)) / e
        print(f"  log log n = {e:9.0f}   overcharge = {1/r:.10f}"
              f"   gap = {1/r-2:.2e}", flush=True)
    # The gap is (log e - log 2)/e exactly, so at e = 1e8 it is 1.8e-7.
    e = 10**8
    r = (0.5 * e - 0.5 * math.log(e) + 0.5 * math.log(2.0)) / e
    ov = 1.0 / r
    check("overcharge -> 2 (within 1e-5 at log log n = 10^8)",
          abs(ov - 2.0) < 1e-5, f"got {ov:.10f}, gap {ov-2:.2e}")


# ===========================================================================
# PART 2 -- the Dickman-de Bruijn replacement, and a REGIME WARNING about the
# shared harness.
# ===========================================================================

def t2_dickman() -> None:
    head("PART 2 -- the replacement bound, and the shared harness's valid range")

    print("  Dickman-de Bruijn:  -log rho(u) ~ u (log u + log log u - 1)."
          "  The leading", flush=True)
    print("  constant is 1, so c=1 in the exponent is TIGHT (not improvable)."
          "  Using the", flush=True)
    print("  SHARED harness, which is the designated source of truth:", flush=True)
    print("        u     -log rho(u)      u log u        ratio c(u)", flush=True)
    # The harness is GUARDED (VALID_U_MAX = 5.0) and raises above that, so the
    # table stops at the guard.  c(u) = -log rho(u)/(u log u) must RISE to 1.
    for u in (1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0):
        r = rho(u)
        lr = -math.log(r)
        ulu = u * math.log(u)
        print(f"  {u:8.2f}  {lr:14.6f}  {ulu:11.6f}  {lr/ulu:.6f}", flush=True)
    cs = [(u, -math.log(rho(u)) / (u * math.log(u)))
          for u in (1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0)]
    # The rise is a u >= 2 statement: c(u) dips 0.8549 -> 0.8522 over [1.5, 2.0]
    # because the normaliser u*log u is ill-conditioned there.  From u = 2 on it
    # rises monotonically all the way to the guard at 5.
    check("shared harness c(u) rises monotonically toward 1 for 2 <= u <= 5"
          " (its whole usable range)", all(cs[i][1] < cs[i + 1][1]
                                          for i in range(1, len(cs) - 1)),
          "  ".join(f"u={u:.1f}:{c:.4f}" for u, c in cs))
    check("c(u) at the guard u=5 is already within 2% of the Dickman limit 1",
          abs(cs[-1][1] - 1.0) < 0.02, f"c(5) = {cs[-1][1]:.6f}")
    null("rho(u) at RSA sizes (u = 11..25)",
         "NOT MEASURED, and the shared harness cannot supply it: it is now "
         "correctly GUARDED to raise above u = 5.  Four independent attempts "
         "to build a validated local replacement all failed the same way -- "
         "see notes/GG_shoup_constant.md S4 for the h-convergence table.  The "
         "best scheme reached (log-space Simpson on the causal Volterra "
         "equation, arbitrary precision) is h-converged to 0.014% at u=5, "
         "0.2% at u=6 and 3.7% at u=7, then collapses (85% spread at u=8, "
         "19000% at u=10) because rho has fallen to ~1e-10 and the per-cell "
         "increment has dropped under the representable resolution of the "
         "running value.  So rho is trustworthy to u ~ 7 and NOT to u ~ 20.")
    print("\n     Consequently: -log rho(u) at RSA sizes is NOT measured here."
          "  The", flush=True)
    print("     de Bruijn leading form u(log u + log log u - 1) gives the"
          " CORRECT SCALE", flush=True)
    print("     (a 1-parameter asymptotic), and the next correction is"
          " u(log log u - 1)/log u:", flush=True)
    for u in (11.0, 15.0, 19.8, 25.0, 40.0):
        lead = u * (math.log(u) + math.log(math.log(u)) - 1)
        corr = lead + u * (math.log(math.log(u)) - 1) / math.log(u)
        print(f"    u = {u:5.1f}   -log rho ~ {lead:8.2f} (leading)"
              f"   {corr:8.2f} (1st corr.)   rho ~ e^-{corr:.1f}", flush=True)


# ===========================================================================
# PART 3 -- exact optimisation.  Shape constant = sqrt(2*a*c).
# ===========================================================================

def exponent_of(a: float, c: float, L: float, logy: float) -> float:
    """Running-time exponent for shape (a, c) at log y = logy, L = log n:

        E = c * (L / logy) * log(L / logy)  +  a * logy.
    """
    return c * (L / logy) * math.log(L / logy) + a * logy


def min_ratio(a: float, c: float, L: float) -> tuple[float, float]:
    """min over log y = s*sqrt(L log L) of E/sqrt(L log L).  Returns
    (min value, argmin s)."""
    best_v, best_s = float("inf"), None
    s = 0.02
    while s < 3.0:
        v = exponent_of(a, c, L, s * math.sqrt(L * math.log(L))) \
            / math.sqrt(L * math.log(L))
        if v < best_v:
            best_v, best_s = v, s
        s += 0.00002
    return best_v, best_s


def t3_optimisation() -> None:
    head("PART 3 -- exact optimisation: shape constant = sqrt(2*a*c)")

    Ls = [1e6, 1e20, 1e50, 1e100, 1e300]
    for a, c, label in (
        (2.0, 2.0, "Shoup AS PRINTED (a=2, c=2)"),
        (2.0, 1.0, "remove H1: sharp Dickman (a=2, c=1)"),
        (1.0, 2.0, "remove H2: one relation (a=1, c=2)"),
        (1.0, 1.0, "remove BOTH (a=1, c=1)"),
    ):
        pred = math.sqrt(2 * a * c)
        spred = math.sqrt(c / (2 * a))
        print(f"\n  a={a:.0f} c={c:.0f}  {label}", flush=True)
        print(f"      predicted constant sqrt(2ac) = {pred:.8f},"
              f"  predicted s* = sqrt(c/2a) = {spred:.6f}", flush=True)
        errs, last = [], None
        for L in Ls:
            v, s = min_ratio(a, c, L)
            err = abs(v - pred) / pred
            errs.append(err)
            last = (v, s)
            print(f"      L=1e{int(round(math.log10(L))):3d}  min={v:.8f}"
                  f"  s*={s:.6f}  err={err*100:.4f}%", flush=True)
        check(f"a={a:.0f} c={c:.0f}: constant converges DOWN to sqrt(2ac)",
              all(errs[i] > errs[i + 1] for i in range(len(errs) - 1)),
              f"errors {[f'{e*100:.3f}%' for e in errs]}")
        check(f"a={a:.0f} c={c:.0f}: argmin s* -> sqrt(c/2a)",
              abs(last[1] - spred) / spred < 0.02,
              f"s*={last[1]:.6f} vs {spred:.6f}")

    # The limit is approached from BELOW and slowly (the error is O(1/log L)),
    # so at L = 1e300 the numerical minimum is within 0.43% of the closed form.
    # 1% is the honest bar; tightening it would be fitting the truncation.
    TOL = 1e-2
    c_shoup = min_ratio(2.0, 2.0, 1e300)[0]
    check("Shoup's PRINTED constant reproduced as 2*sqrt(2)",
          abs(c_shoup - 2 * SQRT2) / (2 * SQRT2) < TOL,
          f"got {c_shoup:.8f}, want {2*SQRT2:.8f} "
          f"({abs(c_shoup-2*SQRT2)/(2*SQRT2)*100:.3f}% -- the O(1/log L) tail)")

    c_h1 = min_ratio(2.0, 1.0, 1e300)[0]
    check("H1 ALONE is worth sqrt(2):  2 sqrt(2) -> 2",
          abs(c_h1 - 2.0) / 2.0 < TOL and abs(2 * SQRT2 / c_h1 - SQRT2) < 0.01,
          f"got {c_h1:.8f}, printed {2*SQRT2:.8f}")

    c_h2 = min_ratio(1.0, 2.0, 1e300)[0]
    check("H2 ALONE is ALSO worth sqrt(2) (independent squares)",
          abs(c_h2 - 2.0) / 2.0 < TOL, f"got {c_h2:.8f}")

    c_both = min_ratio(1.0, 1.0, 1e300)[0]
    check("removing BOTH gives sqrt(2), the ECM heuristic shape constant",
          abs(c_both - SQRT2) / SQRT2 < TOL, f"got {c_both:.8f}")

    # The decisive ratio, which is truncation-free: removing H1 divides the
    # constant by sqrt(2) exactly, whatever the O(1/log L) tail.
    r1 = c_shoup / c_h1
    r2 = c_shoup / c_h2
    r3 = c_shoup / c_both
    check("ratio 2sqrt(2)/2 = sqrt(2) EXACTLY (H1)", abs(r1 - SQRT2) < 0.01,
          f"ratio = {r1:.8f}")
    check("ratio 2sqrt(2)/2 = sqrt(2) EXACTLY (H2)", abs(r2 - SQRT2) < 0.01,
          f"ratio = {r2:.8f}")
    check("ratio 2sqrt(2)/sqrt(2) = 2 EXACTLY (both)", abs(r3 - 2.0) < 0.02,
          f"ratio = {r3:.8f}")


# ===========================================================================
# PART 4 -- S4: the regime.
# ===========================================================================

def t4_regime() -> None:
    head("PART 4 -- S4 regime: u at real sizes")

    print("   bits    log n     log log n   log y (Shoup)      u      log u"
          "   log u/log log n", flush=True)
    for bits in (512, 768, 1024, 1536, 2048, 3072, 4096, 8192, 16384, 65536):
        L = bits * LN2
        M = math.log(L)
        logy = balanced_logy(L)
        u = L / logy
        r = math.log(u) / M
        print(f"  {bits:6d}  {L:8.3f}  {M:10.4f}  {logy:14.3f}  {u:8.3f}  "
              f"{math.log(u):8.4f}   {r:.6f}", flush=True)

    print("\n  u = sqrt(2) sqrt(log n / log log n).  At RSA-2048, u = 19.8."
          "  Shoup's own", flush=True)
    print("  hypothesis (no prime factor of n is <= y) forces y < sqrt(n),"
          " hence u > 2 always;", flush=True)
    print("  and u -> infinity only as slowly as sqrt(log n).", flush=True)

    print("\n  How large must n be for u to reach a given value?", flush=True)
    for target in (20, 50, 100, 1000, 10**6):
        Lm = target ** 2 / 2.0
        L = Lm
        for _ in range(400):
            L = Lm * math.log(L) if L > 1.0 else Lm
        print(f"    u = {target:8.0f}   needs  n ~ 2^{L/LN2:.4g}  "
              f"({L/LN2:.4g} bits)", flush=True)

    print("\n  The H1 overcharge at RSA sizes (limit is 2):", flush=True)
    for bits in (512, 1024, 2048, 4096, 16384):
        L = bits * LN2
        u = L / balanced_logy(L)
        r = math.log(u) / math.log(L)
        print(f"    {bits:6d} bits:  log u / log log n = {r:.6f}"
              f"   overcharge = {1/r:.4f}  (limit 2.0)", flush=True)

    print("\n  Lemma 15.5 (p. 412-413): P[failure] = 2^{-w+1},"
          " w = #distinct odd primes of n.", flush=True)
    for w in (2, 3, 4, 8, 16, 32, 64):
        print(f"    w = {w:3d}  ->  P[failure] = 2^-{w-1} = {2.0**-(w-1):.4e}",
              flush=True)
    null("u -> infinity is NOT reached at any RSA size",
         "u = 11.0 at 512 bits, 19.8 at 2048, 92 at 65536.  Reaching u = 100 "
         "needs a ~79000-bit modulus.  Every statement in Thm 15.6 is an "
         "o(1)-term asymptotic; at RSA sizes the o(1) is NOT small.")


# ===========================================================================
# PART 5 -- EMPIRICAL: the printed p. 412 counting step, measured.
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
    vectors).  A COUNTER, not a probability model: no Dickman value is
    computed here.  Feasible only for u = log x / log y of order 3."""
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


def t5_empirical() -> None:
    head("PART 5 -- empirical: the printed p.412 counting step, measured")

    # (a) Dickman's theorem at FIXED u = 2, where the limit is known exactly:
    #     Psi(x,y)/x -> rho(2) = 1 - ln 2.  This is the right test of the
    #     counter: u = 2 is a limit that the data approaches from above.
    print("\n  Dickman's theorem at fixed u=2: Psi(y^2,y)/y^2 -> 1 - ln 2 ="
          f" {1-math.log(2):.8f}", flush=True)
    T = 1 - math.log(2)
    prev = None
    mono = True
    for y in (2**5, 2**6, 2**7, 2**8, 2**9, 2**10, 2**11, 2**12, 2**13):
        x = y * y
        e = exact_psi(y, x) / x
        if prev is not None and e >= prev:      # must be strictly DECREASING
            mono = False
        prev = e
        print(f"    y=2^{int(math.log2(y)):2d}  exact Psi/x = {e:.8f}"
              f"   gap to 1-ln2 = {e-T:+.6f}", flush=True)
    check("exact Psi counter at fixed u=2 converges DOWN toward 1 - ln 2",
          mono, "counter is behaving like a smoothness counter should")
    check("shared harness rho(2) equals 1 - ln 2 to 1e-4",
          abs(rho(2.0) - T) < 1e-4,
          f"harness {rho(2.0):.8f} vs exact {T:.8f}, rel {abs(rho(2.0)-T)/T:.2e}")

    # (b) The counting identity of p. 412, on a real semiprime, exactly.
    print("\n  Shoup's p.412 step:  sigma = Psi(y,n)/|Z*_n|  >=  Psi(y,n)/n.",
          flush=True)
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
    print(f"    n = {n} ({n.bit_length()} bits),  |Z*_n| = {phi}", flush=True)
    print(f"    slack is exactly |Z*_n|/n = {slack:.16f}", flush=True)
    check("slack |Z*_n|/n is NEGLIGIBLE, so the '>= Psi/n' step is NOT the"
          " source of the factor 2",
          abs(slack - 1.0) < 1e-5, f"relative loss = {slack-1:.3e}")

    # (c) MEASURE sigma by sampling Z*_n, and compare against the EXACT
    #     Psi(y,n)/|Z*_n| -- not against rho(u), because Dickman's theorem is a
    #     LIMIT and at a 40-bit n it is nowhere near converged (part (a) shows
    #     an 8% gap at u=2 already).  So this is the honest comparison.
    #     Sized so that exact Psi(y,n) is computable: the memoised recursion
    #     costs about pi(y)*sqrt(n), so y=60, n~1e6 gives u ~ 3.4.
    from sympy import nextprime
    y = 60
    p = int(nextprime(10**3))
    while p <= y:
        p = int(nextprime(p + 1))
    q = int(nextprime(p + 7))
    while q == p or q <= y:
        q = int(nextprime(q + 1))
    n = p * q
    phi = (p - 1) * (q - 1)
    psi_exact = exact_psi(y, n)
    sigma_exact = psi_exact / phi          # Shoup's p.412 identity, EXACTLY
    u = math.log(n) / math.log(y)

    print(f"\n  Same identity at a size where exact Psi IS computable:"
          f"  n = {n}", flush=True)
    print(f"    p = {p}, q = {q}, y = {y}, u = {u:.4f}", flush=True)
    print(f"    Psi(y,n) = {psi_exact}   (EXACT)", flush=True)
    print(f"    |Z*_n|   = {phi}", flush=True)
    print(f"    sigma = Psi(y,n)/|Z*_n| = {sigma_exact:.8e}   <- EXACT prediction",
          flush=True)
    print(f"    Shoup's weaker Psi(y,n)/n  = {psi_exact/n:.8e}", flush=True)
    print(f"    shared-harness rho({u:.3f})   = {rho(u):.8e}"
          f"   <- NOT converged at this n", flush=True)

    trials = 200000
    rng = random.Random(20260929)
    ps_y = primes_upto(y)
    hits = 0
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
    sd = math.sqrt(max(sigma_exact * (1 - sigma_exact), 1e-15) / trials)
    dev = abs(meas - sigma_exact) / sd
    print(f"    MEASURED over {trials} random elements of Z*_n:"
          f" {meas:.8e}", flush=True)
    print(f"    deviation from the EXACT prediction: {dev:.2f} sigma", flush=True)
    check("MEASURED sigma matches the EXACT Psi(y,n)/|Z*_n| -- this validates"
          " Shoup's p.412 counting identity directly, with no Dickman model"
          " in the loop", dev < 3.5, f"dev = {dev:.2f} sigma")
    null("the counting identity at RSA-scale u ~ 20",
         f"verified at u = {u:.2f} only.  Exact Psi is computable to u ~ 3.5, so "
         f"the identity is NOT verified at the u = 19.8 of RSA-2048.  What IS "
         f"verified there is algebra, not counting: |Z*_n|/n = 1 - O(1/p) at "
         f"every size, so the '>= Psi/n' relaxation costs nothing regardless "
         f"of u.")

    # (d) Failure probability, MEASURED not quoted.
    print("\n  Measuring P[gamma = +-1] for a semiprime, p = q = 3 mod 4:",
          flush=True)

    def crt(a: int, b: int, m1: int, m2: int) -> int:
        g = pow(m1, -1, m2)
        return (a + m1 * ((b - a) * g % m2)) % (m1 * m2)

    p = int(nextprime(10**6))
    while p % 4 != 3:
        p = int(nextprime(p + 1))
    q = int(nextprime(p + 100))
    while q % 4 != 3 or q == p:
        q = int(nextprime(q + 1))
    n = p * q
    # For an odd prime the only roots of x^2 = 1 are +-1, so the four roots
    # mod pq are the CRT combinations of (+-1, +-1).
    roots = sorted({crt(a, b, p, q) for a in (1, p - 1) for b in (1, q - 1)})
    check("the four roots really do square to 1 mod n",
          all((r * r) % n == 1 for r in roots), f"roots = {roots}")
    check("exactly 4 square roots of 1 mod n (p,q = 3 mod 4)",
          len(roots) == 4, f"p={p} q={q} roots={roots}")
    ntriv = sum(1 for r in roots if r in (1, n - 1))
    print(f"    n = {n} ({n.bit_length()} bits)", flush=True)
    print(f"    roots of x^2 = 1 mod n: {roots}", flush=True)
    print(f"    of which +-1: {ntriv}  =>  P[gamma = +-1] = {ntriv/len(roots)}",
          flush=True)
    check("P[gamma = +-1] = 1/2 EXACTLY -- Lemma 15.5's 'at most 1/2' is TIGHT"
          " (attained) for a semiprime, so Exercise 15.5's extra relations"
          " are genuinely needed",
          abs(ntriv / len(roots) - 0.5) < 1e-12, f"got {ntriv/len(roots)}")

    # (e) The failure budget is free in the exponent.
    null("the 1/2 failure probability is NOT a source of the factor 2",
         "it affects the SUCCESS probability, not the exp[...] constant.  And "
         "it is TIGHT, so it cannot be improved analytically -- only bought "
         "with extra relations, which is a k+2 -> k+1+ell change.  Since "
         "log k = o(sqrt(L log L)), ell extra relations cost nothing in the "
         "constant.  So the 1/2 is orthogonal to the factor of 2.")


# ===========================================================================
# PART 6 -- S3: optimality of 2 WITHIN the shape.
# ===========================================================================

def t6_optimality() -> None:
    head("PART 6 -- S3: is 2 optimal within this shape?")

    # c = 1 is forced by the TIGHTNESS of Dickman's theorem: c(u) = 1 means
    # -log rho(u) ~ u log u, and the leading constant 1 cannot be lowered
    # (rho(u) = exp(-(1+o(1)) u log u) is a two-sided statement).
    # Verified on the shared harness where it is valid (u <= 6).
    us = [2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0]
    cs = [-math.log(rho(u)) / (u * math.log(u)) for u in us]
    check("Dickman constant c(u) rises monotonically toward 1 for 2 <= u <= 5:"
          " c = 1 is TIGHT, so no better smoothness count can lower the"
          " constant",
          all(cs[i] < cs[i + 1] for i in range(len(cs) - 1)) and cs[-1] < 1.0,
          "  ".join(f"u={u:.1f}:{c:.4f}" for u, c in zip(us, cs)))

    print("\n  a = 2 is forced by COUNTING, not by analysis quality:", flush=True)
    print("    - k = pi(y) primes form the factor base (p. 407)", flush=True)
    print("    - k+2 relations needed: Z_2^{(k+1)} has dim k+1 (p. 410)",
          flush=True)
    print("    - each attempt costs k trial divisions (p. 411 pseudocode)",
          flush=True)
    print("    => running time ~ sigma^-1 * pi(y)^2, so a = 2 FORCED", flush=True)

    c2 = min_ratio(2.0, 1.0, 1e300)[0]
    check("with c=1 forced and a=2 forced, constant 2 is the SHAPE OPTIMUM",
          abs(c2 - 2.0) / 2.0 < 1e-2,
          f"got {c2:.8f} ({abs(c2-2)/2*100:.3f}% -- O(1/log L) tail)")

    print("\n  constant landscape sqrt(2*a*c):", flush=True)
    for a in (1.0, 1.5, 2.0, 3.0):
        row = "   ".join(
            f"c={c}: {math.sqrt(2*a*c):.4f}" for c in (0.75, 1.0, 2.0))
        print(f"    a = {a:.1f}   {row}", flush=True)
    print("    (c < 1 is NOT achievable: Dickman is tight at c = 1)", flush=True)

    null("a < 2 requires a DIFFERENT ALGORITHM, not a better analysis",
         "a = 1 means ONE relation suffices, i.e. no factor-base linear "
         "algebra.  That is the ECM shape, and ECM's sqrt(2) is HEURISTIC -- "
         "it needs the random-curve smoothness model, not a counting bound.  "
         "So sqrt(2) is NOT a proved unconditional constant for factoring.")
    null("global lower bound on the constant of ANY factoring algorithm",
         "NOT PROVED.  This script optimises Shoup's SHAPE only.  Asserting 2 "
         "as a universal lower bound over all algorithms would be unsound.")


# ===========================================================================

def t7_rho_dependency_audit() -> None:
    """Does any conclusion rest on rho(u) with u > 5?

    Answered EXECUTABLY, not textually.  A source-scanning tripwire was tried
    first and was itself buggy twice (it flagged a de Bruijn print table, then
    a docstring); regex over prose is not evidence.  Instead the shared rho is
    wrapped in a spy that records the largest u it is ever called at, and the
    whole test suite's rho-using parts are run under it.  The spy asserts the
    guard itself, so a violation raises exactly as the real harness would.
    """
    head("PART 7 -- audit: does any conclusion rest on rho(u) with u > 5?")

    import dickman as _dk

    real_rho = _dk.rho
    seen: list[float] = []

    def spy(u):
        seen.append(float(u))
        return real_rho(u)          # the REAL harness call, guard included

    _dk.rho = spy
    # Every module-level name in this file that referred to the harness was
    # bound at import time, so patch those bindings too.
    saved = {k: v for k, v in globals().items() if v is real_rho}
    for k in saved:
        globals()[k] = spy
    try:
        t2_dickman()
        t5_empirical()
        t6_optimality()
    finally:
        _dk.rho = real_rho
        for k, v in saved.items():
            globals()[k] = v

    umax = max(seen) if seen else 0.0
    print(f"\n     the spy recorded {len(seen)} calls to the shared rho();"
          f" u values: {sorted(set(seen))}", flush=True)
    print(f"     LARGEST u ever passed to rho() = {umax}", flush=True)
    check("no conclusion in this note evaluates rho(u) for u > 5"
          " (the harness's own guard)", umax <= 5.0,
          f"max u fed to rho = {umax}")

    # The two load-bearing results, re-derived with rho() removed entirely.
    globals()["rho"] = lambda u: (_ for _ in ()).throw(
        AssertionError("rho() must not be needed for the central results"))
    try:
        c_h1 = min_ratio(2.0, 1.0, 1e300)[0]
        c_shoup = min_ratio(2.0, 2.0, 1e300)[0]
        ratio = c_shoup / c_h1
        L = 2**20 * LN2
        uu = L / balanced_logy(L)
        rr = math.log(uu) / math.log(L)
        corr = 0.5 - 0.5 * math.log(math.log(L)) / math.log(L) \
            + 0.5 * math.log(2.0) / math.log(L)
        ok_ratio = abs(ratio - SQRT2) < 0.01
        ok_h1 = abs(corr - rr) < 1e-9
        check("the 2sqrt(2) -> 2 improvement is re-derived with rho() POISONED"
              " (closed form in (a, c) only)", ok_ratio,
              f"ratio = {ratio:.8f} vs sqrt(2) = {SQRT2:.8f}")
        check("the H1 identity log u / log log n -> 1/2 is re-derived with"
              " rho() POISONED", ok_h1,
              f"measured {rr:.10f} vs formula {corr:.10f}")
    finally:
        globals()["rho"] = real_rho

    null("rho(u) for u > 5 supports NO conclusion in this note",
         "Verified executably: with rho() replaced by a function that raises, "
         "both load-bearing results still verify.  rho is used only for the "
         "c(u) TIGHTNESS diagnostic in S3, on 2 <= u <= 5 where the harness is "
         "sound (c(5) = 0.9861, rising monotonically toward 1).")


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
    t7_rho_dependency_audit()

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
