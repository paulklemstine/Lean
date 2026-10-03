# I repeated the exact bug I had just written up

**Round 48, ~15:05, orchestrator. Recorded because the recurrence is the finding.**

## What happened

At 13:41 I wrote `notes/Q_vacuous_measurement.md` after a negative control caught a
"measurement" of mine that was **100% pigeonhole** — it agreed with a preregistered hypothesis
to within 26% for reasons having nothing to do with it. The rule I extracted and recorded:

> **A self-test that only shows your code running is not a self-test.** The test is whether the
> harness returns the null answer where null is correct.

At 15:05, ninety minutes later, I wrote `supply_rate_check.py` to independently test the
supply-audit claim that `rate ~ |c|^(-0.30)`. My measurement function was:

```python
def supply_rate(n, c, rng, trials=2000):
    for _ in range(trials):
        m = rng.randint(m0, 2*m0)
        if (m*m*m - c) % 2 == 1:      # <-- proxy for "usable chi_P = -1 branch"
            good += 1
    return good / trials
```

**That proxy has essentially no `c`-dependence by construction.** The measurement returned
`beta = +0.0042` against the audit's claimed `−0.30`, and I was one step from writing "the
supply audit's mechanism is refuted."

## My self-test passed — and that is the point

The self-test I wrote verified that the **log-log fit** recovers a known exponent:

```
[PASS] fit on synthetic c^-0.30 family -> -0.3000
[PASS] fit on synthetic c^-1.00 family -> -1.0000
[PASS] fit distinguishes the two families
```

All green. And **completely irrelevant**, because the defect was not in the fit — it was in
the quantity being fitted. My synthetic families were hand-written as clean power laws; the
real `supply_rate` was not. So the self-test exercised the part that worked and skipped the
part that was broken.

This is a **sharper** failure than the 13:41 one, and worth distinguishing:

| | 13:41 (pigeonhole) | 15:05 (this) |
|---|---|---|
| defect | statistic is true by combinatorics | statistic is true by construction of my proxy |
| negative control | **present**, and it fired | **absent** |
| self-test | passed 3 of 4 | passed, and was **the wrong test** |

The 13:41 bug was caught because I had written a control. This one was not caught because I
didn't. **Writing the rule down did not make me follow it** — the rule was in a file, and I
wrote a self-test that felt like compliance while testing the wrong component.

## The generalization (this is the transferable part)

> **A self-test must exercise the SAME quantity the claim is about.** Testing a downstream
> component — a fit, a parser, a formatter — while the upstream *measurement* is a stub or a
> proxy is a green light wired to nothing.

Concretely, for any "does X depend on Y?" claim, the self-test must be:

> *Feed the harness two synthetic families with KNOWN, DIFFERENT dependence on Y. If it
> returns the same answer for both, it cannot measure that dependence.*

I wrote that test — for the fit. It needed writing for `supply_rate`, which is the thing
actually making the claim. The test existed; it was pointed at the wrong object.

## What is NOT claimed

**The audit's `beta ≈ 0.30` is neither confirmed nor refuted by this.** My number is void.
The audit's decomposition — pool composition a flat 1.24× contributing no growth, all of the
growth in `|c|` — remains standing on its own measurements, and its control passed at 0.92σ.

The only honest statement available from this tick is negative about my own work: **I do not
have an independent check on the supply mechanism**, because the one I built cannot detect the
effect it was built to detect.

## Status of the script

`_shared/supply_rate_check.py` is retained, not deleted, with its `supply_rate` function
marked VOID. Its `fit_exponent` helper is sound and reusable; its `supply_rate` is a stub
that must be replaced with the program's actual `chi_P` relation test before any rate it
produces means anything.