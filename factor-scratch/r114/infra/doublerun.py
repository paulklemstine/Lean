"""
doublerun.py -- run a measurement twice, report whether it is REPRODUCIBLE.

    from doublerun import double_run, rate
    r = double_run(lambda seed: measure(seed), seeds=range(12))
    if not r["agree"]:
        print(r["diff"])     # DO NOT publish a count from this

WHY THIS EXISTS
---------------
The campaign has lost three published numbers to unseeded drift:
  * r53 threshold_test.py: 13/40, then 12/40 on a re-run.
  * r112: 17/40 withdrawn; boundary cells gave 3/8 then 5/8.
  * r112: two "same-seed" passes gave 28/40 vs 33/40, because the seed was
    derived from Python's randomized str/tuple hash.

A count is only citable if it survives this module.  The bar is not "close" --
it is EXACT agreement on the per-seed outcome vector.

WHAT COUNTS AS A DISAGREEMENT
-----------------------------
Any difference in the per-seed outcome vector.  Timing jitter is NOT a
disagreement: `time_s` is deliberately excluded from the comparison and
reported separately.  Two runs of the same attack WILL differ in wall time; if
you made timing part of the verdict you would train yourself to ignore it.
"""
from __future__ import annotations

import json
import time


def _outcome(x):
    """Reduce a measurement to a comparable, hashable outcome.

    Floats that look like timings are dropped; everything else must match
    exactly.  If your measurement returns a float that genuinely matters
    (a rate, a lattice coefficient), do NOT let it round silently -- wrap it
    yourself and return the rounded value explicitly so the comparison is
    visible in the source.
    """
    if isinstance(x, dict):
        return tuple(sorted((k, _outcome(v)) for k, v in x.items()
                            if k not in ("time_s", "elapsed", "wall_s", "work_s")))
    if isinstance(x, (list, tuple)):
        return tuple(_outcome(v) for v in x)
    if isinstance(x, float):
        # keep as-is but normalise -0.0/0.0 so sign noise is not a "disagree"
        return 0.0 if x == 0 else x
    return x


def double_run(fn, seeds, warmup=None, label="measurement"):
    """Run fn(seed) once per seed, twice over.  Never raises on a failed run.

    Returns:
      outcomes_1, outcomes_2 : per-seed raw results
      vectors_1, vectors_2   : per-seed comparable outcomes
      agree                  : True iff the two vectors are identical
      diff                   : human-readable list of differing seeds
      timings_1, timings_2   : wall seconds per seed (reported, not compared)
      flaky_seeds            : seeds whose OUTCOME differed between passes
    """
    if warmup:
        for s in (warmup if hasattr(warmup, "__iter__") else [warmup]):
            try:
                fn(s)
            except Exception:
                pass

    def sweep():
        outs, tims = [], []
        for s in seeds:
            t0 = time.time()
            try:
                r = fn(s)
                err = None
            except Exception as e:
                r = ("EXCEPTION", type(e).__name__, str(e)[:120])
                err = "%s: %s" % (type(e).__name__, e)
            tims.append(time.time() - t0)
            outs.append((r, err))
        return outs, tims

    o1, t1 = sweep()
    o2, t2 = sweep()

    v1 = [_outcome(r) for r, _ in o1]
    v2 = [_outcome(r) for r, _ in o2]

    diff = []
    for i, s in enumerate(seeds):
        if v1[i] != v2[i]:
            diff.append("  seed %s: pass1=%s pass2=%s" % (s, _short(v1[i]), _short(v2[i])))

    return dict(label=label,
                seeds=list(seeds),
                agree=(v1 == v2),
                outcomes_1=[r for r, _ in o1], outcomes_2=[r for r, _ in o2],
                vectors_1=v1, vectors_2=v2,
                diff=diff,
                flaky_seeds=[seeds[i] for i in range(len(seeds)) if v1[i] != v2[i]],
                errors=[(seeds[i], e) for i, (_, e) in enumerate(o1) if e],
                timings_1=t1, timings_2=t2)


def _short(v, n=90):
    s = repr(v)
    return s if len(s) <= n else s[:n - 3] + "..."


def rate(bools):
    """Summarise a boolean outcome vector as a RATE, never as pass/fail.

    The r113 addendum: "Report a RATE, not pass/fail. A 0/4 against someone's
    3/3 is a seed problem until proven otherwise."
    """
    n = len(bools)
    k = sum(1 for b in bools if b)
    if n == 0:
        return dict(k=0, n=0, rate=None, note="no seeds")
    # Wilson 95% interval -- an exact binomial interval is wrong near 0 and 1,
    # which is exactly where these campaigns live.
    import math
    z = 1.959963985
    ph = k / n
    d = 1 + z * z / n
    c = (ph + z * z / (2 * n)) / d
    hw = z * math.sqrt(ph * (1 - ph) / n + z * z / (4 * n * n)) / d
    return dict(k=k, n=n, rate=ph,
                ci95=(max(0.0, c - hw), min(1.0, c + hw)),
                text="%d/%d = %.3f  (95%% CI %.3f-%.3f)" % (k, n, ph, max(0.0, c - hw), min(1.0, c + hw)))


def report(r):
    """The block that must accompany any published count."""
    L = []
    L.append("== double-run report: %s ==" % r["label"])
    L.append("seeds          : %s" % (r["seeds"],))
    L.append("AGREE          : %s" % ("YES" if r["agree"] else "NO -- DO NOT PUBLISH"))
    if not r["agree"]:
        L.append("differing seeds: %s" % r["flaky_seeds"])
        L.extend(r["diff"])
    if r["errors"]:
        L.append("errors         : %s" % r["errors"])
    tot1 = sum(r["timings_1"])
    tot2 = sum(r["timings_2"])
    L.append("wall total     : pass1 %.2fs  pass2 %.2fs  (NOT compared; jitter is expected)"
             % (tot1, tot2))
    return "\n".join(L)


if __name__ == "__main__":
    import random as _r

    print("== TEST 7a: a STABLE measurement agrees ==")
    r = double_run(lambda s: {"hit": (s * 7) % 3 == 0}, seeds=range(12))
    print(report(r))
    assert r["agree"], "stable fn must agree"

    print()
    print("== TEST 7b: an UNSTABLE measurement is CAUGHT (this is the point) ==")
    # Simulates exactly the r53 threshold_test drift: same seed, different answer.
    _calls = {"n": 0}

    def flaky(s):
        _calls["n"] += 1
        return {"hit": ((s * 7) % 3 == 0) if _calls["n"] <= 12
                else ((s * 7) % 3 == 1)}

    r2 = double_run(flaky, seeds=range(12), label="simulated unseeded drift")
    print(report(r2))
    assert not r2["agree"], "unstable fn MUST be flagged"
    assert r2["flaky_seeds"], "flaky seeds must be named"
    print("  PASS: drift is detected and the differing seeds are named")

    print()
    print("== TEST 7c: timing jitter alone is NOT a disagreement ==")
    r3 = double_run(lambda s: time.sleep(0.001 * (s % 3)) or {"hit": True},
                    seeds=range(6), label="jitter only")
    print(report(r3))
    assert r3["agree"], "pure timing jitter must not count as drift"

    print()
    print("== TEST 7d: rate() reports a RATE with a CI, not pass/fail ==")
    print("  3/12  ->", rate([True] * 3 + [False] * 9)["text"])
    print("  10/12 ->", rate([True] * 10 + [False] * 2)["text"])
    print("  0/12  ->", rate([False] * 12)["text"])
    print("  12/12 ->", rate([True] * 12)["text"])
    lo = rate([False] * 12)["ci95"]
    print("  Wilson upper bound at 0/12 is %.3f, NOT 0 -> 0/12 does not mean impossible" % lo[1])
    assert lo[1] > 0.10, "CI must not collapse to a point at 0/n"
    print()
    print("ALL DOUBLE-RUN TESTS PASS")