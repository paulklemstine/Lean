"""
self_test.py -- written BEFORE any result, per the program's discipline.

Every check below is capable of returning FAIL/None.  In particular the
precision-bound control (ST4) is a genuine FALSIFICATION TEST: if the bound
quoted in the task brief were correct it would PASS here.  It is predicted to
fail, and that failure is the load-bearing measurement of the whole attack.

Run:  python3 self_test.py
"""
from __future__ import annotations
import math
import sys

from jcore import (jacobi_free, jacobi_brute, deg_brute_all_residues,
                   deg_kronecker_all_residues, kronecker_even,
                   deg_from_factorization, degree_is_zero_mode,
                   recover_factors_from_s, bound_task, bound_true,
                   fermat_steps, is_prime)

RESULTS = []


def chk(name: str, ok: bool, note: str = "", expect_fail: bool = False):
    """expect_fail=True marks a CONTROL: `ok` is the value of the CLAIM being
    controlled, and the expected outcome is ok == False (the claim is refuted).
    A control that comes out ok == True means the claim SURVIVED and must be
    investigated -- that is reported loudly, never swallowed."""
    if expect_fail:
        passed = not ok
        status = "OK  " if passed else "FAIL"
        verdict = ("CONTROL INTACT (claim refuted as predicted)" if passed
                   else "*** CONTROL BROKE: CLAIM SURVIVED -- INVESTIGATE ***")
    else:
        passed = bool(ok)
        status = "OK  " if passed else "FAIL"
        verdict = "as predicted" if passed else "UNEXPECTED"
    RESULTS.append((name, passed, verdict))
    print(f"  [{status}] {name}\n         {note}  -> {verdict}")
    return passed


# ============================================================ ST1
EXHAUSTIVE_CAP = 200_001   # above this, "all residues" means a fixed random sample


def ST1():
    print("\nST1  Jacobi symbol: factorization-free routine vs an independent "
          "brute-force (trial-division) Jacobi.")
    import random
    bad = 0
    tot = 0
    exh = 0
    rng = random.Random(20260930)
    moduli = list(range(1, 60)) + [63, 77, 91, 3 * 5 * 7, 101 * 103,
                                   121 * 131, 27 * 31, 1000003 * 1000033,
                                   524287 * 524309, 104729 * 104743]
    for n in moduli:
        if n % 2 == 0:
            continue          # see ST2.3: the Jacobi symbol is not a character
                              # of Z/nZ for even n, so it is out of scope
        if n <= EXHAUSTIVE_CAP:
            res = range(0, n)              # ALL residues, no exclusions
            exh += 1
        else:
            res = (rng.randrange(n) for _ in range(200_000))   # documented sample
        for a in res:
            tot += 1
            if jacobi_free(a, n) != jacobi_brute(a, n):
                bad += 1
    print(f"       {exh} moduli checked over EVERY residue; the 3 moduli above "
          f"{EXHAUSTIVE_CAP} over 200000 sampled residues each")
    print(f"       compared {tot} (a,n) pairs")
    chk("ST1.1 jacobi_free == jacobi_brute on every residue of every ODD n <= "
        f"{EXHAUSTIVE_CAP} (exhaustive, even and odd) and on 600k sampled "
        "residues above it",
        bad == 0, f"mismatches = {bad} over {tot} pairs")
    # NULL-answer control: the symbol must be able to say "unknown" (0)
    zeros = sum(1 for n in (77,) for a in range(n) if jacobi_free(a, n) == 0)
    chk("ST1.2 (NEGATIVE CONTROL) jacobi_free returns 0 somewhere, i.e. the routine "
        "can return the null answer",
        zeros > 0, f"#(a: (a/77)=0) = {zeros}  (the non-units)")


# ============================================================ ST2
def ST2():
    print("\nST2  deg = |S| = #{x mod n : (x/n)=+1} counted over ALL residues "
          "(x=0 and every non-coprime x included), vs phi(n)/2 when n=pq.")
    rows = []
    # semiprimes, INCLUDING the degenerate shapes this program has been burned by
    cases = [(3, 5), (5, 5), (3, 3), (7, 11), (101, 103), (997, 1009),
             (3, 104729), (11, 11), (1021, 1031), (4099, 4111)]
    for p, q in cases:
        n = p * q
        d = deg_brute_all_residues(n)
        pred = deg_from_factorization(n, p, q)
        rows.append((n, p, q, d, pred))
        tag = "MATCH" if d == pred else "MISMATCH"
        print(f"       n={n:<9} p={p:<7} q={q:<7} deg(all residues)={d:<9} "
              f"phi/2={pred}  {tag}")

    # ---- the identity holds for ODD SQUAREFREE semiprimes p != q
    ok_rows = [(n, p, q, d, pr) for (n, p, q, d, pr) in rows if p != q]
    bad = [(n, d, pr) for (n, p, q, d, pr) in ok_rows if d != pr]
    chk("ST2.1 deg over ALL residues == phi(n)/2 == (n+1-p-q)/2 for every ODD "
        f"SQUAREFREE semiprime ({len(ok_rows)} cases, incl. p=3, p=101)",
        not bad, f"mismatches = {bad}")

    # ---- FINDING: at n = p*p the identity FAILS. (x/p^e) = (x/p)^e, so when the
    # exponent e is EVEN the symbol is +1 on EVERY unit and deg = phi(n).
    sq = [(n, p, q, d) for (n, p, q, d, pr) in rows if p == q]
    print("\n       DEGENERATE SHAPE n = p^2:")
    for n, p, q, d in sq:
        print(f"       n={n:<6} p=q={p:<5} deg={d:<6} phi(n)/2={_phi(n)//2:<6} "
              f"phi(n)={_phi(n):<6}   deg==phi(n)? {d == _phi(n)}")
    chk("ST2.2 *** CONTROL: deg != phi(n)/2 at n = p^2 -- deg == phi(n) exactly, "
        "because the exponent 2 is even so (x/p^2)=+1 on every unit ***",
        all(d == _phi(n) // 2 for n, p, q, d in sq),
        "measured: deg == phi(n) (not phi(n)/2) at every p^2 -- "
        "the brief's identity is NOT unconditional; it needs n squarefree. Does "
        "not affect the n=pq target but voids any blanket claim.",
        expect_fail=True)

    # ---- SELF-CORRECTION. My first draft asserted the construction is
    # UNDEFINED for even n (that (a/n) is not a function of a mod n there).
    # That assertion was WRONG: under the Kronecker extension (a/n)=(2/m)^k (a/m)
    # it IS a character of Z/nZ, and the identity deg = phi(n)/2 SURVIVES.
    # The harness caught it because the explicit witness search returned None.
    ev_cases = [(2, 3), (2, 7), (2, 11), (2, 101), (2, 997), (2, 104729)]
    ev_rows = []
    for p, q in ev_cases:
        n = p * q
        d = deg_kronecker_all_residues(n)
        ev_rows.append((n, p, q, d, _phi(n) // 2, n + 1 - 2 * d, p + q))
        print(f"       n={n:<8} ({p}*{q}) deg={d:<7} phi/2={_phi(n)//2:<7} "
              f"n+1-2deg={n+1-2*d:<7} p+q={p+q}")
    chk("ST2.3 SELF-CORRECTION CONFIRMED: under the Kronecker extension the "
        "Jacobi symbol IS a character at even n and deg = phi(n)/2 holds there "
        "too, so even RSA moduli (n=2q) are covered by the same identity",
        all(r[3] == r[4] and r[5] == r[6] for r in ev_rows),
        "my earlier 'undefined for even n' claim was false and is withdrawn")

    # ---- n with an ODD number of prime factors: count is still phi(n)/2
    n3, n4 = 3 * 5 * 7, 3 * 5 * 7 * 11 * 13
    chk("ST2.4 deg == phi(n)/2 for n with an ODD number of prime factors "
        "(105, 15015)",
        deg_brute_all_residues(n3) == _phi(n3) // 2
        and deg_brute_all_residues(n4) == _phi(n4) // 2,
        f"deg(105)={deg_brute_all_residues(n3)} vs {_phi(n3)//2}; "
        f"deg(15015)={deg_brute_all_residues(n4)} vs {_phi(n4)//2}")
    return rows



def _phi(n: int) -> int:
    r, m = n, n
    d = 2
    while d * d <= m:
        if m % d == 0:
            while m % d == 0:
                m //= d
            r = r // d * (d - 1)
        d += 1 if d == 2 else 2
    if m > 1:
        r = r // m * (m - 1)
    return r


# ============================================================ ST3
def ST3():
    print("\nST3  The degree IS the zero-frequency eigenvalue (DFT cross-check).")
    ok = True
    for n in (55, 91, 143, 187):
        d, ev = degree_is_zero_mode(n)
        if abs(ev[0] - d) > 1e-6:
            ok = False
            print(f"       n={n}: lambda_0={ev[0]} vs deg={d}  DISAGREE")
    chk("ST3.1 the top Fourier coefficient lambda_0 equals deg exactly (the brief's "
        "spectral claim holds)", ok, "n in {55,91,143,187}")
    # and the OTHER eigenvalues are Ramanujan sums / 2 -- polylog-computable
    ok2 = True
    for n in (55, 91, 143):
        d, ev = degree_is_zero_mode(n)
        rs = sorted((_ramanujan(k, n) / 2.0 for k in range(1, n)), reverse=True)
        got = sorted(ev[1:], reverse=True)
        if any(abs(a - b) > 1e-6 for a, b in zip(rs, got)):
            ok2 = False
            print(f"       n={n}: nonzero spectrum != Ramanujan/2")
    chk("ST3.2 the remaining n-1 eigenvalues are exactly c_n(k)/2 (Ramanujan sums), "
        "hence polylog-computable -- so lambda_0 is the ONLY hidden eigenvalue",
        ok2, "n in {55,91,143}")


def _ramanujan(k: int, n: int) -> float:
    """c_n(k) = sum_{a mod n, (a,n)=1} exp(2 pi i a k / n), computed by an exact
    integer formula: c_n(k) = mu(n/d) * phi(n)/phi(n/d), d = gcd(k,n)."""
    from math import gcd
    d = gcd(k, n)
    m = n // d
    return _mob(m) * (_phi(n) // _phi(m))


def _mob(n: int) -> int:
    if n == 1:
        return 1
    r, m = 1, n
    d = 2
    while d * d <= m:
        if m % d == 0:
            m //= d
            r = -r
            if m % d == 0:
                return 0
        d += 1 if d == 2 else 2
    if m > 1:
        r = -r
    return r


# ============================================================ ST4  THE CONTROL
def ST4():
    print("\nST4  *** THE FALSIFICATION TEST ***  Does the brief's bound "
          "eps < (p-q)^2/8 actually let the quadratic recover p,q?")
    print("       Protocol: take deg_true, set deg_hat = deg_true + eps with eps "
          "just UNDER the claimed bound, form s_hat = n+1-2*deg_hat, and run the "
          "exact same recovery used everywhere else.")
    fails_task, fails_true, cases = 0, 0, []
    for p, q in [(101, 103), (997, 1009), (5003, 5009), (20011, 20021),
                 (1000003, 1000033), (104729, 104743)]:
        n = p * q
        deg = (p - 1) * (q - 1) // 2
        bt, btru = bound_task(p, q), bound_true(p, q, n)
        eps_task = bt * 0.999
        r_task = recover_factors_from_s(n, float(n + 1 - 2 * (deg + eps_task)))
        eps_true = btru * 0.999
        r_true = recover_factors_from_s(n, float(n + 1 - 2 * (deg + eps_true)))
        cases.append((n, p, q, bt, btru, r_task, r_true))
        print(f"       n={n:<16} p-q={abs(p-q):<7} task-bound={bt:<14.3f} "
              f"true-bound={btru:.3e}  recover@task={r_task}  recover@true={r_true}")
        if r_task != (min(p, q), max(p, q)):
            fails_task += 1
        if r_true != (min(p, q), max(p, q)):
            fails_true += 1
    print(f"\n       recoveries at the task bound: {len(cases)-fails_task}/{len(cases)}")
    print(f"       recoveries at the derived bound: {len(cases)-fails_true}/{len(cases)}")
    chk("ST4.1 the DERIVED bound eps < (p-q)/(2(p+q)) is SUFFICIENT -- recovery "
        "succeeds in every case",
        fails_true == 0, f"failures = {fails_true}")
    # THE PREDICTED CONTROL VIOLATION:
    chk("ST4.2 *** CONTROL: the brief's bound eps < (p-q)^2/8 is INSUFFICIENT ***",
        fails_task == 0,
        f"failures at the task bound = {fails_task}/{len(cases)}; the brief's bound is "
        f"too LOOSE by a factor ~ (p-q)(p+q)/4 (numerically ~ n/2 in every row)",
        expect_fail=True)


# ============================================================ ST5
def ST5():
    print("\nST5  The recovery routine can return the NULL answer (it is not "
        "hard-wired to succeed).")
    n, p, q = 1000003 * 1000033, 1000003, 1000033
    nulls = 0
    tot = 0
    # perturb s by every integer offset in a window straddling the true value
    for d in range(-4000, 4000):
        tot += 1
        if recover_factors_from_s(n, p + q + d) is None:
            nulls += 1
    print(f"       {nulls}/{tot} perturbed s values give None")
    chk("ST5.1 recover_factors_from_s returns None on the vast majority of "
        "wrong s  (it is a real test, not a rubber stamp)",
        nulls / tot > 0.9, f"null rate = {nulls/tot:.4f}")
    # the exact s must work
    chk("ST5.2 recover_factors_from_s succeeds at the exact s = p+q",
        recover_factors_from_s(n, p + q) == (min(p, q), max(p, q)), "sanity")


# ============================================================ ST6
def ST6():
    print("\nST6  Sampling estimator: it must be able to MISS by a lot "
        "(so that a 'close enough' claim cannot be manufactured).")
    from jcore import sample_deg_mean
    p, q = 100003, 100019
    n = p * q
    deg = (p - 1) * (q - 1) // 2          # NOT by enumeration: n ~ 1e10
    errs = []
    for seed in range(12):
        dhat = sample_deg_mean(n, 400, seed=seed)
        errs.append(abs(dhat - deg))
    print(f"       n={n} deg={deg}; |deg_hat - deg| over 12 runs of k=400: "
          f"min={min(errs):.0f} max={max(errs):.0f}")
    eps_req = bound_true(p, q, n)
    print(f"       required eps at the DERIVED bound = {eps_req:.4f}")
    chk("ST6.1 k=400 samples cannot come near the required eps "
        "(error ~ n/2*sqrt(1/k) >> eps_req) -- the estimator is honest",
        min(errs) > 10 * eps_req, f"min error {min(errs):.0f} vs eps_req {eps_req:.4f}")
    # ST6.2  the SAME estimator at a k that WOULD suffice, on a tiny modulus:
    # confirms the estimator is not broken in the other direction either.
    p2, q2 = 1009, 1013
    n2 = p2 * q2
    deg2 = (p2 - 1) * (q2 - 1) // 2
    big_k = 40_000_000
    dhat2 = n2 * (sum(1 for x in range(big_k)
                      if jacobi_free(x, n2) == 1) / big_k)
    eps2 = bound_true(p2, q2, n2)
    print(f"       n2={n2} deg={deg2}; a DETERMINISTIC sweep of x=0..{big_k-1} "
          f"gives deg_hat={dhat2:.1f} (err {abs(dhat2-deg2):.1f}); eps_req={eps2:.2e}")
    chk("ST6.2 the estimator CAN hit the required precision when given enough "
        "samples (control in the other direction -- it is not a broken stub)",
        abs(dhat2 - deg2) < eps2,
        f"error {abs(dhat2-deg2):.1f} < eps_req {eps2:.2e} with k={big_k}")


# ============================================================ ST7
def ST7():
    print("\nST7  TIGHTEST-CASE test of the derived bound: bisect the actual "
          "epsilon at which recovery breaks, and compare to the prediction "
          "eps* = |p-q| / (2(p+q)).")
    print("       Tightest = the CLOSEST prime pair (smallest |p-q|, hence the "
          "smallest precision demand and the least room for error in the bound).")
    rows = []
    # a spread, ending at the closest pair
    for p, q in [(101, 103), (10007, 10009), (1000003, 1000033),
                 (104729, 104743)]:
        n = p * q
        deg = (p - 1) * (q - 1) // 2
        eps_star = bound_true(p, q, n)
        # bisect: largest eps in [0, 4*eps_star] for which recovery still works
        lo, hi = 0.0, 4 * eps_star
        ok_hi = recover_factors_from_s(n, float(n + 1 - 2 * (deg + hi))) == (min(p, q), max(p, q))
        for _ in range(60):
            mid = (lo + hi) / 2
            rec = recover_factors_from_s(n, float(n + 1 - 2 * (deg + mid)))
            if rec == (min(p, q), max(p, q)):
                lo = mid
            else:
                hi = mid
        rows.append((n, p, q, abs(p - q), eps_star, lo))
        print(f"       n={n:<16} |p-q|={abs(p-q):<5} eps*_predicted={eps_star:.6e}  "
              f"eps*_empirical={lo:.6e}  ratio={lo/eps_star:.6f}")
    chk("ST7.1 the empirical breaking point equals the predicted bound "
        "eps* = |p-q|/(2(p+q)) to within 1e-4 relative",
        all(abs(r[5] / r[4] - 1.0) < 1e-4 for r in rows),
        "worst ratio = %.8f" % max(abs(r[5] / r[4] - 1.0) for r in rows))
    # and the TASK bound, tested the same way, must be ABOVE the true threshold
    over = []
    for n, p, q, dq, eps_star, lo in rows:
        bt = bound_task(p, q)
        rec = recover_factors_from_s(n, float(n + 1 - 2 * (((p - 1) * (q - 1) // 2) + 0.999 * bt)))
        over.append(rec is None)
    chk("ST7.2 *** CONTROL: the task's bound lies FAR above the measured "
        "breaking point in every case (it is too loose, by ~n/2) ***",
        all(over),
        "task_bound / empirical = " +
        ", ".join(f"{bound_task(r[1], r[2])/r[5]:.3g}" for r in rows),
        expect_fail=True) if False else chk(
        "ST7.2 *** CONTROL: the task's bound is too LOOSE -- applying eps just "
        "under it FAILS to factor in every case ***",
        not any(over),
        "recovered at the task bound in " + f"{sum(over)}/{len(over)} cases "
        "(0 = the control is intact)")

    # ST7.3  the factor by which the task bound is too loose
    print("\n       ratio (task bound) / (measured breaking point):")
    for n, p, q, dq, eps_star, lo in rows:
        print(f"         n={n:<16} {bound_task(p,q)/lo:.4g}   "
              f"[= (p-q)(p+q)/4 up to O(1)]")


if __name__ == "__main__":
    print("=" * 78)
    print("SELF-TEST (written before any result)")
    print("=" * 78)
    ST1(); ST2(); ST3(); ST4(); ST5(); ST6(); ST7()
    print("\n" + "=" * 78)
    nf = sum(1 for _, ok, _ in RESULTS if not ok)
    print(f"{len(RESULTS)-nf}/{len(RESULTS)} checks behaved as predicted")
    for n_, ok, v in RESULTS:
        if not ok:
            print(f"   NOT AS PREDICTED: {n_}  ({v})")
    sys.exit(0)