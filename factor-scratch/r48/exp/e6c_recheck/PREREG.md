# PREREGISTRATION — E-6c recheck (H1 / H2 / H3)

Written **before** the measurement code was run. `e6c_recheck.py` embeds the
sha256 of this file and refuses to run if it does not match, so the
hypotheses below cannot be edited after seeing results.

## The claim under test

`Experiments/FACTORING_PROGRAM_SUMMARY.md` claims:

> "E-6c: at ~29-bit class numbers, 0.720 vs 0.440 — ~1.6x smoothness
> advantage over elliptic curves at matched scale. First positive at-scale
> signal for a non-EC lottery."

`Experiments/e6c_results.json` in full: `{"n": 25, "class_smooth": 0.72, "ec_smooth": 0.44}`.

No `.py` was ever committed for E-6b/E-6c/E-7 (verified via
`git log --all --diff-filter=A`), so nothing about this is checkable.

## Why this must be redone rather than trusted

`notes/M_forensics.md` shows E-6b's "EC baseline 0.925" equals
`rho(log2(1684)/log2(1000)) = 0.9273` — the Dickman prediction for its *own*
class-number arm's bit-length. It is a prediction, not an ECM measurement.

The E-6c pair is more interesting: at 29 bits and B = 1000, Dickman predicts
`rho(29/log2(1000)) = rho(2.910) = 0.0587`, so 0.720 sits **12.3x above
uniform** — and 0.440 sits 7.5x above uniform. If real, that is a
distributional discovery. If the arm was mis-measured, it is an artifact.

## Hypotheses (preregistered)

**H1 — class numbers are unusually smooth.**
`P(h(-q) is B-smooth) > rho(log2 h / log2 B)` for q prime ≡ 3 mod 4.
**Direction predicted in advance: ABOVE uniform.**
Primary quantity: the ratio `rate_class / mean_dickman`, with a 95% interval.
To be tested at several B and several scales, not one cell.

**H2 — the advantage is real against a CORRECT EC baseline.**
Implement a genuine ECM-order arm: for a **known** p, sample curves over F_p,
compute the group order, and measure its B-smoothness with the SAME
`is_smooth` from the shared harness. Matched by **binning on measured
bit-length**, not by assuming the arms share a nominal scale.
Primary quantity: `rate_class / rate_ec` within a bit-length bin, 95% interval.

**H3 — the "~1.6x at matched scale" claim.**
Measure the corrected ratio at matched scale and state whether 1.6 survives.
A ratio of 1.6 survives only if its 95% interval contains 1.6 and excludes 1.

## Controls preregistered as mandatory (a control that runs only at the
## parameter it was derived at is not a control)

1. **Multiple B.** B ∈ {1e3, 1e4, 1e5, 1e6}. B = 1e3 is the original's B.
2. **Multiple scales.** q ∈ [2^21, 2^31, 2^41, 2^51, 2^61]; p ∈ [2^16, 2^36].
3. **Bit-length binning.** Every comparison is made *within* a bin of the
   measured bit-length of the object, so no comparison depends on the two
   arms having the same nominal scale.
4. **A third arm: random ODD integers at matched bit-length.** By genus
   theory `h(-q)` is ODD for q ≡ 3 mod 4 prime (2-rank of Cl = t-1 = 0), so it
   never carries a factor 2, whereas a uniform integer carries one with
   probability 1/2. This control separates "class numbers are unusually
   smooth" from "class numbers are just odd integers". **This control was not
   in the original.**
5. **The harness's own null.** `dickman.ecm_baseline_smooth_rate` at the same
   bit-lengths, to confirm the harness reproduces rho where it must.
6. **Negative controls.** The self-test's EC-order certifier must REJECT
   perturbed orders; the smoothness counter must separate known-smooth from
   known-rough.

## Statistical treatment (fixed in advance)

- Proportions: Wilson score interval, 95%.
- Ratio of two independent proportions: nonparametric bootstrap, 10000
  resamples, seed 20261003, percentile interval.
- Class vs EC at matched bin: Fisher exact test, two-sided.
- A ratio is called "surviving" only if its interval contains the claimed
  value AND excludes 1.

## Falsification conditions (fixed in advance)

- **H1 is refuted** if the 95% interval for `rate_class / mean_dickman`
  contains 1 at ANY (B, scale) cell — i.e. class numbers are uniform-smooth
  — or if it lies entirely BELOW 1 (which would refute it in the opposite
  direction).
- **H2 is refuted** if the 95% interval for `rate_class / rate_ec` contains 1
  at the matched cells.
- **H3 is refuted** unless 1.6 ∈ the interval and 1 ∉ the interval.
- The "first positive at-scale signal" claim survives **only if H2 holds**.

## Known structural fact that cuts against the claim

Genus theory: for q prime ≡ 3 mod 4, the discriminant D = -q has t = 1 prime
discriminant, so the 2-rank of the class group is t-1 = 0 and **h(-q) is odd**.
A uniform integer of the same bit-length is even half the time and thus gains
a free factor 2 contributing ~1 bit of size. This biases h(-q) toward being
LESS smooth than uniform, and control 4 above is designed to expose the size
of that bias.

## Instruments

- Python 3.12.3, sympy 1.13.1, cypari2 (PARI 2.15-ish), numpy, scipy.
- Smoothness: `/home/raver1975/lean/factor-scratch/r48/_shared/dickman.py`,
  used as-is. **No smoothness function is written in this directory.**
- Class numbers: PARI `qfbclassno(-q)`, certified in `selftest.py` against an
  independent reduced-binary-quadratic-form enumeration.
- EC orders: PARI `ellcard` on `ellinit([a4,a6],p)`, every sampled order
  algebraically certified in `selftest.py`.
- Everything computed with a p is labelled **[uses p]** in the output JSON.

## Integrity

`e6c_recheck.py` reads this file, hashes it, and compares against the
constant `_PREREG_SHA256` baked into its source. A mismatch aborts the run.
