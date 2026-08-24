"""
Domain factors for attention key budgets: exact numerical demonstrations.
========================================================================

This script is a self-contained, dependency-free companion to the study of
*multiplicative domain factors* for attention key budgets.  Everything is
computed in exact rational arithmetic (``fractions.Fraction``), so every
inequality printed below is a genuine verification, not a floating-point
approximation.

The objects
-----------
An *attention profile* is a positive sequence ``w(0), w(1), w(2), ...`` where
``w(i)`` is the attention mass carried by the i-th most important key.

    head mass          M_w(m)      = w(0) + ... + w(m-1)
    retained fraction  R_w(n, k)   = M_w(min(k, n)) / M_w(n)
    knee (key budget)  k*(w, n, t) = least k with R_w(n, k) >= t

Two profile transforms generate the whole theory:

    block dilation   (D_c w)(i) = w(i // c) / c          (spread each key over c)
    key merging      (C_q w)(i) = w(qi) + ... + w(qi+q-1) (fuse q keys into one)

The results demonstrated here
-----------------------------
 1. Dilation bracket:      c*(k*-1) < k*(D_c w, cn) <= c*k*(w, n).
 2. Sharpness:             an explicit profile/gate where the left inequality is
                           strict and exact multiplicativity fails.
 3. Relative error:        1 - 1/k* < k*(D_c w, cn) / (c k*) <= 1.
 4. Increment bracket:     c*D - (c-1) <= D_dilated <= c*D + (c-1).
 5. Cross-ratio audit:     which rows of the reported five-domain table admit a
                           single multiplicative factor (and which do not).
 6. Ceiling law:           k*(C_q w, n) = ceil( k*(w, qn) / q ), exactly.
 7. Token-matched reading: an exact factor at equal token counts forces a flat
                           base curve; the reported French row is out of window.
 8. Limit knee and locus:  k_inf, and the context at which the knee freezes,
                           computed exactly for the dyadic witness 2^(-i).
"""

from __future__ import annotations

from fractions import Fraction
from typing import Callable, Dict, List, Optional, Sequence, Tuple

Profile = Callable[[int], Fraction]

# ----------------------------------------------------------------------------
# 1. Core quantities
# ----------------------------------------------------------------------------


def head_mass(w: Profile, m: int) -> Fraction:
    """Total attention mass of the first ``m`` keys, M_w(m) = sum_{i<m} w(i)."""
    total = Fraction(0)
    for i in range(m):
        total += w(i)
    return total


def retained(w: Profile, n: int, k: int) -> Fraction:
    """Fraction of the context-``n`` mass retained by a budget of ``k`` keys."""
    denom = head_mass(w, n)
    if denom == 0:
        raise ValueError("degenerate profile: zero head mass")
    return head_mass(w, min(k, n)) / denom


def kstar(w: Profile, n: int, tau: Fraction) -> int:
    """Knee: least budget ``k`` with ``retained(w, n, k) >= tau`` (tau <= 1)."""
    for k in range(0, n + 1):
        if retained(w, n, k) >= tau:
            return k
    raise ValueError("gate exceeds 1; no budget clears it")


# ----------------------------------------------------------------------------
# 2. The two profile transforms
# ----------------------------------------------------------------------------


def dilate(c: int, w: Profile) -> Profile:
    """Block dilation: spread each key's mass evenly over ``c`` consecutive keys."""
    if c <= 0:
        raise ValueError("dilation depth must be positive")
    return lambda i: w(i // c) / c


def contract(q: int, w: Profile) -> Profile:
    """Key merging: fuse each block of ``q`` adjacent keys into a single key."""
    if q <= 0:
        raise ValueError("merging depth must be positive")
    return lambda i: sum((w(q * i + j) for j in range(q)), Fraction(0))


def rat_dilate(p: int, q: int, w: Profile) -> Profile:
    """Rational domain factor ``p/q``: merge ``q`` keys, then dilate by ``p``."""
    return dilate(p, contract(q, w))


# ----------------------------------------------------------------------------
# 3. A small zoo of base profiles
# ----------------------------------------------------------------------------


def geometric(ratio: Fraction) -> Profile:
    """w(i) = ratio^i, the spectral-gap ("fast decay") profile."""
    return lambda i: ratio ** i


def zipf(exponent: int) -> Profile:
    """w(i) = 1 / (i+1)^exponent, the heavy-tailed profile."""
    return lambda i: Fraction(1, (i + 1) ** exponent)


def uniform() -> Profile:
    """w(i) = 1, the flat profile: every key equally important."""
    return lambda i: Fraction(1)


def mixture(a: Fraction, ratio: Fraction, b: Fraction, exponent: int) -> Profile:
    """A head-plus-tail profile: geometric head, polynomial tail."""
    geo = geometric(ratio)
    zpf = zipf(exponent)
    return lambda i: a * geo(i) + b * zpf(i)


# ----------------------------------------------------------------------------
# 4. Demonstration 1 — the dilation bracket and its sharpness
# ----------------------------------------------------------------------------


def check_dilation_bracket(
    w: Profile, c: int, n: int, tau: Fraction
) -> Tuple[int, int, bool, bool]:
    """Return (base knee, dilated knee, lower bound holds, upper bound holds)."""
    base = kstar(w, n, tau)
    dil = kstar(dilate(c, w), c * n, tau)
    lower_ok = c * (base - 1) < dil
    upper_ok = dil <= c * base
    return base, dil, lower_ok, upper_ok


def demo_dilation_bracket() -> None:
    print("=" * 78)
    print("1. THE DILATION BRACKET:  c*(k*-1)  <  k*(D_c w, cn)  <=  c*k*")
    print("=" * 78)
    profiles: List[Tuple[str, Profile]] = [
        ("geometric 1/2", geometric(Fraction(1, 2))),
        ("geometric 4/5", geometric(Fraction(4, 5))),
        ("zipf 1", zipf(1)),
        ("zipf 2", zipf(2)),
        ("uniform", uniform()),
        ("mixture", mixture(Fraction(1), Fraction(3, 4), Fraction(1, 10), 2)),
    ]
    gates = [Fraction(1, 2), Fraction(3, 4), Fraction(9, 10), Fraction(99, 100)]
    print(f"{'profile':>16} {'c':>3} {'n':>4} {'tau':>8} {'k*':>5} "
          f"{'k*_dil':>7} {'window':>12}  ok")
    failures = 0
    for name, w in profiles:
        for c in (2, 3, 4):
            for n in (8, 16):
                for tau in gates:
                    base, dil, lo, hi = check_dilation_bracket(w, c, n, tau)
                    ok = lo and hi
                    failures += 0 if ok else 1
                    if (c, n, tau) in ((2, 16, Fraction(9, 10)),
                                       (3, 8, Fraction(3, 4))):
                        window = f"({c*(base-1)},{c*base}]"
                        print(f"{name:>16} {c:>3} {n:>4} {str(tau):>8} {base:>5} "
                              f"{dil:>7} {window:>12}  {'yes' if ok else 'NO'}")
    print(f"\n  bracket violations over the full sweep: {failures}   "
          f"(theory predicts 0)")


def demo_bracket_sharpness() -> None:
    print()
    print("=" * 78)
    print("2. THE ERROR BAR IS REAL: exact multiplicativity is FALSE")
    print("=" * 78)
    w = uniform()
    tau = Fraction(1, 4)
    base = kstar(w, 2, tau)
    dil = kstar(dilate(2, w), 4, tau)
    print(f"  uniform profile, c = 2, n = 2, gate tau = 1/4")
    print(f"  base knee   k*(w, 2)          = {base}")
    print(f"  dilated     k*(D_2 w, 4)      = {dil}")
    print(f"  prediction  2 * k*            = {2 * base}")
    print(f"  => the multiplicative law fails by one dilation block: "
          f"{dil} < {2*base}")
    print(f"  the bracket still holds: {2*(base-1)} < {dil} <= {2*base}")


def demo_relative_error() -> None:
    print()
    print("=" * 78)
    print("3. RELATIVE ERROR OF THE FACTOR LAW IS AT MOST 1/k*")
    print("=" * 78)
    w = mixture(Fraction(1), Fraction(9, 10), Fraction(1, 20), 2)
    tau = Fraction(9, 10)
    print(f"{'n':>5} {'k*':>5} {'c':>3} {'k*_dil':>7} {'ratio':>10} "
          f"{'1 - 1/k*':>10}  ok")
    for n in (8, 16, 32, 64):
        base = kstar(w, n, tau)
        for c in (2, 3):
            dil = kstar(dilate(c, w), c * n, tau)
            ratio = Fraction(dil, c * base)
            bound = 1 - Fraction(1, base)
            ok = bound < ratio <= 1
            print(f"{n:>5} {base:>5} {c:>3} {dil:>7} {float(ratio):>10.6f} "
                  f"{float(bound):>10.6f}  {'yes' if ok else 'NO'}")
    print("\n  at the budgets the reported table lives on (k* = 16..40) the law is")
    print("  accurate to better than 1/16 = 6.25%.")


def demo_increment_bracket() -> None:
    print()
    print("=" * 78)
    print("4. THE DOUBLING INCREMENT CARRIES THE SAME FACTOR")
    print("=" * 78)
    w = mixture(Fraction(1), Fraction(9, 10), Fraction(1, 20), 2)
    tau = Fraction(9, 10)
    print(f"{'n':>5} {'c':>3} {'Delta':>7} {'Delta_dil':>10} "
          f"{'window':>14}  ok")
    for n in (8, 16, 32):
        for c in (2, 3):
            base_lo = kstar(w, n, tau)
            base_hi = kstar(w, 2 * n, tau)
            delta = base_hi - base_lo
            dil = dilate(c, w)
            d_lo = kstar(dil, c * n, tau)
            d_hi = kstar(dil, 2 * (c * n), tau)
            delta_dil = d_hi - d_lo
            lo, hi = c * delta - (c - 1), c * delta + (c - 1)
            ok = lo <= delta_dil <= hi
            print(f"{n:>5} {c:>3} {delta:>7} {delta_dil:>10} "
                  f"{f'[{lo},{hi}]':>14}  {'yes' if ok else 'NO'}")
    print("\n  this is the structural reason a '+4' English column becomes a '+8'")
    print("  French column under a two-fold dilation.")


# ----------------------------------------------------------------------------
# 5. Demonstration 5 — auditing the reported five-domain table
# ----------------------------------------------------------------------------

REPORTED_TABLE: Dict[str, Tuple[int, int]] = {
    "code": (12, 12),
    "prose-EN": (16, 20),
    "math": (16, 20),
    "prose-DE": (20, 24),
    "prose-FR": (32, 40),
}


def has_factor(base: Tuple[int, int], row: Tuple[int, int]) -> Optional[Fraction]:
    """Return the unique factor c with row = c * base, or None if none exists."""
    if row[0] * base[1] != row[1] * base[0]:
        return None
    return Fraction(row[0], base[0])


def demo_table_audit() -> None:
    print()
    print("=" * 78)
    print("5. THE CROSS-RATIO AUDIT OF THE REPORTED TABLE")
    print("=" * 78)
    base = REPORTED_TABLE["prose-EN"]
    print(f"  base row (English prose): k*@512 = {base[0]}, k*@1024 = {base[1]}")
    print()
    print(f"{'domain':>10} {'k*@512':>7} {'k*@1024':>8} {'increment':>10} "
          f"{'cross-ratio':>12} {'factor':>8} {'predicts@1024':>14}")
    for name, row in REPORTED_TABLE.items():
        c = has_factor(base, row)
        cross = f"{row[0]*base[1]} vs {row[1]*base[0]}"
        naive = Fraction(row[0], base[0]) * base[1]
        print(f"{name:>10} {row[0]:>7} {row[1]:>8} {row[1]-row[0]:>10} "
              f"{cross:>12} {str(c) if c else 'none':>8} {str(naive):>14}")
    print()
    print("  Only English, math and French satisfy the cross-ratio identity.")
    print("  The code row's factor 3/4 predicts 15 at 1024 (measured 12);")
    print("  the German row's factor 5/4 predicts 25 at 1024 (measured 24).")
    print("  A non-zero increment can never be scaled to zero, so the flat code")
    print("  column is qualitatively outside a multiplicative family.")
    print()
    quant = all(r[0] % 4 == 0 and r[1] % 4 == 0 for r in REPORTED_TABLE.values())
    incs = sorted({r[1] - r[0] for r in REPORTED_TABLE.values()})
    print(f"  Surviving invariant -- quantisation: every entry a multiple of 4: "
          f"{quant}")
    print(f"  increments observed: {incs}  (all in 4*{{0,1,2}})")


# ----------------------------------------------------------------------------
# 6. Demonstration 6 — the exact ceiling law for key merging
# ----------------------------------------------------------------------------


def demo_ceiling_law() -> None:
    print()
    print("=" * 78)
    print("6. THE CEILING LAW FOR KEY MERGING:  k*(C_q w, n) = ceil(k*(w, qn)/q)")
    print("=" * 78)
    profiles: List[Tuple[str, Profile]] = [
        ("geometric 4/5", geometric(Fraction(4, 5))),
        ("zipf 1", zipf(1)),
        ("mixture", mixture(Fraction(1), Fraction(3, 4), Fraction(1, 10), 2)),
    ]
    print(f"{'profile':>16} {'q':>3} {'n':>4} {'tau':>8} {'k*(w,qn)':>9} "
          f"{'merged':>7} {'ceil':>5}  ok")
    bad = 0
    for name, w in profiles:
        for q in (2, 3, 5):
            for n in (6, 10):
                for tau in (Fraction(3, 4), Fraction(9, 10)):
                    merged = kstar(contract(q, w), n, tau)
                    k = kstar(w, q * n, tau)
                    ceil = -((-k) // q)
                    ok = merged == ceil
                    bad += 0 if ok else 1
                    if n == 10 and tau == Fraction(9, 10):
                        print(f"{name:>16} {q:>3} {n:>4} {str(tau):>8} {k:>9} "
                              f"{merged:>7} {ceil:>5}  {'yes' if ok else 'NO'}")
    print(f"\n  ceiling-law violations over the full sweep: {bad}  "
          f"(theory predicts 0)")
    print("  Merging is the only transform whose knee is a closed form rather")
    print("  than a window; the ceiling is where the table's quantisation is born.")


def demo_rational_windows() -> None:
    print()
    print("=" * 78)
    print("7. RATIONAL FACTORS RESCUE GERMAN, BUT NOT THE FLAT CODE COLUMN")
    print("=" * 78)
    print("  Base English knees are 16 at the short context and 20 at the long one.")
    for (p, q, label) in ((5, 4, "German 5/4"), (3, 5, "code 3/5")):
        w512 = -((-16) // q)
        w1024 = -((-20) // q)
        print(f"  {label:>12}: window@512 = ({p*(w512-1)},{p*w512}]   "
              f"window@1024 = ({p*(w1024-1)},{p*w1024}]")
    print("  German (20, 24) lies inside (15,20] x (20,25]  -> compatible.")
    print("  Code   (12, 12) lies inside ( 9,12] x ( 9,12]  -> compatible, but the")
    print("  effective factor is 3/5 = 0.6, not the reported 0.75.")
    print()
    print("  Why a flat column forces coarse merging (q >= 5):")
    print(f"{'q':>3} {'ceil(16/q)':>11} {'ceil(20/q)':>11}  windows disjoint?")
    for q in range(1, 7):
        a = -((-16) // q)
        b = -((-20) // q)
        print(f"{q:>3} {a:>11} {b:>11}  {'yes' if a < b else 'NO -- flat possible'}")


# ----------------------------------------------------------------------------
# 7. Demonstration 8 — the token-matched reading
# ----------------------------------------------------------------------------


def demo_token_matched() -> None:
    print()
    print("=" * 78)
    print("8. TOKEN-MATCHED VERSUS CONTEXT-MATCHED FACTORS")
    print("=" * 78)
    print("  The experiment measures every domain at the SAME token count.")
    print("  Theory: k*(D_c w, N) <= c * k*(w, N/c) < k*(D_c w, N) + c.")
    print("  So the token-matched prediction c * k*(w, N) overshoots by c*D,")
    print("  where D is the base increment across the ratio c.")
    print()
    print("  Reported English chain read backwards by its own +4 law:")
    print("      k*@256 = 12,  k*@512 = 16,  k*@1024 = 20,  k*@2048 = 24")
    lo, hi = 2 * (12 - 1) + 1, 2 * 12
    print(f"  Every two-fold dilation therefore has k*@512 in ({lo-1}, {hi}].")
    print(f"  The reported French value 32 lies OUTSIDE ({lo-1}, {hi}]: refuted.")
    print(f"  Honest token-matched French factor: in ({Fraction(lo,16)}, "
          f"{Fraction(hi,16)}] = (11/8, 3/2], not 2.")
    print()
    print("  Merging side, exactly: k*(C_2 w, 512) = ceil(k*(w,1024)/2) = "
          f"{-((-20)//2)}   (a naive 0.5 factor would say 8)")
    print("                        k*(C_2 w, 1024) = ceil(k*(w,2048)/2) = "
          f"{-((-24)//2)}")
    print("  => merged increment +2, never the reported +0.")
    print()
    print("  Empirical check on a concrete rising profile:")
    w = mixture(Fraction(1), Fraction(9, 10), Fraction(1, 20), 2)
    tau = Fraction(9, 10)
    print(f"{'N':>5} {'k*(w,N)':>8} {'k*(D_2 w,N)':>12} {'2*k*(w,N)':>10} "
          f"{'exact factor?':>14}")
    for n in (8, 16, 32, 64):
        base = kstar(w, n, tau)
        dil = kstar(dilate(2, w), n, tau)
        print(f"{n:>5} {base:>8} {dil:>12} {2*base:>10} "
              f"{'yes' if dil == 2*base else 'no':>14}")
    print("  An exact token-matched factor would force k*(w, N/c) = k*(w, N):")
    print("  a flat base curve.  A rising curve admits no exact factor at all.")


# ----------------------------------------------------------------------------
# 8. Demonstration 9 — the dyadic witness, limit knee and stabilisation locus
# ----------------------------------------------------------------------------


def limit_knee(w: Profile, total: Fraction, tau: Fraction, search: int = 200) -> int:
    """Least k with tau * (total mass) <= M_w(k): the limit knee k_inf."""
    for k in range(search + 1):
        if tau * total <= head_mass(w, k):
            return k
    raise ValueError("limit knee not found within search range")


def demo_dyadic_witness() -> None:
    print()
    print("=" * 78)
    print("9. THE DYADIC WITNESS: RISING KNEE, LIMIT KNEE, STABILISATION LOCUS")
    print("=" * 78)
    w = geometric(Fraction(1, 2))
    tau = Fraction(2 ** 32 - 5000, 2 ** 32 - 1)
    print(f"  profile w(i) = 2^-i,  gate tau = (2^32 - 5000)/(2^32 - 1) "
          f"~ {float(tau):.9f}")
    k16 = kstar(w, 16, tau)
    k32 = kstar(w, 32, tau)
    print(f"  k*(w, 16)  = {k16}      k*(w, 32) = {k32}   "
          f"-> a genuine '+4 per doubling' chain")
    kinf = limit_knee(w, Fraction(2), tau)
    print(f"  limit knee k_inf = {kinf}: the asymptotic budget, a profile invariant")
    print()
    print(f"{'context m':>10} {'k*(w,m)':>9} {'frozen at k_inf?':>18}")
    for m in (16, 18, 20, 21, 24, 32, 64):
        k = kstar(w, m, tau)
        print(f"{m:>10} {k:>9} {'yes' if k == kinf else 'no':>18}")
    print()
    print("  The knee is still 16 at context 16, still <= 19 at context 20, and is")
    print(f"  frozen at {kinf} from context 21 onwards: the stabilisation locus is")
    print("  exactly 21.  The short reported context sits strictly BELOW the locus,")
    print("  so any factor read there is read in the pre-asymptotic regime, where")
    print("  every measurement systematically under-reports the true budget.")
    print()
    print("  Certificate check: the knee is frozen as soon as the geometric tail")
    print("  beyond the measured knee fits under the gate slack, r^k*/(1-r) <= 1-tau.")
    r = Fraction(1, 2)
    for k in (16, 20, 21, 22):
        tail = r ** k / (1 - r)
        slack = 1 - tau
        print(f"      k = {k:>3}:  r^k/(1-r) = {float(tail):.3e}   "
              f"1 - tau = {float(slack):.3e}   "
              f"{'CERTIFIED' if tail <= slack else 'fails'}")


# ----------------------------------------------------------------------------
# 9. Driver
# ----------------------------------------------------------------------------


def main() -> None:
    demo_dilation_bracket()
    demo_bracket_sharpness()
    demo_relative_error()
    demo_increment_bracket()
    demo_table_audit()
    demo_ceiling_law()
    demo_rational_windows()
    demo_token_matched()
    demo_dyadic_witness()
    print()
    print("=" * 78)
    print("All checks completed in exact rational arithmetic.")
    print("=" * 78)


if __name__ == "__main__":
    main()
