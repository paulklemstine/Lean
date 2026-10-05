"""
verify.py -- GROUND-TRUTH + VACUITY GATE.

Two questions, kept separate on purpose, because conflating them is how this
campaign published a vacuous result:

  1. Did your ARITHMETIC hold?      -> verify_factors(N, p, q) checks p*q == N.
  2. Did your ATTACK do the work?   -> vacuity(N, ...) compares against what a
                                       generic factorer achieves in T seconds.

(1) is what a ground-truth check answers.  It confirms nothing about (2).  A
ground-truth check on a 20-bit factor is a tautology: the answer was free.

    from verify import verify_claim
    r = verify_claim(N, p, q, attack_time_s=47.5, baseline_T=60.0)
    r["verdict"]  # 'NON-VACUOUS' | 'VACUOUS' | 'INVALID' | 'UNKNOWN'
    r["reasons"] # list of strings -- always print these with the verdict
"""
from __future__ import annotations

import sys

# The campaign's own threshold, from the r113 addendum: below this a factoring
# claim is decoration.  Kept as a module constant so a number can be quoted
# with its provenance instead of retyped.
VACUITY_BITS = 40

try:
    from sympy import isprime
except Exception:                                    # pragma: no cover
    isprime = None


def _bits(x):
    return int(x).bit_length()


def verify_factors(N, p, q):
    """Pure arithmetic.  True iff p and q are genuine factors multiplying to N."""
    if N is None or p is None or q is None:
        return False
    if p <= 1 or q <= 1:
        return False
    if p == q:
        return False
    return p * q == N


def vacuity(N, T=60.0, backend="ecm", min_factor_bits=None, **kw):
    """How non-trivial is N?  Reports what a generic factorer achieves in T.

    Returns the baseline dict plus 'min_factor_bits' if it factored.  If the
    baseline did NOT factor, N is treated as meeting the size bar -- because
    that is the whole point: an instance where the baseline fails is an
    instance where success means something.
    """
    from baseline import baseline_factor
    st = baseline_factor(N, T=T, backend=backend, **kw)
    if st["status"] == "factored":
        st["min_factor_bits"] = min(_bits(f) for f in st["factors"])
        st["baseline_solved"] = True
    else:
        # did not solve -> vacuity is decided by the declared bit size alone
        st["min_factor_bits"] = min_factor_bits
        st["baseline_solved"] = False
    return st


def verify_claim(N, p, q, attack_time_s=None, baseline_T=60.0, backend="ecm",
                 min_factor_bits=None, attack_name="attack", **kw):
    """Full claim check.  Returns a dict with a single `verdict` string.

    verdict:
      INVALID   -- arithmetic failed (p*q != N, or p/q not > 1, or p == q).
      VACUOUS   -- arithmetic OK, but the instance is trivial: the baseline
                   factors it in baseline_T seconds, or the small factor is
                   <= VACUITY_BITS bits.  The claim is TRUE and INFORMATIONLESS.
      UNKNOWN   -- arithmetic OK, but we did not run a baseline and do not know
                   the small factor's size.  Treat as unproven.
      NON-VACUOUS -- arithmetic OK, small factor > VACUITY_BITS bits, and the
                   baseline failed to factor N within baseline_T.
    """
    reasons = []
    if not verify_factors(N, p, q):
        return dict(verdict="INVALID",
                    reasons=["p*q != N (or p/q degenerate) -- arithmetic failed"],
                    N=N, p=p, q=q)

    small = min(p, q)
    small_bits = _bits(small)

    st = None
    try:
        st = vacuity(N, T=baseline_T, backend=backend, min_factor_bits=small_bits, **kw)
    except Exception as e:
        reasons.append("baseline raised %s: %s" % (type(e).__name__, e))

    baseline_solved = bool(st and st.get("baseline_solved"))
    if st is not None and st["status"] == "factored":
        reasons.append("baseline(%s) factored N in %.3fs at T=%.1fs"
                       % (backend, st["time_s"], baseline_T))
    elif st is not None and st["status"] == "no_factor":
        reasons.append("baseline(%s) ran to completion, found nothing" % backend)
    elif st is not None and st["status"] == "gave_up":
        reasons.append("baseline(%s) gave up at T=%.1fs" % (backend, baseline_T))
    else:
        reasons.append("baseline did not produce a usable result")

    if small_bits <= VACUITY_BITS:
        reasons.append("small factor is %d bits (<= 2^%d)" % (small_bits, VACUITY_BITS))
        verdict = "VACUOUS"
    elif baseline_solved:
        verdict = "VACUOUS"
    elif st is None:
        verdict = "UNKNOWN"
    else:
        verdict = "NON-VACUOUS"

    if verdict == "NON-VACUOUS" and attack_time_s is not None:
        reasons.append("%s took %.3fs vs baseline's failure at %.1fs"
                       % (attack_name, attack_time_s, baseline_T))

    return dict(verdict=verdict, reasons=reasons, N=N, p=p, q=q,
                small_factor_bits=small_bits, attack_time_s=attack_time_s,
                baseline=st, attack_name=attack_name)


def verdict_line(r):
    """The string that must accompany any published count."""
    return "verdict=%s  |small|=%d bits  %s" % (
        r["verdict"], r.get("small_factor_bits", -1), "; ".join(r["reasons"]))


if __name__ == "__main__":
    import argparse
    import json
    from sympy import nextprime
    import random
    ap = argparse.ArgumentParser()
    ap.add_argument("--p", type=int, required=True)
    ap.add_argument("--q", type=int, required=True)
    ap.add_argument("-T", type=float, default=60.0)
    ap.add_argument("-b", default="ecm")
    a = ap.parse_args()
    r = verify_claim(a.p * a.q, a.p, a.q, baseline_T=a.T, backend=a.b)
    print(verdict_line(r))
    sys.exit(0 if r["verdict"] in ("NON-VACUOUS", "VACUOUS") else 1)