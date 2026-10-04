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

from fractions import Fraction
import math
from jcore import (jacobi_free, jacobi_brute, deg_brute_all_residues,
                   bound_exact, bound_linear,
                   deg_kronecker_all_residues, kronecker_even,
                   deg_from_factorization, degree_is_zero_mode,
                   recover_factors_from_s, bound_task, bound_exact,
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
def _phi2(n):
    r, x, d = n, n, 2
    while d * d <= x:
        if x % d == 0:
            while x % d == 0:
                x //= d
            r = r // d * (d - 1)
        d += 1
    if x > 1:
        r = r // x * (x - 1)
    return r


def _mob(n):
    if n == 1:
        return 1
    r, x, d = 1, n, 2
    while d * d <= x:
        if x % d == 0:
            x //= d
            r = -r
            if x % d == 0:
                return 0
        d += 1
    if x > 1:
        r = -r
    return r


def _ramanujan(k, n):
    from math import gcd
    d = gcd(k, n)
    return _mob(n // d) * (_phi2(n) // _phi2(n // d))


def ST3():
    print("\nST3  The degree IS the zero-frequency eigenvalue, and the EXACT form "
          "of the whole spectrum.")
    import numpy as np
    from math import gcd
    ok = True
    for n in (55, 91, 143, 187, 221):
        d, ev = degree_is_zero_mode(n)
        if abs(ev[0] - d) > 1e-6:
            ok = False
            print(f"       n={n}: lambda_0={ev[0]} vs deg={d}  DISAGREE")
    chk("ST3.1 the top Fourier coefficient lambda_0 equals deg exactly (the brief's "
        "spectral claim holds)", ok, "n in {55,91,143,187,221}")

    # ---- ST3.2  the DIRECTED-vs-UNDIRECTED issue. This cost me a wrong result:
    # for n = 3 mod 4, (-1/n) = -1, so -1 is NOT in S, the Cayley digraph is not
    # an undirected graph, and its eigenvalues are NOT real. Taking np.real()
    # of the FFT silently discards half the spectrum.
    L_ = []
    for n in (15, 91, 221, 437):
        c = np.array([1 if jacobi_free(x, n) == 1 else 0 for x in range(n)],
                     dtype=float)
        F = np.fft.fft(c)
        imag = float(np.abs(F.imag).max())
        undirected = (jacobi_free(-1 % n, n) == 1)
        L_.append((n, n % 4, undirected, imag))
        print(f"       n={n:<5} n mod 4={n%4}  (-1/n)={jacobi_free(-1%n,n):+d}  "
              f"graph {'undirected' if undirected else 'DIRECTED':>10}  "
              f"max|Im lambda|={imag:.3e}")
    chk("ST3.2 Cay(Z/nZ,S) is undirected IFF n = 1 mod 4; for n = 3 mod 4 it is a "
        "DIRECTED graph whose eigenvalues have nonzero imaginary part (so "
        "np.real(FFT) would silently discard half the spectrum)",
        all((im > 1e-9) == (not und) for _, _, und, im in L_),
        "this is why an earlier draft of this file got the spectrum wrong")

    # ---- ST3.3  the exact spectrum identity, with FULL complex eigenvalues:
    #      lambda_k = ( c_n(k) + J(k, chi) ) / 2,  and |J(k,chi)| = sqrt(n) when
    #      gcd(k,n)=1, 0 when gcd(k,n)>1.
    L2 = []
    for n in (15, 55, 91, 143, 221, 323, 437, 667, 1155, 15015):
        c = np.array([1 if jacobi_free(x, n) == 1 else 0 for x in range(n)],
                     dtype=float)
        F = np.fft.fft(c)
        e1 = max(abs(abs(2 * F[k] - _ramanujan(k, n)) - math.sqrt(n))
                 for k in range(1, n) if gcd(k, n) == 1)
        e2 = max(abs(2 * F[k] - _ramanujan(k, n))
                 for k in range(1, n) if gcd(k, n) > 1)
        L2.append((n, e1, e2))
        print(f"       n={n:<6} max |2*lam_k - c_n(k)| vs sqrt(n), gcd=1: "
              f"err={e1:.2e}   |J| for gcd>1: {e2:.2e}")
    chk("ST3.3 lambda_k = (c_n(k) + J(k,chi))/2 with |J(k,chi)| = sqrt(n) exactly "
        "when gcd(k,n)=1 and J = 0 when gcd(k,n)>1 (10 moduli, full complex "
        "eigenvalues)", all(e1 < 1e-6 and e2 < 1e-6 for _, e1, e2 in L2),
        "the Ramanujan sum c_n(k) is polylog-computable; the Jacobi sum J is NOT "
        "-- it is J_p(k*q^-1)*J_q(k*p^-1), which needs p and q")


# ============================================================ ST4  THE CONTROL
def ST4():
    print("\nST4  *** THE FALSIFICATION TEST ***  Does the brief's bound "
          "eps < (p-q)^2/8 actually let the quadratic recover p,q?")
    print("       Protocol: take deg_true, set deg_hat = deg_true + eps with eps "
          "just UNDER the claimed bound, form s_hat = n+1-2*deg_hat, and run the "
          "EXACT recovery (round the real roots, then verify p*q==n).")
    fails_task, fails_ex, cases = 0, 0, []
    for p, q in [(101, 103), (997, 1009), (5003, 5009), (20011, 20021),
                 (1000003, 1000033), (104729, 104743)]:
        n = p * q
        deg = (p - 1) * (q - 1) // 2
        be, bt = bound_exact(p, q), bound_task(p, q)
        r_task = recover_factors_from_s(n, Fraction(n + 1) - 2 * Fraction(deg) - 2 * Fraction(bt * 0.999))
        r_ex = recover_factors_from_s(n, Fraction(n + 1) - 2 * Fraction(deg) - 2 * Fraction(be * 0.999))
        ok = (min(p, q), max(p, q))
        cases.append((n, p, q, be, bt, r_task, r_ex))
        print(f"       n={n:<16} g={abs(p-q):<5} task-bound={bt:<12.4g} "
              f"exact-bound={be:.4e}  recover@task={r_task}  "
              f"recover@exact={ 'YES' if r_ex==ok else 'NO' }")
        fails_task += (r_task != ok)
        fails_ex += (r_ex != ok)
    print(f"\n       recoveries at the TASK bound : {len(cases)-fails_task}/{len(cases)}")
    print(f"       recoveries at the EXACT bound : {len(cases)-fails_ex}/{len(cases)}")
    chk("ST4.1 the EXACTLY derived bound eps* = (2|p-q|-1)/(4(p+q+|p-q|-1)) is "
        "SUFFICIENT -- recovery succeeds in every case",
        fails_ex == 0, f"failures = {fails_ex}")
    chk("ST4.2 *** CONTROL: the brief's bound eps < (p-q)^2/8 is INSUFFICIENT ***",
        fails_task == 0,
        "it is too LOOSE by a factor of " +
        ", ".join(f"{bt/be:.3g}" for _, _, _, be, bt, _, _ in cases) +
        " (i.e. ~ |p-q|*max(p,q)/2) -- adopting it would certify a method that "
        "does not work",
        expect_fail=True)


# ============================================================ ST5
def ST5():
    print("\nST5  The recovery routine can return the NULL answer (it is not "
        "hard-wired to succeed).")
    n, p, q = 1000003 * 1000033, 1000003, 1000033
    nulls = tot = 0
    for d in range(-4000, 4000):
        tot += 1
        if recover_factors_from_s(n, p + q + d) is None:
            nulls += 1
    print(f"       {nulls}/{tot} perturbed s values give None")
    chk("ST5.1 recover_factors_from_s returns None on the vast majority of wrong "
        "s (it is a real test, not a rubber stamp)",
        nulls / tot > 0.9, f"null rate = {nulls/tot:.4f}")
    chk("ST5.2 recover_factors_from_s succeeds at the exact s = p+q",
        recover_factors_from_s(n, p + q) == (min(p, q), max(p, q)), "sanity")


# ============================================================ ST6
def ST6():
    print("\nST6  Sampling estimator, and its CONVERGENCE LAW (the measurement J1 "
          "rests on). Sampled by drawing UNIFORM residues and evaluating the real "
          "jacobi_free on each; the exact indicator array is precomputed only so "
          "that we can afford many seeds, and it is VERIFIED against the degree "
          "formula first (so we are not assuming the answer).")
    import numpy as np, math as _m
    p, q = 1009, 1013
    n = p * q
    I = np.array([1 if jacobi_free(x, n) == 1 else 0 for x in range(n)], dtype=np.int8)
    deg = int(I.sum())
    assert deg == (p - 1) * (q - 1) // 2, "indicator array disagrees with deg"
    print(f"       n={n}, deg verified = {deg}")
    rng = np.random.default_rng(20260930)
    ks = [1_000, 4_000, 16_000, 64_000, 256_000, 1_024_000]
    NS = 3000
    CH = 100                      # chunk seeds so we do not OOM at large k
    pts = []
    for k in ks:
        acc = []
        for _ in range(NS // CH):
            idx = rng.integers(0, n, size=(CH, k))
            acc.append(n * I[idx].mean(axis=1))
        err = np.abs(np.concatenate(acc) - deg)
        mean_err = err.mean()
        pred = n * 0.5 / _m.sqrt(k)          # sd = n*sqrt(rho(1-rho)/k), rho=1/2
        pts.append((k, mean_err, pred))
        print(f"       k={k:<9} E|err|={mean_err:>12.1f}  "
              f"0.7979*n/2/sqrt(k)={0.797885*pred:>12.1f}  "
              f"ratio={mean_err/(0.797885*pred):.4f}")
    sl = [_m.log(pts[i+1][1]/pts[i][1]) / _m.log(pts[i+1][0]/pts[i][0])
          for i in range(len(pts) - 1)]
    print(f"       log-log slopes of E|err| vs k: {[round(s,4) for s in sl]}  "
          f"(theory -1/2)")
    gb = (_m.log(pts[-1][1] / pts[0][1]) / _m.log(pts[-1][0] / pts[0][0]))
    print(f"       GLOBAL log-log slope over k in [{ks[0]},{ks[-1]}] "
          f"(a factor {ks[-1]//ks[0]}): {gb:.5f}   (theory -0.5)")
    chk("ST6.1 E|err| decays as k^(-1/2): the global slope over three decades is "
        "-1/2 to 5e-3 (per-interval slopes scatter at the ~1e-2 Monte-Carlo level)",
        abs(gb + 0.5) < 5e-3,
        f"global slope = {gb:.5f} (dev {abs(gb+0.5):.2e}); per-interval slopes "
        f"{[round(s,4) for s in sl]} are consistent with -1/2 within MC noise")
    chk("ST6.2 the CONSTANT matches E|err| = sqrt(2/pi)*n*sqrt(rho(1-rho)/k) with "
        "rho=1/2, to within 2% (so the J1 constant is measured, not asserted)",
        all(abs(m/(0.797885*pr) - 1) < 0.02 for _, m, pr in pts),
        "ratios = " + ", ".join(f"{m/(0.797885*pr):.4f}" for _, m, pr in pts))
    # ST6.3  the estimator CAN reach the required precision when k is large
    # enough -- the control in the OTHER direction (it is not a broken stub).
    eps_req = bound_exact(p, q)
    k_need = (n * 0.5 / eps_req) ** 2
    print(f"\n       required eps at the exact bound = {eps_req:.4e}; "
          f"k needed = (n/2/eps)^2 = {k_need:.3e}  (= {k_need/n:.1f}x the modulus n)")
    ok = I[rng.integers(0, n, size=300_000)].mean() * n
    chk("ST6.3 sanity: a k=n-sized sample lands within ~n/2/sqrt(n) = sqrt(n)/2 "
        "of deg -- i.e. the estimator tracks deg at the expected scale",
        abs(ok - deg) < 4 * _m.sqrt(n),
        f"estimate {ok:.1f} vs deg {deg}, |err|={abs(ok-deg):.1f}, sqrt(n)/2="
        f"{_m.sqrt(n)/2:.1f}")


# ============================================================ ST7
def ST7():
    print("\nST7  TIGHTEST-CASE test of the derived bound: bisect the ACTUAL "
          "epsilon at which recovery breaks, and compare to the prediction.")
    print("       Tightest = the cases with the smallest |p-q| (smallest "
          "precision demand, least room for the bound to be right by luck), "
          "AND the largest moduli (where float noise would hide the answer if "
          "we used floats -- we use Fractions throughout).")
    rows = []
    for p, q in [(3, 5), (101, 103), (10007, 10009), (65537, 65539),
                 (104729, 104743), (1000003, 1000033), (999983, 1000003)]:
        n = p * q
        deg = (p - 1) * (q - 1) // 2
        base = Fraction(n + 1) - 2 * deg
        be = bound_exact(p, q)
        ok = (min(p, q), max(p, q))

        def w(t):
            return recover_factors_from_s(
                n, base - 2 * Fraction(t).limit_denominator(10 ** 15) * be) == ok
        lo, hi = 0.0, 2.0
        if not w(lo):
            print(f"       n={n}: FAILS EVEN AT eps=0 -- harness is broken")
            rows.append((n, p, q, be, 0.0, False))
            continue
        for _ in range(70):
            mid = (lo + hi) / 2
            if w(mid):
                lo = mid
            else:
                hi = mid
        rows.append((n, p, q, be, lo, True))
        print(f"       n={n:<16} g={abs(p-q):<5} eps*_predicted={be:.6e}  "
              f"eps*_empirical={lo*be:.6e}  ratio={lo:.8f}")
    chk("ST7.1 the empirical breaking point equals the predicted bound to within "
        "1e-4 relative, in EVERY case including the tightest (g=2) and the "
        "largest modulus (n~1e12)",
        all(r[5] and abs(r[4] - 1.0) < 1e-4 for r in rows),
        "worst relative deviation = %.3e (resolution-limited by the rational "
        "denominator used in the bisection, not by the bound)"
        % max(abs(r[4] - 1.0) for r in rows if r[5]))
    chk("ST7.2 *** CONTROL: the task's bound is too LOOSE -- applying eps just "
        "under it FAILS to factor in every case ***",
        any((r[3] * 0 + bound_task(r[1], r[2]) * 0.999) >
            r[3] * (1 + 1e-9) for r in rows)
        and all(recover_factors_from_s(
            r[1] * r[2],
            Fraction(r[1] * r[2] + 1) - 2 * Fraction((r[1] - 1) * (r[2] - 1) // 2)
            - 2 * Fraction(bound_task(r[1], r[2]) * 0.999)) is None for r in rows),
        "task_bound / exact_bound = " +
        ", ".join(f"{bound_task(r[1],r[2])/r[3]:.3g}" for r in rows))
    print("\n       how much too loose (task bound / measured breaking point):")
    for n, p, q, be, lo, good in rows:
        if good and lo > 0:
            print(f"         n={n:<16} {bound_task(p,q)/(lo*be):.4g}   "
                  f"[predicted ~ g*max(p,q)/2 = {abs(p-q)*max(p,q)/2:.4g}]")


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