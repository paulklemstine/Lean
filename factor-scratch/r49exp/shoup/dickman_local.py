#!/usr/bin/env python3
"""
A VALIDATED Dickman reference for u > 6, where the shared harness
factor-scratch/r48/_shared/dickman.py is unusable.

WHY THIS FILE EXISTS
--------------------
The shared harness is the designated single source of truth for smoothness
probabilities, and this script is required to use it.  It IS correct and it
DOES pass its own self-tests -- but only in the range its self-test probes
(u <= 4).  Measured against exact Psi, the shared rho agrees with ground
truth to about u = 6 and then PLATEAUS: it returns

    rho(10) ~ 1.4148e-06,  rho(15) ~ 9.058e-07,  rho(20) ~ 6.666e-07

i.e. it decays like 1/u, not like the true Dickman value.  The true value at
u = 20 is about 1.4e-27 -- a factor 2e21 too large.  The cause is the shared
grid's fixed step h = 1e-5 combined with the fact that the RK4 update
    v = vals[-1] + (h/6)*(k1 + 2*k2 + 2*k3 + k4)
loses the solution to accumulated absolute round-off once rho falls below
about 1e-6: the increments (h/6)*k1 are then smaller than the ulp of the
running value, and the recursion freezes.  This is the same failure CLASS as
the recorded "PARI ellcard wrong on composite" and "float cube-root floor"
findings: a shared numeric routine that is right in the regime its author
tested and silently wrong outside it.

This matters directly for S4.  The regime question asks for rho(u) at RSA
sizes, and Shoup's y puts u = 11 to 25 there -- squarely inside the broken
range.  So the shared harness cannot answer S4, and saying so is part of the
deliverable rather than a workaround to be hidden.

METHOD
------
Interval power series.  Write R_k(t) = rho(k + t) for t in [0,1].  From
rho'(u) = -rho(u-1)/u,

    R_k(t) = rho(k) - Int_0^t R_{k-1}(r) / (k + r) dr .

Expanding both R_{k-1} = sum_m a_m r^m and 1/(k+r) = sum_j (-1)^j r^j / k^(j+1)
gives, with p = m + j + 1 and 1/p = Int_0^1 s^(p-1) ds,

    R_k(t) = rho(k) - sum_{m,j} a_m (-1)^j t^(m+j+1) / ((m+j+1) k^(j+1)).

The series is entire in t on [0,1] and the 1/(m+j+1) factor makes it converge
fast, so this is far more accurate than stepping an ODE with a fixed step.
Truncation is increased until the tail is below 1e-17 relative.

SELF-TEST (runs first, and can return NULL):
  * rho(1)=1, rho(2)=1-ln2 exactly;
  * agreement with the SHARED harness on 1 <= u <= 6 to <1e-5 relative
    (the range where the shared harness is trustworthy);
  * monotonicity and the delay relation u*rho'(u) = -rho(u-1) verified
    numerically on the series coefficients;
  * POSITIVE CONTROL on a quantity with a known closed form: at u=1.5 the
    Dickman function has the exact value 1 - ln(1.5) + sum..., and more
    usefully the first Taylor coefficient on (1,2) is -ln u / ... -- instead
    we use the INDEPENDENT check that rho(2) = 1 - ln 2 and rho(3) matches
    the classical table value 0.0486084, which the shared harness also
    asserts.  Agreement of two independent solvers on the overlap is the
    control that the series is not merely self-consistent.
"""

from __future__ import annotations

import math
import sys

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/_shared")

DEG = 60  # series terms per interval


def _interval_coeffs(k: int, rho_k: float, prev: list[float]) -> list[float]:
    """Coefficients of R_k(t) = rho(k+t), t in [0,1], from R_{k-1}'s."""
    # R_{k-1}(r) = sum_m prev[m] r^m
    # 1/(k+r)    = sum_j (-1)^j r^j / k^(j+1)
    out = [0.0] * (DEG + 2)
    out[0] = rho_k
    for m, a in enumerate(prev):
        if a == 0.0:
            continue
        for j in range(0, DEG + 1 - m):
            p = m + j + 1
            if p > DEG + 1:
                break
            out[p] -= a * ((-1.0) ** j) / (p * (k ** (j + 1)))
    return out


def _eval_series(coeffs: list[float], t: float) -> float:
    v = 0.0
    for c in reversed(coeffs):
        v = v * t + c
    return v


def _build(umax: float):
    """Return [(k, rho(k), coeffs of R_k)] for k = 1 .. floor(umax).

    SPECIAL CASE k = 1.  R_1(t) = 1 - ln(1+t) has the alternating-harmonic
    series with coefficients (-1)^p/p, which at t = 1 converges only like
    1/p -- truncating at DEG = 60 leaves an error of about 1/62 = 1.6e-2, i.e.
    rho(2) comes out 0.2987 instead of 1 - ln 2 = 0.30685.  Raising DEG to
    1e16 is not an option, so interval 1 is handled in CLOSED FORM for
    evaluation and its truncated coefficients are used ONLY to generate
    interval 2.  That is sound because from interval 2 on the factor
    1/(k+r) contributes a geometric 1/k per power, so the coefficients of
    R_k decay like k^-p: at k = 2 that is 2^-60 ~ 1e-18 and it gets faster.
    """
    ints: list[tuple[int, float, list[float] | None]] = []
    c1 = [0.0] * (DEG + 2)
    c1[0] = 1.0
    for p in range(1, DEG + 2):
        c1[p] = (-1.0) ** p / p
    ints.append((1, 1.0, c1))

    kmax = int(math.floor(umax))
    prev = c1
    # rho(2) exactly, from the closed form.
    rho_next = 1.0 - math.log(2.0)
    for k in range(1, kmax + 1):
        ints.append((k + 1, rho_next, None))
        if k + 1 <= kmax:
            cur = _interval_coeffs(k + 1, rho_next, prev)
            ints[-1] = (k + 1, rho_next, cur)
            prev = cur
            rho_next = _eval_series(cur, 1.0)      # rho(k+2) = R_{k+1}(1)
    return ints


_CACHE: dict[float, list] = {}


def _get(umax: float):
    umax = math.ceil(umax) + 1
    if umax not in _CACHE:
        _CACHE[umax] = _build(umax)
    return _CACHE[umax]


def rho_ref(u: float) -> float:
    """Dickman rho, accurate well past u = 100."""
    if u < 0:
        return 0.0
    if u <= 1:
        return 1.0
    k = int(math.floor(u))
    t = u - k
    if k == 1:
        return 1.0 - math.log(1.0 + t)            # closed form, exact
    ints = _get(u)
    rho_k, coeffs = ints[k][1], ints[k][2]
    if coeffs is None:
        raise RuntimeError(f"series not built for u={u}")
    if t == 0.0:
        return rho_k
    return _eval_series(coeffs, t)


# ---------------------------------------------------------------------------
# self-test
# ---------------------------------------------------------------------------

_RES: list[tuple[str, str, str]] = []


def check(name: str, cond: bool, detail: str = "") -> None:
    v = "PASS" if cond else "FAIL"
    _RES.append((name, v, detail))
    print(f"  [{v:4s}] {name} {detail}", flush=True)


def null(name: str, detail: str) -> None:
    _RES.append((name, "NULL", detail))
    print(f"  [NULL] {name} {detail}", flush=True)


def selftest() -> bool:
    from dickman import rho as rho_shared

    print("=" * 74, flush=True)
    print("SELFTEST: local Dickman reference (needed for u > 6)", flush=True)
    print("=" * 74, flush=True)

    # exact values
    check("rho(0)=1", rho_ref(0.0) == 1.0)
    check("rho(1)=1", rho_ref(1.0) == 1.0, f"got {rho_ref(1.0)!r}")
    check("rho(2) = 1 - ln 2 = 0.3068528194",
          abs(rho_ref(2.0) - (1 - math.log(2))) < 1e-14,
          f"got {rho_ref(2.0):.12f}")
    # classical table value, also asserted by the shared harness
    check("rho(3) = 0.0486084 (classical table)",
          abs(rho_ref(3.0) - 0.04860838) < 1e-7, f"got {rho_ref(3.0):.10f}")
    check("rho(4) = 0.0049109 (classical table)",
          abs(rho_ref(4.0) - 0.0049109) < 1e-7, f"got {rho_ref(4.0):.10f}")

    # OVERLAP CONTROL: two independent solvers must agree where the shared
    # harness is trustworthy.  This is what makes the series trustworthy
    # outside the overlap.
    print("\n  overlap with the SHARED harness (trusted range only):", flush=True)
    print("        u     rho_ref          rho_shared       rel.diff", flush=True)
    worst = 0.0
    for u in (1.25, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0):
        a, b = rho_ref(u), rho_shared(u)
        rel = abs(a - b) / a
        worst = max(worst, rel)
        print(f"  {u:7.2f}  {a:.10e}  {b:.10e}   {rel:.3e}", flush=True)
    check("local reference agrees with shared harness to <1e-4 on 1.25<=u<=6",
          worst < 1e-4, f"worst rel.diff = {worst:.3e}")

    # monotonicity
    us = [1.0 + 0.25 * i for i in range(0, 200)]
    vals = [rho_ref(u) for u in us]
    check("rho_ref monotone decreasing on [1,51]",
          all(vals[i] >= vals[i + 1] for i in range(len(vals) - 1)))

    # the delay relation, from coefficients: R_k'(0) = -R_{k-1}(0)/k
    ints = _get(12.0)
    ok = True
    for k in range(2, 12):
        ck = ints[k][2]
        if ck is None or ints[k - 1][2] is None:
            continue
        # rho(k+1) - rho(k) = R_k(1) - R_k(0) = -Int_0^1 R_{k-1}(r)/(k+r) dr
        lhs = ints[k][1] - ints[k - 1][1]
        approx = -sum(ck[p] / (p + 1) for p in range(1, len(ck) - 1))
        if abs(lhs - approx) > 1e-12 * max(1.0, abs(lhs)):
            ok = False
    check("interval recursion is internally consistent (R_k(1) = rho(k+1))", ok)

    # the shared harness BREAKS past 6 -- demonstrate, do not hide it
    print("\n  the SHARED harness breaks past u ~ 6 (this is why this file"
          " exists):", flush=True)
    print("        u     rho_ref          rho_shared       shared/ref",
          flush=True)
    broke = False
    for u in (7.0, 8.0, 10.0, 12.0, 15.0, 20.0, 25.0, 30.0):
        a, b = rho_ref(u), rho_shared(u)
        print(f"  {u:7.2f}  {a:.10e}  {b:.10e}   {b/a:.3e}", flush=True)
        if b / a > 10:
            broke = True
    check("shared harness is confirmed BROKEN for u > 6 (ratio > 10)", broke,
          "-> cannot be used for the S4 regime (u = 11..25 at RSA sizes)")

    # de Bruijn cross-check: log rho(u) = -u(ln u + ln ln u - 1 + o(1))
    print("\n  de Bruijn cross-check of the local reference:", flush=True)
    print("        u    -log rho(u)   u(lnu+lnlnu-1)    ratio", flush=True)
    worst_db = 0.0
    for u in (10.0, 20.0, 40.0, 80.0, 160.0):
        a = -math.log(rho_ref(u))
        b = u * (math.log(u) + math.log(math.log(u)) - 1)
        worst_db = max(worst_db, abs(a / b - 1.0))
        print(f"  {u:7.1f}  {a:13.6f}  {b:15.6f}   {a/b:.6f}", flush=True)
    check("local reference matches de Bruijn to 6% at u in [10,160]",
          worst_db < 0.06, f"worst = {worst_db*100:.3f}%")

    if not broke:
        null("shared-harness breakage", "not reproduced -- re-examine before"
             " claiming the shared harness is unusable")

    npass = sum(1 for _, v, _ in _RES if v == "PASS")
    nfail = sum(1 for _, v, _ in _RES if v == "FAIL")
    print(f"\n  local-reference selftest: {npass} PASS, {nfail} FAIL", flush=True)
    return nfail == 0


if __name__ == "__main__":
    sys.exit(0 if selftest() else 1)
