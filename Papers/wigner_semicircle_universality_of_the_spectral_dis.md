# Computational Evidence — Wigner Semicircle Law

All computations below were performed in Lean with **exact rational arithmetic**
(`ℚ`, no floating point, no sampling) by *complete enumeration* of the
`2^(N(N-1)/2)` sign configurations of the Rademacher Wigner ensemble.  The code is
in `Catalog/Probability/WignerEvidence.lean`; the `#eval` commands are left
commented out there so the module builds instantly, and the numbers below are the
output obtained by re-enabling them.

**Status of the numbers.** They come from `#eval` (exact rational arithmetic, but
evaluated by the compiler/interpreter, *not* kernel-checked). They are therefore
reported as evidence, not as verified theorems. Where a formula was subsequently
*proved*, this is stated explicitly and the theorem is named.

## 1. The model

`W` is the `N × N` symmetric matrix with `W i i = 0` and, for `i ≠ j`,
`W i j = ±1` uniformly and independently over the `N(N-1)/2` unordered pairs.
`E[·]` is the uniform average over all sign configurations.

## 2. Small-case trace moments

| `N` | `E[tr W²]` | `E[tr W³]` | `E[tr W⁴]` | `E[tr W⁵]` | `E[tr W⁶]` |
|-----|-----------|-----------|-----------|-----------|-----------|
| 1 | 0 | 0 | 0 | 0 | 0 |
| 2 | 2 | 0 | 2 | 0 | 2 |
| 3 | 6 | 0 | 18 | 0 | 66 |
| 4 | 12 | 0 | 60 | 0 | 372 |
| 5 | 20 | 0 | 140 | — | 1220 |
| 6 | — | — | — | — | 3030 |

Number of configurations enumerated: `2^0, 2^1, 2^3, 2^6, 2^10, 2^15` for
`N = 1,…,6` (the `N = 6` row required enumerating all 32768 sign patterns).

## 3. Matching against proved formulas

* `E[tr W²] = N(N-1)`: values `0, 2, 6, 12, 20` — matches. Proved (in the much
  stronger deterministic form `tr W² = N² - N` for *every* configuration) as
  `RademacherWigner.trace_W_sq`.
* `E[tr W³] = 0`, `E[tr W⁵] = 0`: matches the proved vanishing of odd moments
  (`WignerUniversal.gexpect_trace_three`, and `semicircleMoment_odd` on the
  semicircle side).
* `E[tr W⁴] = 2N(N-1)² - N(N-1)`: predicted `0, 2, 18, 60, 140` — matches the table
  exactly. Proved as `RademacherWigner.expect_trace_W_four`, and generalised to an
  arbitrary centred unit-variance entry law with fourth moment `m₄` as
  `WignerUniversal.gexpect_trace_four`:
  `E[tr W⁴] = 2N(N-1)² - 2N(N-1) + m₄ N(N-1)` (`m₄ = 1` for signs).

## 4. Sixth moment: the interpolated formula (conjecture)

The five data points `0, 2, 66, 372, 1220` have constant fourth finite difference
`120`, hence are fitted exactly by a quartic. Newton interpolation gives

```
E[tr W⁶] = 5N⁴ - 20N³ + 26N² - 11N = N(N-1)(5N² - 15N + 11).
```

Checks: `N=1 ↦ 0`, `N=2 ↦ 2`, `N=3 ↦ 66`, `N=4 ↦ 372`, `N=5 ↦ 1220`. The quartic
was fitted on `N ≤ 5` (five data points, five coefficients), so `N = 6` is a
genuine out-of-sample test: the formula predicts `6·5·(180-90+11) = 3030`, and the
brute-force enumeration over all `2^15` configurations returns exactly `3030`. The leading
coefficient is `5 = C₃`, the third Catalan number, exactly as the semicircle law
predicts (`WignerSemicircle.semicircleMoment_two_mul` gives `m₆ = C₃ = 5`). The
subleading coefficients `-20, 26, -11` are the content of Conjecture 1 of
`FUTURE_DIRECTIONS.md`. This formula is **not proved** here.

## 5. Counterexample hunt

* *Is the second moment self-averaging?* For every enumerated configuration at
  `N = 2,3,4,5` the value of `tr W²` was constant, equal to `N² - N`. No
  counterexample. This is now a theorem (`RademacherWigner.trace_W_sq`), so the
  hunt is closed.
* *Is the fourth moment self-averaging?* No. At `N = 3` the enumeration gives
  `tr W⁴ = 18` for every configuration, which suggested self-averaging; but the
  proved general formula `E[tr W⁴] = 2N(N-1)² - 2N(N-1) + m₄N(N-1)` has an
  `m₄`-dependent term, so the fourth moment cannot be configuration-independent for
  a general entry law. The `N = 3` coincidence is an artefact of the sign ensemble
  at small `N`, and this is exactly why the fourth-moment result was formalised in
  expectation rather than deterministically.
* *Does the entry law affect the limit?* The formula
  `2N(N-1)² - 2N(N-1) + m₄N(N-1)` has an `m₄` term of order `N²`, which is
  invisible after dividing by `N³`. So no counterexample to universality at order
  four can exist — this is the proved theorem
  `WignerUniversal.tendsto_gexpect_normalizedMoment_four`.

## 6. OEIS

The sixth-moment sequence `0, 2, 66, 372, 1220` (`N = 1,2,3,4,5`) is a polynomial
sequence; no OEIS identification was attempted and none is claimed. The Catalan
numbers `1, 1, 2, 5, 14, …` appearing as the even semicircle moments are
[OEIS A000108](https://oeis.org/A000108); Mathlib's `catalan` is used directly, so
this identification is part of the proved statement
`WignerSemicircle.semicircleMoment_two_mul`.

## 7. Kernel-verified enumeration (final cycle)

The numerical evidence above was originally produced by `#eval` in
`Catalog/Probability/WignerEvidence.lean`, i.e. by the Lean *evaluator*.  Since
`RademacherWigner.IsEvenWalk` is decidable and
`RademacherWigner.expect_trace_pow_eq_card` identifies each trace moment with the
cardinality of the finite set `evenWalks N m`, several of these values are now
*theorems checked by the Lean kernel* (`Catalog/Probability/WignerEvenWalkCount.lean`):

| statement | value | Lean name |
|---|---|---|
| even closed 4-walks, `N = 3` | 18 | `card_evenWalks_three_four` |
| even closed 4-walks, `N = 4` | 60 | `card_evenWalks_four_four` |
| even closed 6-walks, `N = 2` | 2 | `card_evenWalks_two_six` |
| even closed 6-walks, `N = 3` | 66 | `card_evenWalks_three_six` |
| even closed 3-walks, `N = 3` | 0 | `card_evenWalks_three_three` |
| even closed 5-walks, `N = 3` | 0 | `card_evenWalks_three_five` |

and hence `E[tr W⁴] = 18` at `N = 3`, `= 60` at `N = 4`, `E[tr W⁶] = 2` at `N = 2`,
`= 66` at `N = 3`, and `E[tr W⁵] = 0` at `N = 3`.  These agree with the brute-force
configuration sums of §1–§4, so the evaluator-level data and the kernel-level
theorems are mutually consistent; the sixth-moment entries are a kernel confirmation
of Conjecture 1 of `FUTURE_DIRECTIONS.md` at `N = 2, 3`.  The corresponding check at
`N = 4` (predicted value `372`) exceeds the default elaboration limits and was not
attempted as a theorem.
