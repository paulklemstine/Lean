# Computational evidence — harmonic bulk × steeper edge

All *verified* claims of this cycle live in
`Catalog/Probability/HarmonicBulkSteeperEdge.lean` and are machine-checked, sorry-free Lean 4
proofs. The numbers below are exploratory floating-point calculations that were used to
choose and sanity-check the statements before formalisation; they are **not** themselves
verification.

## 1. The recorded tension, in numbers

The carried-forward tension is a bulk exponent `≈ 1.104` versus head statistics implying a
steeper exponent (edge fraction `.2346 → ≈ .22`, first decile `.162 → ≈ .14`,
peak/end `2.54 → ≈ 2.10`).

For a pure power-law kernel `k ↦ k^(-a)` the peak/end ratio on the first two cells is
exactly `2^a`:

| statistic | value | implied exponent |
|---|---|---|
| bulk fit | — | `1.104` |
| `2^1.104` | `2.1495` | — |
| recorded peak/end | `2.54` | `log₂ 2.54 = 1.3448` |

So the two readings differ by `≈ 0.24` in exponent: no single power law fits both.
This is formalised twice — abstractly, as
`no_single_exponent_fits_two_windows` (two head windows with different implied exponents
admit no common exponent), and concretely, as
`pure_power_law_peak_end_lt_observed` (`a ≤ 1.104 ⟹ 2^a < 2.54`).

## 2. An exact two-component resolution

Harmonic bulk `a = 1`, quadratic edge `b = 2`, mixture weight `w`:
peak/end `= 4/(2 − w)`, so `w = 2 − 4/2.54 = 54/127 = 0.4251968…` reproduces `2.54`
exactly. Verified in Lean as `harmonic_edge_mixture_matches_observed_peak_end`
(an exact rational identity, no floating point involved).

## 3. Window-implied exponents of the mixture (the key numerical pattern)

Implied exponent = the unique `c` with `headMass c n m` equal to the mixture's head mass on
`{1,…,m}` inside `{1,…,n}` (found by bisection; the uniqueness is proved in Lean).

| n \ m | 1 | 2 | 5 | 20 | 100 |
|---|---|---|---|---|---|
| 50 | 1.2072 | 1.1835 | 1.1522 | 1.1144 | — |
| 200 | 1.1709 | 1.1503 | 1.1235 | 1.0918 | 1.0683 |
| 1000 | 1.1410 | 1.1233 | 1.1006 | 1.0741 | 1.0548 |

Every row is strictly decreasing in the window width `m`, and every entry lies in `(1,2)`.
Both features are now theorems: `mix_implied_exponent_mem_Ioo` (membership in `(a,b)`) and
`implied_exponent_antitone` (antitone in `m`), the latter proved via a single-crossing
argument resting on quasiconvexity of the mixture-to-power-law ratio
(`two_term_rpow_quasiconvex`).

## 4. Saturation dichotomy of the dial

`headMass a n 5` as the truncation `n` grows:

| a | n = 50 | 200 | 1000 | 10000 |
|---|---|---|---|---|
| 1.5 | 0.7553 | 0.7124 | 0.6906 | 0.6791 |
| 1.0 (harmonic) | 0.5075 | 0.3885 | 0.3050 | 0.2333 |

The `a = 1.5` column saturates; the harmonic column decays towards `0` (like `1/log n`).
Formalised as `headMass_tendsto_pos_of_one_lt` and `headMass_tendsto_zero_of_le_one`:
the saturation threshold is exactly `a = 1`, with the harmonic kernel on the
non-saturating side.

## 5. Head bias versus equal-weight counting

`headMass 0.5 100 10 = 0.2701` against the equal-weight share `10/100 = 0.1`.
Formalised in general as `headMass_gt_uniform`.

## 6. Counterexample hunt

* Searched for a violation of antitonicity of the implied exponent over
  `w ∈ {0.1,…,0.9}`, `(a,b)` with `a < b` in `{0.5, 1, 1.5, 2, 3}`, `n ≤ 1000`: none found —
  consistent with the theorem now proved.
* Termwise ("likelihood-ratio") proofs of the window law *fail*: the mixture-to-power-law
  ratio is U-shaped, not monotone, so any proof must use the single-crossing structure. This
  ruled out an earlier, simpler proof plan and is the reason the Lean proof goes through
  quasiconvexity.

No OEIS sequence is relevant here (all quantities are real-valued statistics of a
continuously parametrised kernel family).

## 7. Continuation cycle: strictness and the harmonic decay rate

*(Exploratory `Float` computations; the corresponding verified statements are named after
each item.)*

* **Strictness of the window law.** For `w = 0.4`, `(a,b) = (1,2)`, `n = 200`, the implied
  exponents at windows `m = 1, 10, 100` come out as `1.171 > 1.118 > 1.068`: strictly
  decreasing, never flat. Verified in general as
  `implied_exponent_strictAnti` (Catalog/Probability/HarmonicBulkSteeperEdgeStrict.lean).
* **Harmonic decay rate.** `headMass 1 n m · log n` for `m = 10`: at `n = 10^5` the product
  is `2.789` against `H(10) = 2.929` — convergence from below, at rate `O(1/log n)`.
  Verified as `headMass_one_mul_log_tendsto`.
* **Squaring halves the dial.** `H(100)/H(10000) = 0.5300` and
  `H(400)/H(10^6) = 0.4565`; both near `1/2`, matching
  `headMass_one_square_ratio_tendsto`. This is the quantitative content of the "saturates
  by ℓ = 400" observation: over the recorded range the harmonic dial moves by only a few
  percent per decade even though its limit is `0`.

## 8. Continuation cycle: the sub-harmonic rate

*(Exploratory `Python` float computations; the corresponding verified statements are named
after each item. Window `m = 10` throughout.)*

* **Polynomial collapse `headMass a n m · n^(1-a) → (1-a)·headSum a m`.**

  | `a` | `n = 10³` | `n = 10⁴` | `n = 10⁵` | predicted limit `(1-a)·headSum a m` |
  |-----|-----------|-----------|-----------|-------------------------------------|
  | 0.5 | 2.5692    | 2.5289    | 2.5163    | 2.5105 |
  | 0.8 | 0.9175    | 0.8297    | 0.7825    | 0.7130 |

  Convergence from above, slowly for `a` near the harmonic threshold (the correction is
  `O(n^{a-1})`, which is `n^{-0.2}` at `a = 0.8`). Verified as
  `headMass_mul_rpow_tendsto` (Catalog/Probability/SubHarmonicSaturationRate.lean).

* **Doubling calibration.** Measured ratio `headMass a (2n) m / headMass a n m` at
  `n = 10⁵`: `0.7066` for `a = 0.5` against `2^(a-1) = 0.7071`, and `0.8597` for `a = 0.8`
  against `0.8706`. Verified as `headMass_doubling_ratio_tendsto`. Contrast the harmonic
  case, where the same ratio tends to `1`: the doubling ratio is itself a readout of the
  exponent below the threshold.
