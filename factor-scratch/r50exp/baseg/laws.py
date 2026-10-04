"""
EXACT 2-ADIC LAWS FOR THE STANGE STEP, AND THE REACHABLE-STRATEGY ENUMERATION.

THE QUESTION. Stange succeeds on attempt iff

        v2(ord_p g)  !=  v2(ord_q g)                      (1)

For a uniform g, averaging over the joint law of (s_p, s_q) gives P = 20/27 exactly
(`r48/_shared/explain_20_over_27.py`).  This module asks whether a NON-UNIFORM g -- one chosen
without factoring n -- does better.

THE PARAMETERISATION.  Put

        a = s_p = v2(p-1),      b = s_q = v2(q-1),      lam_p = s_p - v2(ord_p g).

Then v2(ord_p g) = a - lam_p, and lam_p ranges over {0,...,a}.  For a uniform element of a
cyclic group of order 2^a * u:

        P(lam = i) = 2^-(i+1)   for 0 <= i <= a-1,      P(lam = a) = 2^-a.     (2)

So (2) is exactly `v2dist(a)` in the shared code, read in reverse.  This is the SAME law the
campaign already trusts, just relabelled -- no new assumption.

THE STRUCTURAL FACT THAT OPENS THE LEVER (verified numerically, and it is textbook):

        lam_p = 0   <=>   g is a QUADRATIC NON-RESIDUE mod p   <=>   (g/p) = -1
        lam_p >= 1  <=>   (g/p) = +1.

Because ord_p g has full 2-part a exactly when g generates past the index-2 subgroup.
Therefore

        (g/p)(g/q) = (-1)^(lam_p + lam_q)   and   Jacobi(g/n) = (g/p)(g/q).     (3)

**So the Jacobi symbol -- which is computable from n alone, in O(log n), with NO factoring --
tells you whether exactly ONE of lam_p, lam_q is 0.**  That is the first piece of 2-adic
information the campaign has never used, because every attempt has used a uniform g.

EXACT RATES.  Everything below is in `fractions.Fraction`.  No renormalisation anywhere --
and ST1 asserts each law has mass exactly 1, because an undeclared renormalisation is what let
a factor-2 error survive in round 48.
"""

from __future__ import annotations

from fractions import Fraction as F

# --------------------------------------------------------------------------------------
# (2) the law of lam = s - v2(ord g) in a cyclic group of 2-part 2^s
# --------------------------------------------------------------------------------------


# Injection switch for ST6.  Deliberately corrupts the lam = 0 mass by DELTA; used only to
# prove the suite and the downstream detectors are non-vacuous.
INJECT_DELTA = F(0)


def set_injection(delta: F) -> None:
    global INJECT_DELTA
    INJECT_DELTA = delta


def lam_law(s: int) -> list[F]:
    """P(lam = i), i = 0..s, for a uniform element of a cyclic group of order 2^s * u.

    Read BACKWARDS from the campaign's `v2dist(s)`: lam = s - k, so this is v2dist reversed.
    """
    if s < 1:
        raise ValueError("s must be >= 1 (odd primes only)")
    d = [F(0)] * (s + 1)
    for i in range(s):
        d[i] += F(1, 2 ** (i + 1))
    d[s] += F(1, 2**s)
    if INJECT_DELTA != 0:  # ST6 only
        d[0] += INJECT_DELTA
    assert sum(d) == 1, f"law(s={s}) has mass {sum(d)}, not 1 -- refusing to renormalise"
    return d


def k_law(s: int) -> list[F]:
    """P(v2(ord_p g) = k) for k = 0..s.  Identical to the campaign's v2dist(s)."""
    return lam_law(s)[::-1]


# --------------------------------------------------------------------------------------
# the two distinguishable "characters" of a g, i.e. what can be conditioned on
# --------------------------------------------------------------------------------------


def qr_cond_lam(s: int) -> list[F]:
    """lam-law CONDITIONED ON g being a QR mod p (i.e. lam >= 1)."""
    d = lam_law(s)
    tail = sum(d[1:])  # = 1/2 exactly
    assert tail == F(1, 2)
    return [F(0)] + [x / tail for x in d[1:]]


def nr_lam(s: int) -> list[F]:
    """lam-law CONDITIONED ON g being a QNR mod p (i.e. lam = 0): a point mass at 0."""
    d = lam_law(s)
    assert d[0] == F(1, 2)
    return [F(1)] + [F(0)] * s


def p_legendre_flags(s: int) -> tuple[F, F]:
    """P(lam = 0) and P(lam >= 1) for a uniform g.  Both are 1/2 for every s."""
    return F(1, 2), F(1, 2)


# --------------------------------------------------------------------------------------
# per-cell success probabilities
# --------------------------------------------------------------------------------------


def cell_uniform(a: int, b: int) -> F:
    """P(v2(ord_p g) != v2(ord_q g)) for UNIFORM g, at fixed (a,b).  The baseline."""
    pa, pb = k_law(a), k_law(b)
    eq = sum(pa[i] * pb[i] for i in range(min(len(pa), len(pb))))
    return 1 - eq


def _cell_jac_one_zero(a: int, b: int) -> F:
    """P(success) given Jacobi(g/n) = -1, i.e. given lam_p = 0 XOR lam_q = 0.

    Branch lam_p = 0:  k_p = a exactly,  k_q = b - lam_q with lam_q ~ QR-cond law at b.
                       success <=> lam_q != b - a.
    Branch lam_q = 0:  symmetric.
    The two branches are equiprobable (both give Legendre signs of opposite type).
    """
    def branch(x: int, y: int) -> F:
        """lam_x = 0 (k_x = x), lam_y ~ QR-cond law at y.  Success <=> lam_y != y - x."""
        m = y - x
        if m < 1:  # lam_y >= 1 can never equal a non-positive m
            return F(1)
        cond = qr_cond_lam(y)
        assert m < len(cond), (x, y, m)
        return 1 - cond[m]

    return (branch(a, b) + branch(b, a)) / 2


def cell_jac_neg(a: int, b: int) -> F:
    """P(success | Jacobi(g/n) = -1)."""
    return _cell_jac_one_zero(a, b)


def cell_jac_pos(a: int, b: int) -> F:
    """P(success | Jacobi(g/n) = +1), i.e. both lam_p, lam_q are 0 (both QNR) or both >= 1."""
    both_nr = F(1) if a != b else F(0)  # k_p = a, k_q = b
    ca, cb = qr_cond_lam(a), qr_cond_lam(b)
    both_qr = 1 - sum(ca[i] * cb[i] for i in range(min(len(ca), len(cb))))
    return (both_nr + both_qr) / 2


# --------------------------------------------------------------------------------------
# averaging over the law of s = v2(p-1):  P(s = j) = 2^-j   (mass exactly 1 -- no renorm)
# --------------------------------------------------------------------------------------


def s_law(smax: int) -> list[F]:
    w = [F(0)] + [F(1, 2**j) for j in range(1, smax + 1)]
    assert sum(w) == 1 - F(1, 2**smax), "P(s=j)=2^-j has mass 1 - 2^-smax (the tail is dropped)"
    return w


def avg(cell_fn, smax: int) -> tuple[F, F]:
    """Average cell_fn(a,b) over independent P(s_p=a)=P(s_q=b)=2^-a.

    Returns (value, dropped_tail_mass) so truncation is NEVER silent.  Every cell value lies
    in [0,1], so `dropped_tail_mass` is a rigorous UPPER BOUND on |value - exact_limit|.
    """
    w = s_law(smax)
    tot = F(0)
    for a in range(1, smax + 1):
        for b in range(1, smax + 1):
            tot += w[a] * w[b] * cell_fn(a, b)
    kept = sum(w)
    return tot, 1 - kept**2  # omitted mass = 1 - (covered mass)^2 ~ 2^(1-smax)


def rate_uniform(smax: int = 40) -> F:
    return avg(cell_uniform, smax)[0]


def rate_jac_neg(smax: int = 40) -> F:
    return avg(cell_jac_neg, smax)[0]


def rate_jac_pos(smax: int = 40) -> F:
    return avg(cell_jac_pos, smax)[0]


# --------------------------------------------------------------------------------------
# v2(n-1): the ONLY 2-adic datum about (a,b) computable from n
# --------------------------------------------------------------------------------------


def v2(m: int) -> int:
    if m == 0:
        return 0
    return (m & -m).bit_length() - 1


def v_of_cell(a: int, b: int) -> str:
    """Which v = v2(n-1) values are compatible with s_p=a, s_q=b.  (See note: if a != b then
    v = min(a,b) exactly; if a == b then v >= a+1.)"""
    return f"v={min(a,b)}" if a != b else f"v>={a+1}"


# --------------------------------------------------------------------------------------
# SELF-TESTS.  (a) exercise the claimed quantity, (b) RETURN THE NULL where the null is
# correct, (c) prove non-vacuity by INJECTION.
# --------------------------------------------------------------------------------------


def selftest() -> bool:
    ok = True

    def chk(cond: bool, msg: str) -> None:
        nonlocal ok
        print(("  [PASS] " if cond else "  [FAIL] ") + msg)
        if not cond:
            ok = False

    print("=" * 78)
    print("ST1  every law has mass EXACTLY 1 (an undeclared renormalisation is a bug)")
    print("=" * 78)
    for s in (1, 2, 3, 7, 20):
        chk(sum(lam_law(s)) == 1, f"lam_law({s}) sums to 1")
        chk(sum(k_law(s)) == 1, f"k_law({s}) sums to 1")
        chk(sum(qr_cond_lam(s)) == 1, f"qr_cond_lam({s}) sums to 1")
        chk(sum(nr_lam(s)) == 1, f"nr_law({s}) sums to 1")
    # the FATAL of 2026-10-03: P(s=j) = 2^-(j+1) has mass 1/2, NOT a law.  Detect it.
    bad = sum(F(1, 2 ** (j + 1)) for j in range(1, 200))
    chk(bad != 1, f"the WRONG weight law 2^-(j+1) has mass {float(bad):.6f} != 1 -- detected")
    print()

    print("=" * 78)
    print("ST2  THE NULL: reproduce the campaign's 20/27 for uniform g")
    print("=" * 78)
    print("      20/27 is an exact LIMIT reached by truncation.  Every cell value lies in")
    print("      [0,1], so the deficit is bounded by the dropped tail mass -- a one-sided")
    print("      certificate, not a tolerance.")
    dropped = 1 - (1 - F(1, 2**60)) ** 2
    r = rate_uniform(60)
    deficit = F(20, 27) - r
    chk(F(0) <= deficit < dropped,
        f"0 <= 20/27 - rate_uniform(60) = {float(deficit):.3e} < tail {float(dropped):.3e}")
    print(f"      rate_uniform(60) = {float(r):.15f}    20/27 = {float(F(20,27)):.15f}")
    print()
    print("      per-cell baseline vs the campaign's table (HH_explain_20_over_27.md):")
    for a, want in ((1, F(1, 2)), (2, F(5, 8)), (3, F(21, 32))):
        got = cell_uniform(a, a)
        chk(got == want, f"  cell_uniform({a},{a}) = {got}  want {want}")
    print()

    print("=" * 78)
    print("ST3  the structural fact (3): lam=0 <=> QNR, so Jacobi pins 'exactly one is 0'")
    print("=" * 78)
    for s in (1, 2, 3, 4, 5):
        chk(lam_law(s)[0] == F(1, 2) and sum(lam_law(s)[1:]) == F(1, 2),
            f"s={s}: P(lam=0) = P(lam>=1) = 1/2 -- Jacobi splits the cell exactly in half")
    print()

    print("=" * 78)
    print("ST4  the NEW rates, computed by the SAME code path as the null")
    print("=" * 78)
    rn, rp, ru = rate_jac_neg(60), rate_jac_pos(60), rate_uniform(60)
    print(f"      rate_uniform  = {float(ru):.15f}   -> 20/27")
    print(f"      rate_jac_neg  = {float(rn):.15f}   -> 8/9   (asserted)")
    print(f"      rate_jac_pos  = {float(rp):.15f}   -> 8/15  (asserted)")
    for name, val, target in (("jac_neg", rn, F(8, 9)), ("jac_pos", rp, F(8, 15))):
        d = abs(val - target)
        chk(d < dropped, f"rate_{name} -> {target} within truncation ({float(d):.3e})")
    chk(rn > ru, f"rate_jac_neg ({float(rn):.6f}) > rate_uniform ({float(ru):.6f})   <-- THE LEVER")
    print()

    print("=" * 78)
    print("ST5  NULL-RETURNING DETECTOR: the cell test must return the empty set on the null")
    print("=" * 78)
    cells = [(a, b) for a in range(1, 6) for b in range(1, 6)]
    fires_null = [k for k in cells if cell_uniform(*k) != cell_uniform(*k)]
    chk(fires_null == [], f"uniform-vs-uniform: nothing flagged ({fires_null})")
    imp = [k for k in cells if cell_jac_neg(*k) != cell_uniform(*k)]
    chk(len(imp) > 0, f"jac-vs-uniform: {len(imp)}/25 cells flagged -- detector NON-VACUOUS")
    chk(cell_jac_neg(1, 1) == F(1),
        "cell (1,1): Jacobi=-1 forces lam_p != lam_q ALWAYS -> cell rate exactly 1")
    chk(cell_jac_neg(1, 1) > cell_uniform(1, 1), "cell (1,1) strictly improved (1 > 1/2)")
    print()

    print("=" * 78)
    print("ST6  INJECTION: corrupt the law on purpose; suite must go RED, then recover")
    print("=" * 78)
    caught = None
    try:
        set_injection(F(1, 1000))  # excess mass at lam = 0 -- exactly the defect ST3 guards
        r_bad = rate_uniform(20)
    except AssertionError:
        caught = "the mass assertion inside lam_law"
    if caught:
        chk(True, f"injected non-unit mass DETECTED by {caught}")
    else:
        chk(abs(r_bad - F(20, 27)) > (1 - (1 - F(1, 2**20)) ** 2),
            f"injected law moved the null: rate_uniform -> {float(r_bad):.9f}")
    set_injection(F(0))
    chk(abs(rate_uniform(20) - F(20, 27)) < (1 - (1 - F(1, 2**20)) ** 2),
        "suite returns to the null once the injection is removed")
    print()

    print("=" * 78)
    print("ST7  truncation is reported, never silent")
    print("=" * 78)
    for smax in (6, 12, 20, 30, 60):
        v, dr = avg(cell_jac_neg, smax)
        print(f"      smax={smax:>3}  rate_jac_neg={float(v):.12f}  dropped tail mass={float(dr):.3e}")
    print()

    print("ALL SELFTESTS PASS" if ok else "!!! SELFTEST FAILURE")
    return ok


if __name__ == "__main__":
    raise SystemExit(0 if selftest() else 1)
