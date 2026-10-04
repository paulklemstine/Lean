"""
selftest.py -- self-tests for the regime analysis.

A self-test that only shows your code running is not a self-test.  It must
return the NULL answer where null is correct, and it must contain a NEGATIVE
CONTROL proving each detector can actually fire.

Run:  python3 selftest.py
"""

from __future__ import annotations

import math
import random
import sys
from fractions import Fraction

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r49exp/regime")
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp/stange")

import fwregime as F
from sympy import Matrix

RESULTS = []


def check(name, cond, detail=""):
    RESULTS.append((name, bool(cond), detail))
    print(f"  [{'PASS' if cond else 'FAIL'}] {name}" + (f"  {detail}" if detail else ""))
    return bool(cond)


# ---------------------------------------------------------------------------
# T1 -- alpha_n against F&W's OWN printed values (p.10)
# ---------------------------------------------------------------------------
# The paper prints: "For n = 2, 3, 4 and 5, alpha_n is larger than 0.238,
# 0.185, 0.176, 0.172 and 0.170, respectively."  That is FIVE numbers
# against a FOUR-value label.  Computing alpha_n from the image-verified
# formula shows the list is correct and the LABEL is off by one: the values
# are for n = 1,2,3,4,5.
def t1_alpha():
    print("T1  alpha_n vs F&W p.10 printed values (label is off by one)")
    # the five printed numbers, in order
    printed = [0.238, 0.185, 0.176, 0.172, 0.170]
    ok = True
    for i, claimed in enumerate(printed, start=1):
        got = F.alpha_n(i)
        good = got > claimed
        ok &= good
        print(f"      alpha_{i} = {got:.4f}   printed > {claimed:.3f}   {'OK' if good else 'MISMATCH'}")
    ok &= check("T1 alpha_n(n) > printed[n] for n=1..5", ok)
    # The paper's LABEL says "For n = 2, 3, 4 and 5" but lists FIVE numbers.
    # Aligning the five numbers to n=2..6 must FAIL at the last value --
    # that is what pins the alignment to n=1..5.
    shifted_ok = [F.alpha_n(i + 2) > printed[i] for i in range(4)] + \
                 [F.alpha_n(6) > printed[4]]
    ok &= check("T1b paper's literal label (n=2..6) is WRONG",
                not all(shifted_ok),
                f"shifted reading flags = {shifted_ok}; "
                f"alpha_6 = {F.alpha_n(6):.4f} is NOT > {printed[4]:.3f}")
    ok &= check("T1c alpha_1 matches the FIRST printed number 0.238",
                F.alpha_n(1) > 0.238, f"alpha_1 = {F.alpha_n(1):.4f}")
    return ok


def t1b_alpha_exact():
    """Cross-check the 60-digit mpmath factor-2 against EXACT rational algebra."""
    print("T2  cor23_factor_exact vs mpmath (exact rationals, no floats)")
    ok = True
    for nd in (2, 4, 6, 8):
        a, bb = F.cor23_factor_exact(nd)
        exact = float(a) + float(bb) * math.sqrt(nd)
        mp_ = F.alpha_n(nd) / (math.prod(1.0 / F.zeta(i) for i in range(2, nd + 2)) - 0.25)
        d = abs(exact - mp_)
        ok &= check(f"T2 n={nd} exact {exact:.12f} vs mpmath {mp_:.12f} (d={d:.2e})",
                    d < 1e-12)
    return ok


def t1c_zeta_hat():
    print("T3  zhat >= 0.434 (F&W Prop 2.5's own stated bound)")
    z = F.zeta_hat()
    return check("T3 zhat = %.6f >= 0.434" % z, z >= 0.434)


# ---------------------------------------------------------------------------
# T4 -- MANDATORY CONTROL: assert M.v == 0 EXACTLY, per kernel vector
# ---------------------------------------------------------------------------
def mv_exact_zero(Mrows, v) -> bool:
    """M v == 0 in EXACT arithmetic (Fraction), per the mandatory control."""
    Mrows = [[Fraction(int(x)) for x in row] for row in Mrows]
    v = [Fraction(x) if not isinstance(x, Fraction) else x for x in v]
    b, cols = len(Mrows), len(Mrows[0])
    assert len(v) == cols, f"kernel vector has {len(v)} entries, M has {cols} columns"
    for i in range(b):
        s = Fraction(0)
        for j in range(cols):
            s += Mrows[i][j] * v[j]
        if s != 0:
            return False
    return True


def t4_exact_kernel():
    print("T4  EXACT nullspace: M.v == 0 per kernel vector, Fraction arithmetic")
    rng = random.Random(20261003)
    nchecked = 0
    nonzero_entries = 0
    fractional_vectors = 0
    trap_witness = None
    for trial in range(80):
        b = rng.randint(3, 8)
        c = rng.randint(2, 6)
        cols = b + c
        Mrows = [[rng.randint(-4, 4) for _ in range(cols)] for _ in range(b)]
        basis = Matrix(Mrows).nullspace()
        for vec in basis:
            vl = [vec[i, 0] for i in range(vec.rows)]
            if not mv_exact_zero(Mrows, vl):
                check(f"T4 trial {trial}", False, "M.v != 0")
                return False
            nz = sum(1 for x in vl if x != 0)
            nonzero_entries += nz
            if nz and any(Fraction(x).denominator != 1 for x in vl):
                # genuinely rational vector -- int() would destroy it
                fractional_vectors += 1
                if trap_witness is None:
                    trap_witness = (Mrows, vl)
            nchecked += 1
    ok = check(f"T4 {nchecked} kernel vectors verified EXACTLY", nchecked > 0,
               f"{nonzero_entries} nonzero entries")
    # r48's T4 lesson: the vectors must ACTUALLY contain non-integer entries,
    # otherwise the truncation test below is vacuous.
    ok &= check("T4b vectors genuinely contain non-integer entries",
                fractional_vectors > 0, f"{fractional_vectors} rational vectors")
    global _TRAP_WITNESS
    _TRAP_WITNESS = trap_witness

    # NEGATIVE CONTROL: perturb one entry; the check MUST now fail.
    Mrows = [[rng.randint(-4, 4) for _ in range(7)] for _ in range(4)]
    basis = Matrix(Mrows).nullspace()
    if basis:
        vl = [basis[0][i, 0] for i in range(basis[0].rows)]
        assert mv_exact_zero(Mrows, vl)
        bad = [row[:] for row in Mrows]
        bad[0][0] += 1
        ok &= check("T4c NEGATIVE CONTROL: perturbed M is detected as non-kernel",
                    not mv_exact_zero(bad, vl))
    return ok


_TRAP_WITNESS = None


def t4b_truncation_trap():
    """The r48 truncation trap: int(Rational(1/2)) == 0 destroys M.v == 0."""
    print("T5  truncation trap: int() on a Rational silently kills the kernel")
    if _TRAP_WITNESS is None:
        return check("T5 a rational kernel witness exists (T4b)", False)
    Mrows, vl = _TRAP_WITNESS
    trunc = [int(x) for x in vl]
    ok = check("T5 rational vector IS an exact kernel vector", mv_exact_zero(Mrows, vl))
    ok &= check("T5b NEGATIVE CONTROL: truncated vector is NOT (detects the trap)",
                not mv_exact_zero(Mrows, trunc),
                f"v = {[str(x) for x in vl]} -> int() = {trunc}")
    return ok


# ---------------------------------------------------------------------------
# T6 -- the paper's own worked example (p.5-7), the mandatory positive control
# ---------------------------------------------------------------------------
def t6_paper_example():
    print("T6  paper's own example n=62389, g=43, B=50 (b=15), c=10")
    import stange
    n, g, B = 62389, 43, 50
    FB = stange.factor_base(B, n)
    ok = check("T6 factor base has b=15 primes", len(FB) == 15, f"|FB|={len(FB)}")
    rng = random.Random(1234567)
    found = 0
    for s in range(8):
        r = random.Random(1000 + s)
        res = stange.alg22(n, g, FB, 10, r)
        if res["factor"]:
            found += 1
        if s == 0:
            ok &= check("T6 G is a multiple of ord(g) or G>0", res["G"] > 0,
                        f"G={res['G']}")
    ok &= check("T6 factors found in 8/8 seeds (paper: gcd(51174-1,62389)=701)",
                found == 8, f"found={found}/8")
    ok &= check("T6 factor_from_multiple(15400,43,62389) == 701  (paper p.7 verbatim)",
                stange.factor_from_multiple(15400, 43, 62389) == 701)
    return ok


# ---------------------------------------------------------------------------
# T7 -- exact integer roots vs the float trap
# ---------------------------------------------------------------------------
def t7_iroot():
    print("T7  EXACT integer roots vs the int(n**(1/k)) trap")
    ok = True
    cubes = [(8, 2), (27, 3), (64, 4), (125, 3), (1000000, 6), (999999999999, 5)]
    for m, k in cubes:
        exact = F.iroot(m, k)
        ok &= check(f"T7 iroot({m},{k}) = {exact}", exact ** k <= m < (exact + 1) ** k)
    # the trap: perfect cubes are where int(n**(1/3)) understates
    trap_hits = 0
    for base in (2, 3, 5, 7, 11, 13, 1000003):
        n = base ** 3
        if int(n ** (1.0 / 3.0)) != base:
            trap_hits += 1
    ok &= check("T7b NEGATIVE CONTROL: int(n**(1/3)) understates on perfect cubes",
                trap_hits > 0, f"{trap_hits}/{len((2,3,5,7,11,13,1000003))} perfect cubes")
    for base in (2, 3, 5, 7, 11, 13, 1000003):
        n = base ** 3
        ok &= check(f"T7 iroot({n},3)=={base} (exact)", F.iroot(n, 3) == base)
    return ok


# ---------------------------------------------------------------------------
# T8 -- b_max boundary is exact and consistent with a brute-force scan
# ---------------------------------------------------------------------------
def t8_bmax():
    print("T8  b_max exactness and boundary")
    ok = True
    rng = random.Random(777)
    for _ in range(40):
        bits = rng.randint(24, 90)
        n = rng.getrandbits(bits) | (1 << (bits - 1))
        bm = F.b_max(n)
        # brute force scan must agree
        scan = 0
        b = 1
        while F.in_stange_regime(b, n):
            scan = b
            b += 1
        ok &= check(f"T8 b_max({bits}-bit n) = {bm} == brute scan {scan}", bm == scan,
                    "")
        # boundary: admitted below, rejected above
        ok &= check(f"T8b boundary exact at b={bm}/{bm+1}",
                    F.in_stange_regime(bm, n) and not F.in_stange_regime(bm + 1, n))
    return ok


# ---------------------------------------------------------------------------
# T9 -- THE ESSENTIAL NEGATIVE CONTROL for P1.
#
#   The headline prediction is "b_max(n,c) is FLAT in c".  A harness that is
#   hard-wired to report "flat" would produce that answer no matter what.
#   So: INJECT a c-dependence into the regime test and require the harness to
#   DETECT it.  If the harness cannot detect a dependence we planted, its "flat"
#   verdict on the real condition is vacuous.
# ---------------------------------------------------------------------------
def t9_injected_cdependence():
    print("T9  NEGATIVE CONTROL: harness CAN detect a c-dependence we inject")

    def b_max_with_c(n, c, cond):
        lo, hi = 1, 2
        while cond(hi, n, c):
            lo = hi
            hi *= 2
        while lo + 1 < hi:
            mid = (lo + hi) // 2
            if cond(mid, n, c):
                lo = mid
            else:
                hi = mid
        return lo

    n = 10 ** 20
    # (a) the TRUE condition -- independent of c by construction
    true_cond = lambda b, nn, c: F.in_stange_regime(b, nn)
    # (b) a PLANTED c-dependence:  n >= 8 b^{b/2} * 2^c
    #     i.e. raising c makes the regime HARDER.  EXACT integer form:
    #         n^2 >= 64 * b^b * 4^c
    #     At n = 10^20 the margin at b = 26 is only 5.04x, so my FIRST attempt
    #     planted a factor (1 + c/b) that was too weak to bite -- and the
    #     negative control then wrongly "confirmed" flatness.  2^c bites at c=3.
    def planted(b, nn, c):
        return (nn * nn) >= 64 * (b ** b) * (4 ** c)

    vals_true = [b_max_with_c(n, c, true_cond) for c in (1, 5, 10, 20, 50, 100)]
    vals_plant = [b_max_with_c(n, c, planted) for c in (1, 5, 10, 20, 50, 100)]

    ok = check("T9a TRUE condition is flat in c", len(set(vals_true)) == 1,
               f"b_max = {vals_true}")
    ok &= check("T9b PLANTED c-dependence IS detected (harness not hard-wired)",
                len(set(vals_plant)) > 1, f"b_max = {vals_plant}")
    ok &= check("T9c planted dependence moves b_max DOWNWARD in c",
                vals_plant[-1] < vals_plant[0],
                f"c=1 -> {vals_plant[0]}, c=100 -> {vals_plant[-1]}")
    return ok


# ---------------------------------------------------------------------------
# T10 -- NULL-ANSWER tests: the harness must be willing to say NO.
# ---------------------------------------------------------------------------
def t10_nulls():
    print("T10 NULL-ANSWER tests (the harness must return falsity where it is "
          "correct)")
    ok = True
    n = 10 ** 20
    # the algorithm's own required b is far outside the regime
    b_need = F.b_needed(math.log(n))
    ok &= check("T10 regime REJECTS the b the algorithm needs",
                not F.in_stange_regime(int(b_need), n), f"b_needed~{b_need:.3g}")
    # small n must REJECT large b
    ok &= check("T10 n=2^30 rejects b=50",
                not F.in_stange_regime(50, 2 ** 30))
    # the honest single-window condition must REJECT what Stange's accepts
    ok &= check("T10 two-window regime is strictly stronger than Stange's",
                (not F.in_two_window_regime(22, n)) and F.in_stange_regime(22, n)
                or (F.in_stange_regime(21, n) and not F.in_two_window_regime(21, n)))
    ok &= check("T10 b_max(two-window) < b_max(stange) for 10^20",
                F.b_max(n, "two-window") < F.b_max(n, "stange"),
                f"{F.b_max(n,'two-window')} < {F.b_max(n,'stange')}")
    # unknown regime must RAISE, not silently fall back
    try:
        F.b_max(n, "nonsense")
        ok &= check("T10b unknown regime raises", False)
    except ValueError:
        ok &= check("T10b unknown regime raises (not a silent default)", True)
    return ok


# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# T11 -- the per-modulus Shor baseline used in exp_cliff.py
# ---------------------------------------------------------------------------
# Every rate in exp_cliff.py is reported next to p_split(p,q), because the
# 20/27 constant is an average over MODULI, not a per-modulus value.  If
# p_split is wrong the whole rate table is misread, so it is pinned down
# two ways: analytically (it must average to exactly 20/27) and by a negative
# control (it must NOT be constant in the modulus).
def t11_psplit():
    from exp_cliff import p_split, v2
    from sympy import nextprime
    print("T11 per-modulus Shor baseline p_split(p,q)")

    def P2(k, m):
        return 2.0 ** -m if k == 0 else 2.0 ** (k - 1 - m)

    ok = True
    # (a) normalisation
    for m in range(1, 12):
        s = P2(0, m) + sum(P2(k, m) for k in range(1, m + 1))
        if abs(s - 1.0) > 1e-12:
            ok &= check(f"T11a dist normalised at m={m}", False, f"sum={s}")
            break
    else:
        ok &= check("T11a v2(ord_p g) distribution normalised for m=1..11", True)
    # (b) analytic average over moduli must be exactly 20/27
    E = [P2(0, 1)]
    # E[P2(0,m)] = sum_{m>=1} 4^-m = 1/3
    E = [1.0 / 3.0] + [(2.0 / 3.0) * 2.0 ** -k for k in range(1, 60)]
    fail = sum(e * e for e in E)
    ok &= check("T11b E[p_split] = 1 - 7/27 = 20/27 = %.6f" % (1 - fail),
                abs((1 - fail) - 20.0 / 27.0) < 1e-12)
    # (c) it must NOT be constant across moduli  (negative control)
    vals = set()
    rng = random.Random(5)
    for _ in range(40):
        p = int(nextprime(rng.getrandbits(20) | 1))
        q = int(nextprime(rng.getrandbits(20) | 1))
        if p != q:
            vals.add(round(p_split(p, q)[0], 6))
    ok &= check("T11c NEGATIVE CONTROL: p_split varies with the modulus",
                len(vals) > 1, f"{len(vals)} distinct values, e.g. {sorted(vals)[:6]}")
    ok &= check("T11d p_split(7,11) = 0.5 (both 3 mod 4)",
                abs(p_split(7, 11)[0] - 0.5) < 1e-12)
    return ok


def main():
    print("=" * 72)
    print("SELF-TESTS for fwregime.py  (Stange 2211.06821 / F&W 1211.6246)")
    print("=" * 72)
    tests = [t1_alpha, t1b_alpha_exact, t1c_zeta_hat, t4_exact_kernel,
             t4b_truncation_trap, t6_paper_example, t7_iroot, t8_bmax,
             t9_injected_cdependence, t10_nulls, t11_psplit]
    for t in tests:
        t()
        print()
    npass = sum(1 for _, ok, _ in RESULTS if ok)
    nfail = len(RESULTS) - npass
    print("=" * 72)
    print(f"{npass}/{len(RESULTS)} checks PASS" + (f",  {nfail} FAIL" if nfail else ""))
    print("=" * 72)
    return nfail == 0


if __name__ == "__main__":
    sys.exit(0 if main() else 1)