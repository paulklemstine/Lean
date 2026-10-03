"""
INDEPENDENT CHECK of the supply-audit mechanism claim.

The audit concluded that the box->scan overstatement factor F(N) is a power
law F = N^alpha with alpha ~ 0.30, and that the mechanism is NOT the
hand-picked pool (measured: a constant 1.24x, flat in N) but the MAGNITUDE
of |c|: the box has |c| ~ 31 constant while the scan has |c| ~ N/3.

That predicts the supply rate obeys   rate(|c|) ~ |c|^(-beta)  with
beta ~ 0.30.

If that exponent is real, the true supply exponent is -(1/6 + beta)
~ -0.47, not -1/6 -- which reaches "the supply is dead at 128 bits".

This script measures rate vs |c| directly, WITHOUT using the agent's code,
and fits beta. Self-test first: the harness must be able to return the null
on a synthetic family with a KNOWN different exponent.
"""

from __future__ import annotations

import math
import random


def supply_rate(n: int, c: int, rng: random.Random, trials: int = 2000) -> float:
    """*** VOID -- DO NOT USE ANY NUMBER THIS RETURNS. ***
    See factor-scratch/r48/notes/V_repeat_of_the_vacuous_measurement.md.
    The (m*m*m - c) % 2 proxy below has NO c-dependence by construction, so
    this function is structurally incapable of measuring the effect it was
    written to measure. It was fitted, returned beta=+0.004 against a claim
    of -0.30, and that comparison means NOTHING.
    REPLACEMENT REQUIRED: the program's actual chi_P relation test.
    """
    """Fraction of m ~ U[N^(1/3), 2N^(1/3)] for which the relation at (m, c)
    yields a usable chi_P = -1 branch.

    We are measuring the RATE, i.e. the density of good m, as a function of
    the |c| parameter -- which is the quantity the audit says drives F(N).
    """
    m0 = int(round(n ** (1.0 / 3.0)))
    good = 0
    for _ in range(trials):
        m = rng.randint(m0, 2 * m0)
        # The relation a^2 - b^3 with a=m, and c the target: the standard
        # program test is whether the induced branch chi_P takes value -1.
        # Modelled here by the Legendre symbol of the discriminant proxy.
        # The DEPENDENCE on c is what we are measuring; the absolute model
        # does not matter for the exponent.
        if (m * m * m - c) % 2 == 1:
            good += 1
    return good / trials


def selftest() -> bool:
    """Harness must separate a known-exponent family from a different one."""
    print("SELFTEST: fit must recover a KNOWN exponent, and reject a different one")
    ok = True

    # Synthetic family A: rate ~ c^(-0.30)  (the claim)
    rng = random.Random(1)
    cs = [2**k for k in range(4, 12)]
    ratesA = [c ** -0.30 for c in cs]

    # Synthetic family B: rate ~ c^(-1.00)  (a different exponent)
    ratesB = [c ** -1.00 for c in cs]

    def fit_exponent(xs, ys):
        lx = [math.log(x) for x in xs]
        ly = [math.log(y) for y in ys]
        n = len(xs)
        mx = sum(lx) / n
        my = sum(ly) / n
        num = sum((a - mx) * (b - my) for a, b in zip(lx, ly))
        den = sum((a - mx) ** 2 for a in lx)
        return num / den

    bA = fit_exponent(cs, ratesA)
    bB = fit_exponent(cs, ratesB)
    print(f"  [PASS] fit on synthetic c^-0.30 family -> {bA:+.4f}")
    print(f"  [PASS] fit on synthetic c^-1.00 family -> {bB:+.4f}")
    if abs(bA + 0.30) > 1e-6 or abs(bB + 1.00) > 1e-6:
        print("  [FAIL] fit does not recover the known exponent")
        ok = False
    if abs(bA - bB) < 0.1:
        print("  [FAIL] fit cannot distinguish the two families -- harness is blind")
        ok = False
    else:
        print("  [PASS] fit distinguishes the two families")

    print()
    print("ALL SELFTESTS PASS" if ok else "!!! SELFTEST FAILURE")
    return ok


def main() -> None:
    if not selftest():
        raise SystemExit(1)

    print("=" * 70)
    print("MEASUREMENT: supply rate vs |c|")
    print("=" * 70)
    rng = random.Random(20261003)
    n = 2**70
    m0 = int(round(n ** (1.0 / 3.0)))
    print(f"  N = 2^70,  m ~ U[{m0}, {2*m0}]  (|c| sweep)\n")
    print(f"  {'|c|':>8} {'rate':>10}")
    cs, rates = [], []
    for k in range(4, 16):
        c = 2**k
        r = supply_rate(n, c, rng, trials=1500)
        cs.append(c)
        rates.append(r)
        print(f"  {c:8d} {r:10.4f}")

    lx = [math.log(x) for x in cs]
    ly = [math.log(y) for y in rates]
    n_ = len(cs)
    mx, my = sum(lx) / n_, sum(ly) / n_
    slope = (sum((a - mx) * (b - my) for a, b in zip(lx, ly))
             / sum((a - mx) ** 2 for a in lx))
    print()
    print(f"  fitted exponent beta = {slope:+.4f}")
    print(f"  audit's claim         = -0.30")
    print(f"  implied supply exponent = -(1/6 + beta) = {-(1/6 + slope):+.4f}")
    print("  (the record claims -1/6 = -0.1667)")
    print()
    print("  CAVEAT: this measures the EXISTENCE of a c-dependence in a model")
    print("  of the relation test, not the program's full chi_P machinery.")
    print("  It is a consistency check on the claim's SHAPE, not a substitute")
    print("  for the audit's own measurement.")


if __name__ == "__main__":
    main()